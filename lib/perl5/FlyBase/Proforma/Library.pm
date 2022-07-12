package FlyBase::Proforma::Library;

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

FlyBase::Proforma::Library - Perl module for parsing the FlyBase
Library/Collection  proforma version 2.1, Mar, 2008.

See the bottom for the proforma
                         
=head1 SYNOPSIS

  use FlyBase::Proforma::Library;
  use DBI;
  
  my $mdbh=DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";
  my %ph=(LC1a=>'AT',....);
  ###!c field implemented as '$fieldname.upd=>'c'' eg. 'LC6.upd'=>'c'
   
  #params db is manditory, debug and validate is optional
  my $pro=FlyBase::proforma::Library->new(db=>$mdbh);
  $pro->validate(%ph);
  my $chadoxml = $pro->process(%ph);
  
  # or

  my $pro=FlyBase::Proforma::Library->new(db=>$mdbh,debug=>1,validate=>1);
  my $chadoxml_string=$pro->process(%ph);

=head1 DESCRIPTION

FlyBase::Proforma::Library is a perl module for parsing FlyBase
Library/Collection proforma and write the result as chadoxml. It is required
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
    'LC1f', 'uniquename',
    'LC1a', 'symbol',
    'LC1b', 'symbol',  ##library_synonym, pub=this pub
    'LC1d', 'nickname', ## library_synonym
    'LC6g', 'fullname', ## NEW Dataset title library_synonym
    'LC6a', 'description',  ##libraryprop free text single entry per pub
    'LC2a', 'FlyBase miscellaneous CV', ## NEW Type [CV]library.typed_id cvtermprop.value dataset_entity_type, type webcv
    'LC2b', 'FlyBase miscellaneous CV', ## NEW Type of dataset data [CV]  FlyBase miscellaneous CV library_cvterm cvterm depends on type_id LC2a
    'LC3',  'belongs_to',  ## library_relationship LC3 type_id project    
    'LC14a', 'assay_of', ## NEW library_relationship LC14a type_id biosample
    'LC14b', 'analysis_of', ## NEW library_relationship LC14b type_id result
    'LC14c', 'uses_reagent', ## NEW library_relationship  LC14c type_id project,collection
    'LC14d', 'technical_reference_is', ## NEW library_relationship LC14d type_id project,assay
    'LC14e', 'biological_reference_is', ## NEW library_relationship LC14e type_id project,assay
    'LC14f', 'replaced_by', ## NEW library_relationship 
    'LC14g', 'genome_reference_is', ## NEW library_relationship 
    'LC14h', 'fb_ann', ## NEW libraryprop [free text]
    'LC3a', 'rename',  ##action items
    'LC3b', 'merge',  ##action items
    'LC3c', 'delete',  ## action items
    'LC3d', 'dissociated_FBrf', ## action items
    'LC3e','library', ## NEW remove all library_relationship from LC1f/LC1a and LC3e

    'LC13a', 'cellular_component', ## NEW Key GO term(s) - Cellular Component (term ; ID)
    'LC13b', 'molecular_function', ## NEW Key GO term(s) - Molecular Function (term ; ID)
    'LC13c', 'biological_process', ## NEW Key GO term(s) - Biological Process (term ; ID)
    'LC13d', 'SO', ## NEW Key SO term(s) [CV]
    
    'LC4a', 'organism.abbreviation',  ###library.organism_id
    'LC4i', 'organism.abbreviation', ## NEW Other species of interest [CV] need new organism_library table
    'LC4h', 'experimental_attribute',  ### library_strain library_strainprop
    'LC4b', 'strain',  ### libraryprop free text
    'LC4f',  'genotype',  ##libraryprop
    'LC4g',  'library_expression',  ### library_expression    
    
    'LC4j', 'FlyBase anatomy CV', ## NEW Tissue of interest [CV] FBbt (term ; ID)
    'LC4k', 'FlyBase development CV', ## NEW Stage of interest [CV] FBdv (term ; ID)
    
    'LC4e', 'experimental_attribute',  ###cell_line_library, cell_line_libraryprop 
    
    'LC12a', 'feature',  ##library_feature library_featureprop
    'LC12b', 'experimental_design type',  ## Type library_featureprop cv for type_id
    'LC12c', '', ## NEW Action - delete the dataset-feature relationship y/blank
    
    'LC6d', 'members_in_db',  ##libraryprop
    'LC6e', 'number_in_collection',  ##libraryprop
    'LC6f',  'number_collection_comment', ##libraryprop
    
    'LC11m', 'FlyBase miscellaneous CV', ## FlyBase miscellaneous CV library_cvtermprop type = lc11mtype
    'LC11j', 'secondary_analysis', ## NEW libraryprop (y/blank

    'LC11a', 'source_prep', ##libraryprop
    'LC6b', 'protocol',    ##libraryprop
    'LC11c', 'mode_of_assay', ##libraryprop
    'LC11e', 'data_analysis', ##libraryprop  
    'LC7a', 'data_type',   ###libraryprop      
    
    'LC7f', 'deposited_files', ## NEW Associated files, archived at ftp site [SoftCV] replaces LC7b

    'LC7c', 'URL',   ##library_dbxref, library_dbxrefprop
    'LC99a', 'data_link',  ##library_dbxref, library_dbxrefprop with b,c,d
    'LC8a', 'owner',  ### library_dbxref, library_dbxrefprop
    'LC8c', 'owner',  ##libraryprop
    'LC8b', 'data_origin',###library_dbxref, library_dbxrefprop
    'LC8d', 'data_origin', ##libraryprop
    'LC9',  'comment',
    'LC10', 'internalnotes',
    'LC9a', 'structured_table', ## NEW Structured table [SoftCV]????
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

    if ( exists( $self->{debug} ) && $self->{debug} == 1 ) {
        foreach my $key ( keys %ph ) {
            print STDERR "$key, $ph{$key}\n";
        }
    }
    print STDERR "processing library.pro $ph{LC1a}...\n";
    if ( exists( $self->{v} ) && $self->{v} == 1 ) {
        $self->validate($tihash);
    }
    if(exists($fbids{$ph{LC1a}})){
        $unique=$fbids{$ph{LC1a}};
    }
    else{
        ($unique, $out)=$self->write_library($tihash);
    }
    if(exists($fbcheck{$ph{LC1a}}{$ph{pub}})){
      print STDERR "Warning: $ph{LC1a} $ph{pub} exists in a previous proforma\n";
    }
    $fbcheck{$ph{LC1a}}{$ph{pub}}=1;
    if(!exists($ph{LC3d})){
      print STDERR "Action Items: Library $unique == $ph{LC1a} with pub $ph{pub}\n"; 
        my $f_p = create_ch_library_pub(
        doc        => $doc,
        library_id => $unique,
        pub_id     => $ph{pub}
    );
    $out .= dom_toString($f_p);
    $f_p->dispose();
    }    
    else{
            $out .= dissociate_with_pub_fromlib( $self->{db}, $unique, $ph{pub} );
            print STDERR "Action Items: dissociate $ph{LC1a} with $ph{pub}\n";
            return $out;
        }
    ##Process other field in Trangenic Insertion proforma
    foreach my $f ( keys %ph ) {

       # print STDERR $f,"\n";
        if (   $f eq 'LC1b'
            || $f eq 'LC1d')
        {  
         if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
            print STDERR "CHECK: !c implementation for $f\n";
            print STDERR "Action Items: !c log,$ph{LC1a} $f  $ph{pub}\n";
              my $t=$f;
              $t=~s/LC1//;
              my $s_pub='unattributed';
              if($t eq 'b'){
                $s_pub=$ph{pub};
              }
              my $current='';
              if($t eq 'c'){
                $current='f';
              }
              $out .= delete_library_synonym( $self->{db}, $doc, $unique, $s_pub, $fpr_type{$f}, $current );
             
            }
	 if(defined ($ph{$f}) && $ph{$f} ne ''){
	   my @items = split( /\n/, $ph{$f} );
            foreach my $item (@items) {
                $item =~ s/^\s+//;
                $item =~ s/\s+$//;
                my $t = $f;
                $t =~ s/LC1//;
                    my $tt     = $t;
                    my $s_type = $fpr_type{$f};
                    my $s_pub  = '';
                    if ( $t eq 'b' ) {
                        $s_pub = $ph{pub};
                        $tt    = 'b';
                        if($t eq 'b' && $item eq $ph{LC1a} ){
                            $tt='a';
                        }
                    }
						  elsif($t eq 'd'){
						   $s_pub=$ph{pub};
						   $tt='a';	
						  }
                    else {
                        $s_pub = 'unattributed';    
                    }
                    $out .=
                      write_library_synonyms( $doc, $unique, $item, $tt, $s_pub,
                        $s_type );
                }
	 }
        }

        if (   $f eq 'LC6g')
        {  
         if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
            print STDERR "CHECK: !c implementation for $f\n";
            print STDERR "Action Items: !c log, $ph{LC1a} $f $ph{pub}\n";
#	    my $s_pub='unattributed';
	    my $s_pub=$ph{pub};
	    my $current='y';
	    $out .= delete_library_synonym( $self->{db}, $doc, $unique, $s_pub, $fpr_type{$f}, $current );
	 }
	 if(defined ($ph{$f}) && $ph{$f} ne ''){
	     if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
		 my $s_type = $fpr_type{$f};
		 my $s_pub  = '';
		 my $tt = 'a';
		 $s_pub = $ph{pub};
		 $out .=
		     write_library_synonyms( $doc, $unique, $ph{$f}, $tt, $s_pub,
					 $s_type );
	     }
	     else{
		 #new function
		 my $t = check_library_synonym_for_title( $self->{db},
							   $unique, 'fullname');
		 if ($t == 0){
		     my $s_type = $fpr_type{$f};
		     my $s_pub  = '';
		     my $tt = 'a';
		     $s_pub = $ph{pub};
		     $out .=
			 write_library_synonyms( $doc, $unique, $ph{$f}, $tt, $s_pub,
						 $s_type );		     
		 }
		 else{
		     print STDERR "ERROR: title exists for $ph{LC1a}, $f\n";
		 }
	     }
	 }
	}

	elsif ( $f eq 'LC2b' ) {
	    if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
		print STDERR "Action Items: !c log,$ph{LC2b} $f  $ph{pub}\n";
		my @results = get_cvterm_for_library_cvterm_withprop(
                    $self->{db}, $unique, $fpr_type{$f},$ph{pub},'lc2btype');
		if(@results==0){
		    print STDERR "ERROR: no previous record found for $ph{LC2b} $f \n";
		}
		foreach my $item (@results) {
		    my $feat_cvterm = create_ch_library_cvterm(
                                                           doc        => $doc,
                                                           library_id => $unique,
                                                           cvterm_id  => create_ch_cvterm(
                                                                                          doc  => $doc,
                                                                                          cv   => $fpr_type{$f},
                                                                                          name => $item
                                                                                         ),
                                                           pub_id => $ph{pub}
                                                          );
		    $feat_cvterm->setAttribute( 'op', 'delete' );
		    $out .= dom_toString($feat_cvterm);
		    $feat_cvterm->dispose();
		}
	    }
	    if(defined ($ph{LC2b} ) && $ph{LC2b}ne ''){
		if ( exists( $ph{LC1f} ) && $ph{LC1f} ne 'new') { 	
		    ( $genus, $species, $type ) =
			get_lib_ukeys_by_uname( $self->{db}, $ph{LC1f} );
		    if ( $genus eq '0' ) {
			print STDERR "ERROR: could not find record for $ph{LC1f}\n";
			exit(0);
		    }
		}
		else{
#		    $type = $ph{LC2a};
                    my $go = "";
                    my $go_id = "";
		    my $item = $ph{LC2a};
                    if ( $item =~ /(.*)\s;\s(.*)/ ) {
                        $go    = $1;
                        $go_id = $2;
                    }
                    $go    =~ s/^\s+//;
                    $go    =~ s/\s+$//;
                    $go_id =~ s/^\s+//;
                    $go_id =~ s/\s+$//;
                    validate_go( $self->{db}, $go, $go_id, $fpr_type{'LC2a'} );
		    $type = $go;
		}
		my $termcv = "";
		if($type eq "reagent collection"){
		    $termcv = "reagent_collection_type";
		}
		else{
		    $termcv = $type."_type";
		}
		my @items = split( /\n/, $ph{$f} );
		foreach my $item (@items) {
                    my $go = "";
                    my $go_id = "";
		    $item =~ s/^\s+//;
		    $item =~ s/\s+$//;
		    my $term = "";
                    if ( $item =~ /(.*)\s;\s(.*)/ ) {
                        $go    = $1;
                        $go_id = $2;
                    }
                    $go    =~ s/^\s+//;
                    $go    =~ s/\s+$//;
                    $go_id =~ s/^\s+//;
                    $go_id =~ s/\s+$//;
		    validate_go( $self->{db}, $go, $go_id, $fpr_type{$f});
		    
		    my $term_id = get_cvterm_by_webcv($self->{db},$go,$termcv);
		    if (defined ($term_id)){
			$term=$go;
			my $f_cvterm = create_ch_library_cvterm(
			    doc        => $doc,
			    library_id => $unique,
			    cvterm_id  => create_ch_cvterm(
				doc  => $doc,
				cv   => $fpr_type{$f},
				name => $term,
			    ),
			    pub_id => $ph{pub},
			    );

			my $fcvprop = create_ch_library_cvtermprop(
			    doc  => $doc,
			    type_id => create_ch_cvterm(doc=>$doc,
						name=>'lc2btype',
						cv=>'library_cvtermprop type'),
			    );
			$f_cvterm->appendChild($fcvprop);
			$out .= dom_toString($f_cvterm);
		    }
		    else{
			print STDERR "ERROR: $item is not a valid cvterm for $type $f\n"; 
		    } 
		}
	    }
	}
	elsif (  $f eq 'LC4i') {
	    if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
		print STDERR "Action Items: !c log,$ph{LC4i} $f\n";
        my @results = get_organism_for_organism_library(
	    $self->{db}, $unique);
		if(@results==0){
		    print STDERR "ERROR: no previous record found for $ph{LC1a} $f \n";
		}
		foreach my $item (@results) {
		    my ($og,$os) = split(/_/,$item); 
		    my $olib = create_ch_organism_library(
			doc        => $doc,
			library_id => $unique,
			organism_id  => create_ch_organism(
			    doc  => $doc,
			    genus   => $og,
			    species => $os,
			),
		    );
          $olib->setAttribute( 'op', 'delete' );
          $out .= dom_toString($olib);
          $olib->dispose();
        }
      }
	    if (defined($ph{$f}) && $ph{$f} ne '' ) { 
		my @items = split( /\n/, $ph{$f} );
		foreach my $item (@items) {
		    $item =~ s/^\s+//;
		    $item =~ s/\s+$//;
		    my ( $og, $os ) =
			get_organism_by_abbrev( $self->{db}, $item );
		    my $olib = create_ch_organism_library(
			doc        => $doc,
			library_id => $unique,
			organism_id  => create_ch_organism(
			    doc  => $doc,
			    genus   => $og,
			    species => $os,
			),
			);
		    $out .= dom_toString($olib);
		    $olib->dispose();
		}
	    }
	}

	elsif ( $f eq 'LC11m' ) {
	    if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
		print STDERR "Action Items: !c log,$ph{LC11m} $f  $ph{pub}\n";
		my @results = get_cvterm_for_library_cvterm_withprop(
                    $self->{db}, $unique, $fpr_type{$f},$ph{pub},'lc11mtype');
		if(@results==0){
		    print STDERR "ERROR: no previous record found for $ph{LC11m} $f \n";
		}
		foreach my $item (@results) {
		    my $cv = "";
		    $cv = get_cv_by_cvterm($self->{db},$item);
		    if($cv ne ""){
			my $feat_cvterm = create_ch_library_cvterm(
                                                           doc        => $doc,
                                                           library_id => $unique,
                                                           cvterm_id  => create_ch_cvterm(
                                                                                          doc  => $doc,
                                                                                          cv   => $cv,
                                                                                          name => $item
                                                                                         ),
                                                           pub_id => $ph{pub}
                                                          );
			$feat_cvterm->setAttribute( 'op', 'delete' );
			$out .= dom_toString($feat_cvterm);
			$feat_cvterm->dispose();
		    }
		    else{
			print STDERR "ERROR: Can't find CV for $item $f $ph{LC1a}\n";
		    }
		}
	    }
	    if(defined ($ph{LC11m} ) && $ph{LC11m}ne ''){
		if ( exists( $ph{LC1f} ) && $ph{LC1f} ne 'new') { 	
		    ( $genus, $species, $type ) =
			get_lib_ukeys_by_uname( $self->{db}, $ph{LC1f} );
		    if ( $genus eq '0' ) {
			print STDERR "ERROR: could not find record for $ph{LC1f}\n";
			exit(0);
		    }
		}
		else{
#		    $type = $ph{LC2a};
                    my $go = "";
                    my $go_id = "";
		    my $item = $ph{LC2a};
                    if ( $item =~ /(.*)\s;\s(.*)/ ) {
                        $go    = $1;
                        $go_id = $2;
                    }
                    $go    =~ s/^\s+//;
                    $go    =~ s/\s+$//;
                    $go_id =~ s/^\s+//;
                    $go_id =~ s/\s+$//;
                    validate_go( $self->{db}, $go, $go_id, $fpr_type{'LC2a'} );
		    $type = $go;
		}
		my @items = split( /\n/, $ph{$f} );
		foreach my $item (@items) {
                    my $go = "";
                    my $go_id = "";
		    $item =~ s/^\s+//;
		    $item =~ s/\s+$//;
                    my $term = "";
                    if ( $item =~ /(.*)\s;\s(.*)/ ) {
                        $go    = $1;
                        $go_id = $2;
                    }
                    $go    =~ s/^\s+//;
                    $go    =~ s/\s+$//;
                    $go_id =~ s/^\s+//;
                    $go_id =~ s/\s+$//;
                    validate_go( $self->{db}, $go, $go_id, $fpr_type{$f});
                    my $value = get_webcv_for_cvterm_cv($self->{db},$go,$fpr_type{$f});
		    my $val_ok = 0;
#		    if(($type eq "project" ) && ($value eq "project_attribute" ||  $value eq "biosample_attribute" || $value eq "assay_attribute" || $value eq "result_attribute")){
		    if(($type eq "project" ) && ($value eq "assay_attribute" || $value eq "assay_type" || $value eq "biosample_attribute" || $value eq "biosample_type" || $value eq "dataset_entity_type" || $value eq "project_attribute" || $value eq "project_type" || $value eq "reagent collection_type" || $value eq "result_attribute" || $value eq "result_type")){
			$val_ok = 1;
		    }
		    if(($type eq "biosample" ) && ($value eq "biosample_attribute" )){
			$val_ok = 1;
		    }
		    if(($type eq "assay" ) && ($value eq "assay_attribute" )){
			$val_ok = 1;
		    }
		    if(($type eq "result" ) && ($value eq "result_attribute" )){
			$val_ok = 1;
		    }
		    if(($type eq "reagent collection" ) && ($value eq "assay_attribute" || $value eq "biosample_attribute")){
			$val_ok = 1;
		    }
		    if($val_ok){
			my $f_cvterm = create_ch_library_cvterm(
			    doc        => $doc,
			    library_id => $unique,
			    cvterm_id  => create_ch_cvterm(
				doc  => $doc,
				cv   => $fpr_type{$f},
				name => $go,
			    ),
			    pub_id => $ph{pub},
			    );

			my $fcvprop = create_ch_library_cvtermprop(
			    doc  => $doc,
			    type_id => create_ch_cvterm(doc=>$doc,
						name=>'lc11mtype',
						cv=>'library_cvtermprop type'),
			    );
			$f_cvterm->appendChild($fcvprop);
			$out .= dom_toString($f_cvterm);
		    }
		    else{
			print STDERR "ERROR: $item is not a valid cvterm for $f $ph{LC1a} $type\n"; 
		    } 
		}
	    }
	}

        elsif($f eq 'LC3'
	      || $f eq 'LC14a'
	      || $f eq 'LC14b'
	      || $f eq 'LC14c'
	    )
	{
            print STDERR "CHECK:  use of $f - multiple entries\n";
            my $object  = 'object_id';
            my $subject = 'subject_id';
	    if ( exists( $ph{"$f.upd"} ) and $ph{"$f.upd"} eq 'c' ) {
		print STDERR "ERROR: !c NOT ALLOWED $ph{LC1a} $f $ph{pub}\n";
            }
            if ( defined($ph{$f}) && $ph{$f} ne '') {
		my @items = split( /\n/, $ph{$f} );
		foreach my $item (@items) {
		    $item =~ s/^\s+//;
		    $item =~ s/\s+$//;
			my ($uname, $og,$os,$otype);
		    
            my $oktype = 0;
			if ( exists( $fbids{$item} ) ) {
				  $uname = $fbids{$item};
				  # Unable to get type so cvannot check when using fbids.
                  $oktype = 1;
            }
			else{
				$uname, $og,$os,$otype = get_lib_ukeys_by_name($self->{db},$item);
			}
		    if ( $uname eq '0'  || $uname eq '2') {
			       print STDERR "ERROR: could not find library with name $item\n";
			}
			if($f eq 'LC3' && ($otype eq 'project' || $otype eq 'result')){
			    #project or result
			    $oktype = 1;
			}
			if($f eq 'LC14a' && ($otype eq 'biosample')){
			    #biosample
			    $oktype = 1;
			}
			if($f eq 'LC14c' && ($otype eq 'project' || $otype eq 'reagent collection')){
			    #project or reagent_collection
			    $oktype = 1;
			}
			if ($f eq 'LC14b'){
			    $oktype = 1;
			}
			if($oktype){
			   print STDERR "DEBUG: $f oktype subject $ph{LC1a} object $item $otype\n"; 
			    my ($fr, $f_p) = write_library_relationship(
				$self->{db},      $doc,    $subject,
				$object,          $unique, $item,
				$fpr_type{$f}, $ph{pub}, 
				);
			    $out.=dom_toString($fr);
			    $out.=$f_p;
                    
			}
			else{
			    print STDERR "ERROR: $f  $ph{$f} $otype not valid type in $ph{LC1a}\n";
			}
		}
	    }
	}

        elsif($f eq 'LC4d'
	      || $f eq 'LC14e'
	      || $f eq 'LC14f'
	      || $f eq 'LC14g'
	    )
	{
            print STDERR "CHECK,  use of $f - single entry no type restiction\n";
            my $object  = 'object_id';
            my $subject = 'subject_id';
	    if ( exists( $ph{"$f.upd"} ) and $ph{"$f.upd"} eq 'c' ) {
		print STDERR "ERROR: !c NOT ALLOWED $ph{LC1a} $f $ph{pub}\n";
            }
	    my $item = $ph{$f};
            if ( defined($ph{$f}) && $ph{$f} ne '') {
		my ($fr, $f_p) = write_library_relationship(
		    $self->{db},      $doc,    $subject,
		    $object,          $unique, $item,
		    $fpr_type{$f}, $ph{pub}, 
		    );
		$out.=dom_toString($fr);
		$out.=$f_p;
                    
	    }
	}
        elsif($f eq 'LC3e' && $ph{$f} ne ''){
#find  and delete all library_relationship between  LC1f and LC3e     
            my $object  = 'object_id';
            my $subject = 'subject_id';
	    my @results =
		get_unique_key_for_lr_object( $self->{db}, $subject, $object,
				       $unique, $ph{$f} );
	    if(@results==0){
                    print STDERR "ERROR: no previous record found for $ph{LC1a} $f \n";
	    }
	    else{
		foreach my $ta (@results) {
		    $out .=
			delete_library_relationship_alltype( $self->{db}, $doc, $ta,
						     $subject, $object, $unique);
		}
	    }
	}

        elsif($f eq 'LC3a'){
	    $out .= update_library_synonym( $self->{db}, $doc,
					  $unique, $ph{$f}, 'symbol');    
	    $fbids{$unique}=$ph{LC1a};
        
	}
        elsif ( $f eq 'LC3b' ) {
            my $tmp=$ph{LC3b};
            $tmp=~s/\n/ /g;
            if($ph{LC1f} eq 'new'){
            print STDERR "Action Items: merge Library $tmp\n";
            }
            else{
                print STDERR "Action Items: merge Library $tmp to $ph{LC1f} == $ph{LC1a} \n";
            }
            $out .= merge_library_records( $self->{db}, $unique, $ph{$f},$ph{LC1a}, $ph{pub} );
	    $fbids{$unique}=$ph{LC3b};
          
        }
        
        elsif ($f eq 'LC4e'){
	  print STDERR "CHECK use of LC4e: $unique $ph{pub}\n";

	  if( exists($ph{"$f.upd"}) && $ph{ "$f.upd" } eq 'c' ) {
	    print STDERR "Action Items: !c log $unique $f $ph{pub}\n";
	    print STDERR "CHECK: use of  $f !c \n";
	    my ($cellu,$cello)= get_cell_line_by_library_pub($self->{db}, $unique, $fpr_type{$f},$ph{pub});
	    my ($cellg,$cells) = get_organism_by_id($self->{db},$cello);
	    my $clp=create_ch_cell_line_library(doc=>$doc,
						cell_line_id=>create_ch_cell_line(doc=>$doc, uniquename=>$cellu, genus=>$cellg, species=>$cells),
						library_id=>$unique,
						pub_id=>$ph{pub});
	    $clp->setAttribute("op","delete");
	    $out.=dom_toString($clp);
                         
	  }
	  if ( defined($ph{$f}) && $ph{$f} ne '' ) { 
	    if ( exists( $ph{LC4a} ) ) {
	      ( $genus, $species ) =
		get_organism_by_abbrev( $self->{db}, $ph{LC4a} );
	    }
	    else{
	      (my $nunique,$genus,$species,my $ntype)=get_lib_ukeys_by_name($db,$ph{LC1a});
	    }
	    my @items = split( /\n/, $ph{$f} );
	    foreach my $item (@items) {
	      $item =~ s/^\s+//;
	      $item =~ s/\s+$//;
	      print STDERR "DEBUG: LC4e $item $unique $ph{pub}\n";
	      my ($cu,$cg,$cs)=get_cell_line_ukeys_by_name($self->{db},$item);
	      if ( $cu eq '0' ) {
		print STDERR "ERROR: could not find record for $ph{LC4e}\n";
		  #		  exit(0);
	      }
	      elsif( $cg ne $genus || $cs ne $species){
		  print STDERR "ERROR: In LC4e $ph{LC4e} library genus/species $genus $species does not match cell_line $cg $cs \n";
		  #  exit(0);
	      }

	      else{
		my $cl=create_ch_cell_line_library(
						   doc=>$doc,
						   cell_line_id=>create_ch_cell_line(doc=>$doc, uniquename=>$cu, genus=>$cg, species=>$cs),
						   library_id=>$unique,
						   pub_id=>$ph{pub},                        
						  );  
		my $clp = create_ch_cell_line_libraryprop(
							  doc=>$doc,
							  type_id=>create_ch_cvterm(
										    doc  => $doc,
										    name => $fpr_type{$f},
										    cv   => "cell_line_libraryprop type",
										   ),
							 );
		$cl->appendChild($clp);     
		$out.=dom_toString($cl);
	      }
	    }
	  }
	}

        elsif ($f eq 'LC10'
            || $f eq 'LC9'
            || $f eq 'LC8c'
            || $f eq 'LC8d'
            || $f eq 'LC7a'
            || $f eq 'LC7f'
            || $f eq 'LC6b'
            || $f eq 'LC6a'
            || $f eq 'LC4b'
            || $f eq 'LC4f'
            || $f eq 'LC6e'
            || $f eq 'LC6d'
            || $f eq 'LC6f'
            || $f eq 'LC11a'
            || $f eq 'LC11b'
            || $f eq 'LC11c'
            || $f eq 'LC11e'
            || $f eq 'LC14h'
            || $f eq 'LC11j'
            || $f eq 'LC9a'
	    ) 
        {
            if ( exists( $ph{ "$f.upd" } ) && $ph{ "$f.upd" } eq 'c' ) {
                  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                my @results =
                  get_unique_key_for_libraryprop( $self->{db}, $unique,
                    $fpr_type{$f}, $ph{pub} );
                foreach my $t (@results) {
                    my $num = get_libprop_pub_nums( $self->{db}, $t->{fp_id} );
                    if ( $num == 1 || (defined($frnum{$unique}{$fpr_type{$f}}{$t->{rank}}) && $num-$frnum{$unique}{$fpr_type{$f}}{$t->{rank}}==1) ) {
                        $out .=
                          delete_libraryprop( $doc, $t->{rank}, $unique,
                            $fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_libraryprop_pub( $doc, $t->{rank}, $unique,
                            $fpr_type{$f}, $ph{pub} );
                    }
                    else {
                        print STDERR "ERROR:something Wrong, please validate first\n";
                         $out .=
                          delete_libraryprop( $doc, $t->{rank}, $unique,
                            $fpr_type{$f} );
                    }
                }
            }
            if ( defined($ph{$f}) && $ph{$f} ne '' ) {
		if($f eq 'LC6a'){
#one per pub
		    if(exists( $ph{ "$f.upd" } ) && $ph{ "$f.upd" } eq 'c' ){
			$out .=
			    write_libraryprop( $self->{db}, $doc, $unique, $ph{$f},
					       $fpr_type{$f}, $ph{pub} );
		    }
		    else{
			print STDERR "DEBUG: $f $ph{LC1a} $ph{pub} not !c\n";
			my @results = get_unique_key_for_libraryprop( $self->{db}, $unique,
								       $fpr_type{$f}, $ph{pub} );
			my $num = scalar(@results);
#			print STDERR "DEBUG: $f $ph{LC1a} $ph{pub} not !c num = $num\n";			
			if($num == 0){
			    $out .= 
				write_libraryprop( $self->{db}, $doc, $unique, $ph{$f},
						$fpr_type{$f}, $ph{pub} );
			}
			else{
			    print STDERR "ERROR: $f previous record found for $unique $ph{LC1a} $ph{pub}\n";
			}
		    }	
		}
		elsif($f eq 'LC11j'){
		    if($ph{$f} eq "y"){		    
			print STDERR "DEBUG: $f $ph{LC1a} $ph{pub} OK\n";
			$out .=
			    write_libraryprop( $self->{db}, $doc, $unique, $ph{$f},
					       $fpr_type{$f}, $ph{pub} );
		    }
		    else{
			print STDERR "ERROR: $f must be y $ph{LC1a} $ph{pub}\n";
		    }
		}
		elsif($f eq 'LC6e' || $f eq 'LC6f'){
		    if(exists( $ph{ "$f.upd" } ) && $ph{ "$f.upd" } eq 'c' ){
			$out .=
			    write_libraryprop( $self->{db}, $doc, $unique, $ph{$f},
					       $fpr_type{$f}, $ph{pub} );
		    }
		    else{
			my @results = get_unique_key_for_libraryprop_nopub( $self->{db}, $unique,
								       $fpr_type{$f});
			print STDERR "DEBUG: $f $ph{LC1a} not !c\n";
			my $num = scalar(@results);
			if($num == 0){
#			print STDERR "DEBUG: $f $ph{LC1a} $ph{pub} not !c num = $num\n";			
			    $out .= 			    
				write_libraryprop( $self->{db}, $doc, $unique, $ph{$f},
						$fpr_type{$f}, $ph{pub} );
			}
			else{
			    print STDERR "ERROR: $f previous record found for $unique $ph{LC1a}\n";
			}
		    }	
		    
		}
		elsif($f eq 'LC6d'){
		    if((exists($ph{LC1f} ) && $ph{LC1f} eq "new") || (exists( $ph{ "$f.upd" } ) && $ph{ "$f.upd" } eq 'c' )){
			if ($ph{$f} eq "Y" || $ph{$f} eq "N" ){
			print STDERR "DEBUG: $f $ph{LC1a} $ph{pub} OK\n";
			    $out .=
				write_libraryprop( $self->{db}, $doc, $unique, $ph{$f},
					       $fpr_type{$f}, $ph{pub} );
			}
			else{
			    print STDERR "ERROR: $f must be Y or N $ph{LC1a} $ph{pub}\n";
			}
		    }
		    else{
			print STDERR "ERROR: $f must be new or !c $ph{LC1a} $ph{pub}\n";

		    }
		}
		elsif($f eq 'LC9a'){
		    #quick and dirty check of 2nd row ---
		    my @items = split( /\n/, $ph{$f} );
		    my $row2 = $items[1];
		    if ($row2 =~ /---/){
			print STDERR "DEBUG: $f $ph{LC1a} $ph{pub} row2 OK\n";
			$out .=
			    write_libraryprop( $self->{db}, $doc, $unique, $ph{$f},
					       $fpr_type{$f}, $ph{pub} );
		    }
		    else{
			print STDERR "ERROR: $f $ph{$f} $ph{pub} $ph{LC1a} 2nd row must be ---'s possible wrong format \n";
		    }
		}
		else{
		    my @items = split( /\n/, $ph{$f} );
		    foreach my $item (@items) {
			$item =~ s/^\s+//;
			$item =~ s/\s+$//;
			print STDERR "CHECK use of libraryprop $item $ph{LC1a} $ph{pub}\n";
			$out .=
			    write_libraryprop( $self->{db}, $doc, $unique, $item,
					       $fpr_type{$f}, $ph{pub} );
		    }
		}
	    }
        }
	elsif ($f eq 'LC4h'){
 	  print STDERR "CHECK use of LC4h: $unique $ph{pub}\n";

           if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
            print STDERR ":Action Items: !c log,library_strain & library_strainprop $unique $ph{LC1a} $f  $ph{pub}\n";
	    #get library_strain
	    my $cvname = "library_strainprop type";
	    my @result =get_strain_for_library_strain( $self->{db}, $unique, $ph{pub}, $fpr_type{$f});
                foreach my $item (@result) {
                    my $lib_sn = create_ch_library_strain(
                        doc        => $doc,
                        library_id => $unique,
                        strain_id  => create_ch_strain(
                            doc  => $doc,
                            uniquename => $item,
                        ),
                        pub_id => $ph{pub}
                    );
                    $lib_sn->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($lib_sn);
                    $lib_sn->dispose();
                }
           }
	   if ( defined($ph{$f}) && $ph{$f} ne '' ) { 
	     if ( exists( $ph{LC4a} ) ) {
	       ( $genus, $species ) =
		 get_organism_by_abbrev( $self->{db}, $ph{LC4a} );
	     }
	     elsif(exists($ph{LC3a})){
		 ( $genus, $species, $type ) =
		     get_lib_ukeys_by_uname( $self->{db}, $ph{LC1f} );
		 if ( $genus eq '0' ) {
		     print STDERR "ERROR: could not find record for $ph{LC1f}\n";
#		     exit(0);
		 }
	     }
	     else{
	       (my $nunique,$genus,$species, my $ntype)=get_lib_ukeys_by_name($db,$ph{LC1a});
	     }

	     my @items = split( /\n/, $ph{$f} );
	     foreach my $item (@items) {
	       $item =~ s/^\s+//;
	       $item =~ s/\s+$//;
	       print STDERR "DEBUG: use of LC4h: $item $unique $ph{LC1a} $ph{pub}\n";

	       my ($lu,$lg,$ls)=get_strain_ukeys_by_name($self->{db},$item);
	       if ( $lu eq '0' ) {
		 print STDERR "ERROR: could not find record for $ph{LC4h}\n";
		  #		  exit(0);
	       }
	       elsif( $lg ne $genus || $ls ne $species){
		 print STDERR "ERROR: In LC4h $ph{LC4h} library genus/species $genus $species does not match strain $lg $ls \n";
		  #  exit(0);
	       }
	       else{
		 print STDERR "DEBUG: In LC4h $ph{LC4h} library genus/species $genus $species strain genus $lg species $ls \n";


		 my $cl=create_ch_library_strain(
					      doc=>$doc,
					      strain_id=>create_ch_strain(doc=>$doc, uniquename=>$lu, genus=>$lg, species=>$ls),
					      library_id=>$unique,
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
	     }
	   }
	 }

        elsif ($f eq 'LC4g'){
#           print STDERR "CHECK: expression module\n";
           if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
            print STDERR ":Action Items: !c log,$unique $f  $ph{pub}\n";
	    #get library_expression
	    my @result =get_expression_for_library_expression( $self->{db}, $unique, $ph{pub});
                foreach my $item (@result) {
                    my $lib_exp = create_ch_library_expression(
                        doc        => $doc,
                        library_id => $unique,
                        expression_id  => create_ch_expression(
                            doc  => $doc,
                            uniquename => $item,
                        ),
                        pub_id => $ph{pub}
                    );
                    $lib_exp->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($lib_exp);
                    $lib_exp->dispose();
                }
           }
          if ( defined($ph{$f}) && $ph{$f} ne '' ) {
	    my @items=split("\n", $ph{$f});
	    foreach my $item(@items){
	      $item=trim($item);
	      if($item ne ""){
		if(!($item=~/<t>/)){
		  $item='<t>'.$item;
		}
		
		my $fe=parse_tap(doc=>$doc,
				db=>$self->{db}, library_id=>$unique, pub_id=>$ph{pub},
				tap=>$item, check_cvterms=>1 );
				 
				 
		if(defined($fe) && $fe ne ''){
		  $out.=dom_toString($fe);
		}
	      }   
	    }
	  }
        }
        elsif($f eq 'LC12a'){
#	  print STDERR "CHECK: in single field LC12a \n";

            $out.=&parse_experimental_entity($unique,\%ph);
        }
        elsif($f eq 'LC12'){
	  print STDERR "CHECK: in multiple field LC12\n";
            ##### library_feature multiple genes
	  my @array = @{ $ph{$f} };
#	  print STDERR "CHECK: there are $#array \n";
	  foreach my $ref (@array) {
	    print STDERR "CHECK: $ref->{LC12a}\n";
	    $out .= &parse_experimental_entity( $unique, $ref);
            }
        }

	elsif( ($f eq 'LC12b' && $ph{LC12b} ne "") && ! defined ($ph{LC12a})){
	  print STDERR "ERROR: LC12b has a term for LC12b but no gene\n";
	}	    

        elsif($f eq 'LC7c' ||
              $f eq 'LC8a' ||
              $f eq 'LC8b')
	  {
#	    print STDERR "DEBUG: check xml for library_dbxref, library_dbxrefprop implementation\n";
	    if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
		print STDERR "CHECK: Action Items: !c log, $unique $f $ph{pub}\n";
		my @result=get_library_dbxref_by_type($self->{db},$unique,$fpr_type{$f});
		my $num= scalar(@result);
		if($num == 0){
		    print STDERR "ERROR: No previous record found for $unique $f type $fpr_type{$f}\n";
		}
		else{
#		    print STDERR "Found $num for ", $fpr_type{$f}, "\n";
		    foreach my $tt(@result){
			my $dxid = $tt->{db}.$tt->{acc};
			my $dbxref_dom=create_ch_dbxref(doc=>$doc,db=>$tt->{db},
							accession=>$tt->{acc},
							version=>$tt->{version},
							macro_id=>$dxid);
			$out.=dom_toString($dbxref_dom);
			my $fd=create_ch_library_dbxref(doc=>$doc,library_id=>$unique, dbxref_id=>$dxid);
			$fd->setAttribute('op','delete');
			$out.=dom_toString($fd);
		    }
		}
	    }
	    if(defined($ph{$f} && $ph{$f} ne '')){
	      my @items=split(/\n/,$ph{$f});
	      foreach my $item(@items){
		my $dbxref_dom="";
		my $dbxref = "null";
#		print STDERR "DEBUG: item = $item \n";
		$item=trim($item);
#		print STDERR "DEBUG: dbname $item\n";
		my $dbname=validate_dbname($self->{db},$item);
		if($dbname ne ''){
#		  print STDERR "DEBUG: found valid dbname = $dbname matches $item\n";
		  my $val = get_dbxref_by_db_dbxref($self->{db},$dbname,$dbxref);
		  if ($val == 0){
		    if(exists($fbdbs{$dbname.$dbxref})){
		      $dbxref_dom=$fbdbs{$dbname.$dbxref};
#		      print STDERR "DEBUG: exists $dbname.$dbxref in val= 0\n";
		    }
		    else{
		      print STDERR "CHECK: dbname = $dbname in $f $fpr_type{$f} creating new dbxref.accession= null\n";
		      $dbxref_dom=create_ch_dbxref(doc=>$doc, 
						 accession=>$dbxref, db=>$dbname,
						 description=>$dbxref, version=>'1', macro_id=>$dbname.$dbxref, no_lookup=>1);
		      $out.=dom_toString($dbxref_dom);
		      $fbdbs{$dbname.$dbxref}=$dbname.$dbxref;
		    }		  
		    my $fd=create_ch_library_dbxref(doc=>$doc, library_id=>$unique, dbxref_id=>$dbname.$dbxref,);
		    my $dbxrefprop=create_ch_library_dbxrefprop(doc=>$doc,
							      type=>$fpr_type{$f},
							      cvname=>,'property type',);		  
		    $fd->appendChild($dbxrefprop);
                           
		    $out.=dom_toString($fd);
		  }
		  elsif($val == 1){
		    print STDERR "CHECK: dbname = $dbname accession = $dbxref in $f $fpr_type{$f} found\n";
		    if(exists($fbdbs{$dbname.$dbxref})){
		      $dbxref_dom=$fbdbs{$dbname.$dbxref};
#		      print STDERR "DEBUG: exists $dbname.$dbxref in val= 1\n";
		    }
		    else{
		      
		      $dbxref_dom=create_ch_dbxref(doc=>$doc, 
						 accession=>$dbxref, db=>$dbname, version=>'1',
						 macro_id=>$dbname.$dbxref,);
		      $out.=dom_toString($dbxref_dom);
		      $fbdbs{$dbname.$dbxref}=$dbname.$dbxref;
		    }		  
		    my $fd=create_ch_library_dbxref(doc=>$doc, library_id=>$unique, dbxref_id=>$dbname.$dbxref,);

		    my $dbxrefprop=create_ch_library_dbxrefprop(doc=>$doc,
							      type=>$fpr_type{$f},
							      cvname=>,'property type',);		  
		    $fd->appendChild($dbxrefprop);
                           
		    $out.=dom_toString($fd);
		  }
		  else{
		    print STDERR "ERROR NO dbname of $item found -- create DB first\n";
		  }
		}

	      }
	    }
	  }

       elsif ( $f eq 'LC13a' || $f eq 'LC13b' || $f eq 'LC13c' || $f eq 'LC13d' || $f eq 'LC4j' || $f eq 'LC4k') {
#		print STDERR "DEBUG: $f cv = $fpr_type{$f}\n";
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
		print STDERR "Action Items: !c log, $ph{LC1a} $f  $ph{pub}\n";
                           my @result =
			       get_cvterm_for_library_cvterm( $self->{db}, $unique,
							 $fpr_type{$f}, $ph{pub} );
                foreach my $item (@result) {
                    my ($cvterm,$obsolete)=split(/,,/,$item);
                    my $gg_cvterm = create_ch_library_cvterm(
                        doc        => $doc,
                        library_id => $unique,
                        cvterm_id  => create_ch_cvterm(
                            doc  => $doc,
                            cv   => $fpr_type{$f},
                            name => $cvterm,
                            is_obsolete=>$obsolete
                        ),
                        pub_id => $ph{pub}
                    );
                    $gg_cvterm->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($gg_cvterm);
                    $gg_cvterm->dispose();
                }
            }
            if ( defined($ph{$f}) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
		    my $go = "";
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
           
                    validate_go( $self->{db}, $go, $go_id, $fpr_type{$f} );
                    my $f_cvterm = create_ch_library_cvterm(
                        doc        => $doc,
                        library_id => $unique,
                        cvterm_id  => create_ch_cvterm(
                            doc      => $doc,
                            cv       => $fpr_type{$f},
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
       elsif($f eq 'LC99a'){
	  $out.= &parse_dataset($unique,\%ph);
        }
        elsif($f eq 'LC99'){
	  print STDERR "CHECK: in multiple field LC99\n";
	  ##### library_dbxref multiple db/accessions
	  my @array = @{ $ph{$f} };
	  print STDERR "CHECK: there are ".  ($#array+1) ." \n";
	  foreach my $ref (@array) {
	    print STDERR "CHECK: $ref->{LC99a}\n";
	    $out .= &parse_dataset( $unique, $ref);
	  }
        }

      }
    $doc->dispose();
    return $out;
  }

sub parse_experimental_entity {
    my $unique  = shift;
    my $generef = shift;
    my %affgene = %$generef;
    my $gene    = '';
    my $fgenus   = '';
    my $fspecies = '';
    my $out     = '';
    my $val = 1;
    
    if ( defined($affgene{"LC12a.upd"}) && $affgene{'LC12a.upd'} eq 'c' ) {
	print STDERR "ERROR: !c NOT ALLOWED $unique LC12a use LC12c\n";
    }
    if(defined($affgene{LC12a}) && ($affgene{LC12a} ne '') && (defined( $affgene{LC12c} ) && ($affgene{LC12c} eq 'y'))){ 
	if(defined ($affgene{LC12b}) && $affgene{LC12b} ne ""){
	    #needs more work
	    my @results = get_feature_for_library_feature($db,$unique,$affgene{LC12a},$affgene{LC12b},$fpr_type{LC12b});
	    if(@results==0){
		print STDERR "ERROR: Can't remove LC12a, LC12b\n";
	    }
	    else{
		my $uname = $affgene{LC12a};
		foreach my $item (@results){
		    my $fu = $item;
		    if($fu eq $uname){
			(my $fg, my $fs, my $ft)=get_feat_ukeys_by_uname($db,$fu);
			my $cname = "SO";
			#if($ft eq 'single balancer'){
			#    $cname = "FlyBase miscellaneous CV";
			#}
			my $csf=create_ch_library_feature(doc=>$doc,
					   feature_id=>create_ch_feature(doc=>$doc, uniquename=>$fu, genus=>$fg, species=>$fs,cvname=>$cname,type=>$ft,),
					   library_id=>$unique,
					  );

			$csf->setAttribute("op","delete");
			$out.=dom_toString($csf);
			$csf->dispose;              
		    }
		}
	    }
	}
	else{
	    print STDERR "ERROR: Must give a type value in LC12b\n";
	}
    }
    if(defined($affgene{LC12a}) && ($affgene{LC12a} ne '') && ($affgene{LC12c} ne 'y')){
#for later may require library and feature be the same organism 
 #    my ( $genus, $species, $type ) = get_lib_ukeys_by_uname( $db, $unique );
 #     if ( $genus eq '0' ) {
#	print STDERR "ERROR: could not find record for $unique\n";
#	$val = 0;
#      }

      (my $fgenus, $fspecies, my $ftype ) = get_feat_ukeys_by_uname( $db, $affgene{LC12a} );
      if ($fgenus eq '0'){
	print STDERR "ERROR: LC12a $affgene{LC12a} not a valid FBid\n";
	$val = 0;
      }     
      if($val == 1){
	  my $uname = $affgene{LC12a};
	  print STDERR "DEBUG: LC12a $affgene{LC12a} uniquename $uname \n";		  
	  if(defined ($affgene{LC12b}) && $affgene{LC12b} ne ""){
	      if (exists ($affgene{LC12b}))  {
		  my $item = $affgene{LC12b};
		  print STDERR "DEBUG: LC12b $item found\n";
		  my $cname = "SO";
		  #if($ftype eq 'single balancer'){
		  #    $cname = "FlyBase miscellaneous CV";
		  #}

		  my $feat=create_ch_feature(
                                doc=>$doc,
                                uniquename=>$uname,
                                genus=>$fgenus,
                                species=>$fspecies,
		                cvname=>$cname,
                                type=>$ftype,
                                macro_id=>$uname,
					   );
		  $out.=dom_toString($feat);  
		  my $f_l=create_ch_library_feature(doc=>$doc,
						library_id=>$unique,
						feature_id=>$uname);

		  my $lfp = create_ch_library_featureprop(doc=>$doc,type=>$item,cvname=>$fpr_type{LC12b});
		  $f_l->appendChild($lfp);
		  $out.=dom_toString($f_l); 
		}
		else{
		  print STDERR "ERROR: wrong term for LC12b \n";
		}
	      }
	      else{
		print STDERR "ERROR: LC12a has a feature but no term for LC12b\n";
	      }
		
      }
	    
    }

    return $out;
  }



sub parse_dataset {
    my $unique  = shift;
    my $generef = shift;
    my %affgene = %$generef;
    my $dbname    = '';
    my $dbxref   = '';
    my $descr = '';
    my $out     = '';
    

    if ( defined($affgene{"LC99a.upd"}) && $affgene{'LC99a.upd'} eq 'c' ) {
      print STDERR "ERROR: !c not allowed for dbxref use LC99d with LC99a\n";
    }
    if((defined($affgene{LC99a}) && $affgene{LC99a} ne '') && (defined($affgene{LC99d}) &&$affgene{LC99d} eq 'y')){
	print STDERR "Action item: dissociate dbxref (data_link) $affgene{LC99b}:$affgene{LC99a} with Dataset $unique\n";
	if(defined($affgene{LC99b}) && $affgene{LC99b} ne ''){
	    my ($dname,$acc,$ver) = get_unique_key_for_library_dbxref_byprop($db,$unique, $affgene{LC99b},$affgene{LC99a},"data_link");
	    if ($dname eq "0"){
		print STDERR "ERROR:cannot dissociate dbxref (data_link) $affgene{LC99b}:$affgene{LC99a} with Dataset $unique\n";
		return $out;
	    }
	    else{
	print STDERR "in Library.pm Dataset $unique: db.name = $dname acc = $acc version = $ver\n";	    
		my $fd=create_ch_library_dbxref(doc=>$doc, 
                                            library_id=>$unique,
					    dbxref_id => create_ch_dbxref(doc => $doc,
									  db => $dname,
									  accession => $acc,
									  version=> $ver,
						),
		    );
		$fd->setAttribute( 'op', 'delete' );
                $out.= dom_toString($fd);         
		
		return $out;
	    }
	}
	else{
	    print STDERR "ERROR: LC99b required for dbxref with LC99a LC99d $unique\n";
	    return $out;
	}
    }
    if(defined($affgene{LC99b}) && $affgene{LC99b} ne ''){
      my $dbxref_dom = "";
      my $dbname=validate_dbname($db,$affgene{LC99b});
      if($dbname ne ''){
#	print STDERR "DEBUG: found valid dbname = $dbname matches $affgene{LC99b}\n";
	#get accession
	if(defined($affgene{LC99a}) && $affgene{LC99a} ne ''){ 
	  my $val=get_dbxref_by_db_dbxref($db,$dbname,$affgene{LC99a});
	  if ($val == -1){
	    print STDERR "ERROR: Multiple accessions in chado with  $affgene{LC99b} $affgene{LC99a}\n";	    
	  }
	  elsif($val == 0){
	    $dbxref = $affgene{LC99a};

	    if(exists($fbdbs{$dbname.$dbxref})){
	      $dbxref_dom=$fbdbs{$dbname.$dbxref};
#	      print STDERR "DEBUG: exists $dbname.$dbxref in val= 0\n";

	    }
	    else{
#		print STDERR "DEBUG: new accession in LC99a $affgene{LC99a} $affgene{LC99b}\n";  
		if(defined($affgene{LC99c}) && $affgene{LC99c} ne ''){
#		    print STDERR "DEBUG: $dbname $affgene{LC99a} description LC99c $affgene{LC99c}\n";
		    $descr = $affgene{LC99c};
		}
		else{
		    $descr = $affgene{LC99a};
		}
		$dbxref_dom=create_ch_dbxref(doc=>$doc, 
					   accession=>$dbxref, db=>$dbname, version=>'1',
					   description=>$descr, macro_id=>$dbname.$dbxref, no_lookup=>1);
		$fbdbs{$dbname.$dbxref}=$dbname.$dbxref;
		$out.=dom_toString($dbxref_dom);
	    }
	    my $fd=create_ch_library_dbxref(doc=>$doc, 
					  library_id=>$unique,
					  dbxref_id=>$dbxref_dom);                          
	    my $fdp=create_ch_library_dbxrefprop(doc=>$doc,type=>"data_link",cvname=>"property type");
	    $fd->appendChild($fdp);    
                            
	    $out.=dom_toString($fd);
	  }
	  elsif($val == 1){
	      $dbxref = $affgene{LC99a};
	      if(exists($fbdbs{$dbname.$dbxref})){
		  $dbxref_dom=$dbname.$dbxref;
#		  print STDERR "DEBUG: exists $dbname.$dbxref in val= 1\n";

	      }
	      else{
#		  print STDERR "DEBUG: accession in LC99a $affgene{LC99a} found\n";
		  my $version = &get_version_from_dbxref($db,$dbname,$affgene{LC99a});
		  if($version eq "0"){
		      print STDERR "ERROR: Multiple accessions in chado with  $affgene{LC99b} $affgene{LC99a} need to know version\n";
		  }
		  else{
		      if(defined($affgene{LC99c}) && $affgene{LC99c} ne ''){
			  print STDERR "WARN: $dbname.$affgene{LC99a} exists LC99c $affgene{LC99c} will be ignored\n"; 
		      }
		      $dbxref_dom=create_ch_dbxref(doc=>$doc, 
					     accession=>$dbxref, db=>$dbname,version=>$version,
					     macro_id=>$dbname.$dbxref,);
		      $fbdbs{$dbname.$dbxref}=$dbname.$dbxref;
		      $out.=dom_toString($dbxref_dom);
		  }
	      }
	      my $fd=create_ch_library_dbxref(doc=>$doc, 
                                            library_id=>$unique,
					    dbxref_id=>$dbxref_dom);
                          
	      my $fdp=create_ch_library_dbxrefprop(doc=>$doc,type=>"data_link",cvname=>"property type");
	      $fd->appendChild($fdp);    
                            
	      $out.=dom_toString($fd);
	  }
	}
	else{
	  print STDERR "ERROR: NO accession in LC99a $affgene{LC99a} \n";
	}
      }
      else{
	print STDERR "ERROR: NO dbname found for $affgene{LC99b} -- create DB first\n";
      }
    }
    return $out;
  }



=head2 $pro->write_library(%ph)
  separate the id generation and lookup from the other curation field to make two-stage parsing possible

=cut

sub write_library{
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

    if (  exists( $ph{LC1f} ) && $ph{LC1f} ne 'new') {   
      if(defined($fbids{$ph{LC1a}}) && !exists($ph{LC3a}) && !exists( $ph{LC3c} ) && !exists($ph{LC3b})){
	$unique=$fbids{$ph{LC1a}};
	if($unique ne $ph{LC1f}){
	  print STDERR "ERROR: something is wrong! $ph{LC1a} != $ph{LC1f}\n";
	}
      }
      else{
        ( $genus, $species, $type ) =
          get_lib_ukeys_by_uname( $self->{db}, $ph{LC1f} );
	if ( $genus eq '0' ) {
	  print STDERR "ERROR: could not find record for $ph{LC1f}\n";
	  exit(0);
        }
       if(!exists($ph{LC3a})){
	 ($unique,$genus,$species,$type)=get_lib_ukeys_by_name($self->{db},$ph{LC1a}) ;
	 if($unique ne $ph{LC1f}){
	   print STDERR "ERROR: name and uniquename not match $ph{LC1f}  $ph{LC1a} \n";
	 exit(0);
	 }
       }
	$unique=$ph{LC1f};
	$feature = create_ch_library(
				     doc        => $doc,
				     uniquename => $unique,
				     species    => $species,
				     genus      => $genus,
				     type       => $type,
				     macro_id   => $unique,
				    );
        if ( exists( $ph{LC3c} ) && $ph{LC3c} eq 'y' ) {
	  print STDERR "Action Items: delete library $ph{LC1f} == $ph{LC1a}\n";
	  my $op = create_doc_element( $doc, 'is_obsolete', 't' );
	  $feature->appendChild($op);
        }
	if(exists($ph{LC3a})){
         if(exists($fbids{$ph{LC3a}})){
             print STDERR "ERROR: Rename LC3a $ph{LC3a} exists in a previous proforma\n";
         }
         if(exists($fbids{$ph{LC1a}})){                                    
             print STDERR "ERROR: Rename LC1a $ph{LC1a} exists in a previous proforma \n";
         }  
	 print STDERR "Action Items: rename $ph{LC1f} from $ph{LC3a} to $ph{LC1a}\n";
	  my $va=validate_lib_name($db, $ph{LC1a});
	  if($va == 0){
	      
	    my $n=create_doc_element($doc,'name',decon(convers($ph{LC1a})));
	      $feature->appendChild($n);
	      $out.=dom_toString($feature);
	      $out .=  write_library_synonyms( $doc, $unique, $ph{LC1a}, 'a',
                'unattributed', 'symbol' );          
	      $fbids{$ph{LC3a}}=$unique;
	  }
	}
	else{
	  $out.=dom_toString($feature);
	}
	$fbids{ $ph{LC1a} } = $unique;
      }
 } 
    else{
      if (!exists($ph{LC3b})){
	my $va=validate_lib_name($db, $ph{LC1a});
        ### if the temp id has been used before, $flag will be 1 to avoid
        ### the DB Trigger reassign a new id to the same symbol.
	if($va==1){
	  $flag=0;
	  ($unique,$genus,$species,$type)=get_lib_ukeys_by_name($db,$ph{LC1a});
	  $fbids{$ph{LC1a}}=$unique;
	}
      }
   	print STDERR "Action Items: new Library $ph{LC1a}\n";
	( $unique, $flag ) = get_tempid( 'lc', $ph{LC1a} );
            
	if(exists($ph{LC3b}) && $ph{LC1f} eq 'new' && $unique !~/temp/){
	  print STDERR "ERROR: merge libs should have a FB..:temp id not $unique\n";
	}
	if ( exists( $ph{LC4a} ) ) {
	  ( $genus, $species ) =
	    get_organism_by_abbrev( $self->{db}, $ph{LC4a} );
	}
#	elsif ( $ph{LC1a} =~ /^(.{4})\\(.*)/ ) {
#	  ( $genus, $species ) = get_organism_by_abbrev( $self->{db}, $1 );
#	}
	if($genus eq '0'){
	  print STDERR "ERROR: could not get genus for Library $ph{LC1a}\n";
	  exit(0);
	}
      if(exists($ph{LC2a})){
      #webcv value = dataset_entity_type
	  my $go = "";
	  my $go_id = "";
	  my $item = $ph{LC2a};
	  if ( $item =~ /(.*)\s;\s(.*)/ ) {
	      $go    = $1;
	      $go_id = $2;
	  }
	  $go    =~ s/^\s+//;
	  $go    =~ s/\s+$//;
	  $go_id =~ s/^\s+//;
	  $go_id =~ s/\s+$//;
	  validate_go( $self->{db}, $go, $go_id, $fpr_type{'LC2a'} );
	  $type = $go;
          my $type_id = get_cvterm_by_webcv($self->{db},$go,'dataset_entity_type');
          if (defined ($type_id)){
            $type=$go;
          }
          else{
            print STDERR "ERROR: $ph{LC2a} is not a valid type for $ph{LC1a}\n"; 
          }
      }  
      else{
	  print STDERR "ERROR: missing LC2a for library $unique $ph{LC1a}\n";
      }
      if ( $flag == 0 ) {
	$feature = create_ch_library(
				     uniquename => $unique,
				     name       => decon( convers( $ph{LC1a} ) ),
				     genus      => $genus,
				     species    => $species,
				     type_id  => create_ch_cvterm(doc=> $doc,
								  cv=>'FlyBase miscellaneous CV',
								  name=>$type,
	    ),
				     doc        => $doc,
				     macro_id   => $unique,
				    );
	$out.=dom_toString($feature);
	$out .=
	  write_library_synonyms( $doc, $unique, $ph{LC1a}, 'a',
                'unattributed', 'symbol' );
      }
      else{
	print STDERR "ERROR, name $ph{LC1a} has been used in this load\n";
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
 
    print STDERR "validating Library ", $tival{LC1a}, "\n";
    
    if(exists($tival{LC1f}) && ($tival{LC1f} ne 'new')){
        validate_uname_name($db, $tival{LC1f}, $tival{LC1a});
    }
    if ( exists( $fbids{$tival{LC1a}})){
        $v_unique=$fbids{$tival{LC1a}};    
    }
    else{
        print STDERR "ERROR: could not validate $tival{LC1a}\n";
        return;
    }
    
        foreach my $f ( keys %tival ) {
            if ( $f =~ /(.*)\.upd/ && !($v_unique=~/temp/) ) {
                $f = $1;
                if (  $f eq 'LC10'
            || $f eq 'LC6g'
            || $f eq 'LC6a'
            || $f eq 'LC14h'
            || $f eq 'LC4b'
            || $f eq 'LC4f'
            || $f eq 'LC6e'
            || $f eq 'LC6f'
            || $f eq 'LC11a'
            || $f eq 'LC6b'
            || $f eq 'LC11c'
            || $f eq 'LC11e'
            || $f eq 'LC7a'
            || $f eq 'LC7f')
                {
                    my $num =
                      get_unique_key_for_libraryprop( $db, $v_unique,
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

our %lc12btype = (
    'antibody_target', 1,
    'RNAi_target', 1,
    'allele_used', 1,
    'transgene_used', 1,
    'experimental_design', 1,
    'inhibitor_target', 1,
    'activator_target', 1,
    'bait_protein', 1,
    'bait_RNA', 1,
    'depletion_target', 1,
    'overexpressed_factor', 1,
    'ectopic_factor', 1,
);


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

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! DATASET/COLLECTION PROFORMA   Version 4.2   08 Jan 2016
!
! LC1f. Database ID for dataset  :
! LC1a. Symbol                    :
! LC1b. Symbol used in paper/source  :
! LC1d. Nickname [for labels]       :
! LC6g. Dataset title  :
! LC6a. Description [free text]  :
! LC2a. Type of dataset entity [CV] 		 :
! LC2b.  Type of dataset data [CV]  	 :
! LC3.  Dataset "belongs_to" this project  :
! LC14a. Dataset assay/collection is "assay_of" this biosample  :
! LC14b. Dataset result is "analysis_of"  :
! LC14c. Dataset "uses_reagent"  :
! LC14d. Dataset "technical_reference_is"  :
! LC14e. Dataset "biological_reference_is"  :
! LC14f. Dataset "replaced_by"  :
! LC14g. Dataset "genome_reference_is"  :
! LC14h. Reference FlyBase gene model annotation set [free text]  :
! LC3a. Action - rename this dataset symbol    :
! LC3b. Action - merge these datasets      :
! LC3c. Action - delete dataset record ["y"/blank]   :
! LC3d. Action - dissociate LC1f from FBrf ["y"/blank]  :
! LC3e. Action - dissociate LC1f from this dataset	 :
! LC13a. Key GO term(s) - Cellular Component (term ; ID)  *f  :
! LC13b. Key GO term(s) - Molecular Function (term ; ID)  *F  :
! LC13c. Key GO term(s) - Biological Process (term ; ID)  *d  :
! LC13d. Key SO term(s) [CV] *t  :
! LC4a. Species of derivation [CV]  :
! LC4i. Other species of interest [CV]  :
! LC4h. Strain used [symbol]    :
! LC4b. Strain used [free text]  :
! LC4f. Genotype used [free text]  :
! LC4g. Stage and tissue (<e> <t> <a> <s> <note>)  :
! LC4j. Tissue of interest [CV]   :
! LC4k. Stage of interest [CV]   :
! LC4e. Cell line used [symbol]  :
! LC12a. Experimental entity [FB feature symbol]  :
! LC12b. Type of experimental entity [CV]  :
! LC12c. Action - delete the dataset-feature relationship specified in LC12a/LC12b ("y"/blank)  :
! LC6d. Dataset/collection members stored in database [Y/N]  :
! LC6e. Number of entities in dataset/collection [if LC6d is N]   :
! LC6f. Comment on number of entities in dataset/collection [free text]  :
! LC11k. Experimental protocol - study design [CV]  :
! LC11f. Experimental protocol - biosample [CV]  :
! LC11g. Experimental protocol - assay or reagent collection [CV]  :
! LC11i. Experimental protocol - analysis [CV]  :
! LC11j. Experimental protocol - data analysis is secondary analysis ("y"/blank)  :
! LC11a. Experimental protocol, source isolation and prep [free text]  :
! LC6b.  Experimental protocol, dataset/collection preparation [free text]  :
! LC11c. Experimental protocol, mode of assay [free text]  :
! LC11e. Experimental protocol, data analysis [free text]  :
! LC7a. Types of additional data available [free text]  :
! LC7f. Associated files, archived at ftp site [SoftCV]  :
! LC7c. Additional data at [database name]  :
! LC99a. DataSet Accession Number [dbxref.accession]  :
! LC99b. Database name [database name]  :
! LC99c. DataSet title [free text]  :
! LC99d. Action - dissociate accession in LC99a/LC99b from dataset in LC1f/LC1a? ("y"/blank)  :
! LC8a. Created by [database name]        :
! LC8c. Created by [free text]      :
! LC8b. Available from [database name]    :
! LC8d. Available from [free text]  :
! LC9.  Additional comments  :
! LC9a.  Structured table [SoftCV]  :
! LC10. Internal notes      :
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

=head1 AUTHOR

Haiyan Zhang, E<lt>haiyan@morgan.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
