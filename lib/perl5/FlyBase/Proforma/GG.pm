package FlyBase::Proforma::GG;

use 5.008004;
use strict;
use warnings;
use XML::DOM;
use FlyBase::WriteChado;
require Exporter;
use FlyBase::Proforma::Util;
use Carp qw(croak);
our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use FlyBase::Proforma::Aberr ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = (
    'all' => [
        qw(

          )
    ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( process validate

);

our $VERSION = '0.01';

=head1 NAME

FlyBase::Proforma::GG - Perl module for parsing the FlyBase
GENEGROUP PROFORMA     Version 4: 28 Aug 2014

See the bottom for the proforma
                         
=head1 SYNOPSIS

  use FlyBase::Proforma::GG;
  use DBI;
  
  my $mdbh=DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";
  my %ph=(A1a=>'TM9', A1g=>'y',....);
  ###!c field implemented as '$fieldname.upd=>'c'' eg. 'A16.upd'=>'c'
   
  #params db is manditory, debug and validate is optional
  my $pro=FlyBase::proforma::Gene->new(db=>$mdbh);
  $pro->validate(%ph);
  my $chadoxml = $pro->process(%ph);
  
  # or

  my $pro=FlyBase::Proforma::Gene->new(db=>$mdbh,debug=>1,validate=>1);
  my $chadoxml_string=$pro->process(%ph);

=head1 DESCRIPTION

FlyBase::Proforma::GG is a perl module for parsing FlyBase
GeneGroup proforma and write the result as chadoxml. It is required
to connected to a chado database for validating and processing.
See Proforma for the proforma template.

The module also requires FlyBase::Proforma::Writechado and
FlyBase::Proforma::Util. The results can be loaded into a chado
database by XML::Xort.

=head2 EXPORT

  process
  validate

=cut

our %ti_fpr_type = (
    'GG1a', 'symbol',                #grp_synonym
    'GG1b', 'symbol',                #grp_synonym
    'GG1e', 'symbol',                #rename grp_synonym
    'GG1f', 'merge',                 #grp_merge_function
    'GG1g', 'new',                   #checking
    'GG2a', 'fullname',              #grp_synonym
    'GG2b', 'fullname',              #grp_synonym
    'GG2c', 'fullname',              #rename grp_synonym
    'GG4',  'FlyBase miscellaneous CV',                  #grp_cvterm
    'GG3a', 'is_obsolete',           #grp.is_obsolete
    'GG3b', 'dissociate_pub',        #grp_pub
    'GG5',  'gg_description',        #grpprop
    'GG6a', 'cellular_component',    #grp_cvterm
    'GG6b', 'molecular_function',    #grp_cvterm
    'GG6c', 'biological_process',    #grp_cvterm
    'GG7a', 'parent_grp',            #grp_relationship.object_id
    'GG7c', 'undefined_grp',         #grp_relationship.object_id
    'GG7d', 'grpmember_dataset'
    , #library_grpmember , grpmember.grp_id,grpmember.type_id='grpmember_dataset', library_id

#    'GG8a', '',  #grp_dbxref GG8a = dbxref.accession, GG8b = db.name, GG8c = dbxref.description
    'GG9',  'gg_owner',             #grpprop
    'GG10', 'gg_comment',           #grpprop
    'GG11', 'gg_review_date',       #grpprop
    'GG12', 'gg_internal_notes',    #grpprop
    'GG13', 'gg_pathway_abstract',  #grpprop
    'GG14', 'GO-CAM',               #grp_dbxref
    );

my $doc = new XML::DOM::Document();
my $db  = '';

sub new {
    my $pkg  = shift;
    my $self = {@_};

    checkargs( $self, qw(db) ) or return;
    $db = $self->{db};

    # bless $self as an object in $pkg and return it

    bless( $self, $pkg );

    return $self;
}

sub checkargs {
    my ( $href, @args ) = @_;

    my $success = 1;

    for (@args) {
        unless ( exists $href->{$_} ) {
            croak "Missing argument '$_'";
            $success = 0;
        }
    }

    return $success;
}

=head1 METHODS

=head2 $pro->process(%ph)
	
	Process each element in the hash table and returns a string of chadoxml.

=cut

sub process {
    my $self    = shift;
    my $tihash  = {@_};
    my %ph      = %$tihash;
    my $unique  = '';
    my $flag    = 0;
    my $feature = '';
    my $type;
    my $out = '';

    if ( exists( $self->{debug} ) && $self->{debug} == 1 ) {
        foreach my $key ( keys %ph ) {
            print STDERR "$key, $ph{$key}\n";
        }
    }
    if ( exists( $self->{validate} ) && $self->{validate} == 1 ) {
        $self->validate(%ph);
    }

    if ( exists( $fbids{ $ph{GG1a} } ) ) {
        $unique = $fbids{ $ph{GG1a} };
    }
    else {
        print "ERROR: could not get uniquename for $ph{GG1a}\n";
        return $out;
    }
    print STDERR "processing GeneGroup " . $ph{GG1a} . "...\n";
    if ( exists( $fbcheck{ $ph{GG1a} }{ $ph{pub} } ) ) {
        print STDERR
          "Warning: $ph{GG1a} $ph{pub} exists in a previous proforma\n";
    }
    $fbcheck{ $ph{GG1a} }{ $ph{pub} } = 1;

    if ( !exists( $ph{GG3b} ) ) {
        if ( $ph{pub} ne 'FBrf0000000' ) {
            print STDERR
"Action Items: genegroup $unique == $ph{GG1a} with pub $ph{pub}\n";
            my $f_p = create_ch_grp_pub(
                doc    => $doc,
                grp_id => $unique,
                pub_id => $ph{pub}
            );
            $out .= dom_toString($f_p);
            $f_p->dispose();
        }
    }
    else {
        print STDERR "Action Items: $ph{GG1a} dissociate with pub $ph{pub}\n";
        print STDERR "CHECK: GG3b NEW implemention test\n";

        $out .= dissociate_with_pub_fromgrp( $self->{db}, $unique, $ph{pub} );
        return $out;
    }
    ##Process other field in GENEGROUP proforma
    foreach my $f ( keys %ph ) {

        #	print STDERR "IN FIELD: $f for $ph{GG1a}\n";

        if ( $f eq 'GG1b' || $f eq 'GG2b' ) {

            #		print STDERR "DEBUG: $f type = $ti_fpr_type{$f}\n";
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{GG1a} $f  $ph{pub}\n";
                $out .=
                  delete_grp_synonym( $self->{db}, $doc, $unique, $ph{pub},
                    $ti_fpr_type{$f} );

            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    my $t = $f;
                    $t =~ s/^GG\d//;

                    if ( $item ne 'unnamed' && $item ne '' ) {
                        if ( ( $f eq 'GG1b' ) && ( $item eq $ph{GG1a} ) ) {
                            $t = 'a';
                        }
                        elsif (( $f eq 'GG2b' )
                            && exists( $ph{GG2a} )
                            && ( $item eq $ph{GG2a} ) )
                        {
                            $t = 'a';
                        }
                        elsif ( !exists( $ph{GG2a} ) && $f eq 'GG2b' ) {
                            $t =
                              check_grp_synonym_is_current( $self->{db},
                                $unique, $item, 'fullname' );
                        }
                        $out .=
                          write_grp_synonyms( $doc, $unique, $item, $t,
                            $ph{pub}, $ti_fpr_type{$f} );
                    }
                }
            }
        }
        elsif ( $f eq 'GG2a' ) {

            #		print STDERR "DEBUG: $f type = $ti_fpr_type{$f}\n";
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "ERROR: GG2a can not accept !c\n";
            }
            my $num = check_grp_synonym( $self->{db}, $unique, 'fullname' );
            if ( $num != 0 ) {
                if (
                    (
                           defined( $ph{GG2c} )
                        && $ph{GG2c} eq ''
                        && !defined( $ph{GG1f} )
                    )
                    || ( !defined( $ph{GG2c} ) && !defined( $ph{GG1f} ) )
                  )
                {
                    print STDERR
                      "ERROR: GG2a must have GG2c filled in unless a merge\n";
                }
                elsif ( defined( $ph{GG2c} ) ) {
                    my $t = check_grp_synonym_is_current( $self->{db},
                        $unique, $ph{GG2c}, $ti_fpr_type{$f} );
                    print STDERR
"DEBUG: GG2c $ph{GG2c} return from check_grp_synonym_is_current = $t\n";
                    if ( $t ne 'a' ) {
                        print STDERR
                          "ERROR: $f $ph{GG2c} is not the current synonym\n";
                    }
                    else {
                        $out .= write_grp_synonyms( $doc, $unique, $ph{$f}, 'a',
                            'unattributed', $ti_fpr_type{$f} );
                        $out .= update_grp_synonym( $self->{db}, $doc, $unique,
                            $ph{GG2c}, $ti_fpr_type{$f} );
                    }
                }
            }
            else {
                $out .= write_grp_synonyms( $doc, $unique, $ph{$f}, 'a',
                    'unattributed', $ti_fpr_type{$f} );
            }
        }
        elsif ( $f eq 'GG1e' ) {

            #	   print STDERR "DEBUG: $f type = $ti_fpr_type{$f}\n";
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "ERROR: $f can not accept !c\n";
            }

            $out .=
              update_grp_synonym( $self->{db}, $doc, $unique, $ph{$f},
                $ti_fpr_type{$f} );
        }
        elsif ( $f eq 'GG3b' ) {
            print STDERR
              "Action Items: $ph{GG1a} dissociate with pub $ph{pub}\n";
            $out .=
              dissociate_with_pub_fromgrp( $self->{db}, $unique, $ph{pub} );
        }
        elsif ( $f eq 'GG1f' ) {
            print STDERR "ERROR: merge NOT implemented yet\n";

#            $out .=
#              merge_grp_records( $self->{db}, $unique, $ph{$f},$ph{GG1a}, $ph{pub} , $ph{GG2a});
#                if(defined($ph{GG2a})){
#                $out.=write_grp_synonyms($doc,$unique,$ph{GG2a},'a','unattributed',$ti_fpr_type{GG2a});
#                }
        }
        elsif ($f eq 'GG7a'
            || $f eq 'GG7c' )
        {
            #	    print STDERR "DEBUG: $f type = $ti_fpr_type{$f}\n";
            my $subject = 'subject_id';
            my $object  = 'object_id';
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{GG1a} $f  $ph{pub}\n";
                my @results =
                  get_unique_key_for_grp_rel( $self->{db}, $subject, $object,
                    $unique, $ti_fpr_type{$f}, $ph{pub} );
                foreach my $ta (@results) {
                    my $num = get_gr_pub_nums( $self->{db}, $ta->{fr_id} );
                    if (
                        $num == 1
                        || ( defined( $frnum{$unique}{ $ta->{name} } )
                            && $num - $frnum{$unique}{ $ta->{name} } == 1 )
                      )
                    {
                        $out .=
                          delete_grp_relationship( $self->{db}, $doc,
                            $ta, $subject, $object, $unique, $ti_fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_grp_relationship_pub( $self->{db},
                            $doc, $ta, $subject, $object, $unique,
                            $ti_fpr_type{$f}, $ph{pub} );
                    }
                    else {
                        print STDERR "something Wrong, please validate first\n";
                    }
                }
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {

                #	    print STDERR "DEBUG: $f type = $ti_fpr_type{$f}\n";
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    print STDERR
                      "DEBUG: $f object $item subject $unique pub $ph{pub}\n";
                    my ( $fr, $f_p ) =
                      write_grp_relationship( $self->{db}, $doc,
                        $subject, $object, $unique, $item,
                        $ti_fpr_type{$f}, $ph{pub}, );
                    $out .= dom_toString($fr);
                    $out .= $f_p;
                }
            }
        }
        elsif ($f eq 'GG5'
            || $f eq 'GG9'
            || $f eq 'GG10'
            || $f eq 'GG11'
            || $f eq 'GG12'
            || $f eq 'GG13' )
        {
            my $rn = 0;
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR
"Action Items: !c log,$ph{GG1a} $f $ti_fpr_type{$f} $ph{pub} $unique\n";
                my @results =
                  get_unique_key_for_grpprop( $self->{db}, $unique,
                    $ti_fpr_type{$f}, $ph{pub} );
                $rn += @results;
                foreach my $t (@results) {
                    my $num = get_grpprop_pub_nums( $self->{db}, $t->{fp_id} );
                    if (
                        $num == 1
                        || (
                            defined(
                                $frnum{$unique}{ $ti_fpr_type{$f} }
                                  { $t->{rank} }
                            )
                            && $num -
                            $frnum{$unique}{ $ti_fpr_type{$f} }{ $t->{rank} }
                            == 1
                        )
                      )
                    {
                        $out .=
                          delete_grpprop( $doc, $t->{rank}, $unique,
                            $ti_fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_grpprop_pub( $doc, $t->{rank}, $unique,
                            $ti_fpr_type{$f}, $ph{pub} );
                    }
                    else {
                        print STDERR "something Wrong, please validate first\n";
                    }
                }
                if ( $rn == 0 ) {
                    print STDERR "ERROR: there is no previous record for $f\n";
                }
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    if ($f eq 'GG13') {
                        if ( scalar @items > 1 ) {
                            print STDERR "ERROR: $unique $f has more than 1 file \n";
                            exit(0);
                        }
                        my ( $gg_id, $rest) = ( $item =~ /^FBgg(\d{7})(_pathway_thumb\.svg)$/);
                        if ( not $gg_id or $gg_id eq "" ){
                            print STDERR "ERROR: $f does not match FBggxxxxxxx_pathway_thumb.svg format";
                            exit(0);
                        }
                    }
                    if ( $f eq 'GG11' ) {
                        my ( $year, $month, $day ) =
                          ( $item =~
/^(\d{4})(1[0-2]|0[1-9])(3[0-1]|0[1-9]|[1-2][0-9])$/
                          );
                        if ( $year ne "" && $month ne "" && $day ne "" ) {
                            $item = $year . $month . $day;

                            #always overwrite
                            my $rank = 0;
                            $out .=
                              write_grpprop( $self->{db}, $doc, $unique, $item,
                                $ti_fpr_type{$f}, $ph{pub}, $rank );
                        }
                        else {
                            print STDERR "ERROR: Do not recognize date for GG11:
						$item\n";
                        }
                    }
                    else {
                        $out .=
                          write_grpprop( $self->{db}, $doc, $unique, $item,
                            $ti_fpr_type{$f}, $ph{pub} );
                    }
                }
            }
        }
        elsif ( $f eq 'GG14') {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "ERROR:: !c log, $ph{GG14} $f  $ph{pub} Not programmed yet\n";
            }
            else {
                my $dbname = $ti_fpr_type{$f};
                my $dbxref = $ph{GG14};
                my $dbxref_dom = create_ch_dbxref(
                    doc         => $doc,
                    accession   => $dbxref,
                    db          => $dbname,
                    version     => '1',
                    description => '',
                    macro_id    => $dbname . $dbxref,
                    no_lookup   => 1
                );
                # $fbdbs{ $dbname . $dbxref } = $dbname . $ph{GG14};
                $out .= dom_toString($dbxref_dom);
                my $fd = create_ch_grp_dbxref(
                    doc       => $doc,
                    grp_id    => $unique,
                    dbxref_id => $dbname . $dbxref
                );
                $out .= dom_toString($fd);
            }
        }
        elsif ( $f eq 'GG4' ) {

            #		print STDERR "DEBUG: $f type = $ti_fpr_type{$f}\n";
            
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{GG1a} $f  $ph{pub}\n";

                # Get cvterm for FBcv 
                my @result =
                  get_cvterm_for_grp_cvterm( $self->{db}, $unique,
                    $ti_fpr_type{$f}, $ph{pub} );
                # print STDERR "Found result for lookup $unique and $ti_fpr_type{$f}... @result\n";
                foreach my $item (@result) {
                    print STDERR "\titem is $item\n";
                    my ( $cvterm, $obsolete ) = split( /,,/, $item );
                    my $gg_cvterm =  create_ch_grp_cvterm(
                        doc       => $doc,
                        grp_id    => $unique,
                        cvterm_id => create_ch_cvterm(
                            doc         => $doc,
                            cv          => $ti_fpr_type{$f},
                            name        => $cvterm,
                            is_obsolete => $obsolete
                        ),
                        pub_id => $ph{pub}
                    );
                    $gg_cvterm->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($gg_cvterm);
                    $gg_cvterm->dispose();
                }
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {

                my @items = split( /\n/, $ph{$f} );

                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    my $cv = get_cv_by_cvterm( $self->{db}, $item );
                    if ( !defined($cv) ) {
                        print STDERR "ERROR: $item is a wrong CV term\n";

                        # exit(0);
                    }
                    validate_cvterm( $self->{db}, $item, $cv );

                    my $f_cvterm = create_ch_grp_cvterm(
                        doc       => $doc,
                        grp_id    => $unique,
                        cvterm_id => create_ch_cvterm(
                            doc  => $doc,
                            cv   => $cv,
                            name => $item
                        ),
                        pub_id => $ph{pub}
                    );

                    $out .= dom_toString($f_cvterm);
                    $f_cvterm->dispose();
                }
            }

        }

        elsif ( $f eq 'GG6a' || $f eq 'GG6b' || $f eq 'GG6c' ) {

            #		print STDERR "DEBUG: $f cv = $ti_fpr_type{$f}\n";
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log, $ph{GG1a} $f  $ph{pub}\n";
                my @result =
                  get_cvterm_for_grp_cvterm( $self->{db}, $unique,
                    $ti_fpr_type{$f}, $ph{pub} );
                foreach my $item (@result) {
                    my ( $cvterm, $obsolete ) = split( /,,/, $item );
                    my $gg_cvterm = create_ch_grp_cvterm(
                        doc       => $doc,
                        grp_id    => $unique,
                        cvterm_id => create_ch_cvterm(
                            doc         => $doc,
                            cv          => $ti_fpr_type{$f},
                            name        => $cvterm,
                            is_obsolete => $obsolete
                        ),
                        pub_id => $ph{pub}
                    );
                    $gg_cvterm->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($gg_cvterm);
                    $gg_cvterm->dispose();
                }
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    my $go    = "";
                    my $go_id = "";
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    if ( $item =~ /(.*)\s;\s(.*)/ ) {
                        $go    = $1;
                        $go_id = $2;
                    }
                    $go    =~ s/^\s+//;
                    $go    =~ s/\s+$//;
                    $go_id =~ s/^\s+//;
                    $go_id =~ s/\s+$//;

                    validate_go( $self->{db}, $go, $go_id, $ti_fpr_type{$f} );
                    my $f_cvterm = create_ch_grp_cvterm(
                        doc       => $doc,
                        grp_id    => $unique,
                        cvterm_id => create_ch_cvterm(
                            doc      => $doc,
                            cv       => $ti_fpr_type{$f},
                            name     => $go,
                            macro_id => $go
                        ),
                        pub_id => $ph{pub}
                    );
                    $out .= dom_toString($f_cvterm);
                    $f_cvterm->dispose();
                }
            }
        }
        elsif ( $f eq 'GG8a' ) {

            #		print STDERR "DEBUG: field $f\n";
            $out .= &parse_dataset( $unique, \%ph );
        }
        elsif ( $f eq 'GG8' ) {
            print STDERR "CHECK: in multiple field GG8\n";
            ##### library_dbxref multiple db/accessions
            my @array = @{ $ph{$f} };

            #	  print STDERR "CHECK: there are ".  ($#array+1) ." \n";
            foreach my $ref (@array) {

                #	    print STDERR "CHECK: $ref->{GG8a}\n";
                $out .= &parse_dataset( $unique, $ref );
            }
        }
        elsif ( $f eq 'GG3a' && $ph{$f} eq 'y' ) {
            print STDERR "GG3a: CHECK delete grp_relationship, grpmember\n";
            $out .= delete_grp( $self->{db}, $doc, $unique, $ph{GG1a} );
        }
    }
    $doc->dispose();
    return $out;
}

=head2 $pro->write_genegroup(%ph)
  separate the id generation and lookup from the other curation field to make two-stage parsing possible
=cut

sub write_genegroup {
    my $self    = shift;
    my $tihash  = {@_};
    my %ph      = %$tihash;
    my $unique  = '';
    my $type    = 'gene_group';
    my $flag    = 0;
    my $feature = '';
    my $out     = '';

    if ( exists( $ph{GG1h} ) ) {
        ( $unique, $type ) = get_grp_ukeys_by_uname( $self->{db}, $ph{GG1h} );
        if ( !exists( $ph{GG1e} ) ) {
            validate_grp_uname_name( $db, $ph{GG1h}, $ph{GG1a} );
        }
        if ( $unique eq '2' ) {
            ( $unique, $type ) =
              get_grp_ukeys_by_name_type( $self->{db}, $ph{GG1a},
                'gene_group' );
            if ( $unique ne $ph{GG1h} ) {
                print STDERR
"ERROR: name and uniquename not match $ph{GG1h}  $ph{GG1a} \n";
            }
        }
        if ( $unique ne '0' && $unique ne '2' ) {
            $unique  = $ph{GG1h};
            $feature = create_ch_grp(
                doc        => $doc,
                uniquename => $unique,
                type       => $type,
                macro_id   => $unique,
            );

            if ( exists( $ph{GG3a} ) && $ph{GG3a} eq 'y' ) {
                print STDERR
                  "Action Items: delete genegroup $unique == $ph{GG1a}\n";
                my $op = create_doc_element( $doc, 'is_obsolete', 't' );
                $feature->appendChild($op);
            }
            if ( exists( $ph{GG1e} ) ) {
                my $op = create_doc_element( $doc, 'name',
                    decon( convers( $ph{GG1a} ) ) );
                $feature->appendChild($op);
            }
            if ( exists( $fbids{ $ph{GG1a} } ) ) {
                my $check = $fbids{ $ph{GG1a} };
                if ( $unique ne $check ) {
                    print STDERR
"ERROR: $check and $unique are not same for $ph{GG1a}, using $unique, please separate proforma to different PHASEs\n";
                }
            }
            $fbids{ $ph{GG1a} } = $unique;
            $out .= dom_toString($feature);
        }
        else {
            print STDERR "ERROR: could not find $ph{GG1h} in database\n";
        }

    }
    else {
        if ( exists( $ph{GG1f} ) ) {
            if ( $ph{GG1g} eq 'n' ) {
                print STDERR
                  "Gene Merge  GG1g = n check: does GG1a $ph{GG1a} exist\n";
                my $va = validate_new_name( $db, $ph{GG1a}, 'grp' );
                if ( $va == 1 ) {
                    print STDERR
"ERROR:GeneGroup Merge  GG1g = n and GG1a $ph{GG1a} exists\n";
                }
            }
            my $tmp = $ph{GG1f};
            $tmp =~ s/\n/ /g;
            print STDERR "Action Items: GeneGroup Merge $tmp\n";
            ( $unique, $flag ) = get_tempid( 'gg', $ph{GG1a} );

            print STDERR "get temp id for $ph{GG1a} $unique\n";

            if ( $flag == 1 ) {
                print STDERR "ERROR: could not assign temp id for $ph{GG1a}\n";
                exit(0);
            }
            else {
                $feature = create_ch_grp(
                    uniquename => $unique,
                    name       => decon( convers( $ph{GG1a} ) ),
                    type       => $type,
                    doc        => $doc,
                    macro_id   => $unique,
                    no_lookup  => '1'
                );
                $out .= dom_toString($feature);
                $out .=
                  write_grp_synonyms( $doc, $unique, $ph{GG1a}, 'a',
                    'unattributed', 'symbol' );
            }
        }
        else {

            if ( $ph{GG1g} ne 'n' ) {
                ( $unique, $type ) =
                  get_grp_ukeys_by_name( $self->{db}, $ph{GG1a} );
                if ( $unique eq '0' ) {
                    print STDERR
                      "ERROR: Could not find uniquename for genegroup ",
                      $ph{GG1a}, "\n";
                    my $current =
                      get_current_grp_name_by_synonym( $self->{db}, $ph{GG1a} );
                    print STDERR
"ERROR: $ph{GG1a} current name may be changed to $current\n";

                    #exit(0);
                }
                if ( $unique eq '2' ) {
                    ( $unique, $type ) =
                      get_grp_ukeys_by_name_type( $self->{db}, $ph{GG1a},
                        'gene_group' );
                }
                if ( $unique eq '0' ) {
                    print STDERR
                      "ERROR: could not find  uniquename for gene_group ",
                      $ph{GG1a}, "\n";

                    #exit(0);
                }

                if ( exists( $ph{GG1h} ) ) {
                    if ( $ph{GG1h} ne $unique ) {
                        print STDERR "ERROR: GG1h and GG1a not match\n";
                    }
                }
                $feature = create_ch_grp(
                    doc        => $doc,
                    uniquename => $unique,
                    type       => $type,
                    macro_id   => $unique,
                    no_lookup  => '1',
                );
                if ( exists( $ph{GG3a} ) && $ph{GG3a} eq 'y' ) {
                    print STDERR
                      "Action Items: delete genegroup $unique == $ph{GG1a}\n";
                    my $op = create_doc_element( $doc, 'is_obsolete', 't' );
                    $feature->appendChild($op);
                }
                if ( exists( $fbids{ $ph{GG1a} } ) ) {
                    my $check = $fbids{ $ph{GG1a} };
                    if ( $unique ne $check ) {
                        print STDERR
"ERROR: $check and $unique are not same for $ph{GG1a}, using $unique, please separate proforma to different PHASEs\n";
                    }
                }
                $fbids{ $ph{GG1a} } = $unique;
                $out .= dom_toString($feature);
                validate_grp_uname_name( $self->{db}, $unique, $ph{GG1a} );
                $out .= write_grp_synonyms( $doc, $unique, $ph{GG1a}, 'a',
                    'unattributed', 'symbol' );
            }
            else {    #GG1g = n and not a merge

                #		print STDERR "DEBUG: $ph{GG1a} validate_new_name\n";
                my $va = validate_new_name( $db, $ph{GG1a}, 'grp' );
                if ( exists( $ph{GG1e} ) ) {
                    if ( exists( $fbids{ $ph{GG1e} } ) ) {
                        print STDERR
                          "ERROR: $ph{GG1e} exists in a previous proforma\n";
                    }
                    if ( exists( $fbids{ $ph{GG1a} } ) ) {
                        print STDERR
"ERROR: Rename GG1a $ph{GG1a} exists in a previous proforma \n";
                    }
                    print STDERR
                      "Action Items: rename $ph{GG1e} to $ph{GG1a}\n";
                    ( $unique, $type ) =
                      get_grp_ukeys_by_name( $self->{db}, $ph{GG1e} );
                    if ( $unique eq '0' or $unique eq '2' ) {
                        print STDERR
                          "ERROR: could not get uniquename for $ph{GG1e}\n";
                    }
                    else {
                        $feature = create_ch_grp(
                            uniquename => $unique,
                            name       => decon( convers( $ph{GG1a} ) ),
                            type       => $type,
                            doc        => $doc,
                            macro_id   => $unique,
                            no_lookup  => '1'
                        );
                        $out .= dom_toString($feature);
                        $out .=
                          write_grp_synonyms( $doc, $unique, $ph{GG1a}, 'a',
                            'unattributed', 'symbol' );

                        $fbids{ $ph{GG1a} } = $unique;
                        $fbids{ $ph{GG1e} } = $unique;
                    }
                }
                else {    #GG1g = n and not a rename
                    ### if the temp id has been used before, $flag will be 1 to avoid
                    ### the DB Trigger reassign a new id to the same symbol.
                    if ( $va == 1 ) {
                        $flag = 0;
                        print STDERR
"val = 1 for $ph{GG1a} flag==$flag where does this happen?\n";
                        ( $unique, $type ) =
                          get_grp_ukeys_by_name( $db, $ph{GG1a} );
                        $fbids{ $ph{GG1a} } = $unique;
                    }
                    else {
                        ( $unique, $flag ) = get_tempid( 'gg', $ph{GG1a} );
                        print STDERR
                          "Action Items: new genegroup $ph{GG1a} $unique\n";
                        print STDERR
                          "get temp id for $ph{GG1a} $unique flag==$flag\n";
                    }
                    if ( $flag == 0 ) {
                        $feature = create_ch_grp(
                            uniquename => $unique,
                            name       => decon( convers( $ph{GG1a} ) ),
                            type       => $type,
                            doc        => $doc,
                            macro_id   => $unique,
                            no_lookup  => '1'
                        );
                        $out .= dom_toString($feature);
                        $out .=
                          write_grp_synonyms( $doc, $unique, $ph{GG1a}, 'a',
                            'unattributed', 'symbol' );
                    }
                    else {
                        print STDERR
                          "ERROR, name $ph{GG1a} has been used in this load\n";
                    }
                }
            }
        }
    }

#    print STDERR "DEBUG: end of write_grp $ph{GG1a} unique = $fbids{$ph{GG1a}}\n";

    $doc->dispose();
    return ( $out, $unique );
}

sub parse_dataset {
    my $unique  = shift;
    my $generef = shift;
    my %affgene = %$generef;
    my $dbname  = '';
    my $dbxref  = '';
    my $descr   = '';
    my $out     = '';

    #    print STDERR "DEBUG: $affgene{GG8a}\n";

    if ( defined( $affgene{"GG8a.upd"} ) && $affgene{'GG8a.upd'} eq 'c' ) {
        print STDERR "ERROR: !c not allowed for dbxref\n";
        return $out;
    }

    if ( ( defined( $affgene{GG8a} ) && $affgene{GG8a} ne '' )
        && $affgene{GG8d} eq 'y' )
    {
        print STDERR
"Action item: dissociate dbxref (data_link) $affgene{GG8b}:$affgene{GG8a} with Dataset $unique\n";
        if ( defined( $affgene{GG8b} ) && $affgene{GG8b} ne '' ) {
            my ( $dname, $acc, $ver ) =
              get_unique_key_for_grp_dbxref( $db, $unique, $affgene{GG8b},
                $affgene{GG8a} );
            if ( $dname eq "0" ) {
                print STDERR
"ERROR:cannot dissociate dbxref (data_link) $affgene{GG8b}:$affgene{GG8a} with Gene Group $unique\n";
                return $out;
            }
            else {
                print STDERR
"in GG.pm Gene Group $unique: db.name = $dname acc = $acc version = $ver\n";
                my $fd = create_ch_grp_dbxref(
                    doc       => $doc,
                    grp_id    => $unique,
                    dbxref_id => create_ch_dbxref(
                        doc       => $doc,
                        db        => $dname,
                        accession => $acc,
                        version   => $ver,
                    ),
                );
                $fd->setAttribute( 'op', 'delete' );
                $out .= dom_toString($fd);

                return $out;
            }
        }
        else {
            print STDERR
              "ERROR: GG8b required for dbxref with GG8a GG8d $unique\n";
            return $out;
        }
    }

    if ( defined( $affgene{GG8b} ) && $affgene{GG8b} ne '' ) {
        my $dbxref_dom = "";
        my $dbname     = validate_dbname( $db, $affgene{GG8b} );
        if ( $dbname ne '' ) {

#          print STDERR "DEBUG: found valid dbname = $dbname matches $affgene{GG8b}\n";
#get accession
            if ( defined( $affgene{GG8a} ) && $affgene{GG8a} ne '' ) {
                my $val =
                  get_dbxref_by_db_dbxref( $db, $dbname, $affgene{GG8a} );
                if ( $val == 0 ) {
                    $dbxref = $affgene{GG8a};

                    if ( exists( $fbdbs{ $dbname . $dbxref } ) ) {
                        $dbxref_dom = $fbdbs{ $dbname . $dbxref };

#                      print STDERR "DEBUG: exists $dbname.$dbxref in val= 0\n";

                    }
                    else {
#                      print STDERR "DEBUG: new accession in GG8a $affgene{GG8a} $affgene{GG8b}\n";
                        if ( defined( $affgene{GG8c} ) && $affgene{GG8c} ne '' )
                        {
                            print STDERR
"DEBUG: $dbname $affgene{GG8a} description GG8c $affgene{GG8c}\n";
                            $descr = $affgene{GG8c};
                        }
                        else {
                            $descr = $affgene{GG8a};
                        }
                        $dbxref_dom = create_ch_dbxref(
                            doc         => $doc,
                            accession   => $dbxref,
                            db          => $dbname,
                            version     => '1',
                            description => $descr,
                            macro_id    => $dbname . $dbxref,
                            no_lookup   => 1
                        );
                        $fbdbs{ $dbname . $dbxref } = $dbname . $dbxref;
                        $out .= dom_toString($dbxref_dom);
                    }
                    my $fd = create_ch_grp_dbxref(
                        doc       => $doc,
                        grp_id    => $unique,
                        dbxref_id => $dbname . $dbxref
                    );
                    $out .= dom_toString($fd);
                }
                elsif ( $val == 1 ) {

                    $dbxref = $affgene{GG8a};
                    if ( exists( $fbdbs{ $dbname . $dbxref } ) ) {
                        $dbxref_dom = $dbname . $dbxref;
                        print STDERR
                          "DEBUG: exists $dbname.$dbxref in val= 1\n";

                    }
                    else {
                        my $version = &get_version_from_dbxref( $db, $dbname,
                            $affgene{GG8a} );
                        if ( $version eq "0" ) {
                            print STDERR
"ERROR: Multiple accessions in chado with  $affgene{GG8b} $affgene{GG8a} need to know version\n";
                        }
                        else {
#                          print STDERR "DEBUG: accession in GG8a $affgene{GG8a} found\n";
                            if ( defined( $affgene{GG8c} )
                                && $affgene{GG8c} ne '' )
                            {
                                print STDERR
"WARN: $dbname.$affgene{GG8a} exists GG8c $affgene{GG8c} will be ignored\n";
                            }
                            $dbxref_dom = create_ch_dbxref(
                                doc       => $doc,
                                accession => $dbxref,
                                db        => $dbname,
                                version   => $version,
                                macro_id  => $dbname . $dbxref,
                            );
                            $fbdbs{ $dbname . $dbxref } = $dbname . $dbxref;
                            $out .= dom_toString($dbxref_dom);
                        }
                    }
                    my $fd = create_ch_grp_dbxref(
                        doc       => $doc,
                        grp_id    => $unique,
                        dbxref_id => $dbxref_dom
                    );

                    $out .= dom_toString($fd);
                }
            }
            else {
                print STDERR "ERROR: NO accession in GG8a $affgene{GG8a} \n";
            }
        }
        else {
            print STDERR
              "ERROR: NO dbname found for $affgene{GG8b} -- create DB first\n";
        }
    }
    return $out;
}

=head2 $pro->validate(%ph)

   validate the following:

=cut

sub validate {
    my $self   = shift;
    my $tihash = {@_};
    my %tival  = %$tihash;

    my $v_unique = '';
    my $v_uname;
    my $v_type;

    print STDERR "Validating GeneGroup NOT implemented", $tival{GG1a},
      " ....\n";

}

sub DESTROY {
    my $self = shift;

    # $self->{doc}->dispose;

}
1;
__END__


=head1 SUPPORT

proformas can be found in http://flystocks.bio.indiana.edu/flybase/curation-docs/genetic-literature/

proforma mapping table can be found in ~haiyan/Documents/genemapping.sxw 

chado schema can be found in http://www.gmod.org

=head1 SEE ALSO

FlyBase::WriteChado
FlyBase::Proforma::Util
FlyBase::Proforma::Pub
FlyBase::Proforma::TP
FlyBase::Proforma::TI
FlyBase::Proforma::TE
FlyBase::Proforma::Gene
FlyBase::Proforma::Aberr
FlyBase::Proforma::Allele
FlyBase::Proforma::Balancer
FlyBase::Proforma::Cell_line
FlyBase::Proforma::DB
FlyBase::Proforma::ExpressionParser
FlyBase::Proforma::Feature;
FlyBase::Proforma::SF;
FlyBase::Proforma::Library;
FlyBase::Proforma::Interaction;
FlyBase::Proforma::Strain;
FlyBase::Proforma::HH;
FlyBase::Proforma::GG;
XML::Xort

=head1 Proforma

! GENEGROUP PROFORMA     Version 4: 28 Aug 2014
!
! GG1h. FlyBase gene group ID (FBgg)  *z :
! GG1a. Gene group symbol                               *a :
! GG1b. Gene group symbol(s) used in reference          *i :
! GG1e. Action - rename this gene group symbol      :
! GG1f. Action - merge these gene groups (symbols)  :
! GG1g. Is GG1a the current symbol of a gene group? (y/n)  :y
! GG2a. Action - gene group name to use in FlyBase      *e :
! GG2b. Gene group name(s) used in reference            *V :
! GG2c. Action - rename this gene group name        :
!
! GG3a. Action - obsolete GG1a in FlyBase (y)        TAKE CARE :
! GG3b. Action - dissociate GG1a from reference (y)  TAKE CARE :
!
! GG4.  Type of gene group [CV]  *t :
!
! GG5.  Description of gene group  [free text]  *D :
!
! GG6a. Key GO term(s) - Cellular Component (term ; ID)  *f :
! GG6b. Key GO term(s) - Molecular Function (term ; ID)  *F :
! GG6c. Key GO term(s) - Biological Process (term ; ID)  *d :
!
! GG7a. Related gene group(s) in FB - parent (symbol)     *P :
! GG7c. Related gene group(s) in FB - undefined (symbol)  *U :
! GG7d. Related dataset(s)/collection(s) in FB (symbol)   *C :
!
! GG8a. Orthologous gene group accession (rpt. sect. for mult.)  *O :
! GG8b. FlyBase database symbol (DB1a) for GG8a  *O :
! GG8c. Title for GG8a [free text]               *T :
!
! GG9.  Other related external resource(s) (title (URL))  *E :
!
! GG10. Comments [free text]  *u :
!
! GG11. Date gene group last reviewed (YYYYMMDD)  *y :
!
! GG12. Internal notes  *W :
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

=head1 AUTHOR

Haiyan Zhang, E<lt>haiyan@morgan.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
