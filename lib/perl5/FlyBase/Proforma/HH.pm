package FlyBase::Proforma::HH;

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

# This allows declaration	use FlyBase::Proforma::HH ':all';
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
my $ver = 1.7;

# Preloaded methods go here.

=head1 NAME

FlyBase::Proforma::HH - Perl module for parsing the FlyBase

HUMAN HEALTH MODEL PROFORMA   Version 1.7:  19 June 2014

See the bottom for the proforma
                         
=head1 SYNOPSIS

  use FlyBase::Proforma::HH;
  use DBI;
  
  my $mdbh=DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";
  my %ph=(HH1f=>'FBhh0000001',....);
  ###!c field implemented as '$fieldname.upd=>'c'' eg. 'HH1d.upd'=>'c'
   
  #params db is manditory, debug and validate is optional
  my $pro=FlyBase::proforma::HH->new(db=>$mdbh);
  $pro->validate(%ph);
  my $chadoxml = $pro->process(%ph);
  
  # or

  my $pro=FlyBase::Proforma::HH->new(db=>$mdbh,debug=>1,validate=>1);
  my $chadoxml_string=$pro->process(%ph);

=head1 DESCRIPTION

FlyBase::Proforma::HH is a perl module for parsing FlyBase
 the Human Health Model proforma and write the result as chadoxml. It is required
to connected to a chado database for validating and processing.
See Proforma for the proforma template.

The module also requires FlyBase::Proforma::Writechado and
FlyBase::Proforma::Util. The results can be loaded into a chado
database by XML::Xort.

=head2 EXPORT

  process
  validate

=cut

our %hh1gtype = ( 'disease', 1, 'health-related process', 1, );

our %hh2atype = (
    'parent entity',   '1', 'sub-entity',   '1',
    'specific entity', '1', 'group entity', '1',
);

our %ftype =
  ( 'HH7a', 'FBgn', 'HH7d', 'FBgn', 'HH7b', 'FBgn', 'HH8a', 'FBgn', );

#mapping proforma to chado
our %fpr_type = (
    'HH1f', 'uniquename',
    'HH1b', 'symbol',       # synonym humanhealth_synonym.is_current = true
    'HH1g',
    'sub_datatype',    ## humanhealthprop.value disease, health-related process
    'HH1d', 'symbol',  # synonym humanhealth_synonym.is_current = false
    'HH1e', 'symbol',  # synonym humanhealth_synonym.is_current = false
    'HH2a', 'category'
    , #humanhealthprop.value parent entity, sub-entity, specific entity, group entity cv (property type) cvterm.name (category)
    'HH2b', 'belongs_to'
    , #humanhealth_relationship object only if HH1f is humanhealthprop.type = cv (property type) cvterm.name (category) value 'sub-entity'
    'HH2c', 'OMIM_PHENOTYPE'
    , #humanhealth_dbxref db = OMIM_PHENOTYPE, humanhealth_dbxrefprop hh2c_link -- now OK for all
    'HH2d', 'disease_ontology'
    , #humanhealth_cvterm humanhealth_cvtermprop for humanhealth_cvterm DOID cvterm -- cv 'disease_ontology' , for  humanhealth_cvtermprop type cv = 'humanhealth_cvtermprop type' cvterm.name = 'doid_term' -- new cvterm
    'HH3a', 'rename',          #  synonym humanhealth_synonym.is_current = false
    'HH3b', 'merge',           ## not implemented
    'HH3c', 'delete',          # humanhealth.is_obsolete
    'HH3d', 'dissociate FBrf', #like INli -- do not need library, expression
    'HH1c', 'hdm_internal_name'
    , ### humanhealthprop OMIM phenotype symbol (internal comment) cvterm.name = 'hdm_internal_name' -- new cvterm
    'HH4a', 'phenotype_description',    #humanhealthprop
    'HH4b', 'genetics_description',     #humanhealthprop
    'HH4c', 'cellular_description',     #humanhealthprop
    'HH4g', 'molecular_description',    #humanhealthprop
    'HH4h', 'process_description',      #humanhealthprop
    'HH4d', 'biological process'
    , #humanhealth_cvterm humanhealth_cvtermprop for humanhealth_cvterm GO cvterm -- cv 'biological process' , for  humanhealth_cvtermprop type cv = 'humanhealth_cvtermprop type' cvterm.name = 'go_term' -- new cvterm -- limit to HH1g 'health-related process' ?
    'HH4f', 'associated_with',    #humanhealth_relationship object
    'HH6c', 'OMIM_PHENOTYPE'
    , #humanhealth_dbxref, humanhealth_dbxrefprop type_id 'OMIM_pheno_table' db = OMIM_PHENOTYPE -- only if HH1f is humanhealthprop.type = cv (property type) cvterm.name (parent entity or group entity)  no lookup to see if accession in chado
    'HH10',  'hh_model_status',                #humanhealthprop
    'HH11a', 'mammalian_transgenics',          #humanhealthprop “y” or blank
    'HH11b', 'mammalian_transgenics_het_rescue'
    , #humanhealthprop if HH11b equal y or humanhealthprop.type mammalian_transgenics = y
    'HH11c', 'mammalian_transgenics_pheno'
    , #humanhealthprop  if HH11b equal y or humanhealthprop.type mammalian_transgenics = y
    'HH11d', 'mammalian_transgenics_physical_inter'
    , #humanhealthprop if HH11b equal y or humanhealthprop.type mammalian_transgenics = y
    'HH11e', 'mammalian_transgenics_genetic_inter'
    , #humanhealthprop if HH11b equal y or humanhealthprop.type mammalian_transgenics = y
    'HH11f', 'mammalian_transgenics_pert_treat'
    , #humanhealthprop if HH11b equal y or humanhealthprop.type mammalian_transgenics = y
    'HH12a', 'dmel_pheno',          #humanhealthprop
    'HH12b', 'dmel_physical_inter', #humanhealthprop
    'HH12c', 'dmel_genetic_inter',  #humanhealthprop
    'HH12d', 'dmel_pert_treat',     #humanhealthprop
    'HH12e', 'dmel_recomb',         #humanhealthprop
    'HH13a', 'experiment_info',     #humanhealthprop
    'HH20',  'hh_internal_notes',   ###humanhealthprop Internal notes
    'HH5a',  'data_link',           ##humanhealth_dbxref, humanhealth_dbxrefprop
    'HH14a', 'BDSC_data_link',      ##humanhealth_dbxref, humanhealth_dbxrefprop
    'HH7b',  'other_mammalian_gene'
    , ##humanhealth_feature.feature_id/, humanhealth_featureprop cv = humanhealth_featureprop type cvterm (other_mammalian_gene) -- only if HH1f is humanhealthprop.type = cv (property type) cvterm.name (sub-entity or specific entity or group entity)

    'HH7a', 'human_gene_implicated'
    , ##humanhealth_feature.feature_id/, humanhealth_featureprop cv = humanhealth_featureprop type with HH7a -- only if HH1f is humanhealthprop.type = cv (property type) cvterm.name (sub-entity or specific entity or group entity)
    'HH7e', 'hgnc_link'
    , ##humanhealth_dbxref, humanhealth_dbxrefprop cv = property type hgnc_link (new cvterm)
    'HH7c', 'hh_ortho_rel_comment'
    , ##humanhealth_dbxrefprop cv = property type hh_ortho_rel_comment with HH7e
    'HH7d', 'diopt_ortholog'
    , ##feature_humanhealth_dbxref with HH7e feature HH7d humanhealth_dbxrefprop cv = property type diopt_ortholog (new cvterm)
    'HH8a', 'dmel_gene_implicated'
    , ##humanhealth_feature.feature_id/, humanhealth_featureprop cv = propert type with HH8c -- only if HH1f is humanhealthprop.type =  cv (property type) cvterm.name (category) value (sub-entity or specific entity or group entity)

#    'HH8b', 'dmel_info', ##humanhealth_featureprop cv = humanhealth_featureprop type with HH8a need to track rank
    'HH8c', 'hh_ortholog_comment'
    , ##humanhealth_featureprop cv = property type with HH8a -- humanhealth_featureprop need to track rank
    'HH15', 'dros_model_overview'
    , ###humanhealthprop.type =  cv (property type) cvterm.name (category) value (parent sub-entity specific entity or group entity)
    'HH8e', 'syn_gene_implicated'
    , ##humanhealth_feature.feature_id/, humanhealth_featureprop cv = humanhealth_featureprop type  -- only if HH1f is humanhealthprop.type = cv (property type) cvterm.name  (category) value (sub-entity or specific entity or group entity)
    'HH13b', 'proposed_mech'
    , #humanhealthprop.type =  cv (property type) cvterm.name (category) value (parent sub-entity specific entity or group entity)
    'HH16a', 'devel_model'
    ,  #humanhealth_pubprop.type =  cv (humanhealth_pubprop type) all categories
    'HH16b', 'refine_model'
    ,  #humanhealth_pubprop.type =  cv (humanhealth_pubprop type) all categories
    'HH16c', 'mech_disease_mut'
    ,  #humanhealth_pubprop.type =  cv (humanhealth_pubprop type) all categories
    'HH16d', 'genetic_int'
    ,  #humanhealth_pubprop.type =  cv (humanhealth_pubprop type) all categories
    'HH16e', 'phys_int'
    ,  #humanhealth_pubprop.type =  cv (humanhealth_pubprop type) all categories
    'HH16f', 'subcell_pheno'
    ,  #humanhealth_pubprop.type =  cv (humanhealth_pubprop type) all categories
    'HH16g', 'role_post-trans'
    ,  #humanhealth_pubprop.type =  cv (humanhealth_pubprop type) all categories
    'HH16h', 'molec_mech'
    ,  #humanhealth_pubprop.type =  cv (humanhealth_pubprop type) all categories
    'HH16i', 'role_molec_pathway'
    ,  #humanhealth_pubprop.type =  cv (humanhealth_pubprop type) all categories
    'HH16j', 'chem_pert'
    ,  #humanhealth_pubprop.type =  cv (humanhealth_pubprop type) all categories
    'HH16k', 'enviro_pert'
    ,  #humanhealth_pubprop.type =  cv (humanhealth_pubprop type) all categories
    'HH16l', 'drug_disc'
    ,  #humanhealth_pubprop.type =  cv (humanhealth_pubprop type) all categories
    'HH7f', ''
    , #Action - dissociate accession specified in HH7e from this human health model (blank/y)
    'HH8d', ''
    , #Action - dissociate gene specified in HH8a from this human health model (blank/y)
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
    my $genus   = 'Homo';
    my $species = 'sapiens';
    my $type;
    my $out = '';

    if ( exists( $self->{debug} ) && $self->{debug} == 1 ) {
        foreach my $key ( keys %ph ) {
            print STDERR "$key, $ph{$key}\n";
        }
    }
    print STDERR "processing humanhealth.pro $ph{HH1f}...\n";
    if ( exists( $self->{v} ) && $self->{v} == 1 ) {
        $self->validate($tihash);
    }
    if ( exists( $fbids{ $ph{HH1b} } ) ) {
        $unique = $fbids{ $ph{HH1b} };
    }
    else {
        ( $unique, $out ) = $self->write_humanhealth($tihash);
    }
    if ( exists( $fbcheck{ $ph{HH1b} }{ $ph{pub} } ) ) {
        print STDERR
          "Warning:  $ph{HH1b} $ph{pub} exists in a previous proforma\n";
    }
    $fbcheck{ $ph{HH1b} }{ $ph{pub} } = 1;
    if ( !exists( $ph{HH3d} ) ) {
        print STDERR
          "Action Items: HH $unique == $ph{HH1b} with pub $ph{pub}\n";
        my $f_p = create_ch_humanhealth_pub(
            doc            => $doc,
            humanhealth_id => $unique,
            pub_id         => $ph{pub},
        );
        $out .= dom_toString($f_p);
        $f_p->dispose();
    }
    else {
        $out .=
          dissociate_with_pub_fromhumanhealth( $self->{db}, $unique, $ph{pub} );
        print STDERR "Action Items: dissociate $ph{HH1b} with $ph{pub}\n";
        return $out;
    }
    ##Process other field in Trangenic Insertion proforma
    foreach my $f ( keys %ph ) {

        # print STDERR $f,"\n";
        if ( $f eq 'HH1d' || $f eq 'HH1e' ) {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "CHECK: !c implementation for $f\n";
                print STDERR "Action Items: !c log, $ph{HH1f} $f  $ph{pub}\n";
                my $s_pub   = $ph{pub};
                my $current = 'f';
                $out .= delete_humanhealth_synonym( $self->{db}, $doc, $unique,
                    $s_pub, $fpr_type{$f}, $current );
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                my $tt = '';
                if ( ( $f eq 'HH1d' ) && ( $ph{$f} eq $ph{HH1b} ) ) {
                    $tt = 'a';
                }
                else {
                    $tt = 'd';
                }
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    my $s_type = $fpr_type{$f};
                    my $s_pub  = $ph{pub};
                    $out .=
                      write_table_synonyms( 'humanhealth', $doc, $unique,
                        $item, $tt, $s_pub, $s_type );
                }
            }
        }
        elsif ( $f eq 'HH2b' ) {
            print STDERR "CHECK,  use of HH2b\n";
            my $object  = 'object_id';
            my $subject = 'subject_id';

            if ( exists( $ph{"$f.upd"} ) and $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{HH1f} $f  $ph{pub}\n";
                my @results = get_unique_key_for_hhr(
                    $self->{db}, $subject,      $object,
                    $unique,     $fpr_type{$f}, $ph{pub}
                );
                foreach my $ta (@results) {
                    my $num = get_hhr_pub_nums( $self->{db}, $ta->{fr_id} );
                    if ( $num == 1 ) {
                        $out .=
                          delete_humanhealth_relationship( $self->{db}, $doc,
                            $ta, $subject, $object, $unique, $fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_humanhealth_relationship_pub( $self->{db},
                            $doc,
                            $ta, $subject, $object, $unique, $fpr_type{$f},
                            $ph{pub} );
                    }
                    else {
                        print STDERR "something Wrong, please validate first\n";
                    }
                }

            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                my $cat = 0;

                #check category
                if ( exists( $ph{HH2a} ) && ( $ph{HH2a} eq 'sub-entity' ) ) {
                    $cat = 1;
                }
                else {
                    my $category = &get_hh_category( $self->{db}, $unique );
                    if ( $category eq 'sub-entity' ) {
                        $cat = 1;
                    }
                }
                if ( $cat == 1 ) {
                    my @items = split( /\n/, $ph{$f} );
                    foreach my $item (@items) {
                        $item =~ s/^\s+//;
                        $item =~ s/\s+$//;
                        my ( $fr, $f_p ) =
                          write_humanhealth_relationship( $self->{db}, $doc,
                            $subject, $object, $unique, $item,
                            $fpr_type{$f}, $ph{pub}, );
                        $out .= dom_toString($fr);
                        $out .= $f_p;
                    }
                }
                else {
                    print STDERR
"ERROR:only 'sub-entity' category allowed for this field $f\n";
                }

            }
        }
        elsif ( $f eq 'HH4f' ) {
            print STDERR "CHECK,  use of HH4f\n";
            my $object  = 'object_id';
            my $subject = 'subject_id';

            if ( exists( $ph{"$f.upd"} ) and $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{HH1f} $f  $ph{pub}\n";
                my @results = get_unique_key_for_hhr(
                    $self->{db}, $subject,      $object,
                    $unique,     $fpr_type{$f}, $ph{pub}
                );
                foreach my $ta (@results) {
                    my $num = get_hhr_pub_nums( $self->{db}, $ta->{fr_id} );
                    if ( $num == 1 ) {
                        $out .=
                          delete_humanhealth_relationship( $self->{db}, $doc,
                            $ta, $subject, $object, $unique, $fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_humanhealth_relationship_pub( $self->{db},
                            $doc,
                            $ta, $subject, $object, $unique, $fpr_type{$f},
                            $ph{pub} );
                    }
                    else {
                        print STDERR "something Wrong, please validate first\n";
                    }
                }

            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    if ( $item eq $unique ) {
                        print STDERR
                          "ERROR $item in $f cannot be same as HH1f $unique\n";
                    }
                    else {
                        my ( $fr, $f_p ) =
                          write_humanhealth_relationship( $self->{db}, $doc,
                            $subject, $object, $unique, $item,
                            $fpr_type{$f}, $ph{pub}, );
                        $out .= dom_toString($fr);
                        $out .= $f_p;
                    }
                }
            }
        }

        elsif ( $f eq 'HH2c' ) {
            print STDERR "CHECK: first use of humanhealth_dbxref\n";
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{hh1f} $f  $ph{pub}\n";
                my @result = get_dbxref_by_humanhealth_db( $self->{db}, $unique,
                    $fpr_type{$f}, "hh2c_link" );
                foreach my $tt (@result) {
                    my $feat_dbxref = create_ch_humanhealth_dbxref(
                        doc            => $doc,
                        humanhealth_id => $unique,
                        dbxref_id      => create_ch_dbxref(
                            doc       => $doc,
                            db        => $fpr_type{$f},
                            accession => $tt->{acc},
                            version   => $tt->{version},
                        )

                    );
                    $feat_dbxref->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($feat_dbxref);
                    $feat_dbxref->dispose();
                }
            }
            if ( defined( $ph{HH2c} ) && $ph{HH2c} ne '' ) {
                my $cat = 1;

#check category
#	if(exists($ph{HH2a}) && ($ph{HH2a} eq 'parent entity' || $ph{HH2a} eq 'sub-entity' || $ph{HH2a} eq 'specific entity') ){
#	  $cat = 1;
#	}
#	else{
#	  my $category = &get_hh_category($self->{db},$unique);
#	  if ($category eq 'parent entity' || $category eq 'sub-entity' || $category eq 'specific entity') {
#	    $cat = 1;
#	  }
#	}
                if ( $cat == 1 ) {
                    my @items = split( /\n/, $ph{$f} );
                    foreach my $item (@items) {
                        $item =~ s/^\s+//;
                        $item =~ s/\s+$//;
                        if ( $item !~ /^\d{6}$/ ) {
                            print STDERR
"ERROR: $item NOT a 6-digit OMIM ID in $f $ph{HH1b}\n";
                            next;
                        }
                        my $val =
                          get_dbxref_by_db_dbxref( $self->{db}, $fpr_type{$f},
                            $item );
                        if ( $val == 1 ) {
                            my $sdbxref = create_ch_humanhealth_dbxref(
                                doc            => $doc,
                                humanhealth_id => $unique,
                                dbxref_id      => create_ch_dbxref(
                                    doc       => $doc,
                                    db        => $fpr_type{$f},
                                    accession => $item,
                                    macro_id  => $item,
                                ),
                            );
                            my $fdp = create_ch_humanhealth_dbxrefprop(
                                doc    => $doc,
                                type   => "hh2c_link",
                                cvname => "property type"
                            );
                            my $fdp2pub = create_ch_humanhealth_dbxrefprop_pub(
                                doc    => $doc,
                                pub_id => $ph{pub}
                            );
                            $fdp->appendChild($fdp2pub);
                            $sdbxref->appendChild($fdp);
                            $out .= dom_toString($sdbxref);
                        }
                        else {
                            print STDERR
"WARN:OMIM_phenotype accession $f $ph{HH2c} not in chado\n";
                            print STDERR
                              "DEBUG: new accession in $f $ph{HH2c} \n";
                            my $sdbxref = create_ch_humanhealth_dbxref(
                                doc            => $doc,
                                humanhealth_id => $unique,
                                dbxref_id      => create_ch_dbxref(
                                    doc       => $doc,
                                    db        => $fpr_type{$f},
                                    accession => $item,
                                    macro_id  => $item,
                                    no_lookup => 1,
                                ),
                            );
                            my $fdp = create_ch_humanhealth_dbxrefprop(
                                doc    => $doc,
                                type   => "hh2c_link",
                                cvname => "property type"
                            );
                            my $fdp2pub = create_ch_humanhealth_dbxrefprop_pub(
                                doc    => $doc,
                                pub_id => $ph{pub}
                            );
                            $fdp->appendChild($fdp2pub);
                            $sdbxref->appendChild($fdp);
                            $out .= dom_toString($sdbxref);

                        }
                    }
                }

#	else{
#	  print STDERR "ERROR:only 'parent entity' or 'sub-entity' or 'specific entity' category allowed for this field $f\n";
#	}
            }
        }
        elsif ( $f eq 'HH3a' ) {
            $out .= update_humanhealth_synonym( $self->{db}, $doc,
                $unique, $ph{$f}, 'symbol' );
            $fbids{$unique} = $ph{HH1b};

        }

        if ( $f eq 'HH3b' ) {
            print STDERR "ERROR: not implemented yet \n";

#          my $tmp=$ph{$f};
#         $tmp=~s/\n/ /g;
#         if($ph{HH1f} eq 'new'){
#              print STDERR "ERROR: Action Items: merge HH $tmp\n";
#          }
#           else{
#              print STDERR "Action Items: merge HH $tmp to $ph{HH1f} \n";
#          }
#  $out .= merge_library_records( $self->{db}, $unique, $ph{$f},$ph{HH1f}, $ph{pub} );

        }

        elsif ( $f eq 'HH1g' ) {
            print STDERR "CHECK: first use of  $f \n";
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                my @results =
                  get_unique_key_for_humanhealthprop( $self->{db}, $unique,
                    $fpr_type{HH1g}, $ph{pub} );
                if ( @results == 0 ) {
                    print STDERR "ERROR: no previous record found for $f \n";
                }
                else {
                    foreach my $t (@results) {
                        $out .=
                          delete_humanhealthprop( $doc, $t->{rank}, $unique,
                            $fpr_type{HH1g} );
                    }
                }
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                my $sub_datatype = $ph{$f};
                $sub_datatype = trim($sub_datatype);
                my $ok = 0;
                if ( $ph{HH1f} eq 'new'
                    || exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' )
                {
                    if ( exists( $hh1gtype{$sub_datatype} ) ) {
                        $ok = 1;
                        if ( $ok == 1 ) {
                            print STDERR "DEBUG: HH1g $ph{HH1g} found\n";
                            $out .=
                              write_humanhealthprop( $self->{db}, $doc,
                                $unique, $sub_datatype,
                                $fpr_type{HH1g}, $ph{pub} );
                        }
                        else {
                            print STDERR
"ERROR:something Wrong, HH1g not a valid sub-datatype\n";
                        }
                    }
                }
                else {
                    print STDERR
"ERROR: $unique $ph{HH1b} HH1f must be new or $f must be !c\n";
                }
            }
        }

        elsif ( $f eq 'HH2a' ) {
            print STDERR "CHECK: first use of  $f \n";
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                my @results =
                  get_unique_key_for_humanhealthprop( $self->{db}, $unique,
                    $fpr_type{HH2a}, $ph{pub} );
                if ( @results == 0 ) {
                    print STDERR "ERROR: no previous record found for $f \n";
                }
                else {
                    foreach my $t (@results) {
                        $out .=
                          delete_humanhealthprop( $doc, $t->{rank}, $unique,
                            $fpr_type{HH2a} );
                    }
                }
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                my $category = $ph{$f};
                $category = trim($category);
                my $ok = 0;
                if ( $ph{HH1f} eq 'new'
                    || exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' )
                {
                    if ( exists( $hh2atype{$category} ) ) {
                        $ok = 1;
                        if ( $ok == 1 ) {
                            print STDERR "DEBUG: HH2a $ph{HH2a} found\n";

                            $out .=
                              write_humanhealthprop( $self->{db}, $doc,
                                $unique, $category, $fpr_type{HH2a}, $ph{pub} );
                        }
                        else {
                            print STDERR
"ERROR:something Wrong, HH2a not a valid category\n";
                        }
                    }
                }
                else {
                    print STDERR
"ERROR: $unique $ph{HH1b} HH1f must be new or $f must be !c\n";
                }

            }
        }

        elsif ( $f eq 'HH2d' ) {

            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log, HH2d $f  $ph{pub}\n";
                my @results = get_cvterm_for_humanhealth_cvterm_withprop(
                    $self->{db}, $unique, $fpr_type{$f},
                    $ph{pub},    'doid_term'
                );
                if ( @results == 0 ) {
                    print STDERR "ERROR: no previous record found for $f \n";
                }
                foreach my $item (@results) {
                    my ( $cvterm, $obsolete ) = split( /,,/, $item );
                    my $feat_cvterm = create_ch_humanhealth_cvterm(
                        doc            => $doc,
                        humanhealth_id => $unique,
                        cvterm_id      => create_ch_cvterm(
                            doc         => $doc,
                            cv          => $fpr_type{$f},
                            name        => $cvterm,
                            is_obsolete => $obsolete,
                        ),
                        pub => $ph{pub}
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
                    my ( $dbname, $accession ) = split /:/, $item;
                    print STDERR
                      "CHECK: $item $f DB = $dbname, ACCESSION = $accession\n";
                    my $term =
                      get_cvterm_by_dbxref( $self->{db}, $dbname, $accession );
                    if ( $term ne '0' ) {
                        my $f_cvterm = create_ch_humanhealth_cvterm(
                            doc            => $doc,
                            humanhealth_id => $unique,
                            cvterm_id      => create_ch_cvterm(
                                doc  => $doc,
                                cv   => $fpr_type{$f},
                                name => $term,
                            ),
                            pub_id => $ph{pub}
                        );

                        my $fcvprop = create_ch_humanhealth_cvtermprop(
                            doc     => $doc,
                            type_id => create_ch_cvterm(
                                doc  => $doc,
                                name => 'doid_term',
                                cv   => 'humanhealth_cvtermprop type'
                            ),
                            rank => '0'
                        );
                        $f_cvterm->appendChild($fcvprop);
                        $out .= dom_toString($f_cvterm);
                        $f_cvterm->dispose();
                    }
                    else {
                        print STDERR "ERROR: no cv term found for $term $f \n";
                    }
                }

            }
        }

        elsif ( $f eq 'HH4d' ) {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                my @results = get_cvterm_for_humanhealth_cvterm_withprop(
                    $self->{db}, $unique, $fpr_type{$f},
                    $ph{pub},    'go_term'
                );
                if ( @results == 0 ) {
                    print STDERR "ERROR: no previous record found for $f \n";
                }
                foreach my $item (@results) {
                    my $feat_cvterm = create_ch_humanhealth_cvterm(
                        doc            => $doc,
                        humanhealth_id => $unique,
                        cvterm_id      => create_ch_cvterm(
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
                my $subd = 0;

                #check sub_datatype
                if ( exists( $ph{HH1g} )
                    && ( $ph{HH1g} eq 'health-related process' ) )
                {
                    $subd = 1;
                }
                else {
                    my $sub_datatype =
                      &get_hh_sub_datatype( $self->{db}, $unique );
                    if ( $sub_datatype eq 'health-related process' ) {
                        $subd = 1;
                    }
                }
                if ( $subd == 1 ) {

                    my @items = split( /\n/, $ph{$f} );
                    foreach my $item (@items) {
                        $item =~ s/^\s+//;
                        $item =~ s/\s+$//;
                        my $rc =
                          validate_cvterm( $self->{db}, $item, $fpr_type{$f} );
                        if ( $rc == 1 ) {
                            my $f_cvterm = &create_ch_humanhealth_cvterm(
                                doc            => $doc,
                                humanhealth_id => $unique,
                                cvterm_id      => create_ch_cvterm(
                                    doc  => $doc,
                                    cv   => $fpr_type{$f},
                                    name => $item,
                                ),
                                pub_id => $ph{pub}
                            );
                            my $fcvprop = create_ch_humanhealth_cvtermprop(
                                type_id => create_ch_cvterm(
                                    doc  => $doc,
                                    name => 'go_term',
                                    cv   => 'humanhealth_cvtermprop type'
                                ),
                                rank => '0'
                            );

                            $f_cvterm->appendChild($fcvprop);

                            $out .= dom_toString($f_cvterm);
                            $f_cvterm->dispose();
                        }
                        else {
                            print STDERR
                              "ERROR: no cv term found for $ph{HH4d} $f \n";
                        }

                    }
                }
                else {
                    print STDERR
"ERROR: only 'health-related process' sub-datatype allowed for this field\n";
                }
            }
        }
        elsif ( $f eq 'HH6c' ) {
            print STDERR "CHECK: first use of humanhealth_dbxref HH6c\n";
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{hh1f} $f  $ph{pub}\n";
                my @result = get_dbxref_by_humanhealth_db( $self->{db}, $unique,
                    $fpr_type{$f}, "OMIM_pheno_table" );
                foreach my $tt (@result) {
                    my $feat_dbxref = create_ch_humanhealth_dbxref(
                        doc            => $doc,
                        humanhealth_id => $unique,
                        dbxref_id      => create_ch_dbxref(
                            doc       => $doc,
                            db        => $fpr_type{$f},
                            accession => $tt->{acc},
                            version   => $tt->{version},
                        )

                    );
                    $feat_dbxref->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($feat_dbxref);
                    $feat_dbxref->dispose();
                }
            }
            if ( defined( $ph{HH6c} ) && $ph{HH6c} ne '' ) {
                my $cat = 0;

                #check category
                if (
                    defined( $ph{HH2a} )
                    && (   $ph{HH2a} eq 'parent entity'
                        || $ph{HH2a} eq 'group entity' )
                  )
                {
                    $cat = 1;
                    print STDERR
                      "CHECK: in HH6c where HH2a exists cat = $cat\n";
                }
                elsif ( defined( $ph{HH2a} ) && ( $ph{HH2a} eq '' ) ) {
                    my $category = &get_hh_category( $self->{db}, $unique );
                    if (   $category eq 'parent entity'
                        || $category eq 'group entity' )
                    {
                        $cat = 1;
                        print STDERR
"CHECK: in HH6c where HH2a not filled in cat = $cat lookup category = $category\n";
                    }
                }
                else {
                    my $category = &get_hh_category( $self->{db}, $unique );
                    if (   $category eq 'parent entity'
                        || $category eq 'group entity' )
                    {
                        $cat = 1;
                        print STDERR
"CHECK: in HH6c where HH2a not exists cat = $cat lookup category = $category\n";
                    }
                }
                if ( $cat == 1 ) {
                    my @items = split( /\n/, $ph{$f} );
                    foreach my $item (@items) {
                        $item =~ s/^\s+//;
                        $item =~ s/\s+$//;
                        if ( $item =~ /:/ ) {
                            print STDERR
"ERROR: only the accession part should be in this field\n";
                        }
                        my $val =
                          get_dbxref_by_db_dbxref( $self->{db}, $fpr_type{$f},
                            $item );
                        if ( $val == 1 ) {
                            my $sdbxref = create_ch_humanhealth_dbxref(
                                doc            => $doc,
                                humanhealth_id => $unique,
                                dbxref_id      => create_ch_dbxref(
                                    doc       => $doc,
                                    db        => $fpr_type{$f},
                                    accession => $item,
                                    macro_id  => $item,
                                ),
                            );
                            my $fdp = create_ch_humanhealth_dbxrefprop(
                                doc    => $doc,
                                type   => "OMIM_pheno_table",
                                cvname => "property type"
                            );
                            my $fdp2pub = create_ch_humanhealth_dbxrefprop_pub(
                                doc    => $doc,
                                pub_id => $ph{pub}
                            );
                            $fdp->appendChild($fdp2pub);
                            $sdbxref->appendChild($fdp);

                            $out .= dom_toString($sdbxref);
                        }
                        else {
                            print STDERR
"WARN:OMIM_phenotype accession $f $item not in chado\n";
                            print STDERR
                              "DEBUG: add new accession in $f $item\n";
                            my $sdbxref = create_ch_humanhealth_dbxref(
                                doc            => $doc,
                                humanhealth_id => $unique,
                                dbxref_id      => create_ch_dbxref(
                                    doc       => $doc,
                                    db        => $fpr_type{$f},
                                    accession => $item,
                                    macro_id  => $item,
                                    no_lookup => 1,
                                ),
                            );
                            my $fdp = create_ch_humanhealth_dbxrefprop(
                                doc    => $doc,
                                type   => "OMIM_pheno_table",
                                cvname => "property type"
                            );
                            my $fdp2pub = create_ch_humanhealth_dbxrefprop_pub(
                                doc    => $doc,
                                pub_id => $ph{pub}
                            );
                            $fdp->appendChild($fdp2pub);
                            $sdbxref->appendChild($fdp);
                            $out .= dom_toString($sdbxref);
                        }
                    }
                }
                else {
                    print STDERR
"ERROR:entries only allowed for this field $f when HH1f is in 'parent entity' or 'group entity' category \n";
                }
            }
        }

        elsif (
            $f eq 'HH1c'       #all
            || $f eq 'HH4a'    #all
            || $f eq 'HH4b'    #all
            || $f eq 'HH4c'    #all
            || $f eq 'HH4g'    #all
            || $f eq 'HH4h'    #all
            || $f eq 'HH10'    #sub-entity, specific entity or group entity only
            || $f eq 'HH11a'   #sub-entity, specific entity or group entity only
            || $f eq 'HH11b'   #sub-entity, specific entity or group entity only
            || $f eq 'HH11c'   #sub-entity, specific entity or group entity only
            || $f eq 'HH11d'   #sub-entity, specific entity or group entity only
            || $f eq 'HH11e'   #sub-entity, specific entity or group entity only
            || $f eq 'HH11f'   #sub-entity, specific entity or group entity only
            || $f eq 'HH12a'   #sub-entity, specific entity or group entity only
            || $f eq 'HH12b'   #sub-entity, specific entity or group entity only
            || $f eq 'HH12c'   #sub-entity, specific entity or group entity only
            || $f eq 'HH12d'   #sub-entity, specific entity or group entity only
            || $f eq 'HH12e'   #sub-entity, specific entity or group entity only
            || $f eq 'HH13a'   #sub-entity, specific entity or group entity only
            || $f eq 'HH20'    #all
            || $f eq 'HH15'    #all
            || $f eq 'HH13b'
          )                    #all

        {
            print STDERR "CHECK: first use of  $f \n";
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                my @results =
                  get_unique_key_for_humanhealthprop( $self->{db}, $unique,
                    $fpr_type{$f}, $ph{pub} );
                if ( @results == 0 ) {
                    print STDERR "ERROR: no previous record found for $f \n";
                }
                else {
                    foreach my $t (@results) {
                        my $num = get_humanhealthprop_pub_nums( $self->{db},
                            $t->{fp_id} );
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
                              delete_humanhealthprop( $doc, $t->{rank}, $unique,
                                $fpr_type{$f} );
                        }
                        elsif ( $num > 1 ) {
                            $out .=
                              delete_humanhealthprop_pub( $doc, $t->{rank},
                                $unique, $fpr_type{$f}, $ph{pub} );
                        }

                        else {
                            print STDERR
                              "ERROR:something Wrong, please validate first\n";
                        }
                    }
                }
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {

                # rules for category
                if (
                    $f eq 'HH1c'       #all
                    || $f eq 'HH4a'    #all
                    || $f eq 'HH4b'    #all
                    || $f eq 'HH4c'    #all
                    || $f eq 'HH4g'    #all
                    || $f eq 'HH4h'    #all
                    || $f eq 'HH20'    #all
                    || $f eq 'HH15'    #all
                    || $f eq 'HH13b'
                  )                    #all

                {
                    if ( $f eq 'HH15' ) {
                        if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                            $out .= write_humanhealthprop( $self->{db}, $doc,
                                $unique, $ph{$f}, $fpr_type{$f}, $ph{pub} );
                        }
                        else {
                            my @results = get_unique_key_for_humanhealthprop(
                                $self->{db},   $unique,
                                $fpr_type{$f}, $ph{pub}
                            );
                            if ( @results == 0 ) {
                                $out .=
                                  write_humanhealthprop( $self->{db}, $doc,
                                    $unique, $ph{$f}, $fpr_type{$f}, $ph{pub} );
                            }
                            else {
                                print STDERR "ERROR:use !c to change value\n";
                            }
                        }

                    }
                    else {
                        my @items = split( /\n/, $ph{$f} );
                        foreach my $item (@items) {
                            $item =~ s/^\s+//;
                            $item =~ s/\s+$//;

                            $out .=
                              write_humanhealthprop( $self->{db}, $doc,
                                $unique, $item, $fpr_type{$f}, $ph{pub} );
                        }
                    }
                }
                else {
                    my $cat = 0;

                    #check category
                    if ( exists( $ph{HH2a} )
                        && ( $ph{HH2a} ne 'parent entity' ) )
                    {
                        $cat = 1;
                    }
                    else {
                        my $category = &get_hh_category( $self->{db}, $unique );
                        if ( $category ne 'parent entity' ) {
                            $cat = 1;
                        }
                    }
                    if ( $cat == 1 ) {
                        if ( $f eq 'HH10' ) {
                            if ( exists( $ph{"$f.upd"} )
                                && $ph{"$f.upd"} eq 'c' )
                            {
                                $out .=
                                  write_humanhealthprop( $self->{db}, $doc,
                                    $unique, $ph{$f}, $fpr_type{$f}, $ph{pub} );
                            }
                            else {
                                my @results =
                                  get_unique_key_for_humanhealthprop(
                                    $self->{db},   $unique,
                                    $fpr_type{$f}, 'unattributed'
                                  );
                                if ( @results == 0 ) {
                                    $out .=
                                      write_humanhealthprop( $self->{db}, $doc,
                                        $unique, $ph{$f},
                                        $fpr_type{$f}, $ph{pub} );
                                }
                                else {
                                    print STDERR
                                      "ERROR:use !c to change value\n";
                                }
                            }
                        }
                        else {
                            my @items = split( /\n/, $ph{$f} );
                            foreach my $item (@items) {
                                $item =~ s/^\s+//;
                                $item =~ s/\s+$//;

                                $out .=
                                  write_humanhealthprop( $self->{db}, $doc,
                                    $unique, $item, $fpr_type{$f}, $ph{pub} );
                            }
                        }
                    }
                    else {
                        print STDERR
"ERROR:'parent entity' category not allowed for this field $f\n";
                    }
                }
            }
        }

        elsif ( $f eq 'HH5a' ) {
            $out .= &parse_dataset( $unique, \%ph, $ph{pub} );
        }
        elsif ( $f eq 'HH5' ) {
            print STDERR "CHECK: in multiple field $f\n";
            ##### humanhealth_dbxref multiple db/accessions
            my @array = @{ $ph{$f} };
            print STDERR "CHECK: there are " . ( $#array + 1 ) . " \n";
            foreach my $ref (@array) {
                print STDERR "CHECK: $ref\n";
                $out .= &parse_dataset( $unique, $ref, $ph{pub} );
            }
        }
        elsif ( $f eq 'HH14a' ) {
            $out .= &parse_dataset_bdsc( $unique, \%ph, $ph{pub} );
        }
        elsif ( $f eq 'HH14' ) {
            print STDERR "CHECK: in multiple field $f\n";
            ##### humanhealth_dbxref multiple db/accessions
            my @array = @{ $ph{$f} };
            print STDERR "CHECK: there are " . ( $#array + 1 ) . " \n";
            foreach my $ref (@array) {
                print STDERR "CHECK: $ref\n";
                $out .= &parse_dataset_bdsc( $unique, $ref, $ph{pub} );
            }
        }

        elsif ( $f eq 'HH7a' ) {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log $unique $ph{pub} $f \n";
                print STDERR "CHECK: first use of  $f !c humanheath_feature\n";

                my @results =
                  get_feature_for_humanhealth_feature( $self->{db}, $unique,
                    $ftype{$f}, $fpr_type{$f}, $ph{pub} );
                foreach my $item (@results) {
                    my $fu = $item;
                    ( my $fg, my $fs, my $ft ) =
                      get_feat_ukeys_by_uname( $self->{db}, $fu );
                    my $cname = "SO";
                    my $csf   = create_ch_humanhealth_feature(
                        doc        => $doc,
                        feature_id => create_ch_feature(
                            doc        => $doc,
                            uniquename => $fu,
                            genus      => $fg,
                            species    => $fs,
                            cvname     => $cname,
                            type       => $ft,
                        ),
                        humanhealth_id => $unique,
                        pub_id         => $ph{pub}
                    );

                    $csf->setAttribute( "op", "delete" );
                    $out .= dom_toString($csf);
                    $csf->dispose;
                }
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                print STDERR "CHECK: first use of  $f humanhealth_feature\n";
                my $fptype = $fpr_type{$f};
                my $cat    = 0;

                #check category
                if ( exists( $ph{HH2a} ) && ( $ph{HH2a} ne 'parent entity' ) ) {
                    $cat = 1;
                }
                else {
                    my $category = &get_hh_category( $self->{db}, $unique );
                    if ( $category ne 'parent entity' ) {
                        $cat = 1;
                    }
                }
                if ( $cat == 1 ) {
                    my @items = split( /\n/, $ph{$f} );
                    foreach my $item (@items) {
                        $item =~ s/^\s+//;
                        $item =~ s/\s+$//;
                        my $fu = $item;
                        ( my $fbid, my $fg, my $fs, my $ft ) =
                          get_feat_ukeys_by_name( $self->{db}, $fu );
                        if ( $fbid eq '0' || $fbid eq '2' ) {
                            print STDERR
                              "ERROR: could not find feature for $fu in DB\n";
                        }
                        else {
                            my $cname   = 'SO';
                            my $feature = create_ch_feature(
                                doc        => $doc,
                                uniquename => $fbid,
                                genus      => $fg,
                                species    => $fs,
                                cvname     => $cname,
                                type       => $ft,
                                macro_id   => $fbid,
                            );
                            $out .= dom_toString($feature);
                            my $sn_f = create_ch_humanhealth_feature(
                                doc            => $doc,
                                feature_id     => $fbid,
                                humanhealth_id => $unique,
                                pub_id         => $ph{pub},
                            );
                            my $ph_cv =
                              get_cv_by_cvterm( $self->{db}, $fptype );
                            print STDERR
                              "CHECK: cv for cvterm $fptype = $ph_cv\n";

                            my $s_fp = create_ch_humanhealth_featureprop(
                                doc     => $doc,
                                type_id => create_ch_cvterm(
                                    doc  => $doc,
                                    name => $fptype,
                                    cv   => $ph_cv
                                ),
                            );
                            $sn_f->appendChild($s_fp);
                            $out .= dom_toString($sn_f);
                        }
                    }
                }
                else {
                    print STDERR
"ERROR:'parent entity' category not allowed for this field $f\n";
                }
            }
        }
        elsif ( $f eq 'HH7b' ) {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log $unique $ph{pub} $f \n";
                print STDERR "CHECK: first use of  $f !c humanheath_feature\n";

                my @results =
                  get_feature_for_humanhealth_feature( $self->{db}, $unique,
                    $ftype{$f}, $fpr_type{$f}, $ph{pub} );
                foreach my $item (@results) {
                    my $fu = $item;
                    ( my $fg, my $fs, my $ft ) =
                      get_feat_ukeys_by_uname( $self->{db}, $fu );
                    my $cname = "SO";
                    my $csf   = create_ch_humanhealth_feature(
                        doc        => $doc,
                        feature_id => create_ch_feature(
                            doc        => $doc,
                            uniquename => $fu,
                            genus      => $fg,
                            species    => $fs,
                            cvname     => $cname,
                            type       => $ft,
                        ),
                        humanhealth_id => $unique,
                        pub_id         => $ph{pub}
                    );

                    $csf->setAttribute( "op", "delete" );
                    $out .= dom_toString($csf);
                    $csf->dispose;
                }
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                print STDERR "CHECK: first use of  $f humanhealth_feature\n";
                my $fptype = $fpr_type{$f};
                my $cat    = 0;

                #check category
                if ( exists( $ph{HH2a} ) && ( $ph{HH2a} ne 'parent entity' ) ) {
                    $cat = 1;
                }
                else {
                    my $category = &get_hh_category( $self->{db}, $unique );
                    if ( $category ne 'parent entity' ) {
                        $cat = 1;
                    }
                }
                if ( $cat == 1 ) {
                    my @items = split( /\n/, $ph{$f} );
                    foreach my $item (@items) {
                        $item =~ s/^\s+//;
                        $item =~ s/\s+$//;
                        my $fu = $item;
                        ( my $fbid, my $fg, my $fs, my $ft ) =
                          get_feat_ukeys_by_name( $self->{db}, $fu );
                        if ( $fbid eq '0' || $fbid eq '2' ) {
                            print STDERR
                              "ERROR: could not find feature for $fu in DB\n";
                        }
                        else {
                            my $cname   = 'SO';
                            my $feature = create_ch_feature(
                                doc        => $doc,
                                uniquename => $fbid,
                                genus      => $fg,
                                species    => $fs,
                                cvname     => $cname,
                                type       => $ft,
                                macro_id   => $fbid,
                            );
                            $out .= dom_toString($feature);
                            my $sn_f = create_ch_humanhealth_feature(
                                doc            => $doc,
                                feature_id     => $fbid,
                                humanhealth_id => $unique,
                                pub_id         => $ph{pub},
                            );
                            my $ph_cv =
                              get_cv_by_cvterm( $self->{db}, $fptype );
                            print STDERR
                              "CHECK: cv for cvterm $fptype = $ph_cv\n";

                            my $s_fp = create_ch_humanhealth_featureprop(
                                doc     => $doc,
                                type_id => create_ch_cvterm(
                                    doc  => $doc,
                                    name => $fptype,
                                    cv   => $ph_cv
                                ),
                            );
                            $sn_f->appendChild($s_fp);
                            $out .= dom_toString($sn_f);
                        }
                    }
                }
                else {
                    print STDERR
"ERROR:'parent entity' category not allowed for this field $f\n";
                }
            }
        }
        elsif ( $f eq 'HH7e' ) {
            $out .= &parse_hgnc_dbxref( $unique, \%ph, $ph{pub} );
        }
        elsif ( $f eq 'HH7' ) {
            print STDERR "Warning: in multiple HH7e field\n";
            ##### humanhealth_dbxref multiple hgnc accession
            my @array = @{ $ph{$f} };
            foreach my $ref (@array) {
                $out .= &parse_hgnc_dbxref( $unique, $ref, $ph{pub} );
            }
        }

        elsif ( $f eq 'HH8a' ) {
            $out .= &parse_affected_dmel_gene( $unique, \%ph, $ph{pub} );
        }
        elsif ( $f eq 'HH8' ) {
            print STDERR "Warning: in multiple HH8a field\n";
            ##### feature_relationship multiple affected_gene
            my @array = @{ $ph{$f} };
            foreach my $ref (@array) {
                $out .= &parse_affected_dmel_gene( $unique, $ref, $ph{pub} );
            }
        }
        elsif ( $f eq 'HH8e' ) {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log $unique $ph{pub} $f \n";
                print STDERR "CHECK: first use of  $f !c humanheath_feature\n";

                my @results =
                  get_feature_for_humanhealth_feature( $self->{db}, $unique,
                    $ftype{$f}, $fpr_type{$f}, $ph{pub} );
                foreach my $item (@results) {
                    my $fu = $item;
                    ( my $fg, my $fs, my $ft ) =
                      get_feat_ukeys_by_uname( $self->{db}, $fu );
                    my $cname = "SO";
                    my $csf   = create_ch_humanhealth_feature(
                        doc        => $doc,
                        feature_id => create_ch_feature(
                            doc        => $doc,
                            uniquename => $fu,
                            genus      => $fg,
                            species    => $fs,
                            cvname     => $cname,
                            type       => $ft,
                        ),
                        humanhealth_id => $unique,
                        pub_id         => $ph{pub}
                    );

                    $csf->setAttribute( "op", "delete" );
                    $out .= dom_toString($csf);
                    $csf->dispose;
                }
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {
                print STDERR "CHECK: first use of  $f humanhealth_feature\n";
                my $fptype = $fpr_type{$f};
                my $cat    = 0;

                #check category
                if ( exists( $ph{HH2a} ) && ( $ph{HH2a} ne 'parent entity' ) ) {
                    $cat = 1;
                }
                else {
                    my $category = &get_hh_category( $self->{db}, $unique );
                    if ( $category ne 'parent entity' ) {
                        $cat = 1;
                    }
                }
                if ( $cat == 1 ) {
                    my @items = split( /\n/, $ph{$f} );
                    foreach my $item (@items) {
                        $item =~ s/^\s+//;
                        $item =~ s/\s+$//;
                        my $fu = $item;
                        ( my $fbid, my $fg, my $fs, my $ft ) =
                          get_feat_ukeys_by_name( $self->{db}, $fu );
                        if ( $fbid eq '0' || $fbid eq '2' ) {
                            print STDERR
                              "ERROR: could not find feature for $fu in DB\n";
                        }
                        else {
                            my $cname   = 'SO';
                            my $feature = create_ch_feature(
                                doc        => $doc,
                                uniquename => $fbid,
                                genus      => $fg,
                                species    => $fs,
                                cvname     => $cname,
                                type       => $ft,
                                macro_id   => $fbid,
                            );
                            $out .= dom_toString($feature);
                            my $sn_f = create_ch_humanhealth_feature(
                                doc            => $doc,
                                feature_id     => $fbid,
                                humanhealth_id => $unique,
                                pub_id         => $ph{pub},
                            );
                            my $ph_cv =
                              get_cv_by_cvterm( $self->{db}, $fptype );
                            print STDERR
                              "CHECK: cv for cvterm $fptype = $ph_cv\n";

                            my $s_fp = create_ch_humanhealth_featureprop(
                                doc     => $doc,
                                type_id => create_ch_cvterm(
                                    doc  => $doc,
                                    name => $fptype,
                                    cv   => $ph_cv
                                ),
                            );
                            $sn_f->appendChild($s_fp);
                            $out .= dom_toString($sn_f);
                        }
                    }
                }
                else {
                    print STDERR
"ERROR:'parent entity' category not allowed for this field $f\n";
                }
            }
        }

        elsif ( $f =~ '^HH16[a-l]$' )    #all
        {
            print STDERR "CHECK: first use of  $f \n";
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                my $result =
                  get_num_for_humanhealth_pubprop( $self->{db}, $unique,
                    $fpr_type{$f}, $ph{pub} );
                if ( $result == 0 ) {
                    print STDERR "ERROR: no previous record in database\n";
                }
                else {
                    my $pub_el = create_ch_humanhealth_pub(
                        doc            => $doc,
                        pub_id         => $ph{pub},
                        humanhealth_id => $unique,
                    );
                    my $pub_prop = create_ch_humanhealth_pubprop(
                        doc    => $doc,
                        cvname => 'humanhealth_pubprop type',
                        type   => $fpr_type{$f},
                        rank   => 0,
                    );
                    $pub_prop->setAttribute( 'op', 'delete' );
                    $pub_el->appendChild($pub_prop);
                    $out .= dom_toString($pub_el);
                    $pub_el->dispose();
                }
            }
            if ( defined( $ph{$f} ) && $ph{$f} ne '' ) {

                #check if y
                if ( $ph{$f} eq "y" ) {
                    my $pub_el = create_ch_humanhealth_pub(
                        doc            => $doc,
                        pub_id         => $ph{pub},
                        humanhealth_id => $unique,
                    );
                    my $pub_prop = create_ch_humanhealth_pubprop(
                        doc    => $doc,
                        cvname => 'humanhealth_pubprop type',
                        type   => $fpr_type{$f},
                        value  => $ph{$f},
                        rank   => 0,
                    );
                    $pub_el->appendChild($pub_prop);
                    $out .= dom_toString($pub_el);
                    $pub_el->dispose();
                }
                else {
                    print STDERR "ERROR: $f must be 'y'/blank\n";
                }
            }
        }
    }
    $doc->dispose();
    return $out;
}

=head2 $pro->write_humanhealth(%ph)

  separate the id generation and lookup from the other curation field to make two-stage parsing possible

=cut

sub write_humanhealth {
    my $self    = shift;
    my $tihash  = {@_};
    my %ph      = %$tihash;
    my $unique  = '';
    my $flag    = 0;
    my $feature = '';
    my $genus   = 'Homo';
    my $species = 'sapiens';
    my $out     = '';

    if ( exists( $ph{HH1f} ) && $ph{HH1f} ne 'new' ) {
        if (   defined( $fbids{ $ph{HH1b} } )
            && !exists( $ph{HH3a} )
            && !exists( $ph{HH3b} )
            && !exists( $ph{HH3c} ) )
        {
            $unique = $fbids{ $ph{HH1b} };
            if ( $unique ne $ph{HH1f} ) {
                print STDERR
                  "ERROR: something is wrong! $ph{HH1b} != $ph{HH1f}\n";
            }
        }
        else {
            ( $genus, $species ) =
              get_humanhealth_ukeys_by_uname( $self->{db}, $ph{HH1f} );
            if ( $genus eq '0' ) {
                print STDERR "ERROR: could not find record for $ph{HH1f}\n";
                exit(0);
            }
            $unique = $ph{HH1f};
            print STDERR "DEBUG: $unique = HH1F $ph{HH1f}\n";
            $feature = create_ch_humanhealth(
                doc        => $doc,
                uniquename => $unique,
                species    => $species,
                genus      => $genus,
                macro_id   => $unique,
            );
            if ( exists( $ph{HH3c} ) && $ph{HH3c} eq 'y' ) {
                print STDERR
                  "Action Items: delete humanhealth record $ph{HH1f} \n";
                my $op = create_doc_element( $doc, 'is_obsolete', 't' );
                $feature->appendChild($op);
            }
            if ( exists( $ph{HH3a} ) ) {
                if ( exists( $fbids{ $ph{HH3a} } ) ) {
                    print STDERR
"ERROR: Rename HH3a $ph{HH3a} exists in a previous proforma\n";
                }
                if ( exists( $fbids{ $ph{HH1b} } ) ) {
                    print STDERR
"ERROR: Rename HH1b $ph{HH1b} exists in a previous proforma \n";
                }

                print STDERR
"Action Items: rename $ph{HH1f} from $ph{HH3a} to $ph{HH1b}\n";
                my $va = validate_humanhealth_name( $db, $ph{HH1b} );
                if ( $va == 0 ) {
                    my $n = create_doc_element( $doc, 'name',
                        decon( convers( $ph{HH1b} ) ) );
                    $feature->appendChild($n);
                    $out .= dom_toString($feature);
                    $out .= write_table_synonyms( 'humanhealth', $doc, $unique,
                        $ph{HH1b}, 'a', 'unattributed', 'symbol' );
                    $fbids{ $ph{HH3a} } = $unique;
                }
            }
            else {
                $out .= dom_toString($feature);
            }
            $fbids{ $ph{HH1b} } = $unique;
        }
    }
    elsif ( exists( $ph{HH1f} ) && $ph{HH1f} eq 'new' ) {
        if ( !exists( $ph{HH3b} ) ) {
            my $va = validate_humanhealth_name( $db, $ph{HH1b} );
            ### if the temp id has been used before, $flag will be 1 to avoid
            ### the DB Trigger reassign a new id to the same symbol.
            print STDERR
              "$va validate_humanhealth_name $ph{HH1b} and flag = $flag \n";
            if ( $va == 1 ) {
                $flag = 0;
                ( $unique, $genus, $species ) =
                  get_humanhealth_ukeys_by_name( $db, $ph{HH1b} );
                $fbids{ $ph{HH1b} } = $unique;
            }
        }
        print STDERR "Action Items: newHuman Health record  $ph{HH1b}\n";
        ( $unique, $flag ) = get_tempid( 'hh', $ph{HH1b} );
        print STDERR "Uniquename $unique for $ph{HH1b} and flag = $flag\n";

        if ( exists( $ph{HH3b} ) && $ph{HH1f} eq 'new' && $unique !~ /temp/ ) {
            print STDERR "ERROR: HH3b not implemented yet \n";
            print STDERR
"ERROR: merge humanhealth should have a FB..:temp id not $unique\n";
        }
        if ( $ph{HH1f} eq 'new' && ( !exists( $ph{HH2a} ) ) ) {
            print STDERR "ERROR, HH2a cannot be blank when HH1f is new\n";
        }
        if ( $ph{HH1f} eq 'new' && ( !exists( $ph{HH1g} ) ) ) {
            print STDERR "ERROR, HH1g cannot be blank when HH1f is new\n";
        }
        if ( $flag == 0 ) {
            $feature = create_ch_humanhealth(
                doc        => $doc,
                uniquename => $unique,
                name       => decon( convers( $ph{HH1b} ) ),
                genus      => $genus,
                species    => $species,
                macro_id   => $unique,
            );
            $out .= dom_toString($feature);
            $out .=
              write_table_synonyms( 'humanhealth', $doc, $unique, $ph{HH1b},
                'a', 'unattributed', 'symbol' );
        }
        else {
            print STDERR "ERROR, name $ph{HH1b} has been used in this load\n";
        }
    }
    else {
        print STDERR
          "ERROR, HH1f must be valid uniquename or new -- can't proceeed ..\n";

        #      exit(0);
    }
    $doc->dispose();
    return ( $out, $unique );

}

sub parse_affected_dmel_gene {
    my $unique  = shift;
    my $generef = shift;
    my $pub     = shift;
    my %affgene = %$generef;
    my $gene    = '';
    my $genus   = '';
    my $species = '';
    my $out     = '';
    my $fptype  = "dmel_gene_implicated";    #HH8a
    my $fptype3 = "hh_ortholog_comment";     #HH8c

    if ( exists( $affgene{"HH8a.upd"} ) && $affgene{"HH8a.upd"} eq 'c' ) {
        print STDERR "ERROR: !c Not allowed $unique $pub HH8a \n";
    }
    if (   ( exists( $affgene{HH8d} ) && $affgene{HH8d} eq 'y' )
        && ( defined( $affgene{HH8a} ) && $affgene{HH8a} ne '' ) )
    {
        print STDERR "Action Items: dissociate $unique $pub $affgene{HH8a} \n";
        my @results = get_humanhealth_feature( $db, $unique, $affgene{HH8a},
            $fpr_type{HH8a}, $pub );
        my $num = scalar(@results);
        if ( $num > 0 ) {
            foreach my $item (@results) {
                my $fu = $item;
                my ( $fg, $fs, $ft ) = get_feat_ukeys_by_uname( $db, $fu );
                my $cname = "SO";
                my $csf   = create_ch_humanhealth_feature(
                    doc        => $doc,
                    feature_id => create_ch_feature(
                        doc        => $doc,
                        uniquename => $fu,
                        genus      => $fg,
                        species    => $fs,
                        cvname     => $cname,
                        type       => $ft,
                    ),
                    humanhealth_id => $unique,
                    pub_id         => $pub
                );

                $csf->setAttribute( "op", "delete" );
                $out .= dom_toString($csf);
                $csf->dispose;
            }
        }
        else {
            print STDERR
              "ERROR: HH8d No previous results for HH8a $unique gene\n";
        }
        return $out;
    }
    if ( exists( $affgene{"HH8c.upd"} ) && $affgene{"HH8c.upd"} eq 'c' ) {
        print STDERR "Action Items: !c log $unique $pub HH8c \n";
        print STDERR "CHECK: first use of  HH8c !c humanhealth_featureprop\n";

        my @results = get_unique_key_for_humanhealth_featureprop( $db, $unique,
            $affgene{HH8a}, $fptype3, $pub );
        my $num = scalar(@results);
        if ( $num > 0 ) {
            foreach my $t (@results) {
                $out .=
                  delete_humanhealth_featureprop( $db, $doc, $unique,
                    $t->{uname}, $fptype3, $t->{rank}, $pub );
            }
        }
        else {
            print STDERR
"ERROR:No previous record found for $unique $affgene{HH8a} $pub HH8c \n";
        }
    }
    if ( defined( $affgene{HH8a} ) && $affgene{HH8a} ne '' ) {
        print STDERR "CHECK: first use of  HH8a humanhealth_feature\n";
        print STDERR "CHECK: property type for HH8a $fptype\n";
        my $cat = 0;

        #check category
        if ( exists( $affgene{HH2a} ) && ( $affgene{HH2a} ne 'parent entity' ) )
        {
            $cat = 1;
        }
        else {
            my $category = &get_hh_category( $db, $unique );
            if ( $category ne 'parent entity' ) {
                $cat = 1;
            }
        }
        if ( $cat == 1 ) {
            my $fu = $affgene{HH8a};
            print STDERR "DEBUG: add gene in HH8a $fu\n";
            # my ( $fbid, $fg, $fs, $ft ) = get_feat_ukeys_by_name( $db, $fu );
            my ( $fbid, $fg, $fs, $ft ) = get_feat_ukeys_by_name_type( $db, $fu, 'gene' );


            if ( $fbid eq '0' || $fbid eq '2' ) {
                print STDERR "ERROR: could not find feature for $fu in DB\n";
            }
            else {
                my $cname   = 'SO';
                my $feature = create_ch_feature(
                    doc        => $doc,
                    uniquename => $fbid,
                    genus      => $fg,
                    species    => $fs,
                    cvname     => $cname,
                    type       => $ft,
                    macro_id   => $fbid,
                );
                $out .= dom_toString($feature);
                my $sn_f = create_ch_humanhealth_feature(
                    doc            => $doc,
                    feature_id     => $fbid,
                    humanhealth_id => $unique,
                    pub_id         => $pub,
                );
                my $ph_cv = get_cv_by_cvterm( $db, $fptype );
                print STDERR "CHECK: cv for cvterm $fptype = $ph_cv\n";

                my $s_fp = create_ch_humanhealth_featureprop(
                    doc     => $doc,
                    type_id => create_ch_cvterm(
                        doc  => $doc,
                        name => $fptype,
                        cv   => $ph_cv
                    ),
                );
                $sn_f->appendChild($s_fp);

                if ( exists( $affgene{HH8c} ) && $affgene{HH8c} ne '' ) {
                    my $rank  = 0;
                    my @items = split( /\n/, $affgene{HH8c} );
                    foreach my $value (@items) {
                        $value =~ s/^\s+//;
                        $value =~ s/\s+$//;
                        print STDERR "DEBUG: comment in HH8c $value\n";
                        my $ph_cv3 = get_cv_by_cvterm( $db, $fptype3 );
                        print STDERR
                          "CHECK: cv for cvterm $fptype3 = $ph_cv3\n";
                        my $s_fp3 = create_ch_humanhealth_featureprop(
                            doc     => $doc,
                            type_id => create_ch_cvterm(
                                doc  => $doc,
                                name => $fptype3,
                                cv   => $ph_cv3,
                            ),
                            value => $value,
                            rank  => $rank,
                        );
                        $rank++;
                        $sn_f->appendChild($s_fp3);
                    }
                }
                $out .= dom_toString($sn_f);
            }
        }
        else {
            print STDERR
              "ERROR:'parent entity' category not allowed for this field\n";
        }
    }
    return $out;
}

sub parse_hgnc_dbxref {
    my $unique  = shift;
    my $generef = shift;
    my $pub     = shift;
    my %affgene = %$generef;
    my $gene    = '';
    my $genus   = '';
    my $species = '';
    my $out     = '';
    my $fptype  = 'hgnc_link';
    my $fptype2 = 'hh_ortho_rel_comment';
    my $fptype3 = 'diopt_ortholog';

    if ( ( exists( $affgene{"HH7e.upd"} ) && $affgene{"HH7e.upd"} eq 'c' ) ) {
        print STDERR "ERROR:!c not allowed for HH7e $unique $pub\n";
    }
    if ( exists( $affgene{HH7f} ) && $affgene{HH7f} eq 'y' ) {
        print STDERR "Action Items: dissociate $unique $pub $affgene{HH7e}\n";
        print STDERR
"CHECK: first use of  HH7e/HH7f HGNC humanhealth_dbxref and CHECK if deletes feature_humanhealth_dbxref, feature_humanhealth_dbxrefprop,feature_humanhealth_dbxrefprop_pub \n";
        my @result =
          get_ukey_for_humanhealth_dbxref( $db, $unique, $affgene{HH7e},
            "hgnc_link" );
        my $num = scalar(@result);
        if ( $num > 0 ) {
            foreach my $tt (@result) {
                my $feat_dbxref = create_ch_humanhealth_dbxref(
                    doc            => $doc,
                    humanhealth_id => $unique,
                    dbxref_id      => create_ch_dbxref(
                        doc       => $doc,
                        db        => $tt->{db},
                        accession => $tt->{acc},
                        version   => $tt->{version},
                    )
                );
                $feat_dbxref->setAttribute( 'op', 'delete' );
                $out .= dom_toString($feat_dbxref);
                $feat_dbxref->dispose();
            }
        }
        else {
            print STDERR
"ERROR: HH7f No previous results for HH7e $unique HGNC accession\n";
        }
        return $out;
    }
    if ( exists( $affgene{"HH7c.upd"} ) && $affgene{"HH7c.upd"} eq 'c' ) {
        print STDERR "Action Items: !c log $unique $pub HH7c \n";
        print STDERR
"CHECK: first use of  HH7c !c HGNC humanhealth_dbxref and CHECK if deletes humanhealth_dbxrefprop_pub\n";
        my @results = get_unique_key_for_humanhealth_dbxrefprop( $db, $unique,
            $affgene{HH7e}, $fptype2, $pub );
        foreach my $t (@results) {
            my $num = get_humanhealth_dbxrefprop_pub_nums( $db, $t->{fp_id} );
            if ( $num == 1 ) {
                $out .=
                  delete_humanhealth_dbxrefprop( $db, $doc, $t->{fp_id},
                    $t->{rank}, $unique, $fptype2 );
            }
            elsif ( $num > 1 ) {
                $out .=
                  delete_humanhealth_dbxrefprop_pub( $db, $doc, $t->{fp_id},
                    $t->{rank}, $unique, $fptype2, $pub );
            }
            else {
                print STDERR "ERROR:something Wrong, please validate first\n";
            }
        }
    }
    if ( exists( $affgene{"HH7d.upd"} ) && $affgene{"HH7d.upd"} eq 'c' ) {
        print STDERR "Action Items: !c log $unique $pub HH7d \n";

#	    print STDERR "WARN: HH7d !c HGNC feature_humanhealth_dbxref NOT yet implemented\n";
        print STDERR
          "CHECK: first use of  HH7d !c HGNC feature_humanhealth_dbxref\n";
        my @results =
          get_feature_humanhealth_dbxref_by_pub( $db, $unique, $affgene{HH7e},
            $fptype3, $pub );
        my $num = scalar(@results);
        if ( $num > 0 ) {
            foreach my $tt (@results) {

                # IDL: No idea what is going on here?
                my $feat_dbxref = create_ch_feature_humanhealth_dbxref(
                    doc        => $doc,
                    feature_id => create_ch_feature(
                        doc        => $doc,
                        uniquename => $tt->{funame},
                        genus      => $tt->{genus},
                        species    => $tt->{species},
                        type       => 'gene',
                    ),
                    humanhealth_dbxref_id =>
                      create_ch_feature_humanhealth_dbxref(
                        doc            => $doc,
                        humanhealth_id => $unique,
                        dbxref_id      => create_ch_dbxref(
                            doc       => $doc,
                            db        => "HGNC",
                            accession => $tt->{acc},
                            version   => $tt->{version},
                        ),
                      ),
                    pub_id => $pub,
                );
                $feat_dbxref->setAttribute( 'op', 'delete' );
                $out .= dom_toString($feat_dbxref);
                $feat_dbxref->dispose();
            }
        }
        else {
            print STDERR
              "ERROR: HH7d No previous results for genes HH7e $unique $pub\n";
        }
    }
    if ( defined( $affgene{HH7e} ) && $affgene{HH7e} ne '' ) {
        print STDERR
"CHECK: first use of  HH7e HGNC humanhealth_dbxref and feature_humanhealth_dbxref\n";
        my $cat = 0;

        #check category
        if ( exists( $affgene{HH2a} ) && ( $affgene{HH2a} ne 'parent entity' ) )
        {
            $cat = 1;
        }
        else {
            my $category = &get_hh_category( $db, $unique );
            if ( $category ne 'parent entity' ) {
                $cat = 1;
            }
        }
        if ( $cat == 1 ) {
            print STDERR "DEBUG: HGNC accession in HH7e $affgene{HH7e}\n";
            my $sdbxref;
            my ( $dbn, $acc ) = split( /:/, $affgene{HH7e}, 2 );
            if ( !defined($dbn) && !defined($acc) ) {
                print STDERR "ERROR: wrong format for HH7e $affgene{HH7e}\n";
            }
            else {
                $dbn = trim($dbn);
                $acc = trim($acc);
                my $val = validate_dbname( $db, $dbn );
                if ( $val eq $dbn ) {
                    my $hhxref = $unique . $dbn . $acc;
                    $sdbxref = create_ch_humanhealth_dbxref(
                        doc            => $doc,
                        humanhealth_id => $unique,
                        dbxref_id      => create_ch_dbxref(
                            doc       => $doc,
                            db        => $dbn,
                            accession => $acc,
                            no_lookup => 1,
                        ),
                        macro_id => $hhxref,
                    );
                    my $fdp = create_ch_humanhealth_dbxrefprop(
                        doc    => $doc,
                        type   => $fptype,
                        cvname => "property type"
                    );
                    my $fdp2pub = create_ch_humanhealth_dbxrefprop_pub(
                        doc    => $doc,
                        pub_id => $pub
                    );
                    $fdp->appendChild($fdp2pub);
                    $sdbxref->appendChild($fdp);

                    #	      $out .= dom_toString($sdbxref);
                    if ( exists( $affgene{HH7c} ) && $affgene{HH7c} ne '' ) {

                        #	      my $value = $affgene{HH7c};
                        my $rank  = 0;
                        my @items = split( /\n/, $affgene{HH7c} );
                        foreach my $value (@items) {
                            $value =~ s/^\s+//;
                            $value =~ s/\s+$//;
                            print STDERR "DEBUG: gene in HH7c $value\n";
                            my $fdp2 = create_ch_humanhealth_dbxrefprop(
                                doc    => $doc,
                                type   => $fptype2,
                                cvname => "property type",
                                value  => $value,
                                rank   => $rank,
                            );
                            $rank++;
                            my $fdp2pub = create_ch_humanhealth_dbxrefprop_pub(
                                doc    => $doc,
                                pub_id => $pub,
                            );
                            $fdp2->appendChild($fdp2pub);
                            $sdbxref->appendChild($fdp2);
                        }
                    }
                    if ( defined( $affgene{HH7d} ) && $affgene{HH7d} ne '' ) {

              #just make a humanhealth_dbxrefprop that there are diopt orthologs
                        my $fdp3 = create_ch_humanhealth_dbxrefprop(
                            doc    => $doc,
                            type   => $fptype3,
                            cvname => "property type"
                        );
                        my $fdp2pub = create_ch_humanhealth_dbxrefprop_pub(
                            doc    => $doc,
                            pub_id => $pub
                        );
                        $fdp3->appendChild($fdp2pub);
                        $sdbxref->appendChild($fdp3);
                    }
                    $out .= dom_toString($sdbxref);
                    if ( defined( $affgene{HH7d} ) && $affgene{HH7d} ne '' ) {
                        my @items = split( /\n/, $affgene{HH7d} );
                        foreach my $item (@items) {
                            $item =~ s/^\s+//;
                            $item =~ s/\s+$//;
                            print STDERR "DEBUG: gene in HH7d $item\n";

                            ( $gene, $genus, $species ) =
                              get_feat_ukeys_by_name_type( $db, $item, 'gene' );
                            my $feature2 = create_ch_feature(
                                doc        => $doc,
                                uniquename => $gene,
                                type       => 'gene',
                                genus      => $genus,
                                species    => $species,
                            );

                            my $fr = create_ch_feature_humanhealth_dbxref(
                                doc                   => $doc,
                                humanhealth_dbxref_id => $hhxref,
                                feature_id            => $feature2,
                                pub_id                => $pub,
                            );
                            $out .= dom_toString($fr);
                        }
                    }
                }
                else {
                    print STDERR
                      "ERROR:HH7e no dbname found for $dbn in chado\n";
                }
            }
        }
        else {
            print STDERR
"ERROR:'parent entity' category not allowed for this field HH7a\n";
        }
    }
    return $out;
}

sub parse_dataset {
    my $unique  = shift;
    my $generef = shift;
    my $pub     = shift;
    my %affgene = %$generef;
    my $dbname  = '';
    my $dbxref  = '';
    my $descr   = '';
    my $out     = '';

    if ( defined( $affgene{"HH5a.upd"} ) && $affgene{'HH5a.upd'} eq 'c' ) {
        print STDERR "ERROR: !c not allowed for dbxref\n";
        return $out;
    }
    if ( ( defined( $affgene{HH5a} ) && $affgene{HH5a} ne '' )
        && $affgene{HH5d} eq 'y' )
    {
        print STDERR
"Action item: dissociate dbxref (data_link) $affgene{HH5b}:$affgene{HH5a} with Humanhealth $unique\n";
        if ( defined( $affgene{HH5b} ) && $affgene{HH5b} ne '' ) {
            my ( $dname, $acc, $ver ) =
              get_unique_key_for_humanhealth_dbxref_byprop( $db, $unique,
                $affgene{HH5b}, $affgene{HH5a}, "data_link" );
            if ( $dname eq "0" ) {
                print STDERR
"ERROR:cannot dissociate dbxref (data_link) $affgene{HH5b}:$affgene{HH5a} with HH $unique\n";
                return $out;
            }
            else {
                print STDERR
"in Humanhealth.pm Humanhealth $unique: db.name = $dname acc = $acc version = $ver\n";
                my $fd = create_ch_humanhealth_dbxref(
                    doc            => $doc,
                    humanhealth_id => $unique,
                    dbxref_id      => create_ch_dbxref(
                        doc       => $doc,
                        db        => $dname,
                        accession => $acc,
                        version   => $ver,
                    ),
                );
                $fd->setAttribute( 'op', 'delete' );
                $out .= dom_toString($fd);

                return $out;
            }
        }
        else {
            print STDERR
              "ERROR: HH5b required for dbxref with HH5a HH5d $unique\n";
            return $out;
        }
    }
    if ( defined( $affgene{HH5b} ) && $affgene{HH5b} ne '' ) {
        my $dbxref_dom = "";
        my $dbname     = validate_dbname( $db, $affgene{HH5b} );
        if ( $dbname ne '' ) {
            if ( $dbname eq "OMIM" || $dbname eq "OMIM_phenotype" ) {
                print STDERR
"ERROR: DB OMIM or OMIM_phenotype accessions not allowed ...\n";
                return $out;
            }
            print STDERR
              "DEBUG: found valid dbname = $dbname matches $affgene{HH5b}\n";

            #get accession
            if ( defined( $affgene{HH5a} ) && $affgene{HH5a} ne '' ) {
                my $val =
                  get_dbxref_by_db_dbxref( $db, $dbname, $affgene{HH5a} );
                if ( $val == -1 ) {
                    print STDERR
"ERROR: Multiple accessions in chado with  $affgene{HH5b} $affgene{HH5a}\n";
                }
                if ( $val == 0 ) {
                    $dbxref = $affgene{HH5a};

                    if ( exists( $fbdbs{ $dbname . $dbxref } ) ) {
                        $dbxref_dom = $fbdbs{ $dbname . $dbxref };
                        print STDERR
                          "DEBUG: exists $dbname.$dbxref in val= 0\n";

                    }
                    else {
                        print STDERR
"DEBUG: new accession in HH5a $affgene{HH5a} $affgene{HH5b}\n";
                        if ( defined( $affgene{HH5c} ) && $affgene{HH5c} ne '' )
                        {
                            print STDERR
"DEBUG: $dbname $affgene{HH5a} description HH5c $affgene{HH5c}\n";
                            $descr = $affgene{HH5c};
                        }
                        else {
                            $descr = $affgene{HH5a};
                        }
                        $dbxref_dom = create_ch_dbxref(
                            doc         => $doc,
                            accession   => $dbxref,
                            db          => $dbname,
                            version     => '1',
                            description => $descr,
                            macro_id    => $dbname . $dbxref,
                            no_lookup   => 1
                        );
                        $fbdbs{ $dbname . $dbxref } = $dbname . $dbxref;
                        $out .= dom_toString($dbxref_dom);
                    }
                    my $fd = create_ch_humanhealth_dbxref(
                        doc            => $doc,
                        humanhealth_id => $unique,
                        dbxref_id      => $dbxref_dom
                    );
                    my $fdp = create_ch_humanhealth_dbxrefprop(
                        doc    => $doc,
                        type   => "data_link",
                        cvname => "property type"
                    );
                    my $fdp2pub = create_ch_humanhealth_dbxrefprop_pub(
                        doc    => $doc,
                        pub_id => $pub
                    );
                    $fdp->appendChild($fdp2pub);
                    $fd->appendChild($fdp);

                    $out .= dom_toString($fd);
                }
                elsif ( $val == 1 ) {

                    $dbxref = $affgene{HH5a};
                    if ( exists( $fbdbs{ $dbname . $dbxref } ) ) {
                        $dbxref_dom = $dbname . $dbxref;
                        print STDERR
                          "DEBUG: exists $dbname.$dbxref in val= 1\n";

                    }
                    else {
                        print STDERR
                          "DEBUG: accession in HH5a $affgene{HH5a} found\n";
                        my $version = &get_version_from_dbxref( $db, $dbname,
                            $affgene{HH5a} );
                        if ( $version eq "0" ) {
                            print STDERR
"ERROR: Multiple accessions in chado with  $affgene{HH5b} $affgene{HH5a} need to know version\n";
                        }
                        else {

                            if ( defined( $affgene{HH5c} )
                                && $affgene{HH5c} ne '' )
                            {
                                print STDERR
"WARN: $dbname.$affgene{HH5a} exists HH5c $affgene{HH5c} will be ignored\n";
                            }
                            $dbxref_dom = create_ch_dbxref(
                                doc       => $doc,
                                accession => $dbxref,
                                db        => $dbname,
                                version   => $version,
                                macro_id  => $dbname . $dbxref,
                            );
                            $fbdbs{ $dbname . $dbxref } = $dbname . $dbxref;
                            $out .= dom_toString($dbxref_dom);
                        }
                    }
                    my $fd = create_ch_humanhealth_dbxref(
                        doc            => $doc,
                        humanhealth_id => $unique,
                        dbxref_id      => $dbxref_dom
                    );

                    my $fdp = create_ch_humanhealth_dbxrefprop(
                        doc    => $doc,
                        type   => "data_link",
                        cvname => "property type"
                    );
                    my $fdp2pub = create_ch_humanhealth_dbxrefprop_pub(
                        doc    => $doc,
                        pub_id => $pub
                    );
                    $fdp->appendChild($fdp2pub);
                    $fd->appendChild($fdp);

                    $out .= dom_toString($fd);
                }
            }
            else {
                print STDERR "ERROR: NO accession in HH5a $affgene{HH5a} \n";
            }
        }
        else {
            print STDERR
              "ERROR: NO dbname found for $affgene{HH5b} -- create DB first\n";
        }
    }
    return $out;
}

sub parse_dataset_bdsc {
    my $unique  = shift;
    my $generef = shift;
    my $pub     = shift;
    my %affgene = %$generef;
    my $dbname  = '';
    my $dbxref  = '';
    my $descr   = '';
    my $out     = '';

    if ( defined( $affgene{"HH14a.upd"} ) && $affgene{'HH14a.upd'} eq 'c' ) {
        print STDERR "ERROR: !c not allowed for dbxref\n";
    }
    if ( ( defined( $affgene{HH14a} ) && $affgene{HH14a} ne '' )
        && $affgene{HH14d} eq 'y' )
    {
        print STDERR
"Action item: dissociate dbxref (data_link) $affgene{HH14b}:$affgene{HH14a} with Humanhealth $unique\n";
        if ( defined( $affgene{HH14b} ) && $affgene{HH14b} ne '' ) {
            my ( $dname, $acc, $ver ) =
              get_unique_key_for_humanhealth_dbxref_byprop( $db, $unique,
                $affgene{HH14b}, $affgene{HH14a}, "data_link_bdsc" );
            if ( $dname eq "0" ) {
                print STDERR
"ERROR:cannot dissociate dbxref (data_link) $affgene{HH14b}:$affgene{HH14a} with HH $unique\n";
                return $out;
            }
            else {
                print STDERR
"in Humanhealth.pm Humanhealth $unique: db.name = $dname acc = $acc version = $ver\n";
                my $fd = create_ch_humanhealth_dbxref(
                    doc            => $doc,
                    humanhealth_id => $unique,
                    dbxref_id      => create_ch_dbxref(
                        doc       => $doc,
                        db        => $dname,
                        accession => $acc,
                        version   => $ver,
                    ),
                );
                $fd->setAttribute( 'op', 'delete' );
                $out .= dom_toString($fd);

                return $out;
            }
        }
        else {
            print STDERR
              "ERROR: HH14b required for dbxref with HH14a HH14d $unique\n";
            return $out;
        }
    }
    if ( defined( $affgene{HH14b} ) && $affgene{HH14b} ne '' ) {
        my $dbxref_dom = "";
        my $dbname     = validate_dbname( $db, $affgene{HH14b} );
        if ( $dbname ne '' ) {
            print STDERR
              "DEBUG: found valid dbname = $dbname matches $affgene{HH14b}\n";

            #get accession
            if ( defined( $affgene{HH14a} ) && $affgene{HH14a} ne '' ) {
                my $val =
                  get_dbxref_by_db_dbxref( $db, $dbname, $affgene{HH14a} );
                if ( $val == -1 ) {
                    print STDERR
"ERROR: Multiple accessions in chado with  $affgene{HH14b} $affgene{HH14a}\n";
                }

                if ( $val == 0 ) {
                    $dbxref = $affgene{HH14a};

                    if ( exists( $fbdbs{ $dbname . $dbxref } ) ) {
                        $dbxref_dom = $fbdbs{ $dbname . $dbxref };
                        print STDERR
                          "DEBUG: exists $dbname.$dbxref in val= 0\n";

                    }
                    else {
                        print STDERR
"DEBUG: new accession in HH14a $affgene{HH14a} $affgene{HH14b}\n";
                        if ( defined( $affgene{HH14c} )
                            && $affgene{HH14c} ne '' )
                        {
                            print STDERR
"DEBUG: $dbname $affgene{HH14a} description HH14c $affgene{HH14c}\n";
                            $descr = $affgene{HH14c};
                        }
                        else {
                            $descr = $affgene{HH14a};
                        }
                        $dbxref_dom = create_ch_dbxref(
                            doc         => $doc,
                            accession   => $dbxref,
                            db          => $dbname,
                            version     => '1',
                            description => $descr,
                            macro_id    => $dbname . $dbxref,
                            no_lookup   => 1
                        );
                        $fbdbs{ $dbname . $dbxref } = $dbname . $dbxref;
                        $out .= dom_toString($dbxref_dom);
                    }
                    my $fd = create_ch_humanhealth_dbxref(
                        doc            => $doc,
                        humanhealth_id => $unique,
                        dbxref_id      => $dbxref_dom
                    );
                    my $fdp = create_ch_humanhealth_dbxrefprop(
                        doc    => $doc,
                        type   => "data_link_bdsc",
                        cvname => "property type"
                    );
                    my $fdp2pub = create_ch_humanhealth_dbxrefprop_pub(
                        doc    => $doc,
                        pub_id => $pub
                    );
                    $fdp->appendChild($fdp2pub);
                    $fd->appendChild($fdp);

                    $out .= dom_toString($fd);
                }
                elsif ( $val == 1 ) {

                    $dbxref = $affgene{HH14a};
                    if ( exists( $fbdbs{ $dbname . $dbxref } ) ) {
                        $dbxref_dom = $dbname . $dbxref;
                        print STDERR
                          "DEBUG: exists $dbname.$dbxref in val= 1\n";

                    }
                    else {
                        print STDERR
                          "DEBUG: accession in HH14a $affgene{HH14a} found\n";
                        my $version = &get_version_from_dbxref( $db, $dbname,
                            $affgene{HH14a} );
                        if ( $version eq "0" ) {
                            print STDERR
"ERROR: Multiple accessions in chado with  $affgene{HH14b} $affgene{HH14a} need to know version\n";
                        }
                        else {

                            if ( defined( $affgene{HH14c} )
                                && $affgene{HH14c} ne '' )
                            {
                                print STDERR
"WARN: $dbname.$affgene{HH14a} exists HH14c $affgene{HH14c} will be ignored\n";
                            }
                            $dbxref_dom = create_ch_dbxref(
                                doc       => $doc,
                                accession => $dbxref,
                                db        => $dbname,
                                version   => $version,
                                macro_id  => $dbname . $dbxref,
                            );
                            $fbdbs{ $dbname . $dbxref } = $dbname . $dbxref;
                            $out .= dom_toString($dbxref_dom);
                        }
                    }
                    my $fd = create_ch_humanhealth_dbxref(
                        doc            => $doc,
                        humanhealth_id => $unique,
                        dbxref_id      => $dbxref_dom
                    );

                    my $fdp = create_ch_humanhealth_dbxrefprop(
                        doc    => $doc,
                        type   => "data_link_bdsc",
                        cvname => "property type"
                    );
                    my $fdp2pub = create_ch_humanhealth_dbxrefprop_pub(
                        doc    => $doc,
                        pub_id => $pub
                    );
                    $fdp->appendChild($fdp2pub);
                    $fd->appendChild($fdp);

                    $out .= dom_toString($fd);
                }
            }
            else {
                print STDERR "ERROR: NO accession in HH14a $affgene{HH14a} \n";
            }
        }
        else {
            print STDERR
              "ERROR: NO dbname found for $affgene{HH14b} -- create DB first\n";
        }
    }
    return $out;
}

=head2 $pro->validate(%ph)

   validate the following:
   1. validate HH1f .
   2. If !c exists, check whether this record already exists in DB.

=cut

sub validate {
    my $self     = shift;
    my $tihash   = {@_};
    my %tival    = %$tihash;
    my $v_unique = '';

    print STDERR "validating HH ", $tival{HH1f}, "\n";

    if ( exists( $tival{HH1f} ) && ( $tival{HH1f} ne 'new' ) ) {
        validate_humanhealth_uname( $db, $tival{HH1f} );
    }

    foreach my $f ( keys %tival ) {
        if ( $f =~ /(.*)\.upd/ && !( $v_unique =~ /temp/ ) ) {
            $f = $1;
            if (   $f eq 'HH1g'
                || $f eq 'HH2a'
                || $f eq 'HH4a'
                || $f eq 'HH4b'
                || $f eq 'HH4g'
                || $f eq 'HH4h'
                || $f eq 'HH11a'
                || $f eq 'HH11b'
                || $f eq 'HH11c'
                || $f eq 'HH11d'
                || $f eq 'HH11e'
                || $f eq 'HH12a'
                || $f eq 'HH12b'
                || $f eq 'HH12c'
                || $f eq 'HH12d'
                || $f eq 'HH13a'
                || $f eq 'HH20' )
            {
                my $num =
                  get_unique_key_for_humanhealthprop( $db, $v_unique,
                    $fpr_type{$f}, $tival{pub} );
                if ( $num == 0 ) {
                    print STDERR "there is no previous record for $f field.\n";
                }
            }
        }
    }
    if ( $v_unique =~ /temp/ ) {
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

! HUMAN HEALTH MODEL PROFORMA   Version 1.13:  10 Nov 2015
!
! HH1f. Database ID for disease or health issue  :
! HH1b. Full name to use in database  :
! HH1g. Sub-datatype [disease, health-related process] :
!
! HH1c. OMIM phenotype symbol (internal comment) :
! HH1d. Symbol/name used in ref (free text)  :
! HH1e. Additional synonyms (free text)   :
!
! HH2a. Category [parent entity, sub-entity, specific entity, group entity] :
! HH2b. Parent entity (if HH2a = sub-entity)  :
! HH2c. OMIM phenotype number :
! HH2d. DOID  :
!
! HH3a. Action - rename this disease (HH1b is rename)  :
! HH3c. Action - delete disease record ("y"/blank)  :
! HH3d. Action - dissociate HH1f from FBrf ("y"/blank)  :
!
! HH15. Overview of Drosophila model (free text)  :
!
! HH4h. Description of process (free text) :
! HH4a. Description/Symptoms and phenotype (free text)  :
! HH4b. Description/Genetics (free text)  :
! HH4c. Description/Cellular phenotype and pathology (free text)  :
! HH4g. Description/Molecular information (free text)  :
!
! HH4d. GO term(s)  :
! HH4e. FB group/process  :
! HH4f. Related human health entity :
!
! HH5a. External link - accession number (repeat for multiple ) :
!      HH5b. External link - FB database ID (DB1a) :
!      HH5c. External link - title/description of specific accession :
!      HH5d. Action - dissociate accession specified in HH5a/HH5b from this human health model (blank/y) :
!
! HH6c. Ordered list of OMIM phenotype entries (sep. by returns) :
!
! HH7a. Human gene(s) implicated (FB symbol, Hsap\xxx) :
! HH7e. Human gene(s) implicated (HGNC accession number) :
!     HH7d. Orthologous Dmel gene(s) [usu. DIOPT] :
!     HH7c. Comments on orthologs (free text) :
! HH7b. Other mammalian genes used  (in FB as transgene) :
!
! HH8a. Dmel gene(s) implicated (repeat for multiple) :
!      HH8c. Comments on orthologs (free text) :
! HH8e. Synthetic gene(s) used (symbol used by FB) :
!
! HH10. Summary of experimental data (free text) :
!
! HH11b. Mammalian transgenics, heterologous rescue (free text) :
! HH11c. Mammalian transgenics, phenotype (free text) :
! HH11d. Mammalian transgenics, physical interactions (free text) :
! HH11e. Mammalian transgenics, interactions (free text) :
! HH11f. Mammalian transgenics, perturbations and treatments (free text) :
!
! HH12a. Dmel gene(s), relevant phenotypes (free text) :
! HH12c. Dmel gene(s), interactions (free text) :
! HH12d. Dmel gene(s), perturbations and treatments (free text) :
! HH12e. Dmel recombinant construct(s), phenotype or rescue (free text) :
!
! HH13a. Additional experimental info (free text) :
! HH13b. Proposed mechanisms (free text) :
!
! HH16a. Development of model ('y'/blank) :
! HH16b. Refinement of model ('y'/blank) :
! HH16c. Mechanism of disease-associated mutation ('y'/blank) :
! HH16d. Genetic interaction ('y'/blank) :
! HH16e. Physical interaction ('y'/blank) :
! HH16f. Subcellular phenotype or mechanism ('y'/blank) :
! HH16g. Role of post-translational modification ('y'/blank) :
! HH16h. Molecular mechanism ('y'/blank) :
! HH16i. Role of/in related molecular pathway ('y'/blank) :
! HH16j. Chemical perturbation/stressor ('y'/blank) :
! HH16k. Environmental perturbation/stressor ('y'/blank) :
! HH16l. Drug discovery/assessment ('y'/blank) :
!
! HH14a. External link to BDSC - page ID (repeat for multiple) :
!      HH14b. External link to BDSC - FB database ID (DB1a) :
!      HH14c. External link to BDSC - title/description of specific page :
!      HH14d. Action - dissociate accession specified in HH14a/HH14b from this human health model (blank/y) :
!
! HH20. Internal notes :
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

=head1 AUTHOR

Haiyan Zhang, E<lt>haiyan@morgan.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
