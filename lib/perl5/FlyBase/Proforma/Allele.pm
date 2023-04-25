package FlyBase::Proforma::Allele;

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

# Preloaded methods go here.

=head1 NAME

FlyBase::Proforma::Allele - Perl module for parsing the FlyBase
Allele  proforma version 39, July 6, 2007.

See the bottom for the proforma
                         
=head1 SYNOPSIS

  use FlyBase::Proforma::Allele;
  use DBI;
  
  my $mdbh=DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";
  my %ph=(GA1a=>'TM9[1]', GA1g=>'y',....);
  ###!c field implemented as '$fieldname.upd=>'c'' eg. 'A16.upd'=>'c'
   
  #params db is manditory, debug and validate is optional
  my $pro=FlyBase::proforma::Allele->new(db=>$mdbh);
  $pro->validate(%ph);
  my $chadoxml = $pro->process(%ph);
  
  # or

  my $pro=FlyBase::Proforma::Allele->new(db=>$mdbh,debug=>1,validate=>1);
  my $chadoxml_string=$pro->process(%ph);

=head1 DESCRIPTION

FlyBase::Proforma::Allele is a perl module for parsing FlyBase
Allele proforma and write the result as chadoxml. It is required
to connected to a chado database for validating and processing.
See Proforma for the proforma template.

The module also requires FlyBase::Proforma::Writechado and
FlyBase::Proforma::Util. The results can be loaded into a chado
database by XML::Xort.

=head2 EXPORT

  process
  validate

=cut

my %pm = ( 'p', '+', '+', '+', 'm', '-', '-', '-' );

my %feat_type = (
    'GA10a', 'transgenic_transposable_element',
    'GA10c', 'transposable_element_insertion_site',
    'GA10e', 'transposable_element_insertion_site',
    'GA10g', 'chromosome_structure_variation',
    'GA80b', 'polypeptide'
    );
my %id_type = ( 'GA10g', 'ab', 'GA10c', 'ti', 'GA10e', 'ti', 'GA10a', 'tp' );

my %fcp_type = ( 'GA30d', 'tool_uses', 'GA35', 'transgenic_product_class' );

my %fpr_type = (
    'gene',  'alleleof',
    'GA1a',  'symbol',
    'GA1b',  'symbol',
    'GA1e',  'symbol',
    'GA1f',  'merge',
    'GA1g',  'new',
    'GA2a',  'fullname',
    'GA2b',  'fullname',
    'GA2c',  'fullname',
    'GA31',  'etymology',                       #feaureprop
    'GA32a', 'is_obsolete',
    'GA32b', 'dissociate',
    'GA3',   'FlyBase miscellaneous CV',        #feature_cvterm
    'GA4',   'FlyBase miscellaneous CV',        #feature_cvterm
    'GA56',  'phenstatement',                   #phenstatement
    'GA17',  'phenstatement',                   #phenstatement
    'GA7a',  'single_mutant_pheno',             #phendesc
    'GA28a', 'phenotype_comparison',
    'GA28b', 'phenotype_comparison',
    'GA28c', 'genetic_interaction_pheno',
    'GA29a', 'phenotype_comparison',
    'GA29b', 'phenotype_comparison',
    'GA29c', 'xeno_interaction_pheno',
    'GA21',  'phenotype_comparison',
    'GA22',  'interallele_comp',
    'GA10a', 'associated_with',                 #feature_relationship.object_id
    'GA10b', 'location_comment',
    'GA10c', 'associated_with',
    'GA10d', 'insertion_into_natTE',
    'GA10e', 'associated_with',
    'GA10f', 'first_base_of_unique_in_natTE',
    'GA10g',
    'associated_with/cyto_change_comment',      #feature_relationship.subject_id
    'GA8',   'FlyBase miscellaneous CV',        #feature_cvterm
    'GA19',  'FlyBase miscellaneous CV',        #feature_cvterm
    'GA15',  'discoverer',
    'GA11',  'progenitor',                      #feature_relationship.object_id
    'GA23a', 'origin_type',
    'GA23b', 'origin_comment',
    'GA12a', 'nucleotide_sub/aminoacid_rep',
    'GA12b', 'molecular_info',
    'GA30',  'included_in',                     #feature_relationship.subject_id
    'GA13',  'misc',
    'GA20',  'availability',
    'GA14',  'internal_notes',
    'GA90a', 'partof',                          #feature_relationship.subject_id
    'GA90b', 'featureloc',
    'GA90c', 'reported_genomic_loc',            #cv = GenBank feature qualifier
    'GA90d', 'na_change',                       #cv = GenBank feature qualifier
    'GA90e', 'reported_na_change',              #cv = GenBank feature qualifier
    'GA90f', 'reported_pr_change',              #cv = GenBank feature qualifier
    'GA90g', 'pr_change',                       #cv = GenBank feature qualifier
    'GA90h', 'linked_to',                       #cv = GenBank feature qualifier
    'GA90j', 'comment',                         #cv = GenBank feature qualifier
    'GA90k', 'type',                            #cv = SO
    'GA91',  'library_feature',                 #library_feature
    'GA91a', 'library_featureprop',             #library_featureprop
    'GA34a', 'disease_ontology',                # feature_cvterm
    'GA34b', 'hdm_comments',
    'GA34c', 'hdm_internal_notes',
    'GA30a', 'tagged_with',                     #feature_relationship.object_id
    'GA30b', 'carries_tool',                    # feature_relationship.object_id
    'GA30c', 'encodes_tool',                    #feature_relationship.object_id
    'GA30e', 'has_reg_region',                  #feature_relationship.object_id
    'GA30f',
    'propagate_transgenic_uses',    #cv property type -- featureprop n/blank
    'GA30d', 'FlyBase miscellaneous CV'
    ,    #feature_cvterm -- feature_cvtermprop type tool_uses
    'GA35', 'SO'
    ,    #feature_cvterm -- feature_cvtermprop type transgenic_product_class
    'GA36', 'disease_associated',    #cv property type -- featureprop y/blank
    'GA80a', 'fly_disease-implication_change', # feature_relationshipprop:- cv = 'feature_relationshipprop type', cvterm = 'fly_disease-implication_change'
    'GA80b', 'representative_isoform', # feature_relationship:- (cv = 'relationship type', cvterm = 'representative_isoform')
    'GA80c', 'other_disease-implication_change', # featureprop:- cv = 'property type', cvterm = 'other_disease-implication_change'
    'GA80d', 'data_link', # feature_dbxref (db = hgnc)
    'GA81a', 'primary_disease-implication_change', # featureprop:- cv = 'property type', cvterm = 'primary_disease-implication_change'
    'GA81b', 'additional_disease-implication_change', # featureprop:- cv = 'property type', cvterm = 'additional_disease-implication_change'
    'GA82', 'human_disease_relevant', # humanhealth_feature +
                                      # humanhealth_featureprop:- (cv = 'humanhealth_featureprop type', cvterm = 'human_disease_relevant')
    'GA83a', 'data_link', # feature_dbxref (db = 'GA83b', accession = ' GA83a')
    'GA83b', 'data_link', # db to be used in GA83a
    'GA83c', 'description', # dbxref.description
    'GA83d', 'action',    # remove the above GA83's
    'GA84a', 'HDM_comment', # featureprop:- cv = 'property type', cvterm = 'HDM_comment'
    'GA84b', 'allele_report_comment', # featureprop:- cv = 'property type', cvterm = 'allele_report_comment'
);

my @GA19field = (
    ' ',
    'In transgenic Drosophila (intraspecific)',
    'Whole-organism transient assay (intraspecific)',
    'Drosophila cell culture',
    '',
'In transgenic Drosophila (allele of one drosophilid species in genome of another drosophilid)',
'Whole-organism transient assay (allele from one drosophilid species assayed in another drosophilid)',
'In transgenic Drosophila (allele of foreign species in genome of drosophilid)',
'Whole-organism transient assay (allele of foreign species assayed in drosophilid)'
);
my %GA21mapping = (
    'Rescues',               'rescues',
    'Fails to rescue',       'non_rescues',
    'Partially rescues',     'part_rescues',
    'Complements',           'complements',
    'Fails to complement',   'non_complements',
    'Partially complements', 'part_complements'
);

my %environments = (
    'temperature conditional',         '1',
    'heat sensitive',                  '1',
    'cold sensitive',                  '1',
    'drug conditional',                '1',
    'RU486 conditional',               '1',
    'tetracycline conditional',        '1',
    'conditional',                     '1',
    'chemical conditional',            '1',
    'nutrition conditional',           '1',
    'calorie restriction conditional', '1',
    'beta-estradiol conditional',      '1',
);

my %cvtermprop = (
    'GA8',  'origin_of_mutation', 'GA4', 'allele_class',
    'GA19', 'mode_of_assay'
);
my %droso = (
    'Chymomyza',      1, 'Dettopsomyia',     1, 'Dichaetophora',    1,
    'Drosophila',     1, 'Hirtodrosophila',  1, 'Idiomyia',         1,
    'Leucophenga',    1, 'Liodrosophila',    1, 'Lordiphosa',       1,
    'Mycodrosophila', 1, 'Phortica',         1, 'Rhinoleucophenga', 1,
    'Samoaia',        1, 'Scaptodrosophila', 1, 'Scaptomyza',       1,
    'Stegana',        1, 'Zaprionus',        1
);

my %ga91a_type =
  ( 'experimental_result', 1, 'member_of_reagent_collection', 1 );

# update 01-29-2014 to use DO specific evidence codes
# taken from Gene.pm - evidence codes for GO used in DO curation statements
my %GOabbr = (
    CEC => 'CEC',
    CEA => 'CEA',
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
    print STDERR "processing Allele " . $ph{GA1a} . "...\n";
    if ( exists( $self->{validate} ) && $self->{validate} == 1 ) {
        $self->validate(%ph);
    }
    if ( exists( $fbids{ $ph{GA1a} } ) ) {
        $unique = $fbids{ $ph{GA1a} };
    }
    else {
        ( $unique, $out ) = $self->write_feature($tihash);
    }
    if ( exists( $fbcheck{ $ph{GA1a} }{ $ph{pub} } ) ) {
        print STDERR
          "Warning: $ph{GA1a} $ph{pub} exists in a previous proforma\n";
    }
    $fbcheck{ $ph{GA1a} }{ $ph{pub} } = 1;
    if ( !exists( $ph{GA32b} ) ) {
        print STDERR
          "Action Items: allele $unique == $ph{GA1a} with pub $ph{pub}\n";
        my $f_p = create_ch_feature_pub(
            doc        => $doc,
            feature_id => $unique,
            pub_id     => $ph{pub}
        );

        $out .= dom_toString($f_p);
        $f_p->dispose();
    }
    else {
        print STDERR "Action Items: dissociate $ph{GA1a} with pub $ph{pub}\n";
        $out .= dissociate_with_pub( $self->{db}, $unique, $ph{pub} );

        return $out;
    }
    if ( exists( $ph{GA32a} ) && $ph{GA32a} eq 'y' ) {
        print STDERR "Action Items: delete allele $unique == $ph{GA1a}\n";
        return $out;

    }
    ###check mutagen/... for genotype groups
    my $group = 0;
    if ( defined( $ph{GA10a} ) ) {
        $group = 1;
    }
    if (   defined( $ph{GA8} )
        && $ph{GA8} ne ''
        && $ph{GA8} =~ /in vitro construct/ )
    {
        $group = 1;
    }
    if ( $group == 0 ) {
        $group = check_al_with_fr_or_mutagen( $self->{db}, $unique );
    }

    ##Process other field in Trangenic Insertion proforma
    foreach my $f ( keys %ph ) {

        if ( $f eq 'GA1b' || $f eq 'GA2b' ) {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{GA1a} $f  $ph{pub}\n";
                $out .=
                  delete_feature_synonym( $self->{db}, $doc, $unique, $ph{pub},
                    $fpr_type{$f} );

            }
            print STDERR "processing GA1b for Allele " . $ph{GA1a} . "...\n";

            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {

                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    print STDERR "processing GA1b for Allele $ph{GA1a} $item\n";

                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    my $t = $f;
                    $t =~ s/^GA\d//;

                    if ( $item ne 'unnamed' && $item ne '' ) {
                        if ( ( $f eq 'GA1b' ) && ( $item eq $ph{GA1a} ) ) {
                            $t = 'a';
                        }
                        elsif (( $f eq 'GA2b' )
                            && exists( $ph{GA2a} )
                            && ( $item eq $ph{GA2a} ) )
                        {
                            $t = 'a';
                        }
                        elsif ( !exists( $ph{GA2a} ) && $f eq 'GA2b' ) {
                            $t =
                              check_feature_synonym_is_current( $self->{db},
                                $unique, $item, 'fullname' );
                        }
                        $out .=
                          write_feature_synonyms( $doc, $unique, $item, $t,
                            $ph{pub}, $fpr_type{$f} );
                    }
                }
            }
        }    # end  if ( $f eq 'GA1b' || $f eq 'GA2b' )
        elsif ( $f eq 'GA2a' ) {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "ERROR: GA2a can not accept !c\n";
            }
            my $num = check_feature_synonym( $self->{db}, $unique, 'fullname' );
            if ( $num != 0 ) {
                if (
                    (
                           defined( $ph{GA2c} )
                        && $ph{GA2c} eq ''
                        && !defined( $ph{GA1f} )
                    )
                    || ( !defined( $ph{GA2c} ) && !defined( $ph{GA1f} ) )
                  )
                {
                    print STDERR
                      "ERROR: GA2a must have GA2c filled in unless a merge\n";
                }
                else {
                    $out .= write_feature_synonyms( $doc, $unique, $ph{$f}, 'a',
                        'unattributed', $fpr_type{$f} );
                }
            }
            else {
                $out .= write_feature_synonyms( $doc, $unique, $ph{$f}, 'a',
                    'unattributed', $fpr_type{$f} );
            }

#Was just this but assume need same checks as Gene
#	  $out.=write_feature_synonyms($doc,$unique,$ph{$f},'a','unattributed',$fpr_type{$f});
        }    # end elsif($f eq 'GA2a')

        elsif ( $f eq 'GA1e' || $f eq 'GA2c' ) {
            $out .=
              update_feature_synonym( $self->{db}, $doc, $unique, $ph{$f},
                $fpr_type{$f} );

        }
        elsif ( $f eq 'GA32b' ) {
            print STDERR
              "Action Items: $ph{GA1a} dissociate with pub $ph{pub}\n";
            $out .= dissociate_with_pub( $self->{db}, $unique, $ph{pub} );
        }

        elsif ( $f eq 'GA1f' ) {
            $out .= merge_records(
                $self->{db}, $unique,  $ph{$f},
                $ph{GA1a},   $ph{pub}, $ph{GA2a}
            );

        }
        elsif ( $f eq 'GA33' ) {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{GA1a} $f  $ph{pub}\n";
                my @result =
                  get_dbxref_by_feature_db( $self->{db}, $unique, 'GB' );
                my @prresult = get_dbxref_by_feature_db( $self->{db}, $unique,
                    'GB_protein' );
                foreach my $tt ( @result, @prresult ) {
                    my $fd = create_ch_feature_dbxref(
                        doc        => $doc,
                        feature_id => $unique,
                        dbxref_id  => create_ch_dbxref(
                            doc       => $doc,
                            db        => $tt->{db},
                            accession => $tt->{acc},
                            version   => $tt->{version}
                        )
                    );
                    $fd->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($fd);
                }
            }
            if ( $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $out .=
                      process_sequence_curation( $self->{db}, $doc, $unique,
                        $item );
                }
            }
        }
        elsif ( $f eq 'GA10g' ) {
            my $object  = 'subject_id';
            my $subject = 'object_id';
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{GA1a} $f  $ph{pub}\n";
                my @results =
                  get_unique_key_for_fr( $self->{db}, $subject, $object,
                    $unique, 'associated_with', $ph{pub} );
                foreach my $ta (@results) {
                    my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );
                    if ( $num == 1 ) {
                        $out .=
                          delete_feature_relationship( $self->{db}, $doc, $ta,
                            $subject, $object, $unique, 'associated_with' );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_feature_relationship_pub( $self->{db}, $doc,
                            $ta, $subject, $object, $unique, 'associated_with',
                            $ph{pub} );
                    }
                }
                my @fpresults =
                  get_unique_key_for_featureprop( $self->{db}, $unique,
                    'cyto_change_comment', $ph{pub} );
                foreach my $t (@fpresults) {
                    my $num = get_fprop_pub_nums( $self->{db}, $t->{fp_id} );
                    if ( $num == 1 ) {
                        $out .=
                          delete_featureprop( $doc, $t->{rank}, $unique,
                            'cyto_change_comment' );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_featureprop_pub( $doc, $t->{rank}, $unique,
                            'cyto_change_comment', $ph{pub} );
                    }
                }

            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {

                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    if ( $item eq '+' ) {
                        $out .=
                          write_featureprop( $self->{db}, $doc, $unique,
                            'Polytene chromosomes normal',
                            'cyto_change_comment', $ph{pub} );
                    }
                    else {
                        my $o_unique = '';
                        if ( $fbids{$item} ) {
                            $o_unique = $fbids{$item};
                        }
                        else {

                            (
                                $o_unique,
                                my $o_genus,
                                my $o_species,
                                my $o_type
                            ) = get_feat_ukeys_by_name( $self->{db}, $item );
                            if ( $o_unique eq '0' ) {
                                $o_genus   = $genus;
                                $o_species = $species;
                                $o_type    = $feat_type{$f};
                                ( $o_unique, undef ) =
                                  get_tempid( $id_type{$f}, $item );
                            }
                            my $o_f = create_ch_feature(
                                doc        => $doc,
                                uniquename => $o_unique,
                                genus      => $o_genus,
                                species    => $o_species,
                                type       => $o_type,
                                macro_id   => $o_unique,
                                no_lookup  => 1
                            );
                            $out .= dom_toString($o_f);
                            $o_f->dispose();
                        }
                        my $fr = create_ch_fr(
                            doc      => $doc,
                            $subject => $unique,
                            $object  => $o_unique,
                            rtype    => 'associated_with'
                        );
                        my $fr_pub =
                          create_ch_fr_pub( doc => $doc, pub_id => $ph{pub} );
                        $fr->appendChild($fr_pub);
                        $out .= dom_toString($fr);
                        $fr->dispose();
                    }
                }
            }
        }    #elsif ( $f eq 'GA10g' )
        # 'gene' comes from previous gene proforma
        # So creating feature relationship between the 2.
        elsif ( $f eq 'gene' ) {
            my $object  = 'object_id';
            my $subject = 'subject_id';
            my ( $fr1, $f_p1 ) =
              write_feature_relationship( $self->{db}, $doc, $subject, $object,
                $unique, $ph{gene}, $fpr_type{$f}, 'unattributed' );
            $out .= dom_toString($fr1);
            $out .= $f_p1;
            if ( !exists( $ph{GA1f} )
                && ( $ph{GA1g} eq 'y' || exists( $ph{GA1e} ) ) )
            {
                my ( $gn, $n, $r ) = get_alleleof_gene( $self->{db}, $unique );
                print STDERR "$gn, $ph{gene}\n";
                if ( $gn ne '0' && ( $gn ne $ph{gene} ) ) {
                    my ( $o_genus, $o_species, $o_type ) =
                      get_feat_ukeys_by_uname( $self->{db}, $gn, 'f' );
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
                        $subject => $unique,
                        $object  => $o_f,
                        rtype    => $fpr_type{$f},
                        rank     => $r
                    );
                    $o_fr->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($o_fr);
                }
            }

            if ( !( exists( $ph{GA32b} ) && $ph{GA32b} eq 'y' ) ) {
                my ( $fr, $f_p ) =
                  write_feature_relationship( $self->{db}, $doc, $subject,
                    $object, $unique, $ph{gene}, $fpr_type{$f}, $ph{pub} );
                $out .= dom_toString($fr);
                $out .= $f_p;
            }

        }    # end elsif ( $f eq 'gene' )
        elsif ($f eq 'GA82'){

            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                my @items = split( /\n/, $ph{$f} );
            	foreach my $item (@items) {
                    # second param is undefined here as we want all hh for an allele/pub.
                    my @results = get_unique_key_for_humanhealth_featureprop($db, undef, $ph{'GA1a'}, $fpr_type{$f}, $ph{pub}, 'humanhealth_featureprop type');
	                my $num = scalar(@results);
	                if($num >0){
	                    foreach my $t (@results) {
                            print STDERR "Deleting $t->{uname} $t->{hh_name}\n";
		                    $out .= delete_humanhealth_featureprop( $db, $doc, $t->{hh_name}, $t->{uname}, $fpr_type{$f}, $t->{rank}, $ph{pub}, 'humanhealth_featureprop type', 'delete_hh_f');
	                    }
	                }                
	                else{
	                    print STDERR "ERROR:No previous record found for :$item:$ph{'GA1a'}:$fpr_type{$f}:$ph{pub}:$f:\n";           
	                }
                }
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) { 
                     $out .= $self->humanhealth_feature($item, $unique, $fpr_type{$f}, $ph{pub})
                }
            }
        }
        elsif ($f eq 'GA80a' && exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ){
            # GA80a is bang c, so need to remove feature_relationshipprop for 
            # this Allele and GA80b.
            #
            if (defined( $ph{'GA80b'}) && $ph{'GA80b'} ne '') {
                my @results = get_unique_key_for_frp_by_feattype(
                    $self->{db},   'subject_id', 'object_id', $unique, $ph{'GA80b'},
                    $fpr_type{'GA80b'}, $ph{pub}, $feat_type{'GA80b'}
                );
                foreach my $ta (@results) {
                    my ( $fr, $f_p ) = write_feature_relationship(
                        $self->{db},   $doc,     'subject_id',
                        'object_id',       $unique,  $ta->{name},
                        $fpr_type{'GA80b'}, $ph{pub}, $feat_type{'GA80b'},
                        $id_type{$f}
                    );
                    my $fprop = create_ch_frprop(
                        doc   => $doc,
                        type_id  =>create_ch_cvterm(
                            name=> $fpr_type{'GA80a'},
                            doc=>$doc,
                            cv=>'feature_relationshipprop type'),
                        rank  => $ta->{rank}
                    );
                    $fprop->setAttribute( "op", "delete" );
                    $fr->appendChild($fprop);
                    $out .= dom_toString($fr);
                    $out .= $f_p;
                    $fr->dispose();
                }
            }    #end !c        
        }
        elsif ($f eq 'GA80'){
            # Presuming here that if we have multiple entries
            # then we cannot !c. So just doing addition.
            my $object  = 'object_id';
            my $subject = 'subject_id';
            foreach my $fields (@{$ph{$f}}) {
                my $item = $$fields{'GA80b'};
                $item =~ s/^\s+//;
                $item =~ s/\s+$//;
                $out .= feature_relationship_process(
                    $self, $unique, 'GA80b', $fields, $ph{pub},
                    $item, $object, $subject);
            }
        }
        elsif ($f eq 'GA11'
            || $f eq 'GA30'
            || $f eq 'GA80b' )
        {
            my $object  = 'object_id';
            my $subject = 'subject_id';
            if ( $f eq 'GA30' ) {
                $object  = 'subject_id';
                $subject = 'object_id';
            }
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{GA1a} $f  $ph{pub}\n";
                my @results = get_unique_key_for_fr_by_feattype(
                    $self->{db},   $subject, $object, $unique,
                    $fpr_type{$f}, $ph{pub}, $feat_type{$f}
                );
                # print STDERR "Results of lookup", @results, "\n";
                foreach my $ta (@results) {
                    my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );

                    # print STDERR "fr number $num\n";
                    if (
                        $num == 1
                        || ( defined( $frnum{$unique}{ $ta->{name} } )
                            && $num - $frnum{$unique}{ $ta->{name} } == 1 )
                      )
                    {
#print STDERR "Warning: deleting feature_relationship $unique $f ",$ta->{name}," ", $ph{pub},"\n";
                        $out .=
                          delete_feature_relationship( $self->{db}, $doc, $ta,
                            $subject, $object, $unique, $fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_feature_relationship_pub( $self->{db}, $doc,
                            $ta, $subject, $object, $unique, $fpr_type{$f},
                            $ph{pub} );
                    }
                    else {
                        print STDERR
                          "ERROR:something Wrong, please validate first\n";
                    }
                }
            }    #end !c
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    $out .= feature_relationship_process(
                        $self, $unique, $f, \%ph, $ph{pub},
                        $item, $object, $subject);
                }
            }
            
        }    # end elsif ($f eq 'GA11' || $f eq 'GA30'

        elsif ($f eq 'GA10a'
            || $f eq 'GA10c'
            || $f eq 'GA10e' )
        {
            my $object  = 'object_id';
            my $subject = 'subject_id';
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{GA1a} $f  $ph{pub}\n";
                if ( $f eq 'GA10a' ) {
                    my @types = ( 'transgenic_transposable_element', 'engineered_region', 'cloned_region' );
                    foreach my $t (@types) {
                        my @results =
                          get_unique_key_for_fr_by_feattype( $self->{db},
                            $subject, $object,
                            $unique, $fpr_type{$f}, $ph{pub}, $t );
                        foreach my $ta (@results) {
                            my $num =
                              get_fr_pub_nums( $self->{db}, $ta->{fr_id} );

                            #print STDERR "fr number $num\n";
                            if (
                                $num == 1
                                || ( defined( $frnum{$unique}{ $ta->{name} } )
                                    && $num - $frnum{$unique}{ $ta->{name} } ==
                                    1 )
                              )
                            {
#print STDERR "Warning: deleting feature_relationship $unique $f ",$ta->{name}," ", $ph{pub},"\n";
                                $out .=
                                  delete_feature_relationship( $self->{db},
                                    $doc, $ta,
                                    $subject, $object, $unique, $fpr_type{$f} );
                            }
                            elsif ( $num > 1 ) {
                                $out .=
                                  delete_feature_relationship_pub( $self->{db},
                                    $doc,
                                    $ta, $subject, $object, $unique,
                                    $fpr_type{$f}, $ph{pub} );
                            }
                            else {
                                print STDERR
"ERROR:something Wrong, please validate first\n";
                            }
                        }
                    }
                }
                else {
                    my @types = (
                        'transposable_element_insertion_site',
                        'insertion_site'
                    );
                    foreach my $t (@types) {
                        my @results =
                          get_unique_key_for_fr_by_feattype( $self->{db},
                            $subject, $object,
                            $unique, $fpr_type{$f}, $ph{pub}, $t );
                        foreach my $ta (@results) {
                            my $num =
                              get_fr_pub_nums( $self->{db}, $ta->{fr_id} );

                            #print STDERR "fr number $num\n";
                            if (
                                $num == 1
                                || ( defined( $frnum{$unique}{ $ta->{name} } )
                                    && $num - $frnum{$unique}{ $ta->{name} } ==
                                    1 )
                              )
                            {
#  print STDERR "DEBUG: deleting feature_relationship $unique $f ",$ta->{name}," ", $ph{pub},"\n";
                                $out .=
                                  delete_feature_relationship( $self->{db},
                                    $doc, $ta,
                                    $subject, $object, $unique, $fpr_type{$f} );
                            }
                            elsif ( $num > 1 ) {
                                $out .=
                                  delete_feature_relationship_pub( $self->{db},
                                    $doc,
                                    $ta, $subject, $object, $unique,
                                    $fpr_type{$f}, $ph{pub} );
                            }
                            else {
                                print STDERR
"ERROR:something Wrong, please validate first\n";
                            }
                        }
                    }
                }
            }    #end !c
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                my $o_unique  = '';
                my $o_genus   = '';
                my $o_species = '';
                my $o_type    = '';
                my $is_c      = 'f';
                my @items     = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    my $flag = 0;
                    my $new  = 0;

                    if ( $item =~ /NEW:(.*)/ ) {
                        $item = $1;
                        $new  = 1;
                    }
                    my $ftype = $feat_type{$f};
                    if ( $f eq 'GA10a' && $item =~ /TI\{/ ) {
                        $ftype = 'engineered_region';
                    }
                    if (   $f eq 'GA10e' && $item =~ /TI\{/
                        || $f eq 'GA10c' && $item =~ /TI\{/ )
                    {
                        $ftype = 'insertion_site';
                    }

                    my ( $fr, $f_p ) = write_feature_relationship(
                        $self->{db},   $doc,     $subject,
                        $object,       $unique,  $item,
                        $fpr_type{$f}, $ph{pub}, $ftype,
                        $id_type{$f}
                    );
                    my $syn_dom = '';
                    if (   ( $f eq 'GA10a' && exists( $ph{'GA10b.upd'} ) )
                        || ( $f eq 'GA10c' && exists( $ph{'GA10e.upd'} ) )
                        || ( $f eq 'GA10d' && exists( $ph{'GA10f.upd'} ) ) )
                    {
                        my $o_u = '';
                        if ( exists( $fbids{$item} ) ) {
                            $o_u = $fbids{$item};
                        }
                        else {
                            print STDERR
"ERROR: could not get uniquename for $o_u for GA10b.upd\n";
                        }

                        $out .=
                          delete_feature_synonym( $self->{db}, $doc, $o_u,
                            $ph{pub}, 'symbol' );
                    }
                    if ( $f eq 'GA10a' && exists( $ph{GA10b} ) ) {
                        my @s_ns = split( /\n/, $ph{GA10b} );
                        foreach my $s_name (@s_ns) {
                            if ( $s_name eq $item ) {
                                $is_c = 't';
                            }
                            else {
                                $is_c = 'f';
                            }
                            my $f_s = create_ch_feature_synonym(
                                doc          => $doc,
                                feature_id   => $fbids{$item},
                                name         => decon( convers($s_name) ),
                                type         => 'symbol',
                                synonym_sgml => toutf( convers($s_name) ),
                                pub_id       => $ph{pub},
                                is_current   => $is_c
                            );
                            $syn_dom .= dom_toString($f_s);
                            $f_s->dispose();
                        }
                        $out .= dom_toString($fr);
                    }
                    elsif ( $f eq 'GA10c' ) {
                        if ( exists( $ph{GA10d} ) ) {
                            my @s_ns = split( /\n/, $ph{GA10d} );
                            foreach my $s_name (@s_ns) {
                                if ( $s_name eq $item ) {
                                    $is_c = 't';
                                }
                                else {
                                    $is_c = 'f';
                                }
                                my $f_s = create_ch_feature_synonym(
                                    doc          => $doc,
                                    feature_id   => $fbids{$item},
                                    name         => decon( convers($s_name) ),
                                    type         => 'symbol',
                                    synonym_sgml => toutf( convers($s_name) ),
                                    pub_id       => $ph{pub},
                                    is_current   => $is_c
                                );
                                $syn_dom .= dom_toString($f_s);
                                $f_s->dispose();
                            }
                        }

                        my $rank =
                          get_frprop_rank( $self->{db}, $subject, $object,
                            $unique, $item, $fpr_type{GA10c}, 'outside' );
                        my $frprop = create_ch_frprop(
                            doc   => $doc,
                            value => 'outside',
                            type  => 'relative_position',
                            rank  => $rank
                        );
                        my $frprop_pub = create_ch_frprop_pub(
                            doc    => $doc,
                            pub_id => $ph{pub}
                        );
                        $frprop->appendChild($frprop_pub);
                        $fr->appendChild($frprop);

                        my ( $f_g, $g_p ) =
                          write_feature_relationship( $self->{db}, $doc,
                            $subject, $object, $ph{gene}, $item,
                            $fpr_type{$f}, $ph{pub} );
                        $out .= dom_toString($fr);
                        $out .= dom_toString($f_g);
                    }
                    elsif ( $f eq 'GA10e' ) {
                        if ( exists( $ph{GA10f} ) ) {
                            my @s_ns = split( /\n/, $ph{GA10f} );
                            foreach my $s_name (@s_ns) {
                                if ( $s_name eq $item ) {
                                    $is_c = 't';
                                }
                                else {
                                    $is_c = 'f';
                                }
                                my $f_s = create_ch_feature_synonym(
                                    doc          => $doc,
                                    feature_id   => $fbids{$item},
                                    name         => decon( convers($s_name) ),
                                    type         => 'symbol',
                                    synonym_sgml => toutf( convers($s_name) ),
                                    pub_id       => $ph{pub},
                                    is_current   => $is_c
                                );
                                $syn_dom .= dom_toString($f_s);
                                $f_s->dispose();
                            }
                        }
                        my $rank =
                          get_frprop_rank( $self->{db}, $subject, $object,
                            $unique, $item, $fpr_type{GA10e}, 'inside' );
                        my $frprop = create_ch_frprop(
                            doc   => $doc,
                            value => 'inside',
                            type  => 'relative_position',
                            rank  => $rank
                        );
                        $fr->appendChild($frprop);
                        my $frprop_pub = create_ch_frprop_pub(
                            doc    => $doc,
                            pub_id => $ph{pub}
                        );
                        $frprop->appendChild($frprop_pub);
##JIRA DC-342
           #                        my ($f_g,$g_p) = write_feature_relationship(
           #                        $self->{db},   $doc,     $subject,
           #                        $object,       $ph{gene},$item,
           #                        $fpr_type{$f}, $ph{pub}
           #                        );
                        $out .= dom_toString($fr);

                        #                        $out.=dom_toString($f_g);
                    }
                    else {
                        $out .= dom_toString($fr);
                    }
                    if ( ( $f eq 'GA10c' || $f eq 'GA10e' ) && $new == 1 ) {
                        print STDERR "DEBUG: field in testing \n";
                        my $construct = $item;
                        print STDERR "DEBUG: construct = $construct\n";

                        if ( $construct =~ /(.*\}{1,})/ ) {
                            $construct = $1;
                        }
                        if ( $construct =~ /(\w.*)\{\}$/ ) {
                            $construct = $1;
                        }
                        if ( $construct eq 'H' ) {
                            $construct = 'hobo';
                        }
                        print STDERR
                          "DEBUG: construct = pulled out $construct\n";

                        if ( !exists( $fbids{$construct} ) ) {
                            my ( $u, $g, $s, $t ) =
                              get_feat_ukeys_by_name( $self->{db}, $construct );
                            if ( $u eq '0' || $t eq 'gene' ) {
                                if ( !( $construct =~ /\{\}$/ ) ) {
                                    $construct .= '-element';
                                    ( $u, $g, $s, $t ) =
                                      get_feat_ukeys_by_name( $self->{db},
                                        $construct );
                                    if ( $u eq '0' ) {
                                        print STDERR
"ERROR: Natural TE $construct is not in DB(check)\n";
                                    }
                                }
                                else {
                                    print STDERR
"ERROR: could not find construct for $item\n";
                                }

                            }
                        }
                        my ( $ipfr, $ipf_p ) = write_feature_relationship(
                            $self->{db},   $doc,
                            'subject_id',  'object_id',
                            $fbids{$item}, $construct,
                            'producedby',  $ph{pub}
                        );
                        $out .= dom_toString($ipfr);
                        $out .= $ipf_p;
                    }
                    $out .= $f_p;
                    $fr->dispose();
                    $out .= $syn_dom;
                }
            }
        }    # end elsif ($f eq 'GA10a' || $f eq 'GA10c' || $f eq 'GA10e')

        elsif ($f eq 'GA31'
            || $f eq 'GA15'
            || $f eq 'GA23a'
            || $f eq 'GA23b'
            || $f eq 'GA12a'
            || $f eq 'GA12b'
            || $f eq 'GA13'
            || $f eq 'GA20'
            || $f eq 'GA14'
            || $f eq 'GA34b'
            || $f eq 'GA34c'
            || $f eq 'GA80c'
            || $f eq 'GA81a'
            || $f eq 'GA81b'
            || $f eq 'GA84a'
            || $f eq 'GA84b' )
        {
            my $proptype = $fpr_type{$f};

            #	    my $cv = 'property type';
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{GA1a} $f  $ph{pub}\n";
                my @types = split( /\//, $fpr_type{$f} );
                foreach my $ty (@types) {
                    my @results =
                      get_unique_key_for_featureprop( $self->{db}, $unique, $ty,
                        $ph{pub} );
                    foreach my $t (@results) {
                        my $num =
                          get_fprop_pub_nums( $self->{db}, $t->{fp_id} );
                        if (
                            $num == 1
                            || (
                                defined(
                                    $frnum{$unique}{ $fpr_type{$f} }
                                      { $t->{rank} }
                                )
                                && $num -
                                $frnum{$unique}{ $fpr_type{$f} }{ $t->{rank} }
                                == 1
                            )
                          )
                        {
                            $out .=
                              delete_featureprop( $doc, $t->{rank}, $unique,
                                $ty );
                        }
                        elsif ( $num > 1 ) {
                            $out .=
                              delete_featureprop_pub( $doc, $t->{rank}, $unique,
                                $ty, $ph{pub} );
                        }
                    }
                }
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    if ( $item ne '' ) {
                        if ( $f eq 'GA12a' ) {
                            if ( $item =~ /Amino acid replacement:/ ) {
                                $proptype = 'aminoacid_rep';
                            }
                            elsif ( $item =~ /Nucleotide substitution:/ ) {
                                $proptype = 'nucleotide_sub';
                            }
                            else {
                                print STDERR "ERROR: can not get type for GA12a $item $unique\n";
                            }
                        }
                        $out .=
                          write_featureprop( $self->{db}, $doc, $unique, $item,
                            $proptype, $ph{pub} );
                    }
                }
            }
        } # end elsif ($f eq 'GA31' || $f eq 'GA15' || $f eq 'GA23a' || $f eq 'GA23b' || $f eq 'GA12a'
          #   || $f eq 'GA12b' || $f eq 'GA13' || $f eq 'GA20' || $f eq 'GA14' )

        elsif ( $f eq 'GA56' || $f eq 'GA17' ) {
            if ( exists( $ph{"$f.upd"} ) ) {

                #print STDERR "Action Items: !c log,$ph{GA1a} $f  $ph{pub}\n";
                print STDERR "ERROR: has not implemented yet $f.upd\n";
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    if ( $item ne '' ) {
                        my $with      = '';
                        my $driver    = '';
                        my @cvterms   = ();
                        my @genotypes = ();

                        if ( $item =~ /^\(with\s(.*?)\)\s(.*)/ ) {
                            $with = $1;
                            $item = $2;
                            my $withcount = $with;
                            my $lcou      = ( $withcount =~ tr/\(// );
                            my $rcou      = ( $withcount =~ tr/\)// );
                            if ( $lcou - $rcou == 1 ) {
                                if ( $item =~ /(.*?)\)(.*)/ ) {
                                    $with .= ' ' . $1;
                                    $item = $2;
                                }

                                else {
                                    print STDERR
                                      "ERROR, could not parse GA56/GA17\n";
                                }
                            }
                        }
                        if ( $item =~ /(.*)\s\{\s(.*)\s\}/ ) {
                            $driver = $2;
                            $item   = $1;
                        }
                        $item =~ s/^\s+//;
                        $item =~ s/\s+$//;
                        if ( $with eq '' && $driver eq '' ) {
                            my $gr = $ph{GA1a};
                            push( @genotypes, $gr );
                        }
                        else {
                            if ( $with ne '' ) {
                                my @groups =
                                  parse_genotype_group( $with, 'with',
                                    $ph{GA1a}, $group );
                                push( @genotypes, @groups );
                            }
                            if ( $driver ne '' ) {
                                my @groups =
                                  parse_genotype_group( $driver, 'driver',
                                    $ph{GA1a}, $group );
                                push( @genotypes, @groups );
                            }
                        }
                        my $a  = join( ' ', @genotypes );
                        my $na = $ph{GA1a};
                        $na =~ s/([\'\#\"\[\]\|\\\/\(\)\+\-\.])/\\$1/g;

                        #print STDERR "check name$a, $na\n";
                        if ( !( $a =~ /$na/ ) ) {
                            push( @genotypes, $ph{GA1a} );
                        }
                        @genotypes = sort @genotypes;

                        my ( $phenout, $phenotype, $environment ) =
                          write_phenotype( $f, $item );
                        if ( !exists( $fprank{environ}{$environment} ) ) {
                            $out .= dom_toString(
                                create_ch_environment(
                                    doc        => $doc,
                                    uniquename => $environment,
                                    macro_id   => $environment
                                )
                            );
                            $fprank{environ}{$environment} = 1;
                        }
                        if ( !exists( $fprank{phenotype}{$phenotype} ) ) {

                            $out .= $phenout;
                            $fprank{phenotype}{$phenotype} = 1;
                        }
                        my $genotype = join( ' ', @genotypes );
                        $genotype =~ s/:::/\//g;
                        $genotype = convers($genotype);
                        if ( !exists( $fprank{genotype}{$genotype} ) ) {
                            my $genotype_f = create_ch_genotype(
                                doc        => $doc,
                                uniquename => $genotype,
                                macro_id   => $genotype
                            );
                            $out .= dom_toString($genotype_f);
                            $genotype_f->dispose();
                            $out .=
                              write_feature_genotype( $genotype, @genotypes );
                            $fprank{genotype}{$genotype} = 1;
                        }

                        my $phenstatement = create_ch_phenstatement(
                            doc            => $doc,
                            genotype_id    => $genotype,
                            phenotype_id   => $phenotype,
                            environment_id => $environment,
                            type_id        => 'unspecified',
                            pub_id         => $ph{pub}
                        );
                        $out .= dom_toString($phenstatement);
                        $phenstatement->dispose();

                    }
                }
            }
        }    # end  elsif ( $f eq 'GA56' || $f eq 'GA17' )

        elsif ( $f eq 'GA21' ) {
            my $phenotype1_id   = 'unspecified';
            my $phenotype2_id   = 'unspecified';
            my $environment1_id = 'unspecified';
            my $environment2_id = 'unspecified';
            my $cv              = 'FlyBase miscellaneous CV';

            if ( exists( $ph{"$f.upd"} ) ) {
                print STDERR "Action Items: !c log,$ph{GA1a} $f  $ph{pub}\n";
                print STDERR "ERROR: has not implemented yet $f.upd\n";
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    my $GA21type     = '';
                    my $genotype1_id = '';
                    my $genotype2_id = '';
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    if ( $item =~ /(.*):\s(.*)/ ) {
                        $GA21type = $1;
                        $item     = $2;
                    }
                    if ( $GA21type eq '' ) {
                        print STDERR "ERROR: no type for GA21 $ph{$f} $unique,",
                          $ph{GA1a},
                          "\n";
                    }
                    my $with   = '';
                    my $driver = '';
                    if ( $item =~ /^\(with\s(.*)\)\s(.*)/ ) {
                        $with = $1;
                        $item = $2;
                    }
                    if ( $item =~ /(.*)\s\{\s(.*)\s\}/ ) {
                        $driver = $2;
                        $item   = $1;
                    }
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    my $cvterm = $GA21mapping{$GA21type};
                    if ( $GA21type =~ /rescue/i ) {
                        my @ras = split( /\//, $item );
                        if ( @ras > 1 ) {
                            for ( my $i = 0 ; $i <= $#ras ; $i++ ) {
                                if (   $ras[$i] =~ /^[+-]$/
                                    || $ras[$i] =~ /\[[+-]\]/ )
                                {
                                    my $fe = $ras[ $i - 1 ];
                                    my $u  = '';
                                    if ( exists( $fbids{$fe} ) ) {
                                        $u = $fbids{$fe};
                                    }
                                    else {
                                        ( $u, my $g, my $s, my $t ) =
                                          get_feat_ukeys_by_name( $db, $fe );

                                    }
                                    if ( $u eq '0' ) {
                                        print STDERR
"ERROR: could not find record for $fe\n";
                                    }
                                    elsif ( $u =~ 'FBal' ) {
                                        my ( $gn, $n, $r ) =
                                          get_alleleof_gene( $db, $u );
                                        $ras[$i] = $n . '[' . $ras[$i] . ']';
                                    }
                                }
                            }

                        }    # end if (@ras > 1)
                        @ras = sort @ras;
                        my $genotype1 = join( ':::', @ras );
                        $genotype1_id = $genotype1;
                        $genotype1_id =~ s/:::/\//g;
                        $genotype1_id = convers($genotype1_id);
                        if ( !exists( $fprank{genotype}{$genotype1_id} ) ) {
                            $out .= dom_toString(
                                create_ch_genotype(
                                    doc        => $doc,
                                    uniquename => $genotype1_id,
                                    macro_id   => $genotype1_id
                                )
                            );
                            $out .=
                              write_feature_genotype( $genotype1_id,
                                $genotype1 );
                            $fprank{genotype}{$genotype1_id} = 1;
                        }
                        my @g2 = ();
                        push( @g2, $ph{GA1a} );
                        if ( $with ne '' ) {
                            my @ws = split( /,\s/, $with );
                            push( @g2, @ws );
                        }
                        if ( $driver ne '' ) {
                            my @ds = split( /,\s/, $driver );
                            foreach my $d (@ds) {
                                $d =~ s/^\s+//;
                                $d =~ s/\s+$//;
                            }
                            push( @g2, @ds );
                        }
                        unshift( @g2, $genotype1 );
                        foreach my $d (@g2) {
                            $d =~ s/^\s+//;
                            $d =~ s/\s+$//;
                        }
                        @g2           = sort @g2;
                        $genotype2_id = join( ' ', @g2 );
                        $genotype2_id =~ s/:::/\//g;
                        $genotype2_id = convers($genotype2_id);
                        if ( !exists( $fprank{genotype}{$genotype2_id} ) ) {
                            $out .= dom_toString(
                                create_ch_genotype(
                                    doc        => $doc,
                                    uniquename => $genotype2_id,
                                    macro_id   => $genotype2_id
                                )
                            );
                            $fprank{genotype}{$genotype2_id} = 1;
                        }
                        $out .= write_feature_genotype( $genotype2_id, @g2 );
                    }    # end if GA21 type =~ /rescue/i

                    elsif ( $GA21type =~ /complement/i ) {

                        my $genotype1 = $item . ':::' . $item;
                        my @genotype1 = ();
                        push( @genotype1, $genotype1 );
                        $genotype1 =~ s/:::/\//;
                        $genotype1_id = convers($genotype1);
                        if ( !exists( $fprank{genotype}{$genotype1_id} ) ) {
                            $out .= dom_toString(
                                create_ch_genotype(
                                    doc        => $doc,
                                    uniquename => $genotype1_id,
                                    macro_id   => $genotype1_id
                                )
                            );
                            $fprank{genotype}{$genotype1_id} = 1;
                            $out .=
                              write_feature_genotype( $genotype1_id,
                                @genotype1 );
                        }
                        my @g2        = sort( $ph{GA1a}, $item );
                        my $genotype2 = join( ':::', @g2 );
                        $genotype2_id = join( '/', @g2 );
                        $genotype2_id = convers($genotype2_id);
                        if ( !exists( $fprank{genotype}{$genotype2_id} ) ) {
                            $out .= dom_toString(
                                create_ch_genotype(
                                    doc        => $doc,
                                    uniquename => $genotype2_id,
                                    macro_id   => $genotype2_id
                                )
                            );
                            $fprank{genotype}{$genotype2_id} = 1;
                            $out .=
                              write_feature_genotype( $genotype2_id,
                                $genotype2 );
                        }
                    }
                    my $organism_id = 'autogenetic';
                    if ( !exists( $droso{$genus} ) ) {
                        $organism_id = 'xenogenetic';
                    }
                    my $ppc = create_ch_phenotype_comparison(
                        doc             => $doc,
                        genotype1_id    => $genotype1_id,
                        pub_id          => $ph{pub},
                        genotype2_id    => $genotype2_id,
                        phenotype1_id   => 'unspecified',
                        phenotype2_id   => 'unspecified',
                        environment1_id => 'unspecified',
                        environment2_id => 'unspecified',
                        organism_id     => $organism_id
                    );
                    my $ppc_cv = create_ch_phenotype_comparison_cvterm(
                        doc       => $doc,
                        cvterm_id => create_ch_cvterm(
                            doc  => $doc,
                            name => $cvterm,
                            cv   => $cv
                        ),
                        rank => '0'
                    );
                    $ppc->appendChild($ppc_cv);
                    $out .= dom_toString($ppc);
                    $ppc->dispose();
                }
            }
        }    # end elsif ( $f eq 'GA21' )

        elsif ( $f =~ /GA28[a-b]$/ || $f =~ /GA29[ab]$/ ) {

            #phenotype_comparison: phenotype2_id=unspecified
            #environment2_id=unspecified
            my $phenotype1_id   = '';
            my $environment1_id = 'unspecified';
            my @genotypes       = ();
            my $organism_id     = 'autogenetic';    #autogenetic
            if ( $f =~ /GA29/ ) {
                $organism_id = 'xenogenetic';       #xenogenetic
            }
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq "c" ) {
                print STDERR "Action Items: !c log,$ph{GA1a} $f  $ph{pub}\n";
                my @list =
                  get_phenotype_comparison( $self->{db}, $ph{pub}, $unique,
                    $organism_id, substr( $f, -1, 1 ) );
                foreach my $l (@list) {

                    my $p_pc = create_ch_phenotype_comparison(
                        doc          => $doc,
                        genotype1_id => create_ch_genotype(
                            doc        => $doc,
                            uniquename => get_genotype_by_id(
                                $self->{db}, $l->{genotype1_id}
                            )
                        ),
                        pub_id       => $ph{pub},
                        genotype2_id => create_ch_genotype(
                            doc        => $doc,
                            uniquename => get_genotype_by_id(
                                $self->{db}, $l->{genotype2_id}
                            )
                        ),
                        phenotype1_id => create_ch_phenotype(
                            doc        => $doc,
                            uniquename => get_phenotype_by_id(
                                $self->{db}, $l->{phenotype1_id}
                            )
                        ),
                        environment1_id => create_ch_environment(
                            doc        => $doc,
                            uniquename => get_environment_by_id(
                                $self->{db}, $l->{environment1_id}
                            )
                        ),
                        environment2_id => create_ch_environment(
                            doc        => $doc,
                            uniquename => get_environment_by_id(
                                $self->{db}, $l->{environment1_id}
                            )
                        ),
                        organism_id => $organism_id
                    );
                    $p_pc->setAttribute( "op", "delete" );
                    $out .= dom_toString($p_pc);
                }
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    if ( $item =~ /non-modified/ ) {
                        print STDERR "PDEV113 $ph{GA1a} $f $item to split\n";
                        my @dup = ( 'non-suppressible', 'non-enhanceable' );
                        foreach my $ni (@dup) {
                            my $newitem = $item;
                            $newitem =~ s/non-modified/$ni/;
                            print STDERR
                              "\tPDEV113 $ph{GA1a}$f $ni ==> $newitem\n";
                            my $g56        = '';
                            my $driver     = '';
                            my $geno_inter = '';
                            if ( $newitem ne '' ) {
                                if ( $newitem =~
                                    /(.*\{\s.*?\s\}),(.*?)\s\{(.*)\s\}/ )
                                {
                                    $g56        = $1;
                                    $driver     = $3;
                                    $geno_inter = $2;
                                }
                                elsif ( $newitem =~
                                    /(\(.*\)\s.*?),(.*)\s\{(.*)\s\}/ )
                                {
                                    $g56        = $1;
                                    $driver     = $3;
                                    $geno_inter = $2;
                                }
                                elsif ( $newitem =~ /(.*),(.*?)\s\{(.*)\s\}/ ) {
                                    $g56        = $1;
                                    $driver     = $3;
                                    $geno_inter = $2;
                                }
                                elsif ( $newitem =~ /(.*)\s\{\s(.*)\s\}/ ) {
                                    $driver     = $2;
                                    $geno_inter = $1;
                                }
                                else {
                                    print STDERR "ERROR; Wrong format for "
                                      . $ph{GA1a} . " "
                                      . $newitem . " $f\n";
                                }
                                print STDERR "GGG $g56, $geno_inter, $driver\n";
                                ###parse $with which is same as GA56
                                my $G56  = $g56;
                                my $with = '';
                                my $g56driver;
                                if (   $g56 =~ /^\(with\s(.*)\)\s(.*)/
                                    || $g56 =~ /^\(with\s(.*?)\)$/ )
                                {
                                    $with = $1;
                                    if ( defined($2) ) {
                                        $g56 = $2;
                                    }
                                    else { $g56 = ''; }
                                }

                                #print "g56 $g56\n";
                                if ( $g56 =~ /(.*)\{\s(.*)\s\}/ ) {
                                    $g56driver = $2;
                                    $g56       = $1;
                                }

                                #print "g56 $g56\n";
                                $g56 =~ s/^\s+//;
                                $g56 =~ s/\s+$//;

                                print STDERR
"FFF $g56, $with, $g56driver,$geno_inter, $driver \n";
                                if ( $g56 eq '' ) {
                                    $phenotype1_id = 'unspecified';

                                }
                                else {
                                    my ( $phenout, $phenotype, $environment ) =
                                      write_phenotype( $f, $g56 );
                                    $phenotype1_id   = $phenotype;
                                    $environment1_id = $environment;
                                    if (
                                        !exists(
                                            $fprank{environ}{$environment}
                                        )
                                      )
                                    {
                                        $out .= dom_toString(
                                            create_ch_environment(
                                                doc        => $doc,
                                                uniquename => $environment,
                                                macro_id   => $environment
                                            )
                                        );
                                        $fprank{environ}{$environment} = 1;
                                    }
                                    if (
                                        !exists(
                                            $fprank{phenotype}{$phenotype}
                                        )
                                      )
                                    {
                                        $out .= $phenout;
                                        $fprank{phenotype}{$phenotype} = 1;
                                    }
                                }

                                @genotypes =
                                  write_genotype( $G56, $ph{GA1a}, $group );
                                my @genotype1 = @genotypes;
                                my @genotype2 = @genotypes;

                                print STDERR "G56 $G56, $driver\n";
                                my @extra =
                                  parse_genotype_group( $driver, 'driver',
                                    $ph{GA1a}, '0' );

                                my @g_terms = split( /\s\|\s/, $geno_inter );
                                my $first   = shift(@g_terms);
                                if ( $first =~ /enhanceable/ ) {
                                    push( @genotype1, @extra );
                                }
                                elsif ( $first =~ /suppressible|UI/ ) {

                                    push( @genotype2, @extra );
                                }
                                else {
                                    print STDERR
"ERROR, $f genetic_interaction type $first not supported\n";
                                }
                                @genotype1 = sort @genotype1;
                                @genotype2 = sort @genotype2;

                                my $genotype1_id = join( ' ', @genotype1 );
                                $genotype1_id =~ s/:::/\//g;
                                $genotype1_id = convers($genotype1_id);
                                if ( !exists( $fprank{genotype}{$genotype1_id} )
                                  )
                                {
                                    my $genotype_f = create_ch_genotype(
                                        doc        => $doc,
                                        uniquename => $genotype1_id,
                                        macro_id   => $genotype1_id
                                    );
                                    $out .= dom_toString($genotype_f);
                                    $genotype_f->dispose();
                                    $out .=
                                      write_feature_genotype( $genotype1_id,
                                        @genotype1 );
                                    $fprank{genotype}{$genotype1_id} = 1;
                                }
                                my $genotype2_id = join( ' ', @genotype2 );
                                $genotype2_id =~ s/:::/\//g;
                                $genotype2_id = convers($genotype2_id);
                                if ( !exists( $fprank{genotype}{$genotype2_id} )
                                  )
                                {
                                    my $genotype_f = create_ch_genotype(
                                        doc        => $doc,
                                        uniquename => $genotype2_id,
                                        macro_id   => $genotype2_id
                                    );
                                    $out .= dom_toString($genotype_f);
                                    $genotype_f->dispose();
                                    $out .=
                                      write_feature_genotype( $genotype2_id,
                                        @genotype2 );
                                    $fprank{genotype}{$genotype2_id} = 1;
                                }

                                #	print "before phenotype_comparison\n";
                                my $phenotype_comparison =
                                  create_ch_phenotype_comparison(
                                    doc             => $doc,
                                    pub_id          => $ph{pub},
                                    environment1_id => $environment1_id,
                                    phenotype2_id   => 'unspecified',
                                    phenotype1_id   => $phenotype1_id,
                                    environment2_id => 'unspecified',
                                    genotype1_id    => $genotype1_id,
                                    genotype2_id    => $genotype2_id,
                                    organism_id     => $organism_id
                                  );

                                my @newterms = sort(@g_terms);
                                unshift( @newterms, $first );
                                my $pccrank = 0;
                                foreach my $term (@newterms) {
                                    $term =~ s/^\s+//;
                                    $term =~ s/\s+$//;

                                    #print "$term\n";
                                    my $cc =
                                      get_cv_by_cvterm( $self->{db}, $term );
                                    if ( !defined($cc) ) {
                                        print STDERR
"Warning: could not find cv for $term\n";
                                    }
                                    my $pcc =
                                      create_ch_phenotype_comparison_cvterm(
                                        doc       => $doc,
                                        cvterm_id => create_ch_cvterm(
                                            doc  => $doc,
                                            name => $term,
                                            cv   => get_cv_by_cvterm(
                                                $self->{db}, $term
                                            )
                                        ),
                                        rank => $pccrank
                                      );
                                    $pccrank++;
                                    $phenotype_comparison->appendChild($pcc);
                                }
                                $out .= dom_toString($phenotype_comparison);
                                $phenotype_comparison->dispose();
                            }
                        }
                    }

                    #not non-modified
                    else {
                        my $g56        = '';
                        my $driver     = '';
                        my $geno_inter = '';

                        if ( $item ne '' ) {
                            if ( $item =~ /(.*\{\s.*?\s\}),(.*?)\s\{(.*)\s\}/ )
                            {
                                $g56        = $1;
                                $driver     = $3;
                                $geno_inter = $2;
                            }
                            elsif ( $item =~ /(\(.*\)\s.*?),(.*)\s\{(.*)\s\}/ )
                            {
                                $g56        = $1;
                                $driver     = $3;
                                $geno_inter = $2;
                            }
                            elsif ( $item =~ /(.*),(.*?)\s\{(.*)\s\}/ ) {
                                $g56        = $1;
                                $driver     = $3;
                                $geno_inter = $2;
                            }
                            elsif ( $item =~ /(.*)\s\{\s(.*)\s\}/ ) {
                                $driver     = $2;
                                $geno_inter = $1;
                            }
                            else {
                                print STDERR "ERROR; Wrong format for "
                                  . $ph{GA1a} . " "
                                  . $item . " $f\n";
                            }
                            print STDERR "GGG $g56, $geno_inter, $driver\n";
                            ###parse $with which is same as GA56
                            my $G56  = $g56;
                            my $with = '';
                            my $g56driver;
                            if (   $g56 =~ /^\(with\s(.*)\)\s(.*)/
                                || $g56 =~ /^\(with\s(.*?)\)$/ )
                            {
                                $with = $1;
                                if ( defined($2) ) {
                                    $g56 = $2;
                                }
                                else { $g56 = ''; }
                            }

                            #print "g56 $g56\n";
                            if ( $g56 =~ /(.*)\{\s(.*)\s\}/ ) {
                                $g56driver = $2;
                                $g56       = $1;
                            }

                            #print "g56 $g56\n";
                            $g56 =~ s/^\s+//;
                            $g56 =~ s/\s+$//;

                            print STDERR
"FFF $g56, $with, $g56driver,$geno_inter, $driver \n";
                            if ( $g56 eq '' ) {
                                $phenotype1_id = 'unspecified';

                            }
                            else {
                                my ( $phenout, $phenotype, $environment ) =
                                  write_phenotype( $f, $g56 );
                                $phenotype1_id   = $phenotype;
                                $environment1_id = $environment;
                                if ( !exists( $fprank{environ}{$environment} ) )
                                {
                                    $out .= dom_toString(
                                        create_ch_environment(
                                            doc        => $doc,
                                            uniquename => $environment,
                                            macro_id   => $environment
                                        )
                                    );
                                    $fprank{environ}{$environment} = 1;
                                }
                                if ( !exists( $fprank{phenotype}{$phenotype} ) )
                                {
                                    $out .= $phenout;
                                    $fprank{phenotype}{$phenotype} = 1;
                                }
                            }

                            @genotypes =
                              write_genotype( $G56, $ph{GA1a}, $group );
                            my @genotype1 = @genotypes;
                            my @genotype2 = @genotypes;

                            print STDERR "G56 $G56, $driver\n";
                            my @extra =
                              parse_genotype_group( $driver, 'driver',
                                $ph{GA1a}, '0' );

                            my @g_terms = split( /\s\|\s/, $geno_inter );
                            my $first   = shift(@g_terms);
                            if ( $first =~ /enhanceable/ ) {
                                push( @genotype1, @extra );
                            }
                            elsif ( $first =~ /suppressible|UI/ ) {

                                push( @genotype2, @extra );
                            }
                            else {
                                print STDERR
"ERROR, $f genetic_interaction type $first not supported\n";
                            }
                            @genotype1 = sort @genotype1;
                            @genotype2 = sort @genotype2;

                            my $genotype1_id = join( ' ', @genotype1 );
                            $genotype1_id =~ s/:::/\//g;
                            $genotype1_id = convers($genotype1_id);
                            if ( !exists( $fprank{genotype}{$genotype1_id} ) ) {
                                my $genotype_f = create_ch_genotype(
                                    doc        => $doc,
                                    uniquename => $genotype1_id,
                                    macro_id   => $genotype1_id
                                );
                                $out .= dom_toString($genotype_f);
                                $genotype_f->dispose();
                                $out .= write_feature_genotype( $genotype1_id,
                                    @genotype1 );
                                $fprank{genotype}{$genotype1_id} = 1;
                            }
                            my $genotype2_id = join( ' ', @genotype2 );
                            $genotype2_id =~ s/:::/\//g;
                            $genotype2_id = convers($genotype2_id);
                            if ( !exists( $fprank{genotype}{$genotype2_id} ) ) {
                                my $genotype_f = create_ch_genotype(
                                    doc        => $doc,
                                    uniquename => $genotype2_id,
                                    macro_id   => $genotype2_id
                                );
                                $out .= dom_toString($genotype_f);
                                $genotype_f->dispose();
                                $out .= write_feature_genotype( $genotype2_id,
                                    @genotype2 );
                                $fprank{genotype}{$genotype2_id} = 1;
                            }

                            #	print "before phenotype_comparison\n";
                            my $phenotype_comparison =
                              create_ch_phenotype_comparison(
                                doc             => $doc,
                                pub_id          => $ph{pub},
                                environment1_id => $environment1_id,
                                phenotype2_id   => 'unspecified',
                                phenotype1_id   => $phenotype1_id,
                                environment2_id => 'unspecified',
                                genotype1_id    => $genotype1_id,
                                genotype2_id    => $genotype2_id,
                                organism_id     => $organism_id
                              );

                            my @newterms = sort(@g_terms);
                            unshift( @newterms, $first );
                            my $pccrank = 0;
                            foreach my $term (@newterms) {
                                $term =~ s/^\s+//;
                                $term =~ s/\s+$//;

                                #print "$term\n";
                                my $cc = get_cv_by_cvterm( $self->{db}, $term );
                                if ( !defined($cc) ) {
                                    print STDERR
                                      "Warning: could not find cv for $term\n";
                                }
                                my $pcc = create_ch_phenotype_comparison_cvterm(
                                    doc       => $doc,
                                    cvterm_id => create_ch_cvterm(
                                        doc  => $doc,
                                        name => $term,
                                        cv   => get_cv_by_cvterm(
                                            $self->{db}, $term
                                        )
                                    ),
                                    rank => $pccrank
                                );
                                $pccrank++;
                                $phenotype_comparison->appendChild($pcc);
                            }
                            $out .= dom_toString($phenotype_comparison);
                            $phenotype_comparison->dispose();
                        }

                    }
                }
            }
        }    # end elsif ( $f =~ /GA28[a-b]$/ || $f =~ /GA29[ab]$/ )

        elsif ( $f eq 'GA7a' || $f eq 'GA28c' || $f eq 'GA22' || $f eq 'GA29c' )
        {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{GA1a} $f  $ph{pub}\n";
                my @result =
                  get_unique_for_phendesc( $self->{db}, $unique, $ph{pub},
                    $fpr_type{$f} );
                my $gg = convers( $ph{GA1a} );
                if ( exists( $ph{GA1e} ) ) {
                    $gg = convers( $ph{GA1e} );
                }
                foreach my $t (@result) {
                    if ( $t->{type} eq $fpr_type{$f} ) {
                        my $geno = create_ch_genotype(
                            doc        => $doc,
                            uniquename => $t->{genotype},
                            macro_id   => $t->{genotype}
                        );
                        $out .= dom_toString($geno);
                        $geno->dispose();
                        my $phendesc = create_ch_phendesc(
                            doc         => $doc,
                            genotype_id => $t->{genotype},
                            environment => $t->{environ},
                            pub_id      => $ph{pub},
                            type_id     => create_ch_cvterm(
                                doc  => $doc,
                                name => $fpr_type{$f},
                                cv   => 'phendesc type'
                            ),
                        );
                        $phendesc->setAttribute( 'op', 'delete' );
                        $out .= dom_toString($phendesc);
                        $phendesc->dispose();
                    }
                    else {
                        print STDERR
"ERROR: !c  phendesc  for $ph{GA1a} $f  $ph{pub}, $fpr_type{$f} NOT found\n";
                    }
                }
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {

                #	print STDERR $fpr_type{$f}, "\n";
                my $phendesc = create_ch_phendesc(
                    doc         => $doc,
                    genotype_id => create_ch_genotype(
                        doc        => $doc,
                        uniquename => convers( $ph{GA1a} ),
                        macro_id   => convers( $ph{GA1a} )
                    ),
                    environment_id => 'unspecified',
                    description    => $ph{$f},
                    type_id        => create_ch_cvterm(
                        doc  => $doc,
                        name => $fpr_type{$f},
                        cv   => 'phendesc type'
                    ),
                    pub_id => $ph{pub}
                );
                $out .= dom_toString($phendesc);
                my $fg = create_ch_feature_genotype(
                    doc           => $doc,
                    feature_id    => $unique,
                    genotype_id   => convers( $ph{GA1a} ),
                    cgroup        => 0,
                    rank          => 0,
                    chromosome_id => 'unspecified',
                    cvterm_id     => 'unspecified'
                );
                $out .= dom_toString($fg);
                $phendesc->dispose();
            }

            #	print STDERR $ph{$f},"\n";
        } # end elsif ( $f eq 'GA7a' || $f eq 'GA28c' || $f eq 'GA22' || $f eq 'GA29c' )

        elsif ( $f eq 'GA90a' ) {
            print STDERR
"DEBUG: single use GA90a Allele $unique Lesion $ph{GA90a} Pub $ph{pub} \n";
            $out .= &parse_multiple_break( $unique, \%ph, $ph{pub} );
        }
        elsif ( $f eq 'GA90' ) {
            print STDERR
"DEBUG: dupl use GA90a Allele $unique Lesion $ph{GA90a} Pub $ph{pub} \n";
            my @array = @{ $ph{GA90} };
            foreach my $ref (@array) {
                $out .= &parse_multiple_break( $unique, $ref, $ph{pub} );
            }
        }
        elsif ( $f eq 'GA8' || $f eq 'GA4' || $f eq 'GA19' ) {
            my $cvprop = $cvtermprop{$f};
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{GA1a} $f  $ph{pub}\n";
                my @result = get_cvterm_for_feature_cvterm_by_cvtermprop(
                    $self->{db}, $unique, $fpr_type{$f},
                    $ph{pub},    $cvprop, 'webcv'
                );
                foreach my $item (@result) {
                    my $feat_cvterm = create_ch_feature_cvterm(
                        doc        => $doc,
                        feature_id => $unique,
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
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;

                    #$item=~s/in vitro construct \|/in vitro construct -/;

                    if ( $f eq 'GA19' && $item =~ /^\d+$/ ) {
                        $item = $GA19field[$item];
                    }
                    my $cv = get_cv_by_cvterm( $self->{db}, $item );
                    if ( !defined($cv) ) {
                        print STDERR "ERROR: $item is a wrong CVterm\n";

                        # exit(0);
                    }
                    validate_cvterm( $self->{db}, $item, $fpr_type{$f} );
                    my $f_cvterm = create_ch_feature_cvterm(
                        doc        => $doc,
                        feature_id => $unique,
                        cvterm_id  => create_ch_cvterm(
                            doc  => $doc,
                            cv   => $fpr_type{$f},
                            name => $item
                        ),
                        pub_id => $ph{pub}
                    );
                    $out .= dom_toString($f_cvterm);
                    $f_cvterm->dispose();
                }
            }
        }    # end elsif ( $f eq 'GA8' || $f eq 'GA4' || $f eq 'GA19' )

        elsif ( $f eq 'GA91' ) {
            print STDERR "CHECK: new implemented $f  $ph{GA1a} \n";

            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "CHECK: new implemented !c $ph{GA1a} $f \n";

                #get library_feature
                my @result =
                  get_library_for_library_feature( $self->{db}, $unique );
                foreach my $item (@result) {
                    ( my $libu, my $libg, my $libs, my $libt ) =
                      get_lib_ukeys_by_name( $self->{db}, $item );
                    my $lib_feat = create_ch_library_feature(
                        doc        => $doc,
                        library_id => create_ch_library(
                            doc        => $doc,
                            uniquename => $libu,
                            genus      => $libg,
                            species    => $libs,
                            type       => $libt,
                        ),
                        feature_id => $unique,
                    );
                    $lib_feat->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($lib_feat);
                    $lib_feat->dispose();
                }
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne "" ) {
                ( my $libu, my $libg, my $libs, my $libt ) =
                  get_lib_ukeys_by_name( $self->{db}, $ph{$f} );
                if ( $libu eq '0' ) {
                    print STDERR "ERROR: could not find record for $ph{GA91}\n";

                    #		  exit(0);
                }
                else {
                    print STDERR "DEBUG: GA91 $ph{$f} uniquename $libu\n";
                    if ( defined( $ph{GA91a} ) && $ph{GA91a} ne "" ) {
                        if ( exists( $ga91a_type{ $ph{GA91a} } ) ) {
                            my $item = $ph{GA91a};
                            print STDERR "DEBUG: GA91a $ph{GA91a} found\n";
                            my $library = create_ch_library(
                                doc        => $doc,
                                uniquename => $libu,
                                genus      => $libg,
                                species    => $libs,
                                type       => $libt,
                                macro_id   => $libu
                            );
                            $out .= dom_toString($library);
                            my $f_l = create_ch_library_feature(
                                doc        => $doc,
                                library_id => $libu,
                                feature_id => $unique
                            );

                            my $lfp = create_ch_library_featureprop(
                                doc  => $doc,
                                type => $item
                            );
                            $f_l->appendChild($lfp);
                            $out .= dom_toString($f_l);
                        }
                        else {
                            print STDERR
                              "ERROR: wrong term for GA91a $ph{GA91a}\n";
                        }
                    }
                    else {
                        print STDERR
                          "ERROR: GA91 has a library no term for GA91a\n";
                    }

                }
            }
        }    # end elsif ( $f eq 'GA91'
        elsif ( ( $f eq 'GA91a' && $ph{GA91a} ne "" ) && !defined( $ph{GA91} ) )
        {
            print STDERR "ERROR: GA91a has a term for GA91a but no library\n";
        }    # end elsif ( $f eq 'GA91a' check if GA91

        elsif ( $f eq 'GA34a' )
        {    # disease model statement - similar to GO statement
                # OK values for qualifier part of
            my @qualifiers = (
                'model of',
                'exacerbates',
                'ameliorates',
                'DOES NOT model',
                'DOES NOT exacerbate',
                'DOES NOT ameliorate'
            );

        # don't need date info for time last reviewed bit so commented out
        #  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime();
        # my $currenttime=sprintf( "%4d%02d%02d", $year+1900,$mon+1,$mday);

            # !c correction section
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log, $ph{GA34a} $f  $ph{pub}\n";
                my @result =
                  get_cvterm_for_feature_cvterm( $self->{db}, $unique,
                    $fpr_type{$f}, $ph{pub} );
                foreach my $item (@result) {
                    my ( $cvterm, $obsolete ) = split( /,,/, $item );

# don't need date info?
# my $date=get_date_by_feature_cvterm($self->{db},$unique,$cvterm,$ti_fpr_type{$f},$ph{pub});
#$fprank{$unique}{$fpr_type{$f}}{$cvterm}{$ph{pub}}=$date;
                    my $feat_cvterm = create_ch_feature_cvterm(
                        doc        => $doc,
                        feature_id => $unique,
                        cvterm_id  => create_ch_cvterm(
                            doc         => $doc,
                            cv          => $fpr_type{$f},
                            name        => $cvterm,
                            is_obsolete => $obsolete
                        ),
                        pub => $ph{pub},
                    );
                    $feat_cvterm->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($feat_cvterm);
                    $feat_cvterm->dispose();
                }
            }

            # have one or more statements that need to be parsed
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item = trim($item);
                    my $prov =
                      'FlyBase';    # this is default provenance - it can change
                    my @do_qualifier = ();    # will hold qualifier terms
                    my $do_id        = '';
                    my ( $do, $prop ) = split( /\s\|\s/, $item )
                      ;    # thing after pipe is a 'with' type property

                    if ( $do =~ /(.*)\s;\s(.*)/ ) {
                        $do    = $1;
                        $do_id = $2;
                    }

                    # dealing with provenance
                    if ( $do =~ /^([\w]+):(.*)/ )
                    {      # a provenance has been specified in the line
                        if ( $1 eq 'FlyBase' ) {
                            $prov = $1;
                            $do   = $2;    # term now has provenance stripped
                        }
                        else {    # unrecognized provenance - report as error
                            print STDERR
                              "ERROR: unrecognized provenance for: $f\n";
                            next;
                        }
                    }

# dealing with qualifiers - checking to see if term starts with a valid qualifier
                    foreach my $q (@qualifiers) {
                        if ( $do =~ /^$q/ ) {
                            push( @do_qualifier, $q );
                            $do =~ s/$q//;    # remove the qualifier bit
                        }
                    }
                    $do    = trim($do);
                    $do_id = trim($do_id);

                  # now we have a cvterm.name and bipartite dbxref (DOID:000000)
                    validate_go( $self->{db}, $do, $do_id, $fpr_type{$f} );

      # dealing with the property i.e. with statement
      # NOTE: want to support linkable alleles - curators just providing symbols

# want to add a bit to check allele symbols and add stuff so they can be linkable
# any allele symbols should be comma space separated and after 'with '
# and surrounded by @@ stamps
                    $prop = trim($prop);

# note we still have evc at beginning of string can we do this all with just sub?
                    if ( $prop =~ /with|by / and $prop =~ /@\S+@/ )
                    {    # we've got some FlyBase features to check
                        my @feats = ( $prop =~ /@(\S+)@/g );
                        foreach my $f (@feats) {

                            # should be a valid symbol but may be new
                            my $uname =
                              get_uniquename_by_name( $self->{db}, trim($f),
                                'FB[a-z]{2}[0-9]{7,12}' );
                            if ( $uname and $uname eq '1' ) {
                                print STDERR
"ERROR: more than one feature with symbol $f found\n";
                                next;
                            }
                            elsif ( !$uname ) {
                                $uname = "NEWFEAT";
                            }
                            my $converted_symb = convers($f);
                            my $str2sub = "FLYBASE:$converted_symb; FB:$uname";
                            my $qf      = quotemeta($f);
                            print STDERR "NOTICE: Convert - @", $f,
                              "@ TO $str2sub\n";
                            $prop =~ s/@($qf)@/$str2sub/;
                        }
                    }

                    # modification of bit to expand evc  to long name
                    my @evcs = grep $prop =~ /$_/, keys %GOabbr;
                    foreach my $k (@evcs) {
                        my $rep = $GOabbr{$k};
                        if ( $prop =~ /$k/ ) {
                            $prop =~ s/\b$k\b/$rep/;
                            print STDERR "NOTICE: EVC expanded - $k to $rep\n";
                        }
                    }

   # ensure that all the feature_cvtermprop have the same rank for a single
   # statement
   # first check to see if this feature_cvterm combo has any existing ranks from
   # this record
                    my $rank = 0;
                    if (
                        exists $fprank{ $unique
                              . $do
                              . $fpr_type{$f}
                              . $ph{pub} } )
                    {
                        #print "WE'VE GOT A RANK\n";
                        $fprank{$unique
                              . $do
                              . $fpr_type{$f}
                              . $ph{pub} }++;    # increment rank in hash
                        $rank =
                          $fprank{ $unique . $do . $fpr_type{$f} . $ph{pub} };

                        #print "\tRANK=$rank\n";
                    }
                    else {
                        my $maxrank =
                          get_max_feature_cvtermprop_rank( $self->{db},
                            $unique, $do, $fpr_type{$f}, $ph{pub} );

                        #print "RANK ALREADY IN DB FOR THIS F_C \n" if $maxrank;
                        if ($maxrank) {
                            if ( $maxrank == -1 ) {
                                print STDERR
"ERROR: more than one feature_cvterm for $unique:$do:$ph{pub}\n";
                                next;
                            }
                            elsif ( $maxrank < 0 ) {
                                $rank = 1;
                                $fprank{$unique
                                      . $do
                                      . $fpr_type{$f}
                                      . $ph{pub} } = $rank;
                            }
                            else {
                                $maxrank++;
                                $rank = $maxrank;
                                $fprank{$unique
                                      . $do
                                      . $fpr_type{$f}
                                      . $ph{pub} } = $maxrank;
                            }
                        }
                        else {
                            $rank = 0E0;
                            $fprank{ $unique . $do . $fpr_type{$f} . $ph{pub} }
                              = $rank;

                            #print "NO EXISTING RANK\nSETTING TO $rank\n";
                        }
                    }

                    # creating the main feature_cvterm
                    my $f_cvterm = create_ch_feature_cvterm(
                        doc        => $doc,
                        feature_id => $unique,
                        cvterm_id  => create_ch_cvterm(
                            doc      => $doc,
                            cv       => $fpr_type{$f},
                            name     => $do,
                            macro_id => $do
                        ),
                        pub_id => $ph{pub},
                    );

                    # adding qualifier props
                    foreach my $qa (@do_qualifier) {
                        my $cvprop = create_ch_feature_cvtermprop(
                            doc     => $doc,
                            type_id => create_ch_cvterm(
                                doc  => $doc,
                                name => 'qualifier',

                                #	  name      => $qa,
                                cv        => 'FlyBase miscellaneous CV',
                                no_lookup => 1
                            ),
                            value => $qa,
                            rank  => $rank,
                        );

                        $f_cvterm->appendChild($cvprop);
                    }

                  #print "AND WHEN CREATING feature_cvtermprops RANK = $rank\n";

                    # adding provenance feature_cvtermprop
                    my $cvprov = create_ch_feature_cvtermprop(
                        doc     => $doc,
                        type_id => create_ch_cvterm(
                            doc       => $doc,
                            name      => 'provenance',
                            cv        => 'FlyBase miscellaneous CV',
                            no_lookup => 1
                        ),
                        value => $prov,
                        rank  => $rank,
                    );
                    $f_cvterm->appendChild($cvprov);

                    # evidence line as feature_cvtermprop
                    if ( $prop ne '' ) {
                        my $fcvprop = create_ch_feature_cvtermprop(
                            doc     => $doc,
                            type_id => create_ch_cvterm(
                                doc  => $doc,
                                name => 'evidence_code',
                                cv   => 'FlyBase miscellaneous CV'
                            ),
                            value => $prop,
                            rank  => $rank
                        );

                        $f_cvterm->appendChild($fcvprop);
                    }

                    $out .= dom_toString($f_cvterm);
                    $f_cvterm->dispose();
                }    # end for each item (statement)
            }    # end one or more statements to be parsed
        }    # end elsif ($f eq 'GA34a')

        #Toools
        elsif ($f eq 'GA30a'
            || $f eq 'GA30b'
            || $f eq 'GA30c'
            || $f eq 'GA30e' )
        {
            my $object  = 'object_id';
            my $subject = 'subject_id';
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{GA1a} $f  $ph{pub}\n";
                my @results = get_unique_key_for_fr_by_feattype(
                    $self->{db},   $subject, $object, $unique,
                    $fpr_type{$f}, $ph{pub}, $feat_type{$f}
                );
                foreach my $ta (@results) {
                    my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );

                    #print STDERR "fr number $num\n";
                    if (
                        $num == 1
                        || ( defined( $frnum{$unique}{ $ta->{name} } )
                            && $num - $frnum{$unique}{ $ta->{name} } == 1 )
                      )
                    {
#print STDERR "Warning: deleting feature_relationship $unique $f ",$ta->{name}," ", $ph{pub},"\n";
                        $out .=
                          delete_feature_relationship( $self->{db}, $doc, $ta,
                            $subject, $object, $unique, $fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_feature_relationship_pub( $self->{db}, $doc,
                            $ta, $subject, $object, $unique, $fpr_type{$f},
                            $ph{pub} );
                    }
                    else {
                        print STDERR
                          "ERROR:something Wrong, please validate first\n";
                    }
                }
            }    #end !c
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {

                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    my ( $fr, $f_p ) = write_feature_relationship(
                        $self->{db},   $doc,     $subject,
                        $object,       $unique,  $item,
                        $fpr_type{$f}, $ph{pub}, $feat_type{$f},
                        $id_type{$f}
                    );
                    $out .= dom_toString($fr);
                    $out .= $f_p;
                }
            }
        } # end elsif $f eq 'GA30a'|| $f eq 'GA30b'|| $f eq 'GA30c'|| $f eq 'GA30e'

        elsif ( $f eq 'GA30f' || $f eq 'GA36' ) {
            my $cv = 'property type';
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{GA1a} $f  $ph{pub}\n";
                my @results =
                  get_unique_key_for_featureprop( $self->{db}, $unique,
                    $fpr_type{$f}, $ph{pub} );
                foreach my $t (@results) {
                    my $num = get_fprop_pub_nums( $self->{db}, $t->{fp_id} );
                    if (
                        $num == 1
                        || (
                            defined(
                                $frnum{$unique}{ $fpr_type{$f} }{ $t->{rank} }
                            )
                            && $num -
                            $frnum{$unique}{ $fpr_type{$f} }{ $t->{rank} } == 1
                        )
                      )
                    {
                        $out .= delete_featureprop( $doc, $t->{rank}, $unique,
                            $fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_featureprop_pub( $doc, $t->{rank}, $unique,
                            $fpr_type{$f}, $ph{pub} );
                    }
                }
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                if (   ( $ph{$f} eq "n" and $f eq 'GA30f' )
                    || ( $ph{$f} eq "y" and $f eq 'GA36' ) )
                {
                    $out .=
                      write_featureprop( $self->{db}, $doc, $unique, $ph{$f},
                        $fpr_type{$f}, $ph{pub} );
                }
                else {
                    if ( $f eq 'GA30f' ) {
                        print STDERR
"ERROR: Value must be n or blank $ph{GA1a} $f  $ph{pub}\n";
                    }
                    else {
                        print STDERR
"ERROR: Value must be y or blank $ph{GA1a} $f  $ph{pub}\n";
                    }
                }
            }
        }    # end elsif ($f eq 'GA30f' or 'GA36'
        elsif ($f eq 'GA30d'
            || $f eq 'GA35' )
        {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log, $ph{$f} $f  $ph{pub}\n";
                my @results = get_cvterm_for_feature_cvterm_withprop(
                    $self->{db}, $unique, $fpr_type{$f},
                    $ph{pub},    $fcp_type{$f}
                );
                if ( @results == 0 ) {
                    print STDERR
"ERROR: not previous record found for $ph{GA1a} $f $ph{pub} $ph{file}\n";
                }
                foreach my $item (@results) {
                    my $feat_cvterm = create_ch_feature_cvterm(
                        doc        => $doc,
                        feature_id => $unique,
                        cvterm_id  => create_ch_cvterm(
                            doc  => $doc,
                            cv   => $fpr_type{$f},
                            name => $item
                        ),
                        pub => $ph{pub}
                    );
                    $feat_cvterm->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($feat_cvterm);
                    $feat_cvterm->dispose();
                }
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                print STDERR
                  "DEBUG feature_cvterm $ph{GA1a} $f $ph{pub} $ph{file}\n";
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    print STDERR
"DEBUG validate cvterm $fpr_type{$f}, $item  $ph{GA1a} $f $ph{pub} $ph{file}\n";
                    validate_cvterm( $self->{db}, $item, $fpr_type{$f} );
                    my $f_cvterm = create_ch_feature_cvterm(
                        doc        => $doc,
                        feature_id => $unique,
                        cvterm_id  => create_ch_cvterm(
                            doc  => $doc,
                            cv   => $fpr_type{$f},
                            name => $item
                        ),
                        pub_id => $ph{pub}
                    );

                    my $fcvprop = create_ch_feature_cvtermprop(
                        doc     => $doc,
                        type_id => create_ch_cvterm(
                            doc  => $doc,
                            name => $fcp_type{$f},
                            cv   => 'feature_cvtermprop type'
                        ),
                        rank => '0'
                    );
                    $f_cvterm->appendChild($fcvprop);
                    $out .= dom_toString($f_cvterm);
                    $f_cvterm->dispose();
                }
            }

        }    # end if GA30d || GA35
        elsif ($f eq 'GA83a'){
            $out .= &parse_dataset( $unique, \%ph);
        }
        elsif ($f eq 'GA83'){ # chopped version of GA83 holding array of values
            my @array = @{ $ph{$f} };
            foreach my $ref (@array) {
	            $out .= &parse_dataset( $unique, $ref);
            }
        }
        elsif ($f eq 'GA80d'){
	        if($ph{$f} ne ''){
                my $delete = 0;
                if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                    $delete = 1;
                }
                my @items = split( /\n/, $ph{$f});
                foreach my $item (@items) {
                    my ($dbn, $dbxref) = split( /:/, $item,2);
	                if(!defined($dbn) || !defined($dbxref)){
		                print STDERR "ERROR: wrong format for DB:accession $item\n";    
	                }
		            my $junk1 = $dbxref;
		            my $junk = chop ($junk1);
		            if($junk eq '.'){
		                print STDERR "ERROR: An accession maynot end in $junk Fix $f $item\n"; 
		            }
		            my $val = validate_dbname($self->{db}, $dbn);
		            if($val eq $dbn){
		                $out.= write_allele_dbxref($self->{db}, $doc, $unique, $dbn, $dbxref, $delete);
		            }
		            else{
		                print STDERR "ERROR: No dbname found for DB: $dbn\n";
                    }    
                }   
	        }
	    }
    }    # end foreach my $f ( keys %ph )

    $doc->dispose();
    return $out;

}

sub write_feature_genotype {
    my ( $genotype, @genotypes ) = @_;
    my $cgroup = 0;
    my $fgout  = '';
    foreach my $geno (@genotypes) {
        my @features = split( /:::/, $geno );
        my $fgrank   = 0;
        foreach my $feat (@features) {
            $feat =~ s/^\s+//;
            $feat =~ s/\s+$//;
            my $f_unique = '';
            if ( !exists( $fbids{$feat} ) ) {

                if ( $feat =~ /^[+-]$/ ) {
                    my $fff = create_ch_feature(
                        doc        => $doc,
                        uniquename => $feat,
                        genus      => 'Unknown',
                        species    => 'unknown',
                        type_id    => create_ch_cvterm(
                            doc  => $doc,
                            name => 'bogus symbol',
                            cv   => 'FlyBase miscellaneous CV'
                        ),
                        name      => $feat,
                        macro_id  => $feat,
                        no_lookup => '1'
                    );
                    $fgout .= dom_toString($fff);
                    $fff->dispose();
                    $f_unique = $feat;
                    $fbids{$feat} = $feat;
                }
                elsif ( $feat =~ /\[[+-]\]$/ ) {
                    my ( $u_id, $f_genus, $f_species, $f_type ) =
                      get_feat_ukeys_by_name( $db, $feat );
                    if ( $u_id eq '0' || $u_id eq '2' ) {
                        my $fg = 'Drosophila';
                        my $fs = 'melanogaster';
                        if ( $feat =~ /^(.*?)\\.*/ ) {
                            ( $fg, $fs ) = get_organism_by_abbrev( $db, $1 );
                        }
                        my $fff = create_ch_feature(
                            doc        => $doc,
                            uniquename => $feat,
                            genus      => $fg,
                            species    => $fs,
                            type_id    => create_ch_cvterm(
                                doc  => $doc,
                                name => 'bogus symbol',
                                cv   => 'FlyBase miscellaneous CV'
                            ),
                            name      => $feat,
                            macro_id  => $feat,
                            no_lookup => 1
                        );
                        $fgout .= dom_toString($fff);
                        $fff->dispose();
                        $fbids{$feat} = $feat;
                        $f_unique = $feat;
                    }
                    else {
                        my $fff = create_ch_feature(
                            doc        => $doc,
                            uniquename => $u_id,
                            genus      => $f_genus,
                            species    => $f_species,
                            type       => $f_type,
                            macro_id   => $u_id
                        );
                        $fgout .= dom_toString($fff);
                        $fff->dispose();
                        $fbids{$feat} = $u_id;
                        $f_unique = $u_id;
                    }

                }

                else {
                    my ( $u_id, $f_genus, $f_species, $f_type ) =
                      get_feat_ukeys_by_name( $db, $feat );
                    if ( $u_id eq '0' ) {
                        print STDERR "ERROR:not found in DB GA56/GA17 $feat \n";
                    }
                    my $cv = 'SO';
                    #if ( $f_type eq 'single balancer' ) {
                    #    $cv = 'FlyBase miscellaneous CV';
                    #}
                    my $fea_dom = create_ch_feature(
                        doc        => $doc,
                        uniquename => $u_id,
                        genus      => $f_genus,
                        species    => $f_species,
                        type_id    => create_ch_cvterm(
                            doc  => $doc,
                            name => $f_type,
                            cv   => $cv,
                        ),
                        macro_id => $u_id
                    );
                    $f_unique = $u_id;
                    $fbids{$feat} = $u_id;
                    $fgout .= dom_toString($fea_dom);
                    $fea_dom->dispose();
                }
            }
            else {
                $f_unique = $fbids{$feat};
            }
            my $f_geno = create_ch_feature_genotype(
                doc           => $doc,
                feature_id    => $f_unique,
                genotype_id   => $genotype,
                rank          => $fgrank,
                cgroup        => $cgroup,
                chromosome_id => 'unspecified',
                cvterm_id     => 'unspecified'
            );
            $fgout .= dom_toString($f_geno);
            $f_geno->dispose();
            $fgrank++;
        }
        $cgroup++;
    }
    return $fgout;
}

sub parse_dataset {
    my $unique  = shift;
    my $ref_ph = shift;
    my %sub_ph = %$ref_ph;
    my $dbxref   = '';
    my $out     = '';

    $dbxref = trim($sub_ph{'GA83a'});
    my $dbn = trim($sub_ph{'GA83b'});
    my $dbxref_desc = trim($sub_ph{'GA83c'});

	my $junk1 = $dbxref;
	my $junk = chop ($junk1);
	if($junk eq '.'){
		print STDERR "ERROR: An accession maynot end in $junk Fix GA83a $sub_ph{'GA83a'}\n"; 
	}
    my $delete = 0;
    if ( exists( $sub_ph{"GA83d"} ) && $sub_ph{"GA83d"} eq 'y' ) {
        $delete = 1;
    }
    
	my $val = validate_dbname($db, $dbn);
	if($val eq $dbn){
#		 print STDERR "DEBUG:  validated dbname $val = $dbn DB accession = $dbxref\n";    
		$out = write_allele_dbxref($db, $doc, $unique, $dbn, $dbxref, $dbxref_desc, $delete);
	}
	else{
		print STDERR "ERROR: No dbname found for DB: $dbn\n";
	}
    return $out;
}

sub parse_multiple_break {
    my $fbti    = shift;
    my $hashref = shift;       ##reference to hash
    my $pub_id  = shift;
    my %gen_loc = %$hashref;
    my $srcfeat = '';
    my $featureloc;
    my $out       = '';
    my $genus     = 'Drosophila';
    my $species   = 'melanogaster';
    my $ftype     = '';
    my $br_unique = '';
    my $strand    = 0;
    my $cv        = 'GenBank feature qualifier';

    if ( !defined( $gen_loc{GA90k} ) || ( $gen_loc{GA90k} eq '' ) ) {
        print STDERR "ERROR: GA90k must be filled in for $gen_loc{GA90a}\n";
        return $out;
    }
    if ( exists( $gen_loc{'GA90k.upd'} ) && $gen_loc{'GA90k.upd'} eq 'c' ) {
        print STDERR "ERROR: GA90k Cannot be used with !c\n";
        return $out;
    }
    $br_unique = $gen_loc{GA90a};
    print STDERR "CHECK: Allele $fbti has GA90a = $br_unique $pub_id \n";
    if ( exists( $gen_loc{'GA90b.upd'} ) && $gen_loc{'GA90b.upd'} eq 'c' ) {
        print STDERR
"CHECK: Action item !c implementation, Field GA90b Allele $fbti Lesion $br_unique Pub $pub_id\n";
        $out .= delete_featureloc( $db, $doc, $br_unique, $pub_id );
        $out .=
          remove_featureprop_function( $db, $doc, $br_unique, $fpr_type{GA90c},
            $pub_id );
    }
    foreach my $f ( 'GA90d', 'GA90e', 'GA90f', 'GA90g', 'GA90h', 'GA90j' ) {
        if ( exists( $gen_loc{ $f . ".upd" } )
            && $gen_loc{ $f . ".upd" } eq 'c' )
        {
            print STDERR
"CHECK: Action item !c  Field $f Allele $fbti Lesion $br_unique Pub $pub_id\n";
            my @results = get_unique_key_for_featureprop( $db, $br_unique,
                $fpr_type{$f}, $pub_id, $cv );
            if ( @results == 0 ) {
                print STDERR
"ERROR: could not find previous records in the database $br_unique, $pub_id $f \n";
            }
            foreach my $t (@results) {
                my $num = get_fprop_pub_nums( $db, $t->{fp_id} );
                if ( $num == 1 ) {
                    $out .= delete_featureprop( $doc, $t->{rank}, $br_unique,
                        $fpr_type{$f}, $cv );
                }
                elsif ( $num > 1 ) {
                    $out .= delete_featureprop_pub( $doc, $t, $br_unique,
                        $fpr_type{$f}, $pub_id );
                }
                else {
                    print STDERR "something Wrong, please validate first\n";
                }
            }
        }
    }

    if ( defined( $gen_loc{GA90a} ) && $gen_loc{GA90a} ne '' ) {
        my $fcv        = 'SO';
        my $br_feature = "";
        my $ta         = $gen_loc{GA90k};
        my ( $g, $s ) = get_feat_ukeys_by_uname_type( $db, $br_unique, $ta );

        #print STDERR "ERROR: $g $br_unique\n";
        if ( ( $g ne '0' && $g ne '2' ) ) {
            print STDERR "DEBUG: lesion $br_unique already in DB\n";
            $br_feature = create_ch_feature(
                doc        => $doc,
                uniquename => $br_unique,
                type_id =>
                  create_ch_cvterm( doc => $doc, cv => $fcv, name => $ta ),
                genus    => $g,
                species  => $s,
                macro_id => $br_unique,
            );
            $out .= dom_toString($br_feature);
            $br_feature->dispose();
        }
        else {
            print STDERR "DEBUG: adding lesion $br_unique to DB\n";
            $g  = 'Drosophila';
            $s  = 'melanogaster';
            $ta = $gen_loc{GA90k};


            $br_feature = create_ch_feature(
                doc        => $doc,
                uniquename => $br_unique,
                name       => $br_unique,
                type_id =>
                  create_ch_cvterm( doc => $doc, cv => $fcv, name => $ta ),
                genus     => $g,
                species   => $s,
                macro_id  => $br_unique,
                no_lookup => 1
            );
            $out .= dom_toString($br_feature);
            $br_feature->dispose();
        }


        my $f_p = create_ch_feature_pub(
            doc        => $doc,
            feature_id => $br_unique,
            pub_id     => $pub_id
            );
        $out .= dom_toString($f_p);
        $f_p->dispose();
        
        my $brfr = create_ch_fr(
            doc          => $doc,
            'subject_id' => $br_unique,
            'object_id'  => $fbti,
            rtype        => $fpr_type{GA90a}
        );
        my $brpub = create_ch_fr_pub(
            doc    => $doc,
            pub_id => $pub_id
        );
        $brfr->appendChild($brpub);
        $out .= dom_toString($brfr);
        $brfr->dispose();

        if ( defined( $gen_loc{GA90b} ) && $gen_loc{GA90b} ne '' ) {
            my $fmin;
            my $fmax;
            my ( $arm, $location ) = split( /:/, $gen_loc{GA90b} );
            if ( defined($location) ) {
                ( $fmin, $fmax ) = split( /\.\./, $location );
                if ( !defined($fmax) && defined($fmin) ) {
                    $fmax = $fmin;
                }
            }
            else {
                print STDERR
"ERROR: Something wrong with GA90b  $gen_loc{GA90b} please fix \n";
            }

            if ( $fmin > $fmax ) {
                print STDERR "ERROR: fmin >fmax $fmin $fmax\n";
                my $tmp = $fmin;
                $fmin = $fmax;
                $fmax = $tmp;
            }
            if ( $arm eq '1' ) {
                $arm = 'X';
            }
            $srcfeat = $arm;
            if ( $gen_loc{GA90c} ) {
                if ( $gen_loc{GA90c} eq '4' ) {
                    $srcfeat = $arm . '_r4';
                    print STDERR
"ERROR WARN: GA90c Release 4 will not display in Location\n";
                }
                elsif ( $gen_loc{GA90c} eq '3' ) {
                    $srcfeat = $arm . '_r3';
                    print STDERR
"ERROR WARN: GA90c Release 3 will not display in Location\n";
                }
                elsif ( $gen_loc{GA90c} eq '5' ) {
                    $srcfeat = $arm . '_r5';
                    print STDERR
"ERROR WARN: GA90c Release 5 will not display in Location\n";
                }
            }
            else{
                print STDERR "ERROR: No (GA90c) Release number. This is now required."               
            }
            if ( !( $srcfeat =~ /.*_r?/ ) ) {
                $srcfeat .= '_r6';
            }

            if ( exists( $gen_loc{GA90i} ) ) {
                if ( $pm{ $gen_loc{GA90i} } eq '+' ) {
                    $strand = 1;
                }
                elsif ( $pm{ $gen_loc{GA90i} } eq '-' ) {
                    $strand = -1;
                }
            }

            my $value = $srcfeat . ":" . $fmin . '..' . $fmax;
            my $rank  = get_max_featureprop_rank( $db, $br_unique,
                'reported_genomic_loc', $value ,'GenBank feature qualifier');
            my $fp = create_ch_featureprop(
                doc        => $doc,
                feature_id => $br_unique,
                rank       => $rank,
                cvname     => 'GenBank feature qualifier',
                type       => 'reported_genomic_loc',
                value      => $value
            );
            my $fpp =
              create_ch_featureprop_pub( doc => $doc, pub_id => $pub_id );
            $fp->appendChild($fpp);
            $out .= dom_toString($fp);

            my $type = 'golden_path';
            if ( $srcfeat eq 'mitochondrion_genome' ) {
                $type = 'chromosome';
            }
            if ( exists( $gen_loc{GA90c} ) && $gen_loc{GA90c} eq '6' ) {

                my $src = &create_ch_feature(
                    doc        => $doc,
                    genus      => $genus,
                    species    => $species,
                    uniquename => $arm,
                    type       => $type,
                );

                if ( defined($fmin) && defined($fmax) ) {

                    #	    if($fmin ne $fmax){
                    #PDEV-58
                    $fmin -= 1;    # interbase in chado

                    #	    }

                    my $locgroup =
                      &get_max_locgroup( $db, $br_unique, $arm, $fmin, $fmax );
                    $featureloc = create_ch_featureloc(
                        doc           => $doc,
                        feature_id    => $br_unique,
                        srcfeature_id => $src,
                        fmin          => $fmin,
                        fmax          => $fmax,
                        locgroup      => $locgroup,
                        strand        => $strand

                    );
                }
                else {
                    my $locgroup =
                      &get_max_locgroup( $db, $br_unique, $arm, $fmin, $fmax );
                    $featureloc = create_ch_featureloc(
                        doc           => $doc,
                        feature_id    => $br_unique,
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
        foreach my $f ( 'GA90d', 'GA90e', 'GA90f', 'GA90g', 'GA90h', 'GA90j' ) {
            if ( defined( $gen_loc{$f} ) && $gen_loc{$f} ne '' ) {
                if ( $f eq 'GA90f' ) {
                    my @items = split( /\n/, $gen_loc{$f} );
                    print STDERR
                      "multiple value GA90f $gen_loc{$f} for $br_unique\n";
                    foreach my $item (@items) {
                        print STDERR "$item \n";
                        $item =~ s/^\s+//;
                        $item =~ s/\s+$//;
                        $out .=
                          write_featureprop_cv( $db, $doc, $br_unique, $item,
                            $fpr_type{$f}, $pub_id, $cv );
                    }
                }
                else {
                    $out .=
                      write_featureprop_cv( $db, $doc, $br_unique, $gen_loc{$f},
                        $fpr_type{$f}, $pub_id, $cv );
                }
            }
        }
    }

    return $out;
}

sub write_genotype {
    my $term      = shift;
    my $ga1a      = shift;
    my $group     = shift;
    my $with      = '';
    my $driver    = '';
    my @genotypes = ();

    if ( $term =~ /^\(with\s(.*)\)\s(.*)/ || $term =~ /^\(with(.*?)\)$/ ) {
        $with = $1;
        if ( defined($2) ) {
            $term = $2;
        }
        else { $term = ''; }
    }
    if ( $term =~ /(.*?)\{\s(.*)\s\}/ ) {
        $driver = $2;
        $term   = $1;
    }

    if ( $with eq '' && $driver eq '' ) {
        push( @genotypes, $ga1a );
    }
    else {
        if ( $with ne '' ) {
            my @groups = parse_genotype_group( $with, 'with', $ga1a, $group );
            push( @genotypes, @groups );
        }
        if ( $driver ne '' ) {
            my @groups =
              parse_genotype_group( $driver, 'driver', $ga1a, $group );
            push( @genotypes, @groups );
        }
    }
    my $a  = join( ' ', @genotypes );
    my $na = $ga1a;
    $na =~ s/([\'\#\"\[\]\|\\\/\(\)\+\-\.])/\\$1/g;

    # print STDERR "check name$a, $na\n";
    if ( !( $a =~ /$na/ ) ) {
        push( @genotypes, $ga1a );
    }
    @genotypes = sort @genotypes;

    return @genotypes;
}

sub write_phenotype {
    my $field        = shift;
    my $aref         = shift;
    my @cvterms      = ();
    my $environment  = 'unspecified';
    my $phenotype    = '';
    my @environs     = ();
    my @newpheno     = ();
    my $first        = '';
    my $out          = '';
    my $pheno_unique = '';
    print STDERR $field, $aref, "\n";

    if ( ( $field eq 'GA17' || $field eq 'GA28b' || $field eq 'GA29b' )
        && $aref =~ /\&/ )
    {
        push( @newpheno, $aref );
        $first = $aref;
    }
    else {
        my @phenoclass = split( /\s\|\s/, $aref );
        $first = shift(@phenoclass);

        #	print STDERR "$field, $first after shift @phenoclass\n";

        foreach my $pheno (@phenoclass) {
            if ( exists( $environments{$pheno} ) ) {
                push( @environs, $pheno );
            }
            else {
                push( @cvterms, $pheno );
            }
        }

        @newpheno = sort(@cvterms);
        unshift( @newpheno, $first );
    }
    $pheno_unique = join( ' | ', @newpheno );

    #    print STDERR "$field, $pheno_unique after join\n";

    #	print "Pheno unique $pheno_unique\n";
    if ( @environs > 0 ) {
        my $environ = create_ch_environment(
            doc        => $doc,
            uniquename => join( ' | ', @environs ),
            macro_id   => join( ' | ', @environs )
        );
        $out .= dom_toString($environ);
        $environ->dispose();
        $environment = join( ' | ', @environs );
    }

    if ( $field eq 'GA56' || $field eq 'GA28a' || $field eq 'GA29a' ) {
        my $ph_cv = get_cv_by_cvterm( $db, $first );
        if ( !defined($ph_cv) ) {
            print STDERR "ERROR: cvterm $first not found in DB\n";
        }
        validate_cvterm( $db, $first, $ph_cv );
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
    elsif ( $field eq 'GA17' || $field eq 'GA28b' || $field eq 'GA29b' ) {
        my $observ_cv = get_cv_by_cvterm( $db, $first );
        my $cvflag    = 0;
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
            validate_cvterm( $db, $first, $observ_cv );
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
                validate_cvterm( $db, $phe, $ph_cv );
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
    return ( $out, $pheno_unique, $environment );
}

sub parse_genotype_group {
    my $word  = shift;
    my $type  = shift;
    my $ga1a  = shift;
    my $g     = shift;
    my @group = ();

    my @items = split( /,\s/, $word );
    foreach my $item (@items) {
        $item =~ s/^\s+//;
        $item =~ s/\s$//;

        # print "parse genotype $item\n";
        my @individual = split( /\//, $item );
        if ( @individual == 1 ) {
            if ( $type eq 'with' ) {
                if ( $g == 0 ) {
                    my $tg = check_al_with_fr_or_mutagen( $db, $item );
                    if ( $tg == 0 ) {
                        my @gs = sort( $item, $ga1a );
                        push( @group, join( ':::', @gs ) );
                    }
                    else {
                        push( @group, $item );
                    }
                }
                else {
                    push( @group, $item );
                }
            }
            else {
                push( @group, $item );
            }
        }
        else {
            my $tag = 0;
            foreach my $i (@individual) {

                #print "individual $i\n";
                if ( $i =~ /^[+-]$/ || $i =~ /\[[+-]\]/ ) {
                    $tag = 1;
                }
            }
            if ( $tag == 0 ) {
                push( @group, join( ':::', sort @individual ) );
            }
            else {
                for ( my $id = 0 ; $id <= $#individual ; $id++ ) {
                    if ( $individual[$id] =~ /^[+-]$/ ) {
                        my $fe = $individual[ $id - 1 ];
                        my $u  = '';
                        if ( exists( $fbids{$fe} ) ) {
                            $u = $fbids{$fe};
                        }
                        else {
                            ( $u, my $g, my $s, my $t ) =
                              get_feat_ukeys_by_name( $db, $fe );

                            #print "check allele $fe $u \n";
                        }
                        if ( $u eq '0' ) {
                            print "ERROR: could not find record for $fe\n";
                        }
                        elsif ( $u =~ 'FBal' ) {
                            my ( $gn, $n, $r ) = get_alleleof_gene( $db, $u );
                            if ( $gn eq '0' ) {
                                print STDERR
                                  "Warning, could not get gene for allele $u\n";
                                if ( $fe =~ /(.*)\[.*\]$/ ) {
                                    $n = $1;
                                }
                                else {

                                    print STDERR
"ERROR: could not get gene for allele $fe\n";
                                }

                            }
                            $individual[$id] =
                              $n . '[' . $individual[$id] . ']';
                        }

                    }
                }
                push( @group, join( ':::', @individual ) );
            }
        }
    }

    return @group;
}

=head2 $pro->write_feature(%ph)
  separate the id generation and lookup from the other curation field to make two-stage parsing possible
=cut

sub write_feature {
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

    if ( exists( $ph{GA1f} ) ) {
        if ( $ph{GA1g} eq 'n' ) {
            print STDERR
              "Allele Merge  GA1g = n check: does GA1a $ph{GA1a} exist\n";
            my $va = validate_new_name( $db, $ph{GA1a} );
            if ( $va == 1 ) {
                print STDERR
                  "ERROR: Allele Merge  GA1g = n and GA1a $ph{GA1a} exists\n";
                exit(0);
            }
        }
        ( $unique, $flag ) = get_tempid( 'al', $ph{GA1a} );
        $fbids{ convers( $ph{GA1a} ) } = $unique;
        $fbids{ $ph{GA1a} } = $unique;
        print STDERR "get temp id for $ph{GA1a} $unique\n";
        if ( $ph{GA1a} =~ /^(.{2,14}?)\\(.*)/ ) {
            my $org = $1;
            ( $genus, $species ) = get_organism_by_abbrev( $self->{db}, $org );
        }
        if ( $ph{GA1a} =~ /^T:(.{2,14}?)\\(.*)/ ) {
            my $org = $1;
            ( $genus, $species ) = get_organism_by_abbrev( $self->{db}, $org );
        }

        if ( $genus eq '0' ) {
            $genus   = 'Drosophila';
            $species = 'melanogaster';
        }
        if ( $flag == 1 ) {
            print STDERR "ERROR: could not assign temp id for $ph{GA1a}\n";
            exit(0);
        }
        else {
            my $tmp = $ph{GA1f};
            $tmp =~ s/\n/ /g;
            print STDERR "Action Items: Allele merge $tmp\n";
            $feature = create_ch_feature(
                uniquename => $unique,
                name       => decon( convers( $ph{GA1a} ) ),
                genus      => $genus,
                species    => $species,
                type       => 'allele',
                doc        => $doc,
                macro_id   => $unique,
                no_lookup  => '1'
            );
            $out .= dom_toString($feature);
            $out .=
              write_feature_synonyms( $doc, $unique, $ph{GA1a}, 'a',
                'unattributed', 'symbol' );
        }
    }
    else {
        if ( $ph{GA1g} eq 'y' ) {
            ( $unique, $genus, $species, $type ) =
              get_feat_ukeys_by_name( $self->{db}, $ph{GA1a} );
            if ( $unique eq '2' ) {
                ( $unique, $genus, $species, $type ) =
                  get_feat_ukeys_by_name_type( $self->{db}, $ph{GA1a}, 'allele' );

            }
            if ( $unique eq '0' ) {
                print STDERR "ERROR, could not get uniquename for $ph{GA1a}\n";

                # exit(0);
            }
            if ( exists( $ph{GA1h} ) ) {
                if ( $ph{GA1h} ne $unique ) {
                    print STDERR "ERROR: GA1h and GA1a not match\n";
                }
            }

            #		print STDERR "uniquename=$unique\n";
            $feature = create_ch_feature(
                doc        => $doc,
                uniquename => $unique,
                species    => $species,
                genus      => $genus,
                type       => $type,
                macro_id   => $unique,
                no_lookup  => 1
            );
            if ( exists( $ph{GA32a} ) && $ph{GA32a} eq 'y' ) {
                print STDERR
                  "Action Items: delete allele $unique == $ph{GA1a}\n";
                my $op = create_doc_element( $doc, 'is_obsolete', 't' );
                $feature->appendChild($op);

            }
            if ( exists( $fbids{ $ph{GA1a} } ) ) {
                my $check = $fbids{ $ph{GA1a} };
                if ( $unique ne $check ) {
                    print STDERR
                      "ERROR: $check and $unique are not same for $ph{GA1a}\n";

                }
            }
            $fbids{ $ph{GA1a} } = $unique;
            $out .= dom_toString($feature);
            if ( exists( $ph{GA32a} ) && $ph{GA32a} eq 'y' ) {
                $out .= delete_genotype( $self->{db}, $doc, $unique );
            }
        }
        else {    #GA1g = n and not a merge
            my $va = 0;

            #         my $va= validate_new_name($db, $ph{GA1a});
            if ( exists( $ph{GA1e} ) ) {
                $va = validate_new_name( $db, $ph{GA1a} );
                if ( $va == 1 ) {
                    print STDERR
                      "ERROR: rename GA1g = n but GA1a $ph{GA1a} exists\n";
                    exit(0);
                }
                if ( exists( $fbids{ $ph{GA1e} } ) ) {
                    print STDERR
"ERROR: Rename GA1e $ph{GA1e} exists in a previous proforma\n";
                }
                if ( exists( $fbids{ $ph{GA1a} } ) ) {
                    print STDERR
"ERROR: Rename GA1a $ph{GA1a} exists in a previous proforma\n";
                }
                print STDERR
                  "Action Items: allele rename $ph{GA1e} to $ph{GA1a}\n";
                ( $unique, $genus, $species, $type ) =
                  get_feat_ukeys_by_name_type( $self->{db}, $ph{GA1e}, 'allele' );
                if ( $unique eq '0' or $unique eq '2' ) {
                    print STDERR
"ERROR: could not find allele $ph{GA1e} in the database\n";
                }
                else {
                    $feature = create_ch_feature(
                        uniquename => $unique,
                        name       => decon( convers( $ph{GA1a} ) ),
                        genus      => $genus,
                        species    => $species,
                        type       => 'allele',
                        doc        => $doc,
                        macro_id   => $unique,
                        no_lookup  => '1'
                    );
                    $out .= dom_toString($feature);
                    $out .=
                      write_feature_synonyms( $doc, $unique, $ph{GA1a}, 'a',
                        'unattributed', 'symbol' );
                    $fbids{ $ph{GA1a} }            = $unique;
                    $fbids{ convers( $ph{GA1a} ) } = $unique;
                    $fbids{ $ph{GA1e} }            = $unique;
                    $fbids{ convers( $ph{GA1e} ) } = $unique;
                }
            }
            else {    #GA1g = n and not a rename
                $va = validate_new_name( $db, $ph{GA1a} );
                ### if the temp id has been used before, $flag will be 1 to avoid
                ### the DB Trigger reassign a new id to the same symbol.

                if ( $va == 1 ) {
                    $flag = 0;
                    ( $unique, $genus, $species, $type ) =
                      get_feat_ukeys_by_name_type( $db, $ph{GA1a}, 'allele' );
                    $fbids{ $ph{GA1a} } = $unique;
                }
                else {
                    print STDERR "Action Items: new allele $ph{GA1a}\n";
                    ( $unique, $flag ) = get_tempid( 'al', $ph{GA1a} );
                    print STDERR "get temp id for $ph{GA1a} $unique\n";
                    if ( $ph{GA1a} =~ /^(.{2,14}?)\\(.*)/ ) {
                        my $abb = $1;
                        my $rem = $2;
                        print STDERR
"abbreviation = $abb remainder = $rem for  $ph{GA1a}\n";

                        ( $genus, $species ) =
                          get_organism_by_abbrev( $self->{db}, $1 );
                    }
                    if ( $ph{GA1a} =~ /^T:(.{2,14}?)\\(.*)/ ) {
                        my $abb = $1;
                        print STDERR
"abbreviation = $abb has begin T: $abb for  $ph{GA1a}\n";

                        ( $genus, $species ) =
                          get_organism_by_abbrev( $self->{db}, $1 );
                    }
                    if ( $genus eq '0' ) {
                        $genus   = 'Drosophila';
                        $species = 'melanogaster';
                    }
                }
                if ( $flag == 0 ) {
                    $feature = create_ch_feature(
                        uniquename => $unique,
                        name       => decon( convers( $ph{GA1a} ) ),
                        genus      => $genus,
                        species    => $species,
                        type       => 'allele',
                        doc        => $doc,
                        macro_id   => $unique,
                        no_lookup  => '1'
                    );
                    $out .= dom_toString($feature);
                    $out .=
                      write_feature_synonyms( $doc, $unique, $ph{GA1a}, 'a',
                        'unattributed', 'symbol' );
                }
                else {
                    print STDERR "ERROR, name $ph{GA1a} has been used before\n";
                }
            }
        }
    }
    foreach my $f ( 'GA10a', 'GA10e', 'GA10c' ) {
        if ( defined( $ph{$f} ) && $ph{$f} =~ /NEW:/ ) {
            my $t        = 'transposable_element_insertion_site';
            my $tgenus   = 'Drosophila';
            my $tspecies = 'melanogaster';
            my $ft       = 'ti';
            if ( $f eq 'GA10a' ) {
                $t        = 'transgenic_transposable_element';
                $tgenus   = 'synthetic';
                $tspecies = 'construct';
                $ft       = 'tp';
            }
            my @items = split( /\n/, $ph{$f} );
            foreach my $item (@items) {
                if ( $item =~ /NEW:/ ) {
                    $item =~ s/NEW://;
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    my ($tu) =
                      get_feat_ukeys_by_name( $self->{db}, $item );
                    my $tf = 0;
                    if ( $tu eq '0' ) {
                        ( $tu, $tf ) = get_tempid( $ft, $item );
                    }
                    else {
                        print STDERR
                          "Warning: $item already exists in the DB\n";
                    }
                    if ( $tf == 0 ) {
                        if ( $f eq 'GA10a' && $item =~ /TI\{/ ) {
                            $t = 'engineered_region';
                        }
                        if (   $f eq 'GA10e' && $item =~ /TI\{/
                            || $f eq 'GA10c' && $item =~ /TI\{/ )
                        {
                            $t = 'insertion_site';
                        }

                        $feature = create_ch_feature(
                            uniquename => $tu,
                            name       => decon( convers($item) ),
                            genus      => $tgenus,
                            species    => $tspecies,
                            type       => $t,
                            doc        => $doc,
                            macro_id   => $tu,
                            no_lookup  => '1'
                        );
                        $fbids{$item} = $tu;
                        $out .= dom_toString($feature);
                        $out .= write_feature_synonyms( $doc, $tu, $item, 'a',
                            'FBrf0105495', 'symbol' );

                    }
                }
            }
        }
    }
    $doc->dispose();
    return ( $out, $unique );
}

=head2 validate
	validate
	1. if a proforma renames an allele to an allele of a different gene, then
you need to:

a. before we actually load the the proformae, generate a list of such
cases for curators to check that its OK before we do a load for a
release (we think this is a good idea in case we made a mistake, as this
should be a rare event).
	2.
=cut

sub validate {
    my $self     = shift;
    my $tihash   = {@_};
    my %tival    = %$tihash;
    my $v_unique = '';
    print STDERR "Validating Allele ", $tival{GA1a}, " ....\n";

    if ( exists( $fbids{ $tival{GA1a} } ) ) {
        $v_unique = $fbids{ $tival{GA1a} };
    }
    else {
        print STDERR "ERROR: did not have the first parse\n";
    }

    foreach my $f ( keys %tival ) {
        if ( $f =~ /(.*)\.upd/ && !( $v_unique =~ /temp/ ) ) {
            $f = $1;
            if (   $f eq 'GA31'
                || $f eq 'GA15'
                || $f eq 'GA23a'
                || $f eq 'GA23b'
                || $f eq 'GA12a'
                || $f eq 'GA12b'
                || $f eq 'GA13'
                || $f eq 'GA20'
                || $f eq 'GA14' )
            {
                my $num =
                  get_unique_key_for_featureprop( $db, $v_unique,
                    $fpr_type{$f}, $tival{pub} );
                if ( $num == 0 ) {
                    print STDERR "there is no previous record for $f field.\n";
                }
            }
            elsif ( $f eq 'GA3' || $f eq 'GA4' || $f eq 'GA8' || $f eq 'GA19' )
            {
                my @items = split( /\n/, $tival{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    validate_cvterm( $db, $item, $fpr_type{$f} );
                }
            }
            elsif ($f eq 'GA10a'
                || $f eq 'GA10c'
                || $f eq 'GA10e'
                || $f eq 'GA10g'
                || $f eq 'GA11'
                || $f eq 'GA30'
                || $f eq 'GA80b' )
            {
                my $num =
                  get_unique_key_for_fr( $db, 'subject_id', 'object_id',
                    $v_unique, $fpr_type{$f}, $tival{pub} );
                if ( $num == 0 ) {
                    print STDERR
                      "ERROR: There is no previous record for $f field\n";
                }
            }
        }

        elsif ( $f eq 'GA1e' ) {
            if ( exists( $tival{gene} ) ) {
                my $newgn = decon( $tival{gene} );
                my ( $gn, $n, $r ) = get_alleleof_gene( $db, $v_unique );
                if ( $gn ne $newgn ) {
                    print STDERR
"Warning: allele $tival{GA1a} will be linked to gene $newgn instead of $gn\n";
                }
                else {
                    print STDERR
                      "Warning: allele has linked to gene $gn $newgn\n";
                }
            }

        }
        elsif ($f eq 'GA10a'
            || $f eq 'GA10c'
            || $f eq 'GA10e'
            || $f eq 'GA10g'
            || $f eq 'GA1f'
            || $f eq 'GA11'
            || $f eq 'GA30'
            || $f eq 'GA80b' )
        {
            my @items = split( /\n/, $tival{$f} );
            foreach my $item (@items) {
                $item =~ s/^\s+//;
                $item =~ s/\s+$//;
                if ( $item ne '+' && $item !~ 'NEW:' ) {
                    if ( !exists( $fbids{$item} ) ) {
                        my ( $uuu, $g, $s, $t ) =
                          get_feat_ukeys_by_name( $db, $item );
                        if ( $uuu eq '0' || $uuu eq '2' ) {
                            print STDERR
"ERROR: Could not find feature $item for field $f in the DB\n";
                        }
                    }
                }
            }
        }
    }
    if ( $v_unique =~ /FBal:temp/ ) {
        foreach my $fu ( keys %tival ) {
            if ( $fu =~ /(.*)\.upd/ ) {
                print STDERR "ERROR: !c fields  $1 for a new record \n";
            }
        }
    }

}

sub feature_relationship_process {
    my $self     = shift;
    my $unique   = shift;
    my $f        = shift; # key being processed
    my $ph_ref   = shift; # hash containing fields to be processed
    my $pub      = shift; # pub, $ph may not have pub if array items.
    my $item     = shift; # field value
    my $object   = shift;
    my $subject  = shift;
    my $out = '';
    my %ph = %$ph_ref;

    my ( $fr, $f_p ) = write_feature_relationship(
        $self->{db},   $doc,     $subject,
        $object,       $unique,  $item,
        $fpr_type{$f}, $pub, $feat_type{$f},
        $id_type{$f}
    );
    $out .= dom_toString($fr);
    $out .= $f_p;
    if ( $f eq 'GA80b' and defined( $ph{'GA80a'} ) and  $ph{'GA80a'} ne '') {
        my $rank = get_frprop_rank(
            $self->{db},
            $subject,
            $object,
            $unique,
            $item,
            $fpr_type{'GA80a'},
            $ph{'GA80a'}
        );
        my $fprop = create_ch_frprop(
            doc   => $doc,
            value => $ph{'GA80a'},
            type_id  =>create_ch_cvterm(
                name=> $fpr_type{'GA80a'},
                doc=>$doc,
                cv=>'feature_relationshipprop type'),
                rank  => $rank
            );
        $fr->appendChild($fprop);
        $out .= dom_toString($fr);
        $out .= $f_p;
        $fr->dispose();
    }
    return $out;
}
sub humanhealth_feature {
    my $self    = shift;
    my $hh_name = shift;
    my $unique = shift;
    my $fptype  = shift;
    my $pub = shift;

    my ( $hh_genus, $hh_species ) = get_humanhealth_ukeys_by_uname( $db, $hh_name );
    if ( $hh_genus eq '0' ) {
	      print STDERR "ERROR: could not find record for $hh_name\n";
	      exit(0);
	}
    my($fg, $fs, $ft)=get_feat_ukeys_by_uname($db, $unique);
	if($fg eq '0' || $fg eq '2'){
	 	print STDERR "ERROR: could not find feature for $unique in DB\n";
         exit(0)
	}

    my $out = '';
    my $hh = create_ch_humanhealth(
                 doc         => $doc,
                 uniquename  => $hh_name,
                 organism_id => create_ch_organism(
                                   doc     => $doc,
                                   genus   => 'Homo',
                                   species => 'sapiens'),
                 macro_id    => $hh_name);
    $out .= dom_toString($hh);
	my $sn_f=create_ch_humanhealth_feature(doc=>$doc,
						 feature_id=>$unique,
						 humanhealth_id=>$hh_name,
						 pub_id=>$pub);

 	my $ph_cv = get_cv_by_cvterm( $db, $fptype);

	my $s_fp = create_ch_humanhealth_featureprop(
						       doc=>$doc,
						       type_id=>create_ch_cvterm(
										 doc  => $doc,
										 name => $fptype,
										 cv   => $ph_cv
										),
						      );
	$sn_f->appendChild($s_fp);
    $out .= dom_toString($sn_f);
    return $out;
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

! ALLELE PROFORMA                        Version 39: 6 July 2007
!
! GA1a.  Allele symbol to use in database                  *A :
! GA1b.  Allele symbol used in paper                       *i :
! GA1e.  Action - rename this allele symbol                   :
! GA1f.  Action - merge these alleles                         :
! GA1g.  Is GA1a the valid symbol of an allele in FlyBase?    :y
! GA2a.  Allele name to use in database                    *e :
! GA2b.  Allele name used in paper                         *V :
! GA2c.  Database allele name(s) to replace                *V :
! GA31.  Etymology                                            :
! GA32a. Action - delete allele             - TAKE CARE :
! GA32b. Action - dissociate GA1a from FBrf - TAKE CARE :
! GA3.   Rank [CV]                                      *k :
! GA4.   Allele class [CV]                              *k :
! GA56.  Phenotypic | dominance class [bipartite CV]    *k :
! GA17.  Phenotype  [CV, body part(s) where manifest]   *k :
! GA7a.  Phenotype  [free text]                         *k :
! GA28a. Genetic interaction  [CV, class, effect]       *S :
! GA28b. Genetic interaction  [CV, anatomy, effect]     *S :
! GA28c. Genetic interaction  [free text]               *S :
! GA29a. Xenogenetic interaction [CV, class, effect]    *j :
! GA29b. Xenogenetic interaction [CV, anatomy, effect]  *j :
! GA29c. Xenogenetic interaction [free text]            *j :
! GA21.  Interallelic complementation data (structured) [SoftCV]*Q :
! GA22.  Interallelic complementation data (free text)          *Q :
! GA10a. Associated construct                              *I :
! GA10b. Name in paper for construct                       *L :
! GA10c. Associated insertion - G1a is outwith insert      *G :
! GA10d. Name in paper for insertion                       *N :
! GA10e. Associated insertion - G1a is inside insert   *G :
! GA10f. Name in paper for insertion                   *N :
! GA10g. Associated aberration / cytology +            *P/*C  :
! GA8.   Mutagen [CV]                                  *o :
! GA19.  Vehicle of assay [CV]                         *k :
! GA15.  Discoverer                                    *w :
! GA11.  Progenitor genotype                           *O :
! GA23a. Notes on origin [SoftCV]                      *R :
! GA23b. Notes on origin [free text]                   *R :
! GA12a. Nucleotide/amino acid changes (wrt GA11) [SoftCV]*s :
! GA12b. Molecular modifications (wrt GA11)   [free text] *s :
! GA30.  Tagged with                                       :
! GA13.  Comments not specific to one transcript/product*u :
! GA20.  Information on availability                    *v :
! GA33.  Accession number (seq cur only)         TAKE CARE :
! GA14.  Internal notes  *W :
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


=head1 AUTHOR

Haiyan Zhang, E<lt>haiyan@morgan.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
