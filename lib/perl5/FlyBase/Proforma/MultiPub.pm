package FlyBase::Proforma::MultiPub;

use 5.008004;
use strict;
use warnings;
use XML::DOM;
use FlyBase::WriteChado;
require Exporter;
use FlyBase::Proforma::Util;
use Carp qw(croak);
our @ISA = qw(Exporter);

# perl module for parsing FlyBase(www.flybase.org) MultiPub 
# proforma(multipub.pro) version 3.
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

FlyBase::Proforma::MultiPub - Perl module for parsing the FlyBase
MultiPub  proforma version 3, 30th April, 2007.

See the bottom for the proforma
                         

=head1 SYNOPSIS

  use FlyBase::Proforma::MultiPub;
  use DBI;
  
  my $mdbh=DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";
  my %ph=(MP1=>'2345', MP8=>'English',....);
  ###!c field implemented as '$fieldname.upd=>'c'' eg. 'P1.upd'=>'c'
   
  #params db is manditory, debug and validate is optional
  my $pro=FlyBase::proforma::MultiPub->new(db=>$mdbh);
  $pro->validate(%ph);
  my $chadoxml = $pro->process(%ph);
  
  # or

  my $pro=FlyBase::Proforma::MultiPub->new(db=>$mdbh,debug=>1,validate=>1);
  my $chadoxml_string=$pro->process(%ph);

=head1 DESCRIPTION

FlyBase::Proforma::MultiPub is a perl module for parsing FlyBase
MultiPublication proforma and write the result as chadoxml. it is required
to connected to a chado database for validating and processing.
The module also requires FlyBase::Proforma::Writechado and
FlyBase::Proforma::Util. The results can be loaded into a chado
database by XML::Xort.

=head2 EXPORT

  process
  validate

=cut

# Preloaded methods go here.

our %ti_fpr_type = (
    'MP1',  'uniquename',
    'MP2a', 'miniref',
    'MP2b', 'title',
    'MP3',  'new',
    'MP9',  'publisher',
    'MP5a', 'miniref',
    'MP5b', 'series_name',
    'MP6',  'pyear',
    'MP7',  'volume',         ##pub_dbxref
    'MP8',  'languages',      #pubprop
    'MP4',  'volumetitle',    #pubprop
    'MP10', 'pubplace',

    'MP11', 'pubauthor',      #pubauthor
    'MP12', 'pages',
    'MP15', 'isbn',           #pub_dbxref book-isbn, journal-issn
    'MP16', 'coden',          #pub_dbxref

    'MP14b', 'published_in_volume',    #pubprop
    'MP14c', 'published_in_issue',     #pubprop
    'MP14a', 'published_in_series',    #pubprop
    'MP13',  'published_in',           #pub_relationship.object_id
    'MP17',  'type_id',
    'MP18', 'pub_dbxref',                #
    'MP19', 'is_obsolete'
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
   Take !c in field mapping to pubprop, pub_relationship, pub_dbxref
	Not taking !c on other field. Take the value in other fields
	to the database, old value will be updated no matter there is !c or
	not.

=cut

sub process {
    my $self    = shift;
    my $tihash  = {@_};
    my %ph      = %$tihash;
    my $unique  = '';
    my $feature = '';
    my $out     = '';

    if ( exists( $self->{debug} ) && $self->{debug} == 1 ) {
        foreach my $key ( keys %ph ) {
            print STDERR "$key, $ph{$key}\n";
        }
    }

    if ( exists( $self->{validate} ) && $self->{validate} == 1 ) {
        $self->validate($tihash);
    }
    foreach my $key(keys %ph){
		 my $field=$key;
		 $field=~s/\.upd//;
	    if($key=~/upd/ && exists($ph{$field}) && $ph{$field} eq '') {
		   print STDERR "Warning: be careful about the !c in Multipub $field \n"; 
		 }
	 }
    if ( exists $ph{MP1} && $ph{MP1} ne 'new' ) {
        print STDERR "processing ", $ph{MP1}, "\n";
        if ( $ph{MP1} =~ /^\d+$/ ) {
            $unique = 'multipub_' . $ph{MP1};
        }
        else {
            $unique = $ph{MP1};
        }
    }
    else {
		   if($ph{MP1} ne 'new'){
		    print STDERR "ERROR: MP1 can not be empty\n";	
			}

        my $mini = '';
        if ( exists( $ph{MP2a} ) ) {
            $mini = $ph{MP2a};
        }
        else{
            $mini=$ph{MP2b};
        }
        if ( exists( $ph{MP5a} ) ) {
            $mini .= ' ' . $ph{MP5a};
        }
        
        print STDERR "processing $mini\n";
        if ( exists( $fbids{$mini} ) ) {
            $unique = $fbids{$mini};
            print STDERR "ERROR: assign $mini to OLD id $unique\n";
        }
        else {

            my $u = get_pub_uniquename_by_miniref( $self->{db}, $mini );
            if ( $u eq '' ) {
                $unique = get_tempid( 'multipub', $mini );
                $fbids{$mini} = $unique;
                print STDERR "STATE: $mini as new id $unique, record is ", $ph{MP3},
                  "\n";
            }
            else {
                $unique = $u;
                if (defined($ph{MP3}) && $ph{MP3} eq 'y' ) {
                    $unique = get_tempid( 'multipub', $mini );
                }
                $fbids{$mini} = $unique;
            }
        }
    }

    my %pubrecord = (
        doc        => $doc,
        uniquename => $unique,
        macro_id   => $unique,
        no_lookup  => 1
    );
    if(exists($ph{MP19}) && $ph{MP19} eq 'y'){
        print STDERR "Warning: this field MP19 is not tested yet\n";
        print STDERR "Action Items: delete multipub $unique\n";
        $pubrecord{is_obsolete}='t';
        $out.=dom_toString(create_ch_pub(%pubrecord));
        return $out;
    }
    if ( exists( $ph{MP17} ) && $ph{MP17} ne '' ) {
        $pubrecord{type} = $ph{MP17};
    }
    if ( exists( $ph{MP7} ) && $ph{MP7} ne '' ) {
        $pubrecord{volume} = $ph{MP7};
    }
    if ( exists( $ph{MP2a} ) && $ph{MP2a} ne '' ) {
        $pubrecord{miniref} = $ph{MP2a};
    }
    if ( exists( $ph{MP12} ) && $ph{MP12} ne '' ) {
        $pubrecord{pages} = $ph{MP12};
    }
    if ( exists( $ph{MP6} ) && $ph{MP6} ne '' ) {
        $pubrecord{pyear} = $ph{MP6};
    }
    if ( exists( $ph{MP2b} ) && $ph{MP2b} ne '' ) {
        $pubrecord{title} = $ph{MP2b};
    }
    if ( exists( $ph{MP4} ) && $ph{MP4} ne '' ) {
        $pubrecord{volumetitle} = $ph{MP4};
    }
    if ( exists( $ph{MP9} ) && $ph{MP9} ne '' ) {
        $pubrecord{publisher} = $ph{MP9};
    }
    if ( exists( $ph{MP10} ) && $ph{MP10} ne '' ) {
        $pubrecord{pubplace} = $ph{MP10};
    }
    if ( exists( $ph{MP5b} ) && $ph{MP5b} ne '' ) {
        $pubrecord{series_name} = $ph{MP5b};
    }
	 if( exists( $ph{"MP5b.upd"}) && $ph{MP5b} eq ''){
	     $pubrecord{series_name} ="";
	 }
    if ( exists( $ph{MP5a} ) && $ph{MP5a} ne '' ) {
        $pubrecord{miniref} .= ' ' . $ph{MP5a};
    }
    $feature = create_ch_pub(%pubrecord);

    $out .= dom_toString($feature);
    if ( exists( $pubrecord{miniref} ) ) {
        $fbids{ $pubrecord{miniref} } = $unique;
    }
    foreach my $f ( keys %ph ) {

        # print STDERR "$f\n";
        if ( $f eq 'MP13' ) {
            my $object  = 'object_id';
            my $subject = 'subject_id';

            if ( exists( $ph{ "$f.upd" } ) and $ph{ "$f.upd" } eq 'c' ) {
            print STDERR "Action Items: !c log, $unique $f\n";
                my @results =
                  get_unique_key_for_pr( $self->{db}, $unique,
                    $ti_fpr_type{$f} );
                foreach my $ta (@results) {
                    my $pr_obj = create_ch_pub_relationship(
                        doc        => $doc,
                        subject_id => $unique,
                        is_object  => 't',
                        rtype      => $ti_fpr_type{$f},
                        uniquename => $ta->{object_id},
                        rank       => $ta->{rank}
                    );
                    $pr_obj->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($pr_obj);
                    $pr_obj->dispose();
                }
            }
            if ( $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    my $object_id = '';
                    if ( exists( $fbids{$item} ) ) {
                        $object_id = $fbids{$item};
                    }
                    else {
                        my $in =
                          get_pub_uniquename_by_miniref( $self->{db}, $item );
              
                        if ( !defined($in) ) {
                            print STDERR "ERROR: Could not find $item in DB\n";
                        }
                        else {
                            $object_id =
                              create_ch_pub( doc => $doc, uniquename => $in );
                        }
                    }
                    my $pr = create_ch_pub_relationship(
                        doc      => $doc,
                        $subject => $unique,
                        $object  => $object_id,
                        rtype    => $ti_fpr_type{$f}
                    );
                    $out .= dom_toString($pr);
                    $pr->dispose();
                }
            }
        }
        elsif ( $f eq 'MP8' || $f =~ 'MP14' ) {
            if ( exists( $ph{ "$f.upd" } ) && $ph{ "$f.upd" } eq 'c' ) {
                print STDERR "Action Items: !c log, $unique  $f\n";
                my @results =
                  get_ranks_for_pubprop( $self->{db}, $unique,
                    $ti_fpr_type{$f} );
                foreach my $t (@results) {
                    my $pub_prop = create_ch_pubprop(
                        doc    => $doc,
                        pub_id => $unique,
                        type   => $ti_fpr_type{$f},
                        rank   => $t
                    );
                    $pub_prop->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($pub_prop);
                    $pub_prop->dispose();
                }
            }
            if ( $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    $out .=
                      write_pubprop( $self->{db}, $doc, $unique,
                        $ti_fpr_type{$f}, $item );
                }
            }
        }
        elsif($f eq 'MP18'){
            print STDERR "Warning: This is an untested field $f\n";
            print STDERR "Action Items: multipub merge $unique $ph{MP18}\n";
            my @items=split('\n',$ph{$f});
            foreach my $item(@items){
                   $item =~ s/^\s+//;
                   $item =~ s/\s+$//;
						 if($item=~/^\d+$/){
						    $item='multipub_'.$item; 
						 }
                   $out.=dom_toString(
                         create_ch_pub_dbxref( doc=>$doc,
                         pub_id=>$unique,
                         dbxref_id=>create_ch_dbxref( doc=>$doc,
                         db=>'FlyBase', accession=>$item, no_lookup=>1),
                         is_current=>'f', 
                         ));
                   $out.=dom_toString(
                         create_ch_pub( doc=>$doc,
                         uniquename=>$item,
                         is_obsolete=>'t',
                         no_lookup=>1));
                   $out.=update_multipub($self->{db}, $doc, $unique,$item);
                   
            }
        }
        elsif ( $f eq 'MP15' || $f eq 'MP16' ) {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
            print STDERR "Action Items: !c log, $unique $f\n";
                my @result =
                  get_dbxref_for_pub_dbxref( $self->{db}, $unique,
                    $ti_fpr_type{$f} );
                if ( $f eq 'MP15' ) {
                    my @is =
                      get_dbxref_for_pub_dbxref( $self->{db}, $unique, 'issn' );

                    foreach my $item (@is) {
                        my $pub_dbxref = create_ch_pub_dbxref(
                            doc       => $doc,
                            pub_id    => $unique,
                            dbxref_id => create_ch_dbxref(
                                doc       => $doc,
                                db        => 'issn',
                                accession => $item
                            )
                        );

                        $pub_dbxref->setAttribute( 'op', 'delete' );
                        $out .= dom_toString($pub_dbxref);
                        $pub_dbxref->dispose();
                    }
                }
                foreach my $item (@result) {
                    my $pub_dbxref = create_ch_pub_dbxref(
                        doc       => $doc,
                        pub_id    => $unique,
                        dbxref_id => create_ch_dbxref(
                            doc       => $doc,
                            db        => $ti_fpr_type{$f},
                            accession => $item
                        )
                    );

                    $pub_dbxref->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($pub_dbxref);
                    $pub_dbxref->dispose();
                }
            }
            if ( $ph{$f} ne '' ) {
                my $istype = $ti_fpr_type{$f};
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    if ( $f eq 'MP15' ) {
                        if ( length($item) == 9 ) {
                            $istype = 'issn';
                        }
                    }
                    my $f_cvterm = create_ch_pub_dbxref(
                        doc       => $doc,
                        pub_id    => $unique,
                        dbxref_id => create_ch_dbxref(
                            doc       => $doc,
                            db        => $istype,
                            accession => $item,
                            no_lookup => 1
                        )
                    );

                    $out .= dom_toString($f_cvterm);
                    $f_cvterm->dispose();
                    
                }
            }
        }
        elsif ( $f eq 'created' && exists( $ph{file} ) ) {
            my $p = $curator{ $ph{cur} };
            if ( !defined($p) ) {
                $p = 'Unknown';
            }
            my $item =
                'Curator: ' 
              . $p
              . ';Proforma: '
              . $ph{file}
              . ';timelastmodified: '
              . $ph{$f};
            $out .=
              write_pubprop( $self->{db}, $doc, $unique, 'curated_by', $item );
        }
        elsif ( $f eq 'MP11' ) {
            #author format is :[surname]\t[firstname]
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
            print STDERR "Action Items: !c log, $unique  $f\n";
                my @result = get_rank_for_pubauthor( $self->{db}, $unique );
                foreach my $item (@result) {
                    my $pub_author = create_ch_pubauthor(
                        doc    => $doc,
                        pub_id => $unique,
                        rank   => $item
                    );
                    $pub_author->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($pub_author);
                    $pub_author->dispose();
                }
            }
            if ( $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                my $num = 0;
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    my ($last,$first) = split( /\t/, $item );
                    $num++;
                  if ( $first eq '?.' ) {
                        $first = '';
                     }
                    my $authors = create_ch_pubauthor(
                        doc        => $doc,
                        pub_id     => $unique,
                        surname    => $last,
                        givennames => $first,
                        rank       => $num,
                        editor     => 't'
                    );
                    $out .= dom_toString($authors);
                    $authors->dispose();
                }
            }

        }

    }
      $doc->dispose();
    return $out;
}

sub get_pub_type {
    my $dbh        = shift;
    my $uniquename = shift;

    my $statement = "select cvterm.name from pub, cvterm where
	pub.uniquename='$uniquename' and pub.type_id=cvterm.cvterm_id";
    my $pt = $dbh->prepare($statement);
    $pt->execute;
    my $name = $pt->fetchrow_array;

    return $name;
}

sub get_unique_key_for_pr {
    my $dbh    = shift;
    my $fbrf   = shift;
    my $cvterm = shift;
    my @ranks  = ();

    my $statement = "select rank, pub1.uniquename from pub_relationship
	pr, pub pub1, pub pub2, cvterm
	where pub1.pub_id=pr.object_id and pub2.pub_id=pr.subject_id and
	pub2.uniquename='$fbrf' and cvterm.cvterm_id=pr.type_id and
	cvterm.name='$cvterm'";
    my $pr_nmm = $dbh->prepare($statement);
    $pr_nmm->execute;
    while ( my ( $rank, $obj ) = $pr_nmm->fetchrow_array ) {
        my %tmp = ( rank => $rank, object_id => $obj );
        push( @ranks, \%tmp );
    }
    return @ranks;
}

=head2 $pro->validate(%ph)
	
	validate the following:
	1. validate whether MP1 is a valid pub in the database
	2. validate whether MP13/MP18 is a valid pub uniquename in the database.
	3. If MP3 is y, MP1 must exists. check whether the journal 
	   abbreviation (MP2a+MP5a) is same in the database. 
    
=cut

sub validate {
    my $self   = shift;
    my $tihash = {@_};
    my %tival  = %$tihash;
    my $unique = '';
    if ( defined( $tival{MP1} ) ) {
        print STDERR "Validating MultiPub ", $tival{MP1}, " ....\n";
        if ( $tival{MP1} =~ /^\d+$/ ) {
            $unique = 'multipub_' . $tival{MP1};
        }
        else {
            $unique = $tival{MP1};
        }
        validate_pub($unique);
    }
    elsif ( defined( $tival{MP2b} ) ) {
        print STDERR "Validating MultiPub ", $tival{MP2b}, " ...\n";
    }
    elsif ( defined( $tival{MP2a} ) ) {
        print STDERR "Validating MultiPub ", $tival{MP2a}, " ...\n";
    }
    if ( $tival{MP3} eq 'n' ) {
        if ( !defined( $tival{MP1} ) ) {
            print STDERR "ERROR: please put in the reference unique ID\n";
        }
        if ( $tival{MP2a} ne '' && $tival{"MP2a.upd"} ne 'c' ) {
            my $mini = $tival{MP2a};
            if ( exists( $tival{MP5a} ) ) {
                $mini .= ' ' . $tival{MP5a};
            }
            my $id = get_pub_uniquename_by_miniref( $db, $mini );
            if ( !defined($id) ) {
                print STDERR "ERROR: $mini is not match to pub $unique\n";
            }
            elsif ( defined($id) and $id ne $tival{MP1} ) {
                print STDERR "ERROR pub title and id NOT MATCH\n";
            }
        }
        elsif($tival{"MP2a.upd"} eq 'c') {
            my $mini = $tival{MP2a};
            if ( exists( $tival{MP5a} ) ) {
                $mini .= ' ' . $tival{MP5a};
            }
            my $id = get_pub_uniquename_by_miniref( $db, $mini );
            if ( defined($id) ) {
                print STDERR "ERROR, multipub abbreviation already exists\n";
            }
        }
    }
  
    ##validate MP13 for a valid pub uniquename
    if ( exists( $tival{MP13} ) ) {
        my @items = split( /\n/, $tival{MP13} );
        foreach my $item (@items) {
            validate_pub($item);
        }
    }
   if ( exists( $tival{MP18} ) ) {
        my @items = split( /\n/, $tival{MP18} );
        foreach my $item (@items) {
            validate_pub($item);
        }
    }
}
sub validate_pub {
    my $name      = shift;
    my $statement = "select pub_id from pub where uniquename='$name'";
    my $pnmm      = $db->prepare($statement);
    $pnmm->execute;
    my $pub = $pnmm->fetchrow_array;

    if ( !defined($pub) ) {
        print STDERR "ERROR: Could not find $name in pub\n";
    }
}
sub DESTROY {
    my $self = shift;

    # $self->{doc}->dispose;

}

1;
__END__


=head1 SUPPORT

proformas can be found in http://flystocks.bio.indiana.edu/flybase/curation-docs/genetic-literature/

proforma mapping table can be found in ~haiyan/Documents/publicationmapping.sxw 

chado schema can be found in http://www.gmod.org

=head1 SEE ALSO

FlyBase::WriteChado
FlyBase::Proforma::Util
FlyBase::Proforma::TP
FlyBase::Proforma::TI
FlyBase::Proforma::TE
FlyBase::Proforma::Gene
FlyBase::Proforma::Aberr
FlyBase::Proforma::Allele
FlyBase::Proforma::Balancer
XML::Xort

=head1 Proforma

! MULTIPUBLICATION PROFORMA                   Version 3:  30 April 2007
!
! MP. MULTIPUBLICATION SOURCE DATA
!
! MP1.   Reference unique ID                       *U :
! MP2a.  Reference abbreviation                    *s :
! MP2b.  Reference full name                       *u :
! MP3.   Is this a new multipub.master record? y/n?   :y
! MP4.   Series/volume/part number within a series *v :
! MP5a.  Series abbreviation                       *S :
! MP5b.  Series full name                          *T :
! MP6.   Date (range) of publication               *t :
! MP7.   Volume number                             *V :
! MP8.   Language                                  *L :English
! MP9.   Publisher                                 *x :
! MP10.  Place(s) of publication                   *P :
! MP11.  Editor(s) or author(s)                 *a-*r :
! MP12.  Number of pages                           *z :
! MP13.  Parent journal                            *w :
! MP14a. Parent journal series                     *Q :
! MP14b. Parent journal volume                     *y :
! MP14c. Parent journal issue                      *Y :
! MP15.  ISBN/ISSN                                 *I :
! MP16.  CODEN                                     *D :
! MP17.  Reference type - P1 CV                   NSC :compendium
! MP18.  Multipub(s) to be merged into MP1.        *N :
! MP19.  Action - delete multipub  - TAKE CARE :
!!!!!!!!!!!!!!!!!! END OF RECORD FOR THIS PUBLICATION !!!!!!!!!!!!!!!!!!!!

=head1 AUTHOR

Haiyan Zhang, E<lt>haiyan@morgan.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
