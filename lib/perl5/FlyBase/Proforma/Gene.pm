package FlyBase::Proforma::Gene;

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

FlyBase::Proforma::Gene - Perl module for parsing the FlyBase
Gene  proforma version 44, Dec 1, 2006.

See the bottom for the proforma
                         
=head1 SYNOPSIS

  use FlyBase::Proforma::Gene;
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

FlyBase::Proforma::Gene is a perl module for parsing FlyBase
Gene proforma and write the result as chadoxml. It is required
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
    'G1a', 'symbol',      #feature_synonym
    'G1b', 'symbol',      #feature_synonym
    'G1e', 'symbol',      #feature_synonym
    'G1f', 'merge',       #merge_function
    'G1g', 'new',         #checking
    'G2a', 'fullname',    #feature_synonym
    'G2b', 'fullname',    #feature_synonym
    'G2c', 'fullname',    #feature_synonym

    'G30',  'SO',                #feature_cvterm
    'G31a', 'is_obsolete',       #feature.is_obsolete
    'G31b', 'dissociate_pub',    #feature_pub...
    'G27',  'etymology',         #feature_genotype,genotype,phendesc

    'G20a', 'in_title_or_abstract/significant_subject_in_review'
    ,                            #featureprop: Analysis:subject #not in chado
    'G20b', 'is_expression_analysed_in_wildtype', #featureprop:Analysis: WT-exp
    'G20c', 'is_expression_analysed_in_mutant',   #featureprop:Analysis: mut-exp
    'G20d', 'is_genome_annotation_analysed',      #featureprop:Analysis: genome
    'G20e', 'is_physical_interaction_analysed', # featureprop:Analysis: physical
    'G20f', 'is_cis-reg_analysed',              #featureprop:Analysis: cis-reg
    'G20g', 'is_gene_model_decorated',          #featureprop: Analysis: mut-map
    'G20h', 'is_polymorphism_reported',    #featureprop: Analysis: polymorph
    'G20i', 'has_GO_curation', 
    'G10a', 'cyto_left_end/cyto_right_end',    #feature_relationship.object_id
    'G10b', 'cyto_left_end/cyto_right_end',    #feature_relationshipprop
    'G11',  'cyto_loc_comment',                #featureprop
    'G25', 'maps_to_clone/nomaps_to_clone/identified_with',    #feature_relationship
    'G19a', 'gene_order',                               #featureprop
    'G19b', 'molecular_info',                           #featureprop
    'G12a', 'wild_type_role',                           #featureprop
    'G12b', 'gene_phenotypes',                          #feature_relationship
    'G14a', 'misc',                                     #featureprop
    'G14b', 'identified_by',                            #featureprop
    'G28a', 'gene_relationships',                       #featureprop
    'G28b', 'merge_source/identity_source',             #featureprop
    'G29a',
    'fnally_comps/fnally_noncomps/fnally_partcomps/gain_of_fn_species'
    ,    #feature_relationship.object_id, featureprop
    'G29b', 'func_comp_desc',          #featureprop
    'G18',  'interacts_genetically',   #???Rachel.feature_relationship.object_id
    'G22',  'homologue',               #feature_relationship.object_id
    'G24a', 'cellular_component',      #???feature_cvterm
    'G24b', 'molecular_function',      #???feature_cvterm
    'G24c', 'biological_process',      #???feature_cvterm
    'G24e', 'GO_internal_notes',       #featureprop
    'G24g', 'GO_review_date',       #featureprop
    'G15',  'internal_notes',          #featureprop
    'G17t', 'rec_position_effect',     #feature_relationship.object_id
    'G17u', 'no_position_effect',      #feature_relationship.object_id
    'G17v', 'dom_position_effect',     #feature_relatinoship.object_id
    'G5',   'genetic_location',        #featureprop
    'G6',   'gen_loc_error',           #featureprop
    'G7a',  'recom_left_end',          #??feature_relationship.object_id
    'G7b',  'recom_right_end',         #??feature_relationship.object_id
    'G8',   'gen_loc_comment',         #featureprop
    'G26',  'foreign_seq_data',
    'G33',  'feature_dbxref',          #feature_dbxref
    'G34',  'reported_antibod_gen' ,   #featureprop
    'G35',  'feature_dbxref',          #feature_dbxref
    'G91',  'library_feature',  #library_feature
    'G91a', 'library_featureprop',  #library_featureprop
    'G37',  'grpmember_feature', # feature_grpmember (grpmember.grp_id grpmember.type_id cv=grpmember type, cvterm=grpmember_feature feature_grpmember.feature_id G1a) plus organism_grpmember (grpmember.grp_id grpmember.type_id cv=grpmember type, cvterm=grpmember_organism organism_grpmember.organism_id G1a -- only 1 per grp??)
    'G39a',  'gene_summary_text', # featureprop single value
    'G39b',  'gene_summary_info',  #featureprop single value y or n
    'G39c',  'gene_summary_date', #featureprop single value behave like G24f
    'G39d',  'gene_summary_internal_notes', #featureprop multiple values
    'G40',   'FlyBase miscellaneous CV', #feature_cvterm Encoded experimental tools (CV) feature_cvtermprop type common_tool_uses
    'G38',  'member_gene_of',  # feature_relationship.object Valid Gene symbol TO7c single
 );
my %feattype = (
    'identified_with', 'cDNA_clone', 'maps_to_clone', 'genomic_clone',
    'nomaps_to_clone', 'genomic_clone', 'G18','gene', 'G38', 'gene'
);
my %featid_type =('G18', 'gn', 'G38','gn');
my %G29atype = (
    'Functionally complements',                     'fnally_comps',
    'Does not functionally complement',             'fnally_noncomps',
    'Partially functionally complements',           'fnally_partcomps',
    'Gain of function effect when expressed in',    'gain_of_fn_species',
    'No gain of function effect when expressed in', 'gain_of_fn_species',
);
my %G25type = (
    'Identified with',       'identified_with',
    'Maps to clone',        'maps_to_clone',
    'Does not map to clone', 'nomaps_to_clone'
);
my %GOabbr = (
    IMP => 'inferred from mutant phenotype',
    IGI => 'inferred from genetic interaction',
    IPI => 'inferred from physical interaction',
    ISS => 'inferred from sequence or structural similarity',
    IDA => 'inferred from direct assay',
    IEA => 'inferred from electronic annotation',
    IEP => 'inferred from expression pattern',
    RCA => 'inferred from reviewed computational analysis',
    TAS => 'traceable author statement',
    NAS => 'non-traceable author statement',
    IC  => 'inferred by curator',
    IGC => 'inferred from genomic context',
    ND  => 'no biological data available',
    ISM => 'inferred from sequence model', 
    ISO => 'inferred from sequence orthology',
    ISA => 'inferred from sequence alignment',
    EXP => 'inferred from experiment',
    IBA =>  'inferred from biological aspect of ancestor',
    IBD =>  'inferred from biological aspect of descendant',
    IKR =>	 'inferred from key residues',
    IRD =>  'inferred from rapid divergence', 
);


my %g91a_type = ('experimental_result', 1 , 'member_of_reagent_collection', 1);
my %fcp_type = ('G40', 'common_tool_uses');

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
    my $genus='Drosophila';
    my $species='melanogaster';
    my $type;
    my $orgabbr='';
    my $grp='';
    my $grpmember='';
    my $out = '';

    if ( exists( $self->{debug} ) && $self->{debug} == 1 ) {
        foreach my $key ( keys %ph ) {
            print STDERR "$key, $ph{$key}\n";
        }
    }

    if ( exists( $self->{validate} ) && $self->{validate} == 1 ) {
        $self->validate(%ph);
    }
    
    if(exists($fbids{$ph{G1a}})){
        $unique=$fbids{$ph{G1a}};
    }
    else{
       print "ERROR: could not get uniquename for $ph{G1a}\n";
        #($unique, $out)=$self->write_feature($tihash);
        return $out;
    }
    print STDERR "processing Gene " . $ph{G1a} . "...\n";
        if(exists($fbcheck{$ph{G1a}}{$ph{pub}})){
        print STDERR "Warning: $ph{G1a} $ph{pub} exists in a previous proforma\n";
    }
    $fbcheck{$ph{G1a}}{$ph{pub}}=1;
    if ( $ph{G1a} =~ /^(.{2,14}?)\\(.*)/ ) {
      $orgabbr=$1;
      ( $genus, $species ) = get_organism_by_abbrev( $self->{db}, $1 );
    }
    if($ph{G1a} =~ /^T:(.{2,14}?)\\(.*)/ ){
      $orgabbr=$1;
      ( $genus, $species ) = get_organism_by_abbrev( $self->{db}, $1 );
    }

    if($genus eq '0'){
      print STDERR "CHECK: organism for $ph{G1a} can not be found default to Dmel\n";
      $genus ='Drosophila';
      $species='melanogaster';
    }
    if(!exists($ph{G31b}) ){
    if( $ph{pub} ne 'FBrf0000000'){
     print STDERR "Action Items: gene $unique == $ph{G1a} with pub $ph{pub}\n"; 
    my $f_p = create_ch_feature_pub(
        doc        => $doc,
        feature_id => $unique,
        pub_id     => $ph{pub}
        );
        $out .= dom_toString($f_p);
        $f_p->dispose();
        }
    } 
    else
    {
            print STDERR "Action Items: $ph{G1a} dissociate with pub $ph{pub}\n";
            $out .= dissociate_with_pub( $self->{db}, $unique, $ph{pub} );
            return ($out, $unique);
    }
    ##Process other field in Trangenic Insertion proforma
    foreach my $f ( keys %ph ) {
        if ( $f eq 'G1b' || $f eq 'G2b' ) {
            if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
            print STDERR "Action Items: !c log,$ph{G1a} $f  $ph{pub}\n";
            $out .=
                      delete_feature_synonym( $self->{db}, $doc, $unique, $ph{pub}, $ti_fpr_type{$f} );
            
            }
            if(defined ($ph{$f}) && $ph{$f} ne ''){
            my @items = split( /\n/, $ph{$f} );
            foreach my $item (@items) {
                $item =~ s/^\s+//;
                $item =~ s/\s+$//;
                my $t = $f;
                $t =~ s/^G\d//;
               
                if ( $item ne 'unnamed' && $item ne '' ) {
                    if ( ( $f eq 'G1b' ) && ( $item eq $ph{G1a} ) ) {
                        $t = 'a';
                    }
                    elsif (( $f eq 'G2b' )
                        && exists( $ph{G2a} )
                        && ( $item eq $ph{G2a} ) )
                    {
                        $t = 'a';
                    }
                    elsif ( !exists( $ph{G2a} ) && $f eq 'G2b' ) {
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
	  elsif($f eq 'G2a'){
	        if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
	           print STDERR "ERROR: G2a can not accept !c\n";
	         }
		my $num = check_feature_synonym( $self->{db},
                            $unique,  'fullname' );
		if( $num != 0){
		  if ((defined($ph{G2c}) && $ph{G2c} eq '' && !defined($ph{G1f})) || (!defined($ph{G2c}) && !defined($ph{G1f}) )) {
		    print STDERR "ERROR: G2a must have G2c filled in unless a merge\n";
		  }
		  else{
		    $out.=write_feature_synonyms($doc,$unique,$ph{$f},'a','unattributed',$ti_fpr_type{$f});
		  }
		}
		else{
		  $out.=write_feature_synonyms($doc,$unique,$ph{$f},'a','unattributed',$ti_fpr_type{$f});
		}
	  }
        elsif ( $f eq 'G1e' || $f eq 'G2c' ) {
           if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
	           print STDERR "ERROR: $f can not accept !c\n";
	         }
	   if ( $f eq 'G2c' ) { 
	       my $t = check_feature_synonym_is_current( $self->{db},
                            $unique, $ph{$f}, $ti_fpr_type{$f} );
	       if ($t ne 'a'){
		   print STDERR "ERROR: $f $ph{$f} is not the current synonym\n";
	       }
	   }
	   $out .=
              update_feature_synonym( $self->{db}, $doc, $unique, $ph{$f},
                $ti_fpr_type{$f} );
              
        }
        elsif ( $f eq 'G31b' ) {
            print STDERR "Action Items: $ph{G1a} dissociate with pub $ph{pub}\n";
            $out .= dissociate_with_pub( $self->{db}, $unique, $ph{pub} );
        }
        elsif ( $f eq 'G1f' ) {
        
            $out .=
              merge_records( $self->{db}, $unique, $ph{$f},$ph{G1a}, $ph{pub} , $ph{G2a});	
                if(defined($ph{G2a})){
                $out.=write_feature_synonyms($doc,$unique,$ph{G2a},'a','unattributed',$ti_fpr_type{G2a});
                }
        }       
         elsif ($f eq 'G33'){
            if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
            print STDERR "Action Items: !c log,$ph{G1a} $f  $ph{pub}\n";
                my @result=get_dbxref_by_feature_db($self->{db},$unique,'GB');
                my @prresult=get_dbxref_by_feature_db($self->{db},$unique,'GB_protein');
                foreach my $tt(@result,@prresult){
                    my $fd=create_ch_feature_dbxref(doc=>$doc,feature_id=>$unique, 
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
         elsif ($f eq 'G35'){
	   if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
	     print STDERR " ERROR: !c not allowed for $f ,$ph{G1a} $f  $ph{pub}\n";
	   }
	   if($ph{$f} ne ''){
	     my @items=split(/\n/,$ph{$f});
	     foreach my $item(@items){
#		 print STDERR "DEBUG:  DB accession = $item\n";    

	       my ($dbn, $dbxref)=split( /:/, $item,2);
	       if(!defined($dbn) && !defined($dbxref)){
		 print STDERR "ERROR: wrong format for DB:accession $item\n";    
	       }
	       else{
		 $dbn = trim($dbn);
		 $dbxref = trim($dbxref);
		 my $junk1 = $dbxref;
		 my $junk = chop ($junk1);
		 if($junk eq '.'){
		     print STDERR "ERROR: An accession maynot end in $junk Fix G35 $ph{G35}\n"; 
		 }     
		 my $val = validate_dbname($self->{db}, $dbn);
		 if($val eq $dbn){
#		 print STDERR "DEBUG:  validated dbname $val = $dbn DB accession = $dbxref\n";    

		   $out.= write_gene_dbxref($self->{db}, $doc, $unique, $dbn, $dbxref);
		 }
		 else{
		     print STDERR "ERROR: No dbname found for DB:accession $item\n";
		 }   
	       }
	     }
	   }
	 }
        elsif ( $f =~ '^G10[a-b]$' ) {
            my $subject = 'subject_id';
            my $object  = 'object_id';
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                    print STDERR "Action Items: !c log,$ph{G1a} $f  $ph{pub}\n";
                foreach my $tp ( 'cyto_left_end', 'cyto_right_end' ) {
                    my @results =
                      get_unique_key_for_fr( $self->{db}, $subject, $object,
                        $unique, $tp, $ph{pub} );
                    foreach my $ta (@results) {
                        my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );
                        if ( $num == 1 || (defined($frnum{$unique}{$ta->{name}}) && $num-$frnum{$unique}{$ta->{name}}==1) ) {
                            $out .=
                              delete_feature_relationship( $self->{db}, $doc,
                                $ta, $subject, $object, $unique,
                                $tp);
                        }
                        elsif ( $num > 1 ) {
                            $out .=
                              delete_feature_relationship_pub( $self->{db},
                                $doc, $ta, $subject, $object, $unique,
                                $tp, $ph{pub} );
                        }
                        else {
                            print STDERR
                              "something Wrong, please validate first\n";
                        }
                    }
                }
            }

            if ( defined($ph{$f}) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    my $start = $item;
                    my $end   = $item;
                    if ( $item =~ /(.*?)--(.*)/ ) {
                        $start = $1;
                        $end   = $2;
                    }
                    my ( $s_fr, $s_p) = write_feature_relationship(
                        $self->{db},     $doc,
                        $subject,        $object,
                        $unique,         'band-' . $start,
                        'cyto_left_end', $ph{pub},
                        'chromosome_band','',$genus,$species
                    );
                    my ($e_fr, $e_p) = write_feature_relationship(
                        $self->{db},      $doc,
                        $subject,         $object,
                        $unique,          'band-' . $end,
                        'cyto_right_end', $ph{pub},
                        'chromosome_band','',$genus,$species
                    );
                    if ( $f eq 'G10a' ) {
                        my $rank = get_frprop_rank(
                            $self->{db},
                            $subject,
                            $object,
                            $unique,
                            'band-' . $start,
                            'cyto_left_end',
                            '(determined by in situ hybridisation)'
                        );
                        my $fprop_1 = create_ch_frprop(
                            doc   => $doc,
                            value => '(determined by in situ hybridisation)',
                            type_id  =>create_ch_cvterm(
                                     name=> 'cyto_left_end',
                                     doc=>$doc,
                                     cv=>'relationship type'),
                            rank  => $rank
                        );
                        $s_fr->appendChild($fprop_1);
                        $rank = get_frprop_rank(
                            $self->{db},
                            $subject,
                            $object,
                            $unique,
                            'band-' . $end,
                            'cyto_left_end',
                            '(determined by in situ hybridisation)',
                            $ph{pub}
                        );
                        my $fprop_2 = create_ch_frprop(
                            doc   => $doc,
                            value => '(determined by in situ hybridisation)',
                            type_id => create_ch_cvterm(
                                     name=> 'cyto_right_end',
                                     doc=>$doc,
                                     cv=>'relationship type'),
                            rank => $rank
                        );
                        $e_fr->appendChild($fprop_2);
                     }
                        $out .= dom_toString($s_fr);
                        $out .= dom_toString($e_fr);
                        $s_fr->dispose();
                        $e_fr->dispose();
                }
            }
        }
        elsif ( $f eq 'G25' ) {
            ###if type=identified_with if EST/cDNA not found in the DB, go
            #to GenBank, grab information, put in the DB and linked to the
            #clone.
            my $subject = 'subject_id';
            my $object  = 'object_id';
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
               print STDERR "Action Items: !c log,$ph{G1a} $f  $ph{pub}\n";
                foreach my $tp ( 'maps_to_clone', 'no_maps_to_clone',
                    'identified_with' )
                {
                    my @results =
                      get_unique_key_for_fr( $self->{db}, $subject, $object,
                        $unique, $tp, $ph{pub} );
                    foreach my $ta (@results) {
                       # print $ta->{fr_id}, "\n";
                        my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );
                        if ( $num == 1 ) {
                            $out .=
                              delete_feature_relationship( $self->{db}, $doc,
                                $ta, $subject, $object, $unique, $tp );
                        }
                        elsif ( $num > 1 ) {
                            $out .=
                              delete_feature_relationship_pub( $self->{db},
                                $doc, $ta, $subject, $object, $unique, $tp,
                                $ph{pub} );
                        }
                        else {
                            print STDERR
                              "something Wrong, please validate first\n";
                        }
                    }
                }
            }
            if ( defined($ph{$f}) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    $item =~ /(.*?):\s(.*)/;
                    my $rtype = $G25type{$1};
                    $item = $2;
                    my $name=$item;
                    $item=~s/\.\dprime//;
                    my $o_type = '';
                    my $flag   = 0;
                    my $feat;
                    my $write = 0;
                   #my $c_unique='';
                   my ( $c_unique, $c_genus, $c_species, $c_type ) =
                          get_feat_ukeys_by_name_type( $self->{db}, $item,
                           $feattype{$rtype} );
                   # if ( $c_unique eq '0' ) {
                    #      ( $c_unique, $flag ) = get_tempid( 'cl', $item );
                    #       $c_type = $feattype{$rtype};
                    #       $c_genus   = $genus;
                    #       $c_species = $species;
                    #        if ( $flag == 1 ) {
                    #            $feat = $c_unique;
                    #        }
                    #        else {

                     #           $feat = create_ch_feature(
                     #               doc        => $doc,
                    #                uniquename => $c_unique,
                     #               type       => $c_type,
                    #                genus      => $c_genus,
                    #                species    => $c_species,
                    #                name       => $item,
                    #                macro_id   => $c_unique,
                   #                 no_lookup  => 1
                   ##             );
                   #             $out.=dom_toString($feat);
      
                    #        }
                    #  }
                if($c_unique ne '' && $c_unique ne '0' && $c_unique ne '2') {
                            $feat = create_ch_feature(
                                doc        => $doc,
                                uniquename => $c_unique,
                                type       => $c_type,
                                genus      => $c_genus,
                               species    => $c_species,
                               macro_id   => $c_unique
                            );
                            $out.=dom_toString($feat);
                 }
					  elsif($rtype eq 'identified_with'){
                   (my $fpout, $c_unique)= get_GenBank_acc($self->{db}, $doc, $item,$feattype{$rtype});    
                    $out.=$fpout;
                }
                else{
                    print STDERR "ERROR: has not implemented yet\n";
                }
                my $fr = create_ch_fr(
                            doc        => $doc,
                            subject_id => $unique,
                            object_id  => $c_unique,
                            rtype      => $rtype
                   );
                my $frp =
                        create_ch_fr_pub( doc => $doc, pub_id => $ph{pub} );
                     $fr->appendChild($frp);
                $out .= dom_toString($fr);
                $fr->dispose();   
                }
                }
        }
        elsif ( $f eq 'G29a' ) {
            my $subject = 'subject_id';
            my $object  = 'object_id';

            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
              print STDERR "Action Items: !c log,$ph{G1a} $f  $ph{pub}\n";
                foreach my $tp ( 'fnally_comps', 'fnally_noncomps',
                    'fnally_partcomps' )
                {
                    my @results =
                      get_unique_key_for_fr( $self->{db}, $subject, $object,
                        $unique, $tp, $ph{pub} );
                    foreach my $ta (@results) {
                        my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );
                        if ( $num == 1 ) {
                            $out .=
                              delete_feature_relationship( $self->{db}, $doc,
                                $ta, $subject, $object, $unique, $tp );
                        }
                        elsif ( $num > 1 ) {
                            $out .=
                              delete_feature_relationship_pub( $self->{db},
                                $doc, $ta, $subject, $object, $unique, $tp,
                                $ph{pub} );
                        }
                        else {
                            print STDERR
                              "something Wrong, please validate first\n";
                        }
                    }
                    ###remove featureprop type=gain_of_fn_species
                    #
                    @results = get_unique_key_for_featureprop(
                        $self->{db},          $unique,
                        'gain_of_fn_species', $ph{pub}
                    );
                    foreach my $t (@results) {
                        my $num =
                          get_fprop_pub_nums( $self->{db}, $t->{fp_id} );
                        if ( $num == 1 || (defined($frnum{$unique}{$ti_fpr_type{$f}}{$t->{rank}}) && $num-$frnum{$unique}{$ti_fpr_type{$f}}{$t->{rank}}==1)) {
                            $out .=
                              delete_featureprop( $doc, $t->{rank}, $unique,
                                'gain_of_fn_species' );
                        }
                        elsif ( $num > 1 ) {
                            $out .=
                              delete_featureprop_pub( $doc, $t, $unique,
                                'gain_of_fn_species', $ph{pub} );
                        }
                        else {
                            print STDERR
                              "something Wrong, please validate first\n";
                        }
                    }

                }

            }
            if ( defined($ph{$f}) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    $item =~ /(.*?):\s(.*)/;
                    my $fritems = $2; my $rtype  = $G29atype{$1};
						  if($rtype eq ''){
						    print STDERR "ERROR: could not find type for G29a $1\n"; 
						  }
                    my @fitems=split(/\s+/,$fritems);
                    foreach my $fritem(@fitems){
                    
                    if ( $rtype =~ /comps/ ) {
                       my ($fr,$f_p) =write_feature_relationship(
                                $self->{db}, $doc,    $subject, $object,
                                $unique,     $fritem, $rtype,   $ph{pub});
                                
                        $out .= dom_toString($fr);
                        $out.=$f_p;
                    }
                    else {
                        $out .=
                          write_featureprop( $self->{db}, $doc, $unique, $item,
                            $rtype, $ph{pub} );
                    }
                }
                }
            }

        }
        elsif ( $f eq 'G22' || $f =~ 'G17[tuv]$' || $f =~ 'G7[a-b]$' || $f eq 'G18' ) {
            my $object  = 'object_id';
            my $subject = 'subject_id';

            if ( exists( $ph{"$f.upd"} ) and $ph{"$f.upd"} eq 'c' ) {
              print STDERR "Action Items: !c log,$ph{G1a} $f  $ph{pub}\n";
                my @results =
                  get_unique_key_for_fr( $self->{db}, $subject, $object,
                    $unique, $ti_fpr_type{$f}, $ph{pub} );
                foreach my $ta (@results) {
                    my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );
                    if ( $num == 1 ) {
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
            if ( defined($ph{$f}) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                  my ($fr, $f_p) = write_feature_relationship(
                            $self->{db},      $doc,    $subject,
                            $object,          $unique, $item,
                            $ti_fpr_type{$f}, $ph{pub}, $feattype{$f}, $featid_type{$f} 
                        );
                    $out.=dom_toString($fr);
                    $out.=$f_p;
                    
                }
            }
        }
        elsif ($f =~ '^G20[a-i]$'
            || $f eq 'G11'
            || $f eq 'G19a'
            || $f eq 'G19b'
            || $f eq 'G12a'
            || $f eq 'G12b'
            || $f eq 'G14a'
            || $f eq 'G14b'
            || $f eq 'G28a'
            || $f eq 'G28b'
            || $f eq 'G29b'
            || $f eq 'G24e'
            || $f eq 'G24g'
            || $f eq 'G15'
            || $f eq 'G5'
            || $f eq 'G6'
            || $f eq 'G34' 
            || $f eq 'G8'
            || $f eq 'G26'
            || $f eq 'G27' )
        {
            my $ptype=$ti_fpr_type{$f};
            if ( $f eq 'G20a' ) {
                if(!defined($ph{p_type})){
                    $ph{p_type}=get_type_from_pub($self->{db},$ph{pub});
                }
                if ($ph{p_type} eq 'review' ) {
                   $ptype = 'significant_subject_in_review';
                }
                else {
                    $ptype = 'in_title_or_abstract';
                }
            }
            my $rn=0;
            if ( exists( $ph{ "$f.upd" } ) && $ph{ "$f.upd" } eq 'c' ) {
               print STDERR "Action Items: !c log,$ph{G1a} $f  $ph{pub} $unique\n";
               my @types=split(/\//,$ptype);
               foreach my $tp(@types){
               print STDERR "type=$tp\n";
                my @results =
                  get_unique_key_for_featureprop( $self->{db}, $unique,
                    $tp, $ph{pub} );
                $rn+=@results;  
                foreach my $t (@results) {
                    print STDERR $t->{fp_id},"\n";   
                    my $num = get_fprop_pub_nums( $self->{db}, $t->{fp_id} );
                    if ( $num == 1 || (defined($frnum{$unique}{$ti_fpr_type{$f}}{$t->{rank}}) && $num-$frnum{$unique}{$ti_fpr_type{$f}}{$t->{rank}}==1)) {
                       $out .=
                          delete_featureprop( $doc, $t->{rank}, $unique,
                            $tp );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_featureprop_pub( $doc, $t->{rank}, $unique,
                            $tp, $ph{pub} );
                    }
                    else {
                        print STDERR "something Wrong, please validate first\n";
                    }
                }
                }
                 if($rn==0){
                    print STDERR "ERROR: there is no previous record for $f\n";
                 }
            }
            if ( defined($ph{$f}) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    if ( $f eq 'G19a' && !( $ph{$f} =~ /Gene order:/ ) ) {
                        $item = 'Gene order: ' . $item;
                    }
                    if ( $f eq 'G28b' ) {
                        if ( $item =~ /Source for merge/ ) {
                            $ptype = 'merge_source';
                        }
                        elsif ( $item =~ /Source for identity/ ) {
                            $ptype = 'identity_source';
                        }
                        else {
                            print STDERR "ERROR: Do not recognize type for G28b:
						$item\n";
                        }
                    }
		    if ( $f eq 'G24g' ) {
		      my ($year, $month, $day) = ($item =~ /^(\d{4})(1[0-2]|0[1-9])(3[0-1]|0[1-9]|[1-2][0-9])$/);
		      if($year ne "" && $month ne "" && $day ne ""){
			$item = $year . $month . $day;
			#always overwrite
			my $rank = 0;
			$out .=
			  write_featureprop( $self->{db}, $doc, $unique, $item,
					     $ptype, $ph{pub}, $rank );
		      }
		      else{
			print STDERR "ERROR: Do not recognize date for G24g:
						$item\n";
                        }
		    }
                    $out .=
                      write_featureprop( $self->{db}, $doc, $unique, $item,
                        $ptype, $ph{pub} );
                }
            }
        }
        elsif ( $f eq 'G30' ) {
          
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
              print STDERR "Action Items: !c log,$ph{G1a} $f  $ph{pub}\n";
                my @results = get_cvterm_for_feature_cvterm_withprop(
                    $self->{db}, $unique, $ti_fpr_type{$f},
                    $ph{pub},    'gene_class'
                );
					 if(@results==0){
					   print STDERR "ERROR: not previous record found for $ph{G1a} $f \n";
					 }
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
                    if ( $item =~ /(.*?)\s;\s.*/ ) {
                        $item = $1;
                    }
                    validate_cvterm($self->{db},$item,$ti_fpr_type{$f});
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

                    my $fcvprop = create_ch_feature_cvtermprop(
                        doc  => $doc,
                        type_id => create_ch_cvterm(doc=>$doc,
                                name=>'gene_class',
                                cv=>'property type'),
                        rank => '0'
                    );
                    $f_cvterm->appendChild($fcvprop);
                    $out .= dom_toString($f_cvterm);
                    $f_cvterm->dispose();
                }
            }

        }
        elsif($f eq 'G24f.upd'){
          print STDERR "Action Items: !c log,$ph{G1a} $f  $ph{pub}\n";
              my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime();
            my $currenttime=sprintf( "%4d%02d%02d",
                $year+1900,$mon+1,$mday);

          foreach my $cv('cellular_component',  'molecular_function',   'biological_process'){
            my @result=get_cvterm_for_feature_cvterm($self->{db},$unique,$cv,$ph{pub});
            foreach my $item(@result){
               my ($cvterm,$obsolete)=split(/,,/,$item);
                my $feat_cvterm = create_ch_feature_cvterm(
                        doc        => $doc,
                        feature_id => $unique,
                        cvterm_id  => create_ch_cvterm(
                            doc  => $doc,
                            cv   => $cv,
                            name => $cvterm,
                            is_obsolete=>$obsolete
                        ),
                        pub => $ph{pub}
                    
                    );
                    my $time=$currenttime;
                    if($ph{G24f} ne 'y' and $ph{G24f} ne 'n'){
                        $time=$ph{G24f};
                    }
                    my $cvprop = create_ch_feature_cvtermprop(
                            doc     => $doc,
                            type => 'date',
                            value=>$time
                            );
                        $feat_cvterm->appendChild($cvprop);    
                $out.=dom_toString($feat_cvterm);
            }
          } 
        }

        elsif ( $f eq 'G24a' || $f eq 'G24b' || $f eq 'G24c' ) {
            
            my @quali = ( 'part_of', 'located_in', 'is_active_in', 'colocalizes_with' );
            if ( $f eq 'G24b') {
                @quali = ( 'enables', 'contributes_to');
            }
            elsif ($f eq 'G24c') {
                @quali = ( 'involved_in', 'acts_upstream_of', 'acts_upstream_of_positive_effect', 'acts_upstream_of_negative_effect' );
            }
            my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime();
            my $currenttime=sprintf( "%4d%02d%02d",
                $year+1900,$mon+1,$mday);

            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                  print STDERR "Action Items: !c log, $ph{G1a} $f  $ph{pub}\n";
                           my @result =
                  get_cvterm_for_feature_cvterm( $self->{db}, $unique,
                    $ti_fpr_type{$f}, $ph{pub} );
                foreach my $item (@result) {
                    my ($cvterm,$obsolete)=split(/,,/,$item);
                    my $date=get_date_by_feature_cvterm($self->{db},$unique,$cvterm,$ti_fpr_type{$f},$ph{pub});
                    $fprank{$unique}{$ti_fpr_type{$f}}{$cvterm}{$ph{pub}}=$date;
                    my $feat_cvterm = create_ch_feature_cvterm(
                        doc        => $doc,
                        feature_id => $unique,
                        cvterm_id  => create_ch_cvterm(
                            doc  => $doc,
                            cv   => $ti_fpr_type{$f},
                            name => $cvterm,
                            is_obsolete=>$obsolete
                        ),
                        pub => $ph{pub}
                    );
                    $feat_cvterm->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($feat_cvterm);
                    $feat_cvterm->dispose();
                }
            }
            if ( defined($ph{$f}) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    my $is_not = 'false';
                    # Check if NOT and set $is_not accordingly.
                    # If NOT remove it afterwards.
                    if (index($item, 'NOT') != -1){
                        $item =~ s/NOT//ig;
                        $is_not = 'true';
                    }
                    print STDERR "ITEM is $item\n";
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    my $prov     = 'FlyBase';
                    my @go_quali = ();
                    my $go_id    = '';
                    my ( $go, $prop ) = split( /\s\|\s/, $item );
                    if ( $go =~ /(.*)\s;\s(.*)/ ) {
                        $go    = $1;
                        $go_id = $2;
                    }
                    if ( $go =~ /^([\w]+):(.*)/ ) {
                        if($1 eq 'UniProtKB' or $1 eq 'FlyBase' or $1 eq 'BHF-UCL' or $1 eq 'GOC' or $1 eq 'HGNC' or $1 eq 'IntAct' or $1 eq 'InterPro' or $1 eq 'MGI' or $1 eq 'PINC' or $1 eq 'Reactome' or $1 eq 'RefGenome' ){
                        $prov=$1;
                        $go   = $2;
                        }
                    }
                    foreach my $q (@quali) {
                        if ( $go =~ /^$q/ ) {
                            push( @go_quali, $q );
                            $go =~ s/$q//;
                            $go =~ s/^\s+//;
                        }
                    }
                    $go    =~ s/^\s+//;
                    $go    =~ s/\s+$//;
                    $go_id =~ s/^\s+//;
                    $go_id =~ s/\s+$//;
           
                    validate_go( $self->{db}, $go, $go_id, $ti_fpr_type{$f} );

		    # want to add a bit to check allele symbols and add stuff so they can be linkable
		    # any allele symbols should be comma space separated and after 'with '
		    # and surrounded by @@ stamps
		    # note we still have evc at beginning of string can we do this all with just sub?
		    if ($prop =~ /with / and $prop =~ /@\S+@/) { # we've got some FlyBase features to check
		      my @feats = ($prop =~ /@(\S+)@/g);	    
		      foreach my $f (@feats) {
			# should be a valid symbol but may be new
			my $uname = get_uniquename_by_name($self->{db}, trim($f), 'FB[a-z]{2}[0-9]{7,12}');
			if ($uname and $uname eq '1') {
			  print STDERR "ERROR: more than one feature with symbol $f found\n";
			  next;
			} elsif (! $uname) {
			  $uname = "NEWFEAT";
			}
			my $str2sub = "FLYBASE:$f; FB:$uname";
			my $qf = quotemeta($f);
			print STDERR "NOTICE: Convert - @",$f,"@ TO $str2sub\n";
			$prop =~ s/@($qf)@/$str2sub/;
		      } 
		    }


                    foreach my $key ( keys %GOabbr ) {
                        my $rep = $GOabbr{$key};
                        $prop =~ s/\b$key\b/$rep/;
								print STDERR "Warning: GO terms:$prop\n"
                    }

                    my $f_cvterm = create_ch_feature_cvterm(
                        doc        => $doc,
                        feature_id => $unique,
                        cvterm_id  => create_ch_cvterm(
                            doc      => $doc,
                            cv       => $ti_fpr_type{$f},
                            name     => $go,
                            macro_id => $go
                         ),
                        pub_id => $ph{pub},
                        is_not => $is_not
                    );
                    if(exists($ph{G24f}) && $ph{G24f} ne 'n'){
                        my $time=$currenttime;
                        if($ph{G24f} ne 'y' ){
                            $time=$ph{G24f};
                        }
                        my $cvprop = create_ch_feature_cvtermprop(
                            doc     => $doc,
                            type => 'date',
                            value=>$time
                            );
                        $f_cvterm->appendChild($cvprop);
                    }
                    elsif(exists($ph{G24f}) && $ph{G24f} eq 'n'){
                        my $time=$currenttime;
                        if(exists($fprank{$unique}{$ti_fpr_type{$f}}{$item}{$ph{pub}})){
                            my $time=$fprank{$unique}{$ti_fpr_type{$f}}{$item}{$ph{pub}};
                        }
                          my $cvprop = create_ch_feature_cvtermprop(
                            doc     => $doc,
                            type => 'date',
                            value=>$time
                            );
                        $f_cvterm->appendChild($cvprop);                         
                       } 
                    else{
                        print STDERR "Warning: there is no G24f field\n";
                        my $time=$currenttime;
                           my $cvprop = create_ch_feature_cvtermprop(
                            doc     => $doc,
                            type => 'date',
                            value=>$time
                            );
                        $f_cvterm->appendChild($cvprop);
                    }
                    foreach my $qa (@go_quali) {
                        my $cv = 'FlyBase miscellaneous CV';
                        if ( $qa eq 'located_in' || $qa eq 'part_of'){
                            $cv = 'relationship';
                        }
                        my $cvprop = create_ch_feature_cvtermprop(
                            doc     => $doc,
                            type_id => create_ch_cvterm(
                                doc       => $doc,
                                name      => $qa,
                                cv        => $cv,
                                no_lookup => 1
                            )
                        );

                        $f_cvterm->appendChild($cvprop);
                    }
                    my $cvprov = create_ch_feature_cvtermprop(
                        doc     => $doc,
                        type_id => create_ch_cvterm(
                            doc       => $doc,
                            name      => 'provenance',
                            cv        => 'FlyBase miscellaneous CV',
                            no_lookup => 1
                        ),
                        value => $prov
                    );
                    $f_cvterm->appendChild($cvprov);
                    if ( $prop ne '' ) {
                     #print STDERR "go=$go\n";
                        my $cvproprank =
                          get_feature_cvtermprop_rank( $db, $unique,
                            $ti_fpr_type{$f}, $go, 'evidence_code', $prop,
                            $ph{pub} );
                        my $fcvprop = create_ch_feature_cvtermprop(
                            doc     => $doc,
                            type_id => create_ch_cvterm(
                                doc  => $doc,
                                name => 'evidence_code',
                                cv   => 'FlyBase miscellaneous CV'
                            ),
                            value => $prop,
                            rank  => $cvproprank
                        );

                        $f_cvterm->appendChild($fcvprop);

                    }

                    $out .= dom_toString($f_cvterm);
                    $f_cvterm->dispose();
                }
            }
        }

	elsif ( $f eq 'G91' ){               
	  print STDERR "CHECK: new implemented $f  $ph{G1a} \n";

	  if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
	    print STDERR "CHECK: new implemented !c $ph{G1a} $f \n";
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
	      print STDERR "ERROR: could not find record for $ph{G91}\n";
	  #		  exit(0);
	    }
	    elsif( $libg ne $genus || $libs ne $species){
		print STDERR "ERROR: In G91 $ph{G91} library genus/species $libg $libs does not match gene $genus $species\n";
		#  exit(0);
	    }

	    else{
#	      print STDERR "DEBUG: G91 $ph{$f} uniquename $libu\n";		  
	      if(defined ($ph{G91a}) && $ph{G91a} ne ""){
		if (exists ($g91a_type{$ph{G91a}} ))  {
		  my $item = $ph{G91a};
#		  print STDERR "DEBUG: G91a $ph{G91a} found\n";
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
		  print STDERR "ERROR: wrong term for G91a $ph{G91a}\n";
		}
	      }
	      else{
		print STDERR "ERROR: G91 has a library no term for G91a\n";
	      }
		
	    }
	  }
	} # end elsif ( $f eq 'G91'
	elsif( ($f eq 'G91a' && $ph{G91a} ne "") && ! defined ($ph{G91}))
	  {
	    print STDERR "ERROR: G91a has a term for G91a but no library\n";
	  } # end elsif ( $f eq 'G91a' check if GA91

	elsif ( $f eq 'G37' ){
	    print STDERR "CHECK: new implemented $f  $ph{G1a} \n";
	    if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
              print STDERR "Action Items: !c log,$ph{G1a} $f  $ph{pub}\n";
              my @results = get_unique_key_for_feature_grpmember($self->{db}, $unique, $ti_fpr_type{$f}, $ph{pub});
	      if(@results==0){
		  print STDERR "ERROR: no previous feature_grpmember (grp) record found for $ph{G1a} $f  $ph{pub}\n";
	      }
	      foreach my $t (@results) {
#		  print STDERR "get_feature_grpmember_pub_nums for $t->{fp_id}\n";   
		  my $num = get_feature_grpmember_pub_nums( $self->{db}, $t->{fp_id} );
		  if ( $num == 1 ) {
		      $out .= delete_feature_grpmember($self->{db},$doc, $t->{grp_uname}, $t->{type}, $t->{cv}, $unique, $t->{rank} );
		  }
		  elsif ( $num > 1 ) {
		      $out .= delete_feature_grpmember_pub($self->{db},$doc, $t->{grp_uname}, $t->{type}, $t->{cv}, $unique, $t->{rank}, $ph{pub} );
		  }
	      }

	    }
	    if (defined ($ph{$f}) && $ph{$f} ne ""){
		my $gunique = '0';
		($gunique, my $gtype)=get_grp_ukeys_by_name($self->{db},$ph{G37});
		if($gunique eq '0' || $gunique eq '2'){
		    print STDERR "ERROR: could not find grp $ph{G37} in the database for $ph{G1a} $ph{pub}\n";
		}
		else{
#		    print STDERR "DEBUG: grp $gunique $ph{G1a} $ph{pub}\n";		    
		    $grp=create_ch_grp(
			    doc        => $doc,
			    uniquename => $gunique,
			    type       => 'gene_group',
			    macro_id   => $gunique,
			    );
		    $out.=dom_toString($grp);  
#		    $fbids{$ph{G37}}=$gunique;
		}
#now figure out how to find/make a grpmember/feature_grpmember/feature_grpmember_pub
		my $grpmember_key = $ph{G37}.'grpmember_feature'.0;
		if(exists($fbgrpms{$grpmember_key})){
		    print STDERR "DEBUG: grpmember $grpmember_key exist in $ph{G1a} $ph{pub}\n";		    
		    $grpmember=$fbgrpms{$grpmember_key};
		}
		else{
#		    print STDERR "DEBUG: grpmember with $ph{G37} not in fbgrpms yet $ph{G1a} $ph{pub}\n";
		    my ($gmid,$gmtype,$gmrank)=get_grpmember_ukeys_by_grp($self->{db},$ph{G37});
		    if($gmid eq '0' || $gmid eq '2'){
			print STDERR "DEBUG: could not find grpmember_feature for grp $ph{G37} in the database for $ph{G1a} $ph{pub}\n";
		    }
		    $grpmember=create_ch_grpmember(
			doc        => $doc,
			grp_id => $gunique,
			type_id => create_ch_cvterm(
                            doc  => $doc,
                            cv   => 'grpmember type',
                            name => 'grpmember_feature',
                        ),
			macro_id   => $grpmember_key,
			no_lookup  => '1'
			);
                    $out.=dom_toString($grpmember);
		    $fbgrpms{$grpmember_key}=$grpmember_key;
		    print STDERR "DEBUG: NEW grpmember $grpmember_key\n";
		}
		#ok we have a grpmember now we need a feature_grpmember and feature_grpmember_pub
		my $f_gmr = create_ch_feature_grpmember(
			    doc        => $doc,
		            grpmember_id => $grpmember_key,
		            feature_id => $unique,
		    );

		my $f_gmrpub=create_ch_feature_grpmember_pub(
						doc=>$doc,
		                                pub_id=>$ph{pub},
					       );
		$f_gmr->appendChild($f_gmrpub);
		$out.=dom_toString($f_gmr);
	    }
	}#end G37
        elsif ($f eq 'G39a'
	       || $f eq 'G39b'
	       || $f eq 'G39d'
	       || $f eq 'G39c'
	    ){
            my $ptype=$ti_fpr_type{$f};
            if ( exists( $ph{ "$f.upd" } ) && $ph{ "$f.upd" } eq 'c' ) {
               print STDERR "Action Items: !c log,$ph{G1a} $f  $ph{pub} $unique\n";
	       my $rn;
	       my @results =
		   get_unique_key_for_featureprop( $self->{db}, $unique,
						   $ptype, $ph{pub} );
	       $rn+=@results;  
	       if($rn==0){
		   print STDERR "ERROR: there is no previous record for $f\n";
	       }
	       else{
		   foreach my $t (@results) {
		       print STDERR $t->{fp_id},"\n";   
		       $out .=
			   delete_featureprop( $doc, $t->{rank}, $unique,
						   $ptype);
		   }
	       }
	    }
            if ( defined($ph{$f}) && $ph{$f} ne '' ) {
		if($f eq 'G39d'){
		    my @items = split( /\n/, $ph{$f} );
		    foreach my $item (@items) {
			$item =~ s/^\s+//;
			$item =~ s/\s+$//;
			$out .=
			    write_featureprop( $self->{db}, $doc, $unique, $item,
					       $ptype, $ph{pub});
		    }
		}
		if($f eq 'G39a'){
		    if(defined($ph{G39b}) && $ph{G39b} eq 'y'){
		    $out .=
			write_featureprop( $self->{db}, $doc, $unique, $ph{G39a},
					       $ptype, $ph{pub},0 );
		    }
		    else{
			print STDERR "ERROR: $f filled in but G39b not equal y\n"; 
		    }
		}
		if($f eq 'G39b'){
		    if(defined($ph{G39a} && $ph{G39b} eq 'y')){
			$out .=
			    write_featureprop( $self->{db}, $doc, $unique, $ph{G39b},
					       $ptype, $ph{pub},0 );
		    }
		    elsif(! defined($ph{G39a}) && $ph{G39b} eq 'n' ){
			    $out .=
				write_featureprop( $self->{db}, $doc, $unique, $ph{G39b},
						   $ptype, $ph{pub},0 );
		    }
		}
		if($f eq 'G39c' && $ph{G39c} ne 'n'){
		    print STDERR "First use $f = $ph{G39c} Not = n Gene $ph{G1a} $ph{pub} $unique\n";
		    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime();
		    my $currenttime=sprintf( "%4d%02d%02d",
				     $year+1900,$mon+1,$mday);	    
		    if((exists($ph{G39a}) && $ph{G39a} ne '') || (exists($ph{G39b}) && $ph{G39b} eq 'n') ){
			my $time=$currenttime;
			if($ph{G39c} ne 'y' ){
			    $time=$ph{G39c};
			}
			my $fp = create_ch_featureprop(
			    doc        => $doc,
			    feature_id => $unique,
			    rank       => 0,
			    type       => $ti_fpr_type{$f},
			    value      => $time,
			    );
			my $fppub = create_ch_featureprop_pub( doc => $doc, pub_id => $ph{pub} );
			$fp->appendChild($fppub);
			$out.=dom_toString($fp);
		    }
		}
		if(($f eq 'G39c' && $ph{G39c} eq 'n') && ! $ph{ "$f.upd" } ){
		    print STDERR "ERROR:$f = G39c = n must be !c Gene $ph{G1a} $ph{pub} $unique\n";
		}
	    }
	}
#Tools	    
	elsif ($f eq 'G40')
	{
	    if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
		print STDERR "Action Items: !c log, $ph{$f} $f  $ph{pub}\n";
		my @results = get_cvterm_for_feature_cvterm_withprop( $self->{db}, $unique, $ti_fpr_type{$f}, $ph{pub}, $fcp_type{$f});
		if(@results==0){
		    print STDERR "ERROR: no previous record found for $ph{G1a} $f $ph{pub} $ph{file}\n";
		}
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
		print STDERR "DEBUG feature_cvterm $ph{G1a} $f $ph{pub} $ph{file}\n";
		my @items = split( /\n/, $ph{$f} );
		foreach my $item (@items) {
		    $item =~ s/^\s+//;
		    $item =~ s/\s+$//;
		    print STDERR "DEBUG validate cvterm $ti_fpr_type{$f}, $item  $ph{G1a} $f $ph{pub} $ph{file}\n";
		    validate_cvterm($self->{db},$item,$ti_fpr_type{$f});
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
		    my $fcvprop = create_ch_feature_cvtermprop(
			doc  => $doc,
			type_id => create_ch_cvterm(doc=>$doc,
                                                name=>$fcp_type{$f},
                                                cv=>'feature_cvtermprop type'),
			rank => '0'
			);
		    $f_cvterm->appendChild($fcvprop);
		    $out .= dom_toString($f_cvterm);
		    $f_cvterm->dispose();
		}
	    }

	} # end if G40
	elsif ($f eq 'G38'){
	    my $object  = 'object_id';
            my $subject = 'subject_id';
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{G1a} $f  $ph{pub}\n";
                my @results = get_unique_key_for_fr_by_feattype(
                    $self->{db}, $subject,      $object,
                    $unique,     $ti_fpr_type{$f}, $ph{pub}, $feattype{$f}
                    );
                foreach my $ta (@results) {
                    my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );
                    #print STDERR "fr number $num\n";
                    if ( $num == 1  || (defined($frnum{$unique}{$ta->{name}}) && $num-$frnum{$unique}{$ta->{name}}==1)) {
                        #print STDERR "Warning: deleting feature_relationship $unique $f ",$ta->{name}," ", $ph{pub},"\n";
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
            } #end !c
	    if(defined($ph{$f}) && $ph{$f} ne ''){
		my ($fr,$f_p) = write_feature_relationship(
		    $self->{db},   $doc,     $subject,
		    $object,       $unique,  $ph{G38},
		    $ti_fpr_type{$f}, $ph{pub}, $feattype{$f},
		    $featid_type{$f}
                            );
		$out .= dom_toString($fr);
		$out.=$f_p;
	    }
                    
	} # end elsif ($f eq G38)
	    

    }#end foreach
    $doc->dispose();
    return ( $out, $unique );
}#end process

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
    my $type='gene';
    my $out = '';
    my $orgabbr = '';

    if(exists($ph{G1h})){
         ($genus,$species,$type)=get_feat_ukeys_by_uname($self->{db},$ph{G1h});
		    if(!exists($ph{G1e})){
			 validate_uname_name($db,$ph{G1h},$ph{G1a});
			}
			if($genus eq '2'){
		      ($unique,$genus,$species,$type)=get_feat_ukeys_by_name_type($self->{db},$ph{G1a},'gene') ;
				if($unique ne $ph{G1h}){
			    print STDERR "ERROR: name and uniquename not match $ph{G1h}  $ph{G1a} \n";	
				}
			}
         if($genus ne '0' && $genus ne '2'){
               $unique=$ph{G1h};
               $feature = create_ch_feature(
            doc        => $doc,
            uniquename => $unique,
            species    => $species,
            genus      => $genus,
            type       => $type,
            macro_id   => $unique,
        );
        
        if ( exists( $ph{G31a} ) && $ph{G31a} eq 'y' ) {
           print STDERR "Action Items: delete gene $unique == $ph{G1a}\n";
            my $op = create_doc_element( $doc, 'is_obsolete', 't' );
            $feature->appendChild($op);
        }
        if(exists($ph{G1e})){
            my $op = create_doc_element( $doc, 'name', decon(convers($ph{G1a})) );
            $feature->appendChild($op);
        }
        if(exists($fbids{$ph{G1a}})){
            my $check=$fbids{$ph{G1a}};
            if($unique ne $check){
                print STDERR "ERROR: $check and $unique are not same for $ph{G1a} Camcur please separate proforma to different PHASEs ; Harvcur please hold back $unique $ph{G1a} and resubmit after file with $check loaded\n"; 
            }
        }
        $fbids{ $ph{G1a} } = $unique;
        $out.=dom_toString($feature);
        }
        else{
            print STDERR "ERROR: could not find $ph{G1h} in database\n";
        }
    }
   else{
    if (exists($ph{G32})){
       	check_gene_model($self->{db},$ph{G32});
	print STDERR "Action Items: G32 rename $ph{G32} to $ph{G1a}\n";
	if(exists($fbids{$ph{G32}}) || exists($fbids{$ph{G1a}})){
            print STDERR "ERROR: $ph{G32} or $ph{G1a} appeared in previous profomra\n";
        } 
        ($unique,$genus,$species,$type)=get_feat_ukeys_by_name($self->{db},$ph{G32});
        if($unique eq '0' || $unique eq '2'){
            print STDERR "ERROR: could not find $ph{G32} in the database\n";
        }
        else{
        $feature=create_ch_feature(
                uniquename => $unique,
                name       => decon( convers( $ph{G1a} ) ),
                genus      => $genus,
                species    => $species,
                type       => 'gene',
                doc        => $doc,
                macro_id   => $unique,
                no_lookup  => '1'
        );
        $fbids{$ph{G32}}=$unique;
        }  
        if(exists($fbids{$ph{G1a}})){
            print STDERR "ERROR: possible duplicates $ph{G1a} exists as $fbids{$ph{G1a}} \n";
        }
        else{
            $fbids{$ph{G1a}}=$unique;
        }
        $out.=dom_toString($feature);
        $out .=
              write_feature_synonyms( $doc, $unique, $ph{G1a}, 'a',
                'unattributed', 'symbol' );
       if($ph{G32} ne $ph{G1a}){
             $out .=
              update_feature_synonym( $self->{db}, $doc, $unique, $ph{G32},
                'symbol' );
       }
   }
   elsif(exists($ph{G1f})){
       if ($ph{G1g} eq 'n' ) {
	   print STDERR "Gene Merge  G1g = n check: does G1a $ph{G1a} exist\n";
	   my $va = validate_new_name($db, $ph{G1a});
	   if($va == 1){
	       print STDERR "ERROR:Gene Merge  G1g = n and G1a $ph{G1a} exists\n";
	   }
       }
       my $tmp=$ph{G1f};
       $tmp=~s/\n/ /g;
       print STDERR "Action Items: Gene Merge $tmp\n";
       ( $unique, $flag ) = get_tempid( 'gn', $ph{G1a} );
           
       print STDERR "get temp id for $ph{G1a} $unique\n";
        
       if ( $ph{G1a} =~ /^(.{2,14}?)\\(.*)/ ) {
	   print STDERR "CHECK: organism abbrev for $ph{G1a} $1 \n";
	   ( $genus, $species ) = get_organism_by_abbrev( $self->{db}, $1 );
	   if($genus eq '0'){
	       print STDERR "CHECK: could not get organism for $ph{G1a} default to Dmel\n";
	   }
       }
       if($ph{G1a} =~ /^T:(.{2,14}?)\\(.*)/ ){
	   print STDERR "CHECK: organism abbrev for $ph{G1a} $1 \n";
	   ( $genus, $species ) = get_organism_by_abbrev( $self->{db}, $1 );
	   if($genus eq '0'){
	       print STDERR "Warning: could not get organism for $ph{G1a}\n";
	   }
       }

       if($genus eq '0'){
	   $genus='Drosophila';
	   $species='melanogaster';
       }
       if($flag ==1){
	   print STDERR "ERROR: could not assign temp id for $ph{G1a}\n";
	   exit(0);
       }
       else{
	   $feature = create_ch_feature(
	       uniquename => $unique,
	       name       => decon( convers( $ph{G1a} ) ),
	       genus      => $genus,
	       species    => $species,
	       type       => 'gene',
	       doc        => $doc,
	       macro_id   => $unique,
	       no_lookup  => '1'
	       );
	   $out.=dom_toString($feature);
	   $out .=
	       write_feature_synonyms( $doc, $unique, $ph{G1a}, 'a',
                'unattributed', 'symbol' );
       }
 
   }
   else{
       if ( $ph{G1g} ne 'n' ) {
	   ( $unique, $genus, $species, $type ) =
	       get_feat_ukeys_by_name( $self->{db}, $ph{G1a} );
	   if ( $unique eq '0' ) {
	       print STDERR "ERROR: Could not find uniquename for gene ", $ph{G1a}, "\n";
	       my $current=get_current_name_by_synonym($self->{db},$ph{G1a});
	       print STDERR "ERROR: $ph{G1a} current name may be changed to $current\n";
            #exit(0);
	   }
	   if ( $unique eq '2' ) {
	       ( $unique, $genus, $species ) =
		   get_feat_ukeys_by_name_type( $self->{db}, $ph{G1a}, 'gene' );
				  $type='gene'
	   }
	   if ( $unique eq '0' ) {
	       print STDERR "ERROR: could not find  uniquename for gene ", $ph{G1a}, "\n";
            #exit(0);
	   }
	   if (exists($ph{G1h})){
	       if($ph{G1h} ne $unique){
		   print STDERR "ERROR: G1h and G1a not match\n";
	       }
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
	   if ( exists( $ph{G31a} ) && $ph{G31a} eq 'y' ) {
	       print STDERR "Action Items: delete gene $unique == $ph{G1a}\n";
	       my $op = create_doc_element( $doc, 'is_obsolete', 't' );
	       $feature->appendChild($op);
	   }
	   if(exists($fbids{$ph{G1a}})){
	       my $check=$fbids{$ph{G1a}};
	       if($unique ne $check){
		   print STDERR "ERROR: $check and $unique are not same for $ph{G1a}, using $unique, please separate proforma to different PHASEs\n"; 
	       }
	   }
	   $fbids{ $ph{G1a} } = $unique;
	   $out.=dom_toString($feature);
	   validate_uname_name($self->{db}, $unique,$ph{G1a});
	   $out .=write_feature_synonyms( $doc, $unique, $ph{G1a}, 'a', 'unattributed', 'symbol' );
       }
       else {#G1g = n and not a merge
	   my $va=0;
	   if(exists($ph{G1e})){
	       if(uc($ph{G1e}) ne uc($ph{G1a})){
		   $va = validate_new_gene_name($db, $ph{G1a});
		   if($va == 1){
		       exit(0);
		   }
	       }
	       if(exists($fbids{$ph{G1e}})){
		   print STDERR "ERROR: Rename G1e $ph{G1e} exists in a previous proforma\n";
	       }
               if(exists($fbids{$ph{G1a}})){                                    
                   print STDERR "ERROR: Rename G1a $ph{G1a} exists in a previous proforma \n";
	       }  
	       print STDERR "Action Items: rename $ph{G1e} to $ph{G1a}\n";
	       ( $unique, $genus, $species, $type ) =
		   get_feat_ukeys_by_name( $self->{db}, $ph{G1e} );
	       if($unique eq '0' or $unique eq '2'){
		   print STDERR "ERROR: could not get uniquename for $ph{G1e}\n";
	       }
	       else{
		   $feature = create_ch_feature(
		       uniquename => $unique,
		       name       => decon( convers( $ph{G1a} ) ),
		       genus      => $genus,
		       species    => $species,
		       type       => 'gene',
		       doc        => $doc,
		       macro_id   => $unique,
		       no_lookup  => '1'
		       );
		   $out.=dom_toString($feature);
		   $out .=
		       write_feature_synonyms( $doc, $unique, $ph{G1a}, 'a',
                'unattributed', 'symbol' );
            
		   $fbids{$ph{G1a}}=$unique;
		   $fbids{$ph{G1e}}=$unique;
	       }
	   }
	   else{#G1g = n and not a rename
	       $va = validate_new_gene_name($db, $ph{G1a}); 
        ### if the temp id has been used before, $flag will be 1 to avoid
        ### the DB Trigger reassign a new id to the same symbol.
	       if($va==1){
		   $flag=0;
		   print STDERR "val = 1 for $ph{G1a} flag==$flag where does this happen?\n";
		   ($unique,$genus,$species,$type)=get_feat_ukeys_by_name($db,$ph{G1a});
		   $fbids{$ph{G1a}}=$unique;
	       }
	       else{
		   ( $unique, $flag ) = get_tempid( 'gn', $ph{G1a} );
		   print STDERR "Action Items: new gene $ph{G1a} $unique\n";
		   print STDERR "get temp id for $ph{G1a} $unique flag==$flag\n";
		   if ( $ph{G1a} =~ /^(.{2,14}?)\\(.*)/ ) {
		       ( $genus, $species ) = get_organism_by_abbrev( $self->{db}, $1 );
		   } 
		   if($ph{G1a} =~ /^T:(.{2,14}?)\\(.*)/ ){
		       ( $genus, $species ) = get_organism_by_abbrev( $self->{db}, $1 );
		   }
		   if($genus eq '0'){
		       print STDERR "Warning: organism $ph{G1a} can not be found default to Dmel\n";
		       $genus ='Drosophila';
		       $species='melanogaster';
		   }
	       }
	       if ( $flag == 0 ) {
		   $feature = create_ch_feature(
		       uniquename => $unique,
		       name       => decon( convers( $ph{G1a} ) ),
		       genus      => $genus,
		       species    => $species,
		       type       => 'gene',
		       doc        => $doc,
		       macro_id   => $unique,
		       no_lookup  => '1'
		       );
		   $out.=dom_toString($feature);
		   $out .=
		       write_feature_synonyms( $doc, $unique, $ph{G1a}, 'a',
                'unattributed', 'symbol' );
	       }
	       else{
		   print STDERR "ERROR, name $ph{G1a} has been used in this load\n";
	       }
	   }
       }
   }
   }
    $doc->dispose();
    return ($out, $unique);
}
=head2 $pro->validate(%ph)

   validate the following:
   1. if G1g is 'y', and  if G1c is blank check whether G1a is a 
	   valid feature.name in the DB. if G1e not blank, check G1e in the
		DB. if G1g is 'n', check whether G1a is already in the DB.
	2. G25 not implemented for Berkeley STS D\d{4} or Dm\d{4}
	3. validate G22, G17*, G18, G1f, G7*,G29a the values 
	   following those fields have
	   to be a valid symbol in the database.
	4. if a new record, !c can not be exists.
	5. validate G24* G30 for the current cvterm in DB
	6. !c validation: has to have records in DB
	7. check whether G10a/G10b is a valid chromosome band.

=cut

sub validate {
    my $self   = shift;
    my $tihash = {@_};
    my %tival  = %$tihash;

    my $v_unique = '';
    my $v_uname;
    my $v_genus;
    my $v_species;
    my $v_type;

    print STDERR "Validating Gene ", $tival{G1a}, " ....\n";
    
    if(exists($fbids{$tival{G1a}})){
        $v_unique=$fbids{$tival{G1a}};
    }
    else{
        print STDERR "ERROR: did not have the first parse\n";
    }
    if ( exists( $tival{G2c} ) ) {
        if ( !exists( $tival{G2a} ) ) {
            print STDERR "ERROR: G2a has to be existed when G2c is filled\n";
        }
    }
   
    if ( $v_unique =~ 'FBgn:temp' ) {
        foreach my $fu ( keys %tival ) {
            if ( $fu =~ /(.*)\.upd/ ) {
                print STDERR "Wrong !c fields  $1 for a new record \n";
            }
        }
    }

    foreach my $f ( keys %tival ) {
        if ( $f eq 'G25' ) {
            my @items = split( /\n/, $tival{$f} );
            foreach my $item (@items) {
                if ( $tival{$f} =~ /^D\d{4}$/ || $tival{$f} =~ /^Dm\d{4}$/ ) {
                    print STDERR "ERROR: G25 not implemented for $f : $item yet.\n";
                }
            }
        }
        elsif($f eq 'G29a'){
           my @items = split( /\n/, $tival{$f} );
           foreach my $item (@items) {
               $item =~ s/^\s+//;
               $item =~ s/\s+$//;
               $item =~ /(.*?):\s(.*)/;
               my $fritems = $2; my $rtype  = $G29atype{$1};
               my @fitems=split(/\s+/,$fritems);
               foreach my $fritem(@fitems){
                   if ( $rtype =~ /comps/ ) {
                       my ($s_u, undef, undef, undef)=get_feat_ukeys_by_name($db,$fritem);
                       if($s_u eq '0' || $s_u eq '2'){
                          print STDERR "ERROR: $item in field $f could not be found in the DB\n";
                       }    
                    }
                }
            }
        }
        elsif($f eq 'G1f' || $f eq 'G18' || $f eq 'G22' || $f =~ '^G17[tvu]$' || $f eq 'G7a' || $f eq 'G7b'){
            my @items=split(/\n/,$tival{$f});
            foreach my $item(@items){
                   $item=~s/\s+$//;
                   $item=~s/^\s+//;  
                   if(!exists($fbids{$item})) {  
                   my ($s_u, undef, undef, undef)=get_feat_ukeys_by_name($db,$item);
                   if($s_u eq '0' || $s_u eq '2'){
                    print STDERR "ERROR: $item in field $f could not be found in the DB\n";
                   }
                   }
            }
        }
        elsif ($f =~ 'G10[a-b]$' )
            {
                my @items = split( /\n/, $tival{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    my $start = $item;
                    my $end   = $item;
                    if ( $item =~ /(.*?)--(.*)/ ) {
                        $start = "band-$1";
                        $end   = "band-$2";
                    }
                    if(!exists($fbids{$item})){
                   my ($s_u, undef, undef, undef)=get_feat_ukeys_by_name($db,$start);
                   if($s_u eq '0' || $s_u eq '2'){
                    print STDERR "ERROR: $start in field $f could not be found in the DB\n";
                   }  
                   my ($o_u, undef, undef, undef)=get_feat_ukeys_by_name($db,$end);
                   if($o_u eq '0' || $o_u eq '2'){
                    print STDERR "ERROR: $end in field $f could not be found in the DB\n";
                   }
                 }
                }
        }
        elsif ( $f =~ /(.*)\.upd/  && !($v_unique =~ 'temp')) {
            $f = $1;
            if (   $f eq 'G27'
                || $f =~ 'G20'
                || $f eq 'G11'
                || $f eq 'G19a'
                || $f eq 'G19b'
                || $f eq 'G12a'
                || $f eq 'G12b'
                || $f eq 'G14a'
                || $f eq 'G14b'
                || $f eq 'G28a'
                || $f eq 'G28b'
                || $f eq 'G29b'
                || $f eq 'G24e'
                || $f eq 'G15'
                || $f eq 'G5'
                || $f eq 'G6'
                || $f eq 'G26' )
            {
                my @types = split( /\//, $ti_fpr_type{$f} );
                my $num = 0;
                foreach my $ftype (@types) {
                    $num +=
                      get_unique_key_for_featureprop( $db, $v_unique, $ftype,
                        $tival{pub} );
                }
                if ( $num == 0 ) {
                    print STDERR
                      "ERROR:there is no previous record for $f field.\n";
                }
            }

            elsif ($f =~ 'G10[a-b]$'
                || $f eq 'G25'
                || $f =~ 'G17[tuv]$'
                || $f eq 'G7b'
                || $f eq 'G7a'
                || $f eq 'G22'
                || $f eq 'G18' )
            {
                my @types = split( /\//, $ti_fpr_type{$f} );
                my $num = 0;
                foreach my $ftype (@types) {
                    $num +=
                      get_unique_key_for_fr( $db, 'subject_id', 'object_id',
                        $v_unique, $ftype, $tival{pub} );

                }
                if ( $num == 0 ) {
                    print STDERR
                      "ERROR:There is no previous record for $f field\n";
                }
            }

        }
        elsif($f eq 'G24f'){
           
            print STDERR "Warning: Default value of 'y' removed from GO date field G24f. 
                            - any GO data will be recorded with new date\n";
        }
        elsif($f =~/^G24[a-c]$/ || $f eq 'G30' ){
             my @items = split( /\n/, $tival{$f} );
            foreach my $item (@items) {
                $item =~ s/^\s+//;
                $item =~ s/\s+$//;
                $item=~/(.*)\s;/;
                $item=$1;
                validate_cvterm($db, $item,$ti_fpr_type{$f});
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
XML::Xort

=head1 Proforma

! GENE PROFORMA                          Version 46:  3 Aug 2007
!
! G1a.  Gene symbol to use in database                      *a :
! G1b.  Gene symbol used in paper                           *i :
! G1e.  Action - rename this gene symbol                       :
! G1f.  Action - merge these genes                             :
! G1g.  Is G1a the valid symbol of a gene in FlyBase?          :y
! G30.  Gene category (if gene is new to FlyBase) [SO CV]   *t :
! G2a.  Gene name to use in database                        *e :
! G2b.  Gene name used in paper                             *V :
! G2c.  Database gene name(s) to replace                    *V :
! G27.  Etymology                                              :
! G31a. Action - delete gene              - TAKE CARE :
! G31b. Action - dissociate G1a from FBrf - TAKE CARE :
! G20a. G1a in title/abstract? Reviews - G1a significant subject? NSC :
! G20b. G1a wildtype expression in wildtype analysed?             NSC :
! G20c. G1a expression analysed in mutant/perturbed bckgrd?       NSC :
! G20d. G1a genome annotation analysed?                           NSC :
! G20e. G1a product physical interaction analysed?                NSC :
! G20f. G1a cis-regulatory elements characterized?                NSC :
! G20g. G1a gene model decorated - alleles/rescue frags/breaks?   NSC :
! G20h. G1a polymorphism data reported?                           NSC :
! G10a. Cytological map posn if by chromosome in situ      *c :
! G10b. Cytological map posn if details unspecified        *c :
! G11.  Comments on cytological map position [SoftCV]      *D :
! G25.  Relationship to clone                         [SoftCV]*s :
! G19a. Gene order/orientation from molecular mapping [SoftCV]*s :
! G19b. Comments, not allele-specific -- molecular         *s :
! G12a. Comments, not allele-specific - biological role    *r :
! G12b. Comments, not allele-specific -- mutants           *p :
! G14a. Comments, not allele-specific -- other             *u :
! G14b. Identification                                        :
! G28a. Comments -- relationship to other genes        [free text] *q :
! G28b. Source for merge/identity of                      [SoftCV] *q :
! G29a. Functional comp/gain of function -- structured [SoftCV] *q :
! G29b. Functional comp/gain of function            [free text] *q :
! G18.  Gene(s) stated to interact genetically with G1a    *p :
! G22.  Homologous gene in reference species of drosophilid*M :
! G24a. GO -- Cellular component | evidence [CV]           *f :
! G24b. GO -- Molecular function | evidence [CV]           *F :
! G24c. GO -- Biological process | evidence [CV]           *d :
! G24e. GO specific internal note                          *H :
! G24f. GO -- date entered or last reviewed  :y
! G15.  Internal notes  *W :
! RARE FIELDS MODULE:
! move to the start of the line below this and include the Gene Modules pro
! GENE PROFORMA MODULES                       Version 12: 6 July 2007
!
! G17t. Abs or mulspcons that cause recessive PEV for G1a  *n :
! G17u. Abs or mulspcons that cause no PEV for G1a         *n :
! G17v. Abs or mulspcons that cause dominant PEV for G1a   *n :
! G5.   Genetic map position if by recombination mapping   *b :
! G6.   Error in genetic map position (+/-) if reported    *b :
! G7a.  Gene(s) recomb-mapped to be left of G1a            *b :
! G7b.  Gene(s) recomb-mapped to be right of G1a           *b :
! G8.   Comments on genetic map position                   *B :
! G26.  Foreign gene/Tag summary information                  :
! G32.  Newly assigned annotation ID (CG/CR number) TAKE CARE :
! G33.  Accession number (TAKE CARE - sequence curation only) :


=head1 AUTHOR

Haiyan Zhang, E<lt>haiyan@morgan.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
