package FlyBase::Proforma::Feature;

use 5.008004;
use strict;
use warnings;
use XML::DOM;
use FlyBase::WriteChado;
require Exporter;
use FlyBase::Proforma::Util;
use FlyBase::Proforma::Assays;
use FlyBase::Proforma::ExpressionParser;

use Carp qw(croak);
our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use FlyBase::Proforma::TI ':all';
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

FlyBase::Proforma::Feature - Perl module for parsing the FlyBase
Feature  proforma version 3, May 3, 2007.

See the bottom for the proforma
                         
=head1 SYNOPSIS

  use FlyBase::Proforma::Feature;
  use DBI;
  
  my $mdbh=DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";
  my %ph=(F1a=>'mir-1', F4=>'mir-1',....);
  ###!c field implemented as '$fieldname.upd=>'c'' eg. 'AB5a.upd'=>'c'
   
  #params db is manditory, debug and validate is optional
  my $pro=FlyBase::proforma::Feature->new(db=>$mdbh);
  $pro->validate(%ph);
  my $chadoxml = $pro->process(%ph);
  
  # or

  my $pro=FlyBase::Proforma::Feature->new(db=>$mdbh,debug=>1,validate=>1);
  my $chadoxml_string=$pro->process(%ph);

=head1 DESCRIPTION

FlyBase::Proforma::Feature is a perl module for parsing FlyBase
Feature proforma and write the result as chadoxml. it is required
to connected to a chado database for validating and processing.
The module also requires FlyBase::Proforma::Writechado and
FlyBase::Proforma::Util. The results can be loaded into a chado
database by XML::Xort.

=head2 EXPORT

  process
  validate

=cut

our %ti_fpr_type = (
    'F1a',  'symbol',
    'F1f',  'uniquename',
    'F1b', 'symbol', #rename
    'F1c', 'merge',
    'F1d', 'delete',
    'F1e', 'dissociate',
    'F3',  'type_id',
    'F4',  'symbol',
    'F2', 'SO',
    'F5',  'molecular_size',
    'F9',  'feature_expression',
    'F15',  'bodypart_expression_text',
#    'F10',  'bodypart_expression_marker', 
    'F10', 'bodypart_expression_marker', #feature_cvterm feature_cvtermprop DC603
    'F11', 'attributed_as_expression_of',
    'F12', 'reported_antibod_gen',
    'F11a',  'is_subset_expression', 
    'F11b',  'is_relative_wildtype',
    'F16a',   'nucleotide_probe',
    'F13',   'comment',
    'F14',   'internalnotes',
    'F16b','nucleotide_probe',
    'F16c','nucleotide_probe',
    'F6', 'FlyExpress',
    'F17','associated_genotype',
    'F91',  'library_feature',  #library_feature
    'F91a', 'library_featureprop',  #library_featureprop
    );

my %f91a_type = ('experimental_result', 1, 'member_of_reagent_collection',1);

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
	if there is a Aberration Proforma under which the Genotype Variant
	Proforma hangs, make feature_relationship variant_of object_id FBab

=cut

#if AB5a is new symbol, will create feature_synonym,
#feature_relationship with tp...
#
sub process {
    my $self    = shift;
    my $tihash  = {@_};
    my %ph      = %$tihash;
    my $unique  = '';
    my $flag    = 0;
    my $feature = '';
    my $genus;
    my $species;
    my $type;
    my $out = '';

   print STDERR "process Feature proforma $ph{F1a} ...\n";
   if ( exists( $self->{debug} ) && $self->{debug} == 1 ) {
        foreach my $key ( keys %ph ) {
            print STDERR "$key, $ph{$key}\n";
        }
    }

    if ( exists( $self->{validate} ) && $self->{validate} == 1 ) {
        $self->validate_ti($tihash);
    }
     if(exists($fbids{$ph{F1a}})){
        $unique=$fbids{$ph{F1a}};
    }
    else{
        return $out;
        #($out,$unique)=$self->write_feature($self, $tihash);
    }
    # PROCESS: DISSOCIATE FROM PUB START
    if(!exists($ph{F1e})){
     print STDERR "Action Items: gene $unique == $ph{F1a} with pub $ph{pub}\n"; 
    my $f_p = create_ch_feature_pub(
        doc        => $doc,
        feature_id => $unique,
        pub_id     => $ph{pub}
    );
    $out .= dom_toString($f_p);
    $f_p->dispose();
    } 
    else{
            print STDERR "Action Items: feature $unique ==  $ph{F1a} dissociate with pub $ph{pub}\n";
            $out .= dissociate_with_pub( $self->{db}, $unique, $ph{pub} );
 #           return ($out, $unique);
	    return $out;
    }    # PROCESS: DISSOCIATE FROM PUB END

    print STDERR "Action Items: feature $unique == $ph{F1a} with pub $ph{pub}\n"; 
    ##Process other field in Trangenic Insertion proforma
    foreach my $f ( keys %ph ) {
        #print $f, "\n";
        # PROCESS: RENAME START
         if ( $f eq 'F1b' ) {
            $out .=
              update_feature_synonym( $self->{db}, $doc, $unique, $ph{$f},
                $ti_fpr_type{$f} );    
        }    # PROCESS: RENAME END
#        elsif ( $f eq 'F1e' ) {
#            print STDERR "Action Items: feature $unique ==  $ph{F1e} dissociate with pub $ph{pub}\n";
#            $out .= dissociate_with_pub( $self->{db}, $unique, $ph{pub} );
#        }

        # PROCESS: MERGE START
        elsif ( $f eq 'F1c' ) {
	  my $tmp=$ph{$f};
	  $tmp=~s/\n/ /g;
	  if($ph{F1f} eq 'new'){
                print STDERR "Action Items: merge Gene Product $tmp\n";
            }
            else{
                print STDERR "Action Items: merge Gene Product $tmp to $ph{F1f} == $ph{F1a} \n";
            }    
            $out .=
              merge_records( $self->{db}, $unique, $ph{$f}, $ph{F1a}, $ph{pub});
              $fbids{$unique}=$ph{F1a};
	
#         $out.=write_feature_synonyms($doc,$unique,$ph{F1a},'a','unattributed',$ti_fpr_type{F1a});
        }   # PROCESS: MERGE END
        elsif ( $f eq 'F4') {
                if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
                   print STDERR "Action Items: !c log,$unique $f  $ph{pub}\n";
                     $out .=
                      delete_feature_synonym( $self->{db}, $doc, $unique, $ph{pub} , $ti_fpr_type{$f});
            
                }
                if(defined($ph{$f}) && $ph{$f} ne ''){
                    my @items = split( /\n/, $ph{$f} );
                    foreach my $item (@items) {
                        $item =~ s/^\s+//;
                        $item =~ s/\s+$//;
                        my $t = $f;
                     
                if ( $item ne 'unnamed' && $item ne '' ) {
                    if (  $item eq $ph{F1a} ) {
                        $t = 'a';
                    }
                    else{
                        $t='b';
                    }
                    $out .=
                      write_feature_synonyms( $doc, $unique, $item, $t,
                        $ph{pub}, $ti_fpr_type{$f} );
                }
            }
        }
        }
        elsif($f eq 'F11c'){
        print STDERR "Warning: multiple field F11c\n";
            my    $object  = 'subject_id';
            my    $subject = 'object_id';
            my @array = @{ $ph{F11c} };
            foreach my $ref (@array) {
                my %tt=%$ref;
                if(exists($tt{'F11.upd'}) and $tt{'F11.upd'} eq 'c'){
                    print STDERR "Action Items: !c log,$unique $f  $ph{pub}\n";
                    $out=parse_bandc_feature_relationship($self->{db}, $doc, $subject,$object, $unique, $ti_fpr_type{F11}, $ph{pub});
                }
                if($tt{F11} ne ''){
                       my @items = split( /\n/, $tt{F11} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    my ($fr,$f_p) = write_feature_relationship( $self->{db}, $doc, $subject,
                        $object, $unique, $item, $ti_fpr_type{F11}, $ph{pub} );
                    if(exists($tt{F11a}) && $tt{F11a} eq 'y'){
                     my $fr_prop=create_ch_frprop(doc=>$doc, value=>$tt{F11a}, type=>$ti_fpr_type{F11a});
                     my $fr_prop_pub=create_ch_frprop_pub(doc=>$doc, pub_id=>$ph{pub});
                     $fr_prop->appendChild($fr_prop_pub);
                     $fr->appendChild($fr_prop);    
                     }
                       if(exists($tt{F11b}) && $tt{F11b} eq 'y'){
                     my $fr_prop=create_ch_frprop(doc=>$doc, value=>$tt{F11b}, type=>$ti_fpr_type{F11b});
                     my $fr_prop_pub=create_ch_frprop_pub(doc=>$doc, pub_id=>$ph{pub});
                     $fr_prop->appendChild($fr_prop_pub);
                     $fr->appendChild($fr_prop);    
                     }
                     $out.=dom_toString($fr);
                     $out.=$f_p;
                    
                }  
                }
            }
        }
        elsif ( $f eq 'F11' ) {         
            my    $object  = 'object_id';
            my    $subject = 'subject_id';
            
            if ( exists( $ph{"$f.upd"} ) and $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$unique $f  $ph{pub}\n";
                my @results =
                  get_unique_key_for_fr( $self->{db}, $subject, $object,
                    $unique, $ti_fpr_type{$f}, $ph{pub} );
                foreach my $ta (@results) {
                    my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );
                    if ( $num == 1 || (defined($frnum{$unique}{$ta->{name}}) && $num-$frnum{$unique}{$ta->{name}}==1) ) {
                        $out .=
                          delete_feature_relationship( $self->{db}, $doc, $ta,
                            $subject, $object, $unique, $ti_fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_feature_relationship_pub( $self->{db}, $doc,
                            $ta, $subject, $object, $unique, $ti_fpr_type{$f},
                            $ph{pub} );
                    }
                    else {
                        print STDERR "ERROR:something Wrong, please validate first\n";
                    }
                }
            }
            if ( $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    my ($fr,$f_p) = write_feature_relationship( $self->{db}, $doc, $subject,
                        $object, $unique, $item, $ti_fpr_type{$f}, $ph{pub} );
                    if(exists($ph{F11a}) && $ph{F11a} eq 'y'){
                     my $fr_prop=create_ch_frprop(doc=>$doc, value=>$ph{F11a}, type=>$ti_fpr_type{F11a});
                     my $fr_prop_pub=create_ch_frprop_pub(doc=>$doc, pub_id=>$ph{pub});
                     $fr_prop->appendChild($fr_prop_pub);
                     $fr->appendChild($fr_prop);    
                    } 
                    if(exists($ph{F11b}) && $ph{F11b} eq 'y'){
                     my $fr_prop=create_ch_frprop(doc=>$doc, value=>$ph{F11b}, type=>$ti_fpr_type{F11b});
                     my $fr_prop_pub=create_ch_frprop_pub(doc=>$doc, pub_id=>$ph{pub});
                     $fr_prop->appendChild($fr_prop_pub);
                     $fr->appendChild($fr_prop);    
                    }
                    $out.=dom_toString($fr);
                    $out.=$f_p;
                }
            }
        }
        elsif($f eq 'F6'){
               
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{F1a} $f  $ph{pub}\n";
                my @result =get_dbxref_by_feature_db( $self->{db}, $unique,
                    $ti_fpr_type{$f} );
                foreach my $item (@result) {
                
                    my $feat_dbxref = create_ch_feature_dbxref(
                        doc        => $doc,
                        feature_id => $unique,
                        dbxref_id  => create_ch_dbxref(
                            doc  => $doc,
                            db   => $ti_fpr_type{$f},
                            accession => $item
                        )
                        
                    );
                    $feat_dbxref->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($feat_dbxref);
                    $feat_dbxref->dispose();
                }
            }
             
             if (defined($ph{$f})&& $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;   
                     my $dbxref = create_ch_feature_dbxref(
                        doc        => $doc,
                        feature_id => $unique,
                        dbxref_id  => create_ch_dbxref(
                            doc       => $doc,
                            accession => $item,
                            db        => $ti_fpr_type{$f},
                            no_lookup =>1
                        ),
                        is_current => 't'
                    );

                    $out .= dom_toString($dbxref);
                 
                }
            }
        }
        elsif($f eq 'F16'){
           my @array = @{ $ph{F16} };
            foreach my $ref (@array) {
                my %tt=%$ref;
                    if ( exists( $tt{"F16a.upd"} ) && $tt{"F16a.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$unique $f  $ph{pub}\n";
                my @results =
                  get_unique_key_for_featureprop( $self->{db}, $unique,
                    $ti_fpr_type{F16a}, $ph{pub} );
                foreach my $t (@results) {
                    my $num = get_fprop_pub_nums( $self->{db}, $t->{fp_id} );
                    if ( $num == 1 ) {
                        $out .=
                          delete_featureprop( $doc, $t->{rank}, $unique,
                            $ti_fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_featureprop_pub( $doc, $t->{rank}, $unique,
                            $ti_fpr_type{F16a}, $ph{pub} );
                    }
                    else {
                        print STDERR "ERROR: something Wrong, please validate first\n";
                    }
                }
            }
               if ( $tt{F16a} ne '' ) { 
              
                    if(exists($ph{F16b}) ){
                    $tt{F16a}.=';'.$ph{F16b};            
                        }
                    else{$tt{F16a}.=';';}
                    if(exists($tt{F16c})){
                        $tt{F16a}.=';'.$ph{F16c};
                    }
                    else {$tt{F16a}.=';';}
                } 
             $out .=
                      write_featureprop( $self->{db}, $doc, $unique, $tt{F16a},
                        $ti_fpr_type{$f}, $ph{pub} );
            }
        }
        elsif( $f eq 'F17'){
			  # print STDERR "ERROR: $f field not implemented yet\n";
            my $object  = 'object_id';
            my $subject = 'subject_id';
        
            if ( exists( $ph{"$f.upd"} ) and $ph{"$f.upd"} eq 'c' ) {
                  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
               
                my @results =
                  get_unique_key_for_fr( $self->{db}, $object, $subject,
                    $unique, $ti_fpr_type{$f}, $ph{pub});
                    foreach my $ta (@results) {
                         print STDERR " f_id  ", $ta->{feature_id}," ", $ta->{name}, "\n";
                        my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );
                        if ( $num == 1 || (defined($frnum{$unique}{$ta->{name}}) && $num-$frnum{$unique}{$ta->{name}}==1)) {
                      
                            $out .=
                              delete_feature_relationship( $self->{db}, $doc,
                                $ta, $object, $subject, $unique,
                                $ti_fpr_type{$f}  );
                        }
                        elsif ( $num > 1 ) {
                            $out .=
                              delete_feature_relationship_pub( $self->{db},
                                $doc, $ta, $object, $subject, $unique,
                                $ti_fpr_type{$f}, $ph{pub});
                        }
                        else {
                            print STDERR"ERROR: $f something Wrong, please validate first\n";
                        }
                    }
            }
            if ( defined($ph{$f}) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
		  $item=trim($item);
		  if($item ne ""){
                    my ($fr,$f_p) = write_feature_relationship(
                        $self->{db},       $doc,
                        $object,           $subject,
                        $unique,           $item,
                        $ti_fpr_type{$f},  $ph{pub},
                    );
                    $out .= dom_toString($fr);
                    $fr->dispose();
                    $out.=$f_p;
		  }
                }
            }
        }
         elsif ( $f eq 'F2') {
          
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
              print STDERR "Action Items: !c log,$ph{F1a} $f  $ph{pub}\n";
                my @results = get_cvterm_for_feature_cvterm(
                    $self->{db}, $unique, $ti_fpr_type{$f},
                    $ph{pub}
                );
                foreach my $item (@results) {
                    my $feat_cvterm = create_ch_feature_cvterm(
                        doc        => $doc,
                        feature_id => $unique,
                        cvterm_id  => create_ch_cvterm(
                            doc  => $doc,
                            cv   => $ti_fpr_type{$f},
                            name => $item
                        ),
                        pub => $ph{pub}
                    );
                    $feat_cvterm->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($feat_cvterm);
                    $feat_cvterm->dispose();
                }
            }
            if (defined($ph{$f}) &&  $ph{$f} ne '' ) {
            
                my @items = split( /\n/, $ph{$f} );
                
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    if ( $item =~ /(.*?)\s+.*/ ) {
                        $item = $1;
                    }
                    my $cv = validate_cvterm( $self->{db},$item,$ti_fpr_type{$f});
		    if ($cv == 1){
			my $f_cvterm = create_ch_feature_cvterm(
			    doc        => $doc,
			    feature_id => $unique,
			    cvterm_id  => create_ch_cvterm(
				doc  => $doc,
				cv   => $ti_fpr_type{$f},
				name => $item
			    ),
			    pub_id => $ph{pub}
			    );

			$out .= dom_toString($f_cvterm);
			$f_cvterm->dispose();
		    }
		    else{
			print STDERR "ERROR: $item not a valid cvterm for $f $ti_fpr_type{$f}\n";
		    }
		}
            }

        }

         elsif ( $f eq 'F10') {
          
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{F1a} $f  $ph{pub}\n";
	            my @cvs = ("cellular component", "FlyBase anatomy CV");
                my @results;
                my @cvlist;
	            foreach my $cv (@cvs){
                    my @res = get_cvterm_for_feature_cvterm_withprop(
                        $self->{db}, $unique,$cv,$ph{pub},$ti_fpr_type{$f});
                    foreach my $item (@res) {
                        push(@results, $item);
                        push(@cvlist, $cv);
                    }
                }
		        if(@results==0){
		            print STDERR "ERROR: not previous record found for $ph{F1a} $f \n";
		        }
		        else{
		                foreach my $item (@results) {
                            my $cv = pop(@cvlist);
 			                my $feat_cvterm = create_ch_feature_cvterm(
			                   doc        => $doc,
			                   feature_id => $unique,
			                   cvterm_id  => create_ch_cvterm(
				               doc  => $doc,
				               cv   => $cv,
				               name => $item
			                   ),
			                   pub => $ph{pub}
			                );
			                $feat_cvterm->setAttribute( 'op', 'delete' );
			                $out .= dom_toString($feat_cvterm);
			                $feat_cvterm->dispose();
		                }
 		            }
       }
            if (defined($ph{$f}) &&  $ph{$f} ne '' ) {
		my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
		    print STDERR "DEBUG: new F10 $ph{F1a} $item $ph{pub}\n";
		    my $go = "";
		    my $go_id = "";
 		    my $db = "";
		    my $acc = "";
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
		    ($db,$acc) = split ':', $go_id;
		    if($go eq "" || $go_id eq "" || $db eq "" || $acc eq ""){
			print STDERR "ERROR: can't parse value for $f $item $ph{F1a}\n";
		    }
		    my ($cv,$cvterm) = get_cv_cvterm_by_dbxref($self->{db},$db,$acc);
		    if (($cv ne '0') && ($cvterm eq $go)){
			print STDERR "DEBUG: $f $ph{F1a} cv $cv, term $cvterm ; db:accession $db:$acc\n";

			my $f_cvterm = create_ch_feature_cvterm(
			    doc        => $doc,
			    feature_id => $unique,
			    cvterm_id  => create_ch_cvterm(
				doc  => $doc,
				cv   => $cv,
				name => $cvterm
			    ),
			    pub_id => $ph{pub}
			    );
			my $fcvprop = create_ch_feature_cvtermprop(
			    doc  => $doc,
			    type_id => create_ch_cvterm(doc=>$doc,
							name=>$ti_fpr_type{$f},
							cv=>'property type'),
			    rank => '0'
			    );
			$f_cvterm->appendChild($fcvprop);
   			$out .= dom_toString($f_cvterm);
			$f_cvterm->dispose();
		    }
		    else{
			print STDERR "ERROR: $go $go_id not a valid cvterm for $f\n";
		    }
		}
            }
	 }

        elsif($f eq 'F9'){
	  if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
	    print STDERR "Action Items: !c log,$unique $f  $ph{pub}\n";	
	    #get feature_expression
	    my @result =get_expression_for_feature_expression( $self->{db}, $unique, $ph{pub});
                foreach my $item (@result) {
                    my $feat_exp = create_ch_feature_expression(
                        doc        => $doc,
                        feature_id => $unique,
                        expression_id  => create_ch_expression(
                            doc  => $doc,
                            uniquename => $item,
                        ),
                        pub => $ph{pub}
                    );
                    $feat_exp->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($feat_exp);
                    $feat_exp->dispose();
                }
	  }
	  if ( $ph{$f} ne '' ) { 	   
	    my @items=split("\n", $ph{$f});
	    foreach my $item(@items){
	      $item=trim($item);
	      if($item ne ""){
		my $fe = parse_tap(doc=>$doc, db=>$self->{db}, feature_id=>$unique, pub_id=>$ph{pub}, tap=>$item, check_cvterms=>1 );
		if(defined($fe)){
		  $out.=dom_toString($fe);
		}
		else{
		  print STDERR "ERROR, could not parse expression $unique, $item, $ph{pub}	\n";
		}
	      }
	    }
	  }
	} 
        elsif ( $f eq 'F5'|| $f eq 'F15' || $f eq 'F12' || $f eq 'F16a' || $f eq 'F13' || $f eq 'F14' ) {  
			  my $oldunique=$unique;
          if($f eq 'F12'){ 
            my ($gene, $gg,$gs,$gt)=get_gene_ukeys_by_transcriptname($self->{db},$ph{F1a});
                my $gene_pro=create_ch_feature(doc=>$doc, uniquename=>$gene,
                                             genus=>$gg, species=>$gs, type=>$gt,
                                             macro_id=>$gene);  
                $out.=dom_toString($gene_pro);
               $unique=$gene; 
             }  
              if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$unique $f  $ph{pub}\n";
                my @results =
                  get_unique_key_for_featureprop( $self->{db}, $unique,
                    $ti_fpr_type{$f}, $ph{pub} );
                foreach my $t (@results) {
                    my $num = get_fprop_pub_nums( $self->{db}, $t->{fp_id} );
                    if ( $num == 1 || (defined($frnum{$unique}{$ti_fpr_type{$f}}{$t->{rank}}) && $num-$frnum{$unique}{$ti_fpr_type{$f}}{$t->{rank}}==1)) {
                        $out .=
                          delete_featureprop( $doc, $t->{rank}, $unique,
                            $ti_fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_featureprop_pub( $doc, $t->{rank}, $unique,
                            $ti_fpr_type{$f}, $ph{pub} );
                    }
                    else {
                        print STDERR "ERROR: something Wrong, please validate first\n";
                    }
                }
            }
            if ( $ph{$f} ne '' ) { 
                if($f eq 'F16a'){
                    if(exists($ph{F16b}) ){
                    $ph{$f}.='::'.$ph{F16b};            
                        }
                    else{$ph{$f}.='::';}
                    if(exists($ph{F16c})){
                        $ph{$f}.='::'.$ph{F16c};
                    }
                    else {$ph{$f}.='::';}
                }
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                   
                    if($item ne ''){
			if($f eq 'F12' && exists($ph{F12b})){
			    $item.=' ('.$ph{F12b}.')';
			}
                    $out .=
                      write_featureprop( $self->{db}, $doc, $unique, $item,
                        $ti_fpr_type{$f}, $ph{pub} );
                        }
                }
				 } 
				$unique=$oldunique;
        }
        elsif ( $f eq 'F91' ){               
	  print STDERR "CHECK: new implemented $f  $ph{F1a} \n";

            if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
                print STDERR "CHECK: new implemented !c $ph{F1a} $f \n";
	    #get library_feature
	    my @result =get_library_for_library_feature( $self->{db}, $unique);
                foreach my $item (@result) {	      
		    (my $libu, my $libg, my $libs, my $libt)=get_lib_ukeys_by_name($self->{db},$item);
		    my $lib_feat = create_ch_library_feature(
							     doc=> $doc,
							     library_id=> create_ch_library(doc => $doc, uniquename => $libu, genus => $libg, species=>$libs, type=>$libt,),
							     feature_id=> $unique,
							   );
                    $lib_feat->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($lib_feat);
                    $lib_feat->dispose();
                }
	      }
	  if (defined ($ph{$f}) && $ph{$f} ne ""){		
	    (my $libu, my $libg, my $libs, my $libt)=get_lib_ukeys_by_name($self->{db},$ph{$f});
	    if ( $libu eq '0' ) {
	      print STDERR "ERROR: could not find record for $ph{F91}\n";
	      #		  exit(0);
	    }
	    else{
	      print STDERR "DEBUG: F91 $ph{$f} uniquename $libu\n";		  
	      if(defined ($ph{F91a}) && $ph{F91a} ne ""){
		if (exists ($f91a_type{$ph{F91a}} ))  {
		  my $item = $ph{F91a};
		  print STDERR "DEBUG: F91a $ph{F91a} found\n";
		  my $library=create_ch_library(
                                doc=>$doc,
                                uniquename=>$libu,
                                genus=>$libg,
                                species=>$libs,
                                type=>$libt,
                                macro_id=>$libu
                            );
		  $out.=dom_toString($library);  
		  my $f_l=create_ch_library_feature(doc=>$doc,
                                          library_id=>$libu,
                                          feature_id=>$unique);

		  my $lfp = create_ch_library_featureprop(doc=>$doc,type=>$item);
		  $f_l->appendChild($lfp);
		  $out.=dom_toString($f_l); 
		}
		else{
		  print STDERR "ERROR: wrong term for F91a $ph{F91a}\n";
		}
	      }
	      else{
		print STDERR "ERROR: F91 has a library no term for F91a\n";
	      }
		
	    }
	  }
	}
	 elsif( ($f eq 'F91a' && $ph{F91a} ne "") && ! defined ($ph{F91})){
	   print STDERR "ERROR: F91a has a term for F91a but no library\n";
	 }	    

   }
  $doc->dispose();
    return $out;
}
=head2 $pro->write_feature(%ph)
  separate the id generation and lookup from the other curation field to make two-stage parsing possible
=cut
sub write_feature{
    my $self    = shift;
    my $tihash  = {@_};
    my %ph      = %$tihash;
    my $unique  = '';
    my $flag    = 0;
    my $feature = '';
    my $genus='Drosophila';
    my $species='melanogaster';
    my $type;
    my $out = '';
    
    if(!($ph{F1a} =~/[\-XP|\-XR]$/) && !($ph{F1a} =~/[\]P[A-Z]|\]R[A-Z]]$/)){
        print STDERR "ERROR: F1a $ph{F1a} must end with -XR or -XP or ]PA or ]RA\n";
		  #return $out;
    }

   if( exists( $ph{F1f} ) && $ph{F1f} eq 'new' ){
       if(exists($ph{F2}) && ($ph{F1a} =~/[\-XP|\-XR]$/)){
	   print STDERR "ERROR: F1a $ph{F1a} cannot end in -XR or -XP if F2 \n";
       }
       if(exists($ph{F3})){
	   my ($t,$SO)=split(/\s+/,$ph{F3});
	   $type=$t;
	   if($type eq 'protein'){
	       print STDERR "ERROR: Type can not be 'protein', should be 'polypeptide'\n";
	   }
       }
       else{
	   print STDERR "ERROR: please specify the feature type for the new feature\n";
       }
        if(!exists($ph{F1c})){
	    $flag=0;
	    my $va=validate_new_name($db,  $ph{F1a});
	    if($va ==1){
	       $flag = 0;
	       ($unique,$genus,$species,$type)=get_feat_ukeys_by_name($db,$ph{F1a});
	       $fbids{convers($ph{F1a})}=$unique;
	       $fbids{$ph{F1a}}=$unique;
	    }	      
        }
        if ( $type eq 'split system combination' ) {
          if( ! $ph{F1a} =~ /&cap\;/ ) {
            print STDERR "ERROR: split system combination $ph{F1a} should have '&cap;' "
          }
          ( $unique, $flag ) = get_tempid( 'co', $ph{F1a} );

        } 
        elsif ( $type eq 'polypeptide' ) {
          if(!($ph{F1a}=~/-XP$/) && !($ph{F1a}=~/]P[A-Z]$/)){
            print STDERR "ERROR: polypeptide $ph{F1a} should be ended with -XP or PA\n";
          }
          ( $unique, $flag ) = get_tempid( 'pp', $ph{F1a} );
        }
        else {
          if(!($ph{F1a}=~/-XR$/) && !($ph{F1a}=~/]R[A-Z]$/)){
            print STDERR "ERROR: transcript $ph{F1a} should be ended with -XR or RA\n";
          }
          ( $unique, $flag ) = get_tempid( 'tr', $ph{F1a} );
        }
        if(exists($ph{F1c}) && $ph{F1f} eq 'new' && $unique !~/temp/){
	print STDERR "ERROR: merge feature should have a FB..:temp id not $unique\n";
      }

#      $fbids{convers($ph{F1a})}=$unique;
#      $fbids{$ph{F1a}}=$unique;
      #print STDERR "get temp id for $ph{F1a} $unique\n";
      if ( $ph{F1a} =~ /^(.{2,14}?)\\(.*)/ ) {
           my $org=$1;
            ( $genus, $species ) = get_organism_by_abbrev( $self->{db}, $org);
      }
      if ( $ph{F1a} =~ /^T:(.{2,14}?)\\(.*)/ ) {
           my $org=$1;
            ( $genus, $species ) = get_organism_by_abbrev( $self->{db}, $org);
      }
      if($genus eq '0'){
            $genus='Drosophila';
            $species='melanogaster';
     
      }
      if($flag ==1){
            print STDERR "ERROR: could not assign temp id for $ph{F1a}\n";
            exit(0);
      }
      else {
        if ( $type eq 'split system combination' ) {
          $feature = create_ch_feature(
            uniquename => $unique,
            name       => decon( convers( $ph{F1a} ) ),
            genus      => $genus,
            species    => $species,
            type       => $type,
            cvname     => 'FlyBase miscellaneous CV',
            doc        => $doc,
            macro_id   => $unique,
            no_lookup  => '1'
          );
          $out.=dom_toString($feature);
          $out .= write_feature_synonyms( $doc, $unique, $ph{F1a}, 'a', 'unattributed', 'symbol' );
        }
        else {
          $feature = create_ch_feature(
            uniquename => $unique,
            name       => decon( convers( $ph{F1a} ) ),
            genus      => $genus,
            species    => $species,
            type       => $type,
            doc        => $doc,
            macro_id   => $unique,
            no_lookup  => '1'
          );
          $out.=dom_toString($feature);
          $out .= write_feature_synonyms( $doc, $unique, $ph{F1a}, 'a', 'unattributed', 'symbol' );
        }
      }
      my $gn=$ph{F1a};
      my @gn_list;
      if($gn=~/[\-XR|\-XP]$/){
      $gn=~s/-XR$//;
      $gn=~s/-XP$//;
#      $gn=~s/XP$//;
#      $gn=~s/XR$//;
      }
      elsif ($gn=~/[\][P[A-Z|\]R[A-Z]$/){
#      $gn=~s/-R[A-Z]$//;
      $gn=~s/R[A-Z]$//;
      $gn=~s/P[A-Z]$//;
      }
      elsif ( $type eq 'split system combination' && ph{F1a} =~ /&cap\;/ ) {
        my @gn_list = split('&cap;', @gn_list);
      }
      else {
        print STDERR "ERROR: Can't parse gene for product $ph{F1a}\n";
      }
      my $gn_list_length = scalar @gn_list;
      if ( $gn_list_length > 1 ) {
        foreach my $split_component (@gn_list) {
          print STDERR "split system component $split_component is part of $ph{F1a}\n";
	      my ($fr,$f_p) = write_feature_relationship( $self->{db}, $doc, 'subject_id',
                          'object_id', $unique, $split_component, 'partially_produced_by', 'unattributed' );
	      $out.=dom_toString($fr);
        }
      }
      else {
        print STDERR "gene $gn product $ph{F1a}\n";
        ### Write feature_relationship with Gene as partof
        ### Going forward make fr 'associated_with' Aug-03-2011
  	    #$out.=remove_old_gene_link($self->{db},$unique,$gn);
	    my ($fr,$f_p) = write_feature_relationship( $self->{db}, $doc, 'subject_id',
                        'object_id', $unique, $gn, 'associated_with', 'unattributed' );
	    $out.=dom_toString($fr);
      }
    } # END new bob
    elsif( exists( $ph{F1f} ) && $ph{F1f} ne 'new' ){
       ( $genus, $species, $type ) =
              get_feat_ukeys_by_uname( $self->{db}, $ph{F1f} );
         if($genus eq '0' || $genus eq '2'){
	     print STDERR "ERROR: could not find $ph{F1f} for symbol $ph{F1a} in DB\n";
	 }
       if(!exists($ph{F1b})){
	   ($unique,$genus,$species,$type)=get_feat_ukeys_by_name($self->{db},$ph{F1a}) ;
	   if($unique ne $ph{F1f}){
	       print STDERR "ERROR: name and uniquename not match $ph{F1f}  $ph{F1a} \n";
	       exit(0);
	   }
       } 

       $unique = $ph{F1f};
       if(!exists($ph{F1a})){
	   print STDERR "ERROR: no F1a field\n";
       }
       if(exists($fbids{$unique})){
	   print STDERR "ERROR: $unique has been in previous proforma with an action item, separate loading\n";
	   return ($out,$unique);
       }
       if ( $type eq 'split system combination' ) {
       $feature = create_ch_feature(
	   doc        => $doc,
	   uniquename => $unique,
	   species    => $species,
	   genus      => $genus,
	   type       => $type,
	   cvname     => 'FlyBase miscellaneous CV',
	   macro_id   => $unique,
	   no_lookup  => '1'
       );
       }
       else {
       $feature = create_ch_feature(
	   doc        => $doc,
	   uniquename => $unique,
	   species    => $species,
	   genus      => $genus,
	   type       => $type,
	   macro_id   => $unique,
	   no_lookup  => '1'
	   );
       }
       if ( exists( $ph{F1d} ) && $ph{F1d} eq 'y' ) {
           print STDERR "Action Items: delete Feature $ph{F1f} == $ph{F1a}\n";
	   my $op = create_doc_element( $doc, 'is_obsolete', 't' );
	   $feature->appendChild($op);
       }
         if(exists($ph{F1b})){
	 if(exists($fbids{$ph{F1b}})){
	     print STDERR "ERROR: Rename F1b $ph{F1b} exists in a previous proforma\n";
	 }
	 if(exists($fbids{$ph{F1a}})){                                    
	     print STDERR "ERROR: Rename F1a $ph{F1a} exists in a previous proforma \n";
	 }  
	 print STDERR "Action Items: Rename $ph{F1b} to $ph{F1a}\n";
	 my $va=validate_new_name($db, $ph{F1a});
	 if ($va == 0){
	     my $n=create_doc_element($doc,'name',decon(convers($ph{F1a})));
	     $feature->appendChild($n);
	     $out.= dom_toString($feature);
	     $out .= write_feature_synonyms( $doc, $unique, $ph{F1a}, 'a', 'unattributed', 'symbol' );
	     $fbids{$ph{F1b}}=$unique;
	    }
        }
        else{

        $out.=dom_toString($feature);
       }
       $fbids{$ph{F1a}}=$unique;

    }

    $fbids{$ph{F1a}}=$unique;
    $doc->dispose();
    return ($out,$unique);
}
sub get_gene_ukeys_by_transcriptname{
    my $db=shift;
    my $name=shift;
    my $gname=$name;
    $gname=~s/\w{2}$//;
    $gname=~s/-$//;
    my ($gu,$gg,$gs,$gt)=get_feat_ukeys_by_name($db,$gname);
    if($gu eq '0' || $gu eq '2' || $gt ne 'gene'){
        print STDERR "ERROR, could not find gene for $name $gu $gt\n";
    }
       return ($gu,$gg,$gs,$gt);
}
sub remove_old_gene_link{
    my $db=shift;
    my $unique=shift;
    my $newgn=shift;
    my $out='';
    my ( $gn, $n, $r ) = get_relationship_gene( $db, $unique, 'partof' );
            #print STDERR "$gn, $ph{gene}\n";
            if ( $gn ne '0' && ($gn ne $newgn) ) {
                my ( $o_genus, $o_species, $o_type ) =
                  get_feat_ukeys_by_uname( $db, $gn );
                my $o_f = create_ch_feature(
                    doc        => $doc,
                    uniquename => $gn,
                    genus      => $o_genus,
                    species    => $o_species,
                    type       => $o_type,
                    macro_id   => $gn
                );
                my $o_fr = create_ch_fr(
                    doc      => $doc,
                    subject_id => $unique,
                    object_id  => $o_f,
                    rtype    => 'partof',
                    rank     => $r
                );
                $o_fr->setAttribute( 'op', 'delete' );
                $out= dom_toString($o_fr);
            }
   return $out;

}
=head2 $pro->validate(%ph)

   validate the following:
   1. If F3 is not polypeptide, F12 should not be filled.
   2. If !c exists, check whether this record already in the DB.
   3. the values following F11 have to be a valid symbol in the database.

=cut

sub validate {
    my $self   = shift;
    my $tihash = {@_};
    my %tival  = %$tihash;

    my $v_unique = '';

    print STDERR "Validating Feature ", $tival{F1a}, " ....\n";
  
    if(exists($fbids{$tival{F1a}})){
        $v_unique=$fbids{$tival{F1a}};
    }
    else{
        print STDERR "ERROR: did not have the first parse\n";
    }
    if(exists($tival{F12}) && !($v_unique =~/FBpp/)){
       print STDERR "ERROR:  $tival{F1a} only polypeptide record can fill F12\n";
    }
     foreach my $f ( keys %tival ) {
        if ( $f =~ /(.*)\.upd/ && !($v_unique =~/temp/)) {
                $f = $1;
                if ( $f eq 'F5' || $f eq 'F9' || $f eq 'F15'|| $f eq 'F16a' || $f eq 'F13' || $f eq 'F14' || $f eq 'F12' ) {
                    my $num =
                      get_unique_key_for_featureprop( $db, $v_unique,
                        $ti_fpr_type{$f}, $tival{pub} );
                    if ( $num == 0 ) {
                        print STDERR
                          "ERROR:  there is no previous record for $f field.\n";
                    }
                }
                elsif ( $f eq 'F11' ) {
                    my $num =
                      get_unique_key_for_fr( $db, 'subject_id','object_id', $v_unique, $ti_fpr_type{$f},
                        $tival{pub} );
                    if ( $num == 0 ) {
                        print STDERR
                          "ERROR:There is no previous record for $f field\n";
                    }
                }
                elsif($f eq 'F11a'){
                    if($tival{$f} ne 'y' && $tival{$f} ne 'n'){
                    print STDERR "ERROR: other value is not allowed in F11a except y/n\n";   
                    }
                }
            }
            elsif($f eq 'F11'){
                  my @items = split( /\n/, $tival{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    if(!exists($fbids{$item})){
                    my ( $uuu, $g, $s, $t ) =
                      get_feat_ukeys_by_name( $db, $item );
                    if ( $uuu eq '0' || $uuu eq '2') {
                        print STDERR
                          "ERROR: Could not find feature $item for field $f in the DB\n";
                       }
                    }
                }
            }
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

proforma mapping table can be found in ~haiyan/Documents/featuremapping.sxw 

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

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! FEATURE ATTRIBUTES/DESCRIPTIONS               Version 3: May 03 2007

! F1f. database id (default 'new')      :new
! F1a. feature symbol (text)            :
! F3. feature type (CV=SO)              :mRNA SO:0000234
! F2.  Sequence attribute [CV]	     :
!
! F1b. Action - rename this gene product (symbol)      :
! F1c. Action - merge these products(s) (symbols or FB#s) :
! F1d. Action - delete gene product record ("y"/blank) :
! F1e. Action - dissociate F1f from FBrf ("y"/blank)   :
!
! F4. names(s) used in paper            :
! F6. FlyExpress image number(s) (FBim)  :
!
! F5.  molecule size(s) (wb, nb, sa)    :

! F9. expression pattern                :
<e>  <t>  <a>  <s>  <c>  <note>
<e>  <t>  <a>  <s>  <c>  <note>

! F15. general expression comment       :

! F10. used as bodypart marker for (CV FBbt) :
! F11. expression pattern abscribed to (gene symbol) :
!     F11a. is subset of wild-type gene expression pattern (y/n) :n
!     F11b. Is pattern aberrant relative to wild-type (y/n):n
! F12. antibody reported (monoclonal, polyclonal) :
!     F12b. Description of F12 [free text]  :
! F16a. nucleotide probe (cDNA, cDNA fragment, genomic fragment, synthetic) :
        ! F16b. sequence coordinates for F16a :
        ! F16c. description of F16a (free text) :
! F17. Alleles or genotypes used :
! F13. comment (text)       :
! F14. internal note (text) :
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

=head1 AUTHOR

Haiyan Zhang, E<lt>haiyan@morgan.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
