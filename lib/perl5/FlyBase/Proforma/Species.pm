package FlyBase::Proforma::Species;

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

# This allows declaration	use FlyBase::Proforma::Species ':all';
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

FlyBase::Proforma::Species - Perl module for parsing the FlyBase
Species  proforma version 2.2, Dec 2009.

See the bottom for the proforma
                         
=head1 SYNOPSIS

  use FlyBase::Proforma::Species;
  use DBI;
  
  my $mdbh=DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";
  my %ph=(SP1a=>'Drosophila',....);
  ###!c field implemented as '$fieldname.upd=>'c'' eg. 'SP3.upd'=>'c'
   
  #params db is manditory, debug and validate is optional
  my $pro=FlyBase::proforma::Species->new(db=>$mdbh);
  $pro->validate(%ph);
  my $chadoxml = $pro->process(%ph);
  
  # or

  my $pro=FlyBase::Proforma::Species->new(db=>$mdbh,debug=>1,validate=>1);
  my $chadoxml_string=$pro->process(%ph);

=head1 DESCRIPTION

FlyBase::Proforma::Species is a perl module for parsing FlyBase
species proforma and write the result as chadoxml. It is required
to connected to a chado database for validating and processing.
See Proforma for the proforma template.

The module also requires FlyBase::Proforma::Writechado and
FlyBase::Proforma::Util. The results can be loaded into a chado
database by XML::Xort.

=head2 EXPORT

  process
  validate

=cut

our %fpr_type = (
    'SP1a', 'genus', ## SP1a + SP1b organism uniquekey
    'SP1b', 'species', ## SP1a + SP1b organism uniquekey 
    'SP1g', 'y/n', ## n SP1a + SP1b not in chado
    'SP2',  'abbreviation',  ## organism.abbreviation may add if none
    'SP3a',  'common_name',   ## organism.common_name like update sequence in feature
    'SP3b',  'y/blank',   ## if y change organism.common_name like DB2b
    'SP4', 'NCBITaxon',  ##organism_dbxref.dbxref_id (db.name = NCBITaxon)
    'SP5', 'taxgroup',  ##organismprop free text multiple values (cv property type, type = taxgroup) 
    'SP6', 'official_db',  ## organismprop value; type=offical_db check valid db.name (HGNC, MGI) before use as value for organismprop 
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
  my $genus   = '';
  my $species = '';
  my $flag    = 0;
  my $out = '';

  if ( exists( $self->{debug} ) && $self->{debug} == 1 ) {
      foreach my $key ( keys %ph ) {
	  print STDERR "$key, $ph{$key}\n";
      }
  }
  print STDERR "processing Species.pro $ph{SP1a} $ph{SP1b} ...\n";
  if ( exists( $self->{v} ) && $self->{v} == 1 ) {
      $self->validate($tihash);
  }
  $genus = $ph{SP1a};
  $species =$ph{SP1b};
  $unique= $genus.'_'.$species;

  if(exists($fbids{$ph{SP1a}.'_'.$ph{SP1b}})){
    $unique=$fbids{$genus.'_'.$species};
  }
  else{
      print STDERR "Species.pro in  process calling write_species($tihash)\n";    
    ($unique, $out)=$self->write_species($tihash);
  }
  if(exists($fbcheck{$genus.'_'.$species}{$ph{pub}})){
    print STDERR "Warning: Species genus $genus == $ph{SP1a} species $species == $ph{SP1b} $ph{pub} exists in a previous proforma\n";
  }
  print STDERR "Action Items: Species genus $genus == $ph{SP1a} species $species == $ph{SP1b} with pub $ph{pub}\n"; 
  my $f_p = create_ch_organism_pub(
      doc => $doc,
      organism_id => create_ch_organism(
	  doc=> $doc,
	  genus=> $genus,
	  species => $species,
      ),
      pub_id     => $ph{pub},
      );
  $out .= dom_toString($f_p);
  $f_p->dispose();

  ##Process other field in Trangenic Insertion proforma
  foreach my $f ( keys %ph ) {
      if ($f eq 'SP4'){  
	  print STDERR "CHECK: first use of  $f \n";
	  if( exists($ph{"$f.upd"}) && $ph{ "$f.upd" } eq 'c' ) {
	      print STDERR "Action Items: !c log $unique $f\n";
	      print STDERR "CHECK: first use of  $f !c \n";
	      my ($dbname,$acc,$ver)= get_organism_dbxref_by_db($self->{db}, $genus,$species, 'NCBITaxon');
	      if ($dbname eq '0'){
		  print STDERR "ERROR: Cannot get organism_dbxref for $genus, $species , NCBITaxon\n"; 
	      }	
	      else{
		  my $clp=create_ch_organism_dbxref(doc=>$doc,
						organism_id=>create_ch_organism(doc=>$doc,
										genus=>$genus, 
										species=>$species,
					       ),
					       db=>$dbname, 
					       accession=>$acc, 
					       version=>$ver,
		      );
		  $clp->setAttribute("op","delete");
		  $out.=dom_toString($clp);
	      }
	  }
	  if ( defined($ph{$f}) && $ph{$f} ne '' ) { 
	      my $item = $ph{SP4};
	      my $num = get_num_organism_dbxref($self->{db}, $genus, $species, 'NCBITaxon', $item);
	      if(($num != 0) && !exists($ph{"$f.upd"})){
		  print STDERR "ERROR: Cannot have more than 1 NCBITaxon dbxref $genus, $species $ph{$f}\n";
	      }
	      else{
		  my $cl=create_ch_organism_dbxref(doc=>$doc,
						   organism_id=>create_ch_organism(doc=>$doc,
										   genus=>$genus, 
										   species=>$species,
						   ),
						   dbxref_id => create_ch_dbxref(doc=>$doc,
										   db=>"NCBITaxon", 
										   accession=>$item,
										   no_lookup=>1,
										   ),
		      );
		  $out.=dom_toString($cl);
	      }
	  }
      }
      elsif ($f eq 'SP5'){
	  my $rn=0;
	  print STDERR "CHECK: first use of  $f \n";
	  if( exists($ph{"$f.upd"}) && $ph{ "$f.upd" } eq 'c' ) {
	      print STDERR "Action Items: !c log $unique $f $ph{pub}\n";
	      print STDERR "CHECK: first use of  $f !c \n";
	      my @results =
		   get_unique_key_for_organismprop( $self->{db}, $genus, $species, $fpr_type{$f} , $ph{pub} );
	      $rn+=@results;  
	      if($rn==0){
		  print STDERR "ERROR: there is no previous record for $f\n";
	      }
	      else{
		  foreach my $t (@results) {
		      my $num = get_organismprop_pub_nums( $self->{db}, $t->{fp_id} );
		      if ( $num == 1 ) {
			  $out .=
			      delete_organismprop( $doc, $t->{rank}, $genus, $species,
						   $fpr_type{$f});
		      }
		      elsif ( $num > 1 ) {
			  $out .=
			      delete_organismprop_pub( $doc, $genus, $species,
						   $fpr_type{$f}, $t->{rank}, $ph{pub} );
		      }
		      else {
			  print STDERR "something Wrong, please validate first\n";
		      }
		  }
	      }
	  }
	  if (defined($ph{$f}) && $ph{$f} ne '' ) { 
	      my @items = split( /\n/, $ph{$f} );
	      foreach my $item (@items) {
		  $item =~ s/^\s+//;
		  $item =~ s/\s+$//;

		  $out .=
		      write_organismprop( $self->{db}, $doc, $genus, $species, $item,
				     $fpr_type{$f}, $ph{pub});
	      }

	  }
      }
      elsif ($f eq 'SP6'){
	  print STDERR "CHECK: first use of  $f \n";
	  if( exists($ph{"$f.upd"}) && $ph{ "$f.upd" } eq 'c' ) {
	      print STDERR "Action Items: !c log $unique $f $ph{pub}\n";
	      print STDERR "CHECK: first use of  $f !c \n";
	      my $num = get_num_organismprop( $self->{db},$genus,$species,$fpr_type{$f},$ph{pub});
	      if($num != 1){
		  print STDERR "ERROR: Cannot get organismprop for $genus, $species, $ph{pub} $f\n"; 
	      }
	      else{
		  $out .=
		      delete_organismprop( $doc, 0, $genus, $species,$fpr_type{$f} );
	      }
	  }
	  if (defined($ph{$f}) && $ph{$f} ne '' ) { 
	      my $item = $ph{SP6};
	      my $rank = 0;
	      my $dbname = validate_dbname($self->{db},$item);
	      if ($dbname ne $item){
		  print STDERR "ERROR, could not get db.name for $ph{SP6}\n";
	      }
	      else{
		  my $num = check_sp6_organismprop($self->{db}, $genus, $species, $fpr_type{$f});
		  if($num > 0){
		      print STDERR "ERROR: $ph{$f} has an organismprop in chado\n";
		  }
		  else{
		      $out .=
			  write_organismprop( $self->{db}, $doc, $genus, $species, $item,
					      $fpr_type{$f}, $ph{pub}, $rank);
		  }
	      }
	  }
      }
  }
  $doc->dispose();
  return $out;
}

=head2 $pro->write_species(%ph)

  separate the id generation and lookup from the other curation field to make two-stage parsing possible

=cut
  sub write_species{
    my $self    = shift;
    my $tihash  = {@_};
    my %ph      = %$tihash;
    my $unique  = '';
    my $flag    = 0;
    my $feature = '';
    my $genus = '';
    my $species = '';
    my $abbrev = '';
    my $common = '';
    my $out = '';
   
    print STDERR "CHECK: first use of Species proforma\n";
    if ( $ph{SP1g} eq 'y') {
#Must have organism entry in chado 
       ($genus, $species) = get_organism_ukeys($db,$ph{SP1a}, $ph{SP1b});
       if($genus ne $ph{SP1a} && $species ne $ph{SP1b}){
	   print STDERR "ERROR, could not get organism for $ph{SP1a}, $ph{SP1b}\n";
       }
       $unique = $genus.'_'.$species;
       if(exists($fbids{$ph{SP1a}.'_'.$ph{SP1b}})){
	   my $check=$fbids{$ph{SP1a}.'_'.$ph{SP1b}};
	   if($unique ne $check){
	       print STDERR "ERROR: $check and $unique are not same for $ph{SP1a}._.$ph{SP1b}\n";
	   }
       }
       $feature = create_ch_organism(
	   doc=> $doc,
	   genus => $genus,
	   species => $species,
	   macro_id   => $unique,
	   );

       if(exists($ph{SP2}) && $ph{SP2} ne ""){
	   my $num = check_abbrev($db,$genus,$species);
	   if($num == 0 ){
	       $abbrev = $ph{SP2};
	       my $n=create_doc_element($doc,'abbreviation',$abbrev);
	       $feature->appendChild($n);
	       print STDERR "DEBUG: SP2 abbreviation $ph{SP2} added\n";  
	   }
	   elsif($num > 0 ){
	       (my $g, my $s) = get_organism_by_abbrev($db,$ph{SP2});
	       if( $g eq $genus && $s eq $species){
		  print STDERR "Warn: abbreviation exists for $genus, $species ... Skip\n"; 
	       }
	       else{
		   print STDERR "ERROR: abbreviation $ph{SP2} assigned to organism $g $s\n";
	       } 
	   }
       } 
       if(exists($ph{SP3a}) && $ph{SP3a} ne ""){
	   my $val = "";
	   if(exists($ph{SP3b}) && $ph{SP3b} eq "y"){
	       my $n=create_doc_element($doc,'common_name',$ph{SP3a});
	       $feature->appendChild($n);
	       print STDERR "DEBUG: SP3a common_name changed for $genus , $species $ph{SP3a}\n";
	   }
	   else{
	       $val = check_common_name($db,$genus,$species,$ph{SP3a});
	       if($val eq "0"){	  
		   my $n=create_doc_element($doc,'common_name',$ph{SP3a});
		   $feature->appendChild($n);
	       } 
	       else{
		   print STDERR "ERROR: SP3a common_name $val exists for $genus , $species use SP3b to change\n";
	       }
	   }
       } 

       $out.=dom_toString($feature);
       $fbids{$ph{SP1a}.'_'.$ph{SP1b}} = $unique;
    }
    else {
      my $va= validate_new_organism($db, $ph{SP1a}, $ph{SP1b} );
      if($va == 0){
	if(exists($fbids{$ph{SP1a}.'_'.$ph{SP1b}})){
	 $flag = 1;
	}
      }
      print STDERR "CHECK: Check if new flag = $flag for Species $ph{SP1a} $ph{SP1b}\n";       
      if ( $flag == 0 ) {
	  print STDERR "Action Items: new Species $ph{SP1a} $ph{SP1b}\n";
	  $genus = $ph{SP1a};
	  $species = $ph{SP1b};
	  if(exists($ph{SP2}) && $ph{SP2} ne ""){
	    $abbrev=$ph{SP2};  
	  }
	  else{
	      print STDERR "ERROR: new organism $genus $species abbreviation SP2 required\n"; 
	  }
	  $feature = create_ch_organism(doc => $doc,
					   genus => $genus,
					   species => $species,
					   abbreviation => $abbrev,
					   macro_id   => $genus.'_'.$species,
					  );

	  if(exists($ph{SP3a}) && $ph{SP3a} ne ""){
	      my $n=create_doc_element($doc,'common_name',$ph{SP3a});
	      $feature->appendChild($n);
	  }
	  $out.=dom_toString($feature);
      }
      else{
	  print STDERR "ERROR, name $ph{SP1a} $ph{SP1b} has been used in this load\n";
      }
      $fbids{ $ph{SP1a}.'_'.$ph{SP1b}} = $genus.'_'.$species;
      $unique = $genus.'_'.$species;
    }   
    $doc->dispose();
     print STDERR "CHECK, unique = $unique $ph{SP1a} $ph{SP1b}\n";
 
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
 
    print STDERR "validating Species $tival{SP1a}, $tival{SP1b}\n";
    

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
FlyBase::Proforma::TI;
FlyBase::Proforma::TP;
FlyBase::Proforma::TE;
FlyBase::Proforma::Pub;
FlyBase::Proforma::Balancer;
FlyBase::Proforma::Aberr;
FlyBase::Proforma::Gene;
FlyBase::Proforma::Allele;
FlyBase::Proforma::MultiPub;
FlyBase::Proforma::Util;
FlyBase::Proforma::Feature;
FlyBase::Proforma::SF;
FlyBase::Proforma::Library;
FlyBase::Proforma::Cell_line;
FlyBase::Proforma::Interaction;
FlyBase::Proforma::Strain;
FlyBase::Proforma::DB;
FlyBase::Proforma::HH;
FlyBase::Proforma::GG;
FlyBase::Proforma::Species;
XML::Xort

=head1 Proforma

! SPECIES PROFORMA     Version 3:  18 Dec 2015
! SP1a. Genus to use in FlyBase (organism.genus)     :
! SP1b. Species to use in FlyBase (organism.species) :
! SP1g. Is SP1a+SP1b already in FlyBase? (y/n) :
! SP2. Abbreviation to use in FlyBase (organism.abbreviation) :
! SP3a. Common name (organism.common_name) :stony coral
! SP3b. Action - change existing organism.common_name? (blank/y) :
! SP4. Taxon ID :
! SP5. Taxgroup [SoftCV] :
! SP6. Official database for species :

=head1 AUTHOR

Haiyan Zhang, E<lt>haiyan@morgan.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
