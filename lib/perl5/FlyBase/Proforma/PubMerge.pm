package FlyBase::Proforma::PubMerge;

# DC-1120: move data from a losing pub to the winning pub in a P32 pub merge.
#
# update_pub (Util.pm) moves rows for a fixed list of feature/phenotype tables.
# This module moves rows in every other table that has a foreign key to pub,
# working from the database schema rather than a hand-written block per table:
#
#   - For each row attached to the losing pub, write the row again with the
#     winning pub (plus its child rows, e.g. *prop, *cvtermprop), then delete
#     the losing pub's row. Parent rows are written as op="lookup" elements
#     built from each table's unique key (these match XORT's ddl.properties).
#   - If the winning pub already has the same row, only the child rows it is
#     missing are added (with new ranks where needed).
#   - pub_relationship rows are moved with curator rules (see
#     merge_pub_relationships).
#   - Any pub-linked table whose rows cannot be moved is reported with an
#     "ERROR:" line so that nothing is lost silently.

use strict;
use warnings;
use XML::DOM;
use FlyBase::WriteChado;
use FlyBase::Proforma::Util qw(dom_toString);
require Exporter;

our @ISA    = qw(Exporter);
our @EXPORT = qw(merge_pub_links);

# Tables moved by update_pub in Util.pm (not touched here).
my %UPDATE_PUB_TABLES = map { $_ => 1 } qw(
  feature_pub feature_relationship_pub featureloc_pub featureprop_pub
  feature_synonym feature_cvterm phendesc phenstatement phenotype_comparison
  pubprop
);

# Pub-level tables that are deliberately left on the losing pub:
# its authors, and its own IDs (PMID, DOI, etc.; P32 itself adds the losing
# FBrf to the winner as a secondary FlyBase pub_dbxref).
my %NOT_MOVED_TABLES = map { $_ => 1 } qw( pubauthor pub_dbxref );

# Pub-linked tables that XORT cannot load (not in harvdev-xorted ddl.properties),
# so writing XML for them would abort the whole load. Their rows stay on the
# losing pub and are reported:
# - genotype_relationship ("is_represented_at_alliance_as") is written only by
#   harvdev-production-bulk-update make_alliance_genotypes.py, which derives its
#   pub from the genotype's phenotype data (moved by update_pub). A reassess
#   run (-r) regenerates these links under the winning pub.
# - pub_analysis_feature has no XORT support; its rows are reported as not moved.
my %NOT_IN_XORT_SCHEMA = (
    genotype_relationship =>
      'STATE: regenerated under the winning pub by make_alliance_genotypes.py -r (reassess)',
    pub_analysis_feature =>
      'ERROR: table not in the XORT schema, cannot be moved by the parser',
);

# pub_relationship types that are not moved: the winning pub has its own journal.
my %PR_TYPES_NOT_MOVED = map { $_ => 1 } qw( published_in );

my %meta_cache = ();
my @pub_fks    = ();
# State kept for the whole parser run, so that several losing pubs merged
# into the same winner (one P32 list, or several records in one load) do not
# write the same row or child row twice:
my %rank_used  = ();    # child ranks used, by winner + row + child table + type
my %written    = ();    # rows written for a winner in this run, with child signatures
my %pr_written = ();    # pub_relationship links written for a winner in this run

# $all_losers (optional): every FBrf in the P32 field, so that links between
# pubs being merged into the same winner are not moved.
sub merge_pub_links {
    my ( $dbh, $doc, $winner, $loser, $all_losers ) = @_;
    my $out = '';

    my $loser_id  = get_pub_id( $dbh, $loser );
    my $winner_id = get_pub_id( $dbh, $winner );    # undef for a new pub
    if ( !defined($loser_id) ) {
        print STDERR "ERROR: P32 merge: could not find pub $loser\n";
        return $out;
    }
    my $ctx = {
        dbh       => $dbh,
        doc       => $doc,
        winner    => $winner,
        loser     => $loser,
        winner_id => $winner_id,
        loser_id  => $loser_id,
        losers    => { map { my $u = $_; $u =~ s/^\s+|\s+$//g; ( $u => 1 ) } ( $loser, @{ $all_losers || [] } ) },
    };

    foreach my $fk ( get_pub_fks($dbh) ) {
        my ( $table, $col ) = @{$fk};
        next if ( $UPDATE_PUB_TABLES{$table} || $NOT_MOVED_TABLES{$table} );
        next if ( $table eq 'pub_relationship' );    # handled below
        if ( my $why = $NOT_IN_XORT_SCHEMA{$table} ) {
            my ($n) = $dbh->selectrow_array( "SELECT count(*) FROM $table WHERE $col = ?", undef, $loser_id );
            if ($n) {
                my ( $level, $reason ) = split( /: /, $why, 2 );
                print STDERR "$level: P32 merge $loser->$winner: $n rows in $table not moved ($reason)\n";
            }
            next;
        }

        my $sql = "SELECT * FROM $table WHERE $col = ?";
        if ( $table eq 'feature_relationshipprop_pub' ) {

            # update_pub already moves these when the parent
            # feature_relationship is also attached to the losing pub.
            $sql .= " AND NOT EXISTS (SELECT 1 FROM feature_relationshipprop frp,"
              . " feature_relationship_pub frpub"
              . " WHERE frp.feature_relationshipprop_id = $table.feature_relationshipprop_id"
              . " AND frpub.feature_relationship_id = frp.feature_relationship_id"
              . " AND frpub.pub_id = ?)";
        }
        my $sth = $dbh->prepare($sql);
        if ( $table eq 'feature_relationshipprop_pub' ) {
            $sth->execute( $loser_id, $loser_id );
        }
        else {
            $sth->execute($loser_id);
        }
        my $rows = $sth->fetchall_arrayref( {} );
        next unless @{$rows};

        my $meta = get_meta( $dbh, $table );
        if ( !@{ $meta->{uk} } || !grep { $_ eq $col } @{ $meta->{uk} } ) {
            print STDERR "ERROR: P32 merge $loser->$winner: "
              . scalar( @{$rows} )
              . " rows in $table will not be moved (no unique key with $col)\n";
            next;
        }
        print STDERR "STATE: P32 merge $loser->$winner: moving "
          . scalar( @{$rows} )
          . " rows in $table\n";
        foreach my $row ( @{$rows} ) {
            my $xml = eval { move_row( $ctx, $table, $col, $row ) };
            if ($@) {
                print STDERR "ERROR: P32 merge $loser->$winner: could not move $table "
                  . "row $row->{$meta->{pk}}: $@\n";
                next;
            }
            $out .= $xml;
        }
    }
    $out .= merge_pub_relationships($ctx);
    return $out;
}

# Write one row again with the winning pub, with its child rows, then delete
# the losing pub's row.
sub move_row {
    my ( $ctx, $table, $col, $row ) = @_;
    my $dbh  = $ctx->{dbh};
    my $doc  = $ctx->{doc};
    my $meta = get_meta( $dbh, $table );

    my $winner_row = find_winner_row( $ctx, $table, $col, $row );
    my $row_key    = join( '|', $ctx->{winner}, $table,
        map { defined( $row->{$_} ) && $_ ne $col ? $row->{$_} : '' } @{ $meta->{uk} } );

    # The winner already has this row: in the database, or written earlier in this run.
    my $exists = ( $winner_row || $written{$row_key} ) ? 1 : 0;
    $written{$row_key} ||= { sigs => {}, loaded => {} };

    my $add = $doc->createElement($table);
    foreach my $c ( @{ $meta->{uk} } ) {
        my $el = col_element( $ctx, $table, $c, $row->{$c}, $c eq $col ? 'winner' : undef );
        $add->appendChild($el) if $el;
    }
    if ( !$exists ) {

        # New row for the winner: copy the other columns too (is_current etc.).
        foreach my $c ( @{ $meta->{cols} } ) {
            next if ( $c eq $meta->{pk} || grep { $_ eq $c } @{ $meta->{uk} } );
            next unless defined( $row->{$c} );
            my $el = col_element( $ctx, $table, $c, $row->{$c} );
            $add->appendChild($el) if $el;
        }
    }
    foreach my $child ( @{ $meta->{children} } ) {
        my ( $ctable, $cfk ) = @{$child};
        foreach my $cel ( child_elements( $ctx, $ctable, $cfk, $row->{ $meta->{pk} }, $winner_row, $row_key, $exists ) ) {
            $add->appendChild($cel);
        }
    }
    my $out = dom_toString($add);

    my $del = $doc->createElement($table);
    $del->setAttribute( 'op', 'delete' );
    foreach my $c ( @{ $meta->{uk} } ) {
        my $el = col_element( $ctx, $table, $c, $row->{$c}, $c eq $col ? 'loser' : undef );
        $del->appendChild($el) if $el;
    }
    $out .= dom_toString($del);
    return $out;
}

# Child rows (props etc.) of a moved row. If the winner already has the row
# (in the database or written earlier in this run), skip children it already
# has and give the others free ranks.
sub child_elements {
    my ( $ctx, $ctable, $cfk, $parent_id, $winner_row, $row_key, $exists ) = @_;
    my $dbh   = $ctx->{dbh};
    my $doc   = $ctx->{doc};
    my $cmeta = get_meta( $dbh, $ctable );
    my @els   = ();

    my $sth = $dbh->prepare("SELECT * FROM $ctable WHERE $cfk = ?");
    $sth->execute($parent_id);
    my $rows = $sth->fetchall_arrayref( {} );
    return @els unless @{$rows};

    foreach my $gchild ( @{ $cmeta->{children} } ) {
        my ( $gtable, $gfk ) = @{$gchild};
        my $n = $dbh->selectrow_array(
            "SELECT count(*) FROM $gtable WHERE $gfk IN (SELECT $cmeta->{pk} FROM $ctable WHERE $cfk = ?)",
            undef, $parent_id );
        if ($n) {
            print STDERR "ERROR: P32 merge $ctx->{loser}->$ctx->{winner}: $n $gtable rows "
              . "under $ctable will not be moved\n";
        }
    }

    my @value_cols = grep { $_ ne $cmeta->{pk} && $_ ne $cfk } @{ $cmeta->{cols} };
    my @sig_cols   = grep { $_ ne 'rank' } @value_cols;
    my $has_rank   = grep { $_ eq 'rank' } @value_cols;

    # Children the winner's row already has: from the database (read once
    # per row) plus those written earlier in this run.
    my $state = $written{$row_key};
    my $sigs  = ( $state->{sigs}{$ctable} ||= {} );
    if ( $winner_row && !$state->{loaded}{$ctable}++ ) {
        my $wrows = $dbh->selectall_arrayref( "SELECT * FROM $ctable WHERE $cfk = ?",
            { Slice => {} }, $winner_row->{_pk} );
        foreach my $w ( @{$wrows} ) {
            $sigs->{ signature( $w, \@sig_cols ) } = 1;
            if ($has_rank) {
                my $rk = rank_key( $row_key, $ctable, $w );
                $rank_used{$rk}{ $w->{rank} } = 1;
            }
        }
    }

    foreach my $r ( @{$rows} ) {
        my $sig = signature( $r, \@sig_cols );
        next if ( $exists && $sigs->{$sig} );
        $sigs->{$sig} = 1;
        my $el = $doc->createElement($ctable);
        foreach my $c (@value_cols) {
            my $v = $r->{$c};
            if ( $c eq 'rank' ) {
                my $rk = rank_key( $row_key, $ctable, $r );
                if ($exists) {
                    $v = 0;
                    $v++ while ( $rank_used{$rk}{$v} );
                }
                $rank_used{$rk}{$v} = 1;
            }
            next unless defined($v);
            my $cel = col_element( $ctx, $ctable, $c, $v );
            $el->appendChild($cel) if $cel;
        }
        push( @els, $el );
    }
    return @els;
}

sub signature {
    my ( $row, $cols ) = @_;
    return join( "\x1f", map { defined( $row->{$_} ) ? $row->{$_} : "\x00" } @{$cols} );
}

sub rank_key {
    my ( $row_key, $ctable, $r ) = @_;
    return join( '|', $row_key, $ctable, defined( $r->{type_id} ) ? $r->{type_id} : '' );
}

# The winning pub's copy of a row, if it already exists (same unique key).
sub find_winner_row {
    my ( $ctx, $table, $col, $row ) = @_;
    return undef unless defined( $ctx->{winner_id} );
    my $meta  = get_meta( $ctx->{dbh}, $table );
    my @where = ();
    my @vals  = ();
    foreach my $c ( @{ $meta->{uk} } ) {
        push( @where, "$c IS NOT DISTINCT FROM ?" );
        push( @vals, $c eq $col ? $ctx->{winner_id} : $row->{$c} );
    }
    my $w = $ctx->{dbh}->selectrow_hashref(
        "SELECT * FROM $table WHERE " . join( ' AND ', @where ),
        undef, @vals );
    $w->{_pk} = $w->{ $meta->{pk} } if $w;
    return $w;
}

# <col>value</col>, or <col><parent op="lookup">...</parent></col> for a
# foreign key. $which = 'winner'/'loser' writes the pub macro id.
sub col_element {
    my ( $ctx, $table, $col, $value, $which ) = @_;
    my $doc = $ctx->{doc};
    return undef unless defined($value);
    my $el = $doc->createElement($col);
    if ($which) {
        $el->appendChild( $doc->createTextNode( $ctx->{$which} ) );
        return $el;
    }
    my $meta = get_meta( $ctx->{dbh}, $table );
    if ( my $ptable = $meta->{fk}{$col} ) {
        $el->appendChild( ref_element( $ctx, $ptable, $value ) );
    }
    else {
        $el->appendChild( $doc->createTextNode($value) );
    }
    return $el;
}

# Lookup element for an existing row, from its unique key.
sub ref_element {
    my ( $ctx, $table, $id ) = @_;
    my $dbh = $ctx->{dbh};
    my $doc = $ctx->{doc};
    if ( $table eq 'pub' ) {
        if ( defined( $ctx->{winner_id} ) && $id == $ctx->{winner_id} ) {
            return $doc->createTextNode( $ctx->{winner} );
        }
        if ( $id == $ctx->{loser_id} ) {
            return $doc->createTextNode( $ctx->{loser} );
        }
    }
    my $meta = get_meta( $dbh, $table );
    die "no unique key for $table\n" unless @{ $meta->{uk} };
    my $row = $dbh->selectrow_hashref( "SELECT * FROM $table WHERE $meta->{pk} = ?", undef, $id );
    die "no $table row with $meta->{pk} $id\n" unless $row;
    my $el = $doc->createElement($table);
    $el->setAttribute( 'op', 'lookup' );
    foreach my $c ( @{ $meta->{uk} } ) {
        next unless defined( $row->{$c} );
        my $cel = $doc->createElement($c);
        if ( my $ptable = $meta->{fk}{$c} ) {
            $cel->appendChild( ref_element( $ctx, $ptable, $row->{$c} ) );
        }
        else {
            $cel->appendChild( $doc->createTextNode( $row->{$c} ) );
        }
        $el->appendChild($cel);
    }
    return $el;
}

# pub_relationship: move the losing pub's links to the winning pub, except
#  - published_in (the winner has its own journal),
#  - links between the losing and winning pubs (or the losing pub and itself),
#  - links to obsolete pubs,
#  - links the winner already has with the same type, in either direction.
sub merge_pub_relationships {
    my ($ctx) = @_;
    my $dbh   = $ctx->{dbh};
    my $doc   = $ctx->{doc};
    my $out   = '';
    my $rows  = $dbh->selectall_arrayref(
        "SELECT pr.subject_id, pr.object_id, pr.type_id, c.name AS rtype, cv.name AS cvname,
                o.pub_id AS other_id, o.uniquename AS other, o.is_obsolete AS other_obsolete
           FROM pub_relationship pr
           JOIN cvterm c ON c.cvterm_id = pr.type_id
           JOIN cv ON cv.cv_id = c.cv_id
           JOIN pub o ON o.pub_id = CASE WHEN pr.subject_id = ? THEN pr.object_id ELSE pr.subject_id END
          WHERE ? IN (pr.subject_id, pr.object_id)",
        { Slice => {} }, $ctx->{loser_id}, $ctx->{loser_id} );

    foreach my $r ( @{$rows} ) {
        my $what = "pub_relationship $r->{rtype} $ctx->{loser}/$r->{other}";
        if ( $PR_TYPES_NOT_MOVED{ $r->{rtype} } ) {
            print STDERR "STATE: P32 merge: not moving $what (type not moved)\n";
            next;
        }
        if ( $r->{other_id} == $ctx->{loser_id}
            || ( defined( $ctx->{winner_id} ) && $r->{other_id} == $ctx->{winner_id} ) )
        {
            print STDERR "STATE: P32 merge: not moving $what (link with the winning pub)\n";
            next;
        }
        if ( $ctx->{losers}{ $r->{other} } ) {
            print STDERR "STATE: P32 merge: not moving $what (other pub is also being merged into $ctx->{winner})\n";
            next;
        }
        my $pr_key = join( '|', $ctx->{winner}, $r->{type_id}, $r->{other_id} );
        if ( $pr_written{$pr_key} ) {
            print STDERR "STATE: P32 merge: not moving $what (already moved to the winner in this load)\n";
            next;
        }
        if ( $r->{other_obsolete} ) {
            print STDERR "STATE: P32 merge: not moving $what (other pub is obsolete)\n";
            next;
        }
        if ( defined( $ctx->{winner_id} ) ) {
            my ($exists) = $dbh->selectrow_array(
                "SELECT count(*) FROM pub_relationship WHERE type_id = ? AND
                   ((subject_id = ? AND object_id = ?) OR (subject_id = ? AND object_id = ?))",
                undef, $r->{type_id}, $ctx->{winner_id}, $r->{other_id},
                $r->{other_id}, $ctx->{winner_id} );
            if ($exists) {
                print STDERR "STATE: P32 merge: not moving $what (winner already has it)\n";
                next;
            }
        }
        $pr_written{$pr_key} = 1;
        my $loser_is_subject = $r->{subject_id} == $ctx->{loser_id};
        print STDERR "STATE: P32 merge: moving $what\n";
        foreach my $op ( '', 'delete' ) {
            my $pub = $op ? $ctx->{loser} : $ctx->{winner};
            my $el  = create_ch_pub_relationship(
                doc        => $doc,
                subject_id => $loser_is_subject
                ? $pub
                : create_ch_pub( doc => $doc, uniquename => $r->{other} ),
                object_id => $loser_is_subject
                ? create_ch_pub( doc => $doc, uniquename => $r->{other} )
                : $pub,
                rtype_id => create_ch_cvterm(
                    doc  => $doc,
                    cv   => $r->{cvname},
                    name => $r->{rtype}
                )
            );
            $el->setAttribute( 'op', 'delete' ) if $op;
            $out .= dom_toString($el);
        }
    }
    return $out;
}

sub get_pub_id {
    my ( $dbh, $uniquename ) = @_;
    my ($id) = $dbh->selectrow_array( "SELECT pub_id FROM pub WHERE uniquename = ?", undef, $uniquename );
    return $id;
}

# All single-column foreign keys to pub.pub_id, as [table, column].
sub get_pub_fks {
    my ($dbh) = @_;
    return @pub_fks if @pub_fks;
    my $rows = $dbh->selectall_arrayref(
        "SELECT c.conrelid::regclass::text, a.attname
           FROM pg_constraint c
           JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = c.conkey[1]
          WHERE c.contype = 'f' AND c.confrelid = 'pub'::regclass
            AND array_length(c.conkey, 1) = 1
          ORDER BY 1, 2" );
    @pub_fks = @{$rows};
    return @pub_fks;
}

# Columns, primary key, unique key, foreign keys and child tables of a table.
# The unique key is the widest unique constraint, which matches the keys in
# XORT's ddl.properties (checked for every table in production_chado).
sub get_meta {
    my ( $dbh, $table ) = @_;
    return $meta_cache{$table} if $meta_cache{$table};
    my %m = ( cols => [], pk => undef, uk => [], fk => {}, children => [] );

    $m{cols} = $dbh->selectcol_arrayref(
        "SELECT attname FROM pg_attribute WHERE attrelid = ?::regclass
            AND attnum > 0 AND NOT attisdropped ORDER BY attnum", undef, $table );

    my $cons = $dbh->selectall_arrayref(
        "SELECT c.conname, c.contype, c.confrelid::regclass::text,
                array_to_string(ARRAY(SELECT a.attname FROM unnest(c.conkey) WITH ORDINALITY k(n, o)
                  JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = k.n ORDER BY k.o), ',')
           FROM pg_constraint c WHERE c.conrelid = ?::regclass AND c.contype IN ('p', 'u', 'f')
          ORDER BY c.conname", undef, $table );
    my @uks = ();
    foreach my $con ( @{$cons} ) {
        my ( $name, $type, $ftable, $cols ) = @{$con};
        my @cols = split( /,/, $cols );
        if    ( $type eq 'p' )                 { $m{pk} = $cols[0]; }
        elsif ( $type eq 'u' )                 { push( @uks, \@cols ); }
        elsif ( $type eq 'f' && @cols == 1 )   { $m{fk}{ $cols[0] } = $ftable; }
    }
    foreach my $uk (@uks) {
        $m{uk} = $uk if ( @{$uk} > @{ $m{uk} } );
    }
    $m{children} = $dbh->selectall_arrayref(
        "SELECT c.conrelid::regclass::text, a.attname
           FROM pg_constraint c
           JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = c.conkey[1]
          WHERE c.contype = 'f' AND c.confrelid = ?::regclass AND array_length(c.conkey, 1) = 1
          ORDER BY 1", undef, $table );
    $meta_cache{$table} = \%m;
    return \%m;
}

1;
