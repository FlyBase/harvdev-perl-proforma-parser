package FlyBase::Proforma::DB;

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

our @EXPORT = qw( process validate

);

our $VERSION = '0.01';
my $ver=2.4;
# Preloaded methods go here.

=head1 NAME

FlyBase::Proforma::DB - Perl module for parsing the FlyBase
DB  proforma version 1.1, June 27, 2013.

See the bottom for the proforma
                         
=head1 SYNOPSIS

  use FlyBase::Proforma::DB;
  use DBI;
  
  my $mdbh=DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";
  my %ph=(F1a=>'mir-1', F4=>'mir-1',....);
  ###!c field implemented as '$fieldname.upd=>'c'' eg. 'AB5a.upd'=>'c'
   
  #params db is manditory, debug and validate is optional
  my $pro=FlyBase::proforma::DB->new(db=>$mdbh);
  $pro->validate(%ph);
  my $chadoxml = $pro->process(%ph);
  
  # or

  my $pro=FlyBase::Proforma::DB->new(db=>$mdbh,debug=>1,validate=>1);
  my $chadoxml_string=$pro->process(%ph);

=head1 DESCRIPTION

FlyBase::Proforma::DB is a perl module for parsing FlyBase
DB proforma and write the result as chadoxml. it is required
to connected to a chado database for validating and processing.
The module also requires FlyBase::Proforma::Writechado and
FlyBase::Proforma::Util. The results can be loaded into a chado
database by XML::Xort.

=head2 EXPORT

  process
  validate

=cut

our %ti_fpr_type = (
    'DB1a',  'name', # db.name
    'DB1g',  'current', # db.name exists
    'DB2a', 'description', # db.description
    'DB2b', '', # change db.description
    'DB3a',  'url', # db.url
    'DB3c',  'url', # change db.url
    'DB3b',  'urlprefix', # db.urlprefix
    'DB3d',  'urlprefix', # change db.urlprefix
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
  my $flag    = 0;
  my $out = '';

  if ( exists( $self->{debug} ) && $self->{debug} == 1 ) {
    foreach my $key ( keys %ph ) {
      print STDERR "$key, $ph{$key}\n";
    }
  }
  print STDERR "processing DATABASE $ph{DB1a}...\n";
  if ( exists( $self->{v} ) && $self->{v} == 1 ) {
    $self->validate($tihash);
  }
  if(exists($fbids{$ph{DB1a}})){
#    print STDERR "unique = $unique in fbids\n";
    $unique=$fbids{$ph{DB1a}};
  }
  else{
#    print STDERR "else calling write_db_table from process\n";
    ($unique, $out)=$self->write_db_table($tihash);
  }
  if(exists($fbcheck{$ph{DB1a}}{$ph{pub}})){
    print STDERR "Warning: $ph{DB1a} $ph{pub} exists in a previous proforma\n";
  }
  $fbcheck{$ph{DB1a}}{$ph{pub}}=1;

  ##Process other field in Trangenic Insertion proforma
  foreach my $f ( keys %ph ) {
    print  STDERR "Process other fields $f\n";
  }
  $doc->dispose();
  return $out;

}

=head2 $pro->write_db_table(%ph)

  separate the id generation and lookup from the other curation field to make two-stage parsing possible

=cut

  sub write_db_table{
    my $self    = shift;
    my $tihash  = {@_};
    my %ph      = %$tihash;
    my $unique  = "";
    my $flag    = 0;
    my $feature = '';
    my $description = "";
    my $url = "";
    my $urlprefix = "";
    my $out = '';
   
    print STDERR "CHECK: first use of DB proforma\n";
    if ( $ph{DB1g} eq 'y') {   
      ($unique)=validate_dbname($db,$ph{DB1a});
      if($unique ne $ph{DB1a}){
	print STDERR "ERROR, could not get db.name for $ph{DB1a}\n";
      }
      else{
	$feature = create_ch_db(
				doc        => $doc,
				name => $unique,
				macro_id   => $unique,
			       );

	if(exists($ph{DB2a}) && $ph{DB2a} ne ""){
	    if(exists($ph{DB2b}) && $ph{DB2b} eq "y"){
		my $n=create_doc_element($doc,'description',$ph{DB2a});
		$feature->appendChild($n);
		print STDERR "DEBUG: DB2a description changed for $ph{DB1a} $ph{DB2a}\n";
	    }
	    else{
		my $val = validate_db_description($db,$ph{DB1a});
		if($val == 0){	  
		    my $n=create_doc_element($doc,'description',$ph{DB2a});
		    $feature->appendChild($n);
		} 
		else{
		    print STDERR "ERROR: DB2a description exists for $ph{DB1a}\n";
		}
	    }
	} 
	if(exists($ph{DB3a}) && $ph{DB3a} ne ""){
	    if(exists($ph{DB3c}) && $ph{DB3c} eq "y"){
		my $n=create_doc_element($doc,'url',$ph{DB3a});
		$feature->appendChild($n);
		print STDERR "DEBUG: DB3a url changed for $ph{DB1a} $ph{DB3a}\n";
	    }
	    else{
		my $val = validate_db_url($db,$ph{DB1a});
		if($val == 0){
		    my $n=create_doc_element($doc,'url',$ph{DB3a});
		    $feature->appendChild($n);
		} 
		else{
		    print STDERR "ERROR: DB3a url exists for $ph{DB1a}\n";
		}
	    }
	}
	if(exists($ph{DB3b}) && $ph{DB3b} ne ""){
	    if(exists($ph{DB3d}) && $ph{DB3d} eq "y"){
		my $n=create_doc_element($doc,'urlprefix',$ph{DB3b});
		$feature->appendChild($n);
		print STDERR "DEBUG: D3b urlprefix changed for $ph{DB1a} $ph{DB3b}\n";
	    }
	    else{
		my $val = validate_db_urlprefix($db,$ph{DB1a});
		if($val == 0){
		    my $n=create_doc_element($doc,'urlprefix',$ph{DB3b});
		    $feature->appendChild($n);
		} 
		else{
		    print STDERR "ERROR: DB3b urlprefix exists for $ph{DB1a}\n";
		}
	    }
	} 
	if(exists($fbids{$ph{DB1a}})){
	  my $check=$fbids{$ph{DB1a}};
	  if($unique ne $check){
	    print STDERR "ERROR: $check and $unique are not same for $ph{DB1a}\n"; 
	  }
	}
	$fbids{ $ph{DB1a} } = $unique;
	$out.=dom_toString($feature);
      }
    }
    else {
      my $va= validate_new_dbname($db, $ph{DB1a});
      if($va == 0){
	if(exists($fbids{ $ph{DB1a}})){
	  $flag = 1;
	}
	print STDERR "CHECK: Check if new flag = $flag for table db $ph{DB1a}\n";       
	if ( $flag == 0 ) {
	  $unique = $ph{DB1a};
	  print STDERR "Action Items: create new name in table db $ph{DB1a}\n";
	  if(exists($ph{DB2a}) && $ph{DB2a} ne ""){
	    $description=$ph{DB2a};  
	  }
	  else{
	    print STDERR "WARN: DB2a Description should be filled in if abbreviation $ph{DB1a}\n";	    
	  }
	  if(exists($ph{DB3a}) && $ph{DB3a} ne ""){
	    $url=$ph{DB3a};  
	  }
	  else{
	    print STDERR "ERROR: DB3a required for a new record $ph{DB1a}\n";
	  }
	  if(exists($ph{DB3b}) && $ph{DB3b} ne ""){
	    $urlprefix=$ph{DB3b};  
	  }
	  else{
	    print STDERR "WARN: DB3b required if dbxref accession linksto this db are desired $ph{DB1a}\n";
	  }
	  $feature = create_ch_db(doc=> $doc,
				  name => $unique,
				  description => $description,
				  url => $url,
                                  urlprefix => $urlprefix,
				  macro_id   => $unique,
				 );
	  $out.=dom_toString($feature);
	}
	else{
	  print STDERR "ERROR, name $ph{DB1a} has been used in this load\n";
	}
	$fbids{ $ph{DB1a} } = $unique;
      }
      else{
	  print STDERR "ERROR, db.name $ph{DB1a} has been used in the database exiting ...\n";
	  exit();
      }
    } 
    $doc->dispose();
    return ($out, $unique);

  }
  

=head1 METHODS

=head2 $pro->process(%ph)
	
	Process each element in the hash table and returns a string of chadoxml.
	if there is a Aberration Proforma under which the Genotype Variant
	Proforma hangs, make feature_relationship variant_of object_id FBab

=cut

=head2 $pro->validate(%ph)

   validate the following:
   1. If DB1g is n, DB1a should not be in db table.
   2. If DB1g is n, DB3a should be filled in.

=cut

sub validate {
    my $self   = shift;
    my $tihash = {@_};
    my %tival  = %$tihash;

    my $v_unique = '';

    print STDERR "Validating DB ", $tival{DB1a}, " ....\n";

    if(exists($tival{DB1a}) && ($tival{DB1g} ne 'y')){
      my $va=validate_new_dbname($db, $tival{DB1a}); 
      if($va == 1){
	print STDERR "ERROR, db.name $tival{DB1a} has been used in the database\n";	
      }
    }
    if ( exists( $fbids{$tival{DB1a}})){
        $v_unique=$fbids{$tival{DB1a}};    
    }
    else{
        print STDERR "ERROR: could not validate $tival{DB1a}\n";
        return;
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
! DATABASE PROFORMA   Version 1.1   Jun 12 2013
! DB1a. Symbol (db.name)			:<database name>
! DB1g. Is DB1a the current symbol of a gene in FlyBase? (y/n)  :<y/n>
! DB2a. Description (db.description)	:<database description>
! DB3a. Database URL (db.url)			:<database url>
! DB3b. Accession URL (db.urlprefix)	:<generic accession url>
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

=head1 AUTHOR

Kathleen Falls, E<lt>falls@morgan.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
