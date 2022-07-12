package FlyBase::Proforma::Strain;

use 5.008004;
use strict;
use warnings;
use XML::DOM;
use FlyBase::WriteChado;
require Exporter;
use FlyBase::Proforma::Util;
use Carp qw(croak);
use FlyBase::Proforma::ExpressionParser;

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
my $ver=2.4;
# Preloaded methods go here.

=head1 NAME

FlyBase::Proforma::Strain - Perl module for parsing the FlyBase
Strain  proforma version 12.0, May, 2012.

See the bottom for the proforma
                         
=head1 SYNOPSIS

  use FlyBase::Proforma::Strain;
  use DBI;
  
  my $mdbh=DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";
  my %ph=(SN1a=>'AT',....);
  ###!c field implemented as '$fieldname.upd=>'c'' eg. 'SN4a.upd'=>'c'
   
  #params db is manditory, debug and validate is optional
  my $pro=FlyBase::proforma::Strain->new(db=>$mdbh);
  $pro->validate(%ph);
  my $chadoxml = $pro->process(%ph);
  
  # or

  my $pro=FlyBase::Proforma::Strain->new(db=>$mdbh,debug=>1,validate=>1);
  my $chadoxml_string=$pro->process(%ph);

=head1 DESCRIPTION

FlyBase::Proforma::Strain is a perl module for parsing FlyBase
Strain proforma and write the result as chadoxml. It is required
to connected to a chado database for validating and processing.
See Proforma for the proforma template.

The module also requires FlyBase::Proforma::Writechado and
FlyBase::Proforma::Util. The results can be loaded into a chado
database by XML::Xort.

=head2 EXPORT

  process
  validate

=cut
our %sntype = (
    'wild type', 'sn',
);

our %sncv=(
	  'SN9e', 'stock_breeding_history', 
	  'SN9f', 'stock_breeding_history',
	  'SN15a', 'biological_process',
);

our %genomechars=(
  'single-nucleotide polymorphisms', '1', 
  'indels', '1', 
  'copy number variation' ,'1' ,
  'microsatellite loci', '1', 
  'restriction fragment length polymorphisms', '1', 
  'rearrangements' ,'1' ,
  'transposable elements' ,'1',
  'recombination rates', '1' ,
  'RNA expression', '1',
);

our %ftype = (
    'SN5a', 'FBal',
    'SN5b', 'FBal',
    'SN5c', 'FBab',
    'SN5d', 'FBab',
    'SN5e', 'FBti',
    'SN5f', 'FBti',
    'SN5g', 'FBba',
    'SN5h', 'FBba',
);

our %fpr_type = (
    'SN1a', 'symbol', ##strain_synonym, pub=this pub, is_current=true
    'SN1b', 'uniquename',  
    'SN1c', 'symbol',  ##strain_synonym pub=flybase pub, is_current=false
    'SN1d', 'symbol', ## rename strain_synonym 
    'SN1e', 'symbol', ## merge strain_synonym 
    'SN1f', 'organism_id',
    'SN1g', 'strain_type', ###strainprop 
    'SN2a',  'fullname',  ### is_current=true
    'SN2b',  'fullname',          ##is_current=false
    'SN2c',  'fullname', ## rename
    'SN3a', 'obsolete',  ##action items
    'SN3b', 'dissociate',  ##action items
    
    'SN4', 'derived_from',  ## strain_relationship.object_id
   
    'SN5a',  'homozygous', ## strain_feature   FBal, strain_featureprop.type=homozygous
    'SN5b',  'heterozygous', ## strain_feature  FBal  strain_featureprop.type=heterozygous
    'SN5c',  'homozygous', ## strain_feature   FBab strain_featureprop.type=homozygous
    'SN5d', 'heterozygous', ## strain_feature  FBab strain_featureprop.type=heterozygous
    'SN5e',  'homozygous', ## strain_feature  FBti strain_featureprop.type=homozygous
    'SN5f',  'heterozygous', ## strain_feature  FBti strain_featureprop.type=heterozygous
    'SN5g',  'homozygous', ## strain_feature   FBba strain_featureprop.type=homozygous
    'SN5h', 'heterozygous', ## strain_feature  FBba strain_featureprop.type=heterozygous
    'SN6a', 'unassigned_class',  ##strain_phenotype , phenotype FBcv-cvalue, FBdv and/or FBcv , strain_phenotypeprop.type=unassigned_class  phenotype_cvterm rank = alphanumeric order
    'SN6b',  'unassigned_anatomy',  ##strain_phenotype, phenotype FBbt-observable_id, strain_phenotypeprop.type=unassigned_anatomy  FBcv phenotype_cvterm rank = alphanumeric order
    'SN6c', 'selected_class',  ##strain_phenotype FBcv-cvalue, FBdv and/or FBcv , strain_phenotypeprop.type=selected_class  phenotype_cvterm rank = alphanumeric order
    'SN6d',  'selected_anatomy',  ##strain_phenotype FBbt-observable_id,  strain_phenotypeprop.type=selected_anatomy   FBcv phenotype_cvterm rank = alphanumeric order
    'SN6e',  'unassigned_pheno_comment', ##strain_phenotypeprop
    'SN6f',  'selected_pheno_comment', ##strain_phenotypeprop
    'SN6g',  'gen_pheno_comment', ##strainprop

    'SN7a', 'p_element_status',   ###strainprop      
    'SN7b', 'hobo_status',      ###strainprop
    'SN7c', 'transposon_related_comment',   ##strainprop

    'SN8a', 'strain_char_genome_seq',  ### strainprop value
    'SN8b', 'dbxref', ### strain_dbxref DB=Genbank accession (latest version)

    'SN8c', 'characterized_genome', #strainprop; allowed values are single-nucleotide polymorphisms, indels, copy number variation, microsatellite loci, restriction fragment length polymorphisms, rearrangements, transposable elements, recombination rates, RNA expression
    'SN8d', 'characterized_comments', #strainprop

    'SN9a', 'isogenized_chr',  #strainprop append SN9b,c to each SN9a
 #   'SN9b', 'isogenized_year', #strainprop
 #   'SN9c', 'isogenized_comment', #strainprop
    'SN9d', 'extract_chr', #strainprop
    'SN9e',  'inbred', #strain_cvterm y=FBsv:0000501 strain_cvtermprop.type_id 
    'SN9f', 'founded_as',#strain_cvterm only allowed values  FBsv:0000502, FBsv:0000503 strain_cvtermprop type_id
    'SN9g', 'breeding_comment', #strainprop

    'SN10a', 'introgressed_chr' , #strainprop -- combine SN10a and SN10b and SN10c
    'SN11a', 'collection_country', #strainprop
    'SN11b', 'collection_state', #strainprop
    'SN11c', 'collection_city', #strainprop
    'SN11d', 'collection_latitude', #strainprop
    'SN11e', 'collection_longitude', #strainprop
    'SN11f', 'collection_date', #strainprop
    'SN11g', 'collection_season', #strainprop
    'SN11h', 'collection_substrate', #strainprop
    'SN11i', 'collection_comment', #strainprop

    'SN12',  'comment', #strainprop
    'SN13', 'internalnotes', #strainprop
    'SN14', 'member_of_reagent_collection', #library_strain, library_strainprop
    'SN15a', 'qtl_assayed', #strain_cvterm, strain_cvtermprop, GO term
    'SN15b', 'qtl_assay_comment', #strainprop
    'SN16a', 'endosymbiont_assay', #strainprop
    'SN16b', 'endosymbiont_comment', #strainprop

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

sub process {
    my $self    = shift;
    my $tihash  = {@_};
    my %ph      = %$tihash;
    my $unique  = '';
    my $flag    = 0;
    my $feature = '';
    my $genus   = 'Drosophila';
    my $species = 'melanogaster';
    my $type;
    my $out = '';
	print STDERR "STRAIN process\n";

    if ( exists( $self->{debug} ) && $self->{debug} == 1 ) {
      foreach my $key ( keys %ph ) {
	print STDERR "$key, $ph{$key}\n";
      }
    }
    print STDERR "processing strain.pro $ph{SN1a}...\n";
    if ( exists( $self->{v} ) && $self->{v} == 1 ) {
      $self->validate($tihash);
    }
    if(exists($fbids{$ph{SN1a}})){
      $unique=$fbids{$ph{SN1a}};
    }
    else{
      ($unique, $out)=$self->write_strain($tihash);
    }
    if(exists($fbcheck{$ph{SN1a}}{$ph{pub}})){
      print STDERR "Warning: $ph{SN1a} $ph{pub} exists in a previous proforma\n";
    }
    $fbcheck{$ph{SN1a}}{$ph{pub}}=1;
    if(!exists($ph{SN3b})){
      print STDERR "Action Items: Strain $unique == $ph{SN1a} with pub $ph{pub}\n"; 
      my $f_p = create_ch_strain_pub(
				     doc        => $doc,
				     strain_id => $unique,
				     pub_id     => $ph{pub}
				    );
      $out .= dom_toString($f_p);
      $f_p->dispose();
    }    
    else{
	print STDERR "ERROR: Not implemented yet dissociate $ph{SN1a} with $ph{pub}\n";
	$out .= dissociate_with_pub_fromstrain( $self->{db}, $unique, $ph{pub} );
	return $out;
    }
    ##Process other field in Strain proforma
    foreach my $f ( keys %ph ) {

      print STDERR "CHECK:process other fields $f\n";
      if (  $f eq 'SN2b' 
            || $f eq 'SN1c' )
        {  
	  if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
            print STDERR "CHECK: !c implementation for $f\n";
            print STDERR "Action Items: !c log,$ph{SN1a} $f  $ph{pub}\n";
 
	    $out .= delete_strain_synonym( $self->{db}, $doc, $unique, $ph{pub}, $fpr_type{$f} );
             
	  }
           
	  if(defined($ph{$f}) && $ph{$f} ne ''){
	    my @items = split( /\n/, $ph{$f} );
            foreach my $item (@items) {
	      $item =~ s/^\s+//;
	      $item =~ s/\s+$//;
	      my $t = $f;
	      $t =~ s/SN\d//;
	      my $tt     = $t;
	      my $s_type = $fpr_type{$f};
	      if ( ( $f eq 'SN1c' ) && ( $item eq $ph{SN1a} ) ) {
		  $tt = 'a';
	      }
	      elsif (( $f eq 'SN2b' )
		     && exists( $ph{SN2a} )
		     && ( $item eq $ph{SN2a} ) )
	      {
		  $tt = 'a';
	      }
	      elsif ( !exists( $ph{SN2a} ) && $f eq 'SN2b' ) {
		  $tt =check_strain_synonym_is_current( $self->{db},
							$unique, $item, 'fullname' );
	      }
	      $out .=
		  write_table_synonyms( "strain",$doc, $unique, $item, $tt,
					      $ph{pub}, $s_type );
	    }
	  }
	}
      elsif($f eq 'SN2a'){
	if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
	  print STDERR "ERROR: SN2a can not accept !c\n";
	  }
	  my $num = check_strain_synonym( $self->{db},
                            $unique,  'fullname' );
	  if( $num != 0){
	    if ((defined($ph{SN2c}) && $ph{SN2c} eq '' && !defined($ph{SN1e})) || (!defined($ph{SN2c}) && !defined($ph{SN1e}) )) {
	      print STDERR "ERROR: SN2a must have SN2c filled in unless a merge\n";
	    }
	    else{
	      $out.=write_table_synonyms( "strain",$doc,$unique,$ph{$f},'a','unattributed',$fpr_type{$f});
	    }
	  }
	  else{
	    $out.=write_table_synonyms("strain",$doc,$unique,$ph{$f},'a','unattributed',$fpr_type{$f});
	  }
#Was just this but assume need same checks as Gene

#		$out.=write_table_synonyms("strain",$doc,$unique,$ph{$f},'a','unattributed',$fpr_type{$f});
	    }

      elsif($f eq 'SN4'){
	print STDERR "CHECK, first use of SN4\n";
	my $object  = 'object_id';
	my $subject = 'subject_id';

	if ( exists( $ph{"$f.upd"} ) and $ph{"$f.upd"} eq 'c' ) {
	  print STDERR "Action Items: !c log,$ph{SN4} $f  $ph{pub}\n";
	  my @results =
	    get_unique_key_for_snr( $self->{db}, $subject, $object,
				    $unique, $fpr_type{$f}, $ph{pub} );
	  foreach my $ta (@results) {
	    my $num = get_snr_pub_nums( $self->{db}, $ta->{fr_id} );
	    if ( $num == 1 ) {
	      $out .=
		delete_strain_relationship($self->{db}, $doc, $ta,
					  $subject, $object, $unique, $fpr_type{$f} );
	    }
	    elsif ( $num > 1 ) {
	      $out .=
		delete_strain_relationship_pub($self->{db}, $doc,
					      $ta, $subject, $object, $unique, $fpr_type{$f},
					      $ph{pub} );
	    }
	    else {
	      print STDERR "something Wrong, please validate first\n";
	    }
	  }

	}
	if ( defined($ph{$f}) && $ph{$f} ne '' ) {
	  my @items = split( /\n/, $ph{$f} );
	  foreach my $item (@items) {
	    $item =~ s/^\s+//;
	    $item =~ s/\s+$//;
	    my ($fr, $f_p) = write_strain_relationship($self->{db},      $doc,    $subject,
						       $object,          $unique, $item,
						       $fpr_type{$f}, $ph{pub}, 
						      );
	    $out.=dom_toString($fr);
	    $out.=$f_p;
                    
	  }
	} 
      }
      elsif($f eq 'SN1d'|| $f eq 'SN2c'){
	$out .= update_strain_synonym($self->{db}, $doc,
					  $unique, $ph{$f}, $fpr_type{$f});    
	$fbids{$unique}=$ph{SN1a};
        
      }
      elsif ( $f eq 'SN1e' ) {
	print STDERR "CHECK: SN1e check implemented merge\n";
#	my $tmp=$ph{SN1e};
#	$tmp=~s/\n/ /g;
	if($ph{SN1b} eq 'new'){
	  print STDERR "Action Items: merge strain $ph{SN1a}\n";
	}
	else{
	  print STDERR "ERROR: merge strain SN1b must be new for $ph{SN1a}\n";
	}
	$out .= merge_strain_records( $self->{db}, $unique, $ph{$f},$ph{SN1a}, $ph{pub} );
      }

      elsif ($f eq 'SN5a'
            || $f eq 'SN5b'
            || $f eq 'SN5c'
            || $f eq 'SN5d'
            || $f eq 'SN5e'
            || $f eq 'SN5f'
            || $f eq 'SN5g'
            || $f eq 'SN5h'){
	if( exists($ph{"$f.upd"}) && $ph{ "$f.upd" } eq 'c' ) {
	  print STDERR "Action Items: !c log $unique $ph{pub} $f \n";
	  print STDERR "CHECK: first use of  $f !c strain_feature\n";
	  
	  my @results = get_feature_for_strain_feature($self->{db},$unique,$ftype{$f},$fpr_type{$f},$ph{pub});
	  foreach my $item (@results){
	    my $fu = $item;
	    (my $fg, my $fs, my $ft)=get_feat_ukeys_by_uname($self->{db},$fu);
	    my $cname = "SO";
	    #if ($ft eq "single balancer"){
	    #  $cname = "FlyBase miscellaneous CV";
	    #}
	    
	    my $csf=create_ch_strain_feature(doc=>$doc,
					   feature_id=>create_ch_feature(doc=>$doc, uniquename=>$fu, genus=>$fg, species=>$fs,cvname=>$cname,type=>$ft,),
					   strain_id=>$unique,
					   pub_id=>$ph{pub});

	    $csf->setAttribute("op","delete");
	    $out.=dom_toString($csf);
	    $csf->dispose;              
	  }
	}
	if ( defined($ph{$f}) && $ph{$f} ne '' ) { 
	  print STDERR "CHECK: first use of  $f strain_feature\n";
	  my $fptype = $fpr_type{$f};
	  my @items = split( /\n/, $ph{$f} );
	  foreach my $item (@items) {
	    $item =~ s/^\s+//;
	    $item =~ s/\s+$//;
	    my $fu=$item;
	    (my $fbid,my $fg, my $fs, my$ft)=get_feat_ukeys_by_name($self->{db},$fu);
	    if($fbid eq '0' || $fbid eq '2'){
	      print STDERR "ERROR: could not find feature for $fu in DB\n";
	    }
	    else{
	      my $cname = 'SO';
	      #if ($ft eq "single balancer"){
		    #$cname = "FlyBase miscellaneous CV";
	      #}
	      my $feature=create_ch_feature(
					    doc=>$doc,
					   uniquename=>$fbid, 
					   genus=>$fg, 
					   species=>$fs, 
					   cvname=> $cname,
					   type=>$ft,
					   macro_id=>$fbid,					   
					   );
	      $out.=dom_toString($feature);  
	      my $sn_f=create_ch_strain_feature(doc=>$doc,
					     feature_id=>$fbid,
					     strain_id=>$unique,
					     pub_id=>$ph{pub},);
	      my $ph_cv = get_cv_by_cvterm( $self->{db}, $fptype);
	      print STDERR "CHECK: cv for cvterm $fptype = $ph_cv\n";

#	    my $va = validate_cvterm($self->{$db},$fptype,$ph_cv);
	      my $s_fp = create_ch_strain_featureprop(
						    doc=>$doc,
						    type_id=>create_ch_cvterm(
									      doc  => $doc,
									      name => $fptype,
									      cv   => $ph_cv
									     ),
						   );
	      $sn_f->appendChild($s_fp);    
	      $out.=dom_toString($sn_f); 
	    }	
	  }    
	}
      }
      elsif( $f=~ /SN7/
	    || $f eq 'SN6g' 
	    || $f eq 'SN8a' 
            || $f eq 'SN1g'
            || $f eq 'SN8c'
            || $f eq 'SN8d'
            || $f=~ 'SN9a'
            || $f=~ 'SN9d'
            || $f=~ 'SN9g'
            || $f=~/SN11/
            || $f eq 'SN12'
            || $f eq 'SN13' 
            || $f eq 'SN15b' 
            || $f eq 'SN16a' 
            || $f eq 'SN16b' ) {
      if ( exists( $ph{ "$f.upd" } ) && $ph{ "$f.upd" } eq 'c' ) {
	print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
	my @results =
	  get_unique_key_for_strainprop($self->{db}, $unique,
				  $fpr_type{$f}, $ph{pub} );
	foreach my $t (@results) {
	  my $num = get_strainprop_pub_nums( $self->{db}, $t->{fp_id} );
	  if ( $num == 1 || (defined($frnum{$unique}{$fpr_type{$f}}{$t->{rank}}) && $num-$frnum{$unique}{$fpr_type{$f}}{$t->{rank}}==1) ) {
	    $out .=
	      delete_strainprop( $doc, $t->{rank}, $unique,
			  $fpr_type{$f} );
	  }
	  elsif ( $num > 1 ) {
	    $out .=
	      delete_strainprop_pub($doc, $t->{rank}, $unique,
			      $fpr_type{$f}, $ph{pub} );
	  }
	  else {
	    print STDERR "ERROR:something Wrong, please validate first\n";
	  }
	}
      }
      if ( defined($ph{$f}) && $ph{$f} ne '' ) {
	print STDERR "CHECK: strainprop $unique $f $ph{pub}\n";
	my @items = split( /\n/, $ph{$f} );
	foreach my $item (@items) {
	  $item =~ s/^\s+//;
	  $item =~ s/\s+$//;
	  if($f eq 'SN9a') {
	    my $value = $item ."\t";
	    if(defined($ph{SN9b}) && $ph{SN9b} ne ''){
	      $value .= $ph{SN9b} . "\t";
	    }
	    if(defined($ph{SN9c}) && $ph{SN9c} ne ''){
	      $value .= $ph{SN9c};
	    }
	  $out .=
	    write_strainprop($self->{db}, $doc, $unique, $value,
		       $fpr_type{$f}, $ph{pub} );
	  }	     
	  else{
	    if ($f eq 'SN8c' && (! exists( $genomechars{$item} ) )){
	      print STDERR "ERROR: $item not allowed $f $unique $ph{pub}\n";
	    }
	    else{
	      $out .=
		write_strainprop($self->{db}, $doc, $unique, $item,
				 $fpr_type{$f}, $ph{pub} );
	    }
	  }
	}
      }
    }
    elsif ($f eq 'SN6a' 
            || $f eq 'SN6b'
            || $f eq 'SN6c'
            || $f eq 'SN6d'){
      if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
	print STDERR "ERROR: !c has not implemented yet for $f\n";
      }
      if( defined($ph{$f}) && $ph{$f} ne '' ) {
	print STDERR "CHECK: $unique $f $ph{pub}\n";

	my @items=split("\n", $ph{$f});
	foreach my $item(@items){
	  $item=trim($item);
	  my($phenout, $phenotype) = 
	    write_phenotype($f,$item);
	  if ( !exists( $fprank{phenotype}{$phenotype} ) ) {
	    $out .= $phenout;
	    $fprank{phenotype}{$phenotype} = 1;
	  }
	  if(defined($phenotype)){
	    #the type of strain_phenotypeprop unassigned, selected
	    my $fptype = "";
	    my $value = "";
	    if( defined($ph{SN6e}) && $ph{SN6e} ne ''){
	      $fptype = $fpr_type{SN6e};
	      $value = $ph{SN6e};
	      print STDERR "CHECK: $fptype, $value SN6e $unique \n";
	    }
	    elsif(defined($ph{SN6f}) && $ph{SN6f} ne ''){
	      $fptype = $fpr_type{SN6f};
	      $value = $ph{SN6f};
	      print STDERR "CHECK: $fptype, $value SN6f $unique \n";
	    }
	    $out .= write_strain_phenotype( $unique,$phenotype,$ph{pub},$fpr_type{$f},$value,$fptype);
	  }
	}
      }
    }
    elsif ($f eq 'SN10a') {
      print STDERR "CHECK: first use ofsingle $f\n";
      if ( exists( $ph{"SN10a.upd"} ) && $ph{"SN10a.upd"} eq 'c' ) {
	  print STDERR "Action Items: !c log,$unique $f  $ph{pub}\n";
	  my @results =
	    get_unique_key_for_strainprop( $self->{db}, $unique,
                    $fpr_type{SN10a}, $ph{pub} );
	  foreach my $t (@results) {
	    my $num = get_strainprop_pub_nums( $self->{db}, $t->{fp_id} );
	    if ( $num == 1 ) {
	      $out .=
		delete_strainprop( $doc, $t->{rank}, $unique,
				   $fpr_type{$f} );
	    }
	    elsif ( $num > 1 ) {
	      $out .=
		delete_strainprop_pub( $doc, $t, $unique,
				       $fpr_type{SN10a}, $ph{pub} );
	    }
	    else {
	      print STDERR "ERROR: something Wrong, please validate first\n";
	    }
	  }
	}
	if ( defined ($ph{SN10a}) && $ph{SN10a} ne '' ) { 
	  my $value = $ph{SN10a};
	  if(exists($ph{SN10b}) ){
	    $value.="\t".$ph{SN10b};            
	  }
	  else{$value.="\t";}
	  if(exists($ph{SN10c})){
	    $value.="\t".$ph{SN10c};
	  }
	  else {$value.="\t";}
	$out .=
                      write_strainprop( $self->{db}, $doc, $unique, $value,
                        $fpr_type{$f}, $ph{pub} );
	} 
      
    }
    elsif ($f eq 'SN10') {
      print STDERR "CHECK: first use of multiple $f\n";
      print STDERR "Warning: in multiple field SN10\n";
     my @array = @{ $ph{$f} };
      foreach my $ref (@array) {
	my %tt=%$ref;
	if ( exists( $tt{"SN10a.upd"} ) && $tt{"SN10a.upd"} eq 'c' ) {
	  print STDERR "Action Items: !c log,$unique $f  $ph{pub}\n";
	  my @results =
	    get_unique_key_for_strainprop( $self->{db}, $unique,
                    $fpr_type{SN10a}, $ph{pub} );
	  foreach my $t (@results) {
	    my $num = get_strainprop_pub_nums( $self->{db}, $t->{fp_id} );
	    if ( $num == 1 ) {
	      $out .=
		delete_strainprop( $doc, $t->{rank}, $unique,
				   $fpr_type{$f} );
	    }
	    elsif ( $num > 1 ) {
	      $out .=
		delete_strainprop_pub( $doc, $t, $unique,
				       $fpr_type{SN10a}, $ph{pub} );
	    }
	    else {
	      print STDERR "ERROR: something Wrong, please validate first\n";
	    }
	  }
	}
	if ( defined($tt{SN10a}) && $tt{SN10a} ne '' ) { 
	  my $value = $tt{SN10a};
	  if(exists($tt{SN10b}) ){
	    $value.=';'.$tt{SN10b};            
	  }
	  else{$value.=';';}
	  if(exists($tt{SN10c})){
	    $value.=';'.$tt{SN10c};
	  }
	  else {$value.=';';}
	$out .=
                      write_strainprop( $self->{db}, $doc, $unique, $value,
                        $fpr_type{SN10a}, $ph{pub} );
	} 
      }
    }
    elsif($f eq 'SN8b'){
      print STDERR "CHECK: first use of strain_dbxref\n";
      if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
	print STDERR "ERROR: !c not allowed $unique $f $ph{pub}\n";
      }
      else{
	  if(defined ($ph{SN8b} ) && $ph{SN8b}ne ''){
	      my $dbn = "GB";
	      my @items=split(/\n/,$ph{$f});
	      foreach my $item(@items){

		  my $dbxref=$item; 
		  my $version = '';
		  if($item=~/(.*)\.(\d)/){
		      $dbxref=$1;
		      $version=$2;
		  }
		  my $sdbxref=create_ch_strain_dbxref(doc=>$doc,
					      strain_id=>$unique,
					      dbxref_id=>create_ch_dbxref(doc=>$doc, 
									  db=>$dbn,
									  accession=>$dbxref, 
									  version=>$version, 
									  no_lookup=>1, 
									  macro_id=>$dbxref,
									 ),
					       ); 
		  $out .= dom_toString($sdbxref);
	      }
	  }
      }
    }
        elsif ($f eq 'SN9e') {
	  my $term = 'inbred line';
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                my @result =
                  get_cvterm_for_strain_cvterm( $self->{db}, $unique, $sncv{$f},
                    $ph{pub} );

                foreach my $item (@result) {
                    my ($cvterm, $obsolete)=split(/,,/,$item);
                    my $feat_cvterm = create_ch_strain_cvterm(
                        doc        => $doc,
                        strain_id => $unique,
                        cvterm_id  => create_ch_cvterm(
                            doc  => $doc,
                            cv   => $sncv{$f},
                            name => $cvterm,
                        ),
                        pub_id => $ph{pub}
                    );

                    $feat_cvterm->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($feat_cvterm);
                    $feat_cvterm->dispose();
                }
            }
            if ( defined($ph{$f}) && $ph{$f} eq 'y' ) {
	      my $f_cvterm = &create_ch_strain_cvterm(
						      doc        => $doc,
						      strain_id => $unique,
						      cvterm_id  => create_ch_cvterm(
										     doc  => $doc,
										     cv   => $sncv{$f},
										     name => $term,
										    ),
						      pub_id => $ph{pub}
						     );
	      my $fcvprop=create_ch_strain_cvtermprop(
                        doc=>$doc,
                        type=>$fpr_type{'SN9e'},
							   );
                    
	      $f_cvterm->appendChild($fcvprop);
		  
	      $out .= dom_toString($f_cvterm);
	      $f_cvterm->dispose();
	    }
	}
            elsif ($f eq 'SN9f') {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                my @result =
                  get_cvterm_for_strain_cvterm( $self->{db}, $unique, $sncv{$f},
                    $ph{pub} );

                foreach my $item (@result) {
                    my ($cvterm, $obsolete)=split(/,,/,$item);
                    my $feat_cvterm = create_ch_strain_cvterm(
                        doc        => $doc,
                        strain_id => $unique,
                        cvterm_id  => create_ch_cvterm(
                            doc  => $doc,
                            cv   => $sncv{$f},
                            name => $cvterm,
                        ),
                        pub_id => $ph{pub}
                    );

                    $feat_cvterm->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($feat_cvterm);
                    $feat_cvterm->dispose();
                }
            }
            if ( defined($ph{$f}) && $ph{$f} ne '' ) {
	      if($ph{$f} eq 'isofemale line' ||  $ph{$f} eq 'multi-female line'){
		my $rc=validate_cvterm($self->{db},$ph{$f}, $sncv{$f});
		my $f_cvterm = &create_ch_strain_cvterm(
						      doc        => $doc,
						      strain_id => $unique,
						      cvterm_id  => create_ch_cvterm(
										     doc  => $doc,
										     cv   => $sncv{$f},
										     name => $ph{$f},
										    ),
						      pub_id => $ph{pub}
						     );
		my $fcvprop=create_ch_strain_cvtermprop(
						      doc=>$doc,
						      type=>$fpr_type{$f},
							   );
                    
		$f_cvterm->appendChild($fcvprop);
		  
		$out .= dom_toString($f_cvterm);
		$f_cvterm->dispose();
	      }
	      else{
		print STDERR "ERROR:$ph{$f} not allowed in field $f for  $unique $ph{SN1a} $ph{pub}\n";
	      }
	    }  
	  }
            elsif ($f eq 'SN15a') {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                my @result =
                  get_cvterm_for_strain_cvterm( $self->{db}, $unique, $sncv{$f},
                    $ph{pub} );

                foreach my $item (@result) {
                    my ($cvterm, $obsolete)=split(/,,/,$item);
                    my $feat_cvterm = create_ch_strain_cvterm(
                        doc        => $doc,
                        strain_id => $unique,
                        cvterm_id  => create_ch_cvterm(
                            doc  => $doc,
                            cv   => $sncv{$f},
                            name => $cvterm,
                        ),
                        pub_id => $ph{pub}
                    );

                    $feat_cvterm->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($feat_cvterm);
                    $feat_cvterm->dispose();
                }
            }
            if ( defined($ph{$f}) && $ph{$f} ne '' ) {
	      my @items = split( /\n/, $ph{$f} );
	      foreach my $item (@items) {
		$item =~ s/^\s+//;
		$item =~ s/\s+$//;
		my $rc=validate_cvterm($self->{db},$item, $sncv{$f});
		my $f_cvterm = &create_ch_strain_cvterm(
						      doc        => $doc,
						      strain_id => $unique,
						      cvterm_id  => create_ch_cvterm(
										     doc  => $doc,
										     cv   => $sncv{$f},
										     name => $item,
										    ),
						      pub_id => $ph{pub}
						     );
		my $fcvprop=create_ch_strain_cvtermprop(
						      doc=>$doc,
						      type=>$fpr_type{$f},
							   );
                    
		$f_cvterm->appendChild($fcvprop);
		  
		$out .= dom_toString($f_cvterm);
		$f_cvterm->dispose();
	      }
	    }  
	  }

      elsif ($f eq 'SN14'){
	print STDERR "CHECK: use of SN14\n";

	if( exists($ph{"$f.upd"}) && $ph{ "$f.upd" } eq 'c' ) {
	  print STDERR "Action Items: !c log $unique $f $ph{pub}\n";
	  print STDERR "CHECK: use of  $f !c \n";
	  my @result = get_library_for_library_strain($self->{db}, $unique, $ph{pub}, $fpr_type{$f});
	  foreach my $item (@result) {
	    my ($lg,$ls,$lt)=get_library_ukeys_by_uname($self->{db},$item);	    
	    my $clp=create_ch_library_strain(doc=>$doc,
                         library_id=>create_ch_library(doc=>$doc, uniquename=>$item, genus=>$lg, species=>$ls, type=>$lt,),
                         strain_id=>$unique,
			 pub_id=>$ph{pub},
			);
	    $clp->setAttribute("op","delete");
	    $out.=dom_toString($clp);
	  }
	}
	if ( defined($ph{$f}) && $ph{$f} ne '' ) { 
	  my @items = split( /\n/, $ph{$f} );
	  foreach my $item (@items) {
	    $item =~ s/^\s+//;
	    $item =~ s/\s+$//;
	    print STDERR "DEBUG: SN14 $item\n";

	    my ($lu,$lg,$ls,$lt)=get_lib_ukeys_by_name($self->{db},$item);
	    if(defined($lu) && defined($lg) && defined($ls) && defined($lt)){
	      my $cl=create_ch_library_strain(
					      doc=>$doc,
					      library_id=>create_ch_library(doc=>$doc, uniquename=>$lu, genus=>$lg, species=>$ls, type=>$lt),
					      strain_id=>$unique,
					      pub_id=>$ph{pub},
					     ); 
	      my $clp = create_ch_library_strainprop(
					       doc=>$doc,
					       type_id=>create_ch_cvterm(
									 doc  => $doc,
									 name => $fpr_type{$f},
									 cv   => "library_strainprop type",
									),
					       );
	      $cl->appendChild($clp);    
	      $out.=dom_toString($cl);
	    }
	    else{
	      print STDERR "ERROR:  unique key missing for $f $item\n";
	    }
	  }
	}
      }
    }
    $doc->dispose();
    return $out;
  }

sub write_phenotype {
    my $field        = shift;
    my $aref         = shift;
    my @cvterms      = ();
    my $phenotype    = '';
    my @newpheno     = ();
    my $first        = '';
    my $out          = '';
    my $pheno_unique = '';
    print STDERR $field, $aref, "\n";

    my @phenoclass = split( /\s\|\s/, $aref );
    $first = shift(@phenoclass);
    foreach my $pheno (@phenoclass) {
      push( @cvterms, $pheno );
    }

    @newpheno = sort(@cvterms);
    unshift( @newpheno, $first );
    
    $pheno_unique = join( ' | ', @newpheno );

    print "Pheno unique $pheno_unique\n";

    if ( $field eq 'SN6a' || $field eq 'SN6c' ) {
        my $ph_cv=get_cv_by_cvterm($db, $first);
	if(!defined($ph_cv)){
	  print STDERR "ERROR: cvterm $first for $db not found in DB\n"; 
	}
	validate_cvterm($db,$first,$ph_cv);
        $phenotype = create_ch_phenotype(
            doc           => $doc,
            assay_id      => 'unspecified',
            attr_id       => 'unspecified',
            observable_id => 'unspecified',
            cvalue_id     => create_ch_cvterm(
                doc  => $doc,
                name => $first,
                cv   => $ph_cv
            ),
            uniquename => $pheno_unique,
            macro_id   => $pheno_unique
        );
        my $pv_rank = 0;
        shift(@newpheno);
        foreach my $phe (@newpheno) {
            my $ph_cv = get_cv_by_cvterm( $db, $phe );
            if ( !defined($ph_cv) ) {
                print STDERR "ERROR: could not get cv for $phe\n";
            }
            my $p_cv = create_ch_phenotype_cvterm(
                doc       => $doc,
                cvterm_id => create_ch_cvterm(
                    doc  => $doc,
                    name => $phe,
                    cv   => $ph_cv
                ),
                rank => $pv_rank
            );
            $phenotype->appendChild($p_cv);
            $pv_rank++;
        }
    }
    elsif ( $field eq 'SN6b' || $field eq 'SN6d' ) {
        my $observ_cv = get_cv_by_cvterm( $db, $first );
        my $cvflag = 0;
        if ( !defined($observ_cv) ) {
            print STDERR "ERROR: could not find cv for $first\n";
            $observ_cv = 'FlyBase anatomy CV';
            $cvflag    = 1;
        }
        my $observ = '';
        if ( $cvflag == 1 ) {
            $observ = create_ch_cvterm(
                doc       => $doc,
                name      => $first,
                cv        => $observ_cv,
                dbxref_id => create_ch_dbxref(
                    doc       => $doc,
                    accession => $pheno_unique,
                    db        => 'FlyBase',
                    no_lookup => 1
                ),
                no_lookup => 1
            );
        }
        else {
         validate_cvterm($db,$first,$observ_cv);
            $observ = create_ch_cvterm(
                doc  => $doc,
                name => $first,
                cv   => $observ_cv
            );
        }
        $phenotype = create_ch_phenotype(
            doc           => $doc,
            assay_id      => 'unspecified',
            attr_id       => 'unspecified',
            cvalue_id     => 'unspecified',
            observable_id => $observ,
            uniquename    => $pheno_unique,
            macro_id      => $pheno_unique
        );

        if ( !( $first =~ /\&/ ) ) {
            my $pv_rank = 0;
            shift(@newpheno);
            foreach my $phe (@newpheno) {
           
                my $ph_cv = get_cv_by_cvterm( $db, $phe );
                 validate_cvterm($db,$phe,$ph_cv);
                my $p_cv = create_ch_phenotype_cvterm(
                    doc       => $doc,
                    cvterm_id => create_ch_cvterm(
                        doc  => $doc,
                        name => $phe,
                        cv   => $ph_cv
                    ),
                    rank => $pv_rank
                );
                $phenotype->appendChild($p_cv);
                $pv_rank++;
            }
        }
    }
    $out .= dom_toString($phenotype);
    $phenotype->dispose();
    return ( $out, $pheno_unique);
}

sub write_strain_phenotype{
  my $fbsn    = shift;
  my $pheno = shift;      
  my $pub_id  = shift; 
  my $type = shift;
  my $value = shift;
  my $fptype = shift;
  my $out = '';

 
  my $sn_ph = create_ch_strain_phenotype(
					 doc=>$doc,
					 strain_id=>$fbsn,
					 phenotype_id=>$pheno,
					 pub_id=>$pub_id,
					);
  if( defined($type) && $type ne '' ){
    my $ph_cv = get_cv_by_cvterm( $db, $type );
    validate_cvterm($db,$type,$ph_cv);      
    my $spp = create_ch_strain_phenotypeprop(
					       doc=>$doc,
					       type_id=>create_ch_cvterm(
									 doc  => $doc,
									 name => $type,
									 cv   => $ph_cv,
									),
					       );
    $sn_ph->appendChild($spp);    

    if( defined($value) && $value  ne ''){
      print STDERR "CHECK: strain_phenotypeprop value = $value \n";
      my $spp2 = create_ch_strain_phenotypeprop(
						doc=>$doc,
						type_id=>create_ch_cvterm(
									 doc  => $doc,
									 name => $fptype,
									 cv   => $ph_cv,
									),
						value=>$value,
					       );
      $sn_ph->appendChild($spp2);    
    }
  }
  $out .= dom_toString($sn_ph);
  $sn_ph->dispose();
  return ( $out );
}

=head2 $pro->write_strain(%ph)

  separate the id generation and lookup from the other curation field to make two-stage parsing possible

=cut

sub write_strain{
    my $self    = shift;
    my $tihash  = {@_};
    my %ph      = %$tihash;
    my $unique  = '';
    my $flag    = 0;
    my $feature = '';
    my $genus='Drosophila';
    my $species='melanogaster';
    my $out = '';
   
 
    if ( exists( $ph{SN1b} ) && $ph{SN1b}  ne 'new') {   
      if(defined($fbids{$ph{SN1a}}) && !exists($ph{SN1d}) && !exists($ph{SN1e}) && !exists( $ph{SN3a})) {
             ###if $ph{SN1a} already exists in previous proforma, check and do not redo the xml
	$unique=$fbids{$ph{SN1a}};
	if($unique ne $ph{SN1b}){
	  print STDERR "ERROR: something is wrong! $ph{SN1a} != $ph{SN1b}\n";
	}
      }
      else{
        ( $genus, $species) =
          get_strain_ukeys_by_uname( $self->{db}, $ph{SN1b} );
	if ( $genus eq '0' ) {
	  print STDERR "ERROR: could not find record for $ph{SN1b}\n";
	  exit(0);
	}
	$unique=$ph{SN1b};

	$feature = create_ch_strain(
				      doc        => $doc,
				      uniquename => $unique,
				      species    => $species,
				      genus      => $genus,
				      macro_id   => $unique,
				     );

        if ( exists( $ph{SN3a} ) && $ph{SN3a} eq 'y' ) {
	  print STDERR "Action Items: delete strain $ph{SN1b} == $ph{SN1a}\n";
	  my $op = create_doc_element( $doc, 'is_obsolete', 't' );
	  $feature->appendChild($op);
        }
	if(exists($ph{SN1d})){
	 if(exists($fbids{$ph{SN1d}})){
	     print STDERR "ERROR: Rename SN1d $ph{SN1d} exists in a previous proforma\n";
	 }
	 if(exists($fbids{$ph{SN1a}})){                                    
	     print STDERR "ERROR: Rename SN1a $ph{SN1a} exists in a previous proforma \n";
	 }  

	  print STDERR "Action Items: rename $ph{SN1b} from $ph{SN1d} to $ph{SN1a}\n";
	  my $va=validate_strain_name($db, $ph{SN1a});
	  if($va == 0){
	    my $n=create_doc_element($doc,'name',decon(convers($ph{SN1a})));
	    $feature->appendChild($n);
	    $out.=dom_toString($feature);
	    $out .=  write_table_synonyms("strain",$doc, $unique, $ph{SN1a}, 'a',
                'unattributed', 'symbol' );
	    $fbids{ $ph{SN1d} } = $unique;
	  }
	}
        else{
	  $out.=dom_toString($feature);
	}
	$fbids{ $ph{SN1a} } = $unique;
      }
    }
    else {
      if (!exists($ph{SN1e})){
	my $va=validate_strain_name($db, $ph{SN1a});
        ### if the temp id has been used before, $flag will be 1 to avoid
        ### the DB Trigger reassign a new id to the same symbol.
	if($va==1 && !exists($ph{SN1d})){
	  $flag=0;
	  ($unique,$genus,$species)=get_strain_ukeys_by_name($db,$ph{SN1a});
	  $fbids{$ph{SN1a}}=$unique;
	}
      }
      print STDERR "Action Items: new Strain $ph{SN1a}\n";
      ( $unique, $flag ) = get_tempid( 'sn', $ph{SN1a} );
      if(exists($ph{SN1e}) && $ph{SN1b} eq 'new' && $unique !~/temp/){
	print STDERR "ERROR: merge strain should have a FB..:temp id not $unique\n";
      }
      if ( exists( $ph{SN1f} ) ) {
	( $genus, $species ) =
	    get_organism_by_abbrev( $self->{db}, $ph{SN1f} );
      }
      elsif ( $ph{SN1a} =~ /^(.{4,14}?)\\(.*)/ ) {
	( $genus, $species ) = get_organism_by_abbrev( $self->{db}, $1 );
      }
      if($genus eq '0'){
	print STDERR "ERROR: could not get genus forStrain $ph{SN1f}\n";
	exit(0);
      }        
      if ( $flag == 0 ) {
	$feature = create_ch_strain(
		uniquename => $unique,
                name       => decon( convers( $ph{SN1a} ) ),
                genus      => $genus,
                species    => $species,
                doc        => $doc,
                macro_id   => $unique
				   );
	$out.=dom_toString($feature);
	$out .=
	  write_table_synonyms("strain",$doc, $unique, $ph{SN1a}, 'a',
                'unattributed', 'symbol' );
      }
      else{
	print STDERR "ERROR, name $ph{SN1a} has been used in this load\n";
      }
    }
    
    $doc->dispose();
    return ($out, $unique);
  }

=head2 $pro->validate(%ph)

   validate the following:
   1. validate TE1f and TE1a consistency.
   2. If !c exists, check whether this record already exists in DB.
   3. the values following TE8,9,10,11 have to be a valid symbol in the database.

=cut

sub validate {
    my $self   = shift;
    my $tihash = {@_};
    my %tival  = %$tihash;
    my $v_unique ='';
 
    print STDERR "validating strain ", $tival{SN1a}, "\n";
    
    if(exists($tival{SN1b}) && ($tival{SN1b} ne 'new')){
        validate_uname_name("strain",$db, $tival{SN1b}, $tival{SN1a});
    }
    if ( exists( $fbids{$tival{SN1a}})){
        $v_unique=$fbids{$tival{SN1a}};    
    }
    else{
        print STDERR "ERROR: could not validate $tival{SN1a}\n";
        return;
    }
    
    foreach my $f ( keys %tival ) {
          if($f eq 'LC4c'){
            my @items=split(/\n/,$tival{$f});
            foreach my $item(@items){
                   $item=~s/\s+$//;
                   $item=~s/^\s+//;  
                   
                   validate_cvterm($db,$item,$fpr_type{$f});
             }
           }
            if ( $f =~ /(.*)\.upd/ && !($v_unique=~/temp/) ) {
                $f = $1;
                if (  $f eq 'SN7b'
            || $f eq 'SN7c'
            || $f eq 'SN6e'
            || $f eq 'SN7a'
            || $f eq 'SN8c'
            || $f eq 'SN8d'
            || $f eq 'SN8e'
            || $f eq 'SN8f'
            || $f eq 'SN8g'
            || $f eq 'SN9a'
            || $f eq 'SN9b'
            || $f eq 'SN9c'
            || $f eq 'SN9d'
            || $f eq 'SN9c'
            || $f eq 'SN9d'
            || $f eq 'SN9e'
            || $f eq 'SN9f'
            || $f eq 'SN9g'
            || $f=~/SN11/
            || $f eq 'SN12'
            || $f eq 'SN13'
            )
                {
                    my $num =
                      get_unique_key_for_strainprop( $db, $v_unique,
                        $fpr_type{$f}, $tival{pub} );
                    if ( $num == 0 ) {
                        print STDERR
                          "there is no previous record for $f field.\n";
                    }
                }
            }
        }
       if($v_unique =~/temp/){    
        foreach my $fu ( keys %tival ) {
            if ( $fu =~ /(.*)\.upd/ ) {
                print STDERR "ERROR:Wrong !c fields  $1 for a new record \n";
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


=head1 AUTHOR

Haiyan Zhang, E<lt>haiyan@morgan.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
