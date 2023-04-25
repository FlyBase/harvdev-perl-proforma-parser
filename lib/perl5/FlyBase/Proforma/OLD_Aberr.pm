package FlyBase::Proforma::Aberr;

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

FlyBase::Proforma::Aberr - Perl module for parsing the FlyBase
Aberration  proforma version 36, July 6, 2007.

See the bottom for the template of the proforma
                         
=head1 SYNOPSIS

  use FlyBase::Proforma::Aberr;
  use DBI;
  
  my $mdbh=DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";
  my %ph=(A1a=>'TM9', A1g=>'y',....);
  ###!c field implemented as '$fieldname.upd=>'c'' eg. 'A16.upd'=>'c'
   
  #params db is manditory, debug and validate is optional
  my $pro=FlyBase::proforma::Aberr->new(db=>$mdbh);
  $pro->validate(%ph);
  my $chadoxml = $pro->process(%ph);
  
  # or

  my $pro=FlyBase::Proforma::Aberr->new(db=>$mdbh,debug=>1,validate=>1);
  my $chadoxml_string=$pro->process(%ph);

=head1 DESCRIPTION

FlyBase::Proforma::Aberr is a perl module for parsing FlyBase
Aberration proforma and write the result as chadoxml. It is required
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
    'A1a',  'symbol',                       #feature_synonym
    'A1b',  'symbol',                       #feature_synonym
    'A1e',  'symbol',                       #feature_synonym
    'A1f',  'merge',                        #merge_function
    'A1g',  'new',                          #checking
    'A2a',  'fullname',                     #feature_synonym
    'A2b',  'fullname',                     #feature_synonym
    'A2c',  'fullname',                     #feature_synonym
    'A27a', 'is_obsolete',                  #feature.is_obsolete
    'A27b', 'dissociate_pub',               #feature_pub...
    'A17',  'aberr_pheno',             #feature_genotype,genotype,phendesc
#    'A10',  'new_order',                    #featureprop
    'A8a',  'break_of',
    'A8b',  '',
    'A19a', 'overlap_inferred',             #feature_relationship
    'A19b', 'aberr_relationships',          #featureprop
    'A9',   'SO',                           #feature_cvterm
#    'A11',  'new_order',                    # featureprop
    'A18',  'cyto_loc_comment',             #featureprop
    'A26',  'SO',                           #feature_cvterm
    'A4',   'FlyBase miscellaneous CV',    #feature_cvterm
    'A24a', 'associated_with',              #feature_relationship
    'A24b', 'carried_on',                   #feature_relationship.subject_id
    'A16',  'discoverer',                   #featureprop
    'A6',   'progenitor',                   #feature_relationship
    'A22a', 'origin_type',                  #featureprop
    'A22b', 'origin_comment',               #featureprop
    'A23',  'segregant_of',                 #feature_relationship.subject_id
    'A7a',  'deletes',                      #feature_relationship
    'A7b',  'duplicates',                   #feature_relationship
    'A7c',  'nondeletes',                   #feature_relationship
    'A7d',  'nonduplicates',                #feature_relationship
    'A7e',  'part_deletes',                 #feature_relationship
    'A7f',  'part_duplicates',              #feature_relationship
    'A7x',  'complementation',             #featureprop
    'A25a', 'molec_deletes',                #feature_relationship
    'A25b', 'molec_dups',                   #feature_relationship
    'A25c', 'molec_nondeletes',             #feature_relationship
    'A25d', 'molec_nondups',                 #feature_relationship
    'A25e', 'molec_partdeletes',            #feature_relationship
    'A25f', 'molec_partdups',               #feature_relationship
    'A25x', 'molecular_info',               #featureprop
    'A20a', 'is_polymorphism_reported',     #featureprop
    'A21',  'availability',                 #featureprop
    'A30', 'library_feature',               #library_feature
    'A30a', 'library_featureprop',          #library_featureprop
    'A14',  'misc',                         #featureprop
    'A15',  'internal_notes' ,               #featureprop
    'A90a',   'break_of',                 #feature_relationship
    'A90h',   'linked_to', #GenBank feature qualifier
    'A90j',   'gen_loc_comment', #property type
    'A28',   'feature_dbxref',
	 'A91a',  'deleted_segment', #featurepop
	 'A92a',  'duplicated_segment', #featureprop
    'A29', 'new_order', #featureprop
);

my %A9type = (
    'Df',   'chromosomal_deletion',
    'tDp',  'tandem_duplication',
    'In',   'chromosomal_inversion',
    'T',    'chromosomal_translocation',
    'R',    'ring_chromosome',
    'AS',   'autosynaptic_chromosome',
    'DS',   'dexstrosynaptic_chromosome',
    'LS',   'laevosynaptic_chromosome',
    'fDp',  'free_duplication',
    'fR',   'free_ring_duplication',
    'DfT',  'deficient_translocation',
    'DfIn', 'deficient_inversion',
    'InT',  'inversion_cum_translocation',
    'bDp',  'bipartite_duplication',
    'cT',   'cyclic_translocation',
    'cIn',  'bipartite_inversion',
    'eDp',  'uninverted_insertional_duplication',
    'iDp',  'inverted_insertional_duplication',
    'uDp',  'unoriented_insertional_duplication',
    'eTp1', 'uninverted_intrachromosomal_transposition',
    'eTp2', 'uninverted_interchromosomal_transposition',
    'iTp1', 'inverted_intrachromosomal_transposition',
    'iTp2', 'inverted_interchromosomal_transposition',
    'uTp1', 'unorientated_intrachromosomal_transposition',
    'uTp2', 'unoriented_interchromosomal_transposition'
);

my %a30a_type = ('experimental_result', 1 , 'member_of_reagent_collection', 1);

my %feat_type = ('A24a','transposable_element_insertion_site',
		 'A30','library',
                );
my %featid_type = ('A24a','ti', 'A30','lc');

my %proptype = ( 'A9', 'aberr_class', 'A26', 'wt_class', 'A4', 'webcv' );

my $doc      = new XML::DOM::Document();
my $db       = '';

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

##
#if symbol change, genotype will be changed?
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

    if ( exists( $self->{debug} ) && $self->{debug} == 1 ) {
        foreach my $key ( keys %ph ) {
            print STDERR "$key, $ph{$key}\n";
        }
    }

    if ( exists( $self->{validate} ) && $self->{validate} == 1 ) {
        $self->validate($tihash);
    }
    print STDERR "processing Aberration $ph{A1a}...\n";
    
    if(exists($fbids{$ph{A1a}})){
        $unique=$fbids{$ph{A1a}};
    }
    else{
        print STDERR "Warning: undefined feature \n";
        ($unique, $out)=$self->write_feature($tihash);
    }
    if(exists($fbcheck{$ph{A1a}}{$ph{pub}})){
        print STDERR "Warning: $ph{A1a} $ph{pub} exists in a previous proforma\n";
    }
    $fbcheck{$ph{A1a}}{$ph{pub}}=1;  # log the record, if this happens twice, it may be a duplicate.
    
    if(!exists($ph{A27b})){
    
        print STDERR "Action Items: aberration $unique == $ph{A1a} with pub $ph{pub}\n"; 
        my $f_p = create_ch_feature_pub(
            doc        => $doc,
            feature_id => $unique,
            pub_id     => $ph{pub}
        );
        $out .= dom_toString($f_p);
        $f_p->dispose();
    } else {
            print STDERR "Action Items: dissociate $ph{A1a} with $ph{pub}\n";
            $out .= dissociate_with_pub( $self->{db}, $unique, $ph{pub} );
            return ($out,$unique);
        }

    ##Process other field in Trangenic Insertion proforma
    foreach my $f ( keys %ph ) {
       # print STDERR "$f  $ph{$f} \n";
        
        if ( $f eq 'A1b' || $f eq 'A2b' ) {
      if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
      print STDERR "Action Items: !c log,$ph{A1a} $f  $ph{pub}\n";
            $out .=
                      delete_feature_synonym( $self->{db}, $doc, $unique, $ph{pub}, $ti_fpr_type{$f});
            
            }
            if(defined ($ph{$f}) && $ph{$f} ne ''){
            my @items = split( /\n/, $ph{$f} );
            foreach my $item (@items) {
                $item =~ s/^\s+//;
                $item =~ s/\s+$//;
                       my $t = $f;
                       $t =~ s/^A\d//;

                if ( $item ne 'unnamed' && $item ne '' ) {
                    if ( ( $f eq 'A1b' ) && ( $item eq $ph{A1a} ) ) {
                        $t = 'a';
                    }
                    elsif (( $f eq 'A2b' )
                        && exists( $ph{A2a} )
                        && ( $item eq $ph{A2a} ) )
                    {
                        $t = 'a';
                    }
                    elsif ( !exists( $ph{A2a} ) && $f eq 'A2b' ) {
                        $t =
                          check_feature_synonym_is_current( $self->{db},
                            $unique, $item, 'fullname' );
                    }
                    $out .=
                      write_feature_synonyms( $doc, $unique, $item, $t,
                        $ph{pub}, $ti_fpr_type{$f} );
                }
            }
        }
        }
        elsif($f eq 'A2a'){

	  if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
	    print STDERR "ERROR: A2a can not accept !c\n";
	  }
	  my $num = check_feature_synonym( $self->{db},
                            $unique,  'fullname' );
	  if( $num != 0){
	    if ((defined($ph{A2c}) && $ph{A2c} eq '' && !defined($ph{A1f})) || (!defined($ph{A2c}) && !defined($ph{A1f}) )) {
	      print STDERR "ERROR: A2a must have A2c filled in unless a merge\n";
	    }
	    else{
	      $out.=write_feature_synonyms($doc,$unique,$ph{$f},'a','unattributed',$ti_fpr_type{$f});
	    }
	  }
	  else{
	    $out.=write_feature_synonyms($doc,$unique,$ph{$f},'a','unattributed',$ti_fpr_type{$f});
	  }

#Was just this but assume need same checks as Gene
		 	#$out.=write_feature_synonyms($doc,$unique,$ph{$f},'a','unattributed',$ti_fpr_type{$f});
	  }
        elsif($f eq 'A1e' || $f eq 'A2c'){
             $out .=
              update_feature_synonym( $self->{db}, $doc, $unique, $ph{$f},
                $ti_fpr_type{$f} );
        }
       
        elsif ( $f eq 'A1f' ) {
            $out .= merge_records( $self->{db}, $unique, $ph{$f}, $ph{A1a}, $ph{pub},$ph{A2a} );
         # $out.=write_feature_synonyms($doc,$unique,$ph{A2a},'a','unattributed',$ti_fpr_type{A2a});
        }
        elsif ($f eq 'A28'){
            if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
            print STDERR "Action Items: !c log,$ph{A1a} $f  $ph{pub}\n";
                my @result=get_dbxref_by_feature_db($self->{db},$unique,'GB');
                my @prresult=get_dbxref_by_feature_db($self->{db},$unique,'GB_protein');
                foreach my $tt(@result,@prresult){
                    my $fd=create_ch_feature_dbxref(doc=>$doc, feature_id=>$unique, 
                    dbxref_id=>create_ch_dbxref(doc=>$doc,db=>$tt->{db},accession=>$tt->{acc}, version=>$tt->{version}));
                    $fd->setAttribute('op','delete');
                    $out.=dom_toString($fd);
                   }   
            }
            if($ph{$f} ne ''){
            my @items=split(/\n/,$ph{$f});
            foreach my $item(@items){
              $out.=process_sequence_curation($self->{db}, $doc, $unique, $item);
             }
            }
        }
        elsif ($f eq 'A6'
            || $f eq 'A19a'
            || $f =~ '^A7[a-f]$'
            || $f =~ '^A24[a-b]$'
            || $f =~ '^A25[a-f]$'
            || $f eq 'A23' )
        {
           print STDERR "enter function $f\n";
            my $object  = 'object_id';
            my $subject = 'subject_id';
            if ( $f eq 'A24b' ) {
                $object  = 'subject_id';
                $subject = 'object_id';
            }
            if ( exists( $ph{"$f.upd"} ) and $ph{"$f.upd"} eq 'c' ) {
            print STDERR "Action Items: !c log,$ph{A1a} $f  $ph{pub}\n";
                my @results =
                  get_unique_key_for_fr( $self->{db}, $subject, $object,
                    $unique, $ti_fpr_type{$f}, $ph{pub} );
                foreach my $ta (@results) {
                    my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );
                    if ( $num == 1 || (defined($frnum{$unique}{$ta->{name}}) && $num-$frnum{$unique}{$ta->{name}}==1)) {
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
                        print STDERR "something Wrong, please validate first\n";
                    }
                }

            }
            
            if (defined($ph{$f}) &&  $ph{$f} ne '' ) {
           
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
						  if($item eq ''){
						    print STDERR "ERROR: $ph{A1a} $f is null (check)\n";
							 next;
						  }
                     if($f eq 'A19a'){
			            if($item=~/Inferred to overlap with: \@(.*)@/){
			                $item=$1;
			            }
			            else{
			                print STDERR "Warning: format is not correct for $f\n";
			            }
		            }
                   my ($fr, $f_p)=   write_feature_relationship( $self->{db}, $doc, $subject,
                        $object, $unique, $item, $ti_fpr_type{$f}, $ph{pub}, $feat_type{$f}, $featid_type{$f});
              
                   $out .=dom_toString($fr);
                   $out.=$f_p;
                  $fr->dispose();
                }
            }
        }
        elsif ($f eq 'A16'
            || $f =~ '^A22[ab]$'
            || $f eq 'A19b'
#            || $f eq 'A11'
            || $f eq 'A7x'
#            || $f eq 'A10'
            || $f eq 'A18'
            || $f eq 'A14'
            || $f eq 'A25x'
            || $f eq 'A20a'
            || $f eq 'A21'
            || $f eq 'A15'
            || $f eq 'A29' )
        {
            if ( exists( $ph{ "$f.upd" } ) && $ph{ "$f.upd" } eq 'c' ) {
            print STDERR "Action Items: !c log,$ph{A1a} $f  $ph{pub}\n";
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
                          delete_featureprop_pub( $doc, $t, $unique,
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
                    $out .=
                      write_featureprop( $self->{db}, $doc, $unique, $item,
                        $ti_fpr_type{$f}, $ph{pub} );
                }
            }
        }

        elsif ( $f eq 'A30' ){               
	  print STDERR "CHECK: new implemented $f  $ph{A1a} \n";

            if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
                print STDERR "CHECK: new implemented !c $ph{A1a} $f \n";
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
		print STDERR "ERROR: could not find record for $ph{A30}\n";
		  #		  exit(0);
	      }
	      else{
		print STDERR "DEBUG: A30 $ph{$f} uniquename $libu\n";		  

		if(defined ($ph{A30a}) && $ph{A30a} ne ""){
		  if (exists ($a30a_type{$ph{A30a}} ))  {
		    my $item = $ph{A30a};
		    print STDERR "DEBUG: A30a $ph{A30a} found\n";
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
		    print STDERR "ERROR: wrong term for A30a $ph{A30a}\n";
		  }
		}
		else{
		  print STDERR "ERROR: A30 has a library no term for A30a\n";
		}
		
	      }
	    }
	}
	elsif( ($f eq 'A30a' && $ph{A30a} ne "") && ! defined ($ph{A30})){
	  print STDERR "ERROR: A30a has a term for A30a but no library\n";
	}	    
        elsif ( $f eq 'A26' || $f eq 'A9' || $f eq 'A4' ) {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
            print STDERR "Action Items: !c log,$ph{A1a} $f  $ph{pub}\n";
                my $class  = $proptype{$f};
                my @result = ();
                if ( $f eq 'A26' || $f eq 'A9' ) {
                    @result =
                      get_cvterm_for_feature_cvterm_withprop( $self->{db},
                        $unique, $ti_fpr_type{$f}, $ph{pub}, $class );
                }
                else {
                    @result =
                      get_cvterm_for_feature_cvterm_by_cvtermprop( $self->{db},
                        $unique, $ti_fpr_type{$f}, $ph{pub}, 'origin_of_mutation',
                        $class );
                }
                foreach my $item (@result) {
                    my $feat_cvterm = create_ch_feature_cvterm(
                        doc        => $doc,
                        feature_id => $unique,
                        cvterm_id  => create_ch_cvterm(
                            doc  => $doc,
                            cv   => $ti_fpr_type{$f},
                            name => $item
                        ),
                        pub_id => $ph{pub}
                    );
                    $feat_cvterm->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($feat_cvterm);
                    $feat_cvterm->dispose();
                }
            }
            if (defined($ph{$f}) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    if ( $item =~ /(.*)\s;\s/ ) {
                        $item = $1;
                    }
                    if ( exists( $A9type{$item} ) ) {
                        $item = $A9type{$item};
                    }
						  validate_cvterm($self->{db},$item,$ti_fpr_type{$f});
                    my $f_cvterm = create_ch_feature_cvterm(
                        doc        => $doc,
                        feature_id => $unique,
                        cvterm_id  => create_ch_cvterm(
                            doc      => $doc,
                            cv       => $ti_fpr_type{$f},
                            name     => $item,
                            macro_id => $item
                        ),
                        pub_id => $ph{pub}
                    );
                    if ( $f eq 'A26' ) {
                        my $fcvprop = create_ch_feature_cvtermprop(
                            doc  => $doc,
                            type => 'wt_class'
                        );
                        $f_cvterm->appendChild($fcvprop);
                    }
                    elsif ( $f eq 'A9' ) {

                        my $fcvprop = create_ch_feature_cvtermprop(
                            doc  => $doc,
                            type => 'aberr_class'
                        );
                        $f_cvterm->appendChild($fcvprop);
                    }

                    $out .= dom_toString($f_cvterm);
                    $f_cvterm->dispose();
                }
            }
        }
        elsif ( $f eq 'A17' ) {
        if(exists($ph{'A17.upd'}) && $ph{'A17.upd'} eq 'c'){
        print STDERR "Action Items: !c log,$ph{A1a} $f  $ph{pub}\n";
            my @result=get_unique_for_phendesc($self->{db}, $unique, $ph{pub}, $ti_fpr_type{$f});
              my $gg=$ph{A1a};
              if(exists($ph{A1e})){
                $gg=convers($ph{A1e});
              }
            foreach my $t(@result){
                if(
                  $t->{environ} eq 'unspecified' &&
                  $t->{type} eq 'aberr_pheno'){
                 my $geno=create_ch_genotype(
                doc        => $doc,
                uniquename => $t->{genotype},
                macro_id   => $t->{genotype}
            );   
	     $out.=dom_toString($geno);
            $geno->dispose();               
              my $phendesc = create_ch_phendesc(
                doc         => $doc,
                genotype_id => $t->{genotype},
                environment => 'unspecified',
                pub_id      => $ph{pub},
                type_id     => create_ch_cvterm(
                    doc  => $doc,
                    name => 'aberr_pheno',
                    cv   => 'phendesc type'
                ),
            );
            $phendesc->setAttribute('op','delete');
            $out.=dom_toString($phendesc);
            $phendesc->dispose();
                  }
		else{
		  print STDERR "ERROR: !c  phendesc  for $ph{A1a} $f  $ph{pub}, $ti_fpr_type{$f} NOT found\n";		  
		}
            }
            
            
        }
            ##write phendesc by genotype->phendesc, feature_genotype,
         if(defined($ph{$f}) && $ph{$f} ne ''){
            my $genotype = create_ch_genotype(
                doc        => $doc,
                uniquename => convers($ph{A1a}),
                macro_id   => convers($ph{A1a})
            );
            my $fg = create_ch_feature_genotype(
                doc           => $doc,
                feature_id    => $unique,
                genotype_id   => convers( $ph{A1a} ),
                rank          => 0,
                cgroup        => 0,
                chromosome_id => 'unspecified',
                cvterm_id     => 'unspecified'
            );
            my $phendesc = create_ch_phendesc(
                doc         => $doc,
                genotype_id => convers($ph{A1a}),
                environment => 'unspecified',
                pub_id      => $ph{pub},
                type_id     => create_ch_cvterm(
                    doc  => $doc,
                    name => $ti_fpr_type{$f},
                    cv   => 'phendesc type'
                ),
                description => $ph{A17}
            );
            $out .=
                dom_toString($genotype)
              . dom_toString($phendesc)
              . dom_toString($fg);
              $genotype->dispose();
              $phendesc->dispose();
              $fg->dispose();
            }
        }
        elsif ( $f eq 'A10'  ) {
             if(exists($ph{"$f.upd"})){
                print STDERR "ERROR: Wrong proforma using obsoleted field $f yet\n";
            }
            print STDERR "ERROR: Wrong proforma using obsoleted field $f  yet\n";
        }
		  elsif($f eq 'A91a' || $f eq 'A92a'){
			  chop($f);
		      $out.=&parse_segment($unique,\%ph,$ph{pub},$f); 
		  }
		  elsif($f eq 'A91' || $f eq 'A92'){
			    my @array = @{ $ph{$f} };
			    foreach my $ref (@array) {
			     $out.=&parse_segment($unique,$ref,$ph{pub}, $f);
		   }
		  }
        elsif ( $f eq 'A90a' ) {
                $out .= &parse_multiple_break( $unique, \%ph, $ph{pub} );
        }
        elsif ( $f eq 'A90' ) {
            my @array = @{ $ph{A90} };
            foreach my $ref (@array) {
                $out .= &parse_multiple_break( $unique, $ref, $ph{pub} );
            }     
        }
        elsif ( $f eq 'A8b' ) {
            if(exists($ph{"$f.upd"})){
                print STDERR "ERROR: has not implemented field $f yet\n";
            }
            if ( length( $ph{$f} ) > 12 ) {
                print STDERR "ERROR: hasnot implemented  field $f  yet\n";
            }
        }
        elsif ( $f eq 'A8a' ) {
            
     
           if(exists($ph{"$f.upd"}) && ($ph{"$f.upd"} eq 'c')){
           print STDERR "Action Items: !c log,$ph{A1a} $f  $ph{pub}\n";
			#  print STDERR "ERROR: need check for A8a corrections $ph{A1a}\n";
            if($ph{A1a}=~/^(D\w{3})\\/){
                 my @results =
                  get_unique_key_for_featureprop( $self->{db}, $unique,
                    'Non_Dmel_location', $ph{pub} );
                foreach my $t (@results) {
                    my $num = get_fprop_pub_nums( $self->{db}, $t->{fp_id} );
                    if ( $num == 1 || (defined($frnum{$unique}{$ti_fpr_type{$f}}{$t->{rank}}) && $num-$frnum{$unique}{$ti_fpr_type{$f}}{$t->{rank}}==1)) {
                        $out .=
                          delete_featureprop( $doc, $t->{rank}, $unique,
                            'Non_Dmel_location');
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_featureprop_pub( $doc, $t, $unique,
                            'Non_Dmel_location', $ph{pub} );
                    }
                    else {
                        print STDERR "ERROR: something Wrong, please validate first\n";
                    }
                }
            }
            else{
				 my @frresults=get_unique_key_for_featureprop($self->{db}, $unique,'inferred_cyto', $ph{pub});
				 foreach my $t(@frresults){
				     my $num = get_fprop_pub_nums( $self->{db}, $t->{fp_id} );
					  if ( $num == 1 || (defined($frnum{$unique}{$ti_fpr_type{$f}}{$t->{rank}}) && $num-$frnum{$unique}{$ti_fpr_type{$f}}{$t->{rank}}==1)) {
						  $out .= delete_featureprop( $doc, $t->{rank},
							  $unique, 'inferred_cyto'); 
					  } elsif ( $num > 1) { 
						  $out .= delete_featureprop_pub( $doc, $t, $unique, 'inferred_cyto', $ph{pub}); 
					  } else { 
						  print STDERR "ERROR: something Wrong, please validate first\n"; 
					  }
				 }
             my @results =
                  get_unique_key_for_fr( $self->{db}, 'object_id', 'subject_id',
                    $unique, $ti_fpr_type{$f}, $ph{pub} );
					 my $Nn=@results;
					 print STDERR "number of fr $Nn\n";
                foreach my $ta (@results) {
                    my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );
                    print STDERR "$ta->{fr_id}\n";
                    if ( $num == 1 ) {
                        $out .=
                          delete_feature_relationship( $self->{db}, $doc, $ta,
                            'object_id', 'subject_id', $unique, $ti_fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_feature_relationship_pub( $self->{db}, $doc,
                            $ta, 'object_id', 'subject_id', $unique, $ti_fpr_type{$f},
                            $ph{pub} );
                          foreach my $stype('progenitor','cyto_left_end','cyto_right_end'){
                            my @subs= get_unique_key_for_fr($self->{db}, 'subject_id','object_id',
                            $ta->{name},$stype,$ph{pub});
                            foreach my $st(@subs){
                                my $s_n=get_fr_pub_nums($self->{db}, $st->{fr_id});
                                if($s_n==1){
                                   $out .=
                          delete_feature_relationship( $self->{db}, $doc, $st,
                            'subject_id', 'object_id', $ta->{name}, $stype );
                                }
                                elsif($s_n>1){
                                 $out .=
                          delete_feature_relationship_pub( $self->{db}, $doc,
                            $st, 'subject_id', 'object_id', $ta->{name}, $stype,
                            $ph{pub} );
                                }
                                } 
                            }                       
                    }
                    else {
                        print STDERR "ERROR: something Wrong, please validate first\n";
                    }
                }
            }
           }



           if(length($ph{$f})>1){
                print STDERR "STATE: A8a field\n";
                ###if not Dmel featureprop.type='Non_Dmel_location'
               
                if($ph{A1a}=~/^(D\w{3})\\/){
                    my ($g,$s)=get_organism_by_abbrev($self->{db},$1);
                    if($g ne '0'){
                        my $br_type = 'non_Dmel_location';
                        $ph{$f}=~s/\n/ /g;
                        $out.=write_featureprop( $self->{db}, $doc, $unique, $ph{$f},
                        $br_type, $ph{pub});
                        print STDERR "NON DMEL LOCATION\n";
                        next;
                    }
                }
            
                ###if [][], will only write for featureprop
                if($ph{$f} =~/\[\]/){
                    print STDERR "PROBLEM: check value of inferred_cyto, should be [][]\n";
                    my $br_type = 'inferred_cyto';
                    my $v=$ph{$f};
                    $v=~s/\n\d\:\s/;/g;
                    $v=~s/\s+$//;
                    $v=~s/^;//;
                    $v=~s/;$//;
                    $v=~s/\n//g;
                    $out.=write_featureprop( $self->{db}, $doc, $unique, $v,
                        $br_type, $ph{pub});
                   
                }
                else{
                    ###chromosome_breakpoint feature uniquename=$ph{A1a}.':bk'.$order
                    my $loc     = '';
                    my @items = split( /\n/, $ph{$f} );
                    foreach my $item (@items) {
                        $item =~ s/^\s+//;
                        $item =~ s/\s+$//;
                        if ( $item ne '' ) {
                            my $order=0;
                            my $left='';
                            my $right='';
                            if($item=~/(\d+):(.*)/){
                                $order=$1;
                                $item=$2;
                                if($item=~/(.*?)-+(.*)/ && !($item=~/\{.*\}/)){
                                    $left=$1;
                                    $right=$2;
                                }
                                else{
                                    $left=$item;
                                    $right=$item;
                                }
                            }
                            print STDERR "$order, $left,$right\n";
                            $left=~s/^\s+//;
                            $left=~s/\s+$//;
                            $right=~s/^\s+//;
                            $right=~s/\s+$//;
                            if($left ne ''){
                                my $br_unique  = $ph{A1a} . ':bk' . $order;
                                print STDERR "Create $br_unique\n";
                                my $br_feature = create_ch_feature(
                                  doc        => $doc,
                                  uniquename => $br_unique,
                                  name       => $br_unique,
                                  type       => 'chromosome_breakpoint',
                                  genus      => 'Drosophila',
                                  species    => 'melanogaster',
                                  macro_id   => $br_unique,
                                  no_lookup  => 1
                                );
                                $out .= dom_toString($br_feature);
                                $br_feature->dispose();
                                print STDERR "Create feat rel $unique $br_unique\n";
                                my $brfr = create_ch_fr(
                                    doc          => $doc,
                                    'subject_id'  => $br_unique,
                                    'object_id' => $unique,
                                    rtype        => $ti_fpr_type{$f}
                                );
                                my $brpub = create_ch_fr_pub(
                                    doc    => $doc,
                                    pub_id => $ph{pub}
                                );
                                $brfr->appendChild($brpub);
                                $out .= dom_toString($brfr);
                                $brfr->dispose();
                           
                                if($left =~/^P/){  
                              
                                  my $s_unique='';
                                
                                  if(exists($fbids{$left})){
                                    $s_unique=$fbids{$left};
                                  }
                                  else{
                                
                                   ( $s_unique, my $s_genus, my $s_species, my $s_type )
                                    = get_feat_ukeys_by_name($self->{db}, $left);
                                    if($s_unique eq '0'){
                                      print STDERR "ERROR: could not find uniquename for $left $f\n";
                                    }
                                    else{
                                      my $leftfeature = create_ch_feature(
                                        doc        => $doc,
                                        uniquename => $s_unique,
                                        type       => $s_type,
                                        genus      => $s_genus,
                                        species    => $s_species,
                                        macro_id   => $s_unique
                                      );
                                
                                      $out .= dom_toString($leftfeature);
                                      $leftfeature->dispose();
                                    }
                                  }
                         
                                  my $fr = create_ch_fr(
                                     doc          => $doc,
                                     'object_id'  => $s_unique,
                                     'subject_id' => $br_unique,
                                     rtype        => 'progenitor'
                                  );
                                  my $frpub = create_ch_fr_pub(
                                    doc    => $doc,
                                    pub_id => $ph{pub}
                                  );
                                  $fr->appendChild($frpub);
                                  $out .= dom_toString($fr);
                                  $fr->dispose();
                                }
                            
                                else {  # left not starting with P
                                  print STDERR "NOt starting P=> ==$left, $right==\n";
                                  if(defined($left) && $left ne ''){
                                    $loc .= '[' . $left . '-' . $right . '];';
                                    my $left_unique = 'band-' . $left;
                                    my ( $o_g,$o_s,undef)=get_feat_ukeys_by_uname($self->{db},$left_unique);
                                    if($o_g eq '0'){
                                        print STDERR "ERROR: --$left_unique-- could not found in DB\n";
                                    }
                                    my $leftfeature = create_ch_feature(
                                      doc        => $doc,
                                      uniquename => $left_unique,
                                      name       => $left_unique,
                                      type       => 'chromosome_band',
                                      genus      => $o_g,
                                      species    => $o_s,
                                      no_lookup  => 1,
                                      macro_id   => $left_unique
                                    );
                                    $out .= dom_toString($leftfeature);
                                    $leftfeature->dispose();
                                    my $fr2 = create_ch_fr(
                                      doc          => $doc,
                                      'subject_id' => $br_unique,
                                      'object_id'  => $left_unique,
                                      rtype =>'cyto_left_end'
                                    );
                                    my $fr2_pub = create_ch_fr_pub(
                                      doc    => $doc,
                                      pub_id => $ph{pub}
                                    );
                                    $fr2->appendChild($fr2_pub);
                                    $out .= dom_toString($fr2);
                                    $fr2->dispose();
                                    my $right_unique = 'band-' . $right;
                                    my ( $s_g,$s_s,undef)=get_feat_ukeys_by_uname($self->{db},$right_unique);
                                    if($s_g eq '0'){
                                        print STDERR "ERROR: $right_unique could not found in DB\n";
                                    }
                                    my $rightfeature = create_ch_feature(
                                      doc        => $doc,
                                      uniquename => $right_unique,
                                      name       => $right_unique,
                                      type       => 'chromosome_band',
                                      genus      => $s_g,
                                      species    => $s_s,
                                      macro_id   => $right_unique,
                                      no_lookup  => 1
                                    );
                                    $out .= dom_toString($rightfeature);
                                    $rightfeature->dispose();
                                    my $fr3 = create_ch_fr(
                                      doc          => $doc,
                                      'subject_id' => $br_unique,
                                      'object_id'  => $right_unique,
                                      rtype=>'cyto_right_end'
                                    );
                                    my $fr3_pub = create_ch_fr_pub(
                                      doc    => $doc,
                                      pub_id => $ph{pub}
                                    );
                                    $fr3->appendChild($fr3_pub);
                                    $out .= dom_toString($fr3);
                                    $fr3->dispose();
                                  }  # END left and not ''
                                }   # END left not starting with P
                            }
                            else{
                                print STDERR "ERROR: Incorrect format assignment in '$item'. Expected (\\d+):(\\w+)-(\\w+)";
                            }
                        }
                        
                    }
                    if($loc ne ''){
                        $out.=write_featureprop( $self->{db}, $doc, $unique, $loc,
                        'inferred_cyto', $ph{pub});
                    }
                    
                }
            }
        }

    }
   
    return ($out,$unique);
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
    
  
      if(exists($ph{A1f})){
	if ($ph{A1g} eq 'n' ) {
	    print STDERR "Aberr Merge  A1g = n check: does A1a $ph{A1a} exist\n";
	    my $va = validate_new_name($db, $ph{A1a});
	    if($va == 1){
	    print STDERR "ERROR: Aberr Merge  A1g = n and A1a $ph{A1a} exists\n";
		exit(0);
	    }
	}
         my $tmp=$ph{A1f};
         $tmp=~s/\n/ /g;
         print STDERR "Action Items: Aberration merge $tmp\n";
         
         ( $unique, $flag ) = get_tempid( 'ab', $ph{A1a} );
          print STDERR "STATE: get temp id for $ph{A1a} $unique\n";
        if ( $ph{A1a} =~ /^(.{4})\\(.*)/ ) {
            ( $genus, $species ) = get_organism_by_abbrev( $self->{db}, $1 );
        }
        if($genus eq '0'){
            $genus='Drosophila';
            $species='melanogaster';
        }
        if($flag ==1){
            print STDERR "ERROR: could not assign temp id for $ph{A1a}\n";
            exit(0);
        }
        else{
             $feature = create_ch_feature(
                uniquename => $unique,
                name       => decon( convers( $ph{A1a} ) ),
                genus      => $genus,
                species    => $species,
                type       => 'chromosome_structure_variation',
                doc        => $doc,
                macro_id   => $unique,
                no_lookup  => '1'
            );
            $out.=dom_toString($feature);
             $out .=
              write_feature_synonyms( $doc, $unique, $ph{A1a}, 'a',
                'unattributed', 'symbol' );
        }
   }
   else{
   if ( $ph{A1g} eq 'y' ) {
        ( $unique, $genus, $species, $type ) =
          get_feat_ukeys_by_name_type( $self->{db}, $ph{A1a},  'chromosome_structure_variation' );
          if($unique eq '0' or $unique eq '2'){
               print STDERR "ERROR: could not find $ph{A1a} in the database\n";
           }
          else{
            if (exists($ph{A1h})){
             if($ph{A1h} ne $unique){
                print STDERR "ERROR: A1h and A1a not match\n";
             }
           }
        $feature = &create_ch_feature(
            doc        => $doc,
            uniquename => $unique,
            species    => $species,
            genus      => $genus,
            type       => 'chromosome_structure_variation',
            macro_id   => $unique,
            no_lookup  => 1
        );
        if ( exists( $ph{A27a} ) && $ph{A27a} eq 'y' ) {
            print STDERR "Action Items: delete Aberration $ph{A1a}\n";
            my $op = create_doc_element( $doc, 'is_obsolete', 't' );
            $feature->appendChild($op);
        }
         if(exists($fbids{$ph{A1a}})){
            my $check=$fbids{$ph{A1a}};
            if($unique ne $check){
                print STDERR "ERROR: $check and $unique are not same for $ph{G1a}\n"; 
                   
            }
        }
        $out.=dom_toString($feature);
          $fbids{$ph{A1a}}=$unique;
          print STDERR "get id for $ph{A1a} $unique\n";
        }   
    }
    else {
     my $va=validate_new_name($db, $ph{A1a});
     if(exists($ph{A1e})){
	 if(exists($fbids{$ph{A1e}})){
	     print STDERR "ERROR: Rename A1e $ph{A1e} exists in a previous proforma\n";
	 }
	 if(exists($fbids{$ph{A1a}})){                                    
	     print STDERR "ERROR: Rename A1a $ph{A1a} exists in a previous proforma \n";
	 }  
	 print STDERR "Action Items: rename aberration $ph{A1e} to $ph{A1a}\n";
	 ( $unique, $genus, $species, $type ) =
          get_feat_ukeys_by_name_type( $self->{db}, $ph{A1e},  'chromosome_structure_variation' );
                 if($unique eq '0' or $unique eq '2'){
               print STDERR "ERROR: could not find $ph{A1e} in the database\n";
           }
          else{
              $feature = create_ch_feature(
                uniquename => $unique,
                name       => decon( convers( $ph{A1a} ) ),
                genus      => $genus,
                species    => $species,
                type       => 'chromosome_structure_variation',
                doc        => $doc,
                macro_id   => $unique,
                no_lookup  => '1'
            );
            $out.=dom_toString($feature);
             $out .=
              write_feature_synonyms( $doc, $unique, $ph{A1a}, 'a',
                'unattributed', 'symbol' );
                  $fbids{$ph{A1a}}=$unique;
            $fbids{$ph{A1e}}=$unique;
        }
        }
        
        else{
        ### if the temp id has been used before, $flag will be 1 to avoid
        ### the DB Trigger reassign a new id to the same symbol.
        if($va==1){
        $flag=0;
              ($unique,$genus,$species,$type)=get_feat_ukeys_by_name_type($db,$ph{A1a},  'chromosome_structure_variation' );
              $fbids{$ph{A1a}}=$unique;
        }
        else{
      
        ( $unique, $flag ) = get_tempid( 'ab', $ph{A1a} );
	print STDERR "Action Items: new aberration $ph{A1a} $unique\n";
        if ( $ph{A1a} =~ /^(.*)\\(.*)$/ ) {

            ( $genus, $species ) = get_organism_by_abbrev( $self->{db}, $1 );
        }
        else {
            $genus   = 'Drosophila';
            $species = 'melanogaster';
        }
        }
        if ( $flag == 0 ) {
            $feature = create_ch_feature(
                uniquename => $unique,
                name       => decon(convers($ph{A1a})),
                genus      => $genus,
                species    => $species,
                type    => 'chromosome_structure_variation',
                doc        => $doc,
                macro_id   => $unique,
                no_lookup  => '1'
            );
            $out.=dom_toString($feature);
          $out .=
              write_feature_synonyms( $doc, $unique, $ph{A1a}, 'a',
                'unattributed', 'symbol' );
        
        }
           
           
       else{
            print STDERR "ERROR, name $ph{A1a} has been used in this load\n";
               }
    }
    }
   }
    $fbids{$unique}=decon(convers($ph{A1a}));
    return ($out,$unique);
}
sub parse_segment{
     my $fbid=shift;
	  my $hashref=shift;
	  my $pub_id=shift;
	  my $f=shift;
       my $out='';
	  my %gen=%$hashref;

	  if((exists($gen{$f."a.upd"}) && $gen{$f."a.upd"} eq 'c') 
	  || (exists($gen{$f."b.upd"}) && $gen{$f.'b.upd'} eq 'c') 
	    || (exists($gen{$f."d.upd"}) && $gen{$f.'d.upd'} eq 'c') 
		 || (exists($gen{$f."e.upd"}) && $gen{$f.'e.upd'} eq 'c')
     	) {
        print STDERR "CHECK: !c $fbid $f $pub_id\n";
		}
     if(!exists($gen{$f.'a'}) || !exists($gen{$f.'b'}) ||
	     !exists($gen{$f.'c'}) || !exists($gen{$f.'d'}) ||
		  !exists($gen{$f.'e'})){
	     print STDERR "ERROR: fields not filled for $f a-e \n"; 
	  } 
	  if (exists($gen{$f.'b.upd'}) && $gen{$f.'b.upd'} eq 'c'){
	        my @results = get_unique_key_for_featureprop( $db, $fbid,
                    $ti_fpr_type{$f.'a'}, $pub_id);
          if(@results==0){
            print STDERR "ERROR: could not find previous records in the database $fbid, $pub_id $f b\n";
          } 
           foreach my $t (@results) {
                my $num = get_fprop_pub_nums( $db, $t->{fp_id} );
                 if ( $num == 1 ) {
                     $out .=
                         delete_featureprop( $doc, $t->{rank}, $fbid,
                           $ti_fpr_type{$f.'a'} );
                  }
                 elsif ( $num > 1 ) {
                      $out .=
                        delete_featureprop_pub( $doc, $t, $fbid,
                       $ti_fpr_type{$f.'a'} , $pub_id );
                  }
                 else {
                      print STDERR "something Wrong, please validate first\n";
                  }
             }
	  }
	  if(defined($gen{$f.'a'}) && defined($gen{$f.'b'}) && 
		  $gen{$f.'b'} ne '' && defined($gen{$f.'c'}) &&
		  $gen{$f.'c'} ne ''
	  ){
	  my $value=$gen{$f.'b'}."--".$gen{$f.'c'};
	  if($gen{$f.'d'} eq 'y'){
	    $value.=" (Estimated cytology)";
	  }
	  if($gen{$f.'e'} eq 'y'){
		  $value.=" (Observed cytology)";
	  }
	  
	  $out.=write_featureprop($db,$doc,$fbid,$value,$ti_fpr_type{$f.'a'},$pub_id);
  }
   return $out;
}
sub parse_multiple_break{
    my $fbti    = shift;
    my $hashref = shift;       ##reference to hash
    my $pub_id  = shift;
    my %gen_loc = %$hashref;
    my $srcfeat = '';
    my $featureloc;
    my $group;
    my $out     = '';
    my $genus   = 'Drosophila'; ##predefined, should modify according to the aberr
    my $species = 'melanogaster';
    if ((exists($gen_loc{'A90b.upd'}) && $gen_loc{'A90b.upd'} eq 'c') ||
          (exists($gen_loc{'A90c.upd'}) && $gen_loc{'A90c.upd'} eq 'c')  ||
          (exists($gen_loc{'A90h.upd'}) && $gen_loc{'A90h.upd'} eq 'c')  ||
          (exists($gen_loc{'A90j.upd'}) && $gen_loc{'A90j.upd'} eq 'c')) {
      print STDERR "CHECK: !c not tested, $fbti A90 $pub_id\n";
       
        #$out .= delete_featureloc( $db, $doc, $fbti, $pub_id );
    }
    if ( defined( $gen_loc{A90a} ) && $gen_loc{A90a} ne '' ) {
      my $br_feature = "";
        my $br_unique  = $fbids{$fbti} . ':bk' . $gen_loc{A90a};
        my ($g,$s,$ta)=get_feat_ukeys_by_uname($db, $br_unique);
        if($g ne '0' && $g ne '2'){
            print STDERR "CHECK: chromosome_breakpoint $br_unique already in DB $g, $s, $ta\n";
	    $br_feature = create_ch_feature(
                                doc        => $doc,
                                uniquename => $br_unique,
                                type       => $ta,
                                genus      => $g,
                                species    => $s,
                                macro_id   => $br_unique,
                            );
        }
      else{
        print STDERR "ADDING A90a: $br_unique\n";
        $br_feature = create_ch_feature(
                                doc        => $doc,
                                uniquename => $br_unique,
                                name       => $br_unique,
                                type       => 'chromosome_breakpoint',
                                genus      => 'Drosophila',
                                species    => 'melanogaster',
                                macro_id   => $br_unique,
                                no_lookup  => 1
                            );
      }
       $out .= dom_toString($br_feature);
       $br_feature->dispose();
        my $brfr = create_ch_fr(
                        doc          => $doc,
                                    'subject_id'  => $br_unique,
                                    'object_id' => $fbti,
                                    rtype        => $ti_fpr_type{A90a}
              );
       my $brpub = create_ch_fr_pub(
                                    doc    => $doc,
                                    pub_id => $pub_id
                            );
       $brfr->appendChild($brpub);     
        
       $out .= dom_toString($brfr);
       $brfr->dispose();
       if (exists($gen_loc{'A90b.upd'}) && $gen_loc{'A90b.upd'} eq 'c'){
            print STDERR "CHECK: breakpoint $br_unique !c A90b\n";
	 
       ($group)=get_featureloc_ukeys_bypub($db,$br_unique,$pub_id);
           my @results =
                  get_unique_key_for_featureprop( $db, $br_unique,
                    'reported_genomic_loc', $pub_id, 'GenBank feature qualifier');
           if(@results==0){
            print STDERR "ERROR: could not find previous records in the database $fbti,$br_unique $pub_id A90b\n";
           }
                foreach my $t (@results) {
#		  print STDERR "CHECK: chromosome_breakpoint $br_unique !c A90b check featureprop\n";
                    my $num = get_fprop_pub_nums( $db, $t->{fp_id} );
                    if ( $num == 1 ) {
#		      print STDERR "CHECK: chromosome_breakpoint $br_unique !c A90b 1 featureprop\n";		      
                        $out .=
                          delete_featureprop( $doc, $t->{rank}, $br_unique,
                           'reported_genomic_loc', 'GenBank feature qualifier' );
                    }
                    elsif ( $num > 1 ) {
#		      print STDERR "CHECK: chromosome_breakpoint $br_unique !c A90b >1 featureprop\n";		      

                        $out .=
                          delete_featureprop_pub( $doc, $t->{rank}, $br_unique,
                           'reported_genomic_loc', $pub_id, 'GenBank feature qualifier' );
                    }
                    else {
                        print STDERR "something Wrong, please validate first\n";
                    }
                }
           print STDERR "CHECK: chromosome_breakpoint $br_unique !c A90b delete featureloc\n";
	    
          $out.=delete_featureloc($db,$doc,$br_unique,$pub_id);
       }
       if(defined($gen_loc{A90b}) && $gen_loc{A90b} ne ''){
        my $fmin;
        my $fmax;
        my ( $arm,  $location ) = split( /:/,    $gen_loc{A90b} ); 
        if(defined($location)){
         ( $fmin, $fmax )     = split( /\-\-|\.\./, $location );
        if(!defined($fmax) && defined($fmin)){
            $fmax=$fmin;
          }
        }
	else{
            print STDERR "ERROR: Something wrong with A90b  $gen_loc{A90b} please fix \n";
	}
        if($fmin>$fmax){
            print STDERR "ERROR: fmin >fmax $fmin $fmax\n";
            my $tmp=$fmin;
            $fmin=$fmax;
            $fmax=$tmp;
        }
        if($arm eq '1'){
            $arm='X';
          }
           $srcfeat=$arm;  
        if ( defined($gen_loc{A90c}) ) {
            if ( $gen_loc{A90c} eq '4' ) {
                $srcfeat = $arm . '_r4';
		print STDERR "ERROR WARN: A90c Release 4 will not display in Sequence coordinates\n";
	    }
            elsif($gen_loc{A90c} eq '3'){
                $srcfeat=$arm.'_r3';
 		print STDERR "ERROR WARN: A90c Release 3 will not display in Sequence coordinates\n";
           
            }
            elsif($gen_loc{A90c} eq '5'){
                $srcfeat=$arm.'_r5';
 		print STDERR "ERROR WARN: A90c Release 5 will not display in Sequence coordinates\n";
           
            }
        }
        if (!($srcfeat=~/.*_r?/)){
           $srcfeat.='_r6';    
        }
 	
	my $type='golden_path';
	if($arm eq 'mitochondrion_genome'){
	    $type='chromosome'; 
	}
	if ( exists ($gen_loc{A90c}) && $gen_loc{A90c} eq '6' ) {
     
        
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
		if(!defined($group)){
		    $group = &get_max_locgroup($db, $br_unique,$arm,$fmin, $fmax);
		}
		$featureloc = create_ch_featureloc(
		    doc           => $doc,
		    feature_id    => $br_unique,
		    srcfeature_id => $src,
		    fmin          => $fmin,
		    fmax          => $fmax,
		    locgroup      => $group
		    );
		print STDERR "DEBUG A90c Release 6 create featureloc feature $br_unique srcfeature $arm fmin $fmin fmax $fmax locgroup $group\n";
		
	}
        else{
	    if(!defined($group)){
		$group = &get_max_locgroup($db, $br_unique,$arm);
	    }
	    $featureloc = create_ch_featureloc(
		doc           => $doc,
		feature_id    => $br_unique,
		srcfeature_id => $src,
		locgroup      => $group
		);
		print STDERR "DEBUG A90c Release 6 create featureloc feature $br_unique srcfeature $arm locgroup $group\n";
        }
        my $fl_pub =
          create_ch_featureloc_pub( doc => $doc, pub_id => $pub_id );
        $featureloc->appendChild($fl_pub);
        $out .= dom_toString($featureloc);
        $featureloc->dispose();
	my $value=$srcfeat.":".$fmin.'..'.$fmax;
        my $rank=get_max_featureprop_rank($db,$br_unique,'reported_genomic_loc',$value,'GenBank feature qualifier');
        my $fp=create_ch_featureprop(doc=>$doc,feature_id=>$br_unique,
                                     rank=>$rank,  cvname=>'GenBank feature qualifier',
                                     type=>'reported_genomic_loc', value=>$value);
        my $fpp=create_ch_featureprop_pub(doc=>$doc, pub_id=>$pub_id);
        $fp->appendChild($fpp);
        $out.=dom_toString($fp);
	}
       }

      my $cv = 'GenBank feature qualifier';
      if(defined($gen_loc{A90h}) && $gen_loc{A90h} ne ''){
	  my $value2=$gen_loc{A90h}; 
	  $value2=trim($value2);
	  $value2=~s/\n/ /g;
	  $out.=write_featureprop_cv($db, $doc, $br_unique, $value2,
                        $ti_fpr_type{A90h}, $pub_id,$cv);
      }
      if(defined($gen_loc{"A90h.upd"}) && $gen_loc{"A90h.upd"} eq 'c'){
	  $out.=remove_featureprop_function($db, $doc, $br_unique, $ti_fpr_type{A90h}, $pub_id, $cv); 
      }
      if(defined($gen_loc{A90j}) && $gen_loc{A90j} ne ''){
	  my $value2=$gen_loc{A90j};
	  $value2=trim($value2);
	  $value2=~s/\n/ /g;
	  $out.=write_featureprop($db, $doc, $br_unique, $value2,
                        $ti_fpr_type{A90j}, $pub_id);
      }
      if(defined($gen_loc{"A90j.upd"}) && $gen_loc{"A90j.upd"} eq 'c'){
	  $out.=remove_featureprop_function($db, $doc, $br_unique,
                        $ti_fpr_type{A90j}, $pub_id);
      }  
    }
    print STDERR "CHECK: leaving parse_multiple_break  A90\n";
  
    return $out;

}
=head2 $pro->validate(%ph)

   validate the following:
    1. A10 and A8b not implemented yet.
	2. validate A7[a-f], A1f, A25[a-f], A23,A6, A19a, A24b the values 
	   following those fields have
	   to be a valid symbol in the database.
	3. if !c exists, check whether this record already in the DB.

=cut

sub validate {
    my $self   = shift;
    my $tihash = {@_};
    my %tival  = %$tihash;

    my $v_unique = '';
    print STDERR "Validating Aberration ", $tival{A1a}, " ....\n";
    
    if(exists($fbids{$tival{A1a}})){
        $v_unique=$fbids{$tival{A1a}};
    }
    else{
        print STDERR "ERROR: did not have the first parse\n";
    }
    
    if ( exists( $tival{A10} ) ) {
        print STDERR "ERROR: A10 is not implemented yet.\n";
    }
   # if ( exists( $tival{A11} ) ) {
   #     print STDERR "ERROR: A11 is not implemented yet\n";

   # }
    if ( exists( $tival{A8b} ) && length( $tival{A8b} ) > 12 ) {
        print STDERR "ERROR: A8b is not implemented yet $tival{A8b}", "\n";

    }
    if ( $v_unique =~ 'FBab:temp' ) {
        foreach my $fu ( keys %tival ) {
            if ( $fu =~ /(.*)\.upd/ ) {
                print STDERR "Wrong !c fields  $1 for a new record \n";
            }
        }
    } 
    
   if(exists($tival{A2c}) && !exists($tival{A2a})){
            print STDERR "ERROR: A2c exists for a new symbol without A2a exists\n";
  }
    foreach my $f ( keys %tival ) {
        if ( $f =~ /(.*)\.upd/  && !($v_unique=~/temp/)) {
            $f = $1;
            if (   $f eq 'A16'
                    || $f =~ 'A22'
                    || $f eq '19b'
                    || $f eq 'A7x'
                    || $f eq 'A10'
                    || $f eq 'A18'
                    || $f eq 'A14'
                    || $f eq 'A25x'
                    || $f eq 'A20a'
                    || $f eq 'A21'
                    || $f eq 'A15' )
             {
                    my $num =
                      get_unique_key_for_featureprop( $db, $v_unique,
                        $ti_fpr_type{$f}, $tival{pub} );
                    if ( $num == 0 ) {
                        print STDERR
                          "ERROR:there is no previous record for $f field.\n";
                    }
              }
            elsif ($f =~ 'A7[a-f]'
                    || $f eq 'A25[a-f]'
                    || $f eq 'A19a'
                    || $f eq 'A24b'
                    || $f eq 'A6'
                    || $f eq 'A23' )
            {
                    my $num =
                      get_unique_key_for_fr( $db, 'subject_id', 'object_id',
                        $v_unique, $ti_fpr_type{$f}, $tival{pub} );
                    if ( $num == 0 ) {
                        print STDERR
                          "ERROR: There is no previous record for $f field\n";
                    }
            }
       }
        elsif (   $f =~ 'A7[a-f]$'
                || $f =~ 'A25[a-f]$'
                || $f eq 'A19a'
                || $f eq 'A1f'
                || $f eq 'A24b'
                || $f eq 'A6'
                || $f eq 'A23' )
            {
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
         elsif($f eq 'A9' || $f eq 'A26' ||  $f eq 'A4'){
             my @items = split( /\n/, $tival{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
               
                validate_cvterm($db,$item,$ti_fpr_type{$f});
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

proforma mapping table can be found in ~haiyan/Documents/aberrmapping.sxw 

chado schema can be found in http://www.gmod.org

=head1 SEE ALSO

FlyBase::WriteChado
FlyBase::Proforma::Aberr;
FlyBase::Proforma::Allele;
FlyBase::Proforma::Balancer;
FlyBase::Proforma::Cell_line;
FlyBase::Proforma::DB;
FlyBase::Proforma::Feature;
FlyBase::Proforma::Gene;
FlyBase::Proforma::HH;
FlyBase::Proforma::Interaction;
FlyBase::Proforma::Library;
FlyBase::Proforma::MultiPub;
FlyBase::Proforma::Pub;
FlyBase::Proforma::SF;
FlyBase::Proforma::Strain;
FlyBase::Proforma::TE;
FlyBase::Proforma::TI;
FlyBase::Proforma::TP;
FlyBase::Proforma::Util;
XML::Xort

=head1 Proforma

! ABERRATION PROFORMA                    Version 36: 6 July 2007
!
! A1a.  Aberration symbol to use in database           *a :
! A1b.  Aberration symbol used in paper                *i :
! A1e.  Action - rename this aberration symbol            :
! A1f.  Action - merge aberrations                        :
! A1g.  Is A1a the valid symbol of an aberration in FlyBase? :y
! A2a.  Aberration name to use in database             *e :
! A2b.  Aberration name used in paper                  *Q :
! A2c.  Database aberration name(s) to replace         *Q :
! A27a. Action - delete aberration        - TAKE CARE :
! A27b. Action - dissociate A1a from FBrf - TAKE CARE :
! A4.   Mutagen  [CV]                                  *o :
! A16.  Discoverer                                     *w :
! A6.   Progenitor genotype                            *O :
! A22a. Notes on origin [SoftCV]                       *R :
! A22b. Notes on origin [free text]                    *R :
! A23.  Parent chromosome (for segregants - *Y)           :
! A7a. Genes removed or broken by the aberration (Df) in A1a (complementation)   *q :
! A7b. Genes fully duplicated in the Dp in A1a (complementation)     *q :
! A7c. Genes NOT removed or broken by the aberration (Df) in A1a (complementation) *q :
! A7d. Genes NOT included in the Dp in A1a (complementation)         *q :
! A7e. Genes partially disrupted by the Df in A1a (complementation) *q :
! A7f. Genes partially duplicated in the Dp in A1a (complementation)*q :
! A7x. Non-standard complementation data (free text, usually for A7e, A7f) *q :
! A17. Phenotype (not associated with specified alleles)    *p :
! A19a. Phenotype in combination with other abs [SoftCV]    *T :
! A19b. Phenotype in combination with other abs [free text] *T :
! A8a. Breaks: cytological or progen break ranges       *B :
1:
2:
3:
! A8b. Segments: cytological ranges of ends *B :
1:
2:
3:
! A9. Type of aberration relative to progenitor [CV]   *C :
! A10. Known new junction(s) of A8a sides *N :
! A11. New order of A8b segments          *N :
! A18. Comments about cytology            *c :
! A26. Type of aberration relative to wild-type  [CV]  *C :
! A24a. Transposon insertions             *P :
! A24b. Non-insert allele(s)              *S :
! A14. Other comments                     *u :
! A25a. Genes fully removed by the aberration (Df) in A1a (molecular) NSC
        :
! A25b. Genes fully duplicated in the Dp in A1a (molecular)  NSC        :
! A25c. Genes NOT removed or broken by the aberration (Df) in A1a (molecular)  NSC      :
! A25d. Genes NOT included in the Dp in A1a (molecular) NSC             :
! A25e. Genes partially removed or broken by the aberration (Df) in A1a (molecular) NSC :
! A25f. Genes partially included in the Dp in A1a (molecular) NSC       :
! A25x. Molecular data (free text, usually for A25e, A25f) NSC :
! A20a. A1a polymorphism data reported?   *K :n
! A21. Information on availability        *v :
! A28. Accession number (seq cur only) TAKE CARE :
! A15. Internal notes                     *K :
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

=head1 AUTHOR

Haiyan Zhang, E<lt>haiyan@morgan.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
