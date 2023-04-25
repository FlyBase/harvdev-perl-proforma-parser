package FlyBase::Proforma::TI;

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

our @EXPORT = qw( process_ti validate_ti

);

our $VERSION = '0.01';

# Preloaded methods go here.
=head1 NAME

FlyBase::Proforma::TI - Perl module for parsing the FlyBase
transposable element insertion site  proforma version 22, Dec 6, 2006.

See the bottom for the proforma
                         
=head1 SYNOPSIS

  use FlyBase::Proforma::TI;
  use DBI;
  
  my $mdbh=DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";
  my %ph=(MA1a=>'TM9',....);
  ###!c field implemented as '$fieldname.upd=>'c'' eg. 'MA16.upd'=>'c'
   
  #params db is manditory, debug and validate is optional
  my $pro=FlyBase::proforma::TI->new(db=>$mdbh);
  $pro->validate(%ph);
  my $chadoxml = $pro->process(%ph);
  
  # or

  my $pro=FlyBase::Proforma::TI->new(db=>$mdbh,debug=>1,validate=>1);
  my $chadoxml_string=$pro->process(%ph);

=head1 DESCRIPTION

FlyBase::Proforma::TI is a perl module for parsing FlyBase
Trasposable element insertion site proforma and write the result as chadoxml. It is required
to connected to a chado database for validating and processing.
See Proforma for the proforma template.

The module also requires FlyBase::Proforma::Writechado and
FlyBase::Proforma::Util. The results can be loaded into a chado
database by XML::Xort.

=head2 EXPORT

  process
  validate

=cut
our %pm = ( 'p', '+', '+', '+', 'm', '-', '-', '-' );

our %ti_feature_uniquetype = (
    'MA4',  'FBtp', 'MA7',   'FBab', 'MA14', 'FBba', 'MA12', 'FBal',
    'MA5d', 'FBgn', 'MA23a', 'FBgn', 'MA18', 'FBti', 'MA15', 'FBti', 'MA21c', 'FBte','MA30' ,'FBlc',
);
our %ti_feat_type = (
    'MA7',   'chromosome_structure_variation',  # ? This existed before New SO cam along?
    'MA14',  'chromosome_structure_variation', # was single balancer
    'MA12',  'gene',
    'MA5d',  'gene',
    'MA23a', 'gene',
    'MA19a', 'transposable_element_flanking_region',
    'MA18',  'transposable_element_insertion_site',
    'MA15',  'transposable_element_insertion_site',
    'MA21c', 'natural_transposable_element',
    'MA30',  'library',
);

our %ti_fpr_type = (
    'MA11', 'comment',
    'MA4',   'producedby',
    'MA15',  'transposed_descendant_of',
    'MA15a', 'transposed_descendant_of',
    'MA7',   'associated_with',
    'MA14',  'associated_with',
    'MA12',  'associated_with',
    'MA8',   'curated_phenotype',
    'MA5a',  'curated_chromosomal_location',
    'MA5c',  'curated_cytological_location',
    'MA5e',  'derived_cyto_location',
    'MA5d',  'associated_with',
    'MA6',   'chromosomal_orientation',
    'MA19',  'associated_with',
    'MA19a', 'associated_with',
    'MA19b', 'flanking_type',                    #MA19a.featureprop
    'MA19c', 'first_base_of_target',             #MA19a.featureprop
    'MA19e', 'problem',                          #MA19a.featureprop
    'MA9',   'comment',
    'MA16',  'availability',
    'MA10',  'internalnotes',
    'MA24',  'is_multiple_insertion_line',
    'MA22',  'originating_line',
    'MA23a', 'affectedby',
    'MA23b', 'control_comment',
    'MA23c', 'comment',
    'MA23g', 'relative_orientation',
    'MA21e', 'gen_loc_comment',
    'MA21c', 'insertion_into_natTE',
    'MA21f', 'insertion_into_otherTE',
    'MA21d', 'dist_to_end_of_TE',
    'MA19d', 'first_base_of_unique_in_natTE',    #MA19a.featureprop
    'MA26',  'associated_with_natTE',
    'MA15b', 'recombinant_descendant_of',
    'MA15c', 'replacement_descendant_of',
    'MA15d', 'modified_descendant_of',
    'MA18',  'separable_insertion',
    'MA27',  'TI_subtype'
);

our %ti_type = (
    'synTE_insertion',          'transposable_element_insertion_site',
    'natTE_isolate',            'transposable_element_insertion_site',
    'natTE_partial_named',      'transposable_element_insertion_site',
    'natTE_sequenced_strain_1', 'transposable_element',
    'natTE_isolate_named',      'transposable_element_insertion_site',
    'TI_insertion',             'insertion_site',
);
my %ma30a_type = ('experimental_result', 1, 'member_of_reagent_collection',1);


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

sub process {
    my $self    = shift;
    my $tihash  = {@_};
    my %ph      = %$tihash;
    my $unique  = '';
    my $flag    = 0;
    my $feature = '';
    my $genus   = 'Drosophila';
    my $species = 'melanogaster';
    my $type    = 'transposable_element_insertion_site';
    my $out     = '';

    print STDERR "processing Transgenic Insertion ", $ph{MA1a}, "...\n";
    if ( exists( $self->{debug} ) && $self->{debug} == 1 ) {
        foreach my $key ( keys %ph ) {
            print STDERR "$key, $ph{$key}\n";
        }
    }

    if ( exists( $self->{v} ) && $self->{v} == 1 ) {
        $self->validate_ti($tihash);
    }
     if(exists($fbids{$ph{MA1a}})){
        $unique=$fbids{$ph{MA1a}};
    }
    else{
        ($unique, $out)=$self->write_feature($tihash);
    }
        if(exists($fbcheck{$ph{MA1a}}{$ph{pub}})){
        print STDERR "Warning: $ph{MA1a} $ph{pub} exists in a previous proforma\n";
    }
    $fbcheck{$ph{MA1a}}{$ph{pub}}=1;
    #print "$unique\n";
    if(!exists($ph{MA1i})){
    if($ph{pub} ne 'FBrf0000000'){
     print STDERR "Action Items: TI $unique == $ph{MA1a} with pub $ph{pub}\n"; 
    my $fpub = create_ch_feature_pub(
        doc        => $doc,
        feature_id => $unique,
        pub_id     => $ph{pub}
    );
    $out .= dom_toString($fpub);
    $fpub->dispose();
    }
    }
    else{
          print STDERR "Action items: dissociate $ph{MA1a} with pub $ph{pub} \n";
          $out .= dissociate_with_pub( $self->{db}, $unique, $ph{pub} );
          return $out;
    }
    
      if(exists($ph{MA1h}) && $ph{MA1h} eq 'y'){
        return $out;
     }
    ##Process other field in Trangenic Insertion proforma
    foreach my $f ( keys %ph ) {
         #print STDERR "$f\n";    
        
        if ( $f eq 'MA1b' || $f eq 'MA1d' || $f eq 'MA1e'  ) {
            my $t = $f;
            $t =~ s/MA1//;   
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                    my $up = 'FBrf0105495';
                    if ( $t eq 'b' ) {
                        $up = $ph{pub};
                    }  
                  $out .= delete_feature_synonym( $self->{db}, $doc, $unique, $up ,'symbol');
            }
           if(defined($ph{$f}) && $ph{$f} ne ''){
            my @items = split( /\n/, $ph{$f} );
            foreach my $item (@items) {
                $item =~ s/^\s+//;
                $item =~ s/\s+$//;
            
                if ( $f eq 'MA1d' && $item =~ /FBti/ ) {
                    my $dbxref = create_ch_feature_dbxref(
                        doc        => $doc,
                        feature_id => $unique,
                        dbxref_id  => create_ch_dbxref(
                            doc       => $doc,
                            accession => $item,
                            db        => 'FlyBase'
                        ),
                        is_current => 'f'
                    );

                    $out .= dom_toString($dbxref);
                    $dbxref->dispose();
                    my ( $s_g, $s_s, $s_t ) =
                      get_feat_ukeys_by_uname( $self->{db}, $item );
		    
                    my $s_f = create_ch_feature(
                        doc         => $doc,
                        uniquename  => $item,
                        genus       => $s_g,
                        species     => $s_s,
                        type        => $s_t,
                        is_obsolete => 't'
                    );
                    $out .= dom_toString($s_f);
                    $s_f->dispose();
                }
                else {
                    if ( $t eq 'b'  && $item eq $ph{MA1a}) {
							  print STDERR "Check TI: $item,", $fbids{$item}, "\n";
                       if($fbids{$item} eq $unique){
                            $out .=
                              write_feature_synonyms( $doc, $unique, $item, 'a',
                                $ph{pub}, 'symbol' );
                       }
                       else{
                        $out .=
                          write_feature_synonyms( $doc, $unique, $item, $t,
                            $ph{pub}, 'symbol' );
                       }                   
                    }
                    elsif ( $t eq 'c' ) {
                   
                        $out .=
                          update_feature_synonym( $self->{db}, $doc, $unique,
                            $item, 'symbol' );
                    }
                    else {
                        $out .=
                          write_feature_synonyms( $doc, $unique, $item, $t,
                            $ph{pub}, 'symbol' );
                    }
                }
            }
          }
        }
         elsif( $f eq 'MA1c'){
                    $out .=
              update_feature_synonym( $self->{db}, $doc, $unique, $ph{$f}, 'symbol' );
                $fbids{$unique}=$ph{MA1a};
        }
      
        elsif ( $f eq 'MA1g' ) {
	  my @items = split( /\n/, $ph{$f} );
	  foreach my $id (@items) {
	    $id =~ s/^\s+//;
	    $id =~ s/\s+$//;
	    my $err = 0;
	    if(!($id=~/^FBti/)){
	      $err = 1;
	      print STDERR "ERROR: $id not FBti can't merge $ph{MA1a} $ph{pub}\n";
	    }
	    elsif($err == 0){
	      my $tmp=$ph{$f};
	      $tmp=~s/\n/ /g;
	      if($ph{MA1f} eq 'new'){
		print STDERR "Action Items: merge TI $tmp\n";
	      }
	      else{
		print STDERR "Action Items: merge TI $tmp to $ph{MA1f} == $ph{MA1a} \n";
	      }
            
	      $out .= merge_records( $self->{db}, $unique, $ph{$f}, $ph{MA1a},$ph{pub},$ph{MA1a} );
              $fbids{$unique}=$ph{MA1a};
	  
	    }
	  }
	}

        elsif ($f eq 'MA4'
            || $f eq 'MA15'
	    || $f =~ '^MA15[a-d]$'
            || $f eq 'MA5d'
            || $f eq 'MA7'
            || $f eq 'MA14'
            || $f eq 'MA12'
            || $f eq 'MA26'
            || $f eq 'MA18'
            || $f eq 'MA21c' )
        {
            my $object  = 'object_id';
            my $subject = 'subject_id';
            if ( $f eq 'MA4' || $f =~ /MA15/ ) {
                $object  = 'subject_id';
                $subject = 'object_id';
            }
            if ( exists( $ph{"$f.upd"} ) and $ph{"$f.upd"} eq 'c' ) {
                  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
               
                if (  $f eq 'MA4' ) {
                    my @results =
                      get_unique_key_for_fr( $self->{db}, $object, $subject,
                        $unique, $ti_fpr_type{$f} );
                    foreach my $ta (@results) {
                    
                        my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );
                        $out .=
                          delete_feature_relationship( $self->{db}, $doc, $ta,
                            $object, $subject, $unique, $ti_fpr_type{$f});
                    }

                }
                else { 
#		    print STDERR "calling get_unique_key_for_fr $f ...\n";
                my @results =
                  get_unique_key_for_fr( $self->{db}, $object, $subject,
                    $unique, $ti_fpr_type{$f}, $ph{pub},$ti_feature_uniquetype{$f} );
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
                            print STDERR
"ERROR: $f something Wrong, please validate first\n";
                        }
                    }
                }
#		  print STDERR "finish !c $f ...\n";
            }
            if ( defined($ph{$f}) && $ph{$f} ne '' ) {
#		print STDERR "begin write_feature_relationship $f value $ph{$f} ...\n";
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {

                    #my @temps=split(/\s\#\s/,$item);
                    #if($temps[0] eq ''){
                    #	$temps[0]=$ph{$f};
                    #}
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    my ($fr,$f_p) = write_feature_relationship(
                        $self->{db},       $doc,
                        $object,           $subject,
                        $unique,           $item,
                        $ti_fpr_type{$f},  $ph{pub},
                        $ti_feat_type{$f}, $ti_feature_uniquetype{$f}
                    );
                    $out .= dom_toString($fr);
                    $fr->dispose();
                    $out.=$f_p;
                }
            }
        }
        elsif ($f eq 'MA5c'
            || $f eq 'MA5a'
            || $f eq 'MA5e'
            || $f eq 'MA9'
            || $f eq 'MA16'
            || $f eq 'MA10'
            || $f eq 'MA6'
            || $f eq 'MA8'
            || $f eq 'MA11'
            || $f eq 'MA22'
            || $f eq 'MA21d'
            || $f eq 'MA21f'
            || $f eq 'MA24'
            || $f eq 'MA21e' )
        {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                 print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                 my @results =
                  get_unique_key_for_featureprop( $self->{db}, $unique,
                    $ti_fpr_type{$f}, $ph{pub} );
                foreach my $t (@results) {
               
                    my $num = get_fprop_pub_nums( $self->{db}, $t->{fp_id} );
                   
                     if ( $num == 1  || (defined($frnum{$unique}{$ti_fpr_type{$f}}{$t->{rank}}) && $num-$frnum{$unique}{$ti_fpr_type{$f}}{$t->{rank}}==1)) {
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
            if (defined($ph{$f}) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    if($f eq 'MA5e' && exists($ph{'MA5f'})){
                        $item.='_r'.$ph{'MA5f'};
                        print STDERR "Warning: new implementation for MA5f\n";
                    }
                    if($f eq 'MA6'){
                        $item=$pm{$item};
                    }
                    $out .=
                      write_featureprop( $self->{db}, $doc, $unique, $item,
                        $ti_fpr_type{$f}, $ph{pub} );
                }
            }
        }
        elsif ( $f eq 'MA21a'  ) {
                  
            $out .= &parse_genome_location( $unique, \%ph, $ph{pub} );

        }
#        elsif ( $f eq 'MA21' ) {
          #print STDERR "Warning: in multiple MA21 field\n";
            ##### multiple featurelocs
#            my $arrayref =$ph{MA21};
           
#            my @array = @$arrayref;
           
#            foreach my $ref (@array) {
               #  print STDERR "in MA21 again\n";
#                $out .= &parse_genome_location( $unique, $ref, $ph{pub} );
 #           }
#        }
        elsif ( $f eq 'MA19' ) {
            print STDERR "Warning: in multiple MA19 field\n";
            ##### feature_relationship multiple flanking_regions
            my @array = @{ $ph{MA19} };
            foreach my $ref (@array) {
                $out .= &parse_flanking_seq( $unique, $ref, $ph{pub} );
            }
        }
        elsif ( $f eq 'MA19a' ) {
      
            ##### feature_relationship flanking_region
            $out .= &parse_flanking_seq( $unique, \%ph, $ph{pub} );
        }
        elsif ( $f eq 'MA23' ) {
         print STDERR "Warning: in multiple MA23 field\n";
            ##### feature_relationship multiple affected_gene
            my @array = @{ $ph{MA23} };
            foreach my $ref (@array) {
                $out .= &parse_affected_gene( $unique, $ref, $ph{pub} );
            }
        }
        elsif ( $f eq 'MA23a' ) {
            $out .= &parse_affected_gene( $unique, \%ph, $ph{pub} );
        }
        elsif ( $f eq 'MA30' ){               
	    print STDERR "CHECK: new implemented $f  $ph{MA1a} \n";

            if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
                print STDERR "CHECK: new implemented !c $ph{MA1a} $f \n";
            #get library_feature
		my @result =get_library_for_library_feature( $self->{db}, $unique);
                foreach my $item (@result) {          
                    (my $libu, my $libg, my $libs, my $libt)=get_lib_ukeys_by_name($self->{db},$item);
                    my $lib_feat = create_ch_library_feature(
                                   doc        => $doc,
                                   library_id => create_ch_library(doc => $doc, 
                                                                   uniquename => $libu, 
                                                                   genus => $libg, 
                                                                   species=>$libs, 
                                                                   type=>$libt,),
                                   feature_id  => $unique,
			);
                    $lib_feat->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($lib_feat);
                    $lib_feat->dispose();
                }               
            }
            if (defined ($ph{$f}) && $ph{$f} ne ""){
	      (my $libu, my $libg, my $libs, my $libt)=get_lib_ukeys_by_name($self->{db},$ph{$f});
	      if ( $libu eq '0' ) {
		print STDERR "ERROR: could not find record for $ph{MA30}\n";
		  #		  exit(0);
	      }
	      else{
		print STDERR "DEBUG: MA30 $ph{$f} uniquename $libu\n";		  
		if(defined ($ph{MA30a}) && $ph{MA30a} ne ""){
		  if (exists ($ma30a_type{$ph{MA30a}} ))  {
		    my $item = $ph{MA30a};
		    print STDERR "DEBUG: MA30a $ph{MA30a} found\n";
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
		    print STDERR "ERROR: wrong term for MA30a $ph{MA30a}\n";
		  }
		}
		else{
		  print STDERR "ERROR: MA30 has a library no term for MA30a\n";
		}
		
	      }
	    }

	}
	elsif( ($f eq 'MA30a' && $ph{MA30a} ne "") && ! defined ($ph{MA30})){
	  print STDERR "ERROR: MA30a has a term for MA30a but no library\n";
	}	    
        elsif ( $f eq 'MA27' ) {
            if ( exists( $ph{'MA27.upd'} ) && $ph{'MA27.upd'} eq 'c' ) {
              print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                my @result =
                  get_cvterm_for_feature_cvterm( $self->{db}, $unique,
                    'TI_subtype', 'FBrf0105495' );

                foreach my $item (@result) {
                 my ($cvterm, $obsolete)=split(/,,/,$item);
                    my $feat_cvterm = create_ch_feature_cvterm(
                        doc        => $doc,
                        feature_id => $unique,
                        cvterm_id  => create_ch_cvterm(
                            doc  => $doc,
                            cv   => 'TI_subtype',
                            name => $cvterm
                        ),
                        pub => 'FBrf0105495'
                    );

                    $feat_cvterm->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($feat_cvterm);
                    $feat_cvterm->dispose();
                }
            }
            if ( $ph{$f} ne '' ) {
                my $f_cvterm = &create_ch_feature_cvterm(
                    doc        => $doc,
                    feature_id => $unique,
                    cvterm_id  => create_ch_cvterm(
                        doc  => $doc,
                        cv   => 'TI_subtype',
                        name => $ph{$f}
                    ),
                    pub_id => 'FBrf0105495'
                );

                $out .= dom_toString($f_cvterm);
                $f_cvterm->dispose();
            }
        }

    }
  $doc->dispose();
    return $out;
}

sub parse_genome_location {
    my $fbti    = shift;
    my $hashref = shift;       ##reference to hash
    my $pub_id  = shift;
    my %gen_loc = %$hashref;
    my $srcfeat = '';
    my $featureloc;
    my $out     = '';
    my $strand  ='';
    my $genus   = 'Drosophila';
    my $species = 'melanogaster';
    if (exists($gen_loc{'MA21a.upd'}) && $gen_loc{'MA21a.upd'} eq 'c' ) {
	print STDERR "Action Items: !c log, $fbti MA21a $pub_id\n";
	
        $out .= delete_featureloc( $db, $doc, $fbti, $pub_id );
	#  print STDERR $out;
    }
    if ( defined( $gen_loc{MA21a} ) && $gen_loc{MA21a} ne '' ) {
        my $fmin;
        my $fmax;
        my ( $arm,  $location ) = split( /:/,    $gen_loc{MA21a} );
        if(defined($location)){
	    ( $fmin, $fmax )     = split( /\.\.|--/, $location );
	    if(!defined($fmax) && defined($fmin)){
		$fmax=$fmin;
	    }
        }
	else{
            print STDERR "ERROR: Something wrong with MA21a  $gen_loc{MA21a} please fix \n";
	}

	if($fmin>$fmax){
	    print STDERR "ERROR: $fbti fmin >fmax\n";	
	}
	
        if($arm eq '1'){
            $arm='X';
	}
	$srcfeat=$arm; 
        if ( $gen_loc{MA21b} ) {
            if ( $gen_loc{MA21b} eq '4' ) {
                $srcfeat = $arm . '_r4';
	        	print STDERR "ERROR WARN: MA21b Release 4 will not be reported\n"           
	        }
            elsif($gen_loc{MA21b} eq '3'){
                $srcfeat=$arm.'_r3';
 		        print STDERR "ERROR WARN: MA21b Release 3 will not be reported\n"           
	        }
	        elsif($gen_loc{MA21b} eq '5'){
                $srcfeat=$arm.'_r5';
 		        print STDERR "ERROR WARN: MA21b Release 5 will not be reported\n"           
   	        }
	    }
        else {
            print STDERR "ERROR: No (MA21b) Release number. This is now required."
        }
        if (!($srcfeat=~/.*_r?/)){
	    $srcfeat.='_r6';    
        }
        my $value=$srcfeat.":".$fmin.'..'.$fmax;
        my $rank=get_max_featureprop_rank($db,$fbti,'reported_genomic_loc',$value,'GenBank feature qualifier');
        my $fp=create_ch_featureprop(doc=>$doc,feature_id=>$fbti, rank=>$rank,
                                     cvname=>'GenBank feature qualifier', 
                                     type=>'reported_genomic_loc',value=>$value);
        my $fpp=create_ch_featureprop_pub(doc=>$doc, pub_id=>$pub_id);
        $fp->appendChild($fpp);
        $out.=dom_toString($fp);
        
	my $type='golden_path';
	if($srcfeat eq 'mitochondrion_genome'){
	    $type='chromosome'; 
	}
	if ( exists ($gen_loc{MA21b}) && $gen_loc{MA21b} eq '6' ) {

	    my $src = &create_ch_feature(
		doc        => $doc,
		genus      => $genus,
		species    => $species,
		uniquename => $arm,
		type       => $type,
		);

	    if(defined($fmin) && defined($fmax)){
#	    if($fmin ne $fmax){
#PDEV-58
		$fmin-=1; # interbase in chado
#	    }
		
		if(exists($gen_loc{MA6}) && $gen_loc{MA6} ne '' ){
		    if($pm{$gen_loc{MA6}} eq '+'){
			$strand=1;
		    }
		    elsif($pm{$gen_loc{MA6}} eq '-'){
			$strand=-1;
		    }
		}
		my $locgroup = &get_max_locgroup($db, $fbti,$arm,$fmin, $fmax);
		$featureloc = create_ch_featureloc(
		    doc           => $doc,
		    feature_id    => $fbti,
		    srcfeature_id => $src,
		    fmin          => $fmin,
		    fmax          => $fmax,
		    locgroup      => $locgroup,
		    strand        => $strand
		    );
	    }
	    else{
		my $locgroup = &get_max_locgroup($db, $fbti,$arm,$fmin, $fmax);
		if(defined($frnum{$fbti}{featureloc})){
		    $locgroup-=$frnum{$fbti}{featureloc};
		    if($locgroup<0){
			$locgroup=0;
		    }
		}
		$featureloc = create_ch_featureloc(
		    doc           => $doc,
		    feature_id    => $fbti,
		    srcfeature_id => $src,
		    locgroup      => $locgroup,
		    strand        => $strand
		    );
	    }
	    my $fl_pub =
		create_ch_featureloc_pub( doc => $doc, pub_id => $pub_id );
	    $featureloc->appendChild($fl_pub);
	    $out .= dom_toString($featureloc);
	    $featureloc->dispose();
	}
        
    }
    return $out;
}

sub parse_flanking_seq {
    my $fbti     = shift;
    my $flankref = shift;        ##reference to hash
    my $pub_id   = shift;
    my $out      = '';
    my %flanking = %$flankref;
    my $feature;
    if ( exists( $flanking{'MA19a.upd'} ) && $flanking{'MA19a.upd'} eq 'c' ) {
	print STDERR "Action Items: !c log, $fbti MA19a $pub_id\n";
        my @results =
	    get_unique_key_for_fr( $db, 'subject_id', 'object_id', $fbti,
				   $ti_fpr_type{MA19a}, $pub_id );
	my $num= scalar(@results);
	if ( $num == 0 ) {
	    print STDERR "ERROR !c: There is no previous record for $fbti $pub_id  MA19a\n";
	}
      else{
	  foreach my $ta (@results) {
	      my $num = get_fr_pub_nums( $db, $ta->{fr_id} );
	      if ( $num == 1 ) {
		  $out .=
		      delete_feature_relationship( $db, $doc, $ta, 'subject_id',
                    'object_id', $fbti, $ti_fpr_type{MA19a} );
	      }
	      elsif ( $num > 1 ) {
		  $out .=
		      delete_feature_relationship_pub( $db, $doc, $ta, 'subject_id',
                    'object_id', $fbti, $ti_fpr_type{MA19a}, $pub_id );
	      }
	      else {
		  print STDERR "ERROR:  something Wrong, please validate first\n";
	      }
	  }
      }
    }
    if(defined($flanking{MA19a}) && $flanking{MA19a} ne ''){
	my $gbid = $flanking{MA19a};
   
	my ( $genus, $species, $type ) = get_feat_ukeys_by_uname( $db, $gbid );
	if ( $genus eq '0' || $genus eq '2' ) {
	    print STDERR "$gbid record not found\n";
	    $type    = $ti_feat_type{MA19a};
	    $genus   = 'Computational';
	    $species = 'result';
	    $feature = create_ch_feature(
		doc        => $doc,
		uniquename => $gbid,
		type       => $type,
		genus      => $genus,
		species    => $species,
		name       => $gbid,
		no_lookup  => 1,
		macro_id   => $gbid
		);
	}
	else {
	    $feature = create_ch_feature(
		doc        => $doc,
		uniquename => $gbid,
		type       => $type,
		genus      => $genus,
		species    => $species,
    #        name       => $gbid,
		macro_id   => $gbid
		);
	}

	my $fr = create_ch_fr(
	    doc        => $doc,
	    subject_id => $fbti,
	    object_id  => $feature,
	    rtype      => $ti_fpr_type{MA19a}
	    );

	my $frp = create_ch_fr_pub( doc => $doc, pub_id => $pub_id );
	$fr->appendChild($frp);
	$out .= dom_toString($fr);
	$fr->dispose();
	if ( exists( $flanking{MA19b} )  && $flanking{MA19b} ne '') {

	    $out .=
		write_featureprop( $db, $doc, $gbid, $flanking{MA19b},
            $ti_fpr_type{MA19b}, $pub_id );
	}
	if ( exists( $flanking{MA19c} )  && $flanking{MA19c} ne '') {
	    $out .=
		write_featureprop( $db, $doc, $gbid, $flanking{MA19c},
            $ti_fpr_type{MA19c}, $pub_id );

	}
	if ( exists( $flanking{MA19d} )  && $flanking{MA19d} ne '') {
	    $out .=
		write_featureprop( $db, $doc, $gbid, $flanking{MA19d},
				   $ti_fpr_type{MA19d}, $pub_id );
	}
	if ( exists( $flanking{MA19e} )  && $flanking{MA19e} ne '') {

	    my @items = split( /\n/, $flanking{MA19e} );
	    foreach my $item (@items) {
		$out .=
		    write_featureprop( $db, $doc, $gbid, $flanking{MA19e},
				       $ti_fpr_type{MA19e}, $pub_id );
	    }
	}
    }
    return $out;
}

sub parse_affected_gene {
    my $unique  = shift;
    my $generef = shift;
    my $pub     = shift;
    my %affgene = %$generef;
    my $gene    = '';
    my $genus   = '';
    my $species = '';
    my $out     = '';
    

    if ( defined($affgene{"MA23a.upd"}) && $affgene{'MA23a.upd'} eq 'c' ) {
      print STDERR "Action Items: !c log, $unique MA23a $pub\n";
           my @results =
          get_unique_key_for_fr( $db, 'object_id', 'subject_id', $unique,
            $ti_fpr_type{MA23a},$pub);
        foreach my $ta (@results) {
            
            my $num = get_fr_pub_nums( $db, $ta->{fr_id} );
            if ( $num == 1 ) {
                $out .=
                  delete_feature_relationship( $db, $doc, $ta, 'object_id',
                    'subject_id', $unique, $ti_fpr_type{MA23a} );
                   
            }
            elsif ( $num > 1 ) {
                $out .=
                  delete_feature_relationship_pub( $db, $doc, $ta, 'object_id',
                    'subject_id', $unique, $ti_fpr_type{MA23a}, $pub );
            }
            else {
                print STDERR "ERROR:  something Wrong, please validate first\n";
            }
        }   
    }
    my $fr='';
    if(defined($affgene{MA23a}) && $affgene{MA23a} ne ''){
    
    if ( $affgene{MA23a} =~ /FBgn/ ) {
        $gene = $affgene{MA23a};
        ( $genus, $species ) =
          get_feat_ukeys_by_uname_type( $db, $affgene{MA23a}, $ti_feat_type{MA23a} );
    }
    else {
        ( $gene, $genus, $species ) =
          get_feat_ukeys_by_name_type( $db, $affgene{MA23a}, $ti_feat_type{MA23a} );
    }
    if(($genus eq '0' && $species eq '2')){
	print STDERR "ERROR: Could not get feature for $affgene{MA23a}, $ti_feat_type{MA23a}\n";
    }

    my $feature = create_ch_feature(
        doc        => $doc,
        uniquename => $gene,
        type       => 'gene',
        genus      => $genus,
        species    => $species
    );

     $fr = create_ch_fr(
        doc        => $doc,
        object_id => $unique,
        subject_id  => $feature,
        rtype      => $ti_fpr_type{MA23a}
    );
    my $frp = create_ch_fr_pub( doc => $doc, pub_id => $pub );
    $fr->appendChild($frp);
    
    
    if ( exists( $affgene{MA23g} ) ) {
        my $value = $pm{ $affgene{MA23g} };
        my $rank = get_frprop_rank( $db,'object_id','subject_id', $unique, $gene, $ti_fpr_type{MA23g}, $value );
        my $frprop = create_ch_frprop(
            doc   => $doc,
            value => $value,
            type  => $ti_fpr_type{MA23g},
            rank  => $rank
        );
        $fr->appendChild($frprop);
    }
    if ( exists( $affgene{MA23c} ) ) {
        my $value = $affgene{MA23c};
        my @items = split( /\n/, $value );
        foreach my $item (@items) {
            my $rank =
              get_frprop_rank( $db,'object_id','subject_id', $unique, $gene, $ti_fpr_type{MA23c},$value );
            my $frprop = create_ch_frprop(
                doc   => $doc,
                value => $item,
                type  => $ti_fpr_type{MA23c},
                rank  => $rank
            );
            $fr->appendChild($frprop);
        }
    }
    if ( exists( $affgene{MA23b} ) ) {
        my $value = $affgene{MA23b};
        my @items = split( /\n/, $value );
        foreach my $item (@items) {
            my $rank =
              get_frprop_rank( $db,'object_id','subject_id', $unique, $gene, $ti_fpr_type{MA23c},$value );
            my $frprop = create_ch_frprop(
                doc   => $doc,
                value => $item,
                type  => $ti_fpr_type{MA23b},
                rank  => $rank
            );
            $fr->appendChild($frprop);
        }
    }
    
    $out.=dom_toString($fr);
    }
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
    my $type = 'transposable_element_insertion_site';
    my $out = '';
    
     
 
    if (
        ( exists( $ph{MA1f} ) && $ph{MA1f} ne 'new' )
        || ( exists( $ph{MA3} )
            && $ph{MA3} eq 'y' )
      )
    {
        if ( exists( $ph{MA1f} ) ) {
            ( $genus, $species, $type ) =
              get_feat_ukeys_by_uname( $self->{db}, $ph{MA1f} ,'f');
              if($genus eq '0' || $genus eq '2'){
              ( $genus, $species, $type ) =
              get_feat_ukeys_by_name_uname( $self->{db}, $ph{MA1f},$ph{MA1a} );
              }
	    if(!exists($ph{MA1c})){
		validate_uname_name($self->{db},$ph{MA1f}, $ph{MA1a});
	    }
            $unique = $ph{MA1f};
#            $fbids{$ph{MA1a}}=$unique;
#	    print STDERR "$ph{MA1a} $unique\n";
        }
        else {
              my $nnn=$ph{MA1a};
             if(exists($ph{MA1c})){
                 $nnn=$ph{MA1c};
             }
            ( $unique, $genus, $species, $type ) =
              get_feat_ukeys_by_name( $self->{db}, $nnn );
             if($unique ne '0' && $unique ne '2'){
                   $fbids{$nnn}=$unique;
             }
        }
         if ( $genus eq '0' || $unique eq '0' ) {
            print STDERR "ERROR: could not find record for $ph{MA1a}\n";
            #exit(0);
        }
        if(exists($fbids{$unique}) ){
            print STDERR "ERROR: $unique has been in previous proforma with an action item, separate loading\n";
            return ($out,$unique);
        }
            $feature = create_ch_feature(
            doc        => $doc,
            uniquename => $unique,
            species    => $species,
            genus      => $genus,
            type       => $type,
            macro_id   => $unique,
            no_lookup  => 1
        );
        if ( exists( $ph{MA1h} ) && $ph{MA1h} eq 'y' ) {
           print STDERR "Action Items: delete TI $ph{MA1f} == $ph{MA1a}\n";
            my $op = create_doc_element( $doc, 'is_obsolete', 't' );
            $feature->appendChild($op);
        }
         if(exists($ph{MA1c})){
         if(exists($fbids{$ph{MA1c}})){
             print STDERR "ERROR: Rename MA1c $ph{MA1c} exists in a previous proforma\n";
         }
         if(exists($fbids{$ph{MA1a}})){                                    
             print STDERR "ERROR: Rename MA1a $ph{MA1a} exists in a previous proforma \n";
         } 
	 print STDERR "Action Items: Rename $ph{MA1c} to $ph{MA1a}\n";
         my $n=create_doc_element($doc,'name',decon(convers($ph{MA1a})));
         $feature->appendChild($n);
         $out.=dom_toString($feature);
         validate_uname_name($self->{db},$ph{MA1f},$ph{MA1c}) ;
			validate_new_name($self->{db},$ph{MA1a});
         $fbids{$ph{MA1c}}=$unique;
        }
        else{
        $out.=dom_toString($feature);
       }
         
       $out .= write_feature_synonyms( $doc, $unique, $ph{MA1a}, 'a',
                'unattributed', 'symbol' );
       $fbids{ $ph{MA1a} } = $unique;
       
    }
    else {
        if(!exists($ph{MA1g})){
            $flag=0;
            my $va=validate_new_name($db, $ph{MA1a});
            #   ($unique,$genus,$species,$type)=get_feat_ukeys_by_name($db,$ph{MA1a});
				#    $fbids{$ph{MA1a}}=$unique;
        }
      
        ( $unique, $flag ) = get_tempid( 'ti', $ph{MA1a} );
        print STDERR "$unique =", $ph{MA1a},"=\n";
        $fbids{$ph{MA1a}}=$unique; 
        if(exists($ph{MA1g}) && $ph{MA1f} eq 'new' && $unique !~/temp/){
            print STDERR "ERROR: merge tis should have a FB..:temp id not $unique\n";
        }
        print STDERR "Action Items: new TI $ph{MA1a} \n";
         if ( exists( $ph{MA20} ) ) {
            ( $genus, $species ) =
              get_organism_by_abbrev( $self->{db}, $ph{MA20} );
        
        }
        if ( $flag == 0 ) {
            if(exists($ph{MA27})){
                $type=$ti_type{$ph{MA27}};
            }
	    else{
		$type='transposable_element_insertion_site';
	    }
            $feature = create_ch_feature(
                uniquename => $unique,
                name       => decon( convers( $ph{MA1a} ) ),
                genus      => $genus,
                species    => $species,
                type       => $type,
                doc        => $doc,
                macro_id   => $unique,
                no_lookup  => '1'
            );
            $out.=dom_toString($feature);
            
             $out .=
              write_feature_synonyms( $doc, $unique, $ph{MA1a}, 'a',
                'unattributed', 'symbol' );
      }
     else{
            print STDERR "Warning, name $ph{MA1a} has been used in this load\n";
               }
        }
      $doc->dispose();
    return ($out, $unique);
}

#Checking points:
#I. when MA1f is new
#1. check existance of MA20(organism) MA27(TI_subtype)
#2. check for the MA1a name existance in DB.
#3. check abbrevation of organism in DB.
#4. check MA27 cvterm existance.
#5. check !c fields
#II. when MA1f has valid id
#1. check for the MA1a existance
#1. name and uniquename consistence
#2. if MA1c exists, check MA1f and MA1c consistence and MA1a existance
#in DB, otherwise only check MA1f and MA1a consistence
#3. check !c on
#4. check !c on MA21a for existance of the featureloc+pub
#ALL:
#1. if MA4, MA19, MA18, new accession/symbol is allowed
#
sub validate {
    my $self   = shift;
    my $tihash = {@_};
    my %tival  = %$tihash;
    my $v_unique='';
    
    print STDERR "Validating TI ", $tival{MA1a}, " ....\n";
    
    if(!exists($tival{MA1a})){
        print STDERR "ERROR: MA1a not exists\n";
    }
    if(exists($tival{MA1f}) && ($tival{MA1f} ne 'new') && !exists($tival{MA1c})){
    validate_uname_name($db, $tival{MA1f}, $tival{MA1a});
    }
    if ( exists( $fbids{$tival{MA1a}})){
        $v_unique=$fbids{$tival{MA1a}};    
    }
    else{
        print STDERR "ERROR: could not validate $tival{MA1a}\n";
        return;
    }
    if($v_unique =~/FBti:temp/){
        foreach my $f (keys %tival){
            if($f=~/(.*)\.upd/){
                print STDERR "ERROR: !c is not allowed for a new TI\n";
            }
        }
    }
    foreach my $f ( keys %tival ) {
            if ( $f =~ /(.*)\.upd/ && !($v_unique=~/FBti:temp/) ) {
                $f = $1;
                if (   $f eq 'MA5c'
                    || $f eq 'MA5a'
                    || $f eq 'MA5e'
                    || $f eq 'MA9'
                    || $f eq 'MA16'
                    || $f eq 'MA10'
                    || $f eq 'MA6'
                    || $f eq 'MA8'
                    || $f eq 'MA11'
                    || $f eq 'MA21e' )
                {
                    my @num =
                      get_unique_key_for_featureprop( $db, $v_unique,
                        $ti_fpr_type{$f}, $tival{pub} );
                    if ( @num == 0 ) {
                        print STDERR "ERROR: !c: there is no previous record for $f field.\n";
                    }
                }
                elsif ($f eq 'MA15'
                    || $f eq 'MA5d'
                    || $f eq 'MA7'
                    || $f eq 'MA18'
                    || $f eq 'MA19a'
                    || $f eq 'MA4'
                    || $f eq 'MA14'
                    || $f eq 'MA12'
                    || $f eq 'MA23a' )
                {
                    my $subject = 'subject_id';
                    my $object  = 'object_id';
                    if ( $f eq 'MA15' || $f eq 'MA4' || $f eq 'MA19a') {
                        $subject = 'object_id';
                        $object  = 'subject_id';
                    }
                    my @num =
                      get_unique_key_for_fr( $db, $object, $subject,
                        $v_unique, $ti_fpr_type{$f}, $tival{pub} );
                    if ( @num == 0 ) {
                        print STDERR "ERROR !c: There is no previous record for $f field\n";
                    }
                }
                elsif ( $f eq 'MA21a' ) {
                    my @num =
                      get_ukeys_from_featureloc( $db, $v_unique,
                        $tival{pub} );
                    if ( @num == 0 ) {
                        print STDERR "ERROR !c: There is no previous record for $f field\n";
                    }

                }

            elsif ( $f eq 'MA19' || $f eq 'MA21' || $f eq 'MA23' ) {
                my $arrref = $tival{$f};
                my @arrays = @$arrref;
                foreach my $href (@arrays) {
                    my %sref = %$href;
                    foreach my $key (%sref) {
                        if ( $key =~ /(.*)\.upd/ ) {
                            my $fkey = $1;
                            if ( $fkey eq 'MA21a' ) {
                                my @num =
                                  get_ukeys_from_featureloc( $db, $v_unique,
                                    $tival{pub} );
                                if ( @num == 0 ) {
                                    print STDERR " ERROR:There is no previous record for $f field\n";
                                }
                            }
                            elsif ( $fkey eq 'MA19a' || $fkey eq 'MA23a' ) {
                                    my $subject = 'subject_id';
                                    my $object  = 'object_id';
                                    if($fkey eq 'MA19a'){
                                    $object = 'subject_id';
                                    $subject  = 'object_id';
                                    }
                                my @num =
                                  get_unique_key_for_fr( $db, $object,$subject, $v_unique,
                                    $sref{$fkey}, $tival{pub} );
                                if ( @num == 0 ) {
                                    print STDERR "ERROR: There is no previous record for $fkey $sref{$fkey} field\n";
                                }

                            }
                        }

                    }
                }
            }        
       }
    elsif ( $f eq 'MA5d' || $f eq 'MA21c' || $f eq 'MA23a' || $f eq 'MA15a' || $f eq 'MA15b' 
    || $f eq 'MA15c' ) {
        if(defined($tival{$f})){
        my @items=split(/\n/,$tival{$f});
        foreach my $item(@items){
            $item=~s/^\s+//;
            $item=~s/\s+$//;
            if(!exists($fbids{$item})){
                my ( $g_u, $g_g, $g_s, $g_t ) =
                 get_feat_ukeys_by_name( $db,  $item );
                if ( $g_u eq '0' ) {
                    print STDERR "ERROR: ", $tival{MA1a}, " $f:", $item, "symbol could not be found in the Database\n";
                }
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
# Below is stub documentation for your module. You'd better edit it!

=head1 SUPPORT

proformas can be found in http://flystocks.bio.indiana.edu/flybase/curation-docs/genetic-literature/

proforma mapping table can be found in ~haiyan/Documents/TEmapping.sxw 

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
! MA. TRANSPOSON INSERTION PROFORMA [ti.pro]      Version 22: 06 Dec 2006
!
! MA1f. Database ID for insertion (FBti)       :new
! MA1a. Insertion symbol to use in database    :
! MA1b. Symbol used in paper                   :
! MA27. Insertion category [CV]                :synTE_insertion
! MA4.  Symbol of inserted transposon          :
! MA20. Species of host genome                 :

! MA1c. Action - rename this insertion symbol    :
! MA1g. Action - merge these insertion(s) (FBti) :
! MA1h. Action - delete insertion record ("y"/blank)   :
! MA1i. Action - dissociate MA1f from FBrf ("y"/blank) :

! MA1d. Other synonym(s) for insertion symbol  :
! MA1e. Silent synonym(s) for insertion symbol :
! MA22. Line id associated with insertion      :

! MA5a. Chromosomal location of insert                     :
! MA5c. Cytological location of insert (in situ)           :
! MA5e. Cytological location (inferred from sequence)      :
!   MA5f. Genomic release number for data reported in MA5e :
! MA5d. Insertion maps to/near gene                        :

! MA7.  Associated chromosomal aberration      :
! MA14. Associated balancer                    :
! MA12. Consequent allele(s)                   :

! MA8.  Phenotype [viable, fertile]            :

! MA21a. Genomic location of insertion (dupl for multiple) :
!   MA21b. Genome release number for entry in MA21a        :
! MA21e. Comments concerning genomic location              :
! MA6.   Orientation of insert relative to chromosome      :

! MA21c. Insertion into natTE (identified, in FB)             :
! MA21f. Insertion into other TE or repeat region ("y"/blank) :
! MA21d. Distance from insertion site to end of natTE/repeat  :

! MA19a. Accession for insertion flanking sequence (dupl for multiple) :
!   MA19b. Insertion site accession type (5', 3', b)                   :
!   MA19c. Position of first base of target sequence in accession      :
!   MA19d. First base of unique sequence in accession if in natTE      :
!   MA19e. Accession invalidation or assessment                        :
! MA26.  Accession for this instance of natTE                          :

! MA23a. Insertion-affected gene reported (dupl for multiple) :
!   MA23b. Affected gene criteria [CV]                        :
!   MA23c. Comment, affected gene criteria [free text]        :
!   MA23g. Orientation relative to affected gene              :

! MA15a. FBti progenitor (via transposition) at distinct location :
! MA15b. FBti progenitor (via recombination) at distinct location :
! MA15c. Replaced FBti progenitor, recombination substrate        :
! MA15d. Modified FBti progenitor (in situ)                       :

! MA24. Arose in multiple insertion line ("y"/"p"/blank) :
! MA18. Co-isolated insertion(s)                         :

! MA9.  Comments [free text]        :
! MA16. Information on availability :
! MA10. Internal notes              :
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

=head1 AUTHOR

Haiyan Zhang, E<lt>haiyan@morgan.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
