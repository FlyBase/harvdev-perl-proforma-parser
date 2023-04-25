package FlyBase::Proforma::Pub;

use 5.008004;
use strict;
use warnings;
use File::Basename;
use XML::DOM;
use FlyBase::WriteChado;
require Exporter;
use FlyBase::Proforma::Util;
use Carp qw(croak);
use Encode;
our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use FlyBase::Proforma::Pub ':all';
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
    
    FlyBase::Proforma::Pub - Perl module for parsing the FlyBase
    Publication  proforma version 27, June 15, 2007.
    
    See the bottom for the proforma
    
    
=head1 SYNOPSIS
    
use FlyBase::Proforma::Pub;
use DBI;

my $mdbh=DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";
my %ph=(P22=>'FBrf0012345', P1=>'paper',....);
###!c field implemented as '$fieldname.upd'=>'c' eg. 'P1.upd'=>'c'

#params db is manditory, debug and validate is optional
my $pro=FlyBase::proforma::Pub->new(db=>$mdbh);
$pro->validate(%ph);
my $chadoxml = $pro->process(%ph);

# or

my $pro=FlyBase::Proforma::Pub->new(db=>$mdbh,debug=>1,validate=>1);
my $chadoxml_string=$pro->process(%ph);

=head1 DESCRIPTION

FlyBase::Proforma::Pub is a perl module for parsing FlyBase
publication proforma and write the result as chadoxml. It is required
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
    'P22',  'uniquename',
    'P1',   'type_id',
    'P32',  'merge',
    'P20',  'seria_name',
    'P4',   'issue',
    'P8',   'publisher',
    'P10',  'pyear',
    'P11a', 'pages',
    'P11b', 'URL',                   #pubprop
    'P11c', 'GB',                    ##pub_dbxref
    'P11d', 'DOI',                   #pub_dbxref
    'P12',  'pubauthor',             #pubauthor
    'P13',  'languages',             #pubprop
    'P14',  'abstract_languages',    #pubprop
    'P16',  'title',
#    'P21',  'published_in',          ##pub_relationship
    'P2',   'miniref',          ## pub_relationship 'published_in'
    'P24',  'pubplace',
    'c3',   'internalnotes',
    'P29', 'isbn',                   #pub_dbxref
    'P25', 'biosis',                 #pub_dbxref
    'P26', 'pubmed',                #pub_dbxref
    'P27', 'zoorec_id',              #pub_dbxref
    'P33', 'conf_abs_text',
    'P31', 'related_to',             #pub_relationship
    'P30', 'also_in',                #pub_relationship
    'P23', 'perscommtext',           #pubprop
    'P18', 'associated_text',        #pubprop
    'P19', 'internalnotes',          #pubprop
    'P38', 'deposited_files',        #pubprop
     'P39', 'is_obsolete',
     'P40', 'cam_flag',             #pubprop CAMCUR 
     'P41', 'harv_flag',             #pubprop HARVCUR
     'P42', 'onto_flag',             #pubprop ONTO
     'P43', 'dis_flag',          #pubprop DISEASE
     'P44', 'diseasenotes',          #pubprop 
     'P28', 'PMCID',              #pub_dbxref
     'P34', 'pubmed_abstract',    #pubprop 
     'P45', 'not_Drospub',    #pubprop
     'P46', 'graphical_abstract',    #pubprop 
);

my $doc = new XML::DOM::Document();
my $db  = '';
my $doi = 'http://dx.doi.org/';

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
    Not taking !c on other field. For other fields, old values will be 
    updated no matter there is !c or not. e.g. P12 authors.

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
    
    if ( exists $ph{P22} && $ph{P22} ne 'new') {
        if ( $ph{P22} =~ /^\d+$/ ) {
            my $zeros = '0' x ( 7 - length( $ph{P22} ) );
            $unique = 'FBrf' . $zeros . $ph{P22};
        }
        elsif ( $ph{P22} =~ /FBrf/ ) {
            $unique = $ph{P22};

        }
        else {
            $unique = $ph{P22};
        }
        validate_pub('P22',$ph{P22});
        print STDERR "processing Pub $unique\n";
    }
    else {
		 if (!exists($ph{P22}) || $ph{P22} eq ""){
		  print STDERR "ERROR, P22 can not be blank\n"; 
		 }
        if ( exists( $ph{P16} ) && exists( $fbids{ $ph{P16} } ) ) {
            print STDERR "Warning: title is already exists,", $ph{P16}, "\n";
        }
        $unique = get_pub_uniquename(%ph);
        if ( $unique eq '0' ) {
            $unique = get_tempid('rf');
            if ( exists( $ph{P16} ) ) {
                $fbids{ $ph{P16} } = $unique;
            }
            else {
                $fbids{$unique} = 1;
            }
            print STDERR "STATE: assigne new pub $unique to\n";
            if(!exists($ph{P1})){
                print STDERR "ERROR: new pub has to have a type, fill P1\n";
            }
        }
     
    }
    my %pubrecord = (
        doc        => $doc,
        uniquename => $unique,
        macro_id   => $unique,
        no_lookup  => 1
    );

    if ( exists( $ph{P1} ) ) {
        $pubrecord{type} = $ph{P1};
    }
    if ( exists( $ph{P3} ) ) {
        $pubrecord{volume} = $ph{P3};
    }
    if ( exists( $ph{P4} ) ) {
        $pubrecord{issue} = $ph{P4};
    }
    if ( exists( $ph{P11a} ) ) {
        $pubrecord{pages} = $ph{P11a};
    }
    if ( exists( $ph{P10} ) ) {
        $pubrecord{pyear} = $ph{P10};
    }
    if ( exists( $ph{P16} ) ) {
        $pubrecord{title} = $ph{P16};
    }
    if ( exists( $ph{P17} ) ) {
        $pubrecord{volumetitle} = $ph{P17};
    }
    if ( exists( $ph{P8} ) ) {
        $pubrecord{publisher} = $ph{P8};
    }
    if ( exists( $ph{P24} ) ) {
        $pubrecord{pubplace} = $ph{P24};
    }
    if ( exists( $ph{P20} ) ) {
        $pubrecord{series_name} = $ph{P20};
    }
	 if ( exists( $ph{P39})){
	     $pubrecord{is_obsolete} ='t';
	 }
    $feature = create_ch_pub(%pubrecord);

    $out .= dom_toString($feature);
   
##Process other field in Trangenic Insertion proforma
    foreach my $f ( keys %ph ) {
    #print STDERR "$f\n";
        if ( $f eq 'P32' ) {
###merge pub
            my @items = split( /\n/, $ph{$f} );
            foreach my $item (@items) {
                $item =~ s/^\s+//;
                $item =~ s/\s+$//;
                my $subf = create_ch_pub(
                    doc         => $doc,
                    uniquename  => $item,
                    macro_id    => $item,
                    is_obsolete => 't',
                    no_lookup   => 1
                );
                $out .= dom_toString($subf);
                $subf->dispose();
                my $pdbx= create_ch_pub_dbxref(
                    doc=> $doc,
                    pub_id=>$unique,
                    is_current=>'f',
                    dbxref_id=>create_ch_dbxref(
                       doc=>$doc,
                       db=>'FlyBase',
                       accession=>$item,
                       no_lookup=>1
                       ));
                $out.=dom_toString($pdbx);
                $pdbx->dispose();
                $out.=update_pub($self->{db}, $doc, $unique,$item);
            }
            
        }
        elsif( $f eq 'P39'){
           $out.=delete_pub($self->{db},$doc,$unique);
        }
        elsif ( $f eq 'P30') {
            my $object  = 'object_id';
            my $subject = 'subject_id';
		  
            if ( exists( $ph{"$f.upd"} ) and $ph{"$f.upd"} eq 'c' ) {
            print STDERR "Action Items: !c log, $unique $f\n";
                my @results =
                  get_unique_key_for_pr( $self->{db}, $unique,
                    $ti_fpr_type{$f} );
                foreach my $ta (@results) {
                    my $pr_obj = create_ch_pub_relationship(
                        doc        => $doc,
                        is_object  => 't',
                        subject_id => $unique,
                        rtype      => $ti_fpr_type{$f},
                        uniquename => $ta->{object_id}
                    );
                    $pr_obj->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($pr_obj);
                    $pr_obj->dispose();
                }
            }
            if ( $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                  my $pr='';
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                       if(($f eq 'P30') && !($item =~/FBrf/)){
                           print STDERR "ERROR: P30 field has no pub id $item\n";
                                next;
                          }
                    $pr = create_ch_pub_relationship(
                        doc      => $doc,
                        $subject => $unique,
                        $object =>
                          create_ch_pub( doc => $doc, uniquename => $item ),
                        rtype => $ti_fpr_type{$f}
                    );
                    $out .= dom_toString($pr);
                    $pr->dispose();
                }
            }
}
        elsif ( $f eq 'P31') {
            my $object  = 'object_id';
            my $subject = 'subject_id';
		  
            if ( exists( $ph{"$f.upd"} ) and $ph{"$f.upd"} eq 'c' ) {
            print STDERR "Action Items: !c log, $unique $f\n";
                my @results =
                  get_unique_key_for_pr( $self->{db}, $unique,$ti_fpr_type{$f} );
                  foreach my $ta (@results) {
                    my $pr_obj = create_ch_pub_relationship(
                        doc        => $doc,
                        is_object  => 't',
                        subject_id => $unique,
                        rtype      => $ti_fpr_type{$f},
                        uniquename => $ta->{object_id}
                    );
                    $pr_obj->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($pr_obj);
                    $pr_obj->dispose();
                }

                  @results =
                  get_unique_key_for_prs( $self->{db}, $unique,$ti_fpr_type{$f} );
                  foreach my $ta (@results) {
                    my $pr_obj = create_ch_pub_relationship(
                        doc        => $doc,
                        is_subject  => 't',
                        object_id => $unique,
                        rtype      => $ti_fpr_type{$f},
                        uniquename => $ta->{subject_id}
                    );
                    $pr_obj->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($pr_obj);
                    $pr_obj->dispose();
                }
               }                
            if ( $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                  my $pr='';
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                       if(( $f eq 'P31') && !($item =~/FBrf/)){
                           print STDERR "ERROR: P31 field has no pub id $item\n";
                                next;
                          }
                        if ($item gt $unique){
                         $pr = create_ch_pub_relationship(
                        doc      => $doc,
                        $subject => $unique,
                        $object =>
                          create_ch_pub( doc => $doc, uniquename => $item),
                        rtype => $ti_fpr_type{$f}
                       );
                        }
                        else{
                           $pr = create_ch_pub_relationship(
                        doc      => $doc,
                        $subject => create_ch_pub( doc => $doc, uniquename => $item),
                        $object =>$unique,
                          
                        rtype => $ti_fpr_type{$f}
                       );
                        }
                       $out .= dom_toString($pr);
                    $pr->dispose();
                }
            }
	  }

        elsif ($f eq 'P46')
	  {
	    print STDERR "NEW field $f value $ph{$f}, $unique\n";
            my $ptype=$ti_fpr_type{$f};
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
             print STDERR "Action Items: !c log, $unique $f\n";
                my @results =
                  get_ranks_for_pubprop( $self->{db}, $unique,
                    $ptype );
                foreach my $t (@results) {
                    my $pub_prop = create_ch_pubprop(
                        doc    => $doc,
                        pub_id => $unique,
                        type   => $ptype,
                        rank   => $t
                    );
                    $pub_prop->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($pub_prop);
                    $pub_prop->dispose();
                }
               if(@results==0){
                print STDERR "ERROR: no previous record in database\n";
               }
            }
            if (defined($ph{$f}) && $ph{$f} ne '' ) {
	      my @items = split( /\n/, $ph{$f} );
	      if(scalar @items > 1){
		print STDERR "ERROR: $unique $f has more than 1 file \n";
		exit(0);
	      }
	      my($filename,$path,$suffix) = fileparse($ph{$f},'\.jpg');
	      print STDERR "DEBUG new field: $f = $ph{$f} filename = $filename, path = $path, suffix = $suffix\n";
	      if(($filename eq '' ) || ($path eq "./" ) || ($suffix ne ".jpg" )){
		print STDERR "ERROR: $unique $f $ph{$f} incorrect format\n";
		exit(0);
	      }
	      print STDERR "DEBUG new field: $f = $ph{$f}\n";
	      if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
		print STDERR "DEBUG $f !c overwite\n";
		my $rank = 0;
		$out .=
		  write_pubprop_withrank( $self->{db}, $doc, $unique,
					$ptype, $ph{$f}, $rank);
	      }
	      else{
		my $match = match_value_for_pubprop( $self->{db}, $unique,
						$ptype , $ph{$f});
		if($match == 0){
		  print STDERR "DEBUG new field: $f value $ph{$f} not in chado\n";
		  my $rank = 0;
		  $out .=
		    write_pubprop_withrank( $self->{db}, $doc, $unique,
					$ptype, $ph{$f}, $rank);
		}
		else{
		  print STDERR "ERROR: Value for $f already in chado use !c to replace\n";
		}
	      }
	    }
	  }
	       
        elsif ($f eq 'P11b'
            || $f eq 'P13'
            || $f eq 'P14'
            || $f eq 'P23'
            || $f eq 'P18'
            || $f eq 'P19'
            || $f eq 'P38'
            || $f eq 'P40'
            || $f eq 'P41'
            || $f eq 'P42'
            || $f eq 'P43'
            || $f eq 'P44'
            || $f eq 'c3'
            || $f eq 'P33'
            || $f eq 'P34'
            || $f eq 'P45' )
        {
            my $ptype=$ti_fpr_type{$f};   
            if($f eq 'P18' && exists($ph{P1}) && $ph{P1} eq 'abstract'){
                $ptype='conf_abs_text';
            }
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
             print STDERR "Action Items: !c log, $unique $f\n";
                my @results =
                  get_ranks_for_pubprop( $self->{db}, $unique,
                    $ptype );
                foreach my $t (@results) {
                    my $pub_prop = create_ch_pubprop(
                        doc    => $doc,
                        pub_id => $unique,
                        type   => $ptype,
                        rank   => $t
                    );
                    $pub_prop->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($pub_prop);
                    $pub_prop->dispose();
                }
               if(@results==0){
                print STDERR "ERROR: no previous record in database\n";
               }
            }
            if (defined($ph{$f}) && $ph{$f} ne '' ) {  
                if($f eq 'P18' || $f eq 'P23' || $f eq 'P19' || $f eq 'P33'|| $f eq 'P34' ){
          # If convert is 'y' then subscripts etc will be done
          my $convert = 'y';
          if ($f eq 'P34'){
              $convert = 'n';
          }
		  $out .=
		    write_pubprop( $self->{db}, $doc, $unique,
                        $ptype, $ph{$f}, $convert);
		}
		elsif($f eq 'P45'){
		    if($ph{$f} eq "y"){
			$out .=
			    write_pubprop( $self->{db}, $doc, $unique,
					   $ptype, $ph{$f});
		    }
		    else{
			print STDERR "ERROR: P45 must be 'y'/blank\n";
		    }
		}
		else{
		  my @items = split( /\n/, $ph{$f} );
		  foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                
                    $out .=
                      write_pubprop( $self->{db}, $doc, $unique,
				     $ptype, $item );
		  }
                }
            }
        }
        elsif ($f eq 'P25'
            || $f eq 'P26'
            || $f eq 'P28'
            || $f eq 'P11d'
            || $f eq 'P27'
            || $f eq 'P29'
            || $f eq 'P11c' )
        {
            if ( $f eq 'P11c' ) {
	       my @results =
                  get_unique_key_for_pr( $self->{db}, $unique, 'published_in' );
	       foreach my $ta (@results) {	       
                if ( $ta->{object_id} eq 'multipub_8651' ) {
                    $ti_fpr_type{$f} = 'GB';
                }
                elsif ( $ta->{object_id}  eq 'multipub_8667' ) {
                    $ti_fpr_type{$f} = 'UniProt/SwissProt';
                }
	      }
            }
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
             print STDERR "Action Items: !c log, $unique $f\n";
                my @result =
                  get_dbxref_for_pub_dbxref( $self->{db}, $unique,
                    $ti_fpr_type{$f} );

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
            if ( defined($ph{$f}) && $ph{$f} ne '' ) {
	      if($f eq 'P28'){
		my $item =  $ph{$f};
		print STDERR "DEBUG: PMCID  = $ph{$f}\n";
		if($item !~ /^PMC\d+$/){
		  print STDERR "ERROR: PMCID must be 1 entry and begin with PMC followed by 7? digits\n";
		  exit(0);
		}
		else{
		  my $f_cvterm = create_ch_pub_dbxref(
			doc       => $doc,
			pub_id    => $unique,
                        dbxref_id => create_ch_dbxref(
                            doc       => $doc,
                            db        => $ti_fpr_type{$f},
                            accession => $item,
                            no_lookup => 1
                        )
                    );
		  $out .= dom_toString($f_cvterm);
		  $f_cvterm->dispose();
		}
	      }
	      else{
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    my $f_cvterm = create_ch_pub_dbxref(
                        doc       => $doc,
                        pub_id    => $unique,
                        dbxref_id => create_ch_dbxref(
                            doc       => $doc,
                            db        => $ti_fpr_type{$f},
                            accession => $item,
                            no_lookup => 1
                        )
                    );

                    $out .= dom_toString($f_cvterm);
                    $f_cvterm->dispose();
                }
	      }
            }
        }
        elsif ( $f eq 'P2' ) {
            my $object  = 'object_id';
            my $subject = 'subject_id';
	    if ( exists( $ph{"$f.upd"} ) and $ph{"$f.upd"} eq 'c' ) {
            print STDERR "Action Items: !c log, $unique $f\n";
                my @results =
                  get_unique_key_for_pr( $self->{db}, $unique, 'published_in' );
                foreach my $ta (@results) {
                    my $pr_obj = create_ch_pub_relationship(
                        doc        => $doc,
                        is_object  => 't',
                        subject_id => $unique,
                        rtype      => 'published_in',
                        uniquename => $ta->{object_id}
                    );
                    $pr_obj->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($pr_obj);
                    $pr_obj->dispose();
                }
            }
           if(exists($ph{$f}) && $ph{$f} ne ""){
	     my $j_u  = '';
	     my $mini = $ph{$f};
	     if ( exists( $fbids{$mini} ) ) {
	       $j_u = $fbids{$mini};
	       print STDERR "Warning: $mini defined before as $j_u\n";
	     }
	     else {
	       my $j = get_pub_uniquename_by_miniref( $self->{db}, $mini );
	       $fbids{$mini} = $j;
	       if ( $j eq '' ) {
		 
		 $j = get_tempid( 'multipub', $mini );
		 print STDERR "ERROR: assign $j to $mini\n";
						  #exit(0);
	       }
	       else{
		 print STDERR "CHECK: $mini in DB $j\n";
               }

	       $j_u = create_ch_pub( doc => $doc, uniquename => $j , macro_id=>$j);
	     }
	     #check if pub already has a parent pub relationship
	     if( !exists( $ph{"$f.upd"} ) and ($unique !~ /temp/)){
	       print STDERR "CHECK: check if $unique has a parent_pub miniref = to P2 $mini\n";
	       my @results = ();
	       @results = get_unique_key_for_pr( $self->{db}, $unique, 'published_in' ); 
	       print STDERR "CHECK: P2 uniquename for multipub $mini check  returns 	$#results\n";       
	       if ( $#results == 0){
		 foreach my $ta (@results) {
		   my $val = &validate_P2($ta->{object_id},$mini);
		   if($val != 1){
		     print STDERR "ERROR:In P2 $unique Parent pub has different abbrev -- use !c P2 to change\n";
		   }
		 }
	       }
	       elsif( $#results > 0){
		 print STDERR "ERROR:In P2 $unique Parent pub exists -- use !c P2 to change\n";	
	       } 
	       else{
		 print STDERR "CHECK:P2 FBrf $unique OK to add Parent pub $mini\n";
	       }		   
	     }
	     my $pr = create_ch_pub_relationship(
						   doc        => $doc,
						   subject_id => $unique,
						   object_id => $j_u,
						   rtype      =>  'published_in',
						  );
	     $out .= dom_toString($pr);
	     $pr->dispose();	       
	   }
	  }
        elsif ( $f eq 'created' && exists( $ph{file} ) ) {
          
            my $p = $curator{ $ph{cur} };
            if ( !defined($p) ) {
					$p=$curator{$ph{c1}};
					if(!defined($p)){
                $p = 'Unknown Curator';
				 }
            }
            my $item =
                'Curator: ' 
              . $p
              . ';Proforma: '
              . $ph{file}
              . ';timelastmodified: '
              . $ph{$f};
            print STDERR "Action Item: $unique == $ph{file}\n";
            #print $item;
            $out .=
              write_pubprop( $self->{db}, $doc, $unique, 'curated_by', $item );
        }
        elsif ( $f eq 'P12' ) {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
             print STDERR "Action Items: !c log, $unique $f\n";
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
                    if(defined($first) && ($first eq '?.')){
                        $first='';
                    }
                    $num++;
                    my $authors = create_ch_pubauthor(
                        doc        => $doc,
                        pub_id     => $unique,
                        surname    => $last,
                        rank       => $num
                    );
                    if(defined($first) && ($first ne '')){
                        $authors->appendChild(create_doc_element($doc,'givennames',$first));
                    }
						  else{
							  print STDERR "Warning: no given name for P12 $item\n";
						  }
                    $out .= dom_toString($authors);
                    $authors->dispose();
                }
            }

        }

    }
   $doc->dispose();
    return ( $out, $unique );
}

sub get_unique_key_for_pr {
    my $dbh    = shift;
    my $fbrf   = shift;
    my $cvterm = shift;
    my @ranks  = ();

    my $statement = "select pub1.uniquename from pub_relationship
pr, pub pub1, pub pub2, cvterm
where pub1.pub_id=pr.object_id and pub2.pub_id=pr.subject_id and
pub2.uniquename='$fbrf' and cvterm.cvterm_id=pr.type_id and
cvterm.name='$cvterm' and pub1.is_obsolete = false and pub2.is_obsolete = false";
    my $pr_nmm = $dbh->prepare($statement);
    $pr_nmm->execute;
    while ( my ($obj) = $pr_nmm->fetchrow_array ) {
        my %tmp = ( object_id => $obj );
        push( @ranks, \%tmp );
    }
    return @ranks;
}
sub validate_P2 {
    my $p21 = shift; #uniquename from get_unique_key_for_pr 
    my $p2  = shift;
    my $result = 0;

    my $state = "select miniref from pub where uniquename='$p21'";
    my $p_nmm = $db->prepare($state);
    $p_nmm->execute;
    my $miniref = $p_nmm->fetchrow_array;

    if ( defined($miniref) && $miniref ne $p2 ) {

        print STDERR "ERROR: field P2 and $miniref do not match\n";
    }
    else{
      $result = 1;
    }
    return $result;
}
sub get_unique_key_for_prs {
    my $dbh    = shift;
    my $fbrf   = shift;
    my $cvterm = shift;
    my @ranks  = ();

    my $statement = "select pub1.uniquename from pub_relationship
pr, pub pub1, pub pub2, cvterm
where pub1.pub_id=pr.subject_id and pub2.pub_id=pr.object_id and
pub2.uniquename='$fbrf' and cvterm.cvterm_id=pr.type_id and
cvterm.name='$cvterm' and pub1.is_obsolete = false and pub2.is_obsolete = false";
    my $pr_nmm = $dbh->prepare($statement);
    $pr_nmm->execute;
    while ( my ($subj) = $pr_nmm->fetchrow_array ) {
        my %tmp = ( subject_id => $subj );
        push( @ranks, \%tmp );
    }
    return @ranks;
}

=head2 $pro->validate(%ph)

validate the following:
1. validate if P22(pub.uniquename) exists in the Database.
2. validate whether P21 and P2(journal) match in the database
3. validate field P30 and P31 whether includes valid pub
uniquename(FBrf....)
4. if P22 not exists, P1 and P10 have to both exist.
5. validate P1(pub type) cvterm existance.
6. check for curator's name

=cut

sub validate {
    my $self   = shift;
    my $tihash = {@_};
    my %tival  = %$tihash;

    print STDERR "Validating Pub ", $tival{pub}, " ....\n";
    
    validate_pub('P22',$tival{pub});
    
    
    if ( !exists( $tival{P22} ) || $tival{P22} eq 'new') {
        if ( !exists( $tival{P1} ) || !exists( $tival{P10} ) ) {
            print STDERR
              "ERROR: please fill in both P1 and P10 fields for a new record\n";
        }
        if ( exists( $tival{P21} ) && exists( $tival{P2} ) ) {
              my $miniref=$tival{P21};
            if(exists($tival{P20})){
                $miniref.=' '.$tival{P20};
            }
            validate_P21_P2($miniref, $tival{P2} );
        }
    }
    if ( exists( $tival{P30} ) ) {
        my @items = split( /\n/, $tival{P30} );
        foreach my $item (@items) {
            validate_pub('P30', $item);
        }
    }
    if ( exists( $tival{P31} ) ) {
        my @items = split( /\n/, $tival{P31} );
        foreach my $item (@items) {
            validate_pub('P31', $item);
        }
    }
    if( exists($tival{P1})){
        validate_cvterm($db, $tival{P1}, 'pub type');
    }
    if(!defined($tival{cur}) || !defined($curator{ $tival{cur} })){
        print STDERR "ERROR: undefined curator\n"; 
    }
}

####sub function to validate the pub uniquename
sub validate_pub {
    my $field    = shift;
    my $name      = shift;
    my $statement = "select pub_id from pub where uniquename='$name' and is_obsolete='f'";
    my $pnmm      = $db->prepare($statement);
    $pnmm->execute;
    my $pub = $pnmm->fetchrow_array;

    if ( !defined($pub) ) {
        print STDERR "ERROR: Could not find $name in pub $field\n";
    }

}
####sub function to validate multipub and the abbreviation
sub validate_P21_P2 {
    my $p21 = shift;
    my $p2  = shift;

    $p21 = 'multipub_' . $p21;
    my $state = "select miniref from pub where uniquename='$p21'";
    my $p_nmm = $db->prepare($state);
    $p_nmm->execute;
    my $miniref = $p_nmm->fetchrow_array;

    if ( defined($miniref) && $miniref ne $p2 ) {

        print STDERR "ERROR: field P2 and P21 do not match\n";
    }

}
#####for a new publication, check to see if it matches a record in DB.
#####Since proforma will be parsed after bulk load of biblio data.
#####check type, journal, pages, first author, year, volumn
#####if only one found, return it, else return 0, will create a new ID.
sub get_pub_uniquename {
    my %tival     = @_;
    my $unique='';
    #print STDERR "in pub_uniquename\n";
    if (
        exists( $tival{P10} )
        && (   exists( $tival{P21} )
            || exists( $tival{P2} ) )
        && exists( $tival{P11a} )
      ){
    
    my $page = $tival{P11a};
    my $year = $tival{P10};
    if(exists($tival{P21})){
        my $n=$tival{P21};
        if(exists($fbids{$n.$year.$page})){
            my $tmp=$fbids{$n.$year.$page};
            print STDERR "Warning: Pub may be same as $tmp\n";
        }
    }
    elsif(exists($tival{P2})){
        my $n=$tival{P2};
        if(exists($fbids{$n.$year.$page})){
            my $tmp=$fbids{$n.$year.$page};
            print STDERR "Warning: Pub may be same as $tmp\n";
        }
    }
   
    my $statement = "select p1.uniquename from pub p1, pub p2,
pub_relationship pr, pubauthor pa, cvterm cvt where
p1.pyear='$year' and p1.pages='$page' ";

    if ( exists( $tival{P3} ) ) {
        my $volume = $tival{P3};
        $statement .= " and p1.volume='$volume'";
    }
    if ( exists( $tival{P1} ) ) {
        my $type = $tival{P1};
        $statement .= " and	cvt.cvterm_id=p1.type_id  and
cvt.name='$type'";
    }
    if ( exists( $tival{P12} ) ) {
        my @authors = split( /\n/, $tival{P12} );
        my $firstauthor = $authors[0];
        if ( $firstauthor =~ /.*\s(.*)/ ) {
            $firstauthor = $1;
           
        }
        $firstauthor=~s/\'/\\\'/g;
        $statement .= " and pa.surname='$firstauthor' and pa.rank=1 and
pa.pub_id=p1.pub_id";
    }
    if ( exists( $tival{P21} ) ) {
        my $journal = 'multipub_' . $tival{P21};
        $statement .= " and p2.uniquename='$journal' and
pr.object_id=p2.pub_id and pr.subject_id=p1.pub_id ";
    }
    elsif ( exists( $tival{P2} ) ) {
        my $miniref = $db->quote($tival{P2});
        $statement .= " and p2.miniref=$miniref and
pr.object_id=p2.pub_id and pr.subject_id=p1.pub_id";
    }

    print STDERR $statement, "\n";
    my $ss = $db->prepare($statement);
    $ss->execute;
    my $num = $ss->rows;
    if ( $num == 1 ) {
        my $u = $ss->fetchrow_array;
        print STDERR "STATE: new pub record match $u\n";
        return 0;
    }
    else {
        while ( my $u = $ss->fetchrow_array ) {
            print STDERR "Warning:pub match $u\n";
        }
    }
    $unique = get_tempid('rf');
    if(exists($tival{P21})){
        my $n=$tival{P21};    
       $fbids{$n.$year.$page}=$unique; 
          print STDERR "STATE: assign $n $year $page new pub  $unique\n";       
    }
    elsif(exists($tival{P2})){
        my $n=$tival{P2};
       $fbids{$n.$year.$page}=$unique;
         print STDERR "STATE: assign $n $year $page new pub  $unique\n";    
    }
   return $unique;
}
elsif($tival{P1} eq 'personal communication to FlyBase' 
      && exists($tival{P10})
      && exists($tival{P12})
      && exists($tival{P16})) {
     
      my $year=$tival{P10};
      my $title=$tival{P16};
       my @authors = split( /\n/, $tival{P12} );
      my $firstauthor = $authors[0];
      if ( $firstauthor =~ /.*\s(.*)/ ) {
            $firstauthor = $1;
      }
      if(exists($fbids{$title.$year.$firstauthor})){
        my $tempid=$fbids{$title.$year.$firstauthor};
        print STDERR "Warning: $tival{file} pub same as $tempid\n";
      }
      else{
      $title=~ s/([\'\\\/\(\)])/\\$1/g;
       my $statement = "select p1.uniquename from pub p1,
        pubauthor pa, cvterm cvt where p1.type_id=cvt.cvterm_id and
        p1.pyear='$year' and p1.title='$title' 
        and cvt.name='personal communication to FlyBase' ";
     
      $statement .= " and pa.surname='$firstauthor' and pa.rank=1 and
pa.pub_id=p1.pub_id";
        my $ss = $db->prepare($statement);
    $ss->execute;
    my $num = $ss->rows;
    if ( $num == 1 ) {
        my $u = $ss->fetchrow_array;
        print STDERR "Warning: new pub record match $u\n";
        return $u;
    }
    else {
        while ( my $u = $ss->fetchrow_array ) {
            print STDERR "Warning:possible duplicates. pub match $u\n";
            return $u;
        }
    }
}
    $unique=get_tempid('rf');
    $fbids{$title.$year.$firstauthor}=$unique;
    print STDERR "STATE: assigning $title,$year, $firstauthor pub to  $unique\n";
    return $unique;
}
 
    return 0;
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
FlyBase::Proforma::MultiPub
XML::Xort

=head1 Proforma

! PUBLICATION PROFORMA                   Version 42:  01 Nov 2010
!
! P22.  FlyBase reference ID (FBrf) or "new"  *U :
! P32.  Action - make this/these FBrf(s) secondary IDs of P22 *N :
! P39.  Action - obsolete P22 in FlyBase               TAKE CARE :
! P1.   Type of publication [CV]  *T :
! P2.   Parent multipub (abbreviation)      *w :
! P12.  Author(s)                   *a-*b :
! P10.  Year or date (YYYY.M.D) if PC  *t :
! P16.  Title                          *u :
! P3.   Volume number                  *y :
! P4.   Issue number                   *Y :
! P11a. Page range or article number        *z :
! P11d. DOI                                    :
! P11b. URL                                 *R :
! P11c. Sequence accession number              :
! P13.  Language of publication [CV]                          *L :English
! P14.  Additional language(s) of abstract [CV]               *A :
! P26.  PubMed ID                *M :
! P29.  ISBN, if P1 = book       *I :
! P23.  Text of personal communication *F :
! P18.  Miscellaneous comments                                  *G :
! P38.  Associated file, archived at ftp site [SoftCV]       *K :
! P30.  Also published as (FBrf)            *C :
! P31.  Related publication (FBrf)          *E :
! P40.  Flag Cambridge for curation           CAMCUR :
! P41.  Flag Harvard for curation            HARVCUR :
! P42.  Flag Ontologists for curation           ONTO :
! P19.  Internal notes                   *H :

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

=head1 AUTHOR

Haiyan Zhang, E<lt>haiyan@morgan.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
