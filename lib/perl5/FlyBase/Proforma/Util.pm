package FlyBase::Proforma::Util;
use 5.008004;

use strict;
no strict 'refs'; # Calls made by &$ alot in here so allow.
use warnings;
use Carp qw(croak);
require Exporter;
use XML::DOM;
our @ISA = qw(Exporter);
use FlyBase::WriteChado;
use Bio::DB::GenBank;
use utf8;
use DBI;

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
# This allows declaration	use FlyBase::Proforma::TI ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = (
    'all' => [
        qw( %fbids %fprank %fbcheck $multipub_no %frnum %curator %fbdbs %fbdv %fbgrpms get_sffeat_ukeys_by_name get_feat_ukeys_by_name read_r3_r4_map
          read_r4_r5_map add_feature_residue trim delete_libraryprop_pub delete_cell_line_relationship
          get_phenotype_comparison get_environment_by_id get_genotype_by_id get_phenotype_by_id
          get_cvterm_obsolete_by_cv_cvterm utftog get_lib_ukeys_by_id get_cell_line_ukeys_by_id
          get_cvterm_by_id get_feat_ukeys_by_name_uname add_interaction_description
          get_feat_ukeys_by_uname get_feat_ukeys_by_name_type get_feat_ukeys_by_id get_int_ukeys_by_name
          get_feature_expressionprop_rank get_cvterm_for_library_cvterm get_cvterm_for_interaction_cvterm get_expression_for_library_expression
          get_expression_for_feature_expression get_cellprop_pub_nums
          get_libprop_pub_nums delete_libraryprop get_unique_key_for_interactionprop get_expression_for_interaction_expression
          get_rank_for_pubauthor get_dbxref_for_pub_dbxref validate_cvterm update_pub get_cell_line_by_interaction_pub
          get_max_pubprop_rank check_feature_synonym_is_current delete_pub write_tableprop write_table_synonyms
          validate_uname_name validate_cell_line_uname_name validate_new_name validate_new_gene_name get_ukeys_from_featureloc
          delete_interactionprop delete_interactionprop_pub write_interactionprop delete_feature_interactionprop
          get_library_dbxref_by_type get_library_dbxrefprop_rank get_dbname_by_description check_feature_synonym
          get_tempid dom_toString dissociate_with_pub dissociate_with_pub_fromlib dissociate_with_pub_frominteraction
          dissociate_with_pub_fromcell_line merge_records update_multipub get_feature_interactionprop_rank get_library_featureprop_rank
          get_unique_key_for_feature_interaction get_unique_key_for_library_dbxref_byprop  get_unique_key_for_grp_dbxref
          write_featureprop write_featureprop_cv write_feature_relationship get_fr_pub_nums get_cell_line_libraryprop_rank get_feat_int_pub_nums
          get_cell_line_ukeys_by_name get_cell_line_ukeys_by_name_uname get_cell_line_ukeys_by_uname_name check_gene_model get_unique_key_for_lr get_unique_key_for_clr
          delete_feature_relationship delete_featureprop get_fprop_pub_nums get_library_strainprop_rank get_library_expressionprop_rank
          delete_featureprop_pub delete_feature_relationship_pub get_current_symbol_by_name get_dbxref_by_db_dbxref
          delete_library_synonym delete_cell_line_synonym write_cell_lineprop get_max_cell_lineprop_rank
          delete_featureloc  write_feature_synonyms get_fr_id recon get_libname_by_uniquename
          get_organism_by_abbrev delete_feature_synonym decon convers conversupdown get_library_for_cell_line_library
          get_feature_cvtermprop_rank match_value_for_pubprop write_pubprop write_pubprop_withrank get_ranks_for_pubprop write_cell_line_relationship
          update_feature_synonym get_frprop_rank get_unique_key_for_fr get_version_from_dbxref add_db_description add_db_url add_db_urlprefix
          get_GenBank_acc get_cvterm_for_feature_cvterm_withprop get_type_from_pub validate_db_description validate_db_url validate_db_urlprefix
          get_cvterm_for_feature_cvterm get_unique_for_phendesc update_feature_genotype
          get_max_locgroup get_feat_ukeys_by_dbxref toutf create_doc_element get_library_by_interaction_pub
          get_name_by_uniquename get_cvterm_for_feature_cvterm_by_cvtermprop validate_new_dbname
          get_unique_key_for_featureprop get_unique_key_for_libraryprop get_unique_key_for_cell_lineprop
          check_al_with_fr_or_mutagen get_cv_by_cvterm get_organism_by_id get_type_by_id  get_cvterm_for_cell_line_cvterm
          get_unique_key_for_fr_by_feattype get_alleleof_gene get_pub_uniquename_by_miniref validate_go
          process_sequence_curation get_cell_line_by_library_pub get_symbol_by_name get_date_by_feature_cvterm
          get_dbxref_by_feature_db validate_name validate_uname get_current_name_by_synonym delete_genotype
          get_feature_pub get_featureprop get_feature_relationship get_feature_dbxref get_feature_by_cell_line_pub
          get_feature_synonym get_feature_cvterm get_featureloc get_max_featureprop_rank write_gene_dbxref write_allele_dbxref validate_dbname
          migrate_r5_location get_lib_ukeys_by_name get_dbname_by_url get_cell_line_ukeys_by_uname
          get_lib_ukeys_by_uname validate_lib_name write_library_synonyms delete_cell_lineprop_pub
          get_feature write_libraryprop get_dbxref get_featureloc_ukeys_bypub get_rank_for_cell_line_cvtermprop
          remove_featureprop_function get_relationship_gene delete_library_relationship_pub delete_cell_lineprop
          update_library_synonym get_lr_pub_nums  write_library_relationship write_cell_line_synonyms
          update_cell_line_synonym get_feat_ukeys_by_uname_type merge_library_records merge_cell_line_records
          get_feature_interaction_pub_nums delete_feature_interaction delete_feature_interaction_pub
          get_library_for_library_feature
          get_strain_ukeys_by_id validate_strain_name get_unique_key_for_snr get_snr_pub_nums get_strain_ukeys_by_uname
          write_strain_relationship get_strain_ukeys_by_name update_strain_synonym get_feature_for_strain_feature
          get_unique_key_for_strainprop get_strainprop_pub_nums delete_strainprop delete_strainprop_pub write_strainprop
          get_library_for_library_strain get_cvterm_for_strain_cvterm check_strain_synonym_is_current delete_strain_synonym
          merge_strain_records get_strainname_by_uniquename dissociate_with_pub_fromstrain delete_strain_relationship
          get_max_strainprop_rank get_strain_for_library_strain get_strain_featureprop_rank check_strain_synonym
          get_uniquename_by_name get_cvterm_id_by_name_cv get_max_feature_cvtermprop_rank get_intprop_pub_nums
          get_cvterm_by_dbxref get_cv_cvterm_by_dbxref get_humanhealth_ukeys_by_id validate_humanhealth_name
          get_unique_key_for_hhr get_hhr_pub_nums get_humanhealth_ukeys_by_uname get_unique_key_for_humanhealth_featureprop
          delete_humanhealth_featureprop write_humanhealth_relationship get_humanhealth_ukeys_by_name update_humanhealth_synonym
          get_feature_for_humanhealth_feature get_humanhealth_feature get_unique_key_for_humanhealthprop get_unique_key_for_humanhealth_dbxref_byprop
          get_dbxref_for_humanhealth_dbxrefprop get_unique_key_for_humanhealth_dbxrefprop get_humanhealth_dbxrefprop_pub_nums
          delete_humanhealth_dbxrefprop delete_humanhealth_dbxrefprop_pub get_humanhealthprop_pub_nums delete_humanhealthprop
          delete_humanhealthprop_pub write_humanhealthprop get_library_for_library_humanhealth get_cvterm_for_humanhealth_cvterm
          get_cvterm_for_humanhealth_cvterm_withprop check_humanhealth_synonym_is_current delete_humanhealth_synonym
          merge_humanhealth_records get_humanhealthname_by_uniquename get_feature_humanhealth_dbxref_by_pub
          dissociate_with_pub_fromhumanhealth delete_humanhealth_relationship get_max_humanhealthprop_rank
          get_humanhealth_for_library_humanhealth get_ukey_for_humanhealth_dbxref get_humanhealth_featureprop_rank
          check_humanhealth_synonym get_hh_category get_hh_sub_datatype get_dbxref_by_humanhealth_db
          get_num_for_humanhealth_pubprop get_grp_ukeys_by_uname validate_grp_uname_name delete_grp_synonym
          write_grp_synonyms update_grp_synonym check_grp_synonym_is_current check_grp_synonym get_cvterm_for_grp_cvterm_by_cvtermprop
          get_unique_key_for_grpprop get_grpprop_pub_nums delete_grpprop delete_grpprop_pub get_cvterm_for_grp_cvterm
          get_unique_key_for_grp_rel get_gr_pub_nums get_grp_ukeys_by_id get_grp_ukeys_by_name write_grp_relationship
          write_grpprop get_max_grpprop_rank delete_grp_relationship delete_grp_relationship_pub get_current_grp_name_by_synonym
          write_grpprop_cv get_grpmember_ukeys_by_grp get_grpmember_ukeys_by_grp_type dissociate_with_pub_fromgrp
          get_unique_key_for_feature_grpmember get_feature_grpmember_pub_nums delete_feature_grpmember delete_grp
          delete_feature_grpmember_pub get_organism_dbxref_by_db get_num_organism_dbxref get_num_organismprop
          delete_organismprop write_organismprop check_sp6_organismprop get_organism_ukeys check_abbrev
          check_common_name validate_new_organism get_max_organismprop_rank delete_organismprop_pub
          get_unique_key_for_organismprop get_organismprop_pub_nums check_library_synonym_for_title
          get_cvterm_by_webcv get_cvterm_for_library_cvterm_withprop get_unique_key_for_lr_object delete_library_relationship_alltype
          get_organism_for_organism_library get_feature_for_library_feature get_webcv_for_cvterm_cv
          get_unique_key_for_libraryprop_nopub get_clfeat_ukeys_by_name get_library_cvtermprop_rank get_unique_key_for_tool_dbxref
          get_unique_key_for_frp_by_feattype
          )
    ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.01';

#our $chr_arms = 'X,1,2,3,4,2R,2L,3R,3L';

our %fbids   = ();
##########################################################################
# name to uniquename
# Also used to hole the last 'new' temp number for FBxx
# NOTE: no type etc just straight name -> uniquename
##########################################################################

our %fbdbs   = ();
##########################################################################
# Used to check if dbxref wrttien to xml already or not.
# $fbdbs{$dbname.$dbxref}=$dbname.$dbxref; set after writing
# Used to check later if it need writing again
##########################################################################

our %fbgrpms = ();
##########################################################################
# Used to check if a group member already written to xml.
# $fbgrpms{$grpmember_key}=$grpmember_key;
##########################################################################
our $temp_id = 0;

our %frnum = ();
##########################################################################
# frnum only seems to be used with featureloc i.e. $frnum{$fb}{featureloc}
# on deletion this gets incremented for {uniquename}{type}{rank}
# but never used except for the feature loc?
##########################################################################

our %fprank;
##########################################################################
# fprank feature prop rank.
# i.e. $fprank{ $unique . $pub }{ $type_id . $value } = $rank;
# contains the current MAX rank for a feature pub prop
# unique is the uniquename
# type_id is the cvtern.name
# value is the prop value
#
# also used in locgroup $locgroup = $fprank{$fb}{locgroup}
##########################################################################

our %fbcheck             = ();
##########################################################################
# used to check is if name symbol/name has been used in a previous 
# proformae. Just gives a warning if it has already been used.
##########################################################################

our $multipub_no         = 0;
our %DecodeDefaultEntity = (
    '"' => "&quot;",
    ">" => "&gt;",
    "<" => "&lt;",
    "'" => "&apos;",
    "&" => "&amp;"
);
our $docindex = 0;
our $lindex   = 0;
my %lib_vector = (
    'TA',     'pOTB7',             'TB',      'pOTB7',
    'BK',     'pNB40',             'AF',      'pAD-GAL4-2.1',
    'CB',     'pCR4-T0P0',         'ST',      'pBluescript_SK(-)',
    'CK',     'pBluescript_SK(+)', 'GH',      'pOT2',
    'GM_pBS', 'pBluescript_SK(-)', 'GM_pOT2', 'pOT2',
    'HL_pBS', 'pBluescript_SK(-)', 'HL_pOT2', 'pOT2',
    'LD_pBS', 'pBluescript_SK(-)', 'LD_pOT2', 'pOT2',
    'LP',     'pOT2',              'SD',      'pOT2',
    'AT',     'pOTB7',             'RE',      'pFLC-I',
    'RH',     'pFLC-I',            'EK_EP',   'pCDNA-SK+',
    'EN',     'pBluescript_SK(-)', 'EC',      'pSport1-Tag21',
    'ESG01',  'pSport1-Tag21',     'IP',      'pOT2',
    'UT',     'pOTB7',             'BS',      'pBluescript_SK(-)'
);

my %vector = (
    'pSport1-Tag21',     'FBmc0002963',
    'pBluescript_SK(-)', 'FBmc0002981',
    'pFLC-I',            'FBmc0002961',
    'pCDNA-SK+',         'FBmc0002962',
    'pBluescript_SK(+)', 'FBmc0002980',
    'pOT2',              'FBmc0002959',
    'pOTB7',             'FBmc0002960',
    'pNB40',             'FBmc0002970',
    'pAD-GAL4-2.1',      'FBmc0002969',
    'pCR4-T0P0',         'FBmc0002968',

);

our %curator = (
    'ag',    'A. de Grey',        'cm',     'C. Mayes',
    'cy',    'C. Yamada',         'ds',     'D. Sutherland',
    'ew',    'E. Whitfield',      'gm',     'G. Millburn',
    'hb',    'H. Butler',         'kk',     'K. Knight',
    'ma',    'M. Ashburner',      'pl',     'P. Leyland',
    'pm',    'P. McQuilton',      'rc',     'R. Collins',
    'rd',    'R. Drysdale',       'rf',     'R. Foulger',
    'rs',    'R. Seal',           'rt',     'R. Collins',
    'sm',    'S. Marygold',       'st',     'S. Tweedie',
    'hp',    'H. J. Platero',     'xx',     'Generic Curator',
    '??',    'Unknown Curator',   'crosby', 'M. Crosby',
    'lc',    'M. Crosby',         'sian',   'L. Sian Gramates',
    'mr',    'M. Roark',          'andy',   'A. Schroeder',
    'susan', 'S. St.Pierre',      'bev',    'B. Matthews',
    'ss',    'S. St.Pierre',      'ra',     'R. Stefancsik',
    'km',    'K. Matthews',       'Bev',    'B. Matthews',
    'ajs',   'A. Schroeder',      'sr',     'S. Reeve',
    'gds',   'G. D. Santos',      'up',     'UniProtKB',
    'as',    'Author Submission', 'us',     'User Submission',
    'sb',    'S. Bunt',           'vfb',    'Virtual Fly Brain',
    'lp',    'L. Ponting',        'ha',     'H. Attrill',
    'pb',    'P. Baker',          'mc',     'M. Costa',
    'ga',    'G. Antonazzo',      'ar',     'A. Rey',
    'ct',    'C. Tabone',         'al',     'A. Larkin',
    'sf',    'S. Fexova',         'tj',     'T. Jones',
    'pu',    'P. Urbano',         'vt',     'V. Trovisco',
    'pg',    'P. Garapati',       'pt',     'Pub Tator',
    'jma',   'J. M. Agapite',     'cp',     'C. Pilgrim',
    'vj',    'V. Jenkins',        'sp',     'S. Pop',
    'ao',    'A. Ozturk-Colak',   'am',     'A. McLachlan',
    'tl',    'T. Lovato',         'dg',     'D. Goutte-Gattat',
    'rz',    'R. Zaru',
);

my $libs =
'RT,FG, RM, DM, BP, TB,RC,FI,TA,ESG01, AA,CK,AF,AM, BQ,AI,CB,AT,BS,EC,EK, EP,EN,GH,GM,HL, LD,LP, RE, RH, SD, UT, IP';

# Preloaded methods go here.
sub validate_lib_name {
    my $dbh  = shift;
    my $name = shift;

    # print STDERR $name,"\n";
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;
    $name = convers($name);
    $name = decon($name);
    my $statement = "select uniquename from library where name= E'$name' and
  library.is_obsolete='f'";

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $num = $nmm->rows;
    if ( $num != 0 ) {
        print STDERR "ERROR: name '$name' has been used in the Database\n";
        return 1;
    }
    $nmm->finish;
    return 0;
}

sub trim {
    my @s = @_;
    for (@s) { s/^\s+//; s/\s+$//; }
    return wantarray ? @s : $s[0];
}

sub validate_new_gene_name {
    my $dbh  = shift;
    my $name = shift;
    print STDERR $name, "\n";
    if ( defined( $fbids{$name} ) && $fbids{$name} =~ /temp/ ) {
        print STDERR "ERROR: name '$name' has been declared as new. \n";
    }
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;
    $name = convers($name);
    $name = decon($name);
    my $statement = "";
    $statement = "select uniquename from feature where name ilike ? and
  feature.is_obsolete='f' and uniquename ~ E'\^FBgn[0-9]+\$'";
    my $nmm = $dbh->prepare($statement);
    $nmm->bind_param( 1, $name );

    #    print STDERR "$statement\n";
    $nmm->execute;
    my $num = $nmm->rows;
    if ( $num != 0 ) {
        print STDERR "ERROR: name '$name' has been used in the Database\n";
        return 1;
    }
    $nmm->finish;
    return 0;
}

sub validate_new_name {
    my $dbh   = shift;
    my $name  = shift;
    my $table = shift;

    # print STDERR $name,"\n";
    if ( defined( $fbids{$name} ) && $fbids{$name} =~ /temp/ ) {
        print STDERR "ERROR: name '$name' has been declared as new. \n";
    }
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;
    $name = convers($name);
    $name = decon($name);
    my $statement = "";
    if (   defined($table)
        && ( $table ne "" )
        && ( ( $table ne 'interaction' ) && ( $table ne 'cell_line' ) ) )
    {
        $statement =
"select uniquename from $table where name= E'$name' and is_obsolete = false";
    }
    elsif ( defined($table) && ( $table ne "" ) && ( $table eq 'interaction' ) )
    {
        $statement =
"select uniquename from $table where uniquename= E'$name' and is_obsolete = false";
    }
    elsif ( defined($table) && ( $table ne "" ) && ( $table eq 'cell_line' ) ) {
        $statement = "select uniquename from $table where name= E'$name'";
    }
    else {
        $statement = "select uniquename from feature where name='$name' and
  feature.is_obsolete='f' and (uniquename ~ '\^FB[a-z][a-z][0-9]+\$' and uniquename !~ '\^FBog[0-9]+\$' )";
    }
    print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $num = $nmm->rows;
    if ( $num != 0 ) {
        print STDERR "ERROR: name '$name' has been used in the Database\n";
        return 1;
    }
    $nmm->finish;
    return 0;
}

sub validate_cell_line_uname_name {
    my $dbh   = shift;
    my $uname = shift;
    my $name  = shift;

    $uname =~ s/\\/\\\\/g;
    $uname =~ s/\'/\\\'/g;
    $name    = convers($name);
    my $aname   = decon($name);
    my $nameutf = toutf($name);
    my $statement ="
        SELECT distinct s.synonym_sgml
            FROM cell_line f, cell_line_synonym fs, synonym s, cv cv, cvterm cvt
            WHERE f.cell_line_id = fs.cell_line_id AND
                  fs.synonym_id = s.synonym_id AND
                  fs.is_current = 't' AND
                  cv.cv_id = cvt.cv_id AND
                  cv.name = 'synonym type' AND
                  cvt.name = 'symbol' AND
                  s.type_id = cvt.cvterm_id AND
                  f.uniquename = '$uname';";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $num = $nmm->rows;

    my ($symbol) = $nmm->fetchrow_array;
    $nmm->finish;
    if ( $symbol ne $nameutf && $symbol ne $name ) {
        print STDERR
          "ERROR: uniquename '$uname' and name '$name' do not match\n ";
        return 0;
    }
    return 1;
}

sub validate_uname_name {
    my $dbh   = shift;
    my $uname = shift;
    my $name  = shift;

    $uname =~ s/\\/\\\\/g;
    $uname =~ s/\'/\\\'/g;
    $name    = convers($name);
    my $aname   = decon($name);
    my $nameutf = toutf($name);
    my $statement = <<"SYNONYM_SQL";
        SELECT DISTINCT s.synonym_sgml
            FROM feature f, feature_synonym fs, synonym s ,cvterm
            WHERE f.is_obsolete='f' AND
                  f.feature_id=fs.feature_id AND
                  fs.synonym_id=s.synonym_id AND
                  fs.is_current='t' AND
                  s.type_id=cvterm.cvterm_id AND
                  cvterm.name='symbol' AND
                  f.uniquename='$uname';
SYNONYM_SQL

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $num = $nmm->rows;

    my ($symbol) = $nmm->fetchrow_array;
    if ( $symbol ne $nameutf && $symbol ne $name ) {
        print STDERR
          "ERROR: uniquename '$uname' and name '$name' do not match\n ";
        return 0;
    }
    else {
        return 1;
    }
    $nmm->finish;
}

sub validate_new_dbname {
    my $dbh  = shift;
    my $name = shift;

    print STDERR "in validate_new_dbname $name\n";
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;
    $name = convers($name);
    $name = decon($name);
    my $statement = "select name from db where name= E'$name'";

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $num = $nmm->rows;
    if ( $num != 0 ) {
        print STDERR "ERROR: name '$name' has been used in the Database\n";
        return 1;
    }
    $nmm->finish;
    return 0;
}

sub validate_cvterm {
    my $dbh    = shift;
    my $cvterm = shift;
    my $cv     = shift;

    $cvterm =~ s/\\/\\\\/g;
    $cvterm =~ s/\'/\\\'/g;
    my $statement =
"select cv.name from cvterm, cv where cvterm.cv_id=cv.cv_id and cvterm.name= E'$cvterm' and cvterm.is_obsolete = 0";
    if ( defined($cv) ) {
        $statement .= " and cv.name='$cv'";
    }

    #        print STDERR "CHECK: $statement\n ";

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $n_cv = $nmm->fetchrow_array;

    if ( !defined($n_cv) ) {
        if ( defined($cv) ) {
            print STDERR "ERROR: could not find $cvterm, $cv in DB\n";
        }
        else {
            print STDERR "ERROR: could not find cvterm $cvterm in DB\n";
        }
        return 0;
    }
    elsif ( defined($cv) && ( $cv ne $n_cv ) ) {
        print STDERR "ERROR: could not find $cvterm, $cv in DB\n";
        return 0;
    }
    return 1;
}

sub validate_name {
    my $dbh  = shift;
    my $name = shift;
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;
    my $statement = "select uniquename from feature where name= E'$name'";
    my $nmm       = $dbh->prepare($statement);
    $nmm->execute;
    my $n_cv = $nmm->fetchrow_array;

    if ( !defined($n_cv) ) {
        print STDERR "ERROR: could not find feature name as $name in DB\n";
    }
}

sub validate_uname {
    my $dbh       = shift;
    my $name      = shift;
    my $statement = "select uniquename from feature where uniquename='$name'";
    my $nmm       = $dbh->prepare($statement);
    $nmm->execute;
    my $n_cv = $nmm->fetchrow_array;
    if ( !defined($n_cv) ) {
        print STDERR
          "ERROR: could not find feature uniquename as $name in DB\n";
    }
}

sub check_gene_model {
    my $dbh  = shift;
    my $name = shift;
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;

#print STDERR "ERROR: first use of function check_gene_model, check!  if have errors, comment out this function in Gene.pm\n";
    my $statement = "select featureloc.* from featureloc,feature where
	featureloc.feature_id=feature.feature_id and
	feature.name='$name';";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $num = $nmm->rows;
    if ( $num == 0 ) {
        print STDERR
          "ERROR, there is no feature location for this gene model $name\n";
    }
}

sub remove_featureprop_function {
    my $dbh    = shift;
    my $doc    = shift;
    my $unique = shift;
    my $type   = shift;
    my $pub    = shift;
    my $cv     = shift;
    my $out    = '';
    if ( !defined($cv) ) {
        $cv = 'property type';
    }
    my @results =
      get_unique_key_for_featureprop( $dbh, $unique, $type, $pub, $cv );
    foreach my $t (@results) {
        my $num = get_fprop_pub_nums( $dbh, $t->{fp_id} );
        if ( $num == 1 ) {
            $out .= delete_featureprop( $doc, $t->{rank}, $unique, $type, $cv );
        }
        elsif ( $num > 1 ) {
            $out .= delete_featureprop_pub( $doc, $t, $unique, $type, $pub );
        }
        else {
            print STDERR "ERROR: something Wrong, please validate first\n";
        }
    }
    return $out;
}

sub get_date_by_feature_cvterm {
    my $dbh    = shift;
    my $unique = shift;
    my $cvterm = shift;
    my $cv     = shift;
    my $pub    = shift;
    $cvterm =~ s/\\/\\\\/g;
    $cvterm =~ s/\'/\\\'/g;
    my $statement =
"select fcvprop.value from feature_cvtermprop fcvprop, feature_cvterm fcv, 
    feature f, cvterm, cv, pub where
    fcvprop.type_id=95386 and fcvprop.feature_cvterm_id=fcv.feature_cvterm_id and fcv.feature_id=f.feature_id and fcv.cvterm_id=cvterm.cvterm_id and cvterm.cv_id=cv.cv_id and cvterm.name= E'$cvterm' and cv.name='$cv' and fcv.pub_id=pub.pub_id and pub.uniquename='$pub' and f.uniquename='$unique'";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $date = $nmm->fetchrow_array;

    return $date;
}

sub process_sequence_curation {
    my $dbh    = shift;
    my $doc    = shift;
    my $unique = shift;
    my $line   = shift;
    my $out    = "";
    my $ntacc  = '';
    my $ntver  = 1;
    my @items  = split( /;/, $line );

    my $nt = shift(@items);

    #   print STDERR "ERROR: $nt\n";
    $nt =~ s/^\s+//;
    $nt =~ s/\s+$//;
    if ( $nt =~ /(.*)\.(\d+)/ ) {
        $ntacc = $1;
        $ntver = $1;
        $out .= dom_toString(
            create_ch_feature_dbxref(
                doc        => $doc,
                feature_id => $unique,
                dbxref_id  => create_ch_dbxref(
                    doc       => $doc,
                    db        => 'GB',
                    accession => $ntacc,
                    version   => $ntver,
                    no_lookup => 1
                )
            )
        );
    }
    else {
        my ( $d_g, $d_s, $d_t ) = get_feat_ukeys_by_uname( $dbh, $nt );
        if ( $d_g eq '0' ) {
            my $gb    = new Bio::DB::GenBank;
            my $query = Bio::DB::Query::GenBank->new(
                -query => $nt,
                -db    => 'nucleotide'
            );
            my $seqio = $gb->get_Stream_by_query($query);
            while ( my $seq = $seqio->next_seq ) {
                print STDERR "in ", $seq->accession, "\n";
                if ( defined($seq) && $seq->accession eq $nt ) {
                    my $newname  = '';
                    my $seqname  = '';
                    my $keywords = join( ';', $seq->get_keywords() );
                    $ntver = $seq->version;
                    $d_g   = $seq->species->genus;
##kludge entrez returning Sophophora for Drosophila
                    if ( $d_g eq 'Sophophora' ) {
                        print STDERR
"CHECK:Kludge Entrez returned Sophophora -- still want Drosophila \n";
                        $d_g = 'Drosophila';
                    }
                    $d_s = $seq->species->species;
                    if ( $keywords =~ /CDNA/ || $keywords =~ /HTC/ ) {
                        $d_t = 'cDNA';
                    }
                    elsif ( $keywords =~ /EST/ ) {
                        $d_t = 'EST';
                    }
                    else {
                        $d_t = 'mRNA';
                    }
                    my $feature = create_ch_feature(
                        doc        => $doc,
                        uniquename => $nt,
                        name       => $nt,
                        genus      => $d_g,
                        species    => $d_s,
                        type       => $d_t,
                        macro_id   => $nt,
                        no_lookup  => 1
                    );
                    $out .= dom_toString($feature);
                    $out .= dom_toString(
                        create_ch_feature_dbxref(
                            doc        => $doc,
                            feature_id => $unique,
                            dbxref_id  => create_ch_dbxref(
                                doc       => $doc,
                                db        => 'GB',
                                accession => $nt,
                                version   => $ntver,
                                macro_id  => $nt,
                                no_lookup => 1
                            )
                        )
                    );
                    $out .= dom_toString(
                        create_ch_feature_dbxref(
                            doc        => $doc,
                            feature_id => $nt,
                            dbxref_id  => $nt
                        )
                    );
                }
            }
        }
        elsif ( $d_g ne '0' && $d_g ne '2' ) {
            my $statement =
              "select max(version) from dbxref where accession='$nt'";
            my $nmm = $dbh->prepare($statement);
            $nmm->execute;
            my $ver = $nmm->fetchrow_array;
            if ( defined($ver) && $ver ne "" ) {
                $ntver = $ver;
            }
            $out .= dom_toString(
                create_ch_feature_dbxref(
                    doc        => $doc,
                    feature_id => $unique,
                    dbxref_id  => create_ch_dbxref(
                        doc       => $doc,
                        db        => 'GB',
                        accession => $nt,
                        version   => $ntver,
                        macro_id  => $nt,
                        no_lookup => 1
                    )
                )
            );
        }
        else {
            print STDERR "ERROR, $nt has more than two records in the DB\n";
        }
    }
    foreach my $item (@items) {
        print STDERR "ERROR: has not checked yet\n";
        $item =~ s/^\s+//;
        $item =~ s/\s+$//;
        if ( $item =~ /(.*)\.(\d+)/ ) {
            my $pracc = $1;
            my $prver = $2;
            $out .= dom_toString(
                create_ch_feature_dbxref(
                    doc        => $doc,
                    feature_id => $unique,
                    dbxref_id  => create_ch_dbxref(
                        doc       => $doc,
                        db        => 'GB_protein',
                        accession => $pracc,
                        version   => $prver
                    )
                )
            );
            my ( $p_g, $p_s, $p_t ) = get_feat_ukeys_by_uname( $dbh, $pracc );
            if ( $p_g ne '0' && $p_g ne '2' ) {
                my $feature = create_ch_feature(
                    doc        => $doc,
                    uniquename => $pracc,
                    genus      => $p_g,
                    species    => $p_s,
                    type       => $p_t,
                    macro_id   => $pracc
                );
                $out .= dom_toString($feature);
            }
            else {
                my $feature = create_ch_feature(
                    doc        => $doc,
                    uniquename => $pracc,
                    genus      => 'Drosophila',
                    species    => 'melanogaster',
                    type       => 'polypeptide',
                    macro_id   => $pracc,
                    no_lookup  => 1
                );
                $out .= dom_toString($feature);
            }
            $out .= dom_toString(
                create_ch_feature_dbxref(
                    doc        => $doc,
                    feature_id => $pracc,
                    dbxref_id  => create_ch_dbxref(
                        doc       => $doc,
                        db        => 'GB_protein',
                        accession => $pracc,
                        version   => $prver
                    )
                )
            );
            my $fr = create_ch_fr(
                doc        => $doc,
                subject_id => $pracc,
                object_id  => $ntacc,
                type       => 'protein_id_of'
            );
            $out .= dom_toString($fr);
        }
    }
    return $out;
}

sub get_dbxref_by_feature_db {
    my $dbh    = shift;
    my $unique = shift;
    my $db     = shift;
    my @result = ();
    my $statement =
"select dbxref.accession, dbxref.version from db, dbxref, feature, feature_dbxref
                    where feature_dbxref.feature_id=feature.feature_id and feature_dbxref.dbxref_id=dbxref.dbxref_id 
                    and db.db_id=dbxref.db_id and db.name='$db' and feature.uniquename='$unique';";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $acc, $ver ) = $nmm->fetchrow_array ) {
        my %tt = ();
        $tt{acc}     = $acc;
        $tt{version} = $ver;
        $tt{db}      = $db;
        push( @result, \%tt );
    }
    return @result;
}

sub update_pub {
    my $dbh    = shift;
    my $doc    = shift;
    my $unique = shift;
    my $old    = shift;
    my $out    = '';
    ###tables containing the pub
    ### expression_pub               | table | emmert
    ### feature_pub                  | table | emmert
    ### feature_pubprop              | table | emmert
    ### feature_relationship_pub     | table | emmert
    ### feature_relationshipprop_pub | table | emmert
    ### featureloc_pub               | table | emmert
    ### featuremap_pub               | table | emmert
    ### featureprop_pub              | table | emmert
    ### feature_cvterm
    ### feature_expression
    ### feature_interaction_pub
    ### feature_synonym
    ### phenstatement
    ### phenotype_comparison
    ### phendesc
    ### library_pub
    ### library_cvterm
    ### library_interaction
    ### library_relationship_pub
    ### library_synonym
    ### libraryprop_pub
    ### interaction_pub
    ### interaction_cvterm
    ### interaction_expression
    ### interaction_cell_line
    ### interactionprop_pub
    ### pub_relationship
    ### pub_prop
    ###todo
    ### organism_pub
    ### organism_cvterm
    ### organismprop_pub

    my $ep_stat =
"select feature_pub.feature_pub_id, feature.uniquename, feature.type_id, feature.organism_id from feature_pub, feature, pub where feature.feature_id=feature_pub.feature_id and feature_pub.pub_id=pub.pub_id and pub.uniquename='$old';";
    my $ep_nmm = $dbh->prepare($ep_stat);
    $ep_nmm->execute;
    while ( my ( $fp_id, $f_u, $f_t, $f_o ) = $ep_nmm->fetchrow_array ) {
        print STDERR "STATE: found pub in feature_pub for $old\n";
        my ( $fg, $fs ) = get_organism_by_id( $dbh, $f_o );
        my $ty      = get_cvterm_by_id( $dbh, $f_t );
        my $feature = create_ch_feature(
            doc        => $doc,
            uniquename => $f_u,
            type       => $ty,
            macro_id   => $f_u,
            genus      => $fg,
            species    => $fs
        );
        $out .= dom_toString($feature);
        my $fp = create_ch_feature_pub(
            doc        => $doc,
            feature_id => $f_u,
            pub_id     => $unique
        );
        my $fp_old = create_ch_feature_pub(
            doc        => $doc,
            feature_id => $f_u,
            pub_id     => $old
        );
        $fp_old->setAttribute( 'op', 'delete' );
        $out .= dom_toString($fp_old);
        my $fpp_stat =
"select value, type_id from feature_pubprop where feature_pub_id=$fp_id";
        my $fpp_nmm = $dbh->prepare($fpp_stat);
        $fpp_nmm->execute;

        while ( my ( $v, $t ) = $fpp_nmm->fetchrow_array ) {
            print STDERR "ERROR: found pub in feature_pubprop for $old\n";
            my $r = get_feature_pubprop_rank( $dbh, $f_u, $unique, $t, $v );
            my ( $cv, $cvname, $is ) = get_cvterm_ukeys_by_id( $dbh, $t );
            my $fpp = create_ch_feature_pubprop(
                doc   => $doc,
                value => $v,
                type_id =>
                  create_ch_cvterm( doc => $doc, cv => $cv, name => $cvname ),
                rank => $r
            );
            $fp->appendChild($fpp);
        }
        $out .= dom_toString($fp);
    }

    my $fr_stat =
"select fr.feature_relationship_id, fr.subject_id, fr.object_id, fr.type_id, fr.rank from feature_relationship fr, feature_relationship_pub frp, pub where fr.feature_relationship_id=frp.feature_relationship_id and frp.pub_id=pub.pub_id and pub.uniquename='$old';";
    my $fr_nmm = $dbh->prepare($fr_stat);
    $fr_nmm->execute;
    while ( my ( $fr_id, $s_id, $o_id, $fr_t, $rank ) =
        $fr_nmm->fetchrow_array )
    {
        print STDERR "STATE: found pub in feature_relationship for $old\n";
        my ( $s_u, $s_g, $s_s, $s_t ) = get_feat_ukeys_by_id( $dbh, $s_id );

        my ( $o_u, $o_g, $o_s, $o_t ) = get_feat_ukeys_by_id( $dbh, $o_id );
        if ( $s_u eq '0' || $o_u eq '0' ) {
            print STDERR "ERROR:features may be obsoleted. $s_id, $o_id\n";
        }
        my $fr = create_ch_fr(
            doc        => $doc,
            subject_id => create_ch_feature(
                doc        => $doc,
                uniquename => $s_u,
                genus      => $s_g,
                species    => $s_s,
                type       => $s_t
            ),
            object_id => create_ch_feature(
                doc        => $doc,
                uniquename => $o_u,
                genus      => $o_g,
                species    => $o_s,
                type       => $o_t
            ),
            rtype => get_cvterm_by_id( $dbh, $fr_t ),
            rank  => $rank
        );
        my $fr_pub    = create_ch_fr_pub( doc => $doc, pub_id => $unique );
        my $fr_pubold = create_ch_fr_pub( doc => $doc, pub_id => $old );
        $fr_pubold->setAttribute( 'op', 'delete' );
        $fr->appendChild($fr_pub);
        $fr->appendChild($fr_pubold);
        my $frp_stat =
"select frp.value, frp.rank, frp.type_id from feature_relationshipprop frp, feature_relationshipprop_pub frpp, pub where pub.uniquename='$old' and pub.pub_id=frpp.pub_id and frpp.feature_relationshipprop_id=frp.feature_relationshipprop_id and frp.feature_relationship_id=$fr_id";

        my $frp_nmm = $dbh->prepare($frp_stat);
        $frp_nmm->execute;
        while ( my ( $value, $rank, $t ) = $frp_nmm->fetchrow_array ) {
            print STDERR
              "STATE: found pub in feature_relationshipprop_pub for $old\n";
            my $frp = create_ch_frprop(
                doc   => $doc,
                value => $value,
                type  => get_cvterm_by_id( $dbh, $t ),
                rank  => $rank
            );
            my $frpp = create_ch_frprop_pub( doc => $doc, pub_id => $unique );
            $frp->appendChild($frpp);
            my $frpp_old = create_ch_frprop_pub( doc => $doc, pub_id => $old );
            $frpp_old->setAttribute( 'op', 'delete' );
            $frp->appendChild($frpp_old);
            $fr->appendChild($frp);
        }
        $out .= dom_toString($fr);
    }

    my $fl_stat =
"select featureloc.feature_id, featureloc.rank, featureloc.locgroup from featureloc,featureloc_pub,  pub where featureloc_pub.pub_id=pub.pub_id and pub.uniquename='$old' and featureloc.featureloc_id=featureloc_pub.featureloc_id;";
    my $fl_nmm = $dbh->prepare($fl_stat);
    $fl_nmm->execute;
    while ( my ( $f_id, $rank, $locgroup ) = $fl_nmm->fetchrow_array ) {
        print STDERR "STATE: found pub in feature_loc for $old\n";
        my ( $fu, $fg, $fs, $ft ) = get_feat_ukeys_by_id( $dbh, $f_id );
        if ( $fu eq '0' ) {
            print STDERR "ERROR: feature may be obsoleted $f_id\n";
        }
        my $fl = create_ch_featureloc(
            doc        => $doc,
            feature_id => create_ch_feature(
                doc        => $doc,
                uniquename => $fu,
                genus      => $fg,
                species    => $fs,
                type       => $ft
            ),
            rank     => $rank,
            locgroup => $locgroup
        );
        my $fl_pub = create_ch_featureloc_pub( doc => $doc, pub_id => $unique );
        $fl->appendChild($fl_pub);
        my $fl_old = create_ch_featureloc_pub( doc => $doc, pub_id => $old );
        $fl_old->setAttribute( 'op', 'delete' );
        $fl->appendChild($fl_old);
        $out .= dom_toString($fl);
    }
    my $fp_stat =
"select featureprop.featureprop_id, featureprop.feature_id, featureprop.value,featureprop.type_id, featureprop.rank from featureprop, featureprop_pub,  pub where featureprop_pub.pub_id=pub.pub_id and featureprop.featureprop_id=featureprop_pub.featureprop_id and pub.uniquename='$old';";
    my $fp_nmm = $dbh->prepare($fp_stat);
    $fp_nmm->execute;
    while ( my ( $fp_id, $f_i, $f_v, $f_t, $f_r ) = $fp_nmm->fetchrow_array ) {
        print STDERR "STATE: found pub in featureprop for $old\n";
        my ( $fu, $fg, $fs, $ft ) = get_feat_ukeys_by_id( $dbh, $f_i );
        if ( $fu eq '0' ) {
            print STDERR "ERROR: feature may be obsoleted $f_i\n";
        }
        my $featureprop = create_ch_featureprop(
            doc        => $doc,
            feature_id => create_ch_feature(
                doc        => $doc,
                uniquename => $fu,
                genus      => $fg,
                species    => $fs,
                type       => $ft
            ),
            rank => $f_r,
            type => get_cvterm_by_id( $dbh, $f_t )
        );
        my $fp_pub =
          create_ch_featureprop_pub( doc => $doc, pub_id => $unique );
        my $fp_pubold =
          create_ch_featureprop_pub( doc => $doc, pub_id => $old );
        $fp_pubold->setAttribute( 'op', 'delete' );
        $featureprop->appendChild($fp_pub);
        $featureprop->appendChild($fp_pubold);
        $out .= dom_toString($featureprop);
    }
    my $fs_stat =
"select feature_synonym.feature_id, feature_synonym.synonym_id, feature_synonym.is_current, feature_synonym.is_internal from feature_synonym,  pub where feature_synonym.pub_id=pub.pub_id and pub.uniquename='$old';";

    my $fs_nmm = $dbh->prepare($fs_stat);
    $fs_nmm->execute;
    while ( my ( $f_id, $s_id, $is_c, $is_i ) = $fs_nmm->fetchrow_array ) {
        print STDERR "STATE: found pub in feature_synonym for $old\n";
        my ( $fu, $fg, $fs, $ft ) = get_feat_ukeys_by_id( $dbh, $f_id );
        if ( $fu eq '0' ) {
            print STDERR "ERROR: feature may be obsoleted $f_id\n";
        }
        my ( $s_name, $s_t, $s_sgml ) = get_synonym_by_id( $dbh, $s_id );
        my $feat = create_ch_feature_synonym(
            doc        => $doc,
            feature_id => create_ch_feature(
                doc        => $doc,
                uniquename => $fu,
                genus      => $fg,
                species    => $fs,
                type       => $ft,
                macro_id   => $fu
            ),
            synonym_id => create_ch_synonym(
                doc          => $doc,
                name         => $s_name,
                type         => $s_t,
                synonym_sgml => $s_sgml,
                macro_id     => "synonym_" . $s_id
            ),
            pub_id => $old
        );
        $feat->setAttribute( 'op', 'delete' );
        $out .= dom_toString($feat);
        my $feat_syn = create_ch_feature_synonym(
            doc         => $doc,
            feature_id  => $fu,
            synonym_id  => "synonym_" . $s_id,
            pub_id      => $unique,
            is_current  => $is_c,
            is_internal => $is_i
        );
        $out .= dom_toString($feat_syn);
    }
    my $fc_stat =
"select feature_cvterm.feature_cvterm_id, feature_cvterm.feature_id,feature_cvterm.is_not, feature_cvterm.cvterm_id from feature_cvterm,  pub where feature_cvterm.pub_id=pub.pub_id and pub.uniquename='$old';";
    my $fc_nmm = $dbh->prepare($fc_stat);
    $fc_nmm->execute;
    while ( my ( $fc_id, $f_i, $is_not, $cv_id ) = $fc_nmm->fetchrow_array ) {

        #print STDERR "ERROR: found pub in feature_cvterm for $old\n";

        my ( $fu, $fg, $fs, $ft ) = get_feat_ukeys_by_id( $dbh, $f_i );
        if ( $fu eq '0' ) {
            print STDERR "ERROR: feature may be obsoleted $f_i\n";
        }
        my ( $cv, $cvterm, $is_o ) = get_cvterm_ukeys_by_id( $dbh, $cv_id );
        my $fcv = create_ch_feature_cvterm(
            doc        => $doc,
            feature_id => create_ch_feature(
                doc        => $doc,
                uniquename => $fu,
                genus      => $fg,
                species    => $fs,
                type       => $ft,
                macro_id   => $fu
            ),
            cvterm_id => create_ch_cvterm(
                doc         => $doc,
                cv          => $cv,
                name        => $cvterm,
                is_obsolete => $is_o,
                macro_id    => "cvterm_" . $cv_id
            ),
            pub_id => $unique
        );
        my $fcv_old = create_ch_feature_cvterm(
            doc        => $doc,
            feature_id => $fu,
            cvterm_id  => "cvterm_" . $cv_id,
            pub_id     => $old
        );
        $fcv_old->setAttribute( 'op', 'delete' );
        my $fcvp_stat =
"select type_id,value from feature_cvtermprop where feature_cvterm_id=$fc_id;";
        my $fcvp_nmm = $dbh->prepare($fcvp_stat);
        $fcvp_nmm->execute;

        while ( my ( $t, $v ) = $fcvp_nmm->fetchrow_array ) {

            # print STDERR "ERROR: found pub in feature_cvtermprop for $old\n";
            my ( $fp_cv, $fp_name, $is ) = get_cvterm_ukeys_by_id( $dbh, $t );
            my $r =
              get_feature_cvtermprop_rank( $dbh, $fu, $cv, $cvterm, $fp_name,
                $v, $unique );
            my $fcvp = create_ch_feature_cvtermprop(
                doc     => $doc,
                value   => $v,
                type_id => create_ch_cvterm(
                    doc         => $doc,
                    cv          => $fp_cv,
                    name        => $fp_name,
                    is_obsolete => $is
                ),
                rank => $r
            );
            $fcv->appendChild($fcvp);
        }
        $out .= dom_toString($fcv);
        $out .= dom_toString($fcv_old);
    }
    my $pd_stat =
"select genotype.uniquename, environment.uniquename, phendesc.type_id, phendesc.description from phendesc, genotype, environment, pub where phendesc.genotype_id=genotype.genotype_id and phendesc.environment_id=environment.environment_id and phendesc.pub_id=pub.pub_id and pub.uniquename='$old';";
    my $pd_nmm = $dbh->prepare($pd_stat);
    $pd_nmm->execute;
    while ( my ( $g_id, $e_id, $cv_id, $desc ) = $pd_nmm->fetchrow_array ) {
        print STDERR "STATE: found pub in phendesc for $old\n";
        my ( $cv, $cvterm, $is_o ) = get_cvterm_ukeys_by_id( $dbh, $cv_id );
        my $phen = create_ch_phendesc(
            doc => $doc,
            genotype_id =>
              create_ch_genotype( doc => $doc, uniquename => $g_id ),
            environment_id =>
              create_ch_environment( doc => $doc, uniquename => $e_id ),
            description => $desc,
            type_id     => create_ch_cvterm(
                doc         => $doc,
                cv          => $cv,
                name        => $cvterm,
                is_obsolete => $is_o
            ),
            pub_id => $unique
        );
        my $phen_old = create_ch_phendesc(
            doc => $doc,
            genotype_id =>
              create_ch_genotype( doc => $doc, uniquename => $g_id ),
            environment_id =>
              create_ch_environment( doc => $doc, uniquename => $e_id ),
            type_id => create_ch_cvterm(
                doc         => $doc,
                cv          => $cv,
                name        => $cvterm,
                is_obsolete => $is_o
            ),
            pub_id => $old
        );
        $phen_old->setAttribute( 'op', 'delete' );
        $out .= dom_toString($phen);
        $out .= dom_toString($phen_old);
    }
    my $ps_stat =
"select genotype.uniquename, environment.uniquename,phenotype.uniquename, phenstatement.type_id from phenstatement, genotype, phenotype, environment,  pub where phenstatement.genotype_id=genotype.genotype_id and phenotype.phenotype_id=phenstatement.phenotype_id and phenstatement.environment_id=environment.environment_id and phenstatement.pub_id=pub.pub_id and pub.uniquename='$old';";
    my $ps_nmm = $dbh->prepare($ps_stat);
    $ps_nmm->execute;
    while ( my ( $g_id, $e_id, $ph_id, $cv_id ) = $ps_nmm->fetchrow_array ) {
        print STDERR "STATE: found pub in phenstatement for $old\n";
        my ( $cv, $cvterm, $is_o ) = get_cvterm_ukeys_by_id( $dbh, $cv_id );
        my $phen = create_ch_phenstatement(
            doc => $doc,
            genotype_id =>
              create_ch_genotype( doc => $doc, uniquename => $g_id ),
            environment_id =>
              create_ch_environment( doc => $doc, uniquename => $e_id ),
            phenotype_id =>
              create_ch_phenotype( doc => $doc, uniquename => $ph_id ),
            type_id => create_ch_cvterm(
                doc         => $doc,
                cv          => $cv,
                name        => $cvterm,
                is_obsolete => $is_o
            ),
            pub_id => $unique
        );
        my $phen_old = create_ch_phenstatement(
            doc => $doc,
            genotype_id =>
              create_ch_genotype( doc => $doc, uniquename => $g_id ),
            environment_id =>
              create_ch_environment( doc => $doc, uniquename => $e_id ),
            phenotype_id =>
              create_ch_phenotype( doc => $doc, uniquename => $ph_id ),
            type_id => create_ch_cvterm(
                doc         => $doc,
                cv          => $cv,
                name        => $cvterm,
                is_obsolete => $is_o
            ),
            pub_id => $old
        );
        $phen_old->setAttribute( 'op', 'delete' );
        $out .= dom_toString($phen);
        $out .= dom_toString($phen_old);

    }
    my $pc_stat =
"select pc.phenotype_comparison_id,g1.uniquename, g2.uniquename, e1.uniquename, e2.uniquename, p.uniquename, p2.uniquename, pc.organism_id from phenotype_comparison pc, phenotype p, phenotype p2, genotype g1, genotype g2, environment e1, environment e2, pub where pc.genotype1_id=g1.genotype_id and pc.genotype2_id=g2.genotype_id and pc.environment1_id=e1.environment_id and pc.environment2_id=e2.environment_id and p.phenotype_id=pc.phenotype1_id and p2.phenotype_id=pc.phenotype2_id and pc.pub_id=pub.pub_id and pub.uniquename='$old';";
    my $pc_nmm = $dbh->prepare($pc_stat);
    $pc_nmm->execute;
    while (
        my ( $pc_id, $g1_id, $g2_id, $e1_id, $e2_id, $ph_id, $p2_id, $o_id ) =
        $pc_nmm->fetchrow_array )
    {
        #print STDERR "ERROR: found pub in phenotype_comparison for $old\n";
        my ( $g, $s ) = get_organism_by_id( $dbh, $o_id );
        my $phen = create_ch_phenotype_comparison(
            doc => $doc,
            genotype1_id =>
              create_ch_genotype( doc => $doc, uniquename => $g1_id ),
            genotype2_id =>
              create_ch_genotype( doc => $doc, uniquename => $g2_id ),
            environment1_id =>
              create_ch_environment( doc => $doc, uniquename => $e1_id ),
            environment2_id =>
              create_ch_environment( doc => $doc, uniquename => $e2_id ),
            phenotype1_id =>
              create_ch_phenotype( doc => $doc, uniquename => $ph_id ),
            phenotype2_id =>
              create_ch_phenotype( doc => $doc, uniquename => $p2_id ),
            organism_id =>
              create_ch_organism( doc => $doc, genus => $g, species => $s ),
            pub_id => $unique
        );
        my $phen_old = create_ch_phenotype_comparison(
            doc => $doc,
            genotype1_id =>
              create_ch_genotype( doc => $doc, uniquename => $g1_id ),
            genotype2_id =>
              create_ch_genotype( doc => $doc, uniquename => $g2_id ),
            environment1_id =>
              create_ch_environment( doc => $doc, uniquename => $e1_id ),
            environment2_id =>
              create_ch_environment( doc => $doc, uniquename => $e2_id ),
            phenotype1_id =>
              create_ch_phenotype( doc => $doc, uniquename => $ph_id ),
            pub_id => $old
        );
        $phen_old->setAttribute( 'op', 'delete' );
        my $sub =
"select cvterm_id, rank from phenotype_comparison_cvterm pcv where pcv.phenotype_comparison_id=$pc_id";
        my $sub_nmm = $dbh->prepare($sub);
        $sub_nmm->execute;

        while ( my ( $cv_id, $rank ) = $sub_nmm->fetchrow_array ) {
            my ( $cv, $cvterm, $is_o ) = get_cvterm_ukeys_by_id( $dbh, $cv_id );
            my $pcf = create_ch_phenotype_comparison_cvterm(
                doc       => $doc,
                cvterm_id => create_ch_cvterm(
                    doc         => $doc,
                    cv          => $cv,
                    name        => $cvterm,
                    is_obsolete => $is_o
                ),
                rank => $rank
            );
            $phen->appendChild($pcf);
        }
        $out .= dom_toString($phen);
        $out .= dom_toString($phen_old);
    }
    my $pp_stat =
"select value, pubprop.type_id from pubprop, pub where pubprop.pub_id=pub.pub_id and pub.uniquename='$old';";
    my $pp_nmm = $dbh->prepare($pp_stat);
    $pp_nmm->execute;
    while ( my ( $ppvalue, $pp_type ) = $pp_nmm->fetchrow_array ) {
        my ( $cv, $cvterm, $is_o ) = get_cvterm_ukeys_by_id( $dbh, $pp_type );
        my $rank    = get_max_pubprop_rank( $dbh, $unique, $cvterm, $ppvalue );
        my $pubprop = create_ch_pubprop(
            doc    => $doc,
            pub_id => $unique,
            value  => $ppvalue,
            rank   => $rank,
            type_id =>
              create_ch_cvterm( doc => $doc, name => $cvterm, cv => $cv )
        );
        $out .= dom_toString($pubprop);
    }

##new calls for new modules

    return $out;
}

sub get_phenotype_comparison {
    my $dbh      = shift;
    my $pub      = shift;
    my $id       = shift;
    my $organism = shift;
    my $field    = shift;
    my @list     = ();
    my $equal    = '=';
    my $add      = 'cvalue_id';
    if ( $field eq 'a' ) {
        $add = "observable_id";
    }
    elsif ( $field eq 'b' ) {
        $add = "cvalue_id";
    }
    if ( $field eq '1' ) {
        $equal = '=';
    }
    else {
        $equal = '!=';
    }
    my $statement =
"select distinct pc.* from phenotype_comparison pc, phenotype p1, feature f, feature_genotype fg, pub, cvterm, organism o where pc.phenotype1_id=p1.phenotype_id and p1.uniquename"
      . $equal
      . "'unspecified' and  pc.pub_id=pub.pub_id and pub.uniquename='$pub' and fg.feature_id=f.feature_id and   (fg.genotype_id=pc.genotype1_id or fg.genotype_id=pc.genotype2_id) and pc.organism_id=o.organism_id and o.species='$organism' and p1.$add=cvterm.cvterm_id and cvterm.name='unspecified'";

    #print STDERR $statement;
    my $pc_nmm = $dbh->prepare($statement);
    $pc_nmm->execute;
    while ( my $pc_hash = $pc_nmm->fetchrow_hashref ) {
        push( @list, $pc_hash );

    }
    return @list;
}

sub get_pub_by_id {
    my $dbh   = shift;
    my $id    = shift;
    my $p     = "select uniquename from pub where pub_id=$id";
    my $p_nmm = $dbh->prepare($p);
    $p_nmm->execute;
    my $u = $p_nmm->fetchrow_array;

    return $u;
}

sub update_multipub {
    my $dbh    = shift;
    my $doc    = shift;
    my $unique = shift;
    my $old    = shift;
    my $out    = '';
    my $p_r =
"select pr.subject_id, pr.object_id, pr.type_id from pub_relationship pr, pub where pub.pub_id=pr.subject_id and pub.uniquename='$old' union select pr.subject_id, pr.object_id, pr.type_id from pub_relationship pr, pub where pub.pub_id=pr.object_id and pub.uniquename='$old'";
    my $pr_nmm = $dbh->prepare($p_r);
    $pr_nmm->execute;

    while ( my ( $s_id, $o_id, $pr_t ) = $pr_nmm->fetchrow_array ) {
        my $sub = get_pub_by_id( $dbh, $s_id );
        if ( $sub eq $old ) {
            $sub = $unique;
        }

        my $obj = get_pub_by_id( $dbh, $o_id );
        if ( $obj eq $old ) {
            $obj = $unique;
        }
        my ( $cv, $cvterm, $is ) = get_cvterm_ukeys_by_id( $dbh, $pr_t );

        $out .= dom_toString(
            create_ch_pub_relationship(
                doc        => $doc,
                subject_id => create_ch_pub( doc => $doc, uniquename => $sub ),
                object_id  => create_ch_pub( doc => $doc, uniquename => $obj ),
                rtype_id   => create_ch_cvterm(
                    doc         => $doc,
                    cv          => $cv,
                    name        => $cvterm,
                    is_obsolete => $is
                )
            )
        );
    }

    my $p_p =
"select value, pubprop.type_id from pubprop, pub where pubprop.pub_id=pub.pub_id and pub.uniquename='$old'";
    my $pp_nmm = $dbh->prepare($p_p);
    $pp_nmm->execute;
    while ( my ( $value, $type_id ) = $pp_nmm->fetchrow_array ) {
        my ( $cv, $cvterm, $is ) = get_cvterm_ukeys_by_id( $dbh, $type_id );
        my $rank = get_max_pubprop_rank( $dbh, $unique, $cvterm, $value );

        $out .= dom_toString(
            create_ch_pubprop(
                doc     => $doc,
                pub_id  => $unique,
                value   => $value,
                type_id => create_ch_cvterm(
                    doc         => $doc,
                    name        => $cvterm,
                    cv          => $cv,
                    is_obsolete => $is
                ),
                rank => $rank
            )
        );

    }
    my $p_d =
"select is_current,accession, version, name from pub_dbxref, pub, dbxref, db where pub_dbxref.pub_id=pub.pub_id and pub.uniquename='$old' and dbxref.dbxref_id=pub_dbxref.dbxref_id and db.db_id=dbxref.db_id";
    my $pd_nmm = $dbh->prepare($p_d);
    $pd_nmm->execute;

    while ( my ( $is_c, $acc, $v, $name ) = $pd_nmm->fetchrow_array ) {
        if ( $name eq 'FlyBase' ) {
            $is_c = 'f';
        }

        my $pub_dbxref = create_ch_pub_dbxref(
            doc       => $doc,
            pub_id    => $unique,
            dbxref_id => create_ch_dbxref(
                doc       => $doc,
                accession => $acc,
                version   => $v,
                db_id     => create_ch_db( doc => $doc, name => $name )
            ),
            is_current => $is_c
        );
        $out .= dom_toString($pub_dbxref);
    }

    my $p_a =
"select editor, surname, givennames, suffix, rank from pubauthor, pub where pubauthor.pub_id=pub.pub_id and pub.uniquename='$old'";
    my $pa_nmm = $dbh->prepare($p_a);
    $pa_nmm->execute;

    while ( my ( $editor, $s, $g, $f, $r ) = $pa_nmm->fetchrow_array ) {

        #print STDERR "$editor, $s, $g,$f,$r\n";
        $out .= dom_toString(
            create_ch_pubauthor(
                doc        => $doc,
                editor     => $editor,
                surname    => $s,
                givennames => $g,
                suffix     => $f,
                rank       => $r,
                pub_id     => $unique
            )
        );
    }
    return $out;
}

sub delete_pub {
    my $dbh = shift;
    my $doc = shift;
    my $old = shift;
    my $out = '';
    ###tables containing the pub
    ### expression_pub
    ### feature_pub
    ### feature_pubprop
    ### feature_relationship_pub
    ### feature_relationshipprop_pub
    ### featureloc_pub
    ### featuremap_pub
    ### featureprop_pub
    ### library_pub
    ### feature_cvterm
    ### feature_synonym
    ### phenstatement
    ###phenotype_comparison
    ### phendesc
    ### library_pub
    ### todo
    ### organism_pub
    ### organism_cvterm
    ### organismprop_pub

    my $ep_stat =
"select feature_pub.feature_pub_id, feature.uniquename, feature.type_id, feature.organism_id from feature_pub, feature, pub where feature.feature_id=feature_pub.feature_id and feature_pub.pub_id=pub.pub_id and pub.uniquename='$old';";
    my $ep_nmm = $dbh->prepare($ep_stat);
    $ep_nmm->execute;
    while ( my ( $fp_id, $f_u, $f_t, $f_o ) = $ep_nmm->fetchrow_array ) {
        print STDERR "Warning: found pub in feature_pub for $old $f_u\n";
        my ( $fg, $fs ) = get_organism_by_id( $dbh, $f_o );
        my $ty      = get_cvterm_by_id( $dbh, $f_t );
        my $feature = create_ch_feature(
            doc        => $doc,
            uniquename => $f_u,
            type       => $ty,
            macro_id   => $f_u,
            genus      => $fg,
            species    => $fs
        );
        $out .= dom_toString($feature);
        my $fp_old = create_ch_feature_pub(
            doc        => $doc,
            feature_id => $f_u,
            pub_id     => $old
        );
        $fp_old->setAttribute( 'op', 'delete' );
        $out .= dom_toString($fp_old);
    }
    my $fr_stat =
"select fr.feature_relationship_id, fr.subject_id, fr.object_id, fr.type_id, fr.rank from feature_relationship fr, feature_relationship_pub frp, pub where fr.feature_relationship_id=frp.feature_relationship_id and frp.pub_id=pub.pub_id and pub.uniquename='$old';";
    my $fr_nmm = $dbh->prepare($fr_stat);
    $fr_nmm->execute;
    while ( my ( $fr_id, $s_id, $o_id, $fr_t, $rank ) =
        $fr_nmm->fetchrow_array )
    {

        my ( $s_u, $s_g, $s_s, $s_t ) = get_feat_ukeys_by_id( $dbh, $s_id );
        my ( $o_u, $o_g, $o_s, $o_t ) = get_feat_ukeys_by_id( $dbh, $o_id );
        if ( $s_u eq '0' || $o_u eq '0' ) {
            print STDERR "ERROR: feature may be obsoleted $s_u, $o_u\n";
        }
        print STDERR
"Warning: found pub in feature_relationship for $old, $fr_id,$s_u,$o_u,$fr_t\n";
        my $num = get_fr_pub_nums( $dbh, $fr_id );
        my $fr  = create_ch_fr(
            doc        => $doc,
            subject_id => create_ch_feature(
                doc        => $doc,
                uniquename => $s_u,
                genus      => $s_g,
                species    => $s_s,
                type       => $s_t
            ),
            object_id => create_ch_feature(
                doc        => $doc,
                uniquename => $o_u,
                genus      => $o_g,
                species    => $o_s,
                type       => $o_t
            ),
            rtype => get_cvterm_by_id( $dbh, $fr_t ),
            rank  => $rank
        );
        if ( $num == 1 ) {
            $fr->setAttribute( 'op', 'delete' );
        }
        elsif ( $num > 1 ) {
            my $fr_pubold = create_ch_fr_pub( doc => $doc, pub_id => $old );
            $fr_pubold->setAttribute( 'op', 'delete' );
            $fr->appendChild($fr_pubold);
            my $frp_stat =
"select frp.feature_relationshipprop_id, frp.value, frp.rank, frp.type_id from feature_relationshipprop frp, feature_relationshipprop_pub frpp, pub where pub.uniquename='$old' and pub.pub_id=frpp.pub_id and frpp.feature_relationshipprop_id=frp.feature_relationshipprop_id and frp.feature_relationship_id=$fr_id";

            my $frp_nmm = $dbh->prepare($frp_stat);
            $frp_nmm->execute;
            while ( my ( $frp_id, $value, $rank, $t ) =
                $frp_nmm->fetchrow_array )
            {
                print STDERR
"Warning: found pub in feature_relationshipprop_pub for $old $frp_id $value\n";
                my $frpnum = get_frp_pub_nums( $dbh, $frp_id );
                my $frp    = create_ch_frprop(
                    doc   => $doc,
                    value => $value,
                    type  => get_cvterm_by_id( $dbh, $t ),
                    rank  => $rank
                );
                if ( $frpnum == 1 ) {
                    $frp->setAttribute( 'op', 'delete' );
                }
                else {
                    my $frpp_old =
                      create_ch_frprop_pub( doc => $doc, pub_id => $old );
                    $frpp_old->setAttribute( 'op', 'delete' );
                    $frp->appendChild($frpp_old);
                }
                $fr->appendChild($frp);
            }
        }
        $out .= dom_toString($fr);
    }
    my $fl_stat =
"select featureloc.featureloc_id,featureloc.feature_id, featureloc.rank, featureloc.locgroup from featureloc,featureloc_pub,  pub where featureloc_pub.pub_id=pub.pub_id and pub.uniquename='$old' and featureloc.featureloc_id=featureloc_pub.featureloc_id;";
    my $fl_nmm = $dbh->prepare($fl_stat);
    $fl_nmm->execute;
    while ( my ( $fl_id, $f_id, $rank, $locgroup ) = $fl_nmm->fetchrow_array ) {
        my ( $fu, $fg, $fs, $ft ) = get_feat_ukeys_by_id( $dbh, $f_id );
        if ( $fu eq '0' ) {
            print STDERR "ERROR: feature may be obsoleted $f_id\n";
        }
        print STDERR "Warning: found pub in feature_loc for $old $fl_id, $fu\n";
        my $fl = create_ch_featureloc(
            doc        => $doc,
            feature_id => create_ch_feature(
                doc        => $doc,
                uniquename => $fu,
                genus      => $fg,
                species    => $fs,
                type       => $ft
            ),
            rank     => $rank,
            locgroup => $locgroup
        );
        my $flnum = get_featureloc_pub_nums( $dbh, $fl_id );
        if ( $flnum == 0 ) {
            print STDERR "ERROR: something wrong with delete_pub featureloc\n";
        }
        elsif ( $flnum == 1 ) {
            $fl->setAttribute( 'op', 'delete' );
        }
        else {
            my $fl_old =
              create_ch_featureloc_pub( doc => $doc, pub_id => $old );
            $fl_old->setAttribute( 'op', 'delete' );
            $fl->appendChild($fl_old);
        }
        $out .= dom_toString($fl);
    }
    my $fp_stat =
"select featureprop.featureprop_id, featureprop.feature_id, featureprop.value,featureprop.type_id, featureprop.rank from featureprop, featureprop_pub,  pub where featureprop_pub.pub_id=pub.pub_id and featureprop.featureprop_id=featureprop_pub.featureprop_id and pub.uniquename='$old';";
    my $fp_nmm = $dbh->prepare($fp_stat);
    $fp_nmm->execute;
    while ( my ( $fp_id, $f_i, $f_v, $f_t, $f_r ) = $fp_nmm->fetchrow_array ) {
        my ( $fu, $fg, $fs, $ft ) = get_feat_ukeys_by_id( $dbh, $f_i );
        if ( $fu eq '0' ) {
            print STDERR "ERROR: feature may be obsoleted $f_i\n";
        }
        my $fp_nums = get_fprop_pub_nums( $dbh, $fp_id );
        print STDERR "Warning: found pub in featureprop for $old $fu $f_v\n";
        my $featureprop = create_ch_featureprop(
            doc        => $doc,
            feature_id => create_ch_feature(
                doc        => $doc,
                uniquename => $fu,
                genus      => $fg,
                species    => $fs,
                type       => $ft
            ),
            rank => $f_r,
            type => get_cvterm_by_id( $dbh, $f_t )
        );
        if ( $fp_nums == 1 ) {
            $featureprop->setAttribute( 'op', 'delete' );
        }
        elsif ( $fp_nums > 1 ) {
            my $fp_pubold =
              create_ch_featureprop_pub( doc => $doc, pub_id => $old );
            $fp_pubold->setAttribute( 'op', 'delete' );

            $featureprop->appendChild($fp_pubold);
        }
        else {
            print STDERR "ERROR something wrong with delete_pub featureprop\n";
        }
        $out .= dom_toString($featureprop);
    }
    my $fs_stat =
"select feature_synonym.feature_id, feature_synonym.synonym_id, feature_synonym.is_current, feature_synonym.is_internal from feature_synonym,  pub where feature_synonym.pub_id=pub.pub_id and pub.uniquename='$old';";
    my $fs_nmm = $dbh->prepare($fs_stat);
    $fs_nmm->execute;
    while ( my ( $f_id, $s_id, $is_c, $is_i ) = $fs_nmm->fetchrow_array ) {
        my ( $fu, $fg, $fs, $ft ) = get_feat_ukeys_by_id( $dbh, $f_id );
        if ( $fu eq '0' ) {
            print STDERR "ERROR: feature may be obsoleted $f_id\n";
        }
        my ( $s_name, $s_t, $s_sgml ) = get_synonym_by_id( $dbh, $s_id );
        print STDERR
          "Warning: found pub in feature_synonym for $old $fu, $s_sgml,\n";
        my $feat = create_ch_feature_synonym(
            doc        => $doc,
            feature_id => create_ch_feature(
                doc        => $doc,
                uniquename => $fu,
                genus      => $fg,
                species    => $fs,
                type       => $ft,
                macro_id   => $fu
            ),
            synonym_id => create_ch_synonym(
                doc          => $doc,
                name         => $s_name,
                type         => $s_t,
                synonym_sgml => $s_sgml,
                macro_id     => "synonym_" . $s_id
            ),
            pub_id => $old
        );
        $feat->setAttribute( 'op', 'delete' );
        $out .= dom_toString($feat);
    }
    my $fc_stat =
"select feature_cvterm.feature_cvterm_id, feature_cvterm.feature_id,feature_cvterm.is_not, feature_cvterm.cvterm_id from feature_cvterm,  pub where feature_cvterm.pub_id=pub.pub_id and pub.uniquename='$old';";
    my $fc_nmm = $dbh->prepare($fc_stat);
    $fc_nmm->execute;
    while ( my ( $fc_id, $f_i, $is_not, $cv_id ) = $fc_nmm->fetchrow_array ) {
        my ( $fu, $fg, $fs, $ft ) = get_feat_ukeys_by_id( $dbh, $f_i );
        if ( $fu eq '0' ) {
            print STDERR "ERROR: feature may be obsoleted $f_i\n";
        }
        my ( $cv, $cvterm, $is_o ) = get_cvterm_ukeys_by_id( $dbh, $cv_id );
        print STDERR
"Warning: found pub in feature_cvterm for $fc_id $old $f_i $fu $cvterm\n";
        my $fcv_old = create_ch_feature_cvterm(
            doc        => $doc,
            feature_id => create_ch_feature(
                doc        => $doc,
                uniquename => $fu,
                genus      => $fg,
                species    => $fs,
                type       => $ft,
                macro_id   => $fu
            ),
            cvterm_id => create_ch_cvterm(
                doc         => $doc,
                cv          => $cv,
                name        => $cvterm,
                is_obsolete => $is_o,
                macro_id    => "cvterm_" . $cv_id
            ),
            pub_id => $old
        );
        $fcv_old->setAttribute( 'op', 'delete' );
        $out .= dom_toString($fcv_old);
    }
    my $pd_stat =
"select genotype.uniquename, environment.uniquename, phendesc.type_id from phendesc, genotype, environment, pub where phendesc.genotype_id=genotype.genotype_id and phendesc.environment_id=environment.environment_id and phendesc.pub_id=pub.pub_id and pub.uniquename='$old';";
    my $pd_nmm = $dbh->prepare($pd_stat);
    $pd_nmm->execute;
    while ( my ( $g_id, $e_id, $cv_id ) = $pd_nmm->fetchrow_array ) {
        print STDERR "Warning: found pub in phendesc for $old $g_id, \n";
        my ( $cv, $cvterm, $is_o ) = get_cvterm_ukeys_by_id( $dbh, $cv_id );
        my $phen_old = create_ch_phendesc(
            doc => $doc,
            genotype_id =>
              create_ch_genotype( doc => $doc, uniquename => $g_id ),
            environment_id =>
              create_ch_environment( doc => $doc, uniquename => $e_id ),
            type_id => create_ch_cvterm(
                doc         => $doc,
                cv          => $cv,
                name        => $cvterm,
                is_obsolete => $is_o
            ),
            pub_id => $old
        );
        $phen_old->setAttribute( 'op', 'delete' );
        $out .= dom_toString($phen_old);
    }
    my $ps_stat =
"select genotype.uniquename, environment.uniquename,phenotype.uniquename, phenstatement.type_id from phenstatement, genotype, phenotype, environment,  pub where phenstatement.genotype_id=genotype.genotype_id and phenotype.phenotype_id=phenstatement.phenotype_id and phenstatement.environment_id=environment.environment_id and phenstatement.pub_id=pub.pub_id and pub.uniquename='$old';";
    my $ps_nmm = $dbh->prepare($ps_stat);
    $ps_nmm->execute;
    while ( my ( $g_id, $e_id, $ph_id, $cv_id ) = $ps_nmm->fetchrow_array ) {
        print STDERR
          "Warning: found pub in phenstatement for $old $g_id, $e_id,$ph_id\n";
        my ( $cv, $cvterm, $is_o ) = get_cvterm_ukeys_by_id( $dbh, $cv_id );
        my $phen_old = create_ch_phenstatement(
            doc => $doc,
            genotype_id =>
              create_ch_genotype( doc => $doc, uniquename => $g_id ),
            environment_id =>
              create_ch_environment( doc => $doc, uniquename => $e_id ),
            phenotype_id =>
              create_ch_phenotype( doc => $doc, uniquename => $ph_id ),
            type_id => create_ch_cvterm(
                doc         => $doc,
                cv          => $cv,
                name        => $cvterm,
                is_obsolete => $is_o
            ),
            pub_id => $old
        );
        $phen_old->setAttribute( 'op', 'delete' );
        $out .= dom_toString($phen_old);

    }
    my $pc_stat =
"select pc.phenotype_comparison_id,g1.uniquename, g2.uniquename, e1.uniquename, e2.uniquename, p.uniquename from phenotype_comparison pc, phenotype p, genotype g1, genotype g2, environment e1, environment e2, pub where pc.genotype1_id=g1.genotype_id and pc.genotype2_id=g2.genotype_id and pc.environment1_id=e1.environment_id and pc.environment2_id=e2.environment_id and p.phenotype_id=pc.phenotype1_id and pc.pub_id=pub.pub_id and pub.uniquename='$old';";
    my $pc_nmm = $dbh->prepare($pc_stat);
    $pc_nmm->execute;
    while ( my ( $pc_id, $g1_id, $g2_id, $e1_id, $e2_id, $ph_id ) =
        $pc_nmm->fetchrow_array )
    {
        print STDERR
"Warning: found pub in phenotype_comparison for $old $pc_id $g1_id, $g2_id\n";
        my $phen_old = create_ch_phenotype_comparison(
            doc => $doc,
            genotype1_id =>
              create_ch_genotype( doc => $doc, uniquename => $g1_id ),
            genotype2_id =>
              create_ch_genotype( doc => $doc, uniquename => $g2_id ),
            environment1_id =>
              create_ch_environment( doc => $doc, uniquename => $e1_id ),
            environment2_id =>
              create_ch_environment( doc => $doc, uniquename => $e2_id ),
            phenotype_id =>
              create_ch_phenotype( doc => $doc, uniquename => $ph_id ),
            pub_id => $old
        );
        $out .= dom_toString($phen_old);
    }

    return $out;
}

sub get_feature_pubprop_rank {
    my $dbh     = shift;
    my $unique  = shift;
    my $pub     = shift;
    my $type_id = shift;
    my $value   = shift;
    my $rank;
    if ( defined($value) ) {
        $value =~ s/([\'\\\/\(\)])/\\$1/g;
    }
    if ( defined($value)
        && exists( $fprank{ $unique . $pub }{ $type_id . $value } ) )
    {
        return $fprank{ $unique . $pub }{ $type_id . $value };
    }
    elsif ( exists( $fprank{ $unique . $pub }{$type_id} ) ) {
        $fprank{ $unique . $pub }{$type_id} += 1;
        return $fprank{ $unique . $pub }{$type_id};
    }
    else {
        my $statement;
        if ( defined($value) ) {
            $statement =
"select rank from feature_pubprop, feature, pub, feature_pub where feature.feature_id=feature_pub.feature_id and pub.pub_id=feature_pub.pub_id and feature_pub.feature_pub_id=feature_pubprop.feature_pub_id and feature.uniquename='$unique' and pub.uniquename='$pub' and feature_pubprop.type_id=$type_id and value= E'$value';";

            my $nmm = $dbh->prepare($statement);
            $nmm->execute;
            $rank = $nmm->fetchrow_array;

        }
        if ( !defined($rank) ) {
            my $statement =
"select max(rank) from feature_pubprop, feature, pub, feature_pub where feature.feature_id=feature_pub.feature_id and pub.pub_id=feature_pub.pub_id and feature_pub.feature_pub_id=feature_pubprop.feature_pub_id and feature.uniquename='$unique' and pub.uniquename='$pub' and feature_pubprop.type_id=$type_id;";
            my $ff_nmm = $dbh->prepare($statement);
            $ff_nmm->execute;
            $rank = $ff_nmm->fetchrow_array;
            if ( !defined($rank) ) {
                $rank = 0;
                if ( defined($value) ) {
                    $fprank{ $unique . $pub }{ $type_id . $value } = 0;
                }
                $fprank{ $unique . $pub }{$type_id} = 0;
            }
            else {
                $fprank{ $unique . $pub }{$type_id} = $rank + 1;
                if ( defined($value) ) {
                    $fprank{ $unique . $pub }{ $type_id . $value } = $rank + 1;
                }
                $rank = $fprank{ $unique . $pub }{$type_id};
            }

        }
        else {
            $fprank{ $unique . $pub }{ $type_id . $value } = $rank;
        }
    }

    return $rank;
}

sub parse_bandc_feature_relationship {
    my $dbh     = shift;
    my $doc     = shift;
    my $subject = shift;
    my $object  = shift;
    my $unique  = shift;
    my $type    = shift;
    my $pub     = shift;
    my $out     = '';
    my @results =
      get_unique_key_for_fr( $dbh, $subject, $object, $unique, $type, $pub );

    foreach my $ta (@results) {
        my $num = get_fr_pub_nums( $dbh, $ta->{fr_id} );
        if ( $num == 1 ) {
            $out .=
              delete_feature_relationship( $dbh, $doc, $ta,
                $subject, $object, $unique, $type );
        }
        elsif ( $num > 1 ) {
            $out .=
              delete_feature_relationship_pub( $dbh, $doc,
                $ta, $subject, $object, $unique, $type, $pub );
        }
        else {
            print STDERR "ERROR: something Wrong, please validate first\n";
        }
    }
    return $out;
}

sub get_symbol_by_name {
    my $dbh    = shift;
    my $name   = shift;
    my $symbol = '';
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;
    my $statement = <<"SYM_NAME";
    SELECT synonym.synonym_sgml 
      FROM synonym, feature_synonym, feature, cvterm
      WHERE feature.name= E'$name' AND
            feature.feature_id=feature_synonym.feature_id AND
            synonym.synonym_id=feature_synonym.synonym_id AND
            feature_synonym.is_current='t' AND
            synonym.type_id=cvterm.cvterm_id AND
            cvterm.name="symbol";
SYM_NAME

    #print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    $symbol = $nmm->fetchrow_array;
    if ( !defined($symbol) ) {
        print STDERR "ERROR: Could not get symbol from the $name\n";
    }
    return $symbol;
}

sub get_cvterm_ukeys_by_id {
    my $dbh = shift;
    my $id  = shift;

    my $statement =
"select cv.name, cvterm.name, cvterm.is_obsolete  from cv , cvterm where cvterm.cvterm_id=$id and cvterm.cv_id=cv.cv_id";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my ( $name, $type, $sgml ) = $nmm->fetchrow_array;

    return ( $name, $type, $sgml );
}

sub get_synonym_by_id {
    my $dbh = shift;
    my $id  = shift;

    my $statement =
"select synonym.name, cvterm.name, synonym_sgml  from synonym , cvterm where cvterm.cvterm_id=synonym.type_id and synonym_id=$id";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my ( $name, $type, $sgml ) = $nmm->fetchrow_array;

    return ( $name, $type, $sgml );
}

sub get_libname_by_uniquename {
    my $dbh  = shift;
    my $name = shift;
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;
    my $statement = "select name from library where uniquename='$name'  and
  library.is_obsolete='f';";

    # print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $uni = $nmm->fetchrow_array;

    return $uni;
}

sub get_name_by_uniquename {
    my $dbh  = shift;
    my $name = shift;
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;
    my $statement = "select name from feature where uniquename='$name'  and
  feature.is_obsolete='f';";

    # print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $uni = $nmm->fetchrow_array;

    return $uni;
}

sub get_current_symbol_by_name {
    my $dbh    = shift;
    my $name   = shift;
    my @symbol = ();
    $name = decon( convers($name) );
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;

    my $statement =
"select distinct(synonym.synonym_sgml) from feature, feature_synonym, synonym where feature.feature_id=feature_synonym.feature_id and feature.is_obsolete='f' and feature.is_analysis='f' and feature_synonym.synonym_id=synonym.synonym_id and feature.name= E'$name' and feature_synonym.is_current='t'";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ($name) = $nmm->fetchrow_array ) {
        push( @symbol, $name );
    }
    if ( @symbol > 1 ) {
        print STDERR
          "ERROR: more than one current symbol asssociated with name $name\n";
        return $symbol[0];
    }
    elsif ( @symbol == 0 ) {
        print STDERR "ERROR: could not find current symbol with name $name\n";
    }
    else {
        return $symbol[0];
    }

}

sub get_current_name_by_synonym {
    my $dbh   = shift;
    my $syn   = shift;
    my @names = ();
    $syn = decon( convers($syn) );
    $syn =~ s/\\/\\\\/g;
    $syn =~ s/\'/\\\'/g;

    my $statement =
"select distinct(feature.name) from feature, feature_synonym, synonym where feature.feature_id=feature_synonym.feature_id and feature.is_obsolete='f' and feature.is_analysis='f' and feature_synonym.synonym_id=synonym.synonym_id and synonym.name= E'$syn'";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ($name) = $nmm->fetchrow_array ) {
        push( @names, $name );
    }
    if ( @names > 1 ) {
        print STDERR
          "ERROR: more than one feature asssociated with synonym $syn\n";
    }
    elsif ( @names == 0 ) {
        print STDERR "ERROR: could not find feature with synonym $syn\n";
    }
    else {
        return $names[0];
    }
}

sub get_alleleof_gene {
    my $dbh    = shift;
    my $allele = shift;
    my $statement = <<"GAG_SQL";
        SELECT f2.uniquename , f2.name, fr.rank
          FROM feature_relationship fr, feature f1, feature f2, cvterm cv
          WHERE fr.subject_id=f1.feature_id AND
                fr.object_id=f2.feature_id AND
	            fr.type_id=cv.cvterm_id AND
	            f1.uniquename='$allele' AND
                cv.name='alleleof' AND
                f2.is_obsolete='f' AND
                f2.is_analysis='f';
GAG_SQL
    my $nm = $dbh->prepare($statement);
    $nm->execute;
    my ( $u, $name, $rank ) = $nm->fetchrow_array;
    if ( !defined($u) ) {
        return '0';
    }
    $nm->finish;
    return ( $u, $name, $rank );
}

sub get_relationship_gene {
    my $dbh    = shift;
    my $unique = shift;
    my $type   = shift;
    my $statement = <<"GRG_SQL";
        SELECT f2.uniquename , f2.name, fr.rank
          FROM feature_relationship fr, feature f1, feature f2, cvterm cv, cvterm cv2
          WHERE fr.subject_id=f1.feature_id AND
	            f1.uniquename='$unique' AND
                f2.feature_id=fr.object_id AND
	            fr.type_id=cv.cvterm_id AND
                cv.name='$type' AND
                f2.is_obsolete='f' AND
                f2.type_id=cv2.cvterm_id AND
                cv2.name='gene';
GRG_SQL
    my $nm = $dbh->prepare($statement);
    $nm->execute;
    my ( $u, $name, $rank ) = $nm->fetchrow_array;

    if ( !defined($u) ) {
        return '0';
    }
    $nm->finish;
    return ( $u, $name, $rank );

}

sub get_pub_uniquename_by_miniref {
    my $dbh  = shift;
    my $mini = shift;
    my $pub  = '';
    $mini =~ s/\'/\\\'/g;
    my $statement =
"select uniquename from pub where miniref= E'$mini' and is_obsolete = false";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    if ( $nmm->rows > 0 ) {
        $pub = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return $pub;
}

sub get_max_locgroup {
    my $dbh      = shift;
    my $fb       = shift;
    my $src      = shift;
    my $fmin     = shift;
    my $fmax     = shift;
    my $strand   = shift;
    my $state    = '';
    my $locgroup = 0;

    #ARGS embedded '
    my $nfb = $fb;
    $nfb =~ s/\'/\\\'/g;

    if ( defined($fmin) && defined($fmax) ) {
        $state = "select locgroup from featureloc, feature f1, feature f2
	where f1.feature_id=featureloc.feature_id and f1.uniquename=E'$nfb'
		and f2.feature_id=featureloc.srcfeature_id and
	f2.uniquename='$src' and fmin=$fmin and fmax=$fmax";
    }
    else {
        $state = "select locgroup from featureloc, feature f1, feature f2
	where f1.feature_id=featureloc.feature_id and f1.uniquename=E'$nfb'
		and f2.feature_id=featureloc.srcfeature_id and
	f2.uniquename='$src' ";
    }
    if ( defined($strand) ) {
        $state .= " and strand=$strand";
    }
    my $nmm = $dbh->prepare($state);
    $nmm->execute;
    my $num = $nmm->rows;

    if ( $num == 1 ) {
        $locgroup = $nmm->fetchrow_array;
        $fprank{$fb}{locgroup} = $locgroup;
    }
    elsif ( $num > 1 ) {
        print STDERR "ERROR: more than 1 featureloc match\n";

        #exit(0);
    }
    elsif ( $num == 0 ) {
        if ( exists( $fprank{$fb}{locgroup} ) ) {
            $fprank{$fb}{locgroup} += 1;
            $locgroup = $fprank{$fb}{locgroup};
        }
        else {
            my $statement = "select max(locgroup) from featureloc, feature where
	feature.feature_id=featureloc.feature_id and
	feature.uniquename=E'$nfb'";
            my $fb_nmm = $dbh->prepare($statement);
            $fb_nmm->execute;
            my $loc = $fb_nmm->fetchrow_array;

            if ( defined($loc) ) {
                $locgroup = $loc + 1;
                if ( exists( $frnum{$fb}{featureloc} ) ) {
                    $locgroup -= $frnum{$fb}{featureloc};
                }
                $fprank{$fb}{locgroup} = $locgroup;
            }
            else {
                $fprank{$fb}{locgroup} = 0;
            }
        }
    }
    $nmm->finish;
    return $locgroup;

}

sub get_cvterm_obsolete_by_cv_cvterm {
    my $dbh    = shift;
    my $cvterm = shift;
    my $cv     = shift;
    $cvterm =~ s/\\/\\\\/g;
    $cvterm =~ s/\'/\\\'/g;
    my $statement =
"select cvterm.is_obsolete from cvterm , cv where cvterm.name= E'$cvterm' and cvterm.cv_id=cv.cv_id 
                   and cv.name='$cv'";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $num  = $nmm->rows;
    my $n_cv = $nmm->fetchrow_array;

    if ( !defined($n_cv) ) {
        print STDERR "ERROR: could not get cvterm $cvterm $cv in DB\n";
    }
    return $n_cv;
}

sub get_feat_ukeys_by_dbxref {
    my $dbh = shift;
    my $acc = shift;

    my $statement =
      "select distinct uniquename, organism.genus, organism.species,
	cvterm.name from feature, organism, cvterm, dbxref,feature_dbxref
	where feature_dbxref.dbxref_id=dbxref.dbxref_id and
	dbxref.accession='$acc' and dbxref.db_id=4 and
	feature.feature_id=feature_dbxref.feature_id and
	feature.organism_id=organism.organism_id and feature.organism_id!=2 and
	cvterm.cvterm_id=feature.type_id and feature.is_obsolete='f' and feature.is_analysis='f'";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $num = $nmm->rows;
    if ( $num != 1 ) {
        print STDERR
          "ERROR: could not get unique keys from dbxref $acc $num $statement\n";

        #exit(0);
    }
    my ( $uniquename, $genus, $species, $type ) = $nmm->fetchrow_array;
    $nmm->finish;
    return ( $uniquename, $genus, $species, $type );
}

sub get_feat_ukeys_by_id {
    ####given name, search db for uniquename, genus, species and cvterm
    my $dbh     = shift;
    my $id      = shift;
    my $genus   = '';
    my $species = '';
    my $type    = '';
    my $fbid    = '';
    my $is      = '';

    #print STDERR "get_feat_ukeys $id\n";
    my $statement = "select uniquename,organism.genus,
  organism.species,cvterm.name, feature.is_obsolete, cv.name from feature,organism,cvterm,cv where
  feature.feature_id=$id and feature.organism_id=organism.organism_id
	  and cvterm.cvterm_id=feature.type_id AND cv.cv_id = cvt.cv_id;";

    #print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    ( $fbid, $genus, $species, $type, $is, $cv_name ) = $nmm->fetchrow_array;

    #      if($is eq '1' && $type ne 'EST'){
    #   return '0';
    #    }

    return ( $fbid, $genus, $species, $type, $is, $cv_name );
}

sub get_lib_ukeys_by_id {
    ####given name, search db for uniquename, genus, species and cvterm
    my $dbh     = shift;
    my $id      = shift;
    my $genus   = '';
    my $species = '';
    my $type    = '';
    my $fbid    = '';
    my $is      = '';

    print STDERR "get_feat_ukeys $id\n";
    my $statement = "select uniquename,organism.genus,
  organism.species,cvterm.name from library,organism,cvterm where
  library.library_id=$id and library.organism_id=organism.organism_id and cvterm.cvterm_id=library.type_id and library.is_obsolete = false ;";

    #print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    ( $fbid, $genus, $species, $type ) = $nmm->fetchrow_array;

    #if($is eq '1' && $type ne 'EST'){
    #   return '0';
    #}

    return ( $fbid, $genus, $species, $type );
}

sub get_cell_line_ukeys_by_id {
    ####given name, search db for uniquename, genus, species
    my $dbh     = shift;
    my $id      = shift;
    my $genus   = '';
    my $species = '';
    my $fbid    = '';

    #print STDERR "get_cell_line_ukeys $id\n";
    my $statement = "select uniquename,organism.genus,
  organism.species  from cell_line,organism where
  cell_line.cell_line_id=$id and organism.organism_id=cell_line.organism_id;";

    #print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    ( $fbid, $genus, $species ) = $nmm->fetchrow_array;

    return ( $fbid, $genus, $species );
}

sub get_cell_line_ukeys_by_name_uname {
    my $dbh     = shift;
    my $uname   = shift;
    my $name    = shift;
    my $genus   = '';
    my $species = '';
    my $fbid    = '';
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;
    my $statement = "select organism.genus,
  organism.species from cell_line,organism where
  cell_line.name= E'$name' and cell_line.uniquename='$uname' and cell_line.organism_id=organism.organism_id and cell_line.uniquename like 'FBtc%';";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;

    if ( $id_num > 1 ) {
        print STDERR "ERROR: duplicate names $name \n$statement\n exiting...\n";
        return '2';

        #exit(0);
    }
    elsif ( $id_num == 0 ) {
        print STDERR "ERROR: could not get uniquename for $name\n";
        return '0';
    }
    elsif ( $id_num == 1 ) {
        ( $genus, $species ) = $nmm->fetchrow_array;
    }

    return ( $genus, $species );
}

sub get_feat_ukeys_by_name_uname {
    my $dbh     = shift;
    my $uname   = shift;
    my $name    = shift;
    my $genus   = '';
    my $species = '';
    my $type    = '';
    my $fbid    = '';
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;
    print STDERR "get_feat_ukeys_by_name_uname $uname $name n";

    my $statement = "select organism.genus,
  organism.species,cvterm.name from feature,organism,cvterm where
  feature.name= E'$name' and feature.uniquename='$uname' and feature.organism_id=organism.organism_id
	  and cvterm.cvterm_id=feature.type_id and feature.is_obsolete='f'
	  and feature.is_analysis='f' and (feature.uniquename not like
  'FBbs%' and feature.uniquename not like
  'FBog%' ) and feature.type_id !=553;";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num > 1 ) {
        print STDERR "ERROR: duplicate names $name \n$statement\n exiting...\n";
        return '2';

        #exit(0);
    }
    elsif ( $id_num == 0 ) {
        print STDERR "ERROR: could not get uniquename for $name\n";
        return '0';
    }
    elsif ( $id_num == 1 ) {
        ( $genus, $species, $type ) = $nmm->fetchrow_array;
    }

    return ( $genus, $species, $type );
}

sub get_cell_line_ukeys_by_uname {
    my $dbh     = shift;
    my $uname   = shift;
    my $genus   = '';
    my $species = '';

    my $statement = "select organism.genus, organism.species
	   from cell_line, organism where
	  cell_line.uniquename='$uname' and
	  cell_line.organism_id=organism.organism_id";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num > 1 ) {
        print STDERR
          "ERROR: duplicate unames $uname \n$statement\n exiting...\n";
        return '2';
    }
    elsif ( $id_num == 0 ) {
        print STDERR "ERROR: could not get cell_line for $uname\n";
        return '0';
    }
    elsif ( $id_num == 1 ) {
        ( $genus, $species ) = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return ( $genus, $species );

}

sub get_lib_ukeys_by_uname {
    my $dbh     = shift;
    my $uname   = shift;
    my $genus   = '';
    my $species = '';
    my $type    = '';

    my $statement = "select organism.genus, organism.species,
	  cvterm.name from library, organism, cvterm where
	  library.uniquename='$uname' and
	  library.organism_id=organism.organism_id and
	  cvterm.cvterm_id=library.type_id";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num > 1 ) {
        print STDERR
          "ERROR: duplicate unames $uname \n$statement\n exiting...\n";
        return '2';
    }
    elsif ( $id_num == 0 ) {
        print STDERR "ERROR: could not get library for $uname\n";
        return '0';
    }
    elsif ( $id_num == 1 ) {
        ( $genus, $species, $type ) = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return ( $genus, $species, $type );

}

sub get_lib_ukeys_by_name {
    my $dbh     = shift;
    my $name    = shift;
    my $genus   = '';
    my $species = '';
    my $type    = '';
    my $fbid    = '';

    $name = convers($name);
    $name = decon($name);
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;

    #print STDERR "get_lib_ukeys $name\n";
    my $statement = "select uniquename,organism.genus,
  organism.species,cvterm.name from library,organism,cvterm where
  library.name= E'$name' and library.organism_id=organism.organism_id
	  and cvterm.cvterm_id=library.type_id and library.is_obsolete='f' AND library.uniquename like 'FBlc%';";

    #    print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;

    #    print " id num=$id_num\n";
    if ( $id_num > 1 ) {
        print STDERR "ERROR: duplicate names $name \n$statement\n exiting...\n";
        return '2';

        #exit(0);
    }
    elsif ( $id_num == 0 ) {
        print STDERR "ERROR: could not get uniquename for $name\n";
        return '0';
    }
    elsif ( $id_num == 1 ) {
        ( $fbid, $genus, $species, $type ) = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return ( $fbid, $genus, $species, $type );
}

sub get_int_ukeys_by_name {
    my $dbh  = shift;
    my $name = shift;
    my $type = '';
    my $fbid = '';
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;

    #print STDERR "get_int_ukeys $name\n";
    my $statement = "select uniquename,cvterm.name from interaction,cvterm where
  interaction.uniquename= E'$name' and cvterm.cvterm_id=interaction.type_id";

    #print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;

    #print " id num=$id_num\n";
    if ( $id_num > 1 ) {
        print STDERR "ERROR: duplicate names $name \n$statement\n exiting...\n";
        return '2';

        #exit(0);
    }
    elsif ( $id_num == 0 ) {
        print STDERR "ERROR: could not get uniquename for $name\n";
        return '0';
    }
    elsif ( $id_num == 1 ) {
        ( $fbid, $type ) = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return ( $fbid, $type );
}

sub get_feat_ukeys_by_name {
    ####given name, search db for uniquename, genus, species and cvterm
    my $dbh     = shift;
    my $name    = shift;
    my $genus   = '';
    my $species = '';
    my $type    = '';
    my $fbid    = '';

    $name = convers($name);
    $name = decon($name);
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;

    print STDERR "get_feat_ukeys_by_name $name\n";
    my $statement = <<"NAME_SQL";
       SELECT uniquename,organism.genus, organism.species,cvterm.name
         FROM feature, organism, cvterm
         WHERE feature.name= E'$name' AND
               feature.organism_id=organism.organism_id AND
	           cvterm.cvterm_id=feature.type_id AND
               feature.is_obsolete='f' AND
	           feature.is_analysis='f' AND
               ( feature.uniquename not like 'FBbs%' AND
                 feature.uniquename not like 'FBog%' AND
                 feature.uniquename not like 'FBcl%') AND
               feature.uniquename ~ '\^FB[a-z][a-z][0-9]+\$';
NAME_SQL
    # print STDERR $statement;

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;

    #    print  STDERR "DEBUG id num=$id_num\n";
    if ( $id_num > 1 ) {
        print STDERR
          "Warning: duplicate names $name \n$statement\n exiting...\n";
        return '2';

        #exit(0);
    }
    elsif ( $id_num == 0 ) {
        print STDERR "Warning: could not get uniquename for $name\n";
        return '0';
    }
    elsif ( $id_num == 1 ) {
        ( $fbid, $genus, $species, $type ) = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return ( $fbid, $genus, $species, $type );
}

sub get_sffeat_ukeys_by_name {
    ####given name, search db for uniquename, genus, species and cvterm
    my $dbh     = shift;
    my $name    = shift;
    my $genus   = '';
    my $species = '';
    my $type    = '';
    my $fbid    = '';

    $name = convers($name);
    $name = decon($name);
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;

    #    print STDERR "get_feat_ukeys $name\n";
    my $statement = "select uniquename,organism.genus,
  organism.species,cvterm.name from feature,organism,cvterm where
  feature.name= E'$name' and feature.organism_id=organism.organism_id
	  and cvterm.cvterm_id=feature.type_id and feature.is_obsolete='f'
            and feature.uniquename ~ '\^FBsf[0-9]+\$'";

    #  print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;

    #    print  STDERR "DEBUG id num=$id_num\n";
    if ( $id_num > 1 ) {
        print STDERR
          "Warning: duplicate names $name \n$statement\n exiting...\n";
        return '2';

        #exit(0);
    }
    elsif ( $id_num == 0 ) {
        print STDERR "Warning: could not get uniquename for $name\n";
        return '0';
    }
    elsif ( $id_num == 1 ) {
        ( $fbid, $genus, $species, $type ) = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return ( $fbid, $genus, $species, $type );
}

sub get_clfeat_ukeys_by_name {
    ####given name, search db for uniquename, genus, species and cvterm
    my $dbh     = shift;
    my $name    = shift;
    my $genus   = '';
    my $species = '';
    my $type    = '';
    my $fbid    = '';

    $name = convers($name);
    $name = decon($name);
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;

    print STDERR "get_clfeat_ukeys $name\n";
    my $statement = "select uniquename,organism.genus,
  organism.species,cvterm.name from feature,organism,cvterm where
  feature.name= E'$name' and feature.organism_id=organism.organism_id
	  and cvterm.cvterm_id=feature.type_id and feature.is_obsolete='f'
            and feature.uniquename ~ '\^FBcl[0-9]+\$'";

    print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;

    print STDERR "DEBUG id num=$id_num\n";
    if ( $id_num > 1 ) {
        print STDERR
          "Warning: duplicate names $name \n$statement\n exiting...\n";
        return '2';

        #exit(0);
    }
    elsif ( $id_num == 0 ) {
        print STDERR "Warning: could not get uniquename for $name\n";
        return '0';
    }
    elsif ( $id_num == 1 ) {
        ( $fbid, $genus, $species, $type ) = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return ( $fbid, $genus, $species, $type );
}

sub get_cell_line_ukeys_by_name {
    ####given name, search db for uniquename, genus, species and cvterm
    my $dbh     = shift;
    my $name    = shift;
    my $genus   = '';
    my $species = '';
    my $fbid    = '';

    $name = convers($name);
    $name = decon($name);
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;

    #print STDERR "get_feat_ukeys $name\n";
    my $statement = "select uniquename,organism.genus,
  organism.species from cell_line,organism where
  cell_line.name= E'$name' and cell_line.organism_id=organism.organism_id ";

    #print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;

    # print " id num=$id_num\n";
    if ( $id_num > 1 ) {
        print STDERR "ERROR: duplicate names $name \n$statement\n exiting...\n";
        return '2';

        #exit(0);
    }
    elsif ( $id_num == 0 ) {
        print STDERR "ERROR: could not get uniquename for $name\n";
        return '0';
    }
    elsif ( $id_num == 1 ) {
        ( $fbid, $genus, $species ) = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return ( $fbid, $genus, $species );
}

sub get_fr_id {
    my $dbh    = shift;
    my $uname  = shift;
    my $unique = shift;
    my $type   = shift;
    my $pub    = shift;
    my $fr_id  = 0;

    my $statement = "select fr.feature_relationship_id from
	feature_relationship fr, feature_relationship_pub frp, feature f1,
	feature f2, cvterm ct, pub 
	where fr.subject_id=f1.feature_id and f1.uniquename='$uname' and
	f2.uniquename='$unique' and f2.feature_id=fr.object_id and
	fr.type_id=ct.cvterm_id and ct.name='$type' and
	frp.pub_id=pub.pub_id and pub.uniquename='$pub'";

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    $fr_id = $nmm->fetchrow_array;
    if ( !defined($fr_id) ) {
        $fr_id = 0;
    }
    $nmm->finish;
    return $fr_id;
}

sub get_dbxref_for_pub_dbxref {
    my $dbh       = shift;
    my $fbrf      = shift;
    my $db_id     = shift;
    my @accs      = ();
    my $statement = "select dbxref.accession from pub_dbxref, dbxref,
	db, pub where pub_dbxref.dbxref_id=dbxref.dbxref_id and
	dbxref.db_id=db.db_id and db.name='$db_id' and pub.pub_id =
	pub_dbxref.pub_id and pub.uniquename='$fbrf'";

    #	print STDERR "$statement\n";
    my $pd_nmm = $dbh->prepare($statement);
    $pd_nmm->execute;
    while ( my ($acc) = $pd_nmm->fetchrow_array ) {
        push( @accs, $acc );
    }
    $pd_nmm->finish;
    return @accs;
}

sub get_feat_ukeys_by_name_type {
    my $dbh      = shift;
    my $name     = shift;
    my $typename = shift;
    my $genus    = '';
    my $species  = '';
    my $type     = '';
    my $fbid     = '';

    $name = convers($name);
    $name = decon($name);
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;
    my $statement = "select uniquename,organism.genus,
  organism.species,cvterm.name from feature,organism,cvterm,cv where
  feature.name= E'$name' and feature.organism_id=organism.organism_id
	  and cvterm.cvterm_id=feature.type_id and cvterm.name='$typename'
	  and feature.is_obsolete='f' and cv.name='SO' and
          cv.cv_id=cvterm.cv_id and feature.uniquename not like  'FBog%';";

    #print STDERR $statement, "\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num > 1 ) {
        print "ERROR: duplicate names $name \n$statement\n";

        # exit(0);
    }
    elsif ( $id_num == 0 ) {
        print STDERR "ERROR: Could not get feature for $name $typename\n";
        return '0';
    }
    elsif ( $id_num == 1 ) {
        ( $fbid, $genus, $species, $type ) = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return ( $fbid, $genus, $species, $type );
}

sub get_feat_ukeys_by_uname_type {
    my $dbh      = shift;
    my $name     = shift;
    my $typename = shift;
    my $genus    = '0';
    my $species  = '2';

    #ARGS embedded '
    $name =~ s/\'/\\\'/g;

    my $statement = "select organism.genus,
  organism.species from
 feature,organism,cvterm,cv where
   feature.uniquename=E'$name' and
  feature.organism_id=organism.organism_id
  and cvterm.cvterm_id=feature.type_id and
 cvterm.name='$typename'
 and feature.is_obsolete='f' and cv.name='SO'
and cv.cv_id=cvterm.cv_id;";

    #print STDERR $statement, "\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num > 1 ) {
        print STDERR "ERROR: duplicate names $name \n$statement\n";

        # exit(0);
    }
    elsif ( $id_num == 0 ) {
        print STDERR "Warn: Could not get feature for $name $typename\n";
    }
    elsif ( $id_num == 1 ) {
        ( $genus, $species ) = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return ( $genus, $species );
}

sub get_organism_by_abbrev {
    my $dbh  = shift;
    my $abbr = shift;

    my $statement =
      "select genus, species from organism where abbreviation='$abbr'";
    my $n_sl = $dbh->prepare($statement);
    $n_sl->execute;
    my $num = $n_sl->rows;

    if ( $n_sl->rows > 1 ) {
        return '2';
    }
    elsif ( $n_sl->rows == 0 ) {

        return '0';
    }
    my ( $genus, $species ) = $n_sl->fetchrow_array;
    $n_sl->finish;
    return $genus, $species;
}

sub get_tempid {
    my $type = shift;
    my $name = shift;
    my $flag = 1;
    if ( !defined($type) || $type eq "" ) {
        print STDERR "ERROR: could not get temp id for $name\n";
        my $x = 1/0; # create a crash to see trace.
    }
    if ( $type ne 'rf' && $type ne 'multipub' ) {
        if ( !defined( $fbids{$name} ) ) {
            $fbids{$name} = 'FB' . $type . ':temp_' . $temp_id++;
            $flag = 0;
        }
        else {
            print STDERR "Warning: $name has been declared before as new\n";
        }
        return ( $fbids{$name}, $flag );
    }
    else {
        if ( $type eq 'rf' ) {

            return 'FBrf' . ':temp_' . $fbids{$type}++;
        }
        elsif ( $type eq 'multipub' ) {
            return 'multipub:temp_' . $fbids{$type}++;
        }
    }
}

sub write_pubprop {
    my $dbh   = shift;
    my $doc   = shift;
    my $fbrf  = shift;
    my $type  = shift;
    my $value = shift;
    my $convert = shift || 'y';

    if ($convert eq 'y'){
        $value = conversupdown($value);
    }

    my $rank = get_max_pubprop_rank( $dbh, $fbrf, $type, $value );

    my $prop = create_ch_pubprop(
        doc    => $doc,
        pub_id => $fbrf,
        value  => $value,
        type   => $type,
        rank   => $rank
    );
    my $out = dom_toString($prop);
    $prop->dispose();
    return $out;
}

sub write_pubprop_withrank {
    my $dbh   = shift;
    my $doc   = shift;
    my $fbrf  = shift;
    my $type  = shift;
    my $value = shift;
    my $rank  = shift;

    my $prop = create_ch_pubprop(
        doc    => $doc,
        pub_id => $fbrf,
        value  => conversupdown($value),
        type   => $type,
        rank   => $rank,
    );
    my $out = dom_toString($prop);
    $prop->dispose();
    return $out;
}

sub get_rank_for_pubauthor {
    my $dbh       = shift;
    my $fbrf      = shift;
    my @ranks     = ();
    my $statement = "select rank from pubauthor, pub where
	pubauthor.pub_id=pub.pub_id and pub.uniquename='$fbrf'";
    my $f_nmm = $dbh->prepare($statement);
    $f_nmm->execute;
    while ( my $rank = $f_nmm->fetchrow_array ) {
        push( @ranks, $rank );
    }
    $f_nmm->finish;
    return @ranks;

}

sub get_ranks_for_pubprop {
    my $dbh       = shift;
    my $fbrf      = shift;
    my $cvterm    = shift;
    my $value     = shift;
    my @ranks     = ();
    my $statement = '';
    if ( defined($value) ) {
        $value =~ s/\\/\\\\/g;
        $value =~ s/\'/\\\'/g;
        $value     = conversupdown($value);
        $statement = "select rank from pubprop, pub,cvterm where 
		pubprop.pub_id=pub.pub_id and pubprop.type_id=cvterm.cvterm_id
			and pub.uniquename='$fbrf' and cvterm.name='$cvterm' and
		value like E'$value'";

        #print STDERR "$statement==\n";
        my $p_nmm = $dbh->prepare($statement);
        $p_nmm->execute;
        my $rank = $p_nmm->fetchrow_array;
        if ( defined($rank) ) {
            return $rank;
        }
        $p_nmm->finish;
    }
    else {
        $statement = "select rank from pubprop, pub, cvterm where
		pubprop.pub_id=pub.pub_id and pubprop.type_id=cvterm.cvterm_id			
			and pub.uniquename='$fbrf' and cvterm.name='$cvterm'";
        my $s_nmm = $dbh->prepare($statement);
        $s_nmm->execute;
        while ( my ($rank) = $s_nmm->fetchrow_array ) {
            push( @ranks, $rank );
        }

    }
    return @ranks;
}

sub match_value_for_pubprop {
    my $dbh       = shift;
    my $fbrf      = shift;
    my $cvterm    = shift;
    my $value     = shift;
    my $rank      = 0;
    my $statement = '';
    $value =~ s/\\/\\\\/g;
    $value =~ s/\'/\\\'/g;
    $value = conversupdown($value);

    $statement = "select * from pubprop, pub,cvterm where 
		pubprop.pub_id=pub.pub_id and pubprop.type_id=cvterm.cvterm_id
			and pub.uniquename='$fbrf' and cvterm.name='$cvterm'";
    print STDERR "$statement==\n";
    my $p_nmm = $dbh->prepare($statement);
    $p_nmm->execute;
    $rank = $p_nmm->rows;
    if ( $rank > 0 ) {
        return $rank;
    }
    $p_nmm->finish;
    $statement = "select value from pubprop, pub,cvterm where 
		pubprop.pub_id=pub.pub_id and pubprop.type_id=cvterm.cvterm_id
			and pub.uniquename='$fbrf' and cvterm.name='$cvterm' and
		value like E'$value'";
    print STDERR "$statement==\n";
    $p_nmm = $dbh->prepare($statement);
    $p_nmm->execute;
    $rank = $p_nmm->rows;
    $p_nmm->finish;
    return $rank;
}

sub get_max_pubprop_rank {
    my $dbh      = shift;
    my $fbrf     = shift;
    my $type     = shift;
    my $value    = shift;
    my $rank     = 0;
    my $newvalue = $value;
    if ( $type eq 'curated_by' ) {
        $value =~ /^(.*)timelastmodified/;
        $value = $1;
        $value .= '%';
    }
    if ( defined($value) && defined( $fprank{$fbrf}{ $type . $value } ) ) {
        $rank = $fprank{$fbrf}{ $type . $value };
    }
    elsif ( defined($value) ) {
        $newvalue =~ s/\\/\\\\/g;
        $newvalue =~ s/\'/\\\'/g;
        $newvalue = conversupdown($newvalue);
        my $statement = "select rank from pubprop, pub,cvterm where 
		pubprop.pub_id=pub.pub_id and pubprop.type_id=cvterm.cvterm_id
			and pub.uniquename='$fbrf' and cvterm.name='$type' and
		value like E'$newvalue'";

        #print STDERR "$statement==\n";
        my $p_nmm = $dbh->prepare($statement);
        $p_nmm->execute;
        $rank = $p_nmm->fetchrow_array;
        if ( defined($rank) ) {
            $fprank{$fbrf}{ $type . $value } = $rank;
        }
    }
    if (   defined($value)
        && !defined( $fprank{$fbrf}{ $type . $value } )
        && defined( $fprank{$fbrf}{$type} ) )
    {
        $rank = $fprank{$fbrf}{$type} + 1;
        $fprank{$fbrf}{$type} += 1;
    }
    else {
        if ( !defined($value) || !defined($rank) ) {
            my $statement = "select max(rank) from pubprop, pub, cvterm where
		    pubprop.pub_id=pub.pub_id and pubprop.type_id=cvterm.cvterm_id			
			  and pub.uniquename='$fbrf' and cvterm.name='$type'";

            my $s_nmm = $dbh->prepare($statement);
            $s_nmm->execute;
            ($rank) = $s_nmm->fetchrow_array;
            if ( !defined($rank) ) {
                $rank = 0;
            }
            else {
                $rank += 1;
            }
            if ( defined($value) ) {
                $fprank{$fbrf}{ $type . $value } = $rank;
            }
            $fprank{$fbrf}{$type} = $rank;
        }
    }

    return $rank;
}

sub get_type_from_pub {
    my $dbh    = shift;
    my $unique = shift;
    my $statement =
"select cvterm.name from pub, cvterm where pub.type_id=cvterm.cvterm_id and pub.uniquename='$unique';";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $type = $nmm->fetchrow_array;

    return $type;
}

sub get_frprop_rank {
    my $dbh     = shift;
    my $subject = shift;
    my $object  = shift;
    my $fb_id   = shift;
    my $name    = shift;
    my $type    = shift;
    my $value   = shift;
    my $rank    = 0;

    $name = decon( convers($name) );
    $name  =~ s/\\/\\\\/g;
    $name  =~ s/\'/\\\'/g;
    $value =~ s/\\/\\\\/g;
    $value =~ s/\'/\\\'/g;
    $value = conversupdown($value);
    if ( defined($value) && exists( $fprank{$fb_id}{$name}{ $type . $value } ) )
    {
        return $fprank{$fb_id}{$name}{ $type . $value };

    }
    elsif ( exists( $fprank{$fb_id}{$name}{$type} ) ) {
        $fprank{$fb_id}{$name}{$type} += 1;
        if ( defined($value) ) {
            $fprank{$fb_id}{$name}{ $type . $value } =
              $fprank{$fb_id}{$name}{$type};
        }
        return $fprank{$fb_id}{$name}{$type};
    }
    my $statement = "select frprop.rank from feature_relationshipprop
	frprop , feature_relationship fr, cvterm, feature f1, feature f2
	where f1.uniquename='$fb_id' and f1.feature_id=fr.$subject and
	f2.feature_id=fr.$object and f2.name= E'$name' and frprop.feature_relationship_id=fr.feature_relationship_id and 
	cvterm.name='$type' and cvterm.cvterm_id=fr.type_id and
	frprop.value= E'$value'";

    #print STDERR "CHECK $statement\n";
    my $fr_el = $dbh->prepare($statement);
    $fr_el->execute;
    while ( my $rk = $fr_el->fetchrow_array ) {
        $fprank{$fb_id}{$name}{ $type . $value } = $rk;
        $rank = $rk;

        #print STDERR "CHECK: rank=$rank\n";
    }
    if ( exists( $fprank{$fb_id}{$name}{$type} ) ) {
        $rank = $fprank{$fb_id}{$name}{$type} + 1;

    }
    else {
        my $state = "select max(frprop.rank) from feature_relationshipprop
	frprop , feature_relationship fr, cvterm, feature f1, feature f2
	where f1.uniquename='$fb_id' and f1.feature_id=fr.$subject and
	f2.feature_id=fr.$object and f2.name= E'$name' and frprop.feature_relationship_id=fr.feature_relationship_id and 
	cvterm.name='$type' and cvterm.cvterm_id=fr.type_id";

        my $fr = $dbh->prepare($state);
        $fr->execute;
        while ( my $rk = $fr->fetchrow_array ) {
            $rank = $rk + 1;

        }
    }
    $fprank{$fb_id}{$name}{$type} = $rank;
    if ( defined($value) ) {
        $fprank{$fb_id}{$name}{ $type . $value } = $rank;
    }
    return $rank;
}

sub get_lr_pub_nums {
    my $dbh   = shift;
    my $fr_id = shift;

    my $statement = "select pub_id from library_relationship_pub where
	library_relationship_id=$fr_id ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub get_featureloc_pub_nums {
    my $dbh   = shift;
    my $fr_id = shift;

    my $statement = "select pub_id from featureloc_pub where
	featureloc_id=$fr_id ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub get_fr_pub_nums {
    my $dbh   = shift;
    my $fr_id = shift;

    my $statement = "select pub_id from feature_relationship_pub where
	feature_relationship_id=$fr_id ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub get_fprop_pub_nums {
    my $dbh   = shift;
    my $fr_id = shift;

    my $statement = "select pub_id from featureprop_pub where
	featureprop_id=$fr_id ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub get_libprop_pub_nums {
    my $dbh   = shift;
    my $fr_id = shift;

    my $statement = "select pub_id from libraryprop_pub where
	libraryprop_id=$fr_id ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub get_cellprop_pub_nums {
    my $dbh   = shift;
    my $fr_id = shift;

    my $statement = "select pub_id from cell_lineprop_pub where
	cell_lineprop_id=$fr_id ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub get_intprop_pub_nums {
    my $dbh   = shift;
    my $fr_id = shift;

    my $statement = "select pub_id from interactionprop_pub where
	interactionprop_id=$fr_id ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub get_feat_int_pub_nums {
    my $dbh   = shift;
    my $fr_id = shift;

    my $statement = "select pub_id from feature_interaction_pub where
	feature_interaction_id=$fr_id ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub get_frp_pub_nums {
    my $dbh   = shift;
    my $fr_id = shift;

    my $statement = "select pub_id from feature_relationshipprop_pub where
	feature_relationshipprop_id=$fr_id ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $num = $nmm->rows;
    $nmm->finish;
    return $num;
}
sub get_unique_key_for_frp_by_feattype {
    #
    # feature_relationshipprop
    #
    my $dbh     = shift;
    my $subject = shift;
    my $object  = shift;
    my $unique  = shift;
    my $fname   = shift;
    my $type    = shift;
    my $pub     = shift;
    my $ftype   = shift;
    my @ranks   = ();
    #if ( !defined($ftype) ) {
    #    @ranks = get_unique_key_for_fr( $dbh, $subject, $object, $unique, $type,
    #        $pub );
    #    return @ranks;
    #}
    my $statement =  <<"UKFRP_SQL";
      SELECT fr.feature_relationship_id, f2.name,f2.feature_id, frprop.rank, frprop.feature_relationshipprop_id
        FROM feature_relationship fr, feature f1, feature f2,cvterm cvt1, cv
             cv1 ,feature_relationship_pub frp, pub, cvterm cvt2,
             feature_relationshipprop frprop
        WHERE f1.uniquename='$unique' AND
              f2.name='$fname' AND
              fr.$subject=f1.feature_id AND
              cvt1.name='$type' AND
              fr.$object=f2.feature_id AND
              cv1.name='relationship type' AND
              cvt1.cv_id=cv1.cv_id AND
              cvt1.cvterm_id=fr.type_id AND
              cvt2.name='$ftype' AND
              cvt2.cvterm_id=f2.type_id AND
              frp.feature_relationship_id=fr.feature_relationship_id AND
              frprop.feature_relationship_id=fr.feature_relationship_id AND
              pub.pub_id=frp.pub_id AND
              pub.uniquename='$pub';
UKFRP_SQL
    print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $fr_id, $f_name, $f_id, $rank, $frp_id ) = $nmm->fetchrow_array ) {
        my $fr = {
            fr_id      => $fr_id,
            frp_id     => $frp_id,
            name       => $f_name,
            feature_id => $f_id,
            rank       => $rank
        };
        push( @ranks, $fr );
    }
    $nmm->finish;
    return @ranks;

}

sub get_unique_key_for_fr_by_feattype {

    my $dbh     = shift;
    my $subject = shift;
    my $object  = shift;
    my $unique  = shift;
    my $type    = shift;
    my $pub     = shift;
    my $ftype   = shift;
    my @ranks   = ();
    if ( !defined($ftype) ) {
        @ranks = get_unique_key_for_fr( $dbh, $subject, $object, $unique, $type,
            $pub );
        return @ranks;
    }
    my $statement =  <<"UKFR_SQL";
      SELECT fr.feature_relationship_id, f2.name,f2.feature_id, rank
        FROM feature_relationship fr, feature f1, feature f2,cvterm cvt1, cv
             cv1 ,feature_relationship_pub frp, pub, cvterm cvt2
        WHERE f1.uniquename='$unique' AND
              fr.$subject=f1.feature_id AND
              cvt1.name='$type' AND
              fr.$object=f2.feature_id AND
              cv1.name='relationship type' AND
              cvt1.cv_id=cv1.cv_id AND
              cvt1.cvterm_id=fr.type_id AND
              cvt2.name='$ftype' AND
              cvt2.cvterm_id=f2.type_id AND
              frp.feature_relationship_id=fr.feature_relationship_id AND
              pub.pub_id=frp.pub_id AND
              pub.uniquename='$pub';
UKFR_SQL
    #print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $fr_id, $f_name, $f_id, $rank ) = $nmm->fetchrow_array ) {
        my $fr = {
            fr_id      => $fr_id,
            name       => $f_name,
            feature_id => $f_id,
            rank       => $rank
        };
        push( @ranks, $fr );
    }
    $nmm->finish;
    return @ranks;

}

sub get_unique_key_for_lr {

    my $dbh     = shift;
    my $subject = shift;
    my $object  = shift;
    my $unique  = shift;

    #    my $type    = shift;
    my $pub    = shift;
    my $f_type = shift;
    my @ranks  = ();
    my $statement =
"select fr.library_relationship_id, f2.name, f2.uniquename, f2.library_id from
  library_relationship fr,  library f1, library f2,cvterm cvt1, cv
  cv1 ";
    if ( defined($pub) ) {
        $statement .= ',library_relationship_pub, pub ';
    }
    $statement .= "where
  f1.uniquename='$unique' and fr.$subject=f1.library_id and cvt1.name='$f_type'
	  and fr.$object=f2.library_id
	and cv1.name='relationship type' and cvt1.cv_id=cv1.cv_id and
  cvt1.cvterm_id=fr.type_id ";
    if ( defined($pub) ) {
        $statement .= "	and
  library_relationship_pub.library_relationship_id=fr.library_relationship_id	and pub.pub_id=library_relationship_pub.pub_id and pub.uniquename='$pub';";
    }

    #print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $fr_id, $f_name, $f_unique, $f_id ) = $nmm->fetchrow_array ) {
        if ( !defined($f_type)
            || ( defined($f_type) && $f_unique =~ /$f_type/ ) )
        {
            my $fr = {
                fr_id      => $fr_id,
                feature_id => $f_id,
                name       => $f_name,
            };
            push( @ranks, $fr );
        }
    }
    $nmm->finish;
    return @ranks;

}

sub get_unique_key_for_clr {

    my $dbh     = shift;
    my $subject = shift;
    my $object  = shift;
    my $unique  = shift;

    #    my $type    = shift;
    my $pub    = shift;
    my $f_type = shift;
    my @ranks  = ();
    my $statement =
"select fr.cell_line_relationship_id, f2.name, f2.uniquename, f2.cell_line_id,cvt1.name from
  cell_line_relationship fr,  cell_line f1, cell_line f2, cvterm cvt1, cv,
  cv1 ";
    if ( defined($pub) ) {
        $statement .= ',cell_line_relationship_pub, pub ';
    }
    $statement .= "where
  f1.uniquename='$unique' and fr.$subject=f1.library_id and cvt1.cvterm_id = fr.type_id 
	  and fr.$object=f2.cell_line_id
	and cv1.name='cell_line relationship type' and cvt1.cv_id=cv1.cv_id";
    if ( defined($pub) ) {
        $statement .= "	and
  cell_line_relationship_pub.cell_line_relationship_id=fr.cell_line_relationship_id and pub.pub_id=cell_line_relationship_pub.pub_id and pub.uniquename='$pub';";
    }

    #print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $fr_id, $f_name, $f_unique, $f_id, $type ) =
        $nmm->fetchrow_array )
    {
        if ( !defined($f_type)
            || ( defined($f_type) && $f_unique =~ /$f_type/ ) )
        {
            my $fr = {
                fr_id      => $fr_id,
                feature_id => $f_id,
                name       => $f_name,
                type       => $type,
            };
            push( @ranks, $fr );
        }
    }
    $nmm->finish;
    return @ranks;

}

sub get_unique_key_for_fr {

    my $dbh     = shift;
    my $subject = shift;
    my $object  = shift;
    my $unique  = shift;
    my $type    = shift;
    my $pub     = shift;
    my $f_type  = shift;
    my @ranks   = ();
    my $statement =
"select fr.feature_relationship_id, f2.name, f2.uniquename, f2.feature_id, rank from
  feature_relationship fr,  feature f1, feature f2,cvterm cvt1, cv
  cv1 ";

    if ( defined($pub) ) {
        $statement .= ',feature_relationship_pub, pub ';
    }
    $statement .= "where
  f1.uniquename='$unique' and fr.$subject=f1.feature_id and cvt1.name='$type'
	  and fr.$object=f2.feature_id
	and cv1.name='relationship type' and cvt1.cv_id=cv1.cv_id and
  cvt1.cvterm_id=fr.type_id ";
    if ( defined($pub) ) {
        $statement .= "	and
  feature_relationship_pub.feature_relationship_id=fr.feature_relationship_id	and pub.pub_id=feature_relationship_pub.pub_id and pub.uniquename='$pub';";
    }

    #	 print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $fr_id, $f_name, $f_unique, $f_id, $rank ) =
        $nmm->fetchrow_array )
    {

        if ( !defined($f_type)
            || ( defined($f_type) && $f_unique =~ /$f_type/ ) )
        {
          #	print STDERR 	"\nCHECK f_unique = $f_unique and f_type = $f_type\n";
            my $fr = {
                fr_id      => $fr_id,
                feature_id => $f_id,
                name       => $f_name,
                rank       => $rank
            };
            push( @ranks, $fr );
        }
    }
    $nmm->finish;
    return @ranks;

}

sub write_library_relationship {
    my $dbh     = shift;
    my $doc     = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;
    my $name    = shift;
    my $fr_type = shift;
    my $pub     = shift;
    my $f_type  = shift;
    my $id_type = shift;
    my $g       = shift;
    my $s       = shift;
    my $flag    = 0;
    my $library;
    my $uniquename = '';
    my $type       = '';
    my $genus      = 'Drosophila';
    my $species    = 'melanogaster';
    my $out        = '';

    if ( $name =~ /^FBlc/ ) {
        if ( $name =~ /temp/ ) {
            $library = $name;
        }
        else {
            ( $genus, $species, $type ) = get_lib_ukeys_by_uname( $dbh, $name );
            if ( $genus eq '0' || $genus eq '2' ) {
                print STDERR
"ERROR: could not find library uniquename $name in DB $genus\n";
            }
            else {
                $library = create_ch_library(
                    doc        => $doc,
                    uniquename => $name,
                    genus      => $genus,
                    species    => $species,
                    type       => $type,
                    macro_id   => $name
                );
            }
        }
    }
    else {
        if ( exists( $fbids{$name} ) ) {
            $library = $fbids{$name};
        }
        else {
            my $sname = $name;
            ( $uniquename, $genus, $species, $type ) =
              get_lib_ukeys_by_name( $dbh, $sname );
            if ( $uniquename eq '0' || $uniquename eq '2' ) {
                print STDERR "ERROR: could not find library with name $name\n";

            }
            else {
                $library = create_ch_library(
                    doc        => $doc,
                    uniquename => $uniquename,
                    type       => $type,
                    genus      => $genus,
                    species    => $species,
                    macro_id   => $uniquename
                );
                $fbids{$name} = $uniquename;
            }
        }
    }
    validate_cvterm( $dbh, $fr_type, 'relationship type' );

    my $fr = create_ch_library_relationship(
        doc      => $doc,
        $subject => $uname,
        $object  => $library,
        rtype    => $fr_type
    );
    if ( ref($library) ) {
        $library->appendChild(
            create_ch_library_pub( doc => $doc, pub_id => $pub ) );
    }
    else {
        $out = dom_toString(
            create_ch_library_pub(
                doc        => $doc,
                library_id => $library,
                pub_id     => $pub
            )
        );
    }
    my $frp = create_ch_library_relationship_pub( doc => $doc, pub_id => $pub );
    $fr->appendChild($frp);

    #print STDERR dom_toString($fr);
    return ( $fr, $out );
}

sub write_cell_line_relationship {
    my $dbh     = shift;
    my $doc     = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;
    my $name    = shift;
    my $fr_type = shift;
    my $flag    = 0;
    my $cell_line;
    my $uniquename = '';

    #    my $type      = '';
    my $genus   = 'Drosophila';
    my $species = 'melanogaster';

    #    my $out='';

    if ( $name =~ /^FBtc/ ) {
        if ( $name =~ /temp/ ) {
            $cell_line = $name;
        }
        else {
            ( $genus, $species ) = get_cell_line_ukeys_by_uname( $dbh, $name );
            if ( $genus eq '0' || $genus eq '2' ) {
                print STDERR "ERROR: could not find $name in DB $genus\n";
            }
            else {
                $cell_line = create_ch_cell_line(
                    doc        => $doc,
                    uniquename => $name,
                    genus      => $genus,
                    species    => $species,
                    macro_id   => $name
                );
            }
        }
    }
    else {
        if ( exists( $fbids{$name} ) ) {
            $cell_line = $fbids{$name};
        }
        else {
            my $sname = $name;
            ( $uniquename, $genus, $species ) =
              get_cell_line_ukeys_by_name( $dbh, $sname );
            if ( $uniquename eq '0' || $uniquename eq '2' ) {
                print STDERR
                  "ERROR: could not find cell_line with name $name\n";

            }
            else {
                $cell_line = create_ch_cell_line(
                    doc        => $doc,
                    uniquename => $uniquename,
                    genus      => $genus,
                    species    => $species,
                    macro_id   => $uniquename
                );
                $fbids{$name} = $uniquename;
            }
        }
    }
    validate_cvterm( $dbh, $fr_type, 'cell_line_relationship' );
    my $fr = create_ch_cell_line_relationship(
        doc      => $doc,
        $subject => $uname,
        $object  => $cell_line,
        rtype    => $fr_type,

    );

    #    print STDERR dom_toString($fr);
    return ($fr);
}

sub write_feature_relationship {
    my $dbh     = shift;
    my $doc     = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;
    my $name    = shift;
    my $fr_type = shift;
    my $pub     = shift;
    my $f_type  = shift;
    my $id_type = shift;
    my $g       = shift;
    my $s       = shift;
    my $flag    = 0;
    my $feature;
    my $uniquename = '';
    my $type       = '';
    my $genus      = 'Drosophila';
    my $species    = 'melanogaster';
    my $out        = '';

    if ( $name =~ /^FB\w{2}.{1}/ && !( $name =~ /^FB\{\}/ ) ) {
        if ( $name =~ /temp/ ) {
            $feature = $name;
        }
        else {
            ( $genus, $species, $type ) =
              get_feat_ukeys_by_uname( $dbh, $name );
            if ( $genus eq '0' || $genus eq '2' ) {
                print STDERR "ERROR: could not find $name in DB $genus\n";
            }
            else {


                my $cv = get_cv_by_cvterm( $dbh, $type );
                $feature = create_ch_feature(
                    doc        => $doc,
                    uniquename => $name,
                    genus      => $genus,
                    species    => $species,
                    type       => $type,
                    cvname     => $cv,
                    macro_id   => $name
                );
            }
        }
    }
    else {
        if ( exists( $fbids{$name} ) ) {
            $feature = $fbids{$name};
        }
        else {
            my $sname = $name;
            my $cv    = "";
            ( $uniquename, $genus, $species, $type ) =
              get_feat_ukeys_by_name( $dbh, $sname );
            if ( ( $uniquename eq '0' || $uniquename eq '2' )
                && defined($f_type) )
            {
                ( $uniquename, $genus, $species, $type ) =
                  get_feat_ukeys_by_name_type( $dbh, $sname, $f_type );
            }

            #print STDERR "$uniquename $genus, $species\n";
            $cv = get_cv_by_cvterm( $dbh, $type );

            if ( $uniquename eq '0' || $uniquename eq '2' ) {
                if (   $name =~ /\[\+\]$/
                    || $name =~ /\[-\]$/
                    || $name =~ /\[\*\]$/ )
                {
                    if ( $name =~ /^(.{2,14}?)\\/ ) {
                        my $org = $1;
                        ( $genus, $species ) =
                          get_organism_by_abbrev( $dbh, $org );
                        if ( $genus eq '0' ) {
                            $genus   = 'Drosophila';
                            $species = 'melanogaster';
                        }
                    }

                    if ( !defined($genus) || $genus eq '0' ) {
                        $genus   = 'Drosophila';
                        $species = 'melanogaster';
                    }

                    $feature = create_ch_feature(
                        doc        => $doc,
                        uniquename => $name,
                        type_id    => create_ch_cvterm(
                            doc  => $doc,
                            name => 'bogus symbol',
                            cv   => 'FlyBase miscellaneous CV'
                        ),
                        genus     => $genus,
                        no_lookup => '1',
                        species   => $species,
                        name      => $name,
                        macro_id  => $name
                    );
                    $fbids{$name} = $name;
                }
                else {
                    if ( !defined($f_type) ) {
                        print STDERR "ERROR! $name could not be found in DB\n";

                        # exit(0);
                    }
                    if ( $f_type eq 'chromosome_band' ) {
                        $uniquename = $name;
                    }
                    else {
                        $id_type =~ s/FB//;
                        ( $uniquename, $flag ) = get_tempid( $id_type, $name );
                    }
                    $type = $f_type;
                    $cv   = get_cv_by_cvterm( $dbh, $type );

                    $genus   = 'Drosophila';
                    $species = 'melanogaster';
                    if ( defined($g) ) {
                        $genus   = $g;
                        $species = $s;
                    }
                    if ( $flag == 1 ) {
                        $feature = $uniquename;
                    }
                    else {
                        print STDERR "ERROR: $name is not in Database\n";
                        if ( $type eq 'trangenic_transposon' ) {
                            $genus   = 'synthetic';
                            $species = 'construct';
                        }
                        $feature = create_ch_feature(
                            doc        => $doc,
                            uniquename => $uniquename,
                            type       => $type,
                            cvname     => $cv,
                            genus      => $genus,
                            no_lookup  => '1',
                            species    => $species,
                            name       => decon( convers($name) ),
                            macro_id   => $uniquename
                        );
                        $fbids{$name} = $uniquename;
                    }
                }
            }
            else {
                $cv = get_cv_by_cvterm( $dbh, $type );

                $feature = create_ch_feature(
                    doc        => $doc,
                    uniquename => $uniquename,
                    type       => $type,
                    cvname     => $cv,
                    genus      => $genus,
                    species    => $species,
                    macro_id   => $uniquename
                );
                $fbids{$name} = $uniquename;
            }
        }
    }
    my $fr = create_ch_fr(
        doc      => $doc,
        $subject => $uname,
        $object  => $feature,
        rtype    => $fr_type
    );
    if ( ref($feature) ) {
        $feature->appendChild(
            create_ch_feature_pub( doc => $doc, pub_id => $pub ) );
    }
    else {
        $out = dom_toString(
            create_ch_feature_pub(
                doc        => $doc,
                feature_id => $feature,
                pub_id     => $pub
            )
        );
    }
    validate_cvterm( $dbh, $fr_type, 'relationship type' );
    my $frp = create_ch_fr_pub( doc => $doc, pub_id => $pub );
    $fr->appendChild($frp);

    #print STDERR dom_toString($fr);
    return ( $fr, $out );
}

sub delete_feature_relationship {
    my $dbh     = shift;
    my $doc     = shift;
    my $t       = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;
    my $fr_type = shift;

    return &delete_table_relationship( $dbh, $doc, 'feature', $t, $subject,
        $object, $uname, $fr_type );

}

sub delete_library_relationship {
    my $dbh     = shift;
    my $doc     = shift;
    my $t       = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;
    my $fr_type = shift;

    return &delete_table_relationship( $dbh, $doc, 'library', $t, $subject,
        $object, $uname, $fr_type );

}

sub delete_cell_line_relationship {
    my $dbh     = shift;
    my $doc     = shift;
    my $t       = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;
    my $fr_type = shift;

    return &delete_table_relationship( $dbh, $doc, 'cell_line', $t, $subject,
        $object, $uname, $fr_type );

}

sub delete_strain_relationship {
    my $dbh     = shift;
    my $doc     = shift;
    my $t       = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;
    my $fr_type = shift;

    return &delete_table_relationship( $dbh, $doc, 'strain', $t, $subject,
        $object, $uname, $fr_type );

}

sub delete_humanhealth_relationship {
    my $dbh     = shift;
    my $doc     = shift;
    my $t       = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;
    my $fr_type = shift;

    return &delete_table_relationship( $dbh, $doc, 'humanhealth', $t, $subject,
        $object, $uname, $fr_type );

}

sub delete_table_relationship {
    my $dbh     = shift;
    my $doc     = shift;
    my $table   = shift;
    my $t       = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;
    my $fr_type = shift;

    my %fr_h = %$t;
    my $out  = '';
    my ( $uniquename, $genus, $species, $type, $is_obsolete, $cv_name) = '';

    my $get_ukey_function = 'get_feat_ukeys_by_id';
    if ( $table eq 'library' ) {
        $get_ukey_function = 'get_lib_ukeys_by_id';
        ( $uniquename, $genus, $species, $type, $is_obsolete ) =
          &$get_ukey_function( $dbh, $fr_h{library_id} );
    }
    elsif ( $table eq 'cell_line' ) {
        $get_ukey_function = 'get_cell_line_ukeys_by_id';
        ( $uniquename, $genus, $species ) =
          &$get_ukey_function( $dbh, $fr_h{cell_line_id} );
    }
    elsif ( $table eq 'strain' ) {
        $get_ukey_function = 'get_strain_ukeys_by_id';
        ( $uniquename, $genus, $species, $is_obsolete ) =
          &$get_ukey_function( $dbh, $fr_h{strain_id} );
    }
    elsif ( $table eq 'humanhealth' ) {
        $get_ukey_function = 'get_humanhealth_ukeys_by_id';
        ( $uniquename, $genus, $species, $is_obsolete ) =
          &$get_ukey_function( $dbh, $fr_h{humanhealth_id} );
    }
    elsif ( $table eq 'grp' ) {
        $get_ukey_function = 'get_grp_ukeys_by_id';
        ( $uniquename, $type, $is_obsolete ) =
          &$get_ukey_function( $dbh, $fr_h{grp_id} );
    }
    else {
        ( $uniquename, $genus, $species, $type, $is_obsolete, $cv_name ) =
          &$get_ukey_function( $dbh, $fr_h{feature_id} );
    }

    if ( $uniquename eq '0' || $uniquename eq '2' ) {
        print STDERR
"ERROR: could not find uniquename for $fr_h{name} error code $uniquename\n";
        return;
    }
    my $create_function = "create_ch_" . $table;
    my $feature         = "";
    if ( $table eq 'feature' ) {
        if ( $type eq 'chromosome_structure_variation' ) {
            $feature = &$create_function(
                doc        => $doc,
                uniquename => $uniquename,
                type       => $type,
                cvname     => 'SO',
                genus      => $genus,
                species    => $species,
                macro_id   => $uniquename
            );
            if ( defined($is_obsolete) && $is_obsolete eq 'f' ) {
                $fbids{ $fr_h{name} } = $uniquename;
            }
        }
        # elsif ( $type eq 'split system combination' ) {
        #     $feature = &$create_function(
        #         doc        => $doc,
        #         uniquename => $uniquename,
        #         type       => $type,
        #         cvname     => 'FlyBase miscellaneous CV',
        #         genus      => $genus,
        #         species    => $species,
        #         macro_id   => $uniquename
        #     );
        #     if ( defined($is_obsolete) && $is_obsolete eq 'f' ) {
        #         $fbids{ $fr_h{name} } = $uniquename;
        #     }
        # }
        else {
            $feature = &$create_function(
                doc        => $doc,
                uniquename => $uniquename,
                type       => $type,
                cvname     => $cv_name
                genus      => $genus,
                species    => $species,
                macro_id   => $uniquename
            );
            if ( defined($is_obsolete) && $is_obsolete eq 'f' ) {
                $fbids{ $fr_h{name} } = $uniquename;
            }
        }
    }
    elsif ( $table eq 'library' ) {
        $feature = &$create_function(
            doc        => $doc,
            uniquename => $uniquename,
            type       => $type,
            genus      => $genus,
            species    => $species,
            macro_id   => $uniquename
        );
        if ( defined($is_obsolete) && $is_obsolete eq 'f' ) {
            $fbids{ $fr_h{name} } = $uniquename;
        }
    }
    elsif ( $table eq 'cell_line' ) {
        $feature = &$create_function(
            doc        => $doc,
            uniquename => $uniquename,
            genus      => $genus,
            species    => $species,
            macro_id   => $uniquename
        );
        $fbids{ $fr_h{name} } = $uniquename;
    }
    elsif ( $table eq 'strain' || $table eq 'humanhealth' ) {
        $feature = &$create_function(
            doc        => $doc,
            uniquename => $uniquename,
            genus      => $genus,
            species    => $species,
            macro_id   => $uniquename
        );
        if ( defined($is_obsolete) && $is_obsolete eq 'f' ) {
            $fbids{ $fr_h{name} } = $uniquename;
        }
    }
    elsif ( $table eq 'grp' ) {
        $feature = &$create_function(
            doc        => $doc,
            uniquename => $uniquename,
            type       => $type,
            macro_id   => $uniquename
        );
        if ( defined($is_obsolete) && $is_obsolete eq 'f' ) {
            $fbids{ $fr_h{name} } = $uniquename;
        }
    }
    my $create_fr_function = "create_ch_" . $table . "_relationship";
    my $fr                 = &$create_fr_function(
        doc      => $doc,
        $subject => $uname,
        $object  => $feature,
        rtype    => $fr_type,

    );
    if ( $table eq 'feature' ) {
        $fr->appendChild( create_doc_element( $doc, "rank", $fr_h{rank} ) );
    }
    elsif ( $table eq 'grp' ) {
        $fr->appendChild( create_doc_element( $doc, "rank", $fr_h{rank} ) );
    }
    elsif ( $table eq 'humanhealth' ) {
        $fr->appendChild( create_doc_element( $doc, "rank", $fr_h{rank} ) );
    }
    elsif ( $table eq 'strain' ) {
        $fr->appendChild( create_doc_element( $doc, "rank", $fr_h{rank} ) );
    }
    $fr->setAttribute( 'op', 'delete' );
    $out = dom_toString($fr);
    $fr->dispose();

    return $out;
}

sub delete_library_relationship_pub {

    my $dbh     = shift;
    my $doc     = shift;
    my $t       = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;
    my $fr_type = shift;
    my $pub     = shift;

    return &delete_table_relationship_pub(
        $dbh,    $doc,   'library', $t, $subject,
        $object, $uname, $fr_type,  $pub
    );

}

sub delete_strain_relationship_pub {

    my $dbh     = shift;
    my $doc     = shift;
    my $t       = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;
    my $fr_type = shift;
    my $pub     = shift;

    return &delete_table_relationship_pub( $dbh, $doc, 'strain', $t, $subject,
        $object, $uname, $fr_type, $pub );

}

sub delete_humanhealth_relationship_pub {

    my $dbh     = shift;
    my $doc     = shift;
    my $t       = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;
    my $fr_type = shift;
    my $pub     = shift;

    return &delete_table_relationship_pub(
        $dbh,    $doc,   'humanhealth', $t, $subject,
        $object, $uname, $fr_type,      $pub
    );

}

sub delete_table_relationship_pub {
    my $dbh     = shift;
    my $doc     = shift;
    my $table   = shift;
    my $t       = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;
    my $fr_type = shift;
    my $pub     = shift;

    my %fr_h            = %$t;
    my $out             = '';
    my $feature         = '';
    my $create_function = 'create_ch_' . $table;
    my $uniquename      = "";

    my $get_uniquename_function = 'get_feat_ukeys_by_id';
    if ( $table eq 'library' ) {
        $get_uniquename_function = 'get_lib_ukeys_by_id';
    }
    elsif ( $table eq 'strain' ) {
        $get_uniquename_function = 'get_strain_ukeys_by_id';
    }
    elsif ( $table eq 'humanhealth' ) {
        $get_uniquename_function = 'get_humanhealth_ukeys_by_id';
    }
    elsif ( $table eq 'grp' ) {
        $get_uniquename_function = 'get_grp_ukeys_by_id';
    }

    if ( $table eq 'library' || $table eq 'feature' ) {
        ( $uniquename, my $genus, my $species, my $type, my $is_obsolete, my $cv_name) =
          &$get_uniquename_function( $dbh, $fr_h{ $table . "_id" } );
        if ( $uniquename eq '0' ) {
            print STDERR
"ERROR: feature/library has been deleted in function delete_table_relationship_pub\n";
        }
        $feature = &$create_function(
        doc        => $doc,
        uniquename => $uniquename,
        type       => $type,
        cvname     => $cv_name,
        genus      => $genus,
        species    => $species,
        macro_id   => $uniquename
        );
        # if ($type eq 'split system combination') {
        #     $feature = &$create_function(
        #     doc        => $doc,
        #     uniquename => $uniquename,
        #     type       => $type,
        #     cvname     => $cv_name,
        #     genus      => $genus,
        #     species    => $species,
        #     macro_id   => $uniquename
        #     );
        # }
        # else {
        #     $feature = &$create_function(
        #     doc        => $doc,
        #     uniquename => $uniquename,
        #     type       => $type,
        #     genus      => $genus,
        #     species    => $species,
        #     macro_id   => $uniquename
        #     );
        # }
    }
    elsif ( $table eq 'grp' ) {
        ( $uniquename, my $type ) =
          &$get_uniquename_function( $dbh, $fr_h{ $table . "_id" } );
        if ( $uniquename eq '0' ) {
            print STDERR
"ERROR: grp has been deleted in function delete_table_relationship_pub\n";
        }
        $feature = &$create_function(
            doc        => $doc,
            uniquename => $uniquename,
            type       => $type,
            macro_id   => $uniquename
        );
    }

    elsif ($table eq 'strain'
        || $table eq 'cell_line'
        || $table eq 'humanhealth' )
    {
        ( $uniquename, my $genus, my $species ) =
          &$get_uniquename_function( $dbh, $fr_h{ $table . "_id" } );
        if ( $uniquename eq '0' ) {
            print STDERR
"ERROR: strain has been deleted in function delete_table_relationship_pub\n";
        }
        $feature = &$create_function(
            doc        => $doc,
            uniquename => $uniquename,
            genus      => $genus,
            species    => $species,
            macro_id   => $uniquename
        );
    }
    $fbids{ $fr_h{name} } = $uniquename;
    my $create_relationship = 'create_ch_' . $table . '_relationship';
    my $fr                  = &$create_relationship(
        doc      => $doc,
        $subject => $uname,
        $object  => $feature,
        rtype    => $fr_type,

    );

    if (   $table eq 'feature'
        || $table eq 'dtrain'
        || $table eq 'humanhealth'
        || $table eq 'grp' )
    {
        $fr->appendChild( create_doc_element( $doc, "rank", $fr_h{rank} ) );
    }
    my $create_ch_relationship_pub =
      'create_ch_' . $table . '_relationship_pub';
    my $frp = &$create_ch_relationship_pub( doc => $doc, uniquename => $pub );
    $frp->setAttribute( 'op', 'delete' );
    $fr->appendChild($frp);
    $out = dom_toString($fr);

    $frnum{$uname}{ $fr_h{name} }++;
    print STDERR "STATE: $uname ", $fr_h{name}, " fr num ",
      $frnum{$uname}{ $fr_h{name} }, "\n";
    $fr->dispose();
    return $out;

}

sub delete_feature_relationship_pub {
    my $dbh     = shift;
    my $doc     = shift;
    my $t       = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;
    my $fr_type = shift;
    my $pub     = shift;
    return &delete_table_relationship_pub(
        $dbh,    $doc,   'feature', $t, $subject,
        $object, $uname, $fr_type,  $pub
    );
}

sub get_unique_for_phendesc {
    my $dbh    = shift;
    my $unique = shift;
    my $pub    = shift;
    my $type   = shift;

    my @result = ();
    my $statement =
      "select distinct genotype.uniquename, environment.uniquename, cvterm.name 
    from genotype, feature, feature_genotype, environment, cvterm, phendesc , pub
    where feature.uniquename='$unique' and feature.feature_id=feature_genotype.feature_id and feature_genotype.genotype_id = genotype.genotype_id 
    and genotype.genotype_id=phendesc.genotype_id and environment.environment_id=phendesc.environment_id and cvterm.cvterm_id=phendesc.type_id 
    and pub.pub_id=phendesc.pub_id and pub.uniquename='$pub' and cvterm.name = '$type'";

    #print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $genotype, $env, $type ) = $nmm->fetchrow_array ) {
        my %tmp = ();
        $tmp{genotype} = $genotype;
        $tmp{environ}  = $env;
        $tmp{type}     = $type;
        push( @result, \%tmp );
    }
    $nmm->finish;
    return @result;
}

sub get_cvterm_for_library_cvterm {
    my $dbh    = shift;
    my $unique = shift;
    my $cv     = shift;
    my $pub    = shift;
    my @result = ();
    my $statement =
      "select cvt1.name, cvt1.is_obsolete from library_cvterm fcv, library f,
	cvterm cvt1,  cv, pub where fcv.library_id=f.library_id
		and f.uniquename='$unique' and fcv.cvterm_id=cvt1.cvterm_id and
	cvt1.cv_id=cv.cv_id and cv.name='$cv' and
	fcv.pub_id=pub.pub_id and pub.uniquename='$pub'";

    #print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $cvterm, $is_o ) = $nmm->fetchrow_array ) {
        push( @result, "$cvterm,,$is_o" );

    }
    $nmm->finish;
    return @result;
}

sub get_cvterm_for_interaction_cvterm {
    my $dbh    = shift;
    my $unique = shift;
    my $cv     = shift;

    #    my $pub       = shift;
    my @result = ();
    my $statement =
"select cvt1.name, cvt1.is_obsolete from interaction_cvterm fcv, interaction f,
	cvterm cvt1,  cv where fcv.interaction_id=f.interaction_id
		and f.uniquename='$unique' and fcv.cvterm_id=cvt1.cvterm_id and
	cvt1.cv_id=cv.cv_id and cv.name='$cv' ";

    #print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $cvterm, $is_o ) = $nmm->fetchrow_array ) {
        push( @result, "$cvterm,,$is_o" );

    }
    $nmm->finish;
    return @result;
}

sub get_cvterm_for_cell_line_cvterm {
    my $dbh    = shift;
    my $unique = shift;
    my $cv     = shift;
    my $pub    = shift;
    my @result = ();
    my $statement =
"select cvt1.name, cvt1.is_obsolete from cell_line_cvterm fcv, cell_line f,
	cvterm cvt1,  cv, pub where fcv.cell_line_id=f.cell_line_id
		and f.uniquename='$unique' and  fcv.cvterm_id=cvt1.cvterm_id and
	cvt1.cv_id=cv.cv_id and cv.name='$cv' and
	fcv.pub_id=pub.pub_id and pub.uniquename='$pub'";

    #	print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $cvterm, $is_o ) = $nmm->fetchrow_array ) {
        push( @result, "$cvterm,,$is_o" );

    }
    $nmm->finish;
    return @result;
}

sub get_cvterm_for_feature_cvterm {
    my $dbh    = shift;
    my $unique = shift;
    my $cv     = shift;
    my $pub    = shift;
    my @result = ();
    my $statement =
      "select cvt1.name, cvt1.is_obsolete from feature_cvterm fcv, feature f,
	cvterm cvt1,  cv, pub where fcv.feature_id=f.feature_id
		and f.uniquename='$unique' and fcv.cvterm_id=cvt1.cvterm_id and
	cvt1.cv_id=cv.cv_id and cv.name='$cv' and
	fcv.pub_id=pub.pub_id and pub.uniquename='$pub'";

    #print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $cvterm, $is_o ) = $nmm->fetchrow_array ) {
        push( @result, "$cvterm,,$is_o" );

    }
    $nmm->finish;
    return @result;
}

sub get_cvterm_for_feature_cvterm_withprop {
    my $dbh       = shift;
    my $unique    = shift;
    my $cv        = shift;
    my $pub       = shift;
    my $proptype  = shift;
    my @result    = ();
    my $statement = "select cvt1.name from feature_cvterm fcv, feature f,
	cvterm cvt1, cvterm cvt2, cv, pub, feature_cvtermprop fcvp where fcv.feature_id=f.feature_id
		and f.uniquename='$unique' and fcv.cvterm_id=cvt1.cvterm_id and
	cvt1.cv_id=cv.cv_id and cv.name='$cv' and
	cvt2.cvterm_id=fcvp.type_id and cvt2.name='$proptype' and
	fcvp.feature_cvterm_id=fcv.feature_cvterm_id and
	fcv.pub_id=pub.pub_id and pub.uniquename='$pub'";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my $cvterm = $nmm->fetchrow_array ) {
        push( @result, $cvterm );

    }
    $nmm->finish;
    return @result;
}

sub get_cvterm_for_feature_cvterm_by_cvtermprop {
    my $dbh       = shift;
    my $unique    = shift;
    my $cv        = shift;
    my $pub       = shift;
    my $propvalue = shift;
    my $proptype  = shift;
    my @result    = ();
    $propvalue =~ s/\\/\\\\/g;
    $propvalue =~ s/\'/\\\'/g;
    my $statement = "select cvt1.name from feature_cvterm fcv, feature f,
	cvterm cvt1, cvterm cvt2, cv, pub, cvtermprop cvp 
	where fcv.feature_id=f.feature_id
	and f.uniquename='$unique' and fcv.cvterm_id=cvt1.cvterm_id and
	cvt1.cv_id=cv.cv_id and cv.name='$cv' and
	cvt2.cvterm_id=cvp.type_id and cvt2.name='$proptype' and
	cvp.value = E'$propvalue' and cvp.cvterm_id=cvt1.cvterm_id and
	fcv.pub_id=pub.pub_id and pub.uniquename='$pub'";

    #print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my $cvterm = $nmm->fetchrow_array ) {
        push( @result, $cvterm );

    }
    $nmm->finish;
    return @result;
}

sub get_unique_key_for_interactionprop {
    my $dbh    = shift;
    my $unique = shift;
    my $type   = shift;

    #    my $pub    = shift;
    my @ranks = ();
    my $statement =
"select interactionprop.interactionprop_id, rank from interactionprop, interaction,cvterm,cv where interaction.uniquename='$unique' and interactionprop.interaction_id=interaction.interaction_id and cvterm.name='$type' and cv.name='interaction property type' and cvterm.cv_id=cv.cv_id and cvterm.cvterm_id=interactionprop.type_id ;";

#    if($pub eq 'unattributed'){
#        $statement="select interactionprop.interactionprop_id, rank from interactionprop, interaction,cvterm,cv where interaction.uniquename='$unique' and interactionprop.interaction_id=interaction.interaction_id and cvterm.name='$type' and cv.name='interaction property type' and cvterm.cv_id=cv.cv_id and cvterm.cvterm_id=interactionprop.type_id";
#    }
# print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $fp_id, $rank ) = $nmm->fetchrow_array ) {
        my $fp = {
            fp_id => $fp_id,
            rank  => $rank
        };
        push( @ranks, $fp );
    }
    $nmm->finish;
    return @ranks;
}

sub get_unique_key_for_libraryprop {
    my $dbh    = shift;
    my $unique = shift;
    my $type   = shift;
    my $pub    = shift;
    my @ranks  = ();
    my $statement =
"select libraryprop.libraryprop_id, rank from libraryprop, library,cvterm,libraryprop_pub, pub,cv where library.uniquename='$unique' and libraryprop.library_id=library.library_id and cvterm.name='$type' and cv.name='property type' and cvterm.cv_id=cv.cv_id and cvterm.cvterm_id=libraryprop.type_id and libraryprop_pub.libraryprop_id=libraryprop.libraryprop_id and pub.pub_id=libraryprop_pub.pub_id and pub.uniquename='$pub';";
    if ( $pub eq 'unattributed' ) {
        $statement =
"select libraryprop.libraryprop_id, rank from libraryprop, library,cvterm,cv where library.uniquename='$unique' and libraryprop.library_id=library.library_id and cvterm.name='$type' and cv.name='property type' and cvterm.cv_id=cv.cv_id and cvterm.cvterm_id=libraryprop.type_id";
    }

    # print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $fp_id, $rank ) = $nmm->fetchrow_array ) {
        my $fp = {
            fp_id => $fp_id,
            rank  => $rank
        };
        push( @ranks, $fp );
    }
    $nmm->finish;
    return @ranks;
}

sub get_unique_key_for_libraryprop_nopub {
    my $dbh    = shift;
    my $unique = shift;
    my $type   = shift;
    my @ranks  = ();
    my $statement =
"select libraryprop.libraryprop_id, rank from libraryprop, library, cvterm, cv where library.uniquename='$unique' and libraryprop.library_id=library.library_id and cvterm.name='$type' and cv.name='property type' and cvterm.cv_id=cv.cv_id and cvterm.cvterm_id=libraryprop.type_id;";

    # print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $fp_id, $rank ) = $nmm->fetchrow_array ) {
        my $fp = {
            fp_id => $fp_id,
            rank  => $rank
        };
        push( @ranks, $fp );
    }
    $nmm->finish;
    return @ranks;
}

sub get_unique_key_for_cell_lineprop {
    my $dbh    = shift;
    my $unique = shift;
    my $type   = shift;
    my $pub    = shift;
    my @ranks  = ();
    my $statement =
"select cell_lineprop.cell_lineprop_id, rank from cell_lineprop, cell_line,cvterm,cell_lineprop_pub, pub,cv where cell_line.uniquename='$unique' and cell_lineprop.cell_line_id=cell_line.cell_line_id and cvterm.name='$type' and cv.name='cell_lineprop type' and cvterm.cv_id=cv.cv_id and cvterm.cvterm_id=cell_lineprop.type_id and cell_lineprop_pub.cell_lineprop_id=cell_lineprop.cell_lineprop_id and pub.pub_id=cell_lineprop_pub.pub_id and pub.uniquename='$pub';";
    if ( $pub eq 'unattributed' ) {
        $statement =
"select cell_lineprop.cell_lineprop_id, rank from cell_lineprop, cell_line,cvterm,cv where cell_line.uniquename='$unique' and cell_lineprop.cell_line_id=cell_line.cell_line_id and cvterm.name='$type' and cv.name='cell_lineprop type' and cvterm.cv_id=cv.cv_id and cvterm.cvterm_id=cell_lineprop.type_id";
    }

    # print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $fp_id, $rank ) = $nmm->fetchrow_array ) {
        my $fp = {
            fp_id => $fp_id,
            rank  => $rank
        };
        push( @ranks, $fp );
    }
    $nmm->finish;
    return @ranks;
}

sub get_unique_key_for_featureprop {
    my $dbh    = shift;
    my $unique = shift;
    my $type   = shift;
    my $pub    = shift;
    my $cv     = shift;
    if ( !defined($cv) ) {
        $cv = 'property type';
    }

    #ARGS embedded '
    $unique =~ s/\'/\\\'/g;

    my @ranks = ();
    my $statement =
"select featureprop.featureprop_id, rank from featureprop, feature,cvterm,featureprop_pub, pub,cv where feature.uniquename=E'$unique' and featureprop.feature_id=feature.feature_id and cvterm.name='$type' and cv.name='$cv' and cvterm.cv_id=cv.cv_id and cvterm.cvterm_id=featureprop.type_id and featureprop_pub.featureprop_id=featureprop.featureprop_id and pub.pub_id=featureprop_pub.pub_id and pub.uniquename='$pub';";

    # print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $fp_id, $rank ) = $nmm->fetchrow_array ) {
        my $fp = {
            fp_id => $fp_id,
            rank  => $rank
        };
        push( @ranks, $fp );
    }
    $nmm->finish;
    return @ranks;
}

sub get_dbname_by_description {
    my $dbh       = shift;
    my $url       = shift;
    my $dbname    = '';
    my $statement = "select name from db where description='$url';";
    my $nmm       = $dbh->prepare($statement);
    $nmm->execute;
    while ( my $name = $nmm->fetchrow_array ) {
        $dbname = $name;
    }
    if ( $dbname eq '' ) {
        my $state = "select name from db where name='$url';";
        my $s_nmm = $dbh->prepare($state);
        $s_nmm->execute;

        while ( my $name = $s_nmm->fetchrow_array ) {
            $dbname = $name;
        }
    }
    return $dbname;
}

sub get_dbname_by_url {
    my $dbh       = shift;
    my $url       = shift;
    my $dbname    = '';
    my $statement = "select name from db where url='$url';";
    my $nmm       = $dbh->prepare($statement);
    $nmm->execute;
    while ( my $name = $nmm->fetchrow_array ) {
        $dbname = $name;
    }
    return $dbname;
}

sub write_tableprop {
    my $dbh     = shift;
    my $doc     = shift;
    my $table   = shift;
    my $feat_id = shift;
    my $value   = shift;
    my $type    = shift;
    my $pub     = shift;

    my $rank = get_max_tableprop_rank( $dbh, $table, $feat_id, $type, $value );

    my $cv = get_cv_by_cvterm( $dbh, $type );
    if ( !defined($cv) ) {
        print STDERR "ERROR: cvterm $type not found in DB\n";
    }
    if ( $table eq 'cell_line' ) {
        $cv = 'cell_lineprop type';
    }
    elsif ( $table eq 'strain' ) {
        $cv = 'property type';
    }
    my $create_prop = 'create_ch_' . $table . 'prop';
    my $tid         = $table . "_id";
    my $fp          = &$create_prop(
        doc     => $doc,
        $tid    => $feat_id,
        value   => $value,
        type_id => create_ch_cvterm( doc => $doc, cv => $cv, name => $type ),
        rank    => $rank
    );

    my $pubfunction = "create_ch_" . $table . "prop_pub";
    $tid = $table . "prop_id";
    my $fppub = &$pubfunction(
        doc    => $doc,
        pub_id => $pub
    );
    $fp->appendChild($fppub);
    my $out = dom_toString($fp);
    $fp->dispose();
    return $out;
}

sub write_libraryprop {
    my $dbh     = shift;
    my $doc     = shift;
    my $feat_id = shift;
    my $value   = shift;
    my $type    = shift;
    my $pub     = shift;

    #print "value=$value\n";
    my $rank = get_max_libraryprop_rank( $dbh, $feat_id, $type, $value );
    my $cv   = get_cv_by_cvterm( $dbh, $type );
    if ( !defined($cv) ) {
        print STDERR "ERROR: cvterm $type not found in DB\n";
    }
    elsif ( $cv ne 'property type' ) {

        #        print STDERR "CHECK: cv $cv not property type\n";
    }

    my $fp = create_ch_libraryprop(
        doc        => $doc,
        library_id => $feat_id,
        rank       => $rank,
        type       => $type,
        value      => $value
    );

    my $fppub = create_ch_libraryprop_pub( doc => $doc, pub_id => $pub );
    $fp->appendChild($fppub);
    my $out = dom_toString($fp);
    $fp->dispose();
    return $out;
}

sub write_cell_lineprop {
    my $dbh     = shift;
    my $doc     = shift;
    my $feat_id = shift;
    my $value   = shift;
    my $type    = shift;
    my $pub     = shift;

    #print "value=$value\n";
    my $rank = get_max_cell_lineprop_rank( $dbh, $feat_id, $type, $value );
    my $cv   = get_cv_by_cvterm( $dbh, $type );
    if ( !defined($cv) ) {
        print STDERR "ERROR: cvterm $type not found in DB\n";
    }
    elsif ( $cv ne 'cell_lineprop type' ) {
        print STDERR "ERROR: cv $cv notcell_lineprop type\n";
    }
    my $fp = create_ch_cell_lineprop(
        doc          => $doc,
        cell_line_id => $feat_id,
        rank         => $rank,
        type         => $type,
        value        => $value
    );

    my $fppub = create_ch_cell_lineprop_pub( doc => $doc, pub_id => $pub );
    $fp->appendChild($fppub);
    my $out = dom_toString($fp);
    $fp->dispose();
    return $out;
}

sub write_interactionprop {
    my $dbh     = shift;
    my $doc     = shift;
    my $feat_id = shift;
    my $value   = shift;
    my $type    = shift;
    my $cv      = shift;
    my $pub     = shift;

    my $rank = get_max_interactionprop_rank( $dbh, $feat_id, $type, $value );
    if ( !defined($cv) ) {
        $cv = get_cv_by_cvterm( $dbh, $type );
        if ( $cv ne 'interaction property type' ) {
            print STDERR
              "ERROR: cv $cv not interaction property type for $feat_id\n";
        }
    }
    else {
        my $va = validate_cvterm( $dbh, $type, $cv );
        if ( $va == 0 ) {
            print STDERR "ERROR: cv $cv / cvterm $type not found in DB\n";
        }
    }
    ## Escape single-quotes
    $value =~ s/\'/\\\'/g;
    print STDERR "value=$value\n";

    my $fp = create_ch_interactionprop(
        doc            => $doc,
        interaction_id => $feat_id,
        rank           => $rank,
        type           => $type,
        value          => $value,
    );

    my $fppub = create_ch_interactionprop_pub( doc => $doc, pub_id => $pub );
    $fp->appendChild($fppub);
    my $out = dom_toString($fp);
    $fp->dispose();
    return $out;
}

sub write_featureprop {
    my $dbh     = shift;
    my $doc     = shift;
    my $feat_id = shift;
    my $value   = shift;
    my $type    = shift;
    my $pub     = shift;
    my $rank    = shift;

    #print "value=$value\n";
    if ( !defined($rank) ) {
        $rank = get_max_featureprop_rank( $dbh, $feat_id, $type, $value );
    }
    my $cv = get_cv_by_cvterm( $dbh, $type );
    if ( !defined($cv) ) {
        print STDERR "ERROR: cvterm $type not found in DB\n";
        return;
    }
    elsif ( $cv ne 'property type' ) {

        #        print STDERR "CHECK: cv $cv not property type\n";
    }

    my $fp = create_ch_featureprop(
        doc        => $doc,
        feature_id => $feat_id,
        rank       => $rank,
        type       => $type,
        value      => $value
    );
    if ( $pub ne 'FBrf0000000' ) {
        my $fppub = create_ch_featureprop_pub( doc => $doc, pub_id => $pub );
        $fp->appendChild($fppub);
    }
    my $out = dom_toString($fp);
    $fp->dispose();
    return $out;
}

sub write_featureprop_cv {
    my $dbh     = shift;
    my $doc     = shift;
    my $feat_id = shift;
    my $value   = shift;
    my $type    = shift;
    my $pub     = shift;
    my $cv      = shift;
    my $rank    = shift;

    #print "value=$value\n";
    if ( !defined($rank) ) {
        $rank = get_max_featureprop_rank( $dbh, $feat_id, $type, $value );
    }

    if ( !defined($cv) ) {
        print STDERR "ERROR: need to pass in cv for cvterm $type \n";
        return;
    }

    my $fp = create_ch_featureprop(
        doc        => $doc,
        feature_id => $feat_id,
        rank       => $rank,
        type_id    => create_ch_cvterm(
            doc  => $doc,
            cv   => $cv,
            name => $type,
        ),
        value => $value
    );
    if ( $pub ne 'FBrf0000000' ) {
        my $fppub = create_ch_featureprop_pub( doc => $doc, pub_id => $pub );
        $fp->appendChild($fppub);
    }
    my $out = dom_toString($fp);
    $fp->dispose();
    return $out;
}

sub write_allele_dbxref {
    my $dbh    = shift;
    my $doc    = shift;
    my $unique = shift;
    my $dbname = shift;
    my $acc    = shift;
    my $acc_desc = shift;
    my $delete = shift;
    my $out    = "";

    print STDERR
      "DEBUG:in write_allele_dbxref allele $unique db = $dbname accession = $acc acc desc = $acc_desc\n";
    my $dbxref;
    if($acc_desc) {
        $dbxref = create_ch_dbxref(
                     doc       => $doc,
                     db        => $dbname,
                     accession => $acc,
                     description => $acc_desc,
                     no_lookup => 1
            );
    }
    else{
        $dbxref = create_ch_dbxref(
                     doc       => $doc,
                     db        => $dbname,
                     accession => $acc,
                     no_lookup => 1
            );
    }
    my $feat = create_ch_feature_dbxref(
                  doc        => $doc,
                  feature_id => $unique,
                  dbxref_id  => $dbxref
        );
    if ($delete) {
        $feat->setAttribute( 'op', 'delete' );
    }
    $out .= dom_toString($feat);

    return $out;
}

sub write_gene_dbxref {
    my $dbh    = shift;
    my $doc    = shift;
    my $unique = shift;
    my $dbname = shift;
    my $acc    = shift;
    my $out    = "";

    print STDERR
      "DEBUG:in write_gene_dbxref gene $unique db = $dbname accession = $acc\n";
    $out .= dom_toString(
        create_ch_feature_dbxref(
            doc        => $doc,
            feature_id => $unique,
            dbxref_id  => create_ch_dbxref(
                doc       => $doc,
                db        => $dbname,
                accession => $acc,
                no_lookup => 1
            )
        )
    );
    return $out;
}

sub validate_dbname {
    my $dbh  = shift;
    my $name = shift;
    my $val  = '';
    $name =~ s/\'/\\\'/g;
    my $statement = "select name from db where name= E'$name'";
    my $nmm       = $dbh->prepare($statement);
    $nmm->execute;
    my $n_cv = $nmm->fetchrow_array;

    if ( !defined($n_cv) ) {
        print STDERR "ERROR: could not find db.name as $name in chado\n";
        return $val;
    }
    else {
        $val = $n_cv;
    }
    return $val;
}

sub validate_db_description {
    my $dbh  = shift;
    my $name = shift;
    my $val  = 0;
    my $statement =
"select description from db where name='$name' and description is not null";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $row_id = $nmm->rows;
    if ( $row_id == 1 ) {
        $val = 1;
        my $n_cv = $nmm->fetchrow_array;
        print STDERR "ERROR: $name has description $n_cv in chado\n";
    }

    return $val;
}

sub validate_db_url {
    my $dbh       = shift;
    my $name      = shift;
    my $val       = 0;
    my $statement = "select url from db where name='$name' and url is not null";
    my $nmm       = $dbh->prepare($statement);
    $nmm->execute;
    my $row_id = $nmm->rows;
    if ( $row_id == 1 ) {
        $val = 1;
        my $n_cv = $nmm->fetchrow_array;
        print STDERR "ERROR: $name has url $n_cv in chado\n";
    }

    return $val;
}

sub validate_db_urlprefix {
    my $dbh  = shift;
    my $name = shift;
    my $val  = 0;
    my $statement =
      "select urlprefix from db where name='$name' and urlprefix is not null";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $row_id = $nmm->rows;
    if ( $row_id == 1 ) {
        $val = 1;
        my $n_cv = $nmm->fetchrow_array;
        print STDERR "ERROR: $name has urlprefix $n_cv in chado\n";
    }

    return $val;
}

sub check_al_with_fr_or_mutagen {
    my $dbh   = shift;
    my $fb_id = shift;

    if ( $fb_id =~ /temp/ ) {
        return 0;
    }
    if ( !( $fb_id =~ /^FB/ ) ) {
        if ( exists( $fbids{$fb_id} ) ) {
            $fb_id = $fbids{$fb_id};
            if ( $fb_id =~ /temp/ ) {
                return 0;
            }
        }
        else {
            #	print $fb_id--\n";
            my ( $unique, $genus, $s, $t ) =
              get_feat_ukeys_by_name( $dbh, $fb_id );
            if ( $unique =~ /FBal/ ) {
                $fb_id = $unique;
            }
            elsif ( $unique ne '0' ) {
                return 0;
            }
            else {
                print STDERR "ERROR, no features in DB name as --$fb_id--\n";
            }
        }
    }
    my $statement = "select f2.uniquename from feature f1, feature f2,
	feature_relationship fr, cvterm cvt where f1.feature_id=fr.subject_id and
	f2.feature_id=fr.object_id and f1.uniquename='$fb_id' and
	fr.type_id = cvt.cvterm_id and cvt.name = 'associated_with' and
	(f2.uniquename like 'FBtp%' or f2.uniquename like 'FBmc%' or
	f2.uniquename like 'FBms%');";

    #print "$statement\n";
    my $mmm = $dbh->prepare($statement);
    $mmm->execute;

    my $num = $mmm->rows;
    if ( $num > 0 ) {
        return 1;
    }
    else {
        my $state = "select cvterm.name from feature_cvterm fcv, cvterm, feature
		where feature.uniquename='$fb_id' and
		feature.feature_id=fcv.feature_id and
		cvterm.cvterm_id=fcv.cvterm_id and
        cvterm.is_obsolete = 0 and
		cvterm.name = 'in vitro construct';";

        #	print "$state\n";
        my $nmm = $dbh->prepare($state);
        $nmm->execute;
        my $nnn = $nmm->rows;
        if ( $nnn > 0 ) {
            return 1;
        }
        $nmm->finish;
    }
    $mmm->finish;
    return 0;
}

sub get_library_dbxrefprop_rank {
    my $dbh    = shift;
    my $db     = shift;
    my $dbxref = shift;
    my $unique = shift;
    my $type   = shift;
    my $value  = shift;

    my $rank = 0;
    $db     =~ s/\\/\\\\/g;
    $db     =~ s/\'/\\\'/g;
    $dbxref =~ s/\\/\\\\/g;
    $dbxref =~ s/\'/\\\'/g;

    if (   defined($value)
        && defined( $fprank{ $db . $dbxref . $type . $value } ) )
    {
        return $fprank{ $db . $dbxref . $type . $value };
    }
    else {
        if ( defined( $fprank{ $db . $dbxref . $type } ) ) {
            $fprank{ $db . $dbxref . $type } += 1;
            if ( defined($value) ) {
                $fprank{ $db . $dbxref . $type . $value } =
                  $fprank{ $db . $dbxref . $type };
            }
            return $fprank{ $db . $dbxref . $type };
        }
        else {
            if ( defined($value) ) {
                my $statement = "select max(library_dbxrefprop.rank) from 
			dbxref, cv, cvterm, db, library_dbxrefprop, library, library_dbxref 			
			where library.library_id = library_dbxref.library_id 
                        and library.uniquename = '$unique' and library_dbxref.library_dbxref_id=library_dbxrefprop.library_dbxref_id 
                        and db.db_id=dbxref.db_id and db.name= E'$db' and
			dbxref.accession = E'$dbxref' and library_dbxref.dbxref_id = dbxref.dbxref_id and 
			library_dbxrefprop.type_id=cvterm.cvterm_id and
			cvterm.name='$type' and
			cvterm.cv_id=cv.cv_id and
			cv.name='property type' and 
		        library_dbxrefprop.value='$value'";

                # print STDERR "$statement\n";
                my $fc_el = $dbh->prepare($statement);
                $fc_el->execute;
                my $f_r = $fc_el->fetchrow_array;
                if ( defined($f_r) ) {
                    $fprank{ $db . $dbxref . $type . $value } = $f_r;
                    return $f_r;
                }
            }

            my $state = "select max(library_dbxrefprop.rank) from 
			dbxref, cv, cvterm, db, library_dbxrefprop, library, library_dbxref 			
			where library.library_id = library_dbxref.library_id 
                        and library.uniquename = '$unique' and library_dbxref.library_dbxref_id=library_dbxrefprop.library_dbxref_id 
                        and db.db_id=dbxref.db_id and db.name= E'$db' and
			dbxref.accession = E'$dbxref' and library_dbxref.dbxref_id = dbxref.dbxref_id and 
			library_dbxrefprop.type_id=cvterm.cvterm_id and
			cvterm.name='$type' and
			cvterm.cv_id=cv.cv_id and
			cv.name='property type'";

            # print STDERR "$state\n";
            my $fb_el = $dbh->prepare($state);
            $fb_el->execute;
            my $p_r = $fb_el->fetchrow_array;
            if ( defined($p_r) ) {
                $rank = $p_r;
                $rank++;
            }
            $fprank{ $db . $dbxref . $type } = $rank;
            if ( defined($value) ) {
                $fprank{ $db . $dbxref . $type . $value } = $rank;
            }
            return $rank;
        }

    }

    return $rank;
}

sub get_feature_cvtermprop_rank {
    my $dbh    = shift;
    my $fb_id  = shift;
    my $cv     = shift;
    my $cvterm = shift;
    my $type   = shift;
    my $value  = shift;
    my $pub    = shift;
    my $rank   = 0;
    $cvterm =~ s/\\/\\\\/g;
    $cvterm =~ s/\'/\\\'/g;

    if ( defined($value) ) {
        $value =~ s/\\/\\\\/g;
        $value =~ s/\'/\\\'/g;
    }
    if (   defined($value)
        && defined( $fprank{$fb_id}{ $cvterm . $pub . $type . $value } ) )
    {
        return $fprank{$fb_id}{ $cvterm . $pub . $type . $value };
    }
    else {
        if ( defined( $fprank{$fb_id}{ $cvterm . $pub . $type } ) ) {
            $fprank{$fb_id}{ $cvterm . $pub . $type } += 1;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $cvterm . $pub . $type . $value } =
                  $fprank{$fb_id}{ $cvterm . $pub . $type };
            }
            return $fprank{$fb_id}{ $cvterm . $pub . $type };
        }
        else {
            if ( defined($value) ) {
                my $statement = "select max(feature_cvtermprop.rank) from 
			feature_cvterm,
			feature, cv, cvterm, pub, cvterm cvterm2, feature_cvtermprop
			where feature_cvterm.feature_id=feature.feature_id and
			feature.uniquename='$fb_id' and
			feature_cvtermprop.feature_cvterm_id = 
			feature_cvterm.feature_cvterm_id
			and feature_cvtermprop.type_id=cvterm2.cvterm_id and
			cvterm2.name='$type' 
				and
			feature_cvterm.cvterm_id=cvterm.cvterm_id and cvterm.cv_id=cv.cv_id
			and cv.name='$cv' and cvterm.name= E'$cvterm' and 
			feature_cvterm.pub_id=pub.pub_id and
			pub.uniquename='$pub' and feature_cvtermprop.value= E'$value'";

                #print STDERR "$statement\n";
                my $fc_el = $dbh->prepare($statement);
                $fc_el->execute;
                my $f_r = $fc_el->fetchrow_array;
                if ( defined($f_r) ) {
                    $fprank{$fb_id}{ $cvterm . $pub . $type . $value } = $f_r;
                    return $f_r;
                }
            }

            my $state = "select max(feature_cvtermprop.rank) from 
			feature_cvterm,
			feature, cv, cvterm, pub, cvterm cvterm2, feature_cvtermprop
			where feature_cvterm.feature_id=feature.feature_id and
			feature.uniquename='$fb_id' and
			feature_cvtermprop.feature_cvterm_id = 
			feature_cvterm.feature_cvterm_id
			and feature_cvtermprop.type_id=cvterm2.cvterm_id and
			cvterm2.name='$type' and
			feature_cvterm.cvterm_id=cvterm.cvterm_id and cvterm.cv_id=cv.cv_id
			and cv.name='$cv' and cvterm.name= E'$cvterm' and 
			feature_cvterm.pub_id=pub.pub_id and
			pub.uniquename='$pub'";

            my $fb_el = $dbh->prepare($state);
            $fb_el->execute;
            while ( my $p_r = $fb_el->fetchrow_array ) {
                if ( $p_r ne '' ) {
                    $rank = $p_r;
                    $rank++;
                }
            }
            $fprank{$fb_id}{ $cvterm . $pub . $type } = $rank;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $cvterm . $pub . $type . $value } = $rank;
            }
            return $rank;
        }

    }
    return $rank;
}

sub get_cell_linename_by_uniquename {
    my $dbh  = shift;
    my $name = shift;
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;
    my $statement = "select name from cell_line where uniquename='$name' ;";

    # print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $uni = $nmm->fetchrow_array;
    return $uni;
}

sub get_rank_for_cell_line_cvtermprop {
    my $dbh    = shift;
    my $fb_id  = shift;
    my $cv     = shift;
    my $cvterm = shift;
    my $type   = shift;
    my $value  = shift;
    my $pub    = shift;
    my $rank   = 0;
    $cvterm =~ s/\\/\\\\/g;
    $cvterm =~ s/\'/\\\'/g;

    if ( defined($value) ) {
        $value =~ s/\\/\\\\/g;
        $value =~ s/\'/\\\'/g;
    }
    if (   defined($value)
        && defined( $fprank{$fb_id}{ $cvterm . $pub . $type . $value } ) )
    {
        return $fprank{$fb_id}{ $cvterm . $pub . $type . $value };
    }
    else {
        if ( defined( $fprank{$fb_id}{ $cvterm . $pub . $type } ) ) {
            $fprank{$fb_id}{ $cvterm . $pub . $type } += 1;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $cvterm . $pub . $type . $value } =
                  $fprank{$fb_id}{ $cvterm . $pub . $type };
            }
            return $fprank{$fb_id}{ $cvterm . $pub . $type };
        }
        else {
            if ( defined($value) ) {
                my $statement = "select max(cell_line_cvtermprop.rank) from 
			cell_line_cvterm,
			cell_line, cv, cvterm, pub, cvterm cvterm2, cell_line_cvtermprop
			where cell_line_cvterm.cell_line_id=cell_line.cell_line_id and
			cell_line.uniquename='$fb_id' and
			cell_line_cvtermprop.cell_line_cvterm_id = 
			cell_line_cvterm.cell_line_cvterm_id
			and cell_line_cvtermprop.type_id=cvterm2.cvterm_id and
			cvterm2.name='$type' 
				and
			cell_line_cvterm.cvterm_id=cvterm.cvterm_id and cvterm.cv_id=cv.cv_id
			and cv.name='$cv' and cvterm.name= E'$cvterm' and 
			cell_line_cvterm.pub_id=pub.pub_id and
			pub.uniquename='$pub' and cell_line_cvtermprop.value= E'$value'";

                #print STDERR "$statement\n";
                my $fc_el = $dbh->prepare($statement);
                $fc_el->execute;
                my $f_r = $fc_el->fetchrow_array;
                if ( defined($f_r) ) {
                    $fprank{$fb_id}{ $cvterm . $pub . $type . $value } = $f_r;
                    return $f_r;
                }
            }

            my $state = "select max(cell_line_cvtermprop.rank) from 
			cell_line_cvterm,
			cell_line, cv, cvterm, pub, cvterm cvterm2, cell_line_cvtermprop
			where cell_line_cvterm.cell_line_id=cell_line.cell_line_id and
			cell_line.uniquename='$fb_id' and
			cell_line_cvtermprop.cell_line_cvterm_id = 
			cell_line_cvterm.cell_line_cvterm_id
			and cell_line_cvtermprop.type_id=cvterm2.cvterm_id and
			cvterm2.name='$type' and
			cell_line_cvterm.cvterm_id=cvterm.cvterm_id and cvterm.cv_id=cv.cv_id
			and cv.name='$cv' and cvterm.name= E'$cvterm' and 
			cell_line_cvterm.pub_id=pub.pub_id and
			pub.uniquename='$pub'";

            my $fb_el = $dbh->prepare($state);
            $fb_el->execute;
            while ( my $p_r = $fb_el->fetchrow_array ) {
                if ( $p_r ne '' ) {
                    $rank = $p_r;
                    $rank++;
                }
            }
            $fprank{$fb_id}{ $cvterm . $pub . $type } = $rank;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $cvterm . $pub . $type . $value } = $rank;
            }
            return $rank;
        }

    }
    return $rank;
}

sub get_library_for_cell_line_library {
    my $dbh    = shift;
    my $unique = shift;
    my $pub    = shift;
    my $type   = shift;
    my @result = ();
    my $cl_sql = <<"CL_SQL";
        SELECT l.uniquename 
          FROM cell_line_library cll, cell_line cl, library l, pub p, cell_line_libraryprop cllp, cvterm cvt, cv 
          WHERE cll.cell_line_id=cl.cell_line_id AND
                l.library_id=cll.library_id AND
                cll.pub_id = p.pub_id AND
                cll.cell_line_library_id = cllp.cell_line_library_id AND
                cllp.type_id = cvt.cvterm_id AND
                cvt.cv_id = cv.cv_id AND
                cv.name = 'cell_line_libraryprop type' AND
                cl.uniquename=? AND
                p.uniquename = ? AND
                cvt.name = ? 
CL_SQL
    my $libq   = $dbh->prepare($cl_sql);
    $libq->bind_param( 1, $unique );
    $libq->bind_param( 2, $pub );
    $libq->bind_param( 3, $type );
    $libq->execute;

    while ( my ($lu) = $libq->fetchrow_array ) {
        push @result, $lu;
    }
    $libq->finish;
    return (@result);
}

sub get_feature_expressionprop_rank {
    my $dbh   = shift;
    my $fb_id = shift;
    my $cv    = shift;
    my $ex_id = shift;
    my $type  = shift;
    my $value = shift;
    my $pub   = shift;
    my $rank  = 0;
    if ( defined($value) ) {
        $value =~ s/\\/\\\\/g;
        $value =~ s/\'/\\\'/g;
    }
    if (   defined($value)
        && defined( $fprank{$fb_id}{ $ex_id . $pub . $type . $value } ) )
    {
        return $fprank{$fb_id}{ $ex_id . $pub . $type . $value };
    }
    else {
        if ( defined( $fprank{$fb_id}{ $ex_id . $pub . $type } ) ) {
            $fprank{$fb_id}{ $ex_id . $pub . $type } += 1;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $ex_id . $pub . $type . $value } =
                  $fprank{$fb_id}{ $ex_id . $pub . $type };
            }
            return $fprank{$fb_id}{ $ex_id . $pub . $type };
        }
        else {
            if ( defined($value) ) {
                my $statement = "select max(feature_expressionprop.rank) 
                        from feature_expression, feature, cv, expression, pub, cvterm cvterm2, feature_expressionprop 
			where feature_expression.feature_id=feature.feature_id 
                        and feature.uniquename='$fb_id' 
                        and feature_expressionprop.feature_expression_id=feature_expression.feature_expression_id 
			and feature_expressionprop.type_id=cvterm2.cvterm_id and cvterm2.name='$type' 
                        and cvterm2.cv_id=cv.cv_id and cv.name='$cv' 
			and feature_expression.expression_id=expression.expression_id 
			and expression.uniquename='$ex_id' 
                        and feature_expression.pub_id=pub.pub_id 
                        and pub.uniquename='$pub' and feature_expressionprop.value= E'$value'";

             #		print STDERR "Not in fprank and lookup with value $statement\n";
                my $fc_el = $dbh->prepare($statement);
                $fc_el->execute;
                my $f_r = $fc_el->fetchrow_array;
                if ( defined($f_r) ) {
                    $fprank{$fb_id}{ $ex_id . $pub . $type . $value } = $f_r;
                    print STDERR
"Not in fprank and lookup with value found in chado returns $f_r\n";
                    return $f_r;
                }
            }

            my $state = "select max(feature_expressionprop.rank) 
                        from feature_expression, feature, cv, expression, pub, cvterm cvterm2, feature_expressionprop 
			where feature_expression.feature_id=feature.feature_id 
                        and feature.uniquename='$fb_id' 
                        and feature_expressionprop.feature_expression_id=feature_expression.feature_expression_id 
			and feature_expressionprop.type_id=cvterm2.cvterm_id and cvterm2.name='$type' 
                        and cvterm2.cv_id=cv.cv_id and cv.name='$cv' 
			and feature_expression.expression_id=expression.expression_id 
			and expression.uniquename='$ex_id' 
                        and feature_expression.pub_id=pub.pub_id 
                        and pub.uniquename='$pub'";

         #            print STDERR "Not in fprank and lookup no value $state\n";

            my $fb_el = $dbh->prepare($state);
            $fb_el->execute;
            my $p_r = $fb_el->fetchrow_array;
            if ( defined($p_r) ) {

#		print STDERR "Not in fprank and lookup no value found in chado max fep rank = $p_r\n";
                $rank = $p_r;
                $rank++;
            }
            $fprank{$fb_id}{ $ex_id . $pub . $type } = $rank;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $ex_id . $pub . $type . $value } = $rank;
            }

          #	    print STDERR "Not in fprank and lookup no value return $rank\n";
            return $rank;
        }
    }

  #    print STDERR "Not found in fprank nor chado return default rank $rank\n";

    return $rank;
}

sub get_unique_key_for_feature_interaction {
    ####given interaction uniquename, pub and feature_interactionprop type search db for feature, role cv,role type, rank
    my $dbh    = shift;
    my $uname  = shift;
    my $type   = shift;
    my $pub    = shift;
    my @result = ();

    ###get feature_interaction and feature_interactionprop
    my $fgr_state =
"select distinct feature_interaction.feature_interaction_id, feature.uniquename, o.genus, o.species, cvt.name as ftype, cv.name as fcv, cvt1.name as rtype, cv1.name as rcv, feature_interaction.rank as firank from
		feature, interaction, feature_interaction, feature_interactionprop, organism o, cv, cvterm cvt, cv cv1, cvterm cvt1, cv cv2, cvterm cvt2, feature_interaction_pub, pub where
		feature.feature_id=feature_interaction.feature_id and feature_interaction.interaction_id = interaction.interaction_id and 
		interaction.uniquename= '$uname' and
		feature.is_analysis='f' and feature.organism_id = o.organism_id and feature.type_id = cvt.cvterm_id and cvt.cv_id = cv.cv_id and 
		feature_interaction.role_id=cvt1.cvterm_id and cvt1.cv_id = cv1.cv_id and 
                feature_interaction.feature_interaction_id = feature_interactionprop.feature_interaction_id and  
                feature_interactionprop.type_id = cvt2.cvterm_id and cvt2.cv_id = cv2.cv_id and cv2.name = 'feature_interaction property type' and cvt2.name = '$type' and 
                feature_interaction.feature_interaction_id = feature_interaction_pub.feature_interaction_id and 
                feature_interaction_pub.pub_id = pub.pub_id and pub.uniquename = '$pub' ";
    my $f_g = $dbh->prepare($fgr_state);
    $f_g->execute;
    while (
        my (
            $fi_id, $funame, $genus, $species, $ftype,
            $fcv,   $rtype,  $rcv,   $firank
        )
        = $f_g->fetchrow_array
      )
    {
        my %tmp = ();
        $tmp{fp_id}   = $fi_id;
        $tmp{f_uname} = $funame;
        $tmp{genus}   = $genus;
        $tmp{species} = $species;
        $tmp{f_type}  = $ftype;
        $tmp{f_cv}    = $fcv;
        $tmp{r_type}  = $rtype;
        $tmp{r_cv}    = $rcv;
        $tmp{fi_rank} = $firank;
        push( @result, \%tmp );

    }
    $f_g->finish;
    return @result;
}

sub get_feature_interactionprop_rank {
    my $dbh   = shift;
    my $fb_id = shift;
    my $cv    = shift;
    my $ex_id = shift;
    my $type  = shift;
    my $value = shift;
    my $rank  = 0;
    if ( defined($value) ) {
        $value =~ s/\\/\\\\/g;
        $value =~ s/\'/\\\'/g;
    }
    if (   defined($value)
        && defined( $fprank{$fb_id}{ $ex_id . $type . $value } ) )
    {
        return $fprank{$fb_id}{ $ex_id . $type . $value };
    }
    else {
        if ( defined( $fprank{$fb_id}{ $ex_id . $type } ) ) {
            $fprank{$fb_id}{ $ex_id . $type } += 1;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $ex_id . $type . $value } =
                  $fprank{$fb_id}{ $ex_id . $type };
            }
            return $fprank{$fb_id}{ $ex_id . $type };
        }
        else {
            if ( defined($value) ) {
                my $statement = "select max(feature_interactionprop.rank) 
                        from feature_interaction, feature, cv, interaction, cvterm cvterm2, feature_interactionprop 
			where feature_interaction.feature_id=feature.feature_id 
                        and feature.uniquename= ?  
                        and feature_interactionprop.feature_interaction_id=feature_interaction.feature_interaction_id 
			and feature_interactionprop.type_id=cvterm2.cvterm_id and cvterm2.name='$type' 
                        and cvterm2.cv_id=cv.cv_id and cv.name='$cv' 
			and feature_interaction.interaction_id=interaction.interaction_id 
			and interaction.uniquename='$ex_id' 
                        and feature_interactionprop.value= E'$value'";

                #print STDERR "$statement\n";
                my $fc_el = $dbh->prepare($statement);
                $fc_el->bind_param( 1, $fb_id );
                $fc_el->execute;
                my $f_r = $fc_el->fetchrow_array;
                if ( defined($f_r) ) {
                    $fprank{$fb_id}{ $ex_id . $type . $value } = $f_r;
                    return $f_r;
                }
            }
            my $state = "select max(feature_interactionprop.rank) 
                        from feature_interaction, feature, cv, interaction, cvterm cvterm2, feature_interactionprop 
			where feature_interaction.feature_id=feature.feature_id 
                        and feature.uniquename= ?
                        and feature_interactionprop.feature_interaction_id=feature_interaction.feature_interaction_id 
			and feature_interactionprop.type_id=cvterm2.cvterm_id and cvterm2.name='$type' 
                        and cvterm2.cv_id=cv.cv_id and cv.name='$cv' 
			and feature_interaction.interaction_id=interaction.interaction_id";

            my $fb_el = $dbh->prepare($state);
            $fb_el->bind_param( 1, $fb_id );
            $fb_el->execute;
            while ( my $p_r = $fb_el->fetchrow_array ) {
                if ( $p_r ne '' ) {
                    $rank = $p_r;
                    $rank++;
                }
            }
            $fprank{$fb_id}{ $ex_id . $type } = $rank;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $ex_id . $type . $value } = $rank;
            }
            return $rank;
        }
    }
    return $rank;
}

sub get_library_featureprop_rank {
    my $dbh   = shift;
    my $fb_id = shift;
    my $cv    = shift;
    my $ex_id = shift;
    my $type  = shift;
    my $value = shift;
    my $rank  = 0;
    if ( defined($value) ) {
        $value =~ s/\\/\\\\/g;
        $value =~ s/\'/\\\'/g;
    }
    if (   defined($value)
        && defined( $fprank{$fb_id}{ $ex_id . $type . $value } ) )
    {
        return $fprank{$fb_id}{ $ex_id . $type . $value };
    }
    else {
        if ( defined( $fprank{$fb_id}{ $ex_id . $type } ) ) {
            $fprank{$fb_id}{ $ex_id . $type } += 1;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $ex_id . $type . $value } =
                  $fprank{$fb_id}{ $ex_id . $type };
            }
            return $fprank{$fb_id}{ $ex_id . $type };
        }
        else {
            if ( defined($value) ) {
                my $statement = "select max(library_featureprop.rank) 
                        from library_feature, feature, cv, library, cvterm cvterm2, library_featureprop 
			where library_feature.feature_id=feature.feature_id 
                        and feature.uniquename='$fb_id' 
                        and library_featureprop.library_feature_id=library_feature.library_feature_id 
			and library_featureprop.type_id=cvterm2.cvterm_id and cvterm2.name='$type' 
                        and cvterm2.cv_id=cv.cv_id and cv.name='$cv' 
			and library_feature.library_id=library.library_id 
			and library.uniquename='$ex_id' 
                        and library_featureprop.value= E'$value'";

                #print STDERR "$statement\n";
                my $fc_el = $dbh->prepare($statement);
                $fc_el->execute;
                my $f_r = $fc_el->fetchrow_array;
                if ( defined($f_r) ) {
                    $fprank{$fb_id}{ $ex_id . $type . $value } = $f_r;
                    return $f_r;
                }
            }
            my $state = "select max(library_featureprop.rank) 
                        from library_feature, feature, cv, library, cvterm cvterm2, library_featureprop 
			where library_feature.feature_id=feature.feature_id 
                        and feature.uniquename='$fb_id' 
                        and library_featureprop.library_feature_id=library_feature.library_feature_id 
			and library_featureprop.type_id=cvterm2.cvterm_id and cvterm2.name='$type' 
                        and cvterm2.cv_id=cv.cv_id and cv.name='$cv' 
			and library_feature.library_id=library.library_id";

            my $fb_el = $dbh->prepare($state);
            $fb_el->execute;
            while ( my $p_r = $fb_el->fetchrow_array ) {
                if ( $p_r ne '' ) {
                    $rank = $p_r;
                    $rank++;
                }
            }
            $fprank{$fb_id}{ $ex_id . $type } = $rank;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $ex_id . $type . $value } = $rank;
            }
            return $rank;
        }
    }
    return $rank;
}

sub get_expression_for_interaction_expression {
    my $dbh    = shift;
    my $unique = shift;
    my $pub    = shift;
    my @result = ();
    my $statement =
"select expression.uniquename from expression, interaction i, interaction_expression ie, pub
        where  i.uniquename = '$unique' and i.interaction_id = ie.interaction_id and ie.expression_id = expression.expression_id 
        and ie.pub_id=pub.pub_id and pub.uniquename='$pub'";

    #print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ($exp) = $nmm->fetchrow_array ) {
        push( @result, $exp );

    }
    $nmm->finish;
    return @result;
}

sub get_expression_for_feature_expression {
    my $dbh    = shift;
    my $unique = shift;
    my $pub    = shift;
    my @result = ();
    my $statement =
"select expression.uniquename from expression, feature f, feature_expression fe, pub
        where  f.uniquename = '$unique' and f.feature_id = fe.feature_id and fe.expression_id = expression.expression_id 
        and fe.pub_id=pub.pub_id and pub.uniquename='$pub'";

    #print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ($exp) = $nmm->fetchrow_array ) {
        push( @result, $exp );

    }
    $nmm->finish;
    return @result;
}

sub get_expression_for_library_expression {
    my $dbh    = shift;
    my $unique = shift;
    my $pub    = shift;
    my @result = ();
    my $statement =
"select expression.uniquename from expression, library l, library_expression le, pub
        where  l.uniquename = '$unique' and l.library_id = le.library_id and le.expression_id = expression.expression_id 
        and le.pub_id=pub.pub_id and pub.uniquename='$pub'";

    #print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ($exp) = $nmm->fetchrow_array ) {
        push( @result, $exp );

    }
    $nmm->finish;
    return @result;
}

sub delete_libraryprop {
    my $doc  = shift;
    my $rank = shift;
    my $f_id = shift;
    my $type = shift;

    my $fp = create_ch_libraryprop(
        doc        => $doc,
        library_id => $f_id,
        rank       => $rank,
        type       => $type
    );

    $fp->setAttribute( 'op', 'delete' );

    my $out = dom_toString($fp);
    $fp->dispose();
    return $out;
}

sub delete_interactionprop {
    my $doc  = shift;
    my $rank = shift;
    my $f_id = shift;
    my $type = shift;

    my $fp = create_ch_interactionprop(
        doc            => $doc,
        interaction_id => $f_id,
        rank           => $rank,
        type           => $type
    );

    $fp->setAttribute( 'op', 'delete' );

    my $out = dom_toString($fp);
    $fp->dispose();
    return $out;
}

sub delete_feature_interactionprop {
    my $doc  = shift;
    my $rank = shift;
    my $f_id = shift;
    my $type = shift;

    my $fname   = shift;
    my $genus   = shift;
    my $species = shift;
    my $ftype   = shift;
    my $role    = shift;
    my $cv      = shift;

    my $fp = create_ch_feature_interactionprop(
        doc            => $doc,
        interaction_id => $f_id,
        rank           => $rank,
        type           => $type,
        feature_id     => create_ch_feature(
            doc        => $doc,
            uniquename => $fname,
            genus      => $genus,
            species    => $species,
            type       => $ftype,
        ),
        role_id => create_ch_cvterm( doc => $doc, cv => $cv, name => $role ),
    );

    $fp->setAttribute( 'op', 'delete' );

    my $out = dom_toString($fp);
    $fp->dispose();
    return $out;
}

sub delete_cell_lineprop {
    my $doc  = shift;
    my $rank = shift;
    my $f_id = shift;
    my $type = shift;

    my $fp = create_ch_cell_lineprop(
        doc          => $doc,
        cell_line_id => $f_id,
        rank         => $rank,
        type         => $type
    );

    $fp->setAttribute( 'op', 'delete' );

    my $out = dom_toString($fp);
    $fp->dispose();
    return $out;
}

sub delete_featureprop {
    my $doc  = shift;
    my $rank = shift;
    my $f_id = shift;
    my $type = shift;
    my $cv   = shift;

    if ( !defined($cv) ) {
        $cv = 'property type';
    }

    my $fp = create_ch_featureprop(
        doc        => $doc,
        feature_id => $f_id,
        rank       => $rank,
        cvname     => $cv,
        type       => $type
    );

    $fp->setAttribute( 'op', 'delete' );

    my $out = dom_toString($fp);
    $fp->dispose();
    return $out;
}

sub delete_interactionprop_pub {
    my $doc  = shift;
    my $rank = shift;
    my $f_id = shift;
    my $type = shift;
    my $pub  = shift;

    my $fp = create_ch_interactionprop(
        doc            => $doc,
        interaction_id => $f_id,
        rank           => $rank,
        type           => $type
    );

    my $fpp = create_ch_interactionprop_pub( doc => $doc, pub_id => $pub );
    $fpp->setAttribute( 'op', 'delete' );

    $fp->appendChild($fpp);
    my $out = dom_toString($fp);
    $frnum{$f_id}{$type}{$rank}++;
    $fp->dispose();
    return $out;
}

sub delete_libraryprop_pub {
    my $doc  = shift;
    my $rank = shift;
    my $f_id = shift;
    my $type = shift;
    my $pub  = shift;

    my $fp = create_ch_libraryprop(
        doc        => $doc,
        library_id => $f_id,
        rank       => $rank,
        type       => $type
    );

    my $fpp = create_ch_libraryprop_pub( doc => $doc, pub_id => $pub );
    $fpp->setAttribute( 'op', 'delete' );

    $fp->appendChild($fpp);
    my $out = dom_toString($fp);
    $frnum{$f_id}{$type}{$rank}++;
    $fp->dispose();
    return $out;
}

sub delete_cell_lineprop_pub {
    my $doc  = shift;
    my $rank = shift;
    my $f_id = shift;
    my $type = shift;
    my $pub  = shift;

    my $fp = create_ch_cell_lineprop(
        doc          => $doc,
        cell_line_id => $f_id,
        rank         => $rank,
        type         => $type
    );

    my $fpp = create_ch_cell_lineprop_pub( doc => $doc, pub_id => $pub );
    $fpp->setAttribute( 'op', 'delete' );

    $fp->appendChild($fpp);
    my $out = dom_toString($fp);
    $frnum{$f_id}{$type}{$rank}++;
    $fp->dispose();
    return $out;
}

sub get_cell_line_by_library_pub {
    my $dbh     = shift;
    my $library = shift;
    my $type    = shift;
    my $pub     = shift;

    my $cellq = $dbh->prepare(
        sprintf(
"SELECT cl.uniquename, cl.organism_id FROM cell_line_library cll, cell_line cl, cell_line_libraryprop cllp, library l, pub p, cvterm cvt, cv where cll.cell_line_id=cl.cell_line_id and l.library_id=cll.library_id and l.uniquename=? and cll.cell_line_library_id = cllp.cell_line_library_id and cllp.type_id = cvt.cvterm_id and cvt.cv_id = cv.cv_id and cv.name = 'cell_line_libraryprop type' and cvt.name = ? and  cl.pub_id=cll.pub_id and p.uniquename=?"
        )
    );
    $cellq->bind_param( 1, $library );
    $cellq->bind_param( 2, $type );
    $cellq->bind_param( 3, $pub );
    $cellq->execute;

    if ( $cellq->rows != 1 ) {
        print STDERR "ERROR: the cell line library row is not 1\n";
    }
    my ( $cu, $co ) = $cellq->fetchrow_array;

    return ( $cu, $co );
}

sub get_cell_line_by_interaction_pub {
    my $dbh         = shift;
    my $interaction = shift;
    my $pub         = shift;

    my $cellq = $dbh->prepare(
        sprintf(
"SELECT cl.uniquename, cl.organism_id FROM interaction_cell_line cli, cell_line cl, interaction i, pub p where cli.cell_line_id=cl.cell_line_id and i.interaction_id=cli.interaction_id and i.uniquename=? and p.pub_id=cli.pub_id and p.uniquename=?"
        )
    );
    $cellq->bind_param( 1, $interaction );
    $cellq->bind_param( 2, $pub );
    $cellq->execute;
    if ( $cellq->rows != 1 ) {
        print STDERR "ERROR: the cell line interaction row is not 1\n";
    }
    my ( $cu, $co ) = $cellq->fetchrow_array;
    return ( $cu, $co );
}

sub get_library_by_interaction_pub {
    my $dbh         = shift;
    my $interaction = shift;
    my $pub         = shift;

    my $libq = $dbh->prepare(
        sprintf(
"SELECT l.uniquename, l.organism_id, l.type_id FROM library_interaction li, interaction i, library l, pub p where li.interaction_id=i.interaction_id and l.library_id=li.library_id and i.uniquename=? and p.pub_id=li.pub_id and p.uniquename=?"
        )
    );
    $libq->bind_param( 1, $interaction );
    $libq->bind_param( 2, $pub );
    $libq->execute;
    if ( $libq->rows != 1 ) {
        print STDERR "ERROR: the interaction library row is not 1\n";
    }
    my ( $lu, $lo, $lt ) = $libq->fetchrow_array;

    return ( $lu, $lo, $lt );
}

sub get_library_for_library_feature {
    my $dbh     = shift;
    my $feature = shift;

    my $libq = $dbh->prepare(
        sprintf(
"SELECT l.uniquename FROM library_feature lf, feature f, library l where lf.feature_id=f.feature_id and l.library_id=lf.library_id and f.uniquename=? "
        )
    );
    $libq->bind_param( 1, $feature );
    $libq->execute;
    if ( $libq->rows != 1 ) {
        print STDERR "ERROR: the library_feature row is not 1\n";
    }
    my ($lu) = $libq->fetchrow_array;
    return ($lu);
}

sub delete_featureprop_pub {
    my $doc  = shift;
    my $rank = shift;
    my $f_id = shift;
    my $type = shift;
    my $pub  = shift;

    #        print STDERR "CHECK: in delete_featureprop_pub\n";
    my $fp = create_ch_featureprop(
        doc        => $doc,
        feature_id => $f_id,
        rank       => $rank,
        type       => $type
    );
    my $fpp = create_ch_featureprop_pub( doc => $doc, pub_id => $pub );
    $fpp->setAttribute( 'op', 'delete' );

    $fp->appendChild($fpp);
    my $out = dom_toString($fp);

    $frnum{$f_id}{$type}{$rank}++;
    $fp->dispose();
    print STDERR "CHECK: leaving delete_featureprop_pub\n";

    return $out;
}

sub get_featureloc_ukeys_bypub {
    my $dbh     = shift;
    my $feature = shift;
    my $pub     = shift;

    #ARGS embedded '
    $feature =~ s/\'/\\\'/g;

    my $statement =
"select featureloc.locgroup, featureloc.rank from featureloc, featureloc_pub, feature, pub where feature.feature_id=featureloc.feature_id and feature.uniquename=E'$feature' and pub.pub_id=featureloc_pub.pub_id and pub.uniquename='$pub' and featureloc.featureloc_id=featureloc_pub.featureloc_id";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $num = $nmm->rows;
    if ( $num != 1 ) {
        print STDERR
          "ERROR: there is not/only one featureloc for $feature, $pub\n";
        return '';
    }
    else {
        my ( $group, $rank ) = $nmm->fetchrow_array;

        return ( $group, $rank );
    }
}

sub get_max_tableprop_rank {
    my $dbh    = shift;
    my $table  = shift;
    my $unique = shift;
    my $type   = shift;
    my $value  = shift;
    my $rank;

    if ( exists( $fprank{$unique}{ $type . $value } ) ) {
        $rank = $fprank{$unique}{ $type . $value };
        return $rank;
    }
    $value =~ s/\\/\\\\/g;
    $value =~ s/\'/\\\'/g;
    $value =~ s/\|/\\\|/g;

    my $statement =
        "select rank from $table"
      . "prop, $table, cvterm,cv where $table"
      . ".uniquename='$unique' and $table"
      . "prop.$table"
      . "_id=$table"
      . ".$table"
      . "_id and cvterm.name='$type' and cvterm.cvterm_id="
      . $table
      . "prop.type_id and $table"
      . "prop.value= E'$value';";

    # print STDERR $statement,"\n";
    my $fp_p = $dbh->prepare($statement);
    $fp_p->execute;
    $rank = $fp_p->fetchrow_array;
    $fp_p->finish;
    if ( defined($rank) ) {
        $fprank{$unique}{ $type . $value } = $rank;
        return $rank;
    }
    else {
        $statement =
            "select max(rank) from $table"
          . "prop, $table, cvterm,cv where $table"
          . ".uniquename='$unique' and $table"
          . "prop.$table"
          . "_id=$table" . "."
          . $table
          . "_id and cvterm.name='$type' and cvterm.cvterm_id="
          . $table
          . "prop.type_id;";

        # print $statement, "\n";
        my $fr_r = $dbh->prepare($statement);
        $fr_r->execute;
        $rank = $fr_r->fetchrow_array;

        if ( exists( $fprank{$unique}{$type} ) ) {

            if ( defined($rank) && $rank >= $fprank{$unique}{$type} ) {
                $fprank{$unique}{$type} = $rank + 1;
            }
            else {
                $fprank{$unique}{$type}++;
            }

        }
        else {
            if ( !defined($rank) ) {
                $fprank{$unique}{$type} = 0;
            }
            else {
                $fprank{$unique}{$type} = $rank + 1;
            }
        }
        $fprank{$unique}{ $type . $value } = $fprank{$unique}{$type};
        return $fprank{$unique}{$type};
    }

}

sub get_max_cell_lineprop_rank {
    my $dbh    = shift;
    my $unique = shift;
    my $type   = shift;
    my $value  = shift;
    my $rank;

    if ( exists( $fprank{$unique}{ $type . $value } ) ) {
        $rank = $fprank{$unique}{ $type . $value };
        return $rank;
    }
    $value =~ s/\\/\\\\/g;
    $value =~ s/\'/\\\'/g;
    $value =~ s/\|/\\\|/g;

    my $statement = "select rank from cell_lineprop, cell_line, cvterm,cv
  where cell_line.uniquename='$unique' and
  cell_lineprop.cell_line_id=cell_line.cell_line_id and cvterm.name='$type'
	  and cv.name='cell_lineprop type' and cv.cv_id=cvterm.cv_id and
  cvterm.cvterm_id=cell_lineprop.type_id and cell_lineprop.value= E'$value';";

    #print STDERR $statement,"\n";
    my $fp_p = $dbh->prepare($statement);
    $fp_p->execute;
    $rank = $fp_p->fetchrow_array;
    $fp_p->finish;
    if ( defined($rank) ) {
        $fprank{$unique}{ $type . $value } = $rank;
        return $rank;
    }
    else {
        $statement =
"select max(rank) from cell_lineprop, cell_line, cvterm,cv where cell_line.uniquename='$unique' and cell_lineprop.cell_line_id=cell_line.cell_line_id and cvterm.name='$type' and cv.name='cell_lineprop type' and cv.cv_id=cvterm.cv_id and cvterm.cvterm_id=cell_lineprop.type_id;";

        my $fr_r = $dbh->prepare($statement);
        $fr_r->execute;
        $rank = $fr_r->fetchrow_array;

        if ( exists( $fprank{$unique}{$type} ) ) {

            if ( defined($rank) && $rank >= $fprank{$unique}{$type} ) {
                $fprank{$unique}{$type} = $rank + 1;
            }
            else {
                $fprank{$unique}{$type}++;
            }

        }
        else {
            if ( !defined($rank) ) {
                $fprank{$unique}{$type} = 0;
            }
            else {
                $fprank{$unique}{$type} = $rank + 1;
            }
        }
        $fprank{$unique}{ $type . $value } = $fprank{$unique}{$type};
        return $fprank{$unique}{$type};
    }
}

sub get_max_libraryprop_rank {
    my $dbh    = shift;
    my $unique = shift;
    my $type   = shift;
    my $value  = shift;
    my $rank;

    if ( exists( $fprank{$unique}{ $type . $value } ) ) {
        $rank = $fprank{$unique}{ $type . $value };
        return $rank;
    }
    $value =~ s/\\/\\\\/g;
    $value =~ s/\'/\\\'/g;
    $value =~ s/\|/\\\|/g;

    my $statement = "select rank from libraryprop, library, cvterm,cv
  where library.uniquename='$unique' and
  libraryprop.library_id=library.library_id and cvterm.name='$type'
	  and cv.name='property type' and cv.cv_id=cvterm.cv_id and
  cvterm.cvterm_id=libraryprop.type_id and libraryprop.value= E'$value';";

    #print STDERR $statement,"\n";
    my $fp_p = $dbh->prepare($statement);
    $fp_p->execute;
    $rank = $fp_p->fetchrow_array;
    $fp_p->finish;
    if ( defined($rank) ) {
        $fprank{$unique}{ $type . $value } = $rank;
        return $rank;
    }
    else {
        $statement =
"select max(rank) from libraryprop, library, cvterm,cv where library.uniquename='$unique' and libraryprop.library_id=library.library_id and cvterm.name='$type' and cv.name='property type' and cv.cv_id=cvterm.cv_id and cvterm.cvterm_id=libraryprop.type_id;";

        my $fr_r = $dbh->prepare($statement);
        $fr_r->execute;
        $rank = $fr_r->fetchrow_array;

        if ( exists( $fprank{$unique}{$type} ) ) {

            if ( defined($rank) && $rank >= $fprank{$unique}{$type} ) {
                $fprank{$unique}{$type} = $rank + 1;
            }
            else {
                $fprank{$unique}{$type}++;
            }

        }
        else {
            if ( !defined($rank) ) {
                $fprank{$unique}{$type} = 0;
            }
            else {
                $fprank{$unique}{$type} = $rank + 1;
            }
        }
        $fprank{$unique}{ $type . $value } = $fprank{$unique}{$type};
        return $fprank{$unique}{$type};
    }
}

sub get_max_interactionprop_rank {
    my $dbh    = shift;
    my $unique = shift;
    my $type   = shift;
    my $value  = shift;
    my $rank;

    if ( exists( $fprank{$unique}{ $type . $value } ) ) {
        $rank = $fprank{$unique}{ $type . $value };
        return $rank;
    }
    $value =~ s/\\/\\\\/g;
    $value =~ s/\'/\\\'/g;
    $value =~ s/\|/\\\|/g;

    my $statement =
      "select max(rank) from interactionprop, interaction, cvterm,cv
  where interaction.uniquename='$unique' and
  interactionprop.interaction_id=interaction.interaction_id and cvterm.name='$type'
	  and cv.name='interaction property type' and cv.cv_id=cvterm.cv_id and
  cvterm.cvterm_id=interactionprop.type_id and interactionprop.value= E'$value';";

    #print STDERR $statement,"\n";
    my $fp_p = $dbh->prepare($statement);
    $fp_p->execute;
    $rank = $fp_p->fetchrow_array;
    $fp_p->finish;
    if ( defined($rank) ) {
        $fprank{$unique}{ $type . $value } = $rank;
        return $rank;
    }
    else {
        $statement =
"select max(rank) from interactionprop, interaction, cvterm,cv where interaction.uniquename='$unique' and interactionprop.interaction_id = interaction.interaction_id and cvterm.name='$type' and cv.name='interaction property type' and cv.cv_id=cvterm.cv_id and cvterm.cvterm_id=interactionprop.type_id;";

        my $fr_r = $dbh->prepare($statement);
        $fr_r->execute;
        $rank = $fr_r->fetchrow_array;

        if ( exists( $fprank{$unique}{$type} ) ) {

            if ( defined($rank) && $rank >= $fprank{$unique}{$type} ) {
                $fprank{$unique}{$type} = $rank + 1;
            }
            else {
                $fprank{$unique}{$type}++;
            }

        }
        else {
            if ( !defined($rank) ) {
                $fprank{$unique}{$type} = 0;
            }
            else {
                $fprank{$unique}{$type} = $rank + 1;
            }
        }
        $fprank{$unique}{ $type . $value } = $fprank{$unique}{$type};
        return $fprank{$unique}{$type};
    }
}

sub get_max_featureprop_rank {
    my $dbh    = shift;
    my $unique = shift;
    my $type   = shift;
    my $value  = shift;
    my $cvname = shift || 'property type';
    my $rank;
    
    if ( exists( $fprank{$unique}{ $type . $value } ) ) {
        $rank = $fprank{$unique}{ $type . $value };
        return $rank;
    }
    $value =~ s/\\/\\\\/g;
    $value =~ s/\'/\\\'/g;
    $value =~ s/\|/\\\|/g;
    $value = conversupdown($value);

    #ARGS embedded '
    my $nunique = $unique;
    $nunique =~ s/\'/\\\'/g;

    my $statement = "select rank from featureprop, feature, cvterm,cv
  where feature.uniquename=E'$nunique' and
  featureprop.feature_id=feature.feature_id and cvterm.name='$type'
	  and cv.name='$cvname' and cv.cv_id=cvterm.cv_id and
  cvterm.cvterm_id=featureprop.type_id and featureprop.value= E'$value';";

    #print STDERR $statement,"\n";
    my $fp_p = $dbh->prepare($statement);
    $fp_p->execute;
    $rank = $fp_p->fetchrow_array;
    $fp_p->finish;
    if ( defined($rank) ) {
        $fprank{$unique}{ $type . $value } = $rank;
        return $rank;
    }
    else {
        $statement =
"select max(rank) from featureprop, feature, cvterm,cv where feature.uniquename=E'$nunique' and featureprop.feature_id=feature.feature_id and cvterm.name='$type' and (cv.name='$cvname' or cv.name='annotation property type')  and cv.cv_id=cvterm.cv_id and cvterm.cvterm_id=featureprop.type_id;";

        my $fr_r = $dbh->prepare($statement);
        $fr_r->execute;
        $rank = $fr_r->fetchrow_array;

        if ( exists( $fprank{$unique}{$type} ) ) {

            if ( defined($rank) && $rank >= $fprank{$unique}{$type} ) {
                $fprank{$unique}{$type} = $rank + 1;
            }
            else {
                $fprank{$unique}{$type}++;
            }

        }
        else {
            if ( !defined($rank) ) {
                $fprank{$unique}{$type} = 0;
            }
            else {
                $fprank{$unique}{$type} = $rank + 1;
            }
        }
        $fprank{$unique}{ $type . $value } = $fprank{$unique}{$type};
        return $fprank{$unique}{$type};
    }

}

sub get_feat_ukeys_by_uname {
    my $dbh         = shift;
    my $name        = shift;
    my $is_analysis = shift;
    my $genus       = '';
    my $species     = '';
    my $type        = '';

    #ARGS embedded " and what not
    $name =~ s/\'/\\\'/g;

    my $statement = "select organism.genus, organism.species,cvterm.name from
feature,organism,cvterm where feature.uniquename=E'$name' and
feature.organism_id=organism.organism_id and
cvterm.cvterm_id=feature.type_id and  feature.is_obsolete='f'";

    if ( defined($is_analysis) ) {
        $statement .= " and feature.is_analysis='$is_analysis'";
    }

    # else{
    #   $statement.=" and feature.is_analysis='f'";
    # }
    #print STDERR "===$statement===\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num > 1 ) {
        print STDERR
          "Warning: duplicate uniquename $name \n$statement\n exiting...\n";
        return 2;

        # exit(0);
    }
    elsif ( $id_num == 0 ) {
        return (0);
    }
    elsif ( $id_num == 1 ) {
        ( $genus, $species, $type ) = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return ( $genus, $species, $type );
}

sub get_feature_by_cell_line_pub {
    my $dbh     = shift;
    my $cunique = shift;
    my $pub     = shift;
    my @result  = ();

    my $statement = "select feature.uniquename from 
feature, cell_line_feature, cell_line, pub 
where cell_line.uniquename='$cunique' and cell_line.cell_line_id = cell_line_feature.cell_line_id and cell_line_feature.pub_id = pub.pub_id 
and cell_line_feature.feature_id = feature.feature_id and feature.is_obsolete='f' and feature.is_analysis = 'f' ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ($funame) = $nmm->fetchrow_array ) {
        push( @result, $funame );
    }
    $nmm->finish;
    return @result;
}

sub create_doc_element {
    my $doc     = shift;
    my $elname  = shift;
    my $elvalue = shift;

    my $el     = $doc->createElement($elname);
    my $eldata = $doc->createTextNode($elvalue);
    $el->appendChild($eldata);

    return $el;
}

sub validate_go {
    my $dbh     = shift;
    my $go_name = shift;
    my $go_id   = shift;
    my $go_cv   = shift;
    $go_name = $dbh->quote($go_name);
    $go_cv   = $dbh->quote($go_cv);

    #   $go_name=~s/\\/\\\\/g;
    #   $go_name=~s/\'/\\\'/g;
    my $statement =
"select dbxref.accession, db.name from cvterm,cv,db, dbxref where cvterm.dbxref_id=dbxref.dbxref_id and cvterm.name=$go_name and cvterm.cv_id=cv.cv_id and cv.name=$go_cv and db.db_id=dbxref.db_id and cvterm.is_obsolete=0";

    #    print STDERR $statement,"\n";
    my $go = $dbh->prepare($statement);
    $go->execute;
    my ( $acc, $db ) = $go->fetchrow_array;
    if ( !defined($acc) ) {
        print STDERR "ERROR:  $go_id is not $go_cv:$go_name--\n";
    }
    else {
        my $id = $db . ':' . $acc;
        if ( $id ne $go_id ) {
            print STDERR "ERROR:  $go_id is not $go_cv:$go_name--\n";
        }
    }
    $go->finish;
}

sub delete_featureloc {
    my $dbh    = shift;
    my $doc    = shift;
    my $unique = shift;
    my $pub    = shift;
    my $out    = '';

    my @keys = get_ukeys_from_featureloc( $dbh, $unique, $pub );

    # $frnum{$unique}{featureloc}+=@keys;
    foreach my $key (@keys) {
        my $loc  = $key->{locgroup};
        my $rank = $key->{rank};
        my $num  = get_pub_nums_for_featureloc( $dbh, $unique, $loc, $rank );
        my $fl   = create_ch_featureloc(
            doc        => $doc,
            locgroup   => $loc,
            rank       => $rank,
            feature_id => $unique
        );
        if ( $num == 0 && $pub eq 'FBrf0000000' ) {
            $fl->setAttribute( 'op', 'delete' );
        }
        elsif ( $num == 1 ) {
            if ( $pub ne 'FBrf0000000' ) {
                $fl->setAttribute( 'op', 'delete' );
                $frnum{$unique}{featureloc} += 1;
            }
        }
        else {
            my $flp =
              create_ch_featureloc_pub( doc => $doc, uniquename => $pub );
            $flp->setAttribute( 'op', 'delete' );
            $fl->appendChild($flp);
        }
        $out .= dom_toString($fl);
        $fl->dispose();
    }

    return $out;
}

sub get_lib_unique {
    my $doc      = shift;
    my $dbh      = shift;
    my $c_name   = shift;
    my $c_type   = shift;
    my $libxml   = '';
    my $c_unique = '';
    ( $c_unique, my $c_genus, my $c_species ) =
      get_feat_ukeys_by_name_type( $dbh, $c_name, $c_type );
    if ( $c_unique eq '0' ) {
        ( $c_unique, my $flag ) = get_tempid( 'cl', $c_name );
        $c_genus   = 'Drosophila';
        $c_species = 'melanogaster';
        if ( $flag != 1 ) {
            my $feat = create_ch_feature(
                doc        => $doc,
                uniquename => $c_unique,
                type       => $c_type,
                genus      => $c_genus,
                species    => $c_species,
                name       => $c_name,
                macro_id   => $c_unique,
                no_lookup  => 1
            );
            $libxml = dom_toString($feat);
        }
    }
    else {
        my $feat = create_ch_feature(
            doc        => $doc,
            uniquename => $c_unique,
            type       => $c_type,
            genus      => $c_genus,
            species    => $c_species,
            macro_id   => $c_unique
        );
        $fbids{$c_name} = $c_unique;
        $libxml = dom_toString($feat);
    }
    return ( $libxml, $c_unique );
}

sub get_GenBank_acc {
    my $dbh       = shift;
    my $doc       = shift;
    my $name      = shift;
    my $c_type    = shift;
    my $type      = '';
    my $acc       = '';
    my $o_genus   = '';
    my $o_species = '';
    my $out       = '';
    my $c_unique  = '';
    my $c_name    = '';
    my $add       = 0;
    my $feature;
    my $count  = 0;
    my $gb     = new Bio::DB::GenBank;
    my $libxml = '';
    my $query  = Bio::DB::Query::GenBank->new(
        -query => $name,
        -db    => 'nucleotide'
    );
    my $write = 0;
    my $seqio = $gb->get_Stream_by_query($query);
    $c_name = $name;
    ( $libxml, $c_unique ) = get_lib_unique( $doc, $dbh, $c_name, $c_type );

    if ( !$seqio->isa("Bio::Seq::RichSeqI") ) {
        print STDERR "ERROR, could not get sequence from NCBI\n";
    }
    while ( my $seq = $seqio->next_seq ) {
        print STDERR "in ", $seq->accession, "\n";
        if (   defined($seq)
            && !( $seq->accession =~ /N\w_\d+/ )
            && $seq->accession ne 'unknown' )
        {
            $count++;
            my $newname = '';
            my $seqname = '';

            my $keywords = join( ';', $seq->get_keywords() );

            #print STDERR "keyword--$keywords-\n";
            #print STDERR "in ", $seq->accession, "\n";
            $acc       = $seq->accession;
            $o_genus   = $seq->species->genus;
            $o_species = $seq->species->species;
            my ($date) = $seq->get_dates;
            $newname = $c_name;
            my ( $e_g, $e_s, $e_t ) =
              get_feat_ukeys_by_uname( $dbh, $seq->accession, 't' );
            if ( $e_g ne '0' ) {

                if ( $c_unique =~ /FBcl:temp/ ) {
                    print STDERR
                      "ERROR: EST/cDNA exists, but clone not exist\n";
                }
                if ( $e_t ne 'cDNA' && $e_t ne 'EST' ) {
                    print STDERR "Warning: $c_unique type is mRNA\n";
                    next;
                }
            }
            else {
                if ( $c_unique =~ /temp/ && $write == 0 ) {
                    $libxml .=
                      write_library_module( $doc, $dbh, $c_unique, $c_name,
                        $seq );
                    $write = 1;
                }
                if ( $keywords =~ /EST/ ) {
                    $type = 'EST';
                    if ( $seq->desc =~ /^(.*?)\s/ ) {
                        $seqname = $1;
                    }
                    if ( $seq->desc =~ /3\'/ || $seq->desc =~ /3prime/ ) {
                        if ( !( $name =~ /3prime/ ) ) {

                            $newname .= '.3prime';
                        }
                    }
                    elsif ( $seq->desc =~ /5\'/ || $seq->desc =~ /5prime/ ) {
                        if ( !( $name =~ /5prime/ ) ) {

                            $newname .= '.5prime';
                        }
                    }
                    if ( $seqname ne $newname ) {
                        print STDERR
"ERROR: EST name did not match $seqname, $newname (bounce)\n";
                        $newname = $seqname;
                        $c_name  = $newname;
                        $c_name =~ s/\.\dprime//;
                        ( $libxml, $c_unique ) =
                          get_lib_unique( $doc, $dbh, $c_name, $c_type );
                        $libxml .=
                          write_library_module( $doc, $dbh, $c_unique, $c_name,
                            $seq );
                        $write = 1;
                    }
                }
                elsif ( $keywords =~ /CDNA/i ) {
                    $type = 'cDNA';
                }
                else {
                    $type = 'mRNA';
                    print STDERR "Warning:", $seq->accession,
                      " $c_name type is mRNA\n";
                    next;
                }

                $feature = create_ch_feature(
                    doc         => $doc,
                    uniquename  => $seq->accession,
                    name        => $newname,
                    genus       => $seq->species->genus,
                    species     => $seq->species->species,
                    type        => $type,
                    residues    => $seq->seq,
                    seqlen      => length( $seq->seq ),
                    no_lookup   => 1,
                    is_analysis => 't',
                    macro_id    => $acc,
                    dbxref_id   => create_ch_dbxref(
                        doc       => $doc,
                        db        => 'GB',
                        accession => $acc,
                        version   => $seq->version,
                        no_lookup => 1
                    )
                );
                my $feature_dbxref = create_ch_feature_dbxref(
                    doc       => $doc,
                    db        => 'GB',
                    accession => $acc,
                    version   => $seq->version
                );
                $feature->appendChild($feature_dbxref);
                my $desc = 'gi|'
                  . $seq->primary_id . '|gb|'
                  . $seq->accession . '.'
                  . $seq->version . ' '
                  . $seq->desc
                  . 'organism: '
                  . $seq->species->genus . ' '
                  . $seq->species->species . ' ('
                  . $date . ')';
                my $featureprop = create_ch_featureprop(
                    doc   => $doc,
                    type  => 'description',
                    value => $desc
                );
                $feature->appendChild($featureprop);
                $out .= dom_toString($feature);

                if ( $add == 0 ) {
                    $out .= $libxml;
                    $add = 1;
                }
                $out .= dom_toString(
                    create_ch_fr(
                        doc          => $doc,
                        'subject_id' => $acc,
                        'object_id'  => $c_unique,
                        rtype        => 'partof'
                    )
                );
            }
        }
    }

    if ( $count eq '0' ) {
        print STDERR "ERROR: no sequence found for clone $name\n";
    }
    return ( $out, $c_unique );
}

sub write_library_module {
    my $ldoc      = shift;
    my $dbh       = shift;
    my $cl_unique = shift;
    my $name      = shift;
    my $query     = shift;

    my $cloneunique = '';
    my $myvector    = '';
    my $lvector     = '';
    my $out         = '';
    my $lib_type    = '';
    my ( $lib_id, $libname ) = &get_library_id( $name, $query->desc );
    $myvector = $lib_vector{$lib_id};
    if ( $lib_id eq '' ) {
        print "Error: library is null\n";
        return;
        return '';
    }
    else {
        ( $lib_id, my $tmp, my $tmp1, $lib_type ) =
          &get_lib_ukeys_by_name( $dbh, $lib_id );
        if ( $lib_id eq '' ) {
            print STDERR "ERROR: could not find library  $name\n";
            return '';
        }
    }
    if ( exists( $vector{$myvector} ) ) {
        $lvector = create_ch_feature(
            doc        => $ldoc,
            genus      => 'synthetic',
            species    => 'construct',
            uniquename => $vector{$myvector},
            type       => 'engineered_construct',
            macro_id   => $vector{$myvector}
        );
        $out .= dom_toString($lvector);

        my $s_fr = create_ch_fr(
            doc        => $ldoc,
            subject_id => $lvector,
            rtype      => 'partof',
            object_id  => $cl_unique
        );
        $out .= dom_toString($s_fr);
    }
    else {
        print STDERR "ERROR: vector not exists for $myvector;\n";
    }
    my $lib = create_ch_library(
        doc        => $ldoc,
        genus      => $query->species->genus,
        species    => $query->species->species,
        uniquename => $lib_id,
        type       => $lib_type,
        macro_id   => $lib_id
    );
    $out .= dom_toString($lib);
    my $lib_feature = create_ch_library_feature(
        doc        => $ldoc,
        library_id => $lib_id,
        feature_id => $cl_unique
    );

    $out .= dom_toString($lib_feature);
    return $out;
}

sub get_library_id {
    my $name = shift;
    my $desc = shift;

    my $lib     = '';
    my $libname = $name;
    if ( $name =~ /(.*)\./ ) {
        $libname = $1;
    }
    $name =~ /^(\w{2})(.*)/;
    my $header = $1;
    my $number = $2;

    if ( $desc =~ /^(.*?)\sCK01/ || $desc =~ /^(.*?)\sCK02/ ) {
        $lib = 'EK_EP';
    }
    elsif ( $desc =~ /^(.*?)\sMN08/ ) {
        $lib = 'EN';
    }
    elsif ( $desc =~ /^(.*?)\sML01/ ) {
        $lib = 'EC';
    }
    elsif ( $desc =~ /^([A-Z][a-z]+_\d+_.*?) / ) {
        $lib = 'CHQ';
    }
    elsif ( $libs =~ /$header/i ) {
        print STDERR "in header\n";
        if ( $header eq 'DM' ) {
            if ( $desc =~
                /(.*?)\s(.*)\sDrosophila melanogaster cDNA clone (.*),/ )
            {
                $lib     = $2;
                $libname = $3;
            }
        }
        elsif ( $header eq 'RC' ) {
            if ( $desc =~ /(.*?)\s(.*)\sDrosophila melanogaster cDNA,/ ) {
                $lib     = $2;
                $libname = $name;
            }
        }
        elsif ( $desc =~ /^Dmel_neb_/ ) {
            $lib = 'TTT_NEB';
        }
        elsif ( $desc =~ /^Dmel_dig_/ ) {
            $lib = 'TTT_DIG';
        }

        elsif ( $name =~ /^ESG01/ ) {
            $lib = 'ESG01';
        }
        elsif ( $header eq 'FG' ) {
            $lib = 'EG';
        }
        elsif ( $header eq 'GM' ) {

            if ( $number le '11496' ) {
                $lib = 'GM_pBS';
            }
            elsif ( $number ge '12101' ) {
                $lib = 'GM_pOT2';
            }
            else {
                print STDERR "Warning: undefined library $name\n";
                exit(0);
            }
        }
        elsif ( $header eq 'BP' ) {
            if (   $desc =~ /Drosophila melanogaster cDNA clone (.*) (\d)\',/
                || $desc =~ /Drosophila melanogaster cDNA clone (.*),/ )
            {
                $lib     = 'EG';
                $libname = $1 . '.' . $2 . 'prime';
                $libname =~ s/\.prime//;
            }
        }
        elsif ( $header eq 'HL' ) {
            if ( $number le '7796' ) {
                $lib = 'HL_pBS';
            }
            elsif ( $number ge '7801' ) {
                $lib = 'HL_pOT2';
            }
            else {
                print STDERR "Warning:undefined library $name\n";
                exit(0);
            }
        }
        elsif ( $header eq 'LD' ) {
            if ( $number le '21096' ) {
                $lib = 'LD_pBS';
            }
            elsif ( $number ge '21101' ) {
                $lib = 'LD_pOT2';
            }
        }
        elsif ( $header eq 'AI' ) {
            if ( $number =~ /^12/ ) {
                $lib = 'BK';
            }
            else {
                print STDERR "ERROR:undefined library  $name\n";
                exit(0);
            }
        }
        elsif ( $header eq 'BQ' ) {
            $lib = 'BK';
        }
        elsif ( $header eq 'AF' ) {
            if ( $number =~ /^083|171/ ) {
                $lib = 'AF';
            }
            else {
                print STDERR "ERROR: undefined library $name\n";
            }
        }
        elsif ( $header eq 'AA' ) {
            if ( $number >= 433187 && $number <= 433290 ) {
                $lib = 'ST';
            }
        }
        elsif ( $header eq 'CB' ) {
            if ( $number >= 305318 && $number <= 305318 ) {
                $lib = 'CB';
            }
        }
        elsif ( $header eq 'EK' || $header eq 'EP' ) {
            $lib = 'EK_EP';
        }
        else {
            $lib = uc($header);
            if ( $lib eq 'ES' ) {
                $lib = '';
            }
        }
    }
    return ( $lib, $libname );
}

sub get_pub_nums_for_featureloc {
    my $dbh      = shift;
    my $unique   = shift;
    my $locgroup = shift;
    my $rank     = shift;

    #ARGS embedded '
    $unique =~ s/\'/\\\'/g;

    my $statement = "select pub.uniquename from
	featureloc, feature,pub, featureloc_pub where featureloc.locgroup=$locgroup	and featureloc.rank=$rank and feature.uniquename=E'$unique' and
	feature.feature_id=featureloc.feature_id and
	featureloc_pub.pub_id=pub.pub_id and
	featureloc_pub.featureloc_id=featureloc.featureloc_id ;";

    #	print STDERR $statement,"\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $num = $nmm->rows;
    $nmm->finish;
    return $num;

}

sub get_cv_by_cvterm {
    my $dbh    = shift;
    my $cvterm = shift;

    $cvterm =~ s/\\/\\\\/g;
    $cvterm =~ s/\'/\\\'/g;
    my $statement = "select cv.name from cv, cvterm where
	cvterm.name= E'$cvterm' and cvterm.cv_id=cv.cv_id and cvterm.is_obsolete = 0 order by cv.cv_id;";

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $cv = $nmm->fetchrow_array;
    $nmm->finish;
    return $cv;
}

sub delete_genotype {
    my $dbh    = shift;
    my $unique = shift;
    my $doc    = shift;
    my $out    = '';
    my $statement =
"select genotype.genotype_id, genotype.uniquename from genotype, feature_genotype, feature
where feature.feature_id=feature_genotype.feature_id and genotype.genotype_id=feature_genotype.genotype_id and feature.uniquename='$unique'";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $gt_id, $gt_unique ) = $nmm->fetchrow_array ) {
        my $genotype =
          create_ch_genotype( doc => $doc, uniquename => $gt_unique );
        $genotype->setAttribute( 'op', 'delete' );
        $out .= dom_toString($genotype);
    }
    return $out;
}

sub update_feature_genotype {
    my $dbh     = shift;
    my $doc     = shift;
    my $unique  = shift;
    my $oldname = shift;
    my $newname = shift;
    my $out     = '';
    my $old     = convers($oldname);
    $old =~ s/([\'\#\"\[\]\|\\\/\(\)\+\-\.])/\\$1/g;
    my $statement =
"select genotype.genotype_id, genotype.uniquename from genotype, feature_genotype, feature
where feature.feature_id=feature_genotype.feature_id and genotype.genotype_id=feature_genotype.genotype_id and feature.uniquename='$unique'";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $gt_id, $gt_unique ) = $nmm->fetchrow_array ) {
        my $old_gt = $gt_unique;
        if ( !( $old_gt =~ s/$old/convers($newname)/ ) ) {
            print STDERR
              "ERROR: could not replace $old to $newname for $gt_id\n";
        }
        else {
            my @gts = split( /\s+/, $old_gt );
            @gts = sort @gts;
            my $genotype = join( ' ', @gts );
            my $new_gt   = $genotype;
            $new_gt =~ s/\\/\\\\/g;
            $new_gt =~ s/\'/\\\'/g;
            my $state =
"select genotype_id from genotype where uniquename= E'$new_gt' and genotype_id!=$gt_id";
            my $s_nmm = $dbh->prepare($state);
            $s_nmm->execute;

            if ( $s_nmm->rows != 0 ) {
                while ( my $id = $s_nmm->fetchrow_array ) {
                    print STDERR "ERROR: $gt_id will be same as gt $id\n";
                    print
"STATE: update phenstatement set genotype_id=$id where genotype_id=$gt_id;\n";
                    print
"STATE: update feature_genotype set genotype_id=$id where genotype_id=$gt_id;\n";
                    print
"STATE: update phendesc set genotype_id=$id where genotype_id=$gt_id\n;";
                    print
"STATE: update phenotype_comparison set genotype1_id=$id where genotype1_id=$gt_id;\n";
                    print
"STATE: update phenotype_comparison set genotype2_id=$id where genotype2_id=$gt_id;\n";
                    print
                      "STATE: delete from genotype where genotype_id=$gt_id;\n";
                }
            }
            else {
                my $geno = create_ch_genotype(
                    doc        => $doc,
                    uniquename => $gt_unique,
                    macro_id   => $gt_unique
                );
                my $new_geno =
                  create_doc_element( $doc, 'uniquename', $genotype );
                $new_geno->setAttribute( 'op', 'update' );
                $geno->appendChild($new_geno);
                $out .= dom_toString($geno);
                $fprank{genotype}{$gt_unique} = 1;
            }

        }

    }
    return $out;
}

sub get_ukeys_from_featureloc {
    my $dbh       = shift;
    my $unique    = shift;
    my $pub       = shift;
    my $statement = '';
    my @ukey      = ();

    #ARGS embedded '
    $unique =~ s/\'/\\\'/g;

    if ( $pub ne 'FBrf0000000' ) {
        $statement = "select locgroup,rank from featureloc,
		feature, featureloc_pub, pub
		where feature.feature_id=featureloc.feature_id and  
	   featureloc_pub.pub_id=pub.pub_id and
		feature.uniquename=E'$unique' and pub.uniquename='$pub' and
		featureloc.featureloc_id=featureloc_pub.featureloc_id;";

        #print $statement;
    }
    else {
        $statement = "select locgroup,rank from featureloc, feature
		where feature.feature_id=featureloc.feature_id and
		feature.uniquename=E'$unique';";
    }
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $locgroup, $rank ) = $nmm->fetchrow_array ) {
        my $keys = { locgroup => $locgroup, rank => $rank };

        # print STDERR $locgroup, $rank, "\n";
        push( @ukey, $keys );
    }
    $nmm->finish;
    return @ukey;

}

sub check_feature_synonym_is_current {
    my $dbh  = shift;
    my $fbid = shift;
    my $name = shift;
    my $type = shift;

    # print STDERR "DEBUG: check_feature_synonym_is_current -- input synonym $name , fbid $fbid, type $type";

    #    $name = decon(convers($name));
    $name = toutf($name);

    #    print STDERR "synonym after touft $name\n";

    my $statement = "select distinct synonym.synonym_sgml from
	feature_synonym, feature, synonym, cvterm where
	feature_synonym.feature_id=feature.feature_id and
	synonym.synonym_id=feature_synonym.synonym_id and
	cvterm.cvterm_id=synonym.type_id and feature.uniquename='$fbid' and
	cvterm.name='$type' and feature_synonym.is_current='t'";

    #print $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my $db_name = $nmm->fetchrow_array ) {

        if ( $db_name eq $name ) {

       #	    print STDERR "DEBUG: check_feature_synonym_is_current return a \n";
            return 'a';
        }
        else {
       #	    print STDERR "DEBUG: check_feature_synonym_is_current return b \n";
            return 'b';
        }
    }
    $nmm->finish;
    return 'b';
}

sub check_feature_synonym {
    my $dbh  = shift;
    my $fbid = shift;
    my $type = shift;
    my $num  = 0;

    my $statement = "select * from
	feature_synonym, feature, synonym, cvterm where
	feature_synonym.feature_id=feature.feature_id and
	synonym.synonym_id=feature_synonym.synonym_id and
	cvterm.cvterm_id=synonym.type_id and feature.uniquename='$fbid' and
	cvterm.name='$type' and feature_synonym.is_current='t'";

    #print $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub delete_library_synonym {
    my $dbh        = shift;
    my $doc        = shift;
    my $uname      = shift;
    my $pub        = shift;
    my $stype      = shift;
    my $is_current = shift;
    my $out        = '';
    $dbh->{pg_enable_utf8} = 1;
    my $statement = "select synonym.name,synonym.synonym_sgml,cvterm.name
	from library,synonym,library_synonym,pub, cvterm where library.uniquename='$uname' and library.library_id=library_synonym.library_id and  library_synonym.synonym_id=synonym.synonym_id and library_synonym.pub_id=pub.pub_id and pub.uniquename='$pub' and cvterm.cvterm_id=synonym.type_id and 
	cvterm.name='$stype'";

    if ( $is_current ne '' ) {
        $statement .= " and library_synonym.is_current='$is_current'";
    }
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $name, $sgml, $type ) = $nmm->fetchrow_array ) {

        my $fs = create_ch_library_synonym(
            doc        => $doc,
            library_id => $uname,
            synonym_id => create_ch_synonym(
                doc          => $doc,
                name         => $name,
                synonym_sgml => $sgml,
                type         => $type
            ),
            pub_id => $pub
        );
        $fs->setAttribute( 'op', 'delete' );
        $out .= dom_toString($fs);
        $fs->dispose();

    }
    $nmm->finish;

    #     print STDERR "delete library_synonym\n";
    return $out;

}

sub delete_cell_line_synonym {
    my $dbh        = shift;
    my $doc        = shift;
    my $uname      = shift;
    my $pub        = shift;
    my $stype      = shift;
    my $is_current = shift;
    my $out        = '';
    $dbh->{pg_enable_utf8} = 1;
    my $statement = "select synonym.name,synonym.synonym_sgml,cvterm.name
	from cell_line,synonym,cell_line_synonym,pub, cvterm where cell_line.uniquename='$uname' and cell_line.cell_line_id=cell_line_synonym.cell_line_id and  cell_line_synonym.synonym_id=synonym.synonym_id and cell_line_synonym.pub_id=pub.pub_id and pub.uniquename='$pub' and cvterm.cvterm_id=synonym.type_id and 
	cvterm.name='$stype'";

    if ( $is_current ne '' ) {
        $statement .= " and cell_line_synonym.is_current='$is_current'";
    }
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $name, $sgml, $type ) = $nmm->fetchrow_array ) {

        my $fs = create_ch_cell_line_synonym(
            doc          => $doc,
            cell_line_id => $uname,
            synonym_id   => create_ch_synonym(
                doc          => $doc,
                name         => $name,
                synonym_sgml => $sgml,
                type         => $type
            ),
            pub_id => $pub
        );
        $fs->setAttribute( 'op', 'delete' );
        $out .= dom_toString($fs);
        $fs->dispose();

    }
    $nmm->finish;

    #     print STDERR "delete cell_line_synonym\n";
    return $out;

}

sub delete_feature_synonym {
    my $dbh       = shift;
    my $doc       = shift;
    my $uname     = shift;
    my $pub       = shift;
    my $stype     = shift;
    my $out       = '';
    my $statement = "";

    $dbh->{pg_enable_utf8} = 1;

    if ( $pub eq 'unattributed' ) {
        $statement = "select synonym.name,synonym.synonym_sgml,cvterm.name
	from feature,synonym,feature_synonym,pub, cvterm where feature.uniquename='$uname' and feature.feature_id=feature_synonym.feature_id and feature_synonym.synonym_id=synonym.synonym_id and feature_synonym.pub_id=pub.pub_id and pub.uniquename='$pub' and feature_synonym.is_current = false and cvterm.cvterm_id=synonym.type_id and cvterm.name='$stype';";
    }
    else {
        $statement = "select synonym.name,synonym.synonym_sgml,cvterm.name
	from feature,synonym,feature_synonym,pub, cvterm where feature.uniquename='$uname' and feature.feature_id=feature_synonym.feature_id and feature_synonym.synonym_id=synonym.synonym_id and feature_synonym.pub_id=pub.pub_id and pub.uniquename='$pub' and cvterm.cvterm_id=synonym.type_id and cvterm.name='$stype';";
    }
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $name, $sgml, $type ) = $nmm->fetchrow_array ) {

        my $fs = create_ch_feature_synonym(
            doc        => $doc,
            feature_id => $uname,
            synonym_id => create_ch_synonym(
                doc          => $doc,
                name         => $name,
                synonym_sgml => $sgml,
                type         => $type
            ),
            pub_id => $pub
        );
        $fs->setAttribute( 'op', 'delete' );
        $out .= dom_toString($fs);
        $fs->dispose();

    }
    $nmm->finish;
    return $out;
}

sub update_library_synonym {
    my $dbh    = shift;
    my $doc    = shift;
    my $fbid   = shift;
    my $symbol = shift;
    my $s_type = shift;

    $dbh->{pg_enable_utf8} = 1;
    my $out = '';
    $symbol = &convers($symbol);
    $symbol = &decon($symbol);
    my $name = $symbol;
    $symbol =~ s/\\/\\\\/g;
    $symbol =~ s/\'/\\\'/g;
    my $statement = "select pub.uniquename, synonym.synonym_sgml from
	library_synonym, library, synonym,cvterm, pub where
	library.library_id=library_synonym.library_id and
	library.uniquename='$fbid' and synonym.type_id=cvterm.cvterm_id and
	cvterm.name='$s_type' and
	synonym.synonym_id=library_synonym.synonym_id and
	synonym.name= E'$symbol' and pub.pub_id=library_synonym.pub_id and
	library_synonym.is_current='t'";

    #print STDERR $statement;
    my $s_el = $dbh->prepare($statement);
    $s_el->execute;
    while ( my ( $pub, $sgml ) = $s_el->fetchrow_array ) {
        my $fs = create_ch_library_synonym(
            doc        => $doc,
            library_id => $fbid,
            synonym_id => create_ch_synonym(
                doc          => $doc,
                name         => $name,
                synonym_sgml => $sgml,
                type         => $s_type
            ),
            pub        => $pub,
            is_current => 'f'
        );
        $out .= dom_toString($fs);
        $fs->dispose();
    }
    $s_el->finish;
    return $out;
}

sub update_cell_line_synonym {
    my $dbh    = shift;
    my $doc    = shift;
    my $fbid   = shift;
    my $symbol = shift;
    my $s_type = shift;

    $dbh->{pg_enable_utf8} = 1;
    my $out = '';
    $symbol = &convers($symbol);
    $symbol = &decon($symbol);
    my $name = $symbol;
    $symbol =~ s/\\/\\\\/g;
    $symbol =~ s/\'/\\\'/g;
    my $statement = "select pub.uniquename, synonym.synonym_sgml from
	cell_line_synonym, cell_line, synonym,cvterm, pub where
	cell_line.cell_line_id=cell_line_synonym.cell_line_id and
	cell_line.uniquename='$fbid' and synonym.type_id=cvterm.cvterm_id and
	cvterm.name='$s_type' and
	synonym.synonym_id=cell_line_synonym.synonym_id and
	synonym.name= E'$symbol' and pub.pub_id=cell_line_synonym.pub_id and
	cell_line_synonym.is_current='t'";

    #print STDERR $statement;
    my $s_el = $dbh->prepare($statement);
    $s_el->execute;
    while ( my ( $pub, $sgml ) = $s_el->fetchrow_array ) {
        my $fs = create_ch_cell_line_synonym(
            doc          => $doc,
            cell_line_id => $fbid,
            synonym_id   => create_ch_synonym(
                doc          => $doc,
                name         => $name,
                synonym_sgml => $sgml,
                type         => $s_type
            ),
            pub        => $pub,
            is_current => 'f'
        );
        $out .= dom_toString($fs);
        $fs->dispose();
    }
    $s_el->finish;
    return $out;
}

sub add_feature_residue {
    my $ldoc    = $_[0];
    my $feature = $_[1];
    my $seq     = $_[2];
    $seq =~ s/\s+//g;

    my $rna_residue = $ldoc->createElement('residues');
    my $mrna_len    = length($seq);
    my $rna_seqlen  = $ldoc->createElement('seqlen');
    my $rna_text    = $ldoc->createTextNode($seq);
    $rna_residue->appendChild($rna_text);
    my $len_text = $ldoc->createTextNode($mrna_len);
    $rna_seqlen->appendChild($len_text);
    my $first = $feature->getFirstChild;

    $feature->insertBefore( $rna_seqlen,  $first );
    $feature->insertBefore( $rna_residue, $first );
    return $feature;
}

sub update_feature_synonym {
    my $dbh    = shift;
    my $doc    = shift;
    my $fbid   = shift;
    my $symbol = shift;
    my $s_type = shift;

    $dbh->{pg_enable_utf8} = 1;
    my $out = '';
    $symbol = &convers($symbol);
    $symbol = &decon($symbol);
    my $name = $symbol;
    $symbol =~ s/\\/\\\\/g;
    $symbol =~ s/\'/\\\'/g;
    my $statement = "select pub.uniquename, synonym.synonym_sgml from
	feature_synonym, feature, synonym,cvterm, pub where
	feature.feature_id=feature_synonym.feature_id and
	feature.uniquename='$fbid' and synonym.type_id=cvterm.cvterm_id and
	cvterm.name='$s_type' and
	synonym.synonym_id=feature_synonym.synonym_id and
	synonym.name= E'$symbol' and pub.pub_id=feature_synonym.pub_id and
	feature_synonym.is_current='t'";

    #print STDERR $statement;
    my $s_el = $dbh->prepare($statement);
    $s_el->execute;
    while ( my ( $pub, $sgml ) = $s_el->fetchrow_array ) {
        my $fs = create_ch_feature_synonym(
            doc        => $doc,
            feature_id => $fbid,
            synonym_id => create_ch_synonym(
                doc          => $doc,
                name         => $name,
                synonym_sgml => $sgml,
                type         => $s_type
            ),
            pub        => $pub,
            is_current => 'f'
        );
        $out .= dom_toString($fs);
        $fs->dispose();
    }
    $s_el->finish;
    return $out;

}

sub write_library_synonyms {
    my $doc         = shift;
    my $fbid        = shift;
    my $symbol      = shift;
    my $field       = shift;
    my $paper       = shift;
    my $s_type      = shift;
    my $is_current  = 0;
    my $is_internal = 0;
    my $out         = '';
    $symbol = &convers($symbol);
    my $sgml_symbol = &toutf($symbol);

    #print "SYMBOL ",$sgml_symbol,"\n";
    $symbol = &decon($symbol);
    if ( $symbol =~ /[^\x{0}-\x{7f}]/ ) {
        print STDERR "ERROR: check symbol $symbol possible utf8 non-Greek\n";
    }

    if ( $field =~ /a/ ) {
        ###current symbol
        $is_current  = 1;
        $is_internal = 0;
    }
    elsif ( $field =~ /b/ || $field =~ /d/ || $field =~ /c/ ) {
        ### other symbols
        $is_current  = 0;
        $is_internal = 0;
    }
    elsif ( $field =~ /e/ ) {

        #silent symbol
        $is_current  = 0;
        $is_internal = 1;
    }
    my $feat_syn = create_ch_library_synonym(
        doc          => $doc,
        library_id   => $fbid,
        synonym_sgml => $sgml_symbol,
        name         => $symbol,
        type         => $s_type,
        is_current   => $is_current,
        is_internal  => $is_internal,
        pub_id       => $paper
    );
    $out .= dom_toString($feat_syn);
    $feat_syn->dispose();
    return $out;
}

sub write_cell_line_synonyms {
    my $doc         = shift;
    my $fbid        = shift;
    my $symbol      = shift;
    my $field       = shift;
    my $paper       = shift;
    my $s_type      = shift;
    my $is_current  = 0;
    my $is_internal = 0;
    my $out         = '';
    $symbol = &convers($symbol);
    my $sgml_symbol = &toutf($symbol);

    #print "SYMBOL ",$sgml_symbol,"\n";
    $symbol = &decon($symbol);

    if ( $field =~ /a/ ) {
        ###current symbol
        $is_current  = 1;
        $is_internal = 0;
    }
    elsif ( $field =~ /b/ || $field =~ /d/ || $field =~ /c/ ) {
        ### other symbols
        $is_current  = 0;
        $is_internal = 0;
    }
    elsif ( $field =~ /e/ ) {

        #silent symbol
        $is_current  = 0;
        $is_internal = 1;
    }
    my $feat_syn = create_ch_cell_line_synonym(
        doc          => $doc,
        cell_line_id => $fbid,
        synonym_sgml => $sgml_symbol,
        name         => $symbol,
        type         => $s_type,
        is_current   => $is_current,
        is_internal  => $is_internal,
        pub_id       => $paper
    );
    $out .= dom_toString($feat_syn);
    $feat_syn->dispose();
    return $out;
}

sub write_table_synonyms {
    my $table       = shift;
    my $doc         = shift;
    my $unique      = shift;
    my $symbol      = shift;
    my $field       = shift;
    my $paper       = shift;
    my $s_type      = shift;
    my $is_current  = 0;
    my $is_internal = 0;
    my $out         = '';
    $symbol = &convers($symbol);
    my $sgml_symbol = &toutf($symbol);

    if ( $paper eq 'FBrf0000000' ) {
        return '';
    }

    #    print "SYMBOL ",$sgml_symbol,"\n";
    $symbol = &decon($symbol);
    if ( $symbol =~ /[^\x{0}-\x{7f}]/ ) {
        print STDERR "ERROR: check symbol $symbol possible utf8 non-Greek\n";
    }

    if ( $field =~ /a/ ) {
        ###current symbol
        $is_current  = 1;
        $is_internal = 0;
    }
    elsif ( $field =~ /b/ || $field =~ /d/ || $field =~ /c/ ) {
        ### other symbols
        $is_current  = 0;
        $is_internal = 0;
    }
    elsif ( $field =~ /e/ ) {

        #silent symbol
        $is_current  = 0;
        $is_internal = 1;
    }
    my $create_function = "create_ch_" . $table . "_synonym";
    my $fn              = &$create_function(
        doc            => $doc,
        $table . "_id" => $unique,
        synonym_sgml   => $sgml_symbol,
        name           => $symbol,
        type           => $s_type,
        is_current     => $is_current,
        is_internal    => $is_internal,
        pub_id         => $paper,
    );
    $out .= dom_toString($fn);
    $fn->dispose();
    return $out;
}

sub write_feature_synonyms {
    my $doc         = shift;
    my $fbid        = shift;
    my $symbol      = shift;
    my $field       = shift;
    my $paper       = shift;
    my $s_type      = shift;
    my $is_current  = 0;
    my $is_internal = 0;
    my $out         = '';

  #    print STDERR "DEBUG: in write_feature_synonyms $symbol $field $s_type\n";

    $symbol = &convers($symbol);

    #    print STDERR "DEBUG: after convers $symbol\n";

    my $sgml_symbol = &toutf($symbol);

    #    print STDERR "DEBUG: after toutf name $symbol sgml $sgml_symbol\n";

    if ( $paper eq 'FBrf0000000' ) {
        return '';
    }
    if ( $s_type eq "fullname" && $symbol =~ /^CG[0-9]{1,5}?$/ ) {
        print STDERR "ERROR: CG number $symbol can not be fullname\n";
    }

    #print "SYMBOL ",$sgml_symbol,"\n";
    $symbol = &decon($symbol);
    if ( $symbol =~ /[^\x{0}-\x{7f}]/ ) {
        print STDERR "ERROR: check symbol $symbol possible utf8 non-Greek\n";
    }

    #    print STDERR "DEBUG: in after decon name $symbol\n";

    if ( $field =~ /a/ ) {
        ###current symbol
        $is_current  = 1;
        $is_internal = 0;
    }
    elsif ( $field =~ /b/ || $field =~ /d/ || $field =~ /c/ ) {
        ### other symbols
        $is_current  = 0;
        $is_internal = 0;
    }
    elsif ( $field =~ /e/ ) {

        #silent symbol
        $is_current  = 0;
        $is_internal = 1;
    }
    my $feat_syn = create_ch_feature_synonym(
        doc          => $doc,
        feature_id   => $fbid,
        synonym_sgml => $sgml_symbol,
        name         => $symbol,
        type         => $s_type,
        is_current   => $is_current,
        is_internal  => $is_internal,
        pub_id       => $paper
    );

#    print STDERR "DEBUG: after create_ch_feature_synonym symbol $symbol sgml $sgml_symbol\n";

    $out .= dom_toString($feat_syn);
    $feat_syn->dispose();
    return $out;
}

sub write_feature_name_change_synonyms {
    my $doc         = shift;
    my $fbid        = shift;
    my $symbol      = shift;
    my $field       = shift;
    my $paper       = shift;
    my $s_type      = shift;
    my $is_current  = 0;
    my $is_internal = 0;
    my $out         = '';
    print STDERR
      "DEBUG: in write_feature_name_change_synonyms $symbol $field $s_type\n";

    $symbol = &convers($symbol);
    print STDERR "DEBUG: after convers $symbol\n";

    my $sgml_symbol = &recon($symbol);

    #assume spelled Greek letters in FBtp symbol get converted to sgml then utf
    print STDERR "DEBUG: after recon name $symbol sgml $sgml_symbol\n";
    $sgml_symbol = &toutf($sgml_symbol);
    print STDERR "DEBUG: after toutf name $symbol sgml $sgml_symbol\n";

    if ( $paper eq 'FBrf0000000' ) {
        return '';
    }
    if ( $s_type eq "fullname" && $symbol =~ /^CG[0-9]{1,5}?$/ ) {
        print STDERR "ERROR: CG number $symbol can not be fullname\n";
    }
    print "SYMBOL ", $sgml_symbol, "\n";
    $symbol = &decon($symbol);
    if ( $symbol =~ /[^\x{0}-\x{7f}]/ ) {
        print STDERR "ERROR: check symbol $symbol possible utf8 non-Greek\n";
    }

    print STDERR "DEBUG: in after decon name $symbol\n";

    if ( $field =~ /a/ ) {
        ###current symbol
        $is_current  = 1;
        $is_internal = 0;
    }
    elsif ( $field =~ /b/ || $field =~ /d/ || $field =~ /c/ ) {
        ### other symbols
        $is_current  = 0;
        $is_internal = 0;
    }
    elsif ( $field =~ /e/ ) {

        #silent symbol
        $is_current  = 0;
        $is_internal = 1;
    }
    my $feat_syn = create_ch_feature_synonym(
        doc          => $doc,
        feature_id   => $fbid,
        synonym_sgml => $sgml_symbol,
        name         => $symbol,
        type         => $s_type,
        is_current   => $is_current,
        is_internal  => $is_internal,
        pub_id       => $paper
    );
    print STDERR
"DEBUG: after create_ch_feature_synonym symbol $symbol sgml $sgml_symbol\n";

    $out .= dom_toString($feat_syn);
    $feat_syn->dispose();
    print STDERR
"DEBUG: finish write_feature_name_change_synonyms $symbol $field $s_type\n";
    return $out;
}

sub get_type_by_id {
    my $dbh = shift;
    my $id  = shift;

    my $cv     = "select name from cvterm where cvterm_id=$id";
    my $cv_nmm = $dbh->prepare($cv);
    $cv_nmm->execute;
    my $name = $cv_nmm->fetchrow_array;
    $cv_nmm->finish;
    return $name;
}

sub get_organism_by_id {
    my $dbh     = shift;
    my $id      = shift;
    my $org     = "select genus,species from organism where organism_id=$id";
    my $org_nmm = $dbh->prepare($org);
    $org_nmm->execute;
    my ( $genus, $species ) = $org_nmm->fetchrow_array;
    $org_nmm->finish;
    return ( $genus, $species );
}

sub get_cvterm_by_id {
    my $dbh     = shift;
    my $id      = shift;
    my $org     = "select name from cvterm where cvterm_id=$id";
    my $org_nmm = $dbh->prepare($org);
    $org_nmm->execute;
    my ($name) = $org_nmm->fetchrow_array;
    $org_nmm->finish;
    return ($name);
}

sub dissociate_with_pub_fromlib {
    my $dbh    = shift;
    my $unique = shift;
    my $pub    = shift;
    my $out    = '';
    my $doc    = new XML::DOM::Document;
    ###get feature_synonym
    print STDERR "in method dissociate_with_pub_fromlib\n";
    my $statement = "select synonym.name, synonym.synonym_sgml,
		cvterm.name
		from library,synonym,library_synonym,pub,cvterm where
		library.uniquename='$unique' and library.library_id = 
		library_synonym.library_id 
		and library_synonym.synonym_id=synonym.synonym_id 
                and library_synonym.pub_id=pub.pub_id and pub.uniquename='$pub'                
                and cvterm.cvterm_id=synonym.type_id;";

    #print STDERR "$statement\n";

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $name, $sgml, $type ) = $nmm->fetchrow_array ) {
        my $fs = create_ch_library_synonym(
            doc        => $doc,
            library_id => $unique,
            synonym_id => create_ch_synonym(
                doc          => $doc,
                name         => $name,
                synonym_sgml => $sgml,
                type         => $type
            ),
            pub_id => $pub
        );
        $fs->setAttribute( 'op', 'delete' );
        $out .= dom_toString($fs);
    }
    $nmm->finish;

    #print STDERR "done synonym\n";
    ###get library_cvterm
    my $c_state = "select cvterm.name, cv.name from
		library_cvterm, cvterm, cv, pub, library where
		library.library_id=library_cvterm.library_id and
		library.uniquename='$unique' and
		library_cvterm.cvterm_id=cvterm.cvterm_id and
		cvterm.cv_id=cv.cv_id and library_cvterm.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$c_state\n";
    my $f_c = $dbh->prepare($c_state);
    $f_c->execute;
    while ( my ( $cvterm, $cv ) = $f_c->fetchrow_array ) {
        my $f = create_ch_library_cvterm(
            doc        => $doc,
            name       => $cvterm,
            cv         => $cv,
            pub_id     => $pub,
            library_id => $unique
        );

        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
    }
    $f_c->finish;

    #print STDERR "done cvterm\n";
    ###get library_pub
    my $fp = "select pub.uniquename from library, library_pub, pub 
		where library.library_id=library_pub.library_id and
		library.uniquename='$unique' and
		pub.pub_id=library_pub.pub_id and pub.uniquename='$pub';";
    my $f_p = $dbh->prepare($fp);
    $f_p->execute;
    while ( my ($fpub) = $f_p->fetchrow_array ) {
        print STDERR "got library_pub \n";
        my $feat_pub = create_ch_library_pub(
            doc        => $doc,
            library_id => $unique,
            pub_id     => $pub
        );
        $feat_pub->setAttribute( 'op', 'delete' );
        $out .= dom_toString($feat_pub);
    }
    $f_p->finish;

    #print STDERR "done pub\n";
    ###get libraryprop,libraryprop_pub
    $fp = "select libraryprop.libraryprop_id, cvterm.name,rank from
		libraryprop,libraryprop_pub, library,cvterm,pub where
		library.library_id=libraryprop.library_id and
		libraryprop.libraryprop_id=libraryprop_pub.libraryprop_id and 
		library.uniquename='$unique' and
		cvterm.cvterm_id=libraryprop.type_id and libraryprop_pub.pub_id =
		pub.pub_id and pub.uniquename='$pub';";

    #print STDERR "$fp\n";
    my $fp_nmm = $dbh->prepare($fp);
    $fp_nmm->execute;
    while ( my ( $fp_id, $type, $rank ) = $fp_nmm->fetchrow_array ) {
        my $num = get_libprop_pub_nums( $dbh, $fp_id );
        if ( $num == 1 ) {
            $out .= delete_libraryprop( $doc, $rank, $unique, $type );
        }
        elsif ( $num > 1 ) {
            $out .= delete_libraryprop_pub( $doc, $rank, $unique, $type, $pub );
        }
    }
    $fp_nmm->finish;
    ###get library_relationship,fr_pub
    my $fr_state =
        "select 'subject_id' as type, fr.library_relationship_id, "
      . "f1.uniquename as subject_id, f2.name as name, f2.library_id,"
      . " f2.uniquename as "
      . "object_id, cvterm.name as frtype from "
      . "library_relationship fr, library_relationship_pub frp, "
      . "library f1,library f2, cvterm, pub where "
      . "frp.library_relationship_id=fr.library_relationship_id and "
      . "cvterm.cvterm_id=fr.type_id and frp.pub_id=pub.pub_id and "
      . "fr.subject_id=f1.library_id and pub.uniquename='$pub' and "
      . "fr.object_id=f2.library_id and f1.uniquename='$unique' "
      . "union "
      . "select 'object_id' as type, fr.library_relationship_id, f2.uniquename as "
      . "subject_id, f1.name as name, f1.library_id, f1.uniquename as "
      . "object_id, cvterm.name as frtype from "
      . "library_relationship fr, library_relationship_pub frp,"
      . "library f1, library f2, cvterm, pub where "
      . "frp.library_relationship_id=fr.library_relationship_id and "
      . "cvterm.cvterm_id=fr.type_id and frp.pub_id=pub.pub_id and "
      . "fr.subject_id=f1.library_id and pub.uniquename='$pub' and "
      . "fr.object_id=f2.library_id and f2.uniquename='$unique'";

    #print STDERR "$fr_state\n";
    my $fr_nmm = $dbh->prepare($fr_state);
    $fr_nmm->execute;
    while ( my $fr_hash = $fr_nmm->fetchrow_hashref ) {

        if ( !defined( $fr_hash->{object_id} ) ) {
            last;
        }
        my $subject_id = 'subject_id';
        my $object_id  = 'object_id';
        my $fr_subject = $fr_hash->{object_id};
        if ( $fr_hash->{type} eq 'object_id' ) {
            $subject_id = 'object_id';
            $object_id  = 'subject_id';
        }

        if ( !exists( $fr_hash->{name} ) ) {
            print STDERR "ERROR: name is not found in disassociate_fncti\n";
        }

        my $num = get_lr_pub_nums( $dbh, $fr_hash->{library_relationship_id} );
        if ( $num == 1 ) {
            $out .=
              delete_library_relationship( $dbh, $doc, $fr_hash, $subject_id,
                $object_id, $unique, $fr_hash->{frtype} );
        }
        elsif ( $num > 1 ) {
            $out .=
              delete_library_relationship_pub( $dbh, $doc, $fr_hash,
                $subject_id, $object_id, $unique, $fr_hash->{frtype}, $pub );
        }
    }
    $fr_nmm->finish;

    #print STDERR "done library_relationship\n";
    ###get library_expression
    my $e_state = "select expression.uniquename from
		expression, library_expression, pub, library where
		library.library_id=library_expression.library_id and
		library.uniquename='$unique' and
		library_expression.expression_id=expression.expression_id and
		library_expression.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$e_state\n";
    my $f_e = $dbh->prepare($e_state);
    $f_e->execute;
    while ( my ($euname) = $f_e->fetchrow_array ) {
        my $f = create_ch_library_expression(
            doc => $doc,
            expression_id =>
              create_ch_expression( doc => $doc, uniquename => $euname ),
            pub_id     => $pub,
            library_id => $unique
        );

        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
    }
    $f_e->finish;

    #print STDERR "done library_expression\n";

    ###get cell_line_library
    my $cf_state =
"select cell_line.name from cell_line, cell_line_library, library, pub where cell_line.cell_line_id=cell_line_library.cell_line_id and cell_line_library.library_id = library.library_id and library.uniquename='$unique' and cell_line_library.pub_id = pub.pub_id and pub.uniquename =  '$pub' ";
    my $c_f = $dbh->prepare($cf_state);
    $c_f->execute;
    while ( my ($f_name) = $c_f->fetchrow_array ) {
        my ( $l_u, $l_g, $l_s ) = get_cell_line_ukeys_by_name( $dbh, $f_name );
        if ( $l_u eq '0' ) {
            print STDERR "ERROR: cell_line $f_name has been obsoleted\n";
        }
        my $cl_feat = create_ch_cell_line_library(
            doc          => $doc,
            library_id   => $unique,
            cell_line_id => create_ch_cell_line(
                doc        => $doc,
                uniquename => $l_u,
                genus      => $l_g,
                species    => $l_s,
            ),
            pub_id => $pub,
        );
        $cl_feat->setAttribute( 'op', 'delete' );
        $out .= dom_toString($cl_feat);
    }
    $c_f->finish;

    #print STDERR "done cell_line_library\n";
    ###get library_interaction
    my $i_state = "select interaction.uniquename, cv.name, cvterm.name from
		interaction, library_interaction, pub, library, cvterm, cv where
		library.library_id=library_interaction.library_id and
		library.uniquename='$unique' and library.type_id = cvterm.cvterm_id and cvterm.cv_id = cv.cv_id and 
		library_interaction.interaction_id = interaction.interaction_id and
		library_interaction.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$i_state\n";
    my $i_e = $dbh->prepare($i_state);
    $i_e->execute;
    while ( my ( $iuname, $cv, $term ) = $i_e->fetchrow_array ) {
        my $f = create_ch_library_interaction(
            doc            => $doc,
            interaction_id => create_ch_interaction(
                doc        => $doc,
                uniquename => $iuname,
                cvname     => $cv,
                type       => $term
            ),
            pub_id     => $pub,
            library_id => $unique
        );

        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
    }
    $i_e->finish;

    #print STDERR "done library_interaction\n";
    print STDERR "leaving method dissociate_with_pub_fromlib\n";
    $doc->dispose();
    return $out;
}

sub dissociate_with_pub_frominteraction {
    my $dbh    = shift;
    my $unique = shift;
    my $pub    = shift;
    my $out    = '';
    my $doc    = new XML::DOM::Document;

    ###get interaction_cvterm
    my $c_state = "select cvterm.name, cv.name from
		interaction_cvterm, cvterm, cv, pub, interaction where
		interaction.interaction_id=interaction_cvterm.interaction_id and
		interaction.uniquename='$unique' and
		interaction_cvterm.cvterm_id=cvterm.cvterm_id and
		cvterm.cv_id=cv.cv_id and interaction_cvterm.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$c_state\n";
    my $f_c = $dbh->prepare($c_state);
    $f_c->execute;
    while ( my ( $cvterm, $cv ) = $f_c->fetchrow_array ) {
        my $f = create_ch_interaction_cvterm(
            doc            => $doc,
            name           => $cvterm,
            cv             => $cv,
            pub_id         => $pub,
            interaction_id => $unique
        );

        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
    }
    $f_c->finish;

    #print STDERR "done cvterm\n";
    ###get interaction_pub
    my $fp = "select pub.uniquename from interaction, interaction_pub,pub
		where interaction.interaction_id=interaction_pub.interaction_id and
		interaction.uniquename='$unique' and
		pub.pub_id=interaction_pub.pub_id and pub.uniquename='$pub';";
    my $f_p = $dbh->prepare($fp);
    $f_p->execute;
    while ( my ($fpub) = $f_p->fetchrow_array ) {
        my $feat_pub = create_ch_interaction_pub(
            doc            => $doc,
            interaction_id => $unique,
            pub_id         => $pub
        );
        $feat_pub->setAttribute( 'op', 'delete' );
        $out .= dom_toString($feat_pub);
    }
    $f_p->finish;

    #print STDERR "done pub\n";
    ##get feature_interaction
    my $i_state = "select feature.uniquename as uname, cv.name, cvterm.name from
		interaction, feature_interaction, feature, cv, cvterm where
		feature.feature_id=feature_interaction.feature_id and 
		feature.is_analysis='f' and feature.is_obsolete = 'f' and 
		feature_interaction.interaction_id=interaction.interaction_id and 
                interaction.uniquename = $unique  and feature_interaction.role_id = cvterm.cvterm_id and cvterm.cv_id = cv.cv_id";

    #print STDERR "$i_state\n";
    my $f_i = $dbh->prepare($i_state);
    $f_i->execute;
    while ( my ( $uname, $cvname, $rolename ) = $f_i->fetchrow_array ) {
        my ( $genus, $species, $type ) =
          get_feat_ukeys_by_uname( $dbh, $uname );
        if ( $genus eq '0' || $genus eq '2' ) {
            print STDERR "ERROR: could not find $uname in DB $genus\n";
        }
        else {
            my $f = create_ch_feature_interaction(
                doc            => $doc,
                interaction_id => $unique,
                role_id        => create_ch_cvterm(
                    doc  => $doc,
                    cv   => $cvname,
                    name => $rolename,
                ),
                feature_id => create_ch_feature(
                    doc        => $doc,
                    uniquename => $uname,
                    type       => $type,
                    genus      => $genus,
                    species    => $species,
                ),
            );

            $f->setAttribute( 'op', 'delete' );
            $out .= dom_toString($f);
        }
    }
    $f_i->finish;

    #print STDERR "done feature_interaction\n";

    ###get interaction_expression
    my $e_state = "select expression.uniquename from
		interaction_expression, pub, interaction where
		interaction.interaction_id=interaction_expression.interaction_id and
		interaction.uniquename='$unique' and
		interaction_expression.expression_id=expression.expression_id and
		interaction_expression.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$e_state\n";
    my $f_e = $dbh->prepare($e_state);
    $f_e->execute;
    while ( my ($euname) = $f_e->fetchrow_array ) {
        my $f = create_ch_interaction_expression(
            doc => $doc,
            expression_id =>
              create_ch_expression( doc => $doc, uniquename => $euname ),
            pub_id         => $pub,
            interaction_id => $unique
        );

        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
    }
    $f_e->finish;

    #print STDERR "done interaction_expression\n";

    ###get interaction_cell_line
    my $cf_state = "
    SELECT cell_line.name 
        FROM cell_line, interaction_cell_line, interaction, pub 
        WHERE cell_line.cell_line_id=interaction_cell_line.cell_line_id AND
              interaction_cell_line.interaction_id = interaction.interaction_id AND
              interaction.uniquename='$unique' AND
              interaction_cell_line.pub_id = '$pub' ";
    my $c_f = $dbh->prepare($cf_state);
    $c_f->execute;
    while ( my ($f_name) = $c_f->fetchrow_array ) {
        my ( $cell_uniquename, $organism_genus, $organism_species ) = get_cell_line_ukeys_by_name( $dbh, $f_name );
        my $cl_feat = create_ch_interaction_cell_line(
            doc            => $doc,
            interaction_id => $unique,
            cell_line_id   => create_ch_cell_line(
                doc        => $doc,
                uniquename => $cell_uniquename,
                genus      => $organism_genus,
                species    => $organism_species,
            ),
            pub_id => $pub,
        );
        $cl_feat->setAttribute( 'op', 'delete' );
        $out .= dom_toString($cl_feat);
    }
    $c_f->finish;

    #print STDERR "done interaction_cell_line\n";

    ###get interactionprop, interactionprop_pub
    $fp = "select interactionprop.interactionprop_id, cvterm.name,rank from
		interactionprop,interactionprop_pub, interaction,cvterm,pub where
		interaction.interaction_id=interactionprop.interaction_id and
		interactionprop.interactionprop_id=interactionprop_pub.interactionprop_id and 
		interaction.uniquename='$unique' and
		cvterm.cvterm_id=interactionprop.type_id and interactionprop_pub.pub_id =
		pub.pub_id and pub.uniquename='$pub';";

    #print STDERR "$fp\n";
    my $fp_nmm = $dbh->prepare($fp);
    $fp_nmm->execute;
    while ( my ( $fp_id, $type, $rank ) = $fp_nmm->fetchrow_array ) {
        my $num = get_interactionprop_pub_nums( $dbh, $fp_id );
        if ( $num == 1 ) {
            $out .= delete_interactionprop( $doc, $rank, $unique, $type );
        }
        elsif ( $num > 1 ) {
            $out .=
              delete_interactionprop_pub( $doc, $rank, $unique, $type, $pub );
        }
    }
    $fp_nmm->finish;
    $doc->dispose();
    return $out;
}

sub dissociate_with_pub_fromcell_line {
    my $dbh    = shift;
    my $unique = shift;
    my $pub    = shift;
    my $out    = '';
    my $doc    = new XML::DOM::Document;
    ###get feature_synonym

    my $statement = "select synonym.name, synonym.synonym_sgml,
		cvterm.name
		from cell_line,synonym,cell_line_synonym,pub,cvterm where
		cell_line.uniquename='$unique' and cell_line.cell_line_id = 
		cell_line_synonym.cell_line_id 
		and cell_line_synonym.synonym_id=synonym.synonym_id 
                and cell_line_synonym.pub_id=pub.pub_id and pub.uniquename='$pub'                
                and cvterm.cvterm_id=synonym.type_id;";

    #print STDERR "$statement\n";

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $name, $sgml, $type ) = $nmm->fetchrow_array ) {
        my $fs = create_ch_cell_line_synonym(
            doc          => $doc,
            cell_line_id => $unique,
            synonym_id   => create_ch_synonym(
                doc          => $doc,
                name         => $name,
                synonym_sgml => $sgml,
                type         => $type
            ),
            pub_id => $pub
        );
        $fs->setAttribute( 'op', 'delete' );
        $out .= dom_toString($fs);
    }
    $nmm->finish;

    #print STDERR "done synonym\n";
    ###get cell_line_cvterm
    my $c_state = "select cvterm.name, cv.name from
		cell_line_cvterm, cvterm, cv, pub, cell_line where
		cell_line.cell_line_id=cell_line_cvterm.cell_line_id and
		cell_line.uniquename='$unique' and
		cell_line_cvterm.cvterm_id=cvterm.cvterm_id and
		cvterm.cv_id=cv.cv_id and cell_line_cvterm.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$c_state\n";
    my $f_c = $dbh->prepare($c_state);
    $f_c->execute;
    while ( my ( $cvterm, $cv ) = $f_c->fetchrow_array ) {
        my $f = create_ch_cell_line_cvterm(
            doc          => $doc,
            name         => $cvterm,
            cv           => $cv,
            pub_id       => $pub,
            cell_line_id => $unique
        );

        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
    }
    $f_c->finish;

    #print STDERR "done cvterm\n";
    ###get cell_line_pub
    my $fp = "select pub.uniquename from cell_line, cell_line_pub,pub
		where cell_line.cell_line_id=cell_line_pub.cell_line_id and
		cell_line.uniquename='$unique' and
		pub.pub_id=cell_line_pub.pub_id and pub.uniquename='$pub';";
    my $f_p = $dbh->prepare($fp);
    $f_p->execute;
    while ( my ($fpub) = $f_p->fetchrow_array ) {
        my $feat_pub = create_ch_cell_line_pub(
            doc          => $doc,
            cell_line_id => $unique,
            pub_id       => $pub
        );
        $feat_pub->setAttribute( 'op', 'delete' );
        $out .= dom_toString($feat_pub);
    }
    $f_p->finish;

    #print STDERR "done pub\n";
    ###get cell_lineprop,cell_lineprop_pub
    $fp = "select cell_lineprop.cell_lineprop_id, cvterm.name,rank from
		cell_lineprop,cell_lineprop_pub, cell_line,cvterm,pub where
		cell_line.cell_line_id=cell_lineprop.cell_line_id and
		cell_lineprop.cell_lineprop_id=cell_lineprop_pub.cell_lineprop_id and 
		cell_line.uniquename='$unique' and
		cvterm.cvterm_id=cell_lineprop.type_id and cell_lineprop_pub.pub_id =
		pub.pub_id and pub.uniquename='$pub';";

    #print STDERR "$fp\n";
    my $fp_nmm = $dbh->prepare($fp);
    $fp_nmm->execute;
    while ( my ( $fp_id, $type, $rank ) = $fp_nmm->fetchrow_array ) {
        my $num = get_cellprop_pub_nums( $dbh, $fp_id );
        if ( $num == 1 ) {
            $out .= delete_cell_lineprop( $doc, $rank, $unique, $type );
        }
        elsif ( $num > 1 ) {
            $out .=
              delete_cell_lineprop_pub( $doc, $rank, $unique, $type, $pub );
        }
    }
    $fp_nmm->finish;
    ##get cell_line_feature
    my $cl_state = "select feature.uniquename as uname from
		cell_line, cell_line_feature,  pub, feature where
		feature.feature_id=cell_line_feature.feature_id and 
		feature.is_analysis='f' and feature.is_obsolete = 'f' and 
		cell_line_feature.cell_line_id=cell_line.cell_line_id and 
                cell_line.uniquename = '$unique'   
                and cell_line_feature.pub_id = pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$cl_state\n";
    my $f_cl = $dbh->prepare($cl_state);
    $f_cl->execute;
    while ( my ($uname) = $f_cl->fetchrow_array ) {
        my ( $genus, $species, $type ) =
          get_feat_ukeys_by_uname( $dbh, $uname );
        if ( $genus eq '0' || $genus eq '2' ) {
            print STDERR "ERROR: could not find $uname in DB $genus\n";
        }
        else {
            my $f = create_ch_cell_line_feature(
                doc          => $doc,
                cell_line_id => $unique,
                feature_id   => create_ch_feature(
                    doc        => $doc,
                    uniquename => $uname,
                    type       => $type,
                    genus      => $genus,
                    species    => $species,
                ),
                pub_id => $pub,
            );

            $f->setAttribute( 'op', 'delete' );
            $out .= dom_toString($f);
        }
    }
    $f_cl->finish;

    #print STDERR "done cell_line_feature\n";

    ###get cell_line_library
    my $ls_state =
"select library.uniquename, organism.genus, organism.species, cv.name, cvterm.name from
		library, cell_line_library, pub, cell_line, organism, cv, cvterm where
		cell_line.cell_line_id=cell_line_library.cell_line_id and
		cell_line.uniquename='$unique' and 
		cell_line_library.library_id = library.library_id and library.organism_id = organism.organism_id and 
                library.type_id = cvterm.cvterm_id and cvterm.cv_id = cv.cv_id and 
		cell_line_library.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$f_state\n";
    my $l_s = $dbh->prepare($ls_state);
    $l_s->execute;
    while ( my ( $funame, $genus, $species, $cvname, $cvterm ) =
        $l_s->fetchrow_array )
    {
        my $f = create_ch_cell_line_library(
            doc        => $doc,
            library_id => create_ch_library(
                doc        => $doc,
                uniquename => $funame,
                genus      => $genus,
                species    => $species,
                type_id    => create_ch_cvterm(
                    doc  => $doc,
                    cv   => $cvname,
                    name => $cvterm
                ),
            ),
            pub_id       => $pub,
            cell_line_id => $unique
        );

        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
    }
    $l_s->finish;

    #print STDERR "done cell_line_library\n";

    ###get interaction_cell_line
    my $int_state = "select interaction.uniquename, cv.name, cvterm.name from
		interaction, interaction_cell_line, pub, cell_line, cv, cvterm where
		cell_line.cell_line_id=interaction_cell_line.cell_line_id and
		cell_line.uniquename='$unique' and 
		interaction_cell_line.interaction_id = interaction.interaction_id and 
                interaction.type_id = cvterm.cvterm_id and cvterm.cv_id = cv.cv_id and 
		interaction_cell_line.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$f_state\n";
    my $int_s = $dbh->prepare($int_state);
    $int_s->execute;
    while ( my ( $funame, $cvname, $cvterm ) = $int_s->fetchrow_array ) {
        my $f = create_ch_interaction_cell_line(
            doc            => $doc,
            interaction_id => create_ch_interaction(
                doc        => $doc,
                uniquename => $funame,
                type_id    => create_ch_cvterm(
                    doc  => $doc,
                    cv   => $cvname,
                    name => $cvterm
                ),
            ),
            pub_id       => $pub,
            cell_line_id => $unique
        );

        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
    }
    $int_s->finish;

    #print STDERR "done interaction_cell_line\n";
    $doc->dispose();
    return $out;
}

sub dissociate_with_pub {
    my $dbh    = shift;
    my $unique = shift;
    my $pub    = shift;
    my $out    = '';
    my $doc    = new XML::DOM::Document;

    ###get feature_pub, feature_pubprop
    my $fp = "select pub.uniquename from feature, feature_pub,pub
		where feature.feature_id=feature_pub.feature_id and
		feature.is_analysis='f' and feature.uniquename='$unique' and
		pub.pub_id=feature_pub.pub_id and pub.uniquename='$pub';";
    my $f_p = $dbh->prepare($fp);
    $f_p->execute;
    my $id_num = $f_p->rows;
    if ( $id_num == 0 ) {
        print STDERR
          "ERROR: Pub $pub not associated with feature $unique .. exiting\n";
        $f_p->finish;
        $doc->dispose();
        return $out;
    }

    while ( my ($fpub) = $f_p->fetchrow_array ) {
        my $feat_pub = create_ch_feature_pub(
            doc        => $doc,
            feature_id => $unique,
            uniquename => $pub
        );
        $feat_pub->setAttribute( 'op', 'delete' );
        $out .= dom_toString($feat_pub);
    }
    $f_p->finish;

    #print STDERR "done pub\n";

    ###get feature_synonym

    my $statement = "select synonym.name, synonym.synonym_sgml,
		cvterm.name
		from feature,synonym,feature_synonym,pub,cvterm where
		feature.uniquename='$unique' and feature.feature_id = 
		feature_synonym.feature_id 
		and feature_synonym.synonym_id=synonym.synonym_id and
	   feature.is_analysis='f' and 
		feature_synonym.pub_id=pub.pub_id and pub.uniquename='$pub' and 
		cvterm.cvterm_id=synonym.type_id;";

    #print STDERR "$statement\n";

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $name, $sgml, $type ) = $nmm->fetchrow_array ) {
        my $fs = create_ch_feature_synonym(
            doc        => $doc,
            feature_id => $unique,
            synonym_id => create_ch_synonym(
                doc          => $doc,
                name         => $name,
                synonym_sgml => $sgml,
                type         => $type
            ),
            pub_id => $pub
        );
        $fs->setAttribute( 'op', 'delete' );
        $out .= dom_toString($fs);
    }
    $nmm->finish;

    #print STDERR "done synonym\n";
    ###get feature_cvterm
    my $c_state = "select cvterm.name, cv.name from
		feature_cvterm, cvterm, cv, pub, feature where
		feature.feature_id=feature_cvterm.feature_id and
		feature.uniquename='$unique' and
		feature.is_analysis='f' and
		feature_cvterm.cvterm_id=cvterm.cvterm_id and
		cvterm.cv_id=cv.cv_id and feature_cvterm.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$c_state\n";
    my $f_c = $dbh->prepare($c_state);
    $f_c->execute;
    while ( my ( $cvterm, $cv ) = $f_c->fetchrow_array ) {
        my $f = create_ch_feature_cvterm(
            doc        => $doc,
            name       => $cvterm,
            cv         => $cv,
            pub        => $pub,
            feature_id => $unique
        );

        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
    }
    $f_c->finish;

    #print STDERR "done cvterm\n";
    ###get featureprop,featureprop_pub
    $fp = "select featureprop.featureprop_id, cvterm.name,rank from
		featureprop,featureprop_pub, feature,cvterm,pub where
		feature.feature_id=featureprop.feature_id and
		featureprop.featureprop_id=featureprop_pub.featureprop_id and 
		feature.is_analysis='f' and feature.uniquename='$unique' and
		cvterm.cvterm_id=featureprop.type_id and featureprop_pub.pub_id =
		pub.pub_id and pub.uniquename='$pub';";

    #print STDERR "$fp\n";
    my $fp_nmm = $dbh->prepare($fp);
    $fp_nmm->execute;
    while ( my ( $fp_id, $type, $rank ) = $fp_nmm->fetchrow_array ) {
        my $num = get_fprop_pub_nums( $dbh, $fp_id );
        if ( $num == 1 ) {
            $out .= delete_featureprop( $doc, $rank, $unique, $type );
        }
        elsif ( $num > 1 ) {
            $out .= delete_featureprop_pub( $doc, $rank, $unique, $type, $pub );
        }
    }
    $fp_nmm->finish;

    #print STDERR "done featureprop\n";
    ###get feature_relationship,fr_pub,frprop,frprop_pub
    my $fr_state =
        "select 'subject_id' as type, fr.feature_relationship_id, "
      . "f1.uniquename as subject_id, f2.name as name, f2.feature_id,"
      . " f2.uniquename as "
      . "object_id, cvterm.name as frtype,rank from "
      . "feature_relationship fr, feature_relationship_pub frp, "
      . "feature f1, feature f2, cvterm, pub where "
      . "frp.feature_relationship_id=fr.feature_relationship_id and "
      . "cvterm.cvterm_id=fr.type_id and frp.pub_id=pub.pub_id and "
      . "fr.subject_id=f1.feature_id and pub.uniquename='$pub' and "
      . "fr.object_id=f2.feature_id and f1.uniquename='$unique' "
      . "union "
      . "select 'object_id' as type, fr.feature_relationship_id, f2.uniquename as "
      . "subject_id, f1.name as name, f1.feature_id, f1.uniquename as "
      . "object_id, cvterm.name as frtype, rank from "
      . "feature_relationship fr, feature_relationship_pub frp,"
      . "feature f1, feature f2, cvterm, pub where "
      . "frp.feature_relationship_id=fr.feature_relationship_id and "
      . "cvterm.cvterm_id=fr.type_id and frp.pub_id=pub.pub_id and "
      . "fr.subject_id=f1.feature_id and pub.uniquename='$pub' and "
      . "fr.object_id=f2.feature_id and f2.uniquename='$unique'";

    #print STDERR "$fr_state\n";
    my $fr_nmm = $dbh->prepare($fr_state);
    $fr_nmm->execute;
    while ( my $fr_hash = $fr_nmm->fetchrow_hashref ) {

        if ( !defined( $fr_hash->{object_id} ) ) {
            last;
        }
        my $subject_id = 'subject_id';
        my $object_id  = 'object_id';
        my $fr_subject = $fr_hash->{object_id};
        if ( $fr_hash->{type} eq 'object_id' ) {
            $subject_id = 'object_id';
            $object_id  = 'subject_id';
        }

        if ( !exists( $fr_hash->{name} ) ) {
            print STDERR "ERROR: name is not found in disassociate_fncti\n";
        }

        my $num = get_fr_pub_nums( $dbh, $fr_hash->{feature_relationship_id} );
        if ( $num == 1 ) {
            $out .=
              delete_feature_relationship( $dbh, $doc, $fr_hash, $subject_id,
                $object_id, $unique, $fr_hash->{frtype} );
        }
        elsif ( $num > 1 ) {
            $out .=
              delete_feature_relationship_pub( $dbh, $doc, $fr_hash,
                $subject_id, $object_id, $unique, $fr_hash->{frtype}, $pub );
        }
    }
    $fr_nmm->finish;

    #print STDERR "done feature_relationship\n";
    ###get feature_loc, featureloc_pub
    my $fl_state = "select f2.uniquename, f2.type_id,
		f2.organism_id, locgroup,rank 
		from featureloc, feature f1, feature f2,featureloc_pub, pub where
		f1.feature_id=featureloc.feature_id and
		f1.uniquename='$unique' and f2.feature_id=featureloc.srcfeature_id
			and featureloc.featureloc_id=featureloc_pub.featureloc_id and
		pub.pub_id=featureloc_pub.pub_id and pub.uniquename='$pub'";
    my $fl_nmm = $dbh->prepare($fl_state);
    $fl_nmm->execute;
    while ( my ( $src_unique, $src_type, $src_org, $locgroup, $rank ) =
        $fl_nmm->fetchrow_array )
    {
        my $s_type = get_type_by_id( $dbh, $src_type );
        my ( $genus, $species ) = get_organism_by_id( $dbh, $src_org );
        my $fl_obj = create_ch_featureloc(
            doc           => $doc,
            feature_id    => $unique,
            locgroup      => $locgroup,
            rank          => $rank,
            srcfeature_id => create_ch_feature(
                doc        => $doc,
                uniquename => $src_unique,
                type       => $s_type,
                genus      => $genus,
                species    => $species
            )
        );
        $fl_obj->setAttribute( 'op', 'delete' );
        $out .= dom_toString($fl_obj);
        $fl_obj->dispose();
    }
    $fl_nmm->finish;

    #print STDERR "done feature_loc\n";
    ###get feature_expression
    my $e_state = "select expression.uniquename from
		expression, feature_expression, pub, feature where
		feature.feature_id=feature_expression.feature_id and
		feature.uniquename='$unique' and
		feature.is_analysis='f' and
		feature_expression.expression_id=expression.expression_id and
		feature_expression.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$e_state\n";
    my $f_e = $dbh->prepare($e_state);
    $f_e->execute;
    while ( my ($euname) = $f_e->fetchrow_array ) {
        my $f = create_ch_feature_expression(
            doc        => $doc,
            uniquename => $euname,
            pub        => $pub,
            feature_id => $unique
        );
        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
        $f->dispose();
    }
    $f_e->finish;

    #print STDERR "done feature_expression\n";
    ###get strain_feature
    my $s_state = "select strain.uniquename from
		strain, strain_feature, pub, feature where
		feature.feature_id=strain_feature.feature_id and
		feature.uniquename='$unique' and
		feature.is_analysis='f' and
		strain_feature.strain_id=strain.strain_id and
		strain_feature.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$s_state\n";
    my $s_f = $dbh->prepare($s_state);
    $s_f->execute;
    while ( my ($euname) = $s_f->fetchrow_array ) {
        my $f = create_ch_feature_strain(
            doc        => $doc,
            uniquename => $euname,
            pub        => $pub,
            feature_id => $unique
        );
        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
        $f->dispose();
    }
    $s_f->finish;

    #print STDERR "done strain_feature\n";
    ##get feature_interaction, feature_interaction_pub
    my $i_state =
"select feature_interaction.feature_interaction_id, interaction.uniquename, cvt.name as type, cv.name as cv, cvt2.name as role, rank from
		interaction, feature_interaction, feature, cv, cvterm cvt, cvterm cvt2, feature_interaction_pub, pub where
		feature.feature_id=feature_interaction.feature_id and
		feature.uniquename='$unique' and
		feature.is_analysis='f' and
		feature_interaction.interaction_id=interaction.interaction_id and interaction.type_id = cvt.cvterm_id and 
                cvt.cv_id = cv.cv_id and feature_interaction.role_id = cvt2.cvterm_id and 
               feature_interaction.feature_interaction_id = feature_interaction_pub.feature_interaction_id and 
               feature_interaction_pub.pub_id = pub.pub_id and pub.uniquename = '$pub' ";

    #print STDERR "$i_state\n";
    my $f_i = $dbh->prepare($i_state);
    $f_i->execute;
    while ( my ( $fi_id, $iuname, $type, $cv, $role, $rank ) =
        $f_i->fetchrow_array )
    {
        my $num = get_feature_interaction_pub_nums( $dbh, $fi_id );
        if ( $num == 1 ) {
            $out .=
              delete_feature_interaction( $doc, $iuname, $type, $cv, $role,
                $unique, $rank );
        }
        elsif ( $num > 1 ) {
            $out .=
              delete_feature_interaction_pub( $doc, $iuname, $type, $cv, $role,
                $unique, $rank, $pub );
        }

    }
    $f_i->finish;

    #print STDERR "done feature_interaction\n";
    ###get humanhealth_feature
    my $hh_state = "select humanhealth.uniquename from
		humanhealth, humanhealth_feature, pub, feature where
		feature.feature_id=humanhealth_feature.feature_id and
		feature.uniquename='$unique' and
		feature.is_analysis='f' and
		humanhealth_feature.humanhealth_id=humanhealth.humanhealth_id and
		humanhealth_feature.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$hh_state\n";
    my $hh_f = $dbh->prepare($hh_state);
    $hh_f->execute;
    while ( my ($euname) = $hh_f->fetchrow_array ) {
        my $f = create_ch_humanhealth_feature(
            doc        => $doc,
            uniquename => $euname,
            pub        => $pub,
            feature_id => $unique
        );
        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
        $f->dispose();
    }
    $hh_f->finish;
    print STDERR "done humanhealth_feature\n";

    ###get feature_grpmember and feature_grpmember_pub
    my $fgr_state =
"select feature_grpmember.feature_grpmember_id, grp.uniquename, cvt.name as type, cv.name as cv, rank from
		grp, grpmember, feature_grpmember, feature, cv, cvterm cvt, feature_grpmember_pub, pub where
		feature.feature_id=feature_grpmember.feature_id and
		feature.uniquename='$unique' and
		feature.is_analysis='f' and
		feature_grpmember.grpmember_id=grpmember.grpmember_id and grpmember.type_id = cvt.cvterm_id and 
                cvt.cv_id = cv.cv_id and cv.name = 'grpmember type' and cvt.name = 'grpmember_feature' and grpmember.grp_id = grp.grp_id and  
                feature_grpmember.feature_grpmember_id = feature_grpmember_pub.feature_grpmember_id and 
                feature_grpmember_pub.pub_id = pub.pub_id and pub.uniquename = '$pub' ";

    #print STDERR "$fgr_state\n";
    my $f_g = $dbh->prepare($fgr_state);
    $f_g->execute;
    while ( my ( $fi_id, $iuname, $type, $cv, $rank ) = $f_g->fetchrow_array ) {
        my $num = get_feature_grpmember_pub_nums( $dbh, $fi_id );
        if ( $num == 1 ) {
            $out .= delete_feature_grpmember( $dbh, $doc, $iuname, $type, $cv,
                $unique, $rank );
        }
        elsif ( $num > 1 ) {
            $out .=
              delete_feature_grpmember_pub( $dbh, $doc, $iuname, $type, $cv,
                $unique, $rank, $pub );
        }

    }
    $f_g->finish;

    print STDERR "done feature_grpmember and feature_grpmember_pub\n";

    ###get cell_line_feature
    my $cf_state =
"select cell_line.name from cell_line, cell_line_feature, feature, pub where cell_line.cell_line_id=cell_line_feature.cell_line_id and cell_line_feature.feature_id = feature.feature_id and feature.uniquename='$unique' and cell_line_feature.pub_id = pub.pub_id and pub.uniquename =  '$pub' ";
    my $c_f = $dbh->prepare($cf_state);
    $c_f->execute;
    while ( my ($f_name) = $c_f->fetchrow_array ) {
        my ( $cell_uniquename, $organism_genus, $organism_species ) = get_cell_line_ukeys_by_name( $dbh, $f_name );
        my $cl_feat = create_ch_cell_line_feature(
            doc          => $doc,
            feature_id   => $unique,
            cell_line_id => create_ch_cell_line(
                doc        => $doc,
                uniquename => $cell_uniquename,
                genus      => $organism_genus,
                species    => $organism_species,
            ),
            pub => $pub,
        );
        $cl_feat->setAttribute( 'op', 'delete' );
        $out .= dom_toString($cl_feat);
    }
    $c_f->finish;

    #print STDERR "done cell_line_feature\n";
    ###get feature_phenotype
    #currently is a empty table
    ###get feature_genotype since feature_genotype has no pub, need
    #to get through phenstatement., phendesc... phenotype_comparison....
    my $fg_state = "select genotype.uniquename, cvterm.name from
		phendesc, feature_genotype, cvterm, feature, genotype, pub where
		feature.uniquename='$unique' and
		feature.feature_id=feature_genotype.feature_id and
		feature_genotype.genotype_id=genotype.genotype_id and
		phendesc.genotype_id=genotype.genotype_id and
		phendesc.type_id=cvterm.cvterm_id and 
		phendesc.pub_id=pub.pub_id and pub.uniquename='$pub'";

    #print STDERR "$fg_state\n";
    my $fg_nmm = $dbh->prepare($fg_state);
    $fg_nmm->execute;
    while ( my ( $geno, $cvterm ) = $fg_nmm->fetchrow_array ) {
        my $phdes = create_ch_phendesc(
            doc         => $doc,
            genotype_id => create_ch_genotype(
                doc        => $doc,
                uniquename => $geno
            ),
            environment_id => 'unspecified',
            type_id        => create_ch_cvterm(
                doc  => $doc,
                name => $cvterm,
                cv   => 'phendesc type'
            ),
            pub_id => $pub
        );
        $phdes->setAttribute( 'op', 'delete' );
        $out .= dom_toString($phdes);
        $phdes->dispose();
    }
    $fg_nmm->finish;

    my $phenstate = "select  genotype.uniquename,
		phenotype.uniquename, environment.uniquename, cvterm.name from
		phenstatement, feature_genotype, phenotype, cvterm, genotype,
		pub, environment, feature where
		feature.uniquename='$unique' and environment.environment_id=phenstatement.environment_id
		and phenotype.phenotype_id=phenstatement.phenotype_id and
		feature.feature_id=feature_genotype.feature_id and
		feature_genotype.genotype_id=genotype.genotype_id and
		phenstatement.genotype_id=genotype.genotype_id and
		phenstatement.type_id=cvterm.cvterm_id and 
		phenstatement.pub_id=pub.pub_id and pub.uniquename='$pub'";

    #print STDERR "$phenstate\n";
    my $ps_nmm = $dbh->prepare($phenstate);
    $ps_nmm->execute;
    while ( my ( $genotype, $phenotype, $environ, $pscv ) =
        $ps_nmm->fetchrow_array )
    {
        my $phen = create_ch_phenstatement(
            doc         => $doc,
            genotype_id => create_ch_genotype(
                doc        => $doc,
                uniquename => $genotype
            ),
            phenotype_id => create_ch_phenotype(
                doc        => $doc,
                uniquename => $phenotype
            ),
            environment_id => create_ch_environment(
                doc        => $doc,
                uniquename => $environ
            ),
            pub_id  => $pub,
            type_id => 'unspecified'
        );
        $phen->setAttribute( 'op', 'delete' );
        $out .= dom_toString($phen);
        $phen->dispose();
    }
    $ps_nmm->finish;

    #print STDERR "done phenostatement\n";
    my $phencom_state = "select  genotype1.uniquename,
		genotype2.uniquename, phenotype.uniquename, 
		environment1.uniquename, environment2.uniquename, phenotype_comparison.organism_id from
		phenotype_comparison, feature_genotype, phenotype, cvterm,
		genotype genotype1, genotype genotype2, feature, environment environment1, environment environment2,
		pub where
		feature.uniquename='$unique' and
		feature.feature_id=feature_genotype.feature_id and
		feature_genotype.genotype_id=genotype1.genotype_id and
		phenotype_comparison.genotype1_id=genotype1.genotype_id and
		phenotype_comparison.genotype2_id=genotype2.genotype_id and
		phenotype.phenotype_id=phenotype_comparison.phenotype1_id and
		environment1.environment_id=phenotype_comparison.environment1_id
			and
		environment2.environment_id=phenotype_comparison.environment2_id
			and 
		phenotype_comparison.pub_id=pub.pub_id and pub.uniquename='$pub'
		union
		select  genotype1.uniquename,
		genotype2.uniquename, phenotype.uniquename, 
		environment1.uniquename, environment2.uniquename, phenotype_comparison.organism_id from
		phenotype_comparison, feature, feature_genotype, phenotype, cvterm,
		genotype genotype1, genotype genotype2, 
		environment environment1, environment environment2,
		pub where
		feature.uniquename='$unique' and
		feature.feature_id=feature_genotype.feature_id and
		feature_genotype.genotype_id=genotype2.genotype_id and
		phenotype_comparison.genotype1_id=genotype1.genotype_id and
		phenotype_comparison.genotype2_id=genotype2.genotype_id and
		phenotype.phenotype_id=phenotype_comparison.phenotype1_id and
		environment1.environment_id=phenotype_comparison.environment1_id
			and
		environment2.environment_id=phenotype_comparison.environment2_id
			and 
		phenotype_comparison.pub_id=pub.pub_id and pub.uniquename='$pub'	";

    #print STDERR "$phencom_state\n";
    my $pc_nmm = $dbh->prepare($phencom_state);
    $pc_nmm->execute;
    while (
        my ( $genotype1, $genotype2, $phenotype1, $environ1, $environ2, $o_id )
        = $pc_nmm->fetchrow_array )
    {
        my ( $g, $s ) = get_organism_by_id( $dbh, $o_id );
        my $phencomp = create_ch_phenotype_comparison(
            doc => $doc,
            genotype1_id =>
              create_ch_genotype( doc => $doc, uniquename => $genotype1 ),
            genotype2_id =>
              create_ch_genotype( doc => $doc, uniquename => $genotype2 ),
            phenotype1_id =>
              create_ch_phenotype( doc => $doc, uniquename => $phenotype1 ),
            environment1_id =>
              create_ch_environment( doc => $doc, uniquename => $environ1 ),
            environment2_id =>
              create_ch_environment( doc => $doc, uniquename => $environ2 ),
            organism_id =>
              create_ch_organism( doc => $doc, genus => $g, species => $s ),
            pub_id => $pub
        );
        $phencomp->setAttribute( 'op', 'delete' );
        $out .= dom_toString($phencomp);
        $phencomp->dispose();
    }
    $pc_nmm->finish;

    #print STDERR "done phenotype_comparison\n";
    ##pending.

    ###featureprange,featuremap,featuremap_pub,featurepos not used in DB--ignore
    $doc->dispose();
    return $out;
}

sub get_feature_interaction_pub_nums {
    my $dbh   = shift;
    my $fi_id = shift;

    my $statement = "select pub_id from feature_interaction_pub where
        feature_interaction_id=$fi_id ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub delete_feature_interaction {
    my $doc    = shift;
    my $iuname = shift;
    my $type   = shift;
    my $cv     = shift;
    my $role   = shift;
    my $unique = shift;
    my $rank   = shift;

    my $f = create_ch_feature_interaction(
        doc        => $doc,
        uniquename => $iuname,
        type       => $type,
        role_id    => create_ch_cvterm( doc => $doc, cv => $cv, name => $role ),
        feature_id => $unique,
        rank       => $rank,
    );
    $f->setAttribute( 'op', 'delete' );
    my $out .= dom_toString($f);
    $f->dispose();
    return $out;
}

sub delete_feature_interaction_pub {
    my $doc    = shift;
    my $iuname = shift;
    my $type   = shift;
    my $cv     = shift;
    my $role   = shift;
    my $unique = shift;
    my $rank   = shift;
    my $pub    = shift;

    my $f = create_ch_feature_interaction(
        doc        => $doc,
        uniquename => $iuname,
        type       => $type,
        role_id    => create_ch_cvterm( doc => $doc, cv => $cv, name => $role ),
        feature_id => $unique,
        rank       => $rank,
    );
    my $fip = create_feature_interaction_pub(
        doc    => $doc,
        pub_id => $pub,
    );
    $fip->setAttribute( 'op', 'delete' );
    $f->appendChild($fip);
    my $out = dom_toString($f);
    $f->dispose();
    return $out;
}

sub get_feature_grpmember_pub_nums {
    my $dbh   = shift;
    my $fi_id = shift;

    my $statement = "select pub_id from feature_grpmember_pub where
        feature_grpmember_id=$fi_id ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub delete_feature_grpmember {
    my $dbh    = shift;
    my $doc    = shift;
    my $guname = shift;
    my $type   = shift;
    my $cv     = shift;
    my $unique = shift;
    my $rank   = shift;

    if ( $guname =~ /FBgg/ ) {
        my $f = create_ch_feature_grpmember(
            doc          => $doc,
            feature_id   => $unique,
            grpmember_id => create_ch_grpmember(
                doc => $doc,
                type_id =>
                  create_ch_cvterm( doc => $doc, cv => $cv, name => $type ),
                rank   => $rank,
                grp_id => create_ch_grp(
                    doc        => $doc,
                    uniquename => $guname,
                    type_id    => create_ch_cvterm(
                        doc  => $doc,
                        cv   => "SO",
                        name => "gene_group"
                    ),
                ),
            ),
        );
        $f->setAttribute( 'op', 'delete' );
        my $out .= dom_toString($f);
        $f->dispose();
        return $out;
    }
    elsif ( $guname =~ /FBgn/ ) {
        my ( $genus, $species ) =
          get_feat_ukeys_by_uname_type( $dbh, $guname, 'gene' );
        if ( ( $genus eq '0' && $species eq '2' ) ) {
            print STDERR "ERROR: Could not get feature for $guname\n";
        }
        else {
            my $f = create_ch_feature_grpmember(
                doc        => $doc,
                feature_id => create_ch_feature(
                    doc        => $doc,
                    uniquename => $guname,
                    type       => 'gene',
                    genus      => $genus,
                    species    => $species,
                ),
                grpmember_id => create_ch_grpmember(
                    doc => $doc,
                    type_id =>
                      create_ch_cvterm( doc => $doc, cv => $cv, name => $type ),
                    rank   => $rank,
                    grp_id => $unique,
                ),
            );
            $f->setAttribute( 'op', 'delete' );
            my $out .= dom_toString($f);
            $f->dispose();
            return $out;
        }
    }
}

sub delete_feature_grpmember_pub {
    my $dbh    = shift;
    my $doc    = shift;
    my $guname = shift;
    my $type   = shift;
    my $cv     = shift;
    my $unique = shift;
    my $rank   = shift;
    my $pub    = shift;

    if ( $guname =~ /FBgg/ ) {
        my $f = create_ch_feature_grpmember(
            doc          => $doc,
            feature_id   => $unique,
            grpmember_id => create_ch_grpmember(
                doc    => $doc,
                grp_id => create_ch_grp(
                    doc        => $doc,
                    uniquename => $guname,
                    type_id    => create_ch_cvterm(
                        doc  => $doc,
                        cv   => "SO",
                        name => "gene_group"
                    ),
                ),
                type_id => create_ch_cvterm(
                    doc  => $doc,
                    cv   => $cv,
                    name => $type
                ),
                rank => $rank,
            ),

        );
        my $fip = create_ch_feature_grpmember_pub(
            doc    => $doc,
            pub_id => $pub,
        );
        $fip->setAttribute( 'op', 'delete' );
        $f->appendChild($fip);
        my $out = dom_toString($f);
        $f->dispose();
        return $out;
    }
    elsif ( $guname =~ /FBgn/ ) {
        my ( $genus, $species ) =
          get_feat_ukeys_by_uname_type( $dbh, $guname, 'gene' );
        if ( ( $genus eq '0' && $species eq '2' ) ) {
            print STDERR "ERROR: Could not get feature for $guname\n";
        }
        else {
            my $f = create_ch_feature_grpmember(
                doc        => $doc,
                feature_id => create_ch_feature(
                    doc        => $doc,
                    uniquename => $guname,
                    type       => 'gene',
                    genus      => $genus,
                    species    => $species,
                ),
                grpmember_id => create_ch_grpmember(
                    doc => $doc,
                    type_id =>
                      create_ch_cvterm( doc => $doc, cv => $cv, name => $type ),
                    rank   => $rank,
                    grp_id => $unique,
                ),
            );
            my $fip = create_ch_feature_grpmember_pub(
                doc    => $doc,
                pub_id => $pub,
            );
            $fip->setAttribute( 'op', 'delete' );
            $f->appendChild($fip);
            my $out = dom_toString($f);
            $f->dispose();
            return $out;
        }
    }
}

sub feature_name_change_action {
    my $dbh    = shift;
    my $doc    = shift;
    my $unique = shift;
    my $old    = shift;
    my $new    = shift;
    my $pub    = shift;
    my $out    = '';
    print STDERR "feature_name_change_action: $unique, $old, $new, $pub\n";

    if ( $old =~ /FB/ ) {
        $old = get_name_by_uniquename( $dbh, $old );
    }
    $new = decon($new);
    if ( $old ne $new ) {
        $old =~ s/([\#\(\)\.\\\/\{\}\@\$\'\"\?\*\&])/\\$1/g;
        print STDERR "feature_name_change_action: old $old, new $new\n";
        if ( $unique =~ /FBtp/ ) {
            my $state =
              "select f1.uniquename, f1.name, f1.organism_id, f1.type_id from
			feature f1, feature f2, feature_relationship fr where
			f1.feature_id=fr.subject_id and f2.feature_id=fr.object_id and
			fr.type_id=27 and f2.uniquename='$unique';";    #type_id=27 is 'producedby'

            my $nc_nmm = $dbh->prepare($state);
            $nc_nmm->execute;
            while ( my ( $u, $n, $o, $t ) = $nc_nmm->fetchrow_array ) {
                my $n_s = $n;

                print STDERR "feature_name_change_action: $n_s, $old, $new\n";
                if ( !( $n_s =~ s/$old/$new/ ) ) {
                    print STDERR
"ERROR: could not do name change for $unique, $n, $n_s, $u,$o,$t,$pub\n";
                }
                my ( $g, $s ) = get_organism_by_id( $dbh, $o );
                $out .= dom_toString(
                    create_ch_feature(
                        doc        => $doc,
                        uniquename => $u,
                        genus      => $g,
                        species    => $s,
                        type       => get_type_by_id( $dbh, $t ),
                        name       => $n_s,
                        no_lookup  => 1,
                        macro_id   => $u
                    )
                );
                $fbids{$n}   = $u;
                $fbids{$n_s} = $u;

                $out .= update_feature_synonym( $dbh, $doc, $u, $n, 'symbol' );

                #print STDERR "end feature $u, $n_s, $pub\n";
                $out .=
                  write_feature_name_change_synonyms( $doc, $u, $n_s, 'a',
                    $pub, 'symbol' );

            }
            $nc_nmm->finish;
        }
    }
    return $out;
}

sub get_library_expressionprop_rank {
    my $dbh   = shift;
    my $fb_id = shift;
    my $cv    = shift;
    my $ex_id = shift;
    my $type  = shift;
    my $value = shift;
    my $pub   = shift;
    my $rank  = 0;
    if ( defined($value) ) {
        $value =~ s/\\/\\\\/g;
        $value =~ s/\'/\\\'/g;
    }
    if (   defined($value)
        && defined( $fprank{$fb_id}{ $ex_id . $pub . $type . $value } ) )
    {
        return $fprank{$fb_id}{ $ex_id . $pub . $type . $value };
    }
    else {
        if ( defined( $fprank{$fb_id}{ $ex_id . $pub . $type } ) ) {
            $fprank{$fb_id}{ $ex_id . $pub . $type } += 1;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $ex_id . $pub . $type . $value } =
                  $fprank{$fb_id}{ $ex_id . $pub . $type };
            }
            return $fprank{$fb_id}{ $ex_id . $pub . $type };
        }
        else {
            if ( defined($value) ) {
                my $statement = "select max(library_expressionprop.rank) 
                        from library_expression, library, cv, expression, pub, cvterm cvterm2, library_expressionprop 
			where library_expression.library_id=library.library_id 
                        and library.uniquename='$fb_id' 
                        and library_expressionprop.library_expression_id=library_expression.library_expression_id 
			and library_expressionprop.type_id=cvterm2.cvterm_id and cvterm2.name='$type' 
                        and cvterm2.cv_id=cv.cv_id and cv.name='$cv' 
			and library_expression.expression_id=expression.expression_id 
			and expression.uniquename='$ex_id' 
                        and library_expression.pub_id=pub.pub_id 
                        and pub.uniquename='$pub' and library_expressionprop.value= E'$value'";

                #print STDERR "$statement\n";
                my $fc_el = $dbh->prepare($statement);
                $fc_el->execute;
                my $f_r = $fc_el->fetchrow_array;
                if ( defined($f_r) ) {
                    $fprank{$fb_id}{ $ex_id . $pub . $type . $value } = $f_r;
                    return $f_r;
                }
            }

            my $state = "select max(library_expressionprop.rank) 
                        from library_expression, library, cv, expression, pub, cvterm cvterm2, library_expressionprop 
			where library_expression.library_id=library.library_id 
                        and library.uniquename='$fb_id' 
                        and library_expressionprop.library_expression_id=library_expression.library_expression_id 
			and library_expressionprop.type_id=cvterm2.cvterm_id and cvterm2.name='$type' 
                        and cvterm2.cv_id=cv.cv_id and cv.name='$cv' 
			and library_expression.expression_id=expression.expression_id 
			and expression.uniquename='$ex_id' 
                        and library_expression.pub_id=pub.pub_id 
                        and pub.uniquename='$pub'";

            my $fb_el = $dbh->prepare($state);
            $fb_el->execute;
            while ( my $p_r = $fb_el->fetchrow_array ) {
                if ( $p_r ne '' ) {
                    $rank = $p_r;
                    $rank++;
                }
            }
            $fprank{$fb_id}{ $ex_id . $pub . $type } = $rank;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $ex_id . $pub . $type . $value } = $rank;
            }
            return $rank;
        }

    }
    return $rank;
}

sub get_library_strainprop_rank {
    my $dbh   = shift;
    my $fb_id = shift;
    my $cv    = shift;
    my $ex_id = shift;
    my $type  = shift;
    my $value = shift;
    my $pub   = shift;
    my $rank  = 0;
    if ( defined($value) ) {
        $value =~ s/\\/\\\\/g;
        $value =~ s/\'/\\\'/g;
    }
    if (   defined($value)
        && defined( $fprank{$fb_id}{ $ex_id . $pub . $type . $value } ) )
    {
        return $fprank{$fb_id}{ $ex_id . $pub . $type . $value };
    }
    else {
        if ( defined( $fprank{$fb_id}{ $ex_id . $pub . $type } ) ) {
            $fprank{$fb_id}{ $ex_id . $pub . $type } += 1;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $ex_id . $pub . $type . $value } =
                  $fprank{$fb_id}{ $ex_id . $pub . $type };
            }
            return $fprank{$fb_id}{ $ex_id . $pub . $type };
        }
        else {
            if ( defined($value) ) {
                my $statement = "select max(library_strainprop.rank) 
                        from library_strain, library, cv, strain, pub, cvterm cvterm2, library_strainprop 
			where library_strain.library_id=library.library_id 
                        and library.uniquename='$fb_id' 
                        and library_strainprop.library_strain_id=library_strain.library_strain_id 
			and library_strainprop.type_id=cvterm2.cvterm_id and cvterm2.name='$type' 
                        and cvterm2.cv_id=cv.cv_id and cv.name='$cv' 
			and library_strain.strain_id=strain.strain_id 
			and strain.uniquename='$ex_id' 
                        and library_strain.pub_id=pub.pub_id 
                        and pub.uniquename='$pub' and library_strainprop.value= E'$value'";

                #print STDERR "$statement\n";
                my $fc_el = $dbh->prepare($statement);
                $fc_el->execute;
                my $f_r = $fc_el->fetchrow_array;
                if ( defined($f_r) ) {
                    $fprank{$fb_id}{ $ex_id . $pub . $type . $value } = $f_r;
                    return $f_r;
                }
            }

            my $state = "select max(library_strainprop.rank) 
                        from library_strain, library, cv, strain, pub, cvterm cvterm2, library_strainprop 
			where library_strain.library_id=library.library_id 
                        and library.uniquename='$fb_id' 
                        and library_strainprop.library_strain_id=library_strain.library_strain_id 
			and library_strainprop.type_id=cvterm2.cvterm_id and cvterm2.name='$type' 
                        and cvterm2.cv_id=cv.cv_id and cv.name='$cv' 
			and library_strain.strain_id=strain.strain_id 
			and strain.uniquename='$ex_id' 
                        and library_strain.pub_id=pub.pub_id 
                        and pub.uniquename='$pub'";

            my $fb_el = $dbh->prepare($state);
            $fb_el->execute;
            while ( my $p_r = $fb_el->fetchrow_array ) {
                if ( $p_r ne '' ) {
                    $rank = $p_r;
                    $rank++;
                }
            }
            $fprank{$fb_id}{ $ex_id . $pub . $type } = $rank;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $ex_id . $pub . $type . $value } = $rank;
            }
            return $rank;
        }

    }
    return $rank;
}

sub get_cell_line_libraryprop_rank {
    my $dbh   = shift;
    my $fb_id = shift;
    my $cv    = shift;
    my $ex_id = shift;
    my $type  = shift;
    my $value = shift;
    my $pub   = shift;
    my $rank  = 0;
    if ( defined($value) ) {
        $value =~ s/\\/\\\\/g;
        $value =~ s/\'/\\\'/g;
    }
    if (   defined($value)
        && defined( $fprank{$fb_id}{ $ex_id . $pub . $type . $value } ) )
    {
        return $fprank{$fb_id}{ $ex_id . $pub . $type . $value };
    }
    else {
        if ( defined( $fprank{$fb_id}{ $ex_id . $pub . $type } ) ) {
            $fprank{$fb_id}{ $ex_id . $pub . $type } += 1;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $ex_id . $pub . $type . $value } =
                  $fprank{$fb_id}{ $ex_id . $pub . $type };
            }
            return $fprank{$fb_id}{ $ex_id . $pub . $type };
        }
        else {
            if ( defined($value) ) {
                my $statement = "select max(cell_line_libraryprop.rank) 
                        from cell_line_library, library, cv, cell_line, pub, cvterm cvterm2, cell_line_libraryprop 
			where cell_line_library.library_id=library.library_id 
                        and library.uniquename='$fb_id' 
                        and cell_line_libraryprop.cell_line_library_id=cell_line_library.cell_line_library_id 
			and cell_line_libraryprop.type_id=cvterm2.cvterm_id and cvterm2.name='$type' 
                        and cvterm2.cv_id=cv.cv_id and cv.name='$cv' 
			and cell_line_library.cell_line_id=cell_line.cell_line_id 
			and cell_line.uniquename='$ex_id' 
                        and cell_line_library.pub_id=pub.pub_id 
                        and pub.uniquename='$pub' and cell_line_libraryprop.value= E'$value'";

                #print STDERR "$statement\n";
                my $fc_el = $dbh->prepare($statement);
                $fc_el->execute;
                my $f_r = $fc_el->fetchrow_array;
                if ( defined($f_r) ) {
                    $fprank{$fb_id}{ $ex_id . $pub . $type . $value } = $f_r;
                    return $f_r;
                }
            }

            my $state = "select max(cell_line_libraryprop.rank) 
                        from cell_line_library, library, cv, cell_line, pub, cvterm cvterm2, cell_line_libraryprop 
			where cell_line_library.library_id=library.library_id 
                        and library.uniquename='$fb_id' 
                        and cell_line_libraryprop.cell_line_library_id=cell_line_library.cell_line_library_id 
			and cell_line_libraryprop.type_id=cvterm2.cvterm_id and cvterm2.name='$type' 
                        and cvterm2.cv_id=cv.cv_id and cv.name='$cv' 
			and cell_line_library.cell_line_id=cell_line.cell_line_id 
			and cell_line.uniquename='$ex_id' 
                        and cell_line_library.pub_id=pub.pub_id 
                        and pub.uniquename='$pub'";

            my $fb_el = $dbh->prepare($state);
            $fb_el->execute;
            while ( my $p_r = $fb_el->fetchrow_array ) {
                if ( $p_r ne '' ) {
                    $rank = $p_r;
                    $rank++;
                }
            }
            $fprank{$fb_id}{ $ex_id . $pub . $type } = $rank;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $ex_id . $pub . $type . $value } = $rank;
            }
            return $rank;
        }

    }
    return $rank;
}

sub merge_library_records {
    my $dbh    = shift;
    my $unique = shift;
    my $value  = shift;
    my $a1     = shift;
    my $p      = shift;
    my $a2     = shift;
    my $out    = '';
    my $doc    = new XML::DOM::Document;

    my @items = split( /\n/, $value );

    #$a1 = decon($a1);
    ####obsolete feature
    foreach my $id (@items) {
        my $oldname = $id;
        $id =~ s/^\s+//;
        $id =~ s/\s+$//;
        print STDERR "merging library $id pub $p\n";
        if ( !( $id =~ /^FB/ ) ) {
            $fbids{$id} = $unique;
            my ( $u, $g, $s, $t ) = get_lib_ukeys_by_name( $dbh, $id );
            print STDERR "Action Items: delete $u due to merge\n";
            print STDERR "$u, $id, $a1, $p\n";
            if ( $u ne '0' ) {
                $id = $u;
                my $feat = create_ch_library(
                    doc         => $doc,
                    uniquename  => $u,
                    genus       => $g,
                    species     => $s,
                    type        => $t,
                    is_obsolete => 't',
                    no_lookup   => 1
                );
                $out .= dom_toString($feat);
                $feat->dispose();
            }
            else {
                print STDERR
                  "ERROR: could not get FBid for name $id for merging field\n";
            }
        }
        else {
            print STDERR "Action Items: delete $id due to merge\n";
            my ( $g, $s, $t ) = get_lib_ukeys_by_uname( $dbh, $id );
            my $nn = get_libname_by_uniquename( $dbh, $id );
            $fbids{$nn} = $unique;
            if ( $g ne '0' ) {
                my $feat = create_ch_library(
                    doc         => $doc,
                    uniquename  => $id,
                    genus       => $g,
                    species     => $s,
                    no_lookup   => 1,
                    type        => $t,
                    is_obsolete => 't',
                    macro_id    => $id
                );
                $out .= dom_toString($feat);
                $feat->dispose();
            }
            else {
                print STDERR
                  "ERROR: could not get FBid for  $id for merging field\n";
            }
            ####_dbxref,is_current=0
            my $fdb = create_ch_library_dbxref(
                doc        => $doc,
                library_id => $unique,
                dbxref_id  => create_ch_dbxref(
                    doc       => $doc,
                    db        => 'FlyBase',
                    accession => $id,
                    no_lookup => 1
                ),
                is_current => 'f'
            );
            $out .= dom_toString($fdb);
            $fdb->dispose();
            ###get library_synonym
            my $statement = "select synonym.name, synonym.synonym_sgml,
		library_synonym.is_internal, cvterm.name, pub.uniquename
		from library,synonym,library_synonym,pub,cvterm where
		library.uniquename='$id' and library.library_id=library_synonym.library_id 
		and library_synonym.synonym_id=synonym.synonym_id and
		library_synonym.pub_id=pub.pub_id and
		cvterm.cvterm_id=synonym.type_id;";
            my $nmm = $dbh->prepare($statement);
            $nmm->execute;
            while ( my ( $name, $sgml, $is_internal, $type, $pub ) =
                $nmm->fetchrow_array )
            {
                #print STDERR "name $name, $a1\n";
                my $is_current = 'f';
                print STDERR "Warning: Checking merge symbols $a1 $sgml\n";
                if ( ( $sgml eq $a1 || $sgml eq toutf($a1) )
                    && $type eq 'symbol' )
                {
                    print STDERR "Warning: is_current=t $sgml\n";
                    $is_current = 't';
                }
                if (   defined($a2)
                    && ( $sgml eq toutf($a2) )
                    && ( $type eq 'nickname' ) )
                {
                    print STDERR "Warning: is_current=t $sgml \n";
                    $is_current = 't';
                }
                my $fs = create_ch_library_synonym(
                    doc        => $doc,
                    library_id => $unique,
                    synonym_id => create_ch_synonym(
                        doc          => $doc,
                        name         => $name,
                        synonym_sgml => $sgml,
                        type         => $type
                    ),
                    pub_id => create_ch_pub( doc => $doc, uniquename => $pub ),
                    is_current  => $is_current,
                    is_internal => $is_internal
                );
                $out .= dom_toString($fs);
                $fs->dispose();
            }
            $nmm->finish;

            #        print STDERR "done synonym\n";
            ###get library_dbxref
            my $d_state =
"select library_dbxref.library_dbxref_id, db.name,accession,version,library_dbxref.is_current from
                library_dbxref,dbxref, db,library where
                library_dbxref.library_id=library.library_id and
                library_dbxref.dbxref_id=dbxref.dbxref_id and  
                db.db_id=dbxref.db_id and library.uniquename='$id';";
            my $d_nmm = $dbh->prepare($d_state);
            $d_nmm->execute;
            while ( my ( $ld_id, $db, $acc, $ver, $cur ) =
                $d_nmm->fetchrow_array )
            {
                if ( $acc eq $id ) {
                    $cur = 'f';
                }
                my $dbx = create_ch_dbxref(
                    doc       => $doc,
                    accession => $acc,
                    db        => $db
                );
                if ( $ver ne '' ) {
                    $dbx->appendChild(
                        create_doc_element( $doc, 'version', $ver ) );
                }
                my $fb = create_ch_library_dbxref(
                    doc        => $doc,
                    library_id => $unique,
                    dbxref_id  => $dbx,
                    is_current => $cur
                );
                print STDERR "done library_dbxref\n";
                print STDERR "get library_dbxrefprop\n";
                ###library_dbxrefprop type's default cv is
                #'property type'
                my $sub = "
                    SELECT value, cvterm.name, cv.name, cvterm.is_obsolete
                       FROM library_dbxrefprop, cvterm, cv 
                       WHERE library_dbxrefprop.type_id=cvterm.cvterm_id AND
                             cv.cv_id=cvterm.cv_id AND
			                 library_dbxrefprop.library_dbxref_id=$ld_id";
                my $s_n = $dbh->prepare($sub);
                $s_n->execute;
                while ( my ( $ldp_value, $cvterm_name, $cv_name, $is_obsolete ) = $s_n->fetchrow_array )
                {
                    my $rank =
                       get_library_dbxrefprop_rank( $dbh, $db, $dbx, $unique,
                                                    $cvterm_name, $ldp_value );

                    my $fc = create_ch_library_dbxrefprop(
                        doc     => $doc,
                        type_id => create_ch_cvterm(
                            doc         => $doc,
                            name        => $cvterm_name,
                            cv          => $cv_name,
                            is_obsolete => $is_obsolete
                        ),
                        rank  => $rank,
                        value => $ldp_value,
                    );
                    $fb->appendChild($fc);
                }
                $out .= dom_toString($fb);
                $fb->dispose();
            }
            $d_nmm->finish;

            ######## get cell_line_library cell_line_libraryprop
            my $cll =
"select cell_line_library_id, cell_line.cell_line_id, pub.uniquename from library, cell_line_library, cell_line, pub where library.library_id=cell_line_library.library_id and library.uniquename='$id' and cell_line_library.cell_line_id cell_line.cell_line_id and cell_line_library.pub_id = pub.pub_id";
            my $cll_nmm = $dbh->prepare($cll);
            $cll_nmm->execute;
            while ( my ( $cll_id, $cl_id, $fpub ) = $cll_nmm->fetchrow_array ) {
                my ( $cl_u, $cl_g, $cl_s ) =
                  get_cell_line_ukeys_by_id( $dbh, $cl_id );
                if ( $cl_u eq '0' ) {
                    print STDERR "ERROR: cell_line $cl_id has been obsoleted\n";
                }
                my $lib_cell_line = create_ch_cell_line_library(
                    doc          => $doc,
                    library_id   => $unique,
                    cell_line_id => create_ch_cell_line(
                        doc        => $doc,
                        uniquename => $cl_u,
                        genus      => $cl_g,
                        species    => $cl_s,
                    ),
                    pub => $fpub,
                );
                ###cell_line_libraryprop type's default cv is
                ### cell_line_libraryprop type
                print STDERR "got cell_line_library\n";
                my $sub =
                  "select value, cvterm.name,cv.name, cvterm.is_obsolete 
                        from cell_line_libraryprop, cvterm, cv 
                        where cell_line_libraryprop.type_id=cvterm.cvterm_id 
                        and cv.cv_id=cvterm.cv_id and cv.name = 'cell_line_libraryprop type'
                        and cell_line_libraryprop.cell_line_library_id=$cll_id";
                my $s_n = $dbh->prepare($sub);
                $s_n->execute;
                while ( my ( $value, $type, $cv, $is ) = $s_n->fetchrow_array )
                {
                     my $rank =
                       get_cell_line_libraryprop_rank( $dbh, $unique, $cv, $cl_u, $type, $value );
                    my $cle = create_ch_cell_line_libraryprop(
                        doc     => $doc,
                        type_id => create_ch_cvterm(
                            doc         => $doc,
                            name        => $type,
                            cv          => $cv,
                            is_obsolete => $is
                        ),
                        rank => $rank
                    );
                    $cle->appendChild(
                        create_doc_element( $doc, 'value', $value ) )
                      if ( defined($value) );
                    $lib_cell_line->appendChild($cle);
                }

                $out .= dom_toString($lib_cell_line);
                $lib_cell_line->dispose();
            }
            print STDERR "done cell_line_library cell_line_libraryprop\n";

            $cll_nmm->finish;

            ###get library_cvterm, library_cvtermprop
            my $c_state =
              "select library_cvterm_id,cvterm.name, cv.name, pub.uniquename 
		from library_cvterm, cvterm, cv, pub, library 
                where library.library_id=library_cvterm.library_id and
		library.uniquename='$id' and
		library_cvterm.cvterm_id=cvterm.cvterm_id and
		cvterm.cv_id=cv.cv_id and library_cvterm.pub_id=pub.pub_id";

            my $f_c = $dbh->prepare($c_state);
            $f_c->execute;
            while ( my ( $fc_id, $cvterm, $cv, $fpub ) = $f_c->fetchrow_array )
            {
                my $f = create_ch_library_cvterm(
                    doc        => $doc,
                    name       => $cvterm,
                    cv         => $cv,
                    pub        => $fpub,
                    library_id => $unique,
                );
                ###library_cvtermprop type's default cv is
                #'library_cvtermprop type'
                print STDERR "start library_cvtermprop\n";
                my $sub =
                  "select value, cvterm.name,cv.name, cvterm.is_obsolete from
                        library_cvtermprop, cvterm,cv where
                        library_cvtermprop.type_id=cvterm.cvterm_id and
                        cv.cv_id=cvterm.cv_id and 
                        library_cvtermprop.library_cvterm_id=$fc_id";
                my $s_n = $dbh->prepare($sub);
                $s_n->execute;
                while ( my ( $value, $type, $fcv, $is ) = $s_n->fetchrow_array )
                {
                    my $rank =
                      get_library_cvtermprop_rank( $dbh, $unique, $cv, $cvterm,
                        $type, $value, $fpub );
                    my $fc = create_ch_library_cvtermprop(
                        doc     => $doc,
                        type_id => create_ch_cvterm(
                            doc         => $doc,
                            name        => $type,
                            cv          => $fcv,
                            is_obsolete => $is
                        ),
                        rank => $rank,
                    );
                    $fc->appendChild(
                        create_doc_element( $doc, 'value', $value ) )
                      if ( defined($value) );
                    $f->appendChild($fc);
                }
                $s_n->finish;
                $out .= dom_toString($f);
                $f->dispose();
            }
            $f_c->finish;
            print STDERR "done library_cvterm library_cvtermprop\n";
            ###get library_pub, library_pubprop
            my $fp =
"select library_pub_id,pub.uniquename from library, library_pub,pub
		where library.library_id=library_pub.library_id and
		library.uniquename='$id' and
		pub.pub_id=library_pub.pub_id;";
            my $f_p = $dbh->prepare($fp);
            $f_p->execute;
            while ( my ( $fpub_id, $pub ) = $f_p->fetchrow_array ) {
                my $feat_pub = create_ch_library_pub(
                    doc        => $doc,
                    library_id => $unique,
                    uniquename => $pub
                );

                my $fp_p = "select value, type_id from library_pubprop
                        where library_pub_id=$fpub_id";
                my $ff = $dbh->prepare($fp_p);
                $ff->execute;
                while ( my ( $value, $type ) = $ff->fetchrow_array ) {
                    my $rank =
                      get_library_pubprop_rank( $dbh, $unique, $pub, $type,
                        $value );
                    my ( $cv, $cvterm, $is ) =
                      get_cvterm_ukeys_by_id( $dbh, $type );
                    my $fpp = create_ch_library_pubprop(
                        doc     => $doc,
                        value   => $value,
                        type_id => create_ch_cvterm(
                            doc  => $doc,
                            cv   => $cv,
                            name => $cvterm
                        ),
                        rank => $rank
                    );
                    $feat_pub->appendChild($fpp);
                }
                $out .= dom_toString($feat_pub);
                $feat_pub->dispose();
                $ff->finish;
            }
            $f_p->finish;

            print STDERR "done pub\n";
            ###get libraryprop,libraryprop_pub
            $fp = "select libraryprop_id,value, cvterm.name,cv.name from
		libraryprop, library,cvterm,cv where
		library.library_id=libraryprop.library_id and
                cv.cv_id=cvterm.cv_id and 
		 library.uniquename='$id' and
		cvterm.cvterm_id=libraryprop.type_id;";
            my $fp_nmm = $dbh->prepare($fp);
            $fp_nmm->execute;
            while ( my ( $fp_id, $value, $type, $fpcv ) =
                $fp_nmm->fetchrow_array )
            {
                my $rank =
                  get_max_libraryprop_rank( $dbh, $unique, $type, $value );
                my $fp_doc = create_ch_libraryprop(
                    doc        => $doc,
                    library_id => $unique,
                    value      => $value,
                    type_id    => create_ch_cvterm(
                        doc  => $doc,
                        name => $type,
                        cv   => $fpcv
                    ),
                    rank => $rank,
                );
                my $lpp = "select pub.uniquename from pub, libraryprop_pub
			where libraryprop_pub.pub_id=pub.pub_id and
			libraryprop_pub.libraryprop_id=$fp_id";
                my $lppp = $dbh->prepare($lpp);
                $lppp->execute;
                while ( my ($pub) = $lppp->fetchrow_array ) {
                    my $pp = create_ch_libraryprop_pub(
                        doc        => $doc,
                        uniquename => $pub
                    );
                    $fp_doc->appendChild($pp);
                }
                $out .= dom_toString($fp_doc);
                $fp_doc->dispose();
            }
            $fp_nmm->finish;
            ######## get library_feature library_featureprop
            my $lp =
"select library_feature.library_feature_id, library_feature.feature_id from library, library_feature where library.library_id=library_feature.library_id and library.uniquename='$id'";
            my $lp_nmm = $dbh->prepare($lp);
            $lp_nmm->execute;
            while ( my ( $lf_id, $f_id ) = $lp_nmm->fetchrow_array ) {
                my ( $l_u, $l_g, $l_s, $l_t ) =
                  get_feat_ukeys_by_id( $dbh, $f_id );
                if ( $l_u eq '0' ) {
                    print STDERR "ERROR: feature $f_id has been obsoleted\n";
                }
                my $lib_feat = create_ch_library_feature(
                    doc        => $doc,
                    library_id => $unique,
                    feature_id => create_ch_feature(
                        doc        => $doc,
                        uniquename => $l_u,
                        genus      => $l_g,
                        species    => $l_s,
                        type       => $l_t,
                    )
                );
                ###library_featureprop type's default cv is library_featureprop type
                print STDERR "got library_feature in merge_library\n";
                my $sub =
"select library_featureprop.value, cvterm.name,cv.name, cvterm.is_obsolete 
                        from library_featureprop, cvterm, cv 
                        where library_featureprop.type_id=cvterm.cvterm_id 
                        and cv.cv_id=cvterm.cv_id  
                        and library_featureprop.library_feature_id=$lf_id";
                my $s_n = $dbh->prepare($sub);
                $s_n->execute;
                while ( my ( $value, $type, $cv, $is ) = $s_n->fetchrow_array )
                {
                    my $rank =
                      get_library_featureprop_rank( $dbh, $l_u, $cv, $unique,
                        $type, $value );
                    my $fe = create_ch_library_featureprop(
                        doc     => $doc,
                        type_id => create_ch_cvterm(
                            doc         => $doc,
                            name        => $type,
                            cv          => $cv,
                            is_obsolete => $is
                        ),
                        rank => $rank,

                        #		    value => $value,
                    );
                    $fe->appendChild(
                        create_doc_element( $doc, 'value', $value ) )
                      if ( defined($value) );
                    $lib_feat->appendChild($fe);
                }
                $out .= dom_toString($lib_feat);
                $lib_feat->dispose();
            }
            print STDERR "done library_feature library_featureprop\n";

            $lp_nmm->finish;

            ######## get library_strain library_strainprop
            my $sl =
"select library_strain_id, strain.strain_id, pub.uniquename from library, library_strain, strain, pub where library.library_id=library_strain.library_id and library.uniquename='$id' and library_strain.strain_id strain.strain_id and library_strain.pub_id = pub.pub_id";
            my $sl_nmm = $dbh->prepare($sl);
            $sl_nmm->execute;
            while ( my ( $ls_id, $s_id, $fpub ) = $sl_nmm->fetchrow_array ) {
                my ( $s_u, $s_g, $s_s ) = get_strain_ukeys_by_id( $dbh, $s_id );
                if ( $s_u eq '0' ) {
                    print STDERR "ERROR: strain $s_id has been obsoleted\n";
                }
                my $lib_strain = create_ch_library_strain(
                    doc        => $doc,
                    library_id => $unique,
                    strain_id  => create_ch_strain(
                        doc        => $doc,
                        uniquename => $s_u,
                        genus      => $s_g,
                        species    => $s_s,
                    ),
                    pub => $fpub,
                );
                ###library_strainprop type's default cv is
                ### library_strainprop type
                print STDERR "got library_strain\n";
                my $sub =
                  "select value, cvterm.name,cv.name, cvterm.is_obsolete 
                        from library_strainprop, cvterm, cv 
                        where library_strainprop.type_id=cvterm.cvterm_id 
                        and cv.cv_id=cvterm.cv_id and cv.name = 'library_strainprop type'
                        and library_strainprop.library_strain_id=$ls_id";
                my $s_n = $dbh->prepare($sub);
                $s_n->execute;
                while ( my ( $value, $type, $cv, $is ) = $s_n->fetchrow_array )
                {
                    my $rank =
                      get_library_strainprop_rank( $dbh, $unique, $cv, $s_u,
                        $type, $value );
                    my $fe = create_ch_library_strainprop(
                        doc     => $doc,
                        type_id => create_ch_cvterm(
                            doc         => $doc,
                            name        => $type,
                            cv          => $cv,
                            is_obsolete => $is
                        ),
                        rank => $rank
                    );
                    $fe->appendChild(
                        create_doc_element( $doc, 'value', $value ) )
                      if ( defined($value) );
                    $lib_strain->appendChild($fe);
                }

                $out .= dom_toString($lib_strain);
                $lib_strain->dispose();
            }
            print STDERR "done library_strain library_strainprop\n";

            $sl_nmm->finish;

#### library_expression, library_expressionprop

            ###get library_expression,library_expressionprop
            ##needed by library.pm
            my $e_state =
"select library_expression_id,expression.uniquename,pub.uniquename 
                from library_expression, expression, pub, library 
                where library.library_id=library_expression.library_id 
                and library.uniquename='$id' 
                and library_expression.expression_id=expression.expression_id 
                and library_expression.pub_id=pub.pub_id";

            my $f_e = $dbh->prepare($e_state);
            $f_e->execute;
            while ( my ( $fe_id, $ex_unique, $fpub ) = $f_e->fetchrow_array ) {
                my $f = create_ch_library_expression(
                    doc           => $doc,
                    expression_id => create_ch_expression(
                        doc        => $doc,
                        uniquename => $ex_unique,
                    ),
                    pub        => $fpub,
                    library_id => $unique,
                );
                ###library_expressionprop type's default cv is
                print STDERR "got library_expression\n";
                ### library_expression property type
                my $sub =
                  "select value, cvterm.name,cv.name, cvterm.is_obsolete 
                        from library_expressionprop, cvterm, cv 
                        where library_expressionprop.type_id=cvterm.cvterm_id 
                        and cv.cv_id=cvterm.cv_id 
                        and library_expressionprop.library_expression_id=$fe_id";
                my $s_n = $dbh->prepare($sub);
                $s_n->execute;
                while ( my ( $value, $type, $cv, $is ) = $s_n->fetchrow_array )
                {
                    my $rank =
                      get_library_expressionprop_rank( $dbh, $unique, $cv,
                        $ex_unique, $type, $value, $fpub );
                    my $fe = create_ch_library_expressionprop(
                        doc     => $doc,
                        type_id => create_ch_cvterm(
                            doc         => $doc,
                            name        => $type,
                            cv          => $cv,
                            is_obsolete => $is
                        ),
                        rank => $rank
                    );
                    $fe->appendChild(
                        create_doc_element( $doc, 'value', $value ) )
                      if ( defined($value) );
                    $f->appendChild($fe);
                }
                $out .= dom_toString($f);
                $f->dispose();
                $s_n->finish;
            }
            print STDERR "done library_expression library_expressionprop\n";
            $f_e->finish;

## library_interaction
            ###get library_interaction
            ##needed by library.pm
            my $i_state =
"select library_interaction_id,interaction.uniquename,pub.uniquename 
                from library_interaction, interaction, pub, library 
                where library.library_id=library_interaction.library_id 
                and library.uniquename='$id' 
                and library_interaction.interaction_id=interaction.interaction_id 
                and library_interaction.pub_id=pub.pub_id";

            my $l_i = $dbh->prepare($i_state);
            $l_i->execute;
            while ( my ( $fe_id, $int_unique, $fpub ) = $l_i->fetchrow_array ) {
                my $f = create_ch_library_interaction(
                    doc            => $doc,
                    interaction_id => create_ch_interaction(
                        doc        => $doc,
                        uniquename => $int_unique,
                    ),
                    pub        => $fpub,
                    library_id => $unique,
                );
                $out .= dom_toString($f);
                $f->dispose();
            }
            print STDERR "done library_interaction\n";
            $l_i->finish;

### library_relationship, library_relationship_pub

            ###get library_relationship,fr_pub,frprop,frprop_pub
            my $fr_state =
                "select 'subject_id' as type, fr.library_relationship_id, "
              . "f1.library_id as subject_id, f2.name as name,"
              . " f2.library_id as "
              . "object_id, cvterm.name as frtype,rank from "
              . "library_relationship fr, "
              . "library f1, library f2, cvterm where "
              . "cvterm.cvterm_id=fr.type_id and "
              . "fr.subject_id=f1.library_id and "
              . "fr.object_id=f2.library_id and f1.is_obsolete = false and f1.uniquename='$id' "
              . "union "
              . "select 'object_id' as type, fr.library_relationship_id, f2.library_id as "
              . "subject_id, f1.name as name, f1.library_id as "
              . "object_id, cvterm.name as frtype, rank from "
              . "library_relationship fr, "
              . "library f1, library f2, cvterm where "
              . "cvterm.cvterm_id=fr.type_id and "
              . "fr.subject_id=f1.library_id and "
              . "fr.object_id=f2.library_id and f2.is_obsolete = false and f2.uniquename='$id'";

            # print STDERR $fr_state;

            my $fr_nmm = $dbh->prepare($fr_state);
            $fr_nmm->execute;

            while ( my ($fr_hash) = $fr_nmm->fetchrow_hashref ) {
                my $fr_obj;
                if ( !defined( $fr_hash->{object_id} ) ) {
                    last;
                }

           #print STDERR $fr_hash->{type}, " object_id ", $fr_hash->{object_id},
           #   " subject_id ", $fr_hash->{subject_id}, "\n";

                my $subject_id = 'subject_id';
                my $object_id  = 'object_id';
                my $fr_subject = $fr_hash->{object_id};
                if ( $fr_hash->{type} eq 'object_id' ) {
                    $subject_id = 'object_id';
                    $object_id  = 'subject_id';
                    $fr_subject = $fr_hash->{object_id};
                }
                my $o_u = '';
                if ( defined( $fr_hash->{name} ) ) {

                    if ( defined( $fbids{ $fr_hash->{name} } )
                        && $fbids{ $fr_hash->{name} } =~ /temp/ )
                    {
                        $fr_subject = $fbids{ $fr_hash->{name} };
                        print STDERR
"Warning: check about this library_relationship $fr_subject $unique\n";
                        $o_u = $fbids{ $fr_hash->{name} };
                    }
                    elsif (
                        !defined( $fbids{ $fr_hash->{name} } )
                        || ( defined( $fbids{ $fr_hash->{name} } )
                            && ( $fbids{ $fr_hash->{name} } ne $fr_subject ) )
                      )
                    {
                        ( $o_u, my $o_g, my $o_s, my $o_t ) =
                          get_lib_ukeys_by_id( $dbh, $fr_subject );
                        if ( $o_u eq '0' ) {
                            print STDERR
"===Warning: could not get ukeys for $fr_subject\n";
                            next;
                        }

                        my $library_ob = create_ch_library(
                            doc        => $doc,
                            uniquename => $o_u,
                            type       => $o_t,
                            genus      => $o_g,
                            species    => $o_s,
                            macro_id   => $o_u
                        );
                        $out .= dom_toString($library_ob);
                        $library_ob->dispose();
                        $fbids{ $fr_hash->{name} } = $o_u;
                    }
                }
                else {

                    ( $o_u, my $o_g, my $o_s, my $o_t ) =
                      get_lib_ukeys_by_id( $dbh, $fr_subject );
                    if ( $o_u eq '0' ) {
                        print STDERR
                          "===Warning: could not get ukeys for $fr_subject\n";
                        next;
                    }
                    my $library_ob = create_ch_library(
                        doc        => $doc,
                        uniquename => $o_u,
                        type       => $o_t,
                        genus      => $o_g,
                        species    => $o_s,
                        macro_id   => $o_u
                    );
                    $out .= dom_toString($library_ob);
                    $library_ob->dispose();

                }

                $fr_obj = create_ch_fr(
                    doc         => $doc,
                    $object_id  => $o_u,
                    $subject_id => $unique,
                    rtype       => $fr_hash->{frtype},
                    rank        => $fr_hash->{rank}
                );
                my $fr_id    = $fr_hash->{library_relationship_id};
                my $fr_pub_s = "select uniquename from
			library_relationship_pub, pub
			where library_relationship_id=$fr_id and
			library_relationship_pub.pub_id=pub.pub_id";
                my $frb_nmm = $dbh->prepare($fr_pub_s);
                $frb_nmm->execute;
                while ( my ($fr_pub) = $frb_nmm->fetchrow_array ) {
                    my $fr_pub = create_ch_fr_pub(
                        doc        => $doc,
                        uniquename => $fr_pub
                    );
                    $fr_obj->appendChild($fr_pub);
                }

                $out .= dom_toString($fr_obj);
                $fr_obj->dispose();
            }
            $fr_nmm->finish;

            #        print STDERR "done library_relationship\n";
        }

        #organism_library
        ###get organism_library
        ##needed by library.pm
     #keep organism_library_id in case later need organism_libraryprop (shudder)
        my $o_state =
          "select organism_library_id,organism.genus,organism.species  
                from organism_library, organism, library 
                where library.library_id=organism_library.library_id 
                and library.uniquename='$id' 
                and organism_library.organism_id=organism.organism_id ";

        my $l_o = $dbh->prepare($o_state);
        $l_o->execute;
        while ( my ( $oid, $ogenus, $ospecies ) = $l_o->fetchrow_array ) {
            my $f = create_ch_organism_library(
                doc         => $doc,
                organism_id => create_ch_organism(
                    doc     => $doc,
                    genus   => $ogenus,
                    species => $ospecies,
                ),
                library_id => $unique,
            );
            $out .= dom_toString($f);
            $f->dispose();
        }
        print STDERR "done organism_library\n";
        $l_o->finish;

    }
    $doc->dispose();
    return $out;

}

sub get_library_cvtermprop_rank {
    my $dbh    = shift;
    my $fb_id  = shift;
    my $cv     = shift;
    my $cvterm = shift;
    my $type   = shift;
    my $value  = shift;
    my $pub    = shift;
    my $rank   = 0;
    $cvterm =~ s/\\/\\\\/g;
    $cvterm =~ s/\'/\\\'/g;

    if ( defined($value) ) {
        $value =~ s/\\/\\\\/g;
        $value =~ s/\'/\\\'/g;
    }
    if (   defined($value)
        && defined( $fprank{$fb_id}{ $cvterm . $pub . $type . $value } ) )
    {
        return $fprank{$fb_id}{ $cvterm . $pub . $type . $value };
    }
    else {
        if ( defined( $fprank{$fb_id}{ $cvterm . $pub . $type } ) ) {
            $fprank{$fb_id}{ $cvterm . $pub . $type } += 1;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $cvterm . $pub . $type . $value } =
                  $fprank{$fb_id}{ $cvterm . $pub . $type };
            }
            return $fprank{$fb_id}{ $cvterm . $pub . $type };
        }
        else {
            if ( defined($value) ) {
                my $statement = "select max(library_cvtermprop.rank) from 
                        library_cvterm,
                        library, cv, cvterm, pub, cvterm cvterm2, library_cvtermprop
                        where library_cvterm.library_id=library.library_id and
                        library.uniquename='$fb_id' and
                        library_cvtermprop.library_cvterm_id = 
                        library_cvterm.library_cvterm_id
                        and library_cvtermprop.type_id=cvterm2.cvterm_id and
                        cvterm2.name='$type' 
                                and
                        library_cvterm.cvterm_id=cvterm.cvterm_id and cvterm.cv_id=cv.cv_id
                        and cv.name='$cv' and cvterm.name= E'$cvterm' and 
                        library_cvterm.pub_id=pub.pub_id and
                        pub.uniquename='$pub' and library_cvtermprop.value= E'$value'";

                #print STDERR "$statement\n";
                my $fc_el = $dbh->prepare($statement);
                $fc_el->execute;
                my $f_r = $fc_el->fetchrow_array;
                if ( defined($f_r) ) {
                    $fprank{$fb_id}{ $cvterm . $pub . $type . $value } = $f_r;
                    return $f_r;
                }
            }

            my $state = "select max(library_cvtermprop.rank) from 
                        library_cvterm,
                        library, cv, cvterm, pub, cvterm cvterm2, library_cvtermprop
                        where library_cvterm.library_id=library.library_id and
                        library.uniquename='$fb_id' and
                        library_cvtermprop.library_cvterm_id = 
                        library_cvterm.library_cvterm_id
                        and library_cvtermprop.type_id=cvterm2.cvterm_id and
                        cvterm2.name='$type' and
                        library_cvterm.cvterm_id=cvterm.cvterm_id and cvterm.cv_id=cv.cv_id
                        and cv.name='$cv' and cvterm.name= E'$cvterm' and 

                        pub.uniquename='$pub'";

            my $fb_el = $dbh->prepare($state);
            $fb_el->execute;
            while ( my $p_r = $fb_el->fetchrow_array ) {
                if ( $p_r ne '' ) {
                    $rank = $p_r;
                    $rank++;
                }
            }
            $fprank{$fb_id}{ $cvterm . $pub . $type } = $rank;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $cvterm . $pub . $type . $value } = $rank;
            }
            return $rank;
        }

    }
    return $rank;
}

sub get_library_pubprop_rank {
    my $dbh     = shift;
    my $unique  = shift;
    my $pub     = shift;
    my $type_id = shift;
    my $value   = shift;
    my $rank;
    if ( defined($value) ) {
        $value =~ s/([\'\\\/\(\)])/\\$1/g;
    }
    if ( defined($value)
        && exists( $fprank{ $unique . $pub }{ $type_id . $value } ) )
    {
        return $fprank{ $unique . $pub }{ $type_id . $value };
    }
    elsif ( exists( $fprank{ $unique . $pub }{$type_id} ) ) {
        $fprank{ $unique . $pub }{$type_id} += 1;
        return $fprank{ $unique . $pub }{$type_id};
    }
    else {
        my $statement;
        if ( defined($value) ) {
            $statement =
"select rank from library_pubprop, library, pub, library_pub where library.library_id=library_pub.library_id and pub.pub_id=library_pub.pub_id and library_pub.library_pub_id=library_pubprop.library_pub_id and library.uniquename='$unique' and pub.uniquename='$pub' and library_pubprop.type_id=$type_id and value='$value';";

            my $nmm = $dbh->prepare($statement);
            $nmm->execute;
            $rank = $nmm->fetchrow_array;

        }
        if ( !defined($rank) ) {
            my $statement =
"select max(rank) from library_pubprop, library, pub, library_pub where library.library_id=library_pub.library_id and pub.pub_id=library_pub.pub_id and library_pub.library_pub_id=library_pubprop.library_pub_id and library.uniquename='$unique' and pub.uniquename='$pub' and library_pubprop.type_id=$type_id;";
            my $ff_nmm = $dbh->prepare($statement);
            $ff_nmm->execute;
            $rank = $ff_nmm->fetchrow_array;
            if ( !defined($rank) ) {
                $rank = 0;
                if ( defined($value) ) {
                    $fprank{ $unique . $pub }{ $type_id . $value } = 0;
                }
                $fprank{ $unique . $pub }{$type_id} = 0;

            }
            else {
                $fprank{ $unique . $pub }{$type_id} = $rank + 1;
                if ( defined($value) ) {
                    $fprank{ $unique . $pub }{ $type_id . $value } = $rank + 1;
                }
                $rank = $fprank{ $unique . $pub }{$type_id};
            }

        }
        else {
            $fprank{ $unique . $pub }{ $type_id . $value } = $rank;
        }
    }

    return $rank;
}

sub merge_cell_line_records {
    my $dbh    = shift;
    my $unique = shift;
    my $value  = shift;
    my $a1     = shift;
    my $p      = shift;
    my $out    = '';
    my $doc    = new XML::DOM::Document;

    my @items = split( /\n/, $value );

    #$a1 = decon($a1);
    ####obsolete feature
    foreach my $id (@items) {
        my $oldname = $id;
        $id =~ s/^\s+//;
        $id =~ s/\s+$//;
        print STDERR "merging $id pub $p\n";
        if ( !( $id =~ /^FB/ ) ) {
            $fbids{$id} = $unique;
            my ( $u, $g, $s ) = get_cell_line_ukeys_by_name( $dbh, $id );
            print STDERR "Action Items: delete $u due to merge\n";
            if ( $u ne '0' ) {
                $id = $u;
                my $feat = create_ch_cell_line(
                    doc        => $doc,
                    uniquename => $u,
                    genus      => $g,
                    species    => $s,
                    no_lookup  => 1
                );
                $out .= dom_toString($feat);
                $feat->dispose();
            }
            else {
                print STDERR
                  "ERROR: could not get FBid for name $id for merging field\n";
            }
        }
        else {
            print STDERR "Action Items: delete $id due to merge\n";
            my ( $u, $g, $s ) = get_cell_line_ukeys_by_uname( $dbh, $id );
            my $nn = get_cell_line_name_by_uniquename( $dbh, $id );
            $fbids{$nn} = $unique;
            if ( $g ne '0' ) {
                my $feat = create_ch_cell_line(
                    doc        => $doc,
                    uniquename => $id,
                    genus      => $g,
                    species    => $s,
                    no_lookup  => 1,
                    macro_id   => $id
                );
                $out .= dom_toString($feat);
                $feat->dispose();
            }
            else {
                print STDERR
                  "ERROR: could not get FBid for  $id for merging field\n";
            }
        }
        my $statement = "select synonym.name, synonym.synonym_sgml,
		cell_line_synonym.is_internal, cvterm.name, pub.uniquename
		from cell_line,synonym,cell_line_synonym,pub,cvterm where
		cell_line.uniquename='$id' and cell_line.cell_line_id=cell_line_synonym.cell_line_id 
		and cell_line_synonym.synonym_id=synonym.synonym_id and
		cell_line_synonym.pub_id=pub.pub_id and
		cvterm.cvterm_id=synonym.type_id;";
        my $nmm = $dbh->prepare($statement);
        $nmm->execute;
        while ( my ( $name, $sgml, $is_internal, $type, $pub ) =
            $nmm->fetchrow_array )
        {
            #print STDERR "name $name, $a1\n";
            my $is_current = 'f';
            if ( $sgml eq $a1 && $type eq 'symbol' ) {

                $is_current = 't';
            }
            my $fs = create_ch_cell_line_synonym(
                doc          => $doc,
                cell_line_id => $unique,
                synonym_id   => create_ch_synonym(
                    doc          => $doc,
                    name         => $name,
                    synonym_sgml => $sgml,
                    type         => $type
                ),
                pub_id      => create_ch_pub( doc => $doc, uniquename => $pub ),
                is_current  => $is_current,
                is_internal => $is_internal
            );
            $out .= dom_toString($fs);
            $fs->dispose();
        }
        $nmm->finish;
        my $c_state =
          "select cell_line_cvterm_id,cvterm.name, cv.name, pub.uniquename,
		cell_line_cvterm.is_not from
		cell_line_cvterm, cvterm, cv, pub, cell_line where
		cell_line.cell_line_id=cell_line_cvterm.cell_line_id and
		cell_line.uniquename='$id' and
		cell_line_cvterm.cvterm_id=cvterm.cvterm_id and
		cvterm.cv_id=cv.cv_id and cell_line_cvterm.pub_id=pub.pub_id";

        my $f_c = $dbh->prepare($c_state);
        $f_c->execute;
        while ( my ( $fc_id, $cvterm, $cv, $fpub, $is_not ) =
            $f_c->fetchrow_array )
        {
            my $f = create_ch_cell_line_cvterm(
                doc          => $doc,
                name         => $cvterm,
                cv           => $cv,
                pub          => $fpub,
                cell_line_id => $unique,
                is_not       => $is_not
            );
            $out .= dom_toString($f);
            $f->dispose();
        }

        # print STDERR "done cvterm\n";
        ###get feature_pub, feature_pubprop
        my $fp =
"select cell_line_pub_id,pub.uniquename from cell_line, cell_line_pub,pub
		where cell_line.cell_line_id=cell_line_pub.cell_line_id and
		cell_line.uniquename='$id' and
		pub.pub_id=cell_line_pub.pub_id;";
        my $f_p = $dbh->prepare($fp);
        $f_p->execute;
        while ( my ( $fpub_id, $pub ) = $f_p->fetchrow_array ) {
            my $feat_pub = create_ch_cell_line_pub(
                doc          => $doc,
                cell_line_id => $unique,
                uniquename   => $pub
            );

            $out .= dom_toString($feat_pub);
        }

        #print STDERR "done pub\n";
        ###get cell_lineprop,cell_lineprop_pub
        $fp = "select cell_lineprop_id,value, cvterm.name,cv.name from
		cell_lineprop, cell_line,cvterm,cv where
		cell_line.cell_line_id=cell_lineprop.cell_line_id and
                cv.cv_id=cvterm.cv_id and 
		 cell_line.uniquename='$id' and
		cvterm.cvterm_id=cell_lineprop.type_id;";
        my $fp_nmm = $dbh->prepare($fp);
        $fp_nmm->execute;
        while ( my ( $fp_id, $value, $type, $fpcv ) = $fp_nmm->fetchrow_array )
        {
            my $rank =
              get_max_cell_lineprop_rank( $dbh, $unique, $type, $value );
            my $fp_doc = create_ch_cell_lineprop(
                doc          => $doc,
                cell_line_id => $unique,
                value        => $value,
                type_id      => create_ch_cvterm(
                    doc  => $doc,
                    name => $type,
                    cv   => $fpcv
                ),
                rank => $rank
            );
            my $clpp = "select pub.uniquename from pub, cell_lineprop_pub
			where cell_lineprop_pub.pub_id=pub.pub_id and
			cell_lineprop_pub.cell_lineprop_id=$fp_id";
            my $clppp = $dbh->prepare($clpp);
            $clppp->execute;
            while ( my ($pub) = $clppp->fetchrow_array ) {
                my $pp = create_ch_cell_lineprop_pub(
                    doc        => $doc,
                    uniquename => $pub
                );
                $fp_doc->appendChild($pp);
            }

            $out .= dom_toString($fp_doc);
            $fp_doc->dispose();
        }
        $fp_nmm->finish;
        ######## get cell_line_feature
        my $lp =
"select feature_id from cell_line, cell_line_feature where cell_line.cell_line_id=cell_line_feature.cell_line_id and cell_line.uniquename='$id'";
        my $lp_nmm = $dbh->prepare($lp);
        $lp_nmm->execute;
        while ( my ($f_id) = $lp_nmm->fetchrow_array ) {
            my ( $l_u, $l_g, $l_s, $l_t ) = get_feat_ukeys_by_id( $dbh, $f_id );
            if ( $l_u eq '0' ) {
                print STDERR "ERROR: feature $f_id has been obsoleted\n";
            }
            my $lib_feat = create_ch_cell_line_feature(
                doc          => $doc,
                cell_line_id => $unique,
                feature_id   => create_ch_feature(
                    doc        => $doc,
                    uniquename => $l_u,
                    genus      => $l_g,
                    species    => $l_s,
                    type       => $l_t
                )
            );
            $out .= dom_toString($lib_feat);
        }
    }
}

sub get_phenotype_by_id {
    my $dbh    = shift;
    my $id     = shift;
    my @result = ();
    my $state  = "select uniquename from phenotype where phenotype_id=$id";

    my $nmm = $dbh->prepare($state);
    $nmm->execute;
    my ($feature) = $nmm->fetchrow_array;

    #print STDERR "phenotype $feature\n";
    return $feature;
}

sub get_genotype_by_id {
    my $dbh    = shift;
    my $id     = shift;
    my @result = ();
    my $state  = "select uniquename from genotype where genotype_id=$id";

    my $nmm = $dbh->prepare($state);
    $nmm->execute;
    my ($feature) = $nmm->fetchrow_array;

    #print STDERR "genotype $feature\n";
    return $feature;
}

sub get_environment_by_id {
    my $dbh    = shift;
    my $id     = shift;
    my @result = ();
    my $state  = "select uniquename from environment where environment_id=$id";

    my $nmm = $dbh->prepare($state);
    $nmm->execute;
    my ($feature) = $nmm->fetchrow_array;

    # print STDERR "environment $feature\n";
    return $feature;
}

sub get_library_dbxref_by_type {
    my $dbh       = shift;
    my $unique    = shift;
    my $type      = shift;
    my @dbs       = ();
    my $statement = "select db.name, dbxref.accession , dbxref.version,
	 library_dbxrefprop.rank, library_dbxrefprop.value from db, dbxref, library_dbxrefprop, library, library_dbxref, cvterm  where
	 db.db_id=dbxref.db_id and dbxref.dbxref_id=library_dbxref.dbxref_id and
	 library.uniquename='$unique' and
	 library.library_id=library_dbxref.library_id and library_dbxref.library_dbxref_id = library_dbxrefprop.library_dbxref_id and library_dbxrefprop.type_id=cvterm.cvterm_id and cvterm.name='$type'";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $db, $acc, $ver, $rank, $value ) = $nmm->fetchrow_array ) {
        my $dbxref = {
            db       => $db,
            acc      => $acc,
            version  => $ver,
            proprank => $rank,
            value    => $value
        };
        push( @dbs, $dbxref );
    }
    return @dbs;
}

sub get_unique_key_for_library_dbxref_byprop {
    my $dbh     = shift;
    my $lunique = shift;
    my $dname   = shift;
    my $acc     = shift;
    my $prop    = shift;
    my $ver     = "";

    my $statement =
"select db.name, dx.accession, dx.version from db, dbxref dx, library_dbxrefprop, library_dbxref, library, cvterm where library_dbxrefprop.type_id = cvterm.cvterm_id and cvterm.name = '$prop' and library_dbxrefprop.library_dbxref_id = library_dbxref.library_dbxref_id and library_dbxref.library_id = library.library_id and library.uniquename = '$lunique' and library_dbxref.dbxref_id = dx.dbxref_id and dx.db_id = db.db_id and db.name = '$dname' and dx.accession = '$acc';";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num != 1 ) {
        print STDERR
"In get_unique_key_for_library_dbxref_byprop $lunique library_dbxrefprop $prop library_dbxref not found or multiple for $dname:$acc \n";
        return "0";
    }
    ( $dname, $acc, $ver ) = $nmm->fetchrow_array();

    return ( $dname, $acc, $ver );
}

sub get_unique_key_for_grp_dbxref {
    my $dbh     = shift;
    my $lunique = shift;
    my $dname   = shift;
    my $acc     = shift;
    my $ver     = "";

    my $statement =
"select db.name, dx.accession, dx.version from db, dbxref dx, grp_dbxref, grp where grp_dbxref.grp_id = grp.grp_id and grp.uniquename = '$lunique' and grp_dbxref.dbxref_id = dx.dbxref_id and dx.db_id = db.db_id and db.name = '$dname' and dx.accession = '$acc';";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num != 1 ) {
        print STDERR
"In get_unique_key_for_grp_dbxref $lunique grp_dbxref not found or multiple for $dname:$acc \n";
        return "0";
    }
    ( $dname, $acc, $ver ) = $nmm->fetchrow_array();

    return ( $dname, $acc, $ver );
}

sub get_unique_key_for_tool_dbxref {
    my $dbh     = shift;
    my $lunique = shift;
    my $dname   = shift;
    my $acc     = shift;
    my $ver     = "NA";

    my $statement =
"select db.name, dx.accession, dx.version from db, dbxref dx, feature_dbxref, feature where feature_dbxref.feature_id = feature.feature_id and feature.uniquename = '$lunique' and feature_dbxref.dbxref_id = dx.dbxref_id and dx.db_id = db.db_id and db.name = '$dname' and dx.accession = '$acc';";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num != 1 ) {
        print STDERR
"In get_unique_key_for_tool_dbxref $lunique feature_dbxref not found or multiple for $dname:$acc \n";
        return "0";
    }
    ( $dname, $acc, $ver ) = $nmm->fetchrow_array();
    print STDERR
"In get_unique_key_for_tool_dbxref db $dname accession $acc version $ver \n";
    if ( $ver eq "" ) {
        $ver = "NA";
    }
    return ( $dname, $acc, $ver );
}

sub get_unique_key_for_humanhealth_dbxref_byprop {
    my $dbh     = shift;
    my $hunique = shift;
    my $dname   = shift;
    my $acc     = shift;
    my $prop    = shift;
    my $ver     = "";

    my $statement =
"select db.name, dx.accession, dx.version from db, dbxref dx, humanhealth_dbxrefprop, humanhealth_dbxref, humanhealth, cvterm where humanhealth_dbxrefprop.type_id = cvterm.cvterm_id and cvterm.name = '$prop' and humanhealth_dbxrefprop.humanhealth_dbxref_id = humanhealth_dbxref.humanhealth_dbxref_id and humanhealth_dbxref.humanhealth_id = humanhealth.humanhealth_id and humanhealth.uniquename = '$hunique' and humanhealth_dbxref.dbxref_id = dx.dbxref_id and dx.db_id = db.db_id and db.name = '$dname' and dx.accession = '$acc';";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num != 1 ) {
        print STDERR
"In get_unique_key_for_humanhealth_dbxref_byprop $hunique humanhealth_dbxrefprop $prop humanhealth_dbxref not found or multiple for $dname:$acc \n";
        return "0";
    }
    ( $dname, $acc, $ver ) = $nmm->fetchrow_array();

    return ( $dname, $acc, $ver );
}

sub merge_records {
    my $dbh    = shift;
    my $unique = shift;
    my $value  = shift;
    my $a1     = shift;
    my $p      = shift;
    my $a2     = shift;
    my $out    = '';
    my $doc    = new XML::DOM::Document;

    my @items = split( /\n/, $value );

    #$a1 = decon($a1);
    ####obsolete feature
    foreach my $id (@items) {
        my $oldname = $id;
        $id =~ s/^\s+//;
        $id =~ s/\s+$//;
        print STDERR "merging $id pub $p\n";
        if ( !( $id =~ /^FB/ ) ) {
            $fbids{$id} = $unique;
            my ( $u, $g, $s, $t ) = get_feat_ukeys_by_name( $dbh, $id );
            print STDERR "Action Items: delete $u due to merge\n";
            print STDERR "$u, $id, $a1, $p\n";
            $out .= feature_name_change_action( $dbh, $doc, $u, $id, $a1, $p );
            if ( $u ne '0' || $u ne '2' ) {
                $id = $u;
                my $feat = create_ch_feature(
                    doc         => $doc,
                    uniquename  => $u,
                    genus       => $g,
                    species     => $s,
                    type        => $t,
                    is_obsolete => 't',
                    no_lookup   => 1
                );
                $out .= dom_toString($feat);
                $feat->dispose();
            }
            else {
                print STDERR
                  "ERROR: could not get FBid for name $id for merging field\n";
            }
        }
        else {
            print STDERR "Action Items: delete $id due to merge\n";
            my ( $g, $s, $t ) = get_feat_ukeys_by_uname( $dbh, $id );
            my $nn = get_name_by_uniquename( $dbh, $id );
            $fbids{$nn} = $unique;
            $out .= feature_name_change_action( $dbh, $doc, $id, $id, $a1, $p );
            if ( $g ne '0' ) {
                if ( $t eq 'split system combination' ) {
                    my $feat = create_ch_feature(
                        doc         => $doc,
                        uniquename  => $id,
                        genus       => $g,
                        species     => $s,
                        no_lookup   => 1,
                        type        => $t,
                        cvname     => 'FlyBase miscellaneous CV',
                        is_obsolete => 't',
                        macro_id    => $id
                    );
                    $out .= dom_toString($feat);
                    $feat->dispose();
                }
                else {
                    my $feat = create_ch_feature(
                        doc         => $doc,
                        uniquename  => $id,
                        genus       => $g,
                        species     => $s,
                        no_lookup   => 1,
                        type        => $t,
                        is_obsolete => 't',
                        macro_id    => $id
                    );
                    $out .= dom_toString($feat);
                    $feat->dispose();
                }
            }
            else {
                print STDERR
                  "ERROR: could not get FBid for  $id for merging field\n";
            }
        }
        ####feature_dbxref,is_current=0
        my $fdb = create_ch_feature_dbxref(
            doc        => $doc,
            feature_id => $unique,
            dbxref_id  => create_ch_dbxref(
                doc       => $doc,
                db        => 'FlyBase',
                accession => $id,
                no_lookup => 1
            ),
            is_current => 'f'
        );
        $out .= dom_toString($fdb);
        $fdb->dispose();
        ###get feature_synonym
        #$a1=~s/([\(\)\[\]\#\\\/\-])/\\$1/g;
        my $statement = "select synonym.name, synonym.synonym_sgml,
		feature_synonym.is_internal, cvterm.name, pub.uniquename
		from feature,synonym,feature_synonym,pub,cvterm where
		feature.uniquename='$id' and feature.feature_id=feature_synonym.feature_id 
		and feature_synonym.synonym_id=synonym.synonym_id and
	   feature.is_analysis='f' and 
		feature_synonym.pub_id=pub.pub_id and
		cvterm.cvterm_id=synonym.type_id;";
        my $nmm = $dbh->prepare($statement);
        $nmm->execute;
        while ( my ( $name, $sgml, $is_internal, $type, $pub ) =
            $nmm->fetchrow_array )
        {
            #print STDERR "name $name, $a1\n";
            my $is_current = 'f';
            print STDERR "Warning: Checking merge symbols $a1 $sgml\n";
            if ( ( $sgml eq $a1 || $sgml eq toutf($a1) ) && $type eq 'symbol' )
            {
                print STDERR "Warning: is_current=t $sgml\n";
                $is_current = 't';
            }
            if (   defined($a2)
                && ( $sgml eq toutf($a2) )
                && ( $type eq 'fullname' ) )
            {
                print STDERR "Warning: is_current=t $sgml \n";
                $is_current = 't';
            }
            my $fs = create_ch_feature_synonym(
                doc        => $doc,
                feature_id => $unique,
                synonym_id => create_ch_synonym(
                    doc          => $doc,
                    name         => $name,
                    synonym_sgml => $sgml,
                    type         => $type
                ),
                pub_id      => create_ch_pub( doc => $doc, uniquename => $pub ),
                is_current  => $is_current,
                is_internal => $is_internal
            );
            $out .= dom_toString($fs);
            $fs->dispose();
        }
        $nmm->finish;

        #        print STDERR "done synonym\n";
        ###get feature_dbxref
        my $d_state =
          "select db.name,accession,version,feature_dbxref.is_current from
		feature_dbxref,dbxref, db,feature where
		feature_dbxref.feature_id=feature.feature_id and
		feature_dbxref.dbxref_id=dbxref.dbxref_id and  
		feature.is_analysis='f' and
		db.db_id=dbxref.db_id and feature.uniquename='$id';";
        my $d_nmm = $dbh->prepare($d_state);
        $d_nmm->execute;
        while ( my ( $db, $acc, $ver, $cur ) = $d_nmm->fetchrow_array ) {
            if ( $acc eq $id ) {
                $cur = 'f';
            }
            my $dbx = create_ch_dbxref(
                doc       => $doc,
                accession => $acc,
                db        => $db
            );
            if ( $ver ne '' ) {
                $dbx->appendChild(
                    create_doc_element( $doc, 'version', $ver ) );
            }
            my $fb = create_ch_feature_dbxref(
                doc        => $doc,
                feature_id => $unique,
                dbxref_id  => $dbx,
                is_current => $cur
            );
            $out .= dom_toString($fb);
            $fb->dispose();
        }
        $d_nmm->finish;

        #        print STDERR "done dbxref\n";
        ###get feature_cvterm,feature_cvtermprop
        my $c_state =
"select feature_cvterm_id,cvterm.name, cv.name, cvterm.is_obsolete, pub.uniquename,
		feature_cvterm.is_not from
		feature_cvterm, cvterm, cv, pub,  feature where
		feature.feature_id=feature_cvterm.feature_id and
		feature.uniquename='$id' and
		feature.is_analysis='f' and
		feature_cvterm.cvterm_id=cvterm.cvterm_id and
		cvterm.cv_id=cv.cv_id and feature_cvterm.pub_id=pub.pub_id";

        my $f_c = $dbh->prepare($c_state);
        $f_c->execute;
        while ( my ( $fc_id, $cvterm, $cv, $obsolete, $fpub, $is_not ) =
            $f_c->fetchrow_array )
        {
            my $f = create_ch_feature_cvterm(
                doc       => $doc,
                cvterm_id => create_ch_cvterm(
                    doc         => $doc,
                    cv          => $cv,
                    name        => $cvterm,
                    is_obsolete => $obsolete
                ),
                pub        => $fpub,
                feature_id => $unique,
                is_not     => $is_not
            );
            ###feature_cvtermprop type's default cv is
            #'feature_cvtermprop type'
            if ( $unique =~ /^FBal/ && $cv eq 'disease_ontology' ) {
                print STDERR
"GA34a merge: check rank , type, value for each DOID/pub in feature_cvtermprop!\n";
                my $sub =
"select value, cvterm.name,cv.name, cvterm.is_obsolete,rank from
			feature_cvtermprop, cvterm,cv where
			feature_cvtermprop.type_id=cvterm.cvterm_id and
                        cv.cv_id=cvterm.cv_id and 
			feature_cvtermprop.feature_cvterm_id=$fc_id order by rank, cvterm.name";
                my $s_n = $dbh->prepare($sub);
                $s_n->execute;
                while ( my ( $value, $type, $fcv, $is, $rank ) =
                    $s_n->fetchrow_array )
                {
                    print STDERR
"existing $type,$fcv, rank = $rank for $unique, $cvterm, $fpub\n";
                    my $fc = create_ch_feature_cvtermprop(
                        doc     => $doc,
                        type_id => create_ch_cvterm(
                            doc         => $doc,
                            name        => $type,
                            cv          => $fcv,
                            is_obsolete => $is
                        ),
                        rank => $rank,
                    );
                    $fc->appendChild(
                        create_doc_element( $doc, 'value', $value ) )
                      if ( defined($value) );
                    $f->appendChild($fc);
                }
                $s_n->finish;
            }
            else {
                my $sub =
                  "select value, cvterm.name,cv.name, cvterm.is_obsolete from
			feature_cvtermprop, cvterm,cv where
			feature_cvtermprop.type_id=cvterm.cvterm_id and
                        cv.cv_id=cvterm.cv_id and 
			feature_cvtermprop.feature_cvterm_id=$fc_id";
                my $s_n = $dbh->prepare($sub);
                $s_n->execute;
                while ( my ( $value, $type, $fcv, $is ) = $s_n->fetchrow_array )
                {
                    my $rank =
                      get_feature_cvtermprop_rank( $dbh, $unique, $fcv, $cvterm,
                        $type, $value, $fpub );
                    if ( $type eq 'date' ) {
                        $rank = 0;
                    }
                    my $fc = create_ch_feature_cvtermprop(
                        doc     => $doc,
                        type_id => create_ch_cvterm(
                            doc         => $doc,
                            name        => $type,
                            cv          => $fcv,
                            is_obsolete => $is
                        ),
                        rank => $rank,
                    );
                    $fc->appendChild(
                        create_doc_element( $doc, 'value', $value ) )
                      if ( defined($value) );
                    $f->appendChild($fc);
                }
                $s_n->finish;
            }
            $out .= dom_toString($f);
            $f->dispose();
        }
        $f_c->finish;

        #        print STDERR "done feature_cvterm, feature_cvtermprop\n";
        ###get feature_pub, feature_pubprop
        my $fp =
          "select feature_pub_id,pub.uniquename from feature, feature_pub,pub
		where feature.feature_id=feature_pub.feature_id and
		feature.is_analysis='f' and feature.uniquename='$id' and
		pub.pub_id=feature_pub.pub_id;";
        my $f_p = $dbh->prepare($fp);
        $f_p->execute;
        while ( my ( $fpub_id, $pub ) = $f_p->fetchrow_array ) {
            my $feat_pub = create_ch_feature_pub(
                doc        => $doc,
                feature_id => $unique,
                uniquename => $pub
            );
            my $fp_p = "select value, type_id from feature_pubprop
			where feature_pub_id=$fpub_id";
            my $ff = $dbh->prepare($fp_p);
            $ff->execute;
            while ( my ( $value, $type ) = $ff->fetchrow_array ) {
                my $rank = get_feature_pubprop_rank( $dbh, $unique, $pub, $type,
                    $value );
                my ( $cv, $cvterm, $is ) =
                  get_cvterm_ukeys_by_id( $dbh, $type );
                my $fpp = create_ch_feature_pubprop(
                    doc     => $doc,
                    value   => $value,
                    type_id => create_ch_cvterm(
                        doc  => $doc,
                        cv   => $cv,
                        name => $cvterm
                    ),
                    rank => $rank
                );
                $feat_pub->appendChild($fpp);
            }

            $out .= dom_toString($feat_pub);
            $feat_pub->dispose();
            $ff->finish;
        }
        $f_p->finish;

        #        print STDERR "done pub\n";
        ###get featureprop,featureprop_pub
        $fp = "select featureprop_id,value, cvterm.name,cv.name from
		featureprop, feature,cvterm,cv where
		feature.feature_id=featureprop.feature_id and
                cv.cv_id=cvterm.cv_id and 
		feature.is_analysis='f' and feature.uniquename='$id' and
		cvterm.cvterm_id=featureprop.type_id;";

        #		  print STDERR $fp, "\n";
        my $fp_nmm = $dbh->prepare($fp);
        $fp_nmm->execute;
        while ( my ( $fp_id, $value, $type, $fpcv ) = $fp_nmm->fetchrow_array )
        {
            my $rank = get_max_featureprop_rank( $dbh, $unique, $type, $value );
            my $fp_doc = create_ch_featureprop(
                doc        => $doc,
                feature_id => $unique,
                value      => $value,
                type_id    => create_ch_cvterm(
                    doc  => $doc,
                    name => $type,
                    cv   => $fpcv
                ),
                rank => $rank
            );
            my $fpp = "select pub.uniquename from pub, featureprop_pub
			where featureprop_pub.pub_id=pub.pub_id and
			featureprop_pub.featureprop_id=$fp_id";
            my $fppp = $dbh->prepare($fpp);
            $fppp->execute;
            while ( my ($pub) = $fppp->fetchrow_array ) {
                my $pp =
                  create_ch_featureprop_pub( doc => $doc, uniquename => $pub );
                $fp_doc->appendChild($pp);
            }

            # if($fpcv eq 'property type'){
            $out .= dom_toString($fp_doc);

            #  }
            $fp_doc->dispose();
        }
        $fp_nmm->finish;

        # print STDERR "done featureprop\n";
        ###get feature_relationship,fr_pub,frprop,frprop_pub
        my $fr_state =
            "select 'subject_id' as type, fr.feature_relationship_id, "
          . "f1.feature_id as subject_id, f2.name as name,"
          . " f2.feature_id as "
          . "object_id, cvterm.name as frtype,rank from "
          . "feature_relationship fr, "
          . "feature f1, feature f2, cvterm where "
          . "cvterm.cvterm_id=fr.type_id and "
          . "fr.subject_id=f1.feature_id and "
          . "fr.object_id=f2.feature_id and f1.is_obsolete = false and f1.uniquename='$id' "
          . "union "
          . "select 'object_id' as type, fr.feature_relationship_id, f2.feature_id as "
          . "subject_id, f1.name as name, f1.feature_id as "
          . "object_id, cvterm.name as frtype, rank from "
          . "feature_relationship fr, "
          . "feature f1, feature f2, cvterm where "
          . "cvterm.cvterm_id=fr.type_id and "
          . "fr.subject_id=f1.feature_id and "
          . "fr.object_id=f2.feature_id and f2.is_obsolete = false and f2.uniquename='$id'";

        # print STDERR $fr_state;

        my $fr_nmm = $dbh->prepare($fr_state);
        $fr_nmm->execute;

        while ( my ($fr_hash) = $fr_nmm->fetchrow_hashref ) {
            my $fr_obj;
            if ( !defined( $fr_hash->{object_id} ) ) {
                last;
            }

           #print STDERR $fr_hash->{type}, " object_id ", $fr_hash->{object_id},
           #   " subject_id ", $fr_hash->{subject_id}, "\n";

            my $subject_id = 'subject_id';
            my $object_id  = 'object_id';
            my $fr_subject = $fr_hash->{object_id};
            if ( $fr_hash->{type} eq 'object_id' ) {
                $subject_id = 'object_id';
                $object_id  = 'subject_id';
                $fr_subject = $fr_hash->{object_id};
            }
            my $o_u = '';
            if ( defined( $fr_hash->{name} ) ) {

                if ( defined( $fbids{ $fr_hash->{name} } )
                    && $fbids{ $fr_hash->{name} } =~ /temp/ )
                {
                    $fr_subject = $fbids{ $fr_hash->{name} };
                    print STDERR
"Warning: check about this feature_relationship $fr_subject $unique\n";
                    $o_u = $fbids{ $fr_hash->{name} };
                }
                elsif (
                    !defined( $fbids{ $fr_hash->{name} } )
                    || ( defined( $fbids{ $fr_hash->{name} } )
                        && ( $fbids{ $fr_hash->{name} } ne $fr_subject ) )
                  )
                {
                    ( $o_u, my $o_g, my $o_s, my $o_t ) =
                      get_feat_ukeys_by_id( $dbh, $fr_subject );
                    if ( $o_u eq '0' ) {
                        print STDERR
                          "===Warning: could not get ukeys for $fr_subject\n";
                        next;
                    }

                    my $feature_ob = create_ch_feature(
                        doc        => $doc,
                        uniquename => $o_u,
                        type       => $o_t,
                        genus      => $o_g,
                        species    => $o_s,
                        macro_id   => $o_u
                    );
                    $out .= dom_toString($feature_ob);
                    $feature_ob->dispose();
                    $fbids{ $fr_hash->{name} } = $o_u;
                }
            }
            else {

                ( $o_u, my $o_g, my $o_s, my $o_t ) =
                  get_feat_ukeys_by_id( $dbh, $fr_subject );
                if ( $o_u eq '0' ) {
                    print STDERR
                      "===Warning: could not get ukeys for $fr_subject\n";
                    next;
                }
                my $feature_ob = create_ch_feature(
                    doc        => $doc,
                    uniquename => $o_u,
                    type       => $o_t,
                    genus      => $o_g,
                    species    => $o_s,
                    macro_id   => $o_u
                );
                $out .= dom_toString($feature_ob);
                $feature_ob->dispose();

            }

            $fr_obj = create_ch_fr(
                doc         => $doc,
                $object_id  => $o_u,
                $subject_id => $unique,
                rtype       => $fr_hash->{frtype},
                rank        => $fr_hash->{rank}
            );
            my $fr_id    = $fr_hash->{feature_relationship_id};
            my $fr_pub_s = "select uniquename from
			feature_relationship_pub, pub
			where feature_relationship_id=$fr_id and
			feature_relationship_pub.pub_id=pub.pub_id";
            my $frb_nmm = $dbh->prepare($fr_pub_s);
            $frb_nmm->execute;
            while ( my ($fr_pub) = $frb_nmm->fetchrow_array ) {
                my $fr_pub = create_ch_fr_pub(
                    doc        => $doc,
                    uniquename => $fr_pub
                );
                $fr_obj->appendChild($fr_pub);
            }
            my $fr_prop_s = "select feature_relationshipprop_id, 
			value, cvterm.name, cv.name from
			feature_relationshipprop frp,  cvterm ,cv where
			frp.feature_relationship_id=$fr_id and
                         cv.cv_id=cvterm.cv_id and 
			frp.type_id=cvterm.cvterm_id;";
            my $frp_nmm = $dbh->prepare($fr_prop_s);
            $frp_nmm->execute;
            while ( my ( $frp_id, $frvalue, $type, $fcv ) =
                $frp_nmm->fetchrow_array )
            {
                my $rank =
                  get_frprop_rank( $dbh, $subject_id, $object_id, $unique,
                    $o_u, $type, $frvalue );
                my $frp = create_ch_frprop(
                    doc     => $doc,
                    value   => $frvalue,
                    type_id => create_ch_cvterm(
                        doc  => $doc,
                        name => $type,
                        cv   => $fcv
                    ),
                    rank => $rank
                );
                my $fr_prop_p_s = "select pub.uniquename from
				feature_relationshipprop_pub frpp, pub where
				frpp.feature_relationshipprop_id=$frp_id and 
				frpp.pub_id=pub.pub_id";
                my $frpp_nmm = $dbh->prepare($fr_prop_p_s);
                $frpp_nmm->execute;
                while ( my ($frp_pub) = $frpp_nmm->fetchrow_array ) {
                    my $frpp = create_ch_frprop_pub(
                        doc        => $doc,
                        uniquename => $frp_pub
                    );
                    $frp->appendChild($frpp);
                }
                $frpp_nmm->finish;
                $fr_obj->appendChild($frp);
            }
            $frp_nmm->finish;
            if (   !( $unique =~ /^FBti/ && $fr_hash->{frtype} eq 'producedby' )
                && !( $unique =~ /^FBal/ && $fr_hash->{frtype} eq 'alleleof' ) )
            {
                $out .= dom_toString($fr_obj);
            }
            $fr_obj->dispose();
        }
        $fr_nmm->finish;

        #        print STDERR "done feature_relationship\n";
        ###get feature_loc, featureloc_pub
        my $fl_state = "select featureloc_id, f2.uniquename, f2.type_id,
		f2.organism_id, fmin, fmax, is_fmin_partial, is_fmax_partial, 
		strand, phase, residue_info, locgroup,rank 
		from featureloc, feature f1, feature f2 where
		f1.feature_id=featureloc.feature_id and
		f1.uniquename='$id' and f2.feature_id=featureloc.srcfeature_id";
        my $fl_nmm = $dbh->prepare($fl_state);
        $fl_nmm->execute;
        while (
            my (
                $fl_id,   $src_unique, $src_type, $src_org, $fmin,
                $fmax,    $is_fmin,    $is_fmax,  $strand,  $phase,
                $residue, $locgroup,   $rank
            )
            = $fl_nmm->fetchrow_array
          )
        {
            my $locgroup =
              get_max_locgroup( $dbh, $unique, $src_unique, $fmin, $fmax,
                $strand );
            if ( !( $unique =~ /^FBti/ ) && $locgroup > 0 ) {
                print STDERR
                  "ERROR, featureloc locgroup >1, $unique, $a1, $p\n";
            }
            my $s_type = get_type_by_id( $dbh, $src_type );
            my ( $genus, $species ) = get_organism_by_id( $dbh, $src_org );
            my $fl_obj = create_ch_featureloc(
                doc             => $doc,
                feature_id      => $unique,
                fmin            => $fmin,
                fmax            => $fmax,
                is_fmin_partial => $is_fmin,
                is_fmax_partial => $is_fmax,
                strand          => $strand,
                phase           => $phase,
                residue_info    => $residue,
                locgroup        => $locgroup,
                rank            => $rank,
                srcfeature_id   => create_ch_feature(
                    doc        => $doc,
                    uniquename => $src_unique,
                    type       => $s_type,
                    genus      => $genus,
                    species    => $species
                )
            );
            my $flp_state = "select pub.uniquename from pub, featureloc_pub
			where featureloc_id=$fl_id and
			featureloc_pub.pub_id=pub.pub_id";
            my $flp_nmm = $dbh->prepare($flp_state);
            $flp_nmm->execute;

            while ( my $pl_name = $flp_nmm->fetchrow_array ) {
                my $flp = create_ch_featureloc_pub(
                    doc        => $doc,
                    uniquename => $pl_name
                );
                $fl_obj->appendChild($flp);
            }

            $out .= dom_toString($fl_obj);
            $fl_obj->dispose();
            $fprank{$unique}{featureloc}++;
        }
        $fl_nmm->finish;

        #        print STDERR "done featureloc\n";

        ###get feature_expression,feature_expressionprop
        ##needed by feature.pm
        my $e_state =
          "select feature_expression_id,expression.uniquename,pub.uniquename 
                from feature_expression, expression, pub, feature 
                where feature.feature_id=feature_expression.feature_id 
                and feature.uniquename='$id' and feature.is_analysis='f' 
                and feature_expression.expression_id=expression.expression_id 
                and feature_expression.pub_id=pub.pub_id";

        my $f_e = $dbh->prepare($e_state);
        $f_e->execute;
        while ( my ( $fe_id, $ex_unique, $fpub ) = $f_e->fetchrow_array ) {
            my $f = create_ch_feature_expression(
                doc           => $doc,
                expression_id => create_ch_expression(
                    doc        => $doc,
                    uniquename => $ex_unique,
                ),
                pub        => $fpub,
                feature_id => $unique,
            );
            ###feature_expressionprop type's default cv is
            print STDERR "got feature_expression\n";
            ### feature_expression property type
            my $sub = "select value, cvterm.name,cv.name, cvterm.is_obsolete 
                        from feature_expressionprop, cvterm, cv 
                        where feature_expressionprop.type_id=cvterm.cvterm_id 
                        and cv.cv_id=cvterm.cv_id 
                        and feature_expressionprop.feature_expression_id=$fe_id";
            my $s_n = $dbh->prepare($sub);
            $s_n->execute;
            while ( my ( $value, $type, $cv, $is ) = $s_n->fetchrow_array ) {
                my $rank = get_feature_expressionprop_rank( $dbh, $unique, $cv,
                    $ex_unique, $type, $value, $fpub );
                my $fe = create_ch_feature_expressionprop(
                    doc     => $doc,
                    type_id => create_ch_cvterm(
                        doc         => $doc,
                        name        => $type,
                        cv          => $cv,
                        is_obsolete => $is
                    ),
                    rank => $rank
                );
                $fe->appendChild( create_doc_element( $doc, 'value', $value ) )
                  if ( defined($value) );
                $f->appendChild($fe);
            }
            $out .= dom_toString($f);
            $f->dispose();
            $s_n->finish;
        }
        print STDERR "done feature_expression feature_expressionprop\n";
        $f_e->finish;
        ###get feature_phenotype
        #currently is a empty table
        ###get feature_genotype
        print STDERR "feature_genotype genotype\n";

        my $fg = "select
		feature_genotype_id,genotype.uniquename,chr.uniquename,
		chr.organism_id, cvt.name,rank, cgroup, cvterm.name,cv.name from
		feature_genotype, feature f1, feature chr,cvterm , cvterm cvt
		,genotype,cv where
		feature_genotype.feature_id=f1.feature_id and
		feature_genotype.genotype_id=genotype.genotype_id and 
		f1.is_analysis='f' and f1.uniquename='$id' and
		cvterm.cvterm_id=feature_genotype.cvterm_id and cvterm.cv_id=cv.cv_id and
		cvt.cvterm_id=chr.type_id and
		chr.feature_id=feature_genotype.chromosome_id;";

        #	print STDERR "$fg\n";
        my $fg_nmm = $dbh->prepare($fg);
        $fg_nmm->execute;
        while (
            my (
                $fg_id, $genotype, $chr_unique, $chr_org, $chr_type,
                $rank,  $cgroup,   $fg_cvterm,  $fg_cv
            )
            = $fg_nmm->fetchrow_array
          )
        {
            print STDERR "HELLO\n";

#             if($oldname ne $a1){
#             my $old_gt=$genotype;
#             my $old=convers($oldname);
#             $old=~ s/([\'\#\"\[\]\|\\\/\(\)\+\-\.])/\\$1/g;
#             my $new=convers($a1);
#               if(!( $old_gt =~s/$old/$new/g)){
#	       print STDERR "after sub $old_gt $old $new\n";
#               print STDERR "CHECK: could not replace $old to $a1 for $genotype\n";
#             }
#             else{
#                my @gts=split(/\s+/,$old_gt);
#                   @gts=sort @gts;
#                $genotype=join(' ',@gts);
#             }
#          }
            print STDERR
"new feature $unique, old name $oldname, new name $a1, genotype $genotype, chromosome $chr_unique \n";
            my ( $chr_genus, $chr_species ) =
              get_organism_by_id( $dbh, $chr_org );
            my $fp_doc = create_ch_feature_genotype(
                doc         => $doc,
                feature_id  => $unique,
                genotype_id => create_ch_genotype(
                    doc        => $doc,
                    uniquename => $genotype,
                    macro_id   => $genotype,
                ),
                chromosome_id => create_ch_feature(
                    doc        => $doc,
                    uniquename => $chr_unique,
                    type       => $chr_type,
                    genus      => $chr_genus,
                    species    => $chr_species,
                    macro_id   => $chr_unique,
                ),
                rank      => $rank,
                cgroup    => $cgroup,
                cvterm_id => create_ch_cvterm(
                    doc  => $doc,
                    name => $fg_cvterm,
                    cv   => $fg_cv
                )
            );
            $out .= dom_toString($fp_doc);
            $fp_doc->dispose;

            #DC-379

        }
        $fg_nmm->finish;
        print STDERR "done feature_genotype\n";
        ###featureprange,featuremap,featuremap_pub,featurepos not used in DB--ignore

        #feature_interaction feature_interaction_pub feature_interactionprop
        ##needed by feature.pm
        my $i_state =
"select feature_interaction.feature_interaction_id as fi_id, interaction.uniquename as iuname, cvt.name as type, cv
.name as cv, cvt2.name as role, rank from
                interaction, feature_interaction, feature, cv, cvterm cvt, cvterm cvt2 where
                feature.feature_id=feature_interaction.feature_id and
                feature.uniquename='$id' and
                feature.is_analysis='f' and
                feature_interaction.interaction_id=interaction.interaction_id and interaction.type_id = cvt.cvterm_id and 
                cvt.cv_id = cv.cv_id and feature_interaction.role_id = cvt2.cvterm_id";

        #print STDERR "$i_state\n";
        my $f_i = $dbh->prepare($i_state);
        $f_i->execute;
        while ( my ( $fi_id, $iuname, $type, $cv, $role, $rank ) =
            $f_i->fetchrow_array )
        {
            my $f = create_ch_feature_interaction(
                doc        => $doc,
                uniquename => $iuname,
                type       => $type,
                role_id =>
                  create_ch_cvterm( doc => $doc, cv => $cv, name => $role ),
                feature_id => $unique,
                rank       => $rank,
            );
            ###feature_interactionprop type's default cv is feature_interaction property type
            print STDERR "got feature_interaction\n";

            ### feature_interaction property type
            my $sub = "select value, cvterm.name,cv.name, cvterm.is_obsolete 
                        from feature_interactionprop, cvterm, cv 
                        where feature_interactionprop.type_id=cvterm.cvterm_id 
                        and cv.cv_id=cvterm.cv_id 
                        and feature_interactionprop.feature_interaction_id=$fi_id";
            my $s_n = $dbh->prepare($sub);
            $s_n->execute;
            while ( my ( $value, $type, $cv, $is ) = $s_n->fetchrow_array ) {
                my $rank =
                  get_feature_interactionprop_rank( $dbh, $unique, $cv, $iuname,
                    $type, $value );
                my $fi = create_ch_feature_interactionprop(
                    doc     => $doc,
                    type_id => create_ch_cvterm(
                        doc         => $doc,
                        name        => $type,
                        cv          => $cv,
                        is_obsolete => $is
                    ),
                    rank => $rank
                );
                $fi->appendChild( create_doc_element( $doc, 'value', $value ) )
                  if ( defined($value) );
                $f->appendChild($fi);
            }
            $out .= dom_toString($f);
            $f->dispose();
            $s_n->finish;
        }
        print STDERR
"done feature_interaction feature_interaction_pub feature_interactionprop\n";
        $f_i->finish;

        ###get library_feature, library_featureprop
        ##needed by Allele.pm, Aberr.pm/Balancer, TI.pm, Gene.pm, Feature.pm, SF.pm
        my $lf_state =
          "select library_feature.library_feature_id,library.uniquename
                from library_feature, library, feature 
                where feature.feature_id=library_feature.feature_id 
                and feature.uniquename='$id' and feature.is_analysis='f' 
                and library_feature.library_id=library.library_id";

        my $l_f = $dbh->prepare($lf_state);
        $l_f->execute;
        while ( my ( $lf_id, $l_unique ) = $l_f->fetchrow_array ) {
            my ( $l_g, $l_s, $l_type ) =
              get_lib_ukeys_by_uname( $dbh, $l_unique );
            my $lf = create_ch_library_feature(
                doc        => $doc,
                library_id => create_ch_library(
                    doc        => $doc,
                    uniquename => $l_unique,
                    genus      => $l_g,
                    species    => $l_s,
                    type       => $l_type,
                ),
                feature_id => $unique,
            );
            ###library_featureprop type's default cv is
            ### library_featureprop type
            print STDERR "got library_feature in merge_records\n";
            my $sub =
"select library_featureprop.value, cvterm.name,cv.name, cvterm.is_obsolete 
                        from library_featureprop, cvterm, cv 
                        where library_featureprop.type_id=cvterm.cvterm_id 
                        and cv.cv_id=cvterm.cv_id 
                        and library_featureprop.library_feature_id=$lf_id";
            my $l_n = $dbh->prepare($sub);
            $l_n->execute;
            while ( my ( $value, $type, $cv, $is ) = $l_n->fetchrow_array ) {
                my $rank =
                  get_library_featureprop_rank( $dbh, $unique, $cv, $l_unique,
                    $type, $value );
                my $lfp = create_ch_library_featureprop(
                    doc     => $doc,
                    type_id => create_ch_cvterm(
                        doc         => $doc,
                        name        => $type,
                        cv          => $cv,
                        is_obsolete => $is
                    ),
                    rank => $rank,

                    #                    value => $value,
                );
                $lfp->appendChild( create_doc_element( $doc, 'value', $value ) )
                  if ( defined($value) );
                $lf->appendChild($lfp);
            }
            $out .= dom_toString($lf);
            $lf->dispose();
            $l_n->finish;
        }
        $l_f->finish;
        print STDERR "done library_feature, library_featureprop\n";

        ###get strain_feature, strain_featureprop
        ##needed by Allele.pm, Aberr.pm/Balancer, TI.pm, TP.pm
        my $sfn_state =
"select strain_feature.strain_feature_id,strain.uniquename,strain.organism_id,pub.uniquename 
                from strain_feature, strain, pub, feature 
                where feature.feature_id=strain_feature.feature_id 
                and feature.uniquename='$id' and feature.is_analysis='f' 
                and strain_feature.strain_id=strain.strain_id 
                and strain_feature.pub_id=pub.pub_id";

        my $s_f = $dbh->prepare($sfn_state);
        $s_f->execute;
        while ( my ( $sf_id, $sn_unique, $sn_org, $fpub ) =
            $s_f->fetchrow_array )
        {
            my ( $genus, $species ) = get_organism_by_id( $dbh, $sn_org );
            my $s = create_ch_strain_feature(
                doc       => $doc,
                strain_id => create_ch_strain(
                    doc         => $doc,
                    uniquename  => $sn_unique,
                    organism_id => create_ch_organism(
                        doc     => $doc,
                        genus   => $genus,
                        species => $species
                    ),
                ),
                pub        => $fpub,
                feature_id => $unique,
            );
            ###strain_featureprop type's default cv is
            print STDERR "got strain_feature\n";
            ### property type
            my $sub = "select value, cvterm.name,cv.name, cvterm.is_obsolete 
                        from strain_featureprop, cvterm, cv 
                        where strain_featureprop.type_id=cvterm.cvterm_id 
                        and cv.cv_id=cvterm.cv_id 
                        and strain_featureprop.strain_feature_id=$sf_id";
            my $s_n = $dbh->prepare($sub);
            $s_n->execute;
            while ( my ( $value, $type, $cv, $is ) = $s_n->fetchrow_array ) {
                my $rank =
                  get_strain_featureprop_rank( $dbh, $unique, $cv, $sn_unique,
                    $type, $value, $fpub );
                my $sfp = create_ch_strain_featureprop(
                    doc     => $doc,
                    type_id => create_ch_cvterm(
                        doc         => $doc,
                        name        => $type,
                        cv          => $cv,
                        is_obsolete => $is
                    ),
                    rank => $rank
                );
                $sfp->appendChild( create_doc_element( $doc, 'value', $value ) )
                  if ( defined($value) );
                $s->appendChild($sfp);
            }
            $out .= dom_toString($s);
            $s->dispose();
            $s_n->finish;
        }
        $s_f->finish;
        print STDERR "done strain_feature, strain_featureprop\n";
        ###get humanhealth_feature, humanhealth_featureprop
        ##needed by Gene.pm
        my $hfn_state =
"select humanhealth_feature.humanhealth_feature_id,humanhealth.uniquename,humanhealth.organism_id,pub.uniquename 
                from humanhealth_feature, humanhealth, pub, feature 
                where feature.feature_id=humanhealth_feature.feature_id 
                and feature.uniquename='$id' and feature.is_analysis='f' 
                and humanhealth_feature.humanhealth_id=humanhealth.humanhealth_id 
                and humanhealth_feature.pub_id=pub.pub_id";

        my $h_f = $dbh->prepare($hfn_state);
        $h_f->execute;
        while ( my ( $sf_id, $sn_unique, $sn_org, $fpub ) =
            $h_f->fetchrow_array )
        {
            my ( $genus, $species ) = get_organism_by_id( $dbh, $sn_org );
            my $s = create_ch_humanhealth_feature(
                doc            => $doc,
                humanhealth_id => create_ch_humanhealth(
                    doc         => $doc,
                    uniquename  => $sn_unique,
                    organism_id => create_ch_organism(
                        doc     => $doc,
                        genus   => $genus,
                        species => $species
                    ),
                ),
                pub        => $fpub,
                feature_id => $unique,
            );
            ###humanhealth_featureprop type's default cv is
            print STDERR "got humanhealth_feature\n";
            ### property type
            my $sub = "select value, cvterm.name,cv.name, cvterm.is_obsolete 
                        from humanhealth_featureprop, cvterm, cv 
                        where humanhealth_featureprop.type_id=cvterm.cvterm_id 
                        and cv.cv_id=cvterm.cv_id 
                        and humanhealth_featureprop.humanhealth_feature_id=$sf_id";
            my $s_n = $dbh->prepare($sub);
            $s_n->execute;
            while ( my ( $value, $type, $cv, $is ) = $s_n->fetchrow_array ) {
                my $rank = get_humanhealth_featureprop_rank( $dbh, $unique, $cv,
                    $sn_unique, $type, $value, $fpub );
                my $sfp = create_ch_humanhealth_featureprop(
                    doc     => $doc,
                    type_id => create_ch_cvterm(
                        doc         => $doc,
                        name        => $type,
                        cv          => $cv,
                        is_obsolete => $is
                    ),
                    rank => $rank
                );
                $sfp->appendChild( create_doc_element( $doc, 'value', $value ) )
                  if ( defined($value) );
                $s->appendChild($sfp);
            }
            $out .= dom_toString($s);
            $s->dispose();
            $s_n->finish;
        }
        $h_f->finish;
        print STDERR "done humanhealth_feature, humanhealth_featureprop\n";

        #get feature_humanhealth_dbxref
        ##needed by Gene.pm
        my $fhd_state =
"select humanhealth.uniquename, humanhealth.organism_id,db.name, dbxref.accession, pub.uniquename
                 from feature, feature_humanhealth_dbxref, humanhealth, humanhealth_dbxref, pub, db, dbxref 
                 where feature.uniquename = '$id' and feature.feature_id = feature_humanhealth_dbxref.feature_id and
                 feature_humanhealth_dbxref.humanhealth_dbxref_id = humanhealth_dbxref.humanhealth_dbxref_id and humanhealth_dbxref.humanhealth_id = humanhealth.humanhealth_id and humanhealth_dbxref.dbxref_id = dbxref.dbxref_id and dbxref.db_id = db.db_id and humanhealth_dbxref.is_current = true and humanhealth.is_obsolete = false and feature_humanhealth_dbxref.pub_id = pub.pub_id";

        #print STDERR "$fhd_state\n";
        my $fhd_g = $dbh->prepare($fhd_state);
        $fhd_g->execute;
        while ( my ( $huname, $horgid, $dbname, $acc, $pub ) =
            $fhd_g->fetchrow_array )
        {
            my ( $genus, $species ) = get_organism_by_id( $dbh, $horgid );
            my $fh = create_ch_feature_humanhealth_dbxref(
                doc                   => $doc,
                feature_id            => $unique,
                pub                   => $pub,
                humanhealth_dbxref_id => create_ch_humanhealth_dbxref(
                    doc            => $doc,
                    humanhealth_id => create_ch_humanhealth(
                        doc         => $doc,
                        uniquename  => $huname,
                        organism_id => create_ch_organism(
                            doc     => $doc,
                            genus   => $genus,
                            species => $species
                        ),
                    ),
                    dbxref_id => create_ch_dbxref(
                        doc       => $doc,
                        db        => $dbname,
                        accession => $acc,
                    ),
                ),
            );
            $out .= dom_toString($fh);
            $fh->dispose();
        }
        print STDERR "done feature_humanhealth_dbxref\n";
        $fhd_g->finish;

        #feature_grpmember feature_grpmember_pub
        ##needed by Gene.pm
        my $fg_state =
"select feature_grpmember.feature_grpmember_id as fi_id, grp.uniquename as iuname, cvt.name as type, cv.name as cv, rank 
    from grp, grpmember, feature_grpmember, feature, cv, cvterm cvt 
    where feature.feature_id=feature_grpmember.feature_id 
    and feature.uniquename='$id' 
    and feature.is_analysis='f' 
    and feature_grpmember.grpmember_id=grpmember.grpmember_id 
    and grpmember.type_id = cvt.cvterm_id 
    and cvt.cv_id = cv.cv_id and grpmember.grp_id = grp.grp_id";
        print STDERR "IN merge_records feature_grpmember $fg_state\n";
        my $f_g = $dbh->prepare($fg_state);
        $f_g->execute;
        while ( my ( $fi_id, $iuname, $type, $cv, $rank ) =
            $f_g->fetchrow_array )
        {
            print STDERR
              "IN merge_records feature_grpmember found feature to merge $id\n";

            my $fgm = create_ch_feature_grpmember(
                doc          => $doc,
                feature_id   => $unique,
                grpmember_id => create_ch_grpmember(
                    doc => $doc,
                    type_id =>
                      create_ch_cvterm( doc => $doc, cv => $cv, name => $type ),
                    rank   => $rank,
                    grp_id => create_ch_grp(
                        doc        => $doc,
                        uniquename => $iuname,
                        type_id    => create_ch_cvterm(
                            doc  => $doc,
                            cv   => "SO",
                            name => "gene_group"
                        ),
                    ),
                ),
            );
            my $fgp = "select pub.uniquename from pub, feature_grpmember_pub
                        where feature_grpmember_pub.pub_id=pub.pub_id and
                        feature_grpmember_pub.feature_grpmember_id=$fi_id";
            my $fgpp = $dbh->prepare($fgp);
            $fgpp->execute;
            while ( my ($pub) = $fgpp->fetchrow_array ) {
                my $pp = create_ch_feature_grpmember_pub(
                    doc        => $doc,
                    uniquename => $pub
                );
                $fgm->appendChild($pp);
            }
            $out .= dom_toString($fgm);
            $fgm->dispose();
            $fgpp->finish;

            #delete the feature_grpmember with obsolete feature
            print STDERR
	      "CHECK: delete feature_grpmember with obsolete (due to merge) feature $id\n";
	    # lookup unique keys for id
            my ( $fg, $fs, $ft ) = get_feat_ukeys_by_uname( $dbh, $id );
	    if ($fg ne '0'){
	      my $dfgm = create_ch_feature_grpmember(
						     doc          => $doc,
						     feature_id   => create_ch_feature(
										       doc => $doc,
										       uniquename => $id,
										       genus => $fg,
										       species => $fs,
										       type_id =>
										       create_ch_cvterm( doc => $doc, cv => 'SO', name => $ft ),
										       ),
										       
						     grpmember_id => create_ch_grpmember(
											 doc => $doc,
											 type_id =>
											 create_ch_cvterm( doc => $doc, cv => $cv, name => $type ),
											 rank   => $rank,
											 grp_id => create_ch_grp(
														 doc        => $doc,
														 uniquename => $iuname,
														 type_id    => create_ch_cvterm(
																		doc  => $doc,
																		cv   => "SO",
																		name => "gene_group"
																	       ),
														),
											),
						    );
            $dfgm->setAttribute( 'op', 'delete' );
	      $out .= dom_toString($dfgm);
	    }
        }
        print STDERR "done feature_grpmember feature_grpmember_pub\n";
        $f_g->finish;
    }
    $doc->dispose();
    return $out;
}

sub add_interaction_description {
    my $ldoc    = $_[0];
    my $feature = $_[1];
    my $desc    = $_[2];

    my $int_desc = $ldoc->createElement('description');
    my $int_text = $ldoc->createTextNode($desc);
    $int_desc->appendChild($int_text);
    my $first = $feature->getFirstChild;
    $feature->insertBefore( $int_desc, $first );
    return $feature;
}

sub get_feature_pub {
    my $dbh    = shift;
    my $unique = shift;
    my @pubs   = ();
    my $fp = "select pub.pub_id, pub.uniquename from feature, feature_pub,pub
                where feature.feature_id=feature_pub.feature_id and
                feature.is_analysis='f' and feature.uniquename='$unique' and
                pub.pub_id=feature_pub.pub_id and feature.is_obsolete='f';";
    my $f_p = $dbh->prepare($fp);
    $f_p->execute;
    while ( my ( $fpub_id, $fpub ) = $f_p->fetchrow_array ) {
        my $fp_p =
"select value, type_id from feature_pubprop where feature_pub_id=$fpub_id";
        my $ff = $dbh->prepare($fp_p);
        $ff->execute;
        my @pp = ();
        while ( my ( $value, $type ) = $ff->fetchrow_array ) {
            push( @pp, "$value,$type" );
        }
        my $pro = '';
        if ( @pp != 0 ) {
            $pro = join( ";;", @pp );
        }
        push( @pubs, "$fpub----$pro" );
    }
    return @pubs;
}

sub get_feature {
    my %params   = @_;
    my @features = ();
    my $state    = "select * from feature where is_obsolete='f' and ";
    foreach my $key ( keys %params ) {
        if ( $key ne 'DB' ) {
            $state .= "$key like '" . $params{$key} . "' and ";
        }
    }
    $state =~ s/and $//;
    my $nmm = $params{DB}->prepare($state);
    $nmm->execute;
    while ( my $feature = $nmm->fetchrow_hashref ) {
        if ( exists( $feature->{dbxref_id} ) ) {
            $feature->{dbxref_id} = get_dbxref(
                DB        => $params{DB},
                dbxref_id => $feature->{dbxref_id}
            );
        }

# $feature->{organism_id}=get_organism(DB=>$params{DB}, organism_id=>$feature->{organism_id});
#$feature->{type_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{type_id});
        push( @features, $feature );
    }
    return @features;
}

sub get_dbxref {
    my %params = @_;
    my @dbxref = ();
    my $state  = "select * from dbxref where ";
    foreach my $key ( keys %params ) {
        if ( $key ne 'DB' ) {
            $state .= "$key like '" . $params{$key} . "' and ";
        }
    }
    $state =~ s/and $//;
    my $nmm = $params{DB}->prepare($state);
    $nmm->execute;
    while ( my $feature = $nmm->fetchrow_hashref ) {
        push( @dbxref, $feature );
    }
    return @dbxref;
}

sub get_dbxref_by_id {
    my $dbh    = shift;
    my $id     = shift;
    my $dbxref = '';
    my $state =
"select dbxref.accession, dbxref.version, db.name from dbxref, db where dbxref.dbxref_id=$id and dbxref.db_id=db.db_id";
    my $nmm = $dbh->prepare($state);
    $nmm->execute;
    while ( my ( $acc, $ver, $db ) = $nmm->fetchrow_array ) {
        return ( $acc, $ver, $db );
    }
    return 0;
}

sub get_version_from_dbxref {
    my $dbh     = shift;
    my $dbname  = shift;
    my $dbxref  = shift;
    my $version = "";
    my $state =
"select dbxref.version from dbxref, db where db.name='$dbname' and dbxref.accession = '$dbxref' and dbxref.db_id=db.db_id";
    my $nmm = $dbh->prepare($state);
    $nmm->execute;
    my $id_num = $nmm->rows;

    if ( $id_num == 1 ) {
        $version = $nmm->fetchrow_array();
        return ($version);
    }
    elsif ( $id_num == 0 ) {
        return "1";
    }
    elsif ( $id_num > 1 ) {
        print STDERR
"ERROR: multiple accessions for dbname $dbname $dbxref Need version -- see developer\n";
        return "0";
    }
}

sub get_dbxref_by_db_dbxref {
    my $dbh    = shift;
    my $dbname = shift;
    my $dbxref = shift;
    my $state =
"select dbxref.accession from dbxref, db where db.name='$dbname' and dbxref.db_id=db.db_id and dbxref.accession='$dbxref'";
    my $nmm = $dbh->prepare($state);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num == 1 ) {
        return (1);
    }
    elsif ( $id_num == 0 ) {
        return (0);
    }
    elsif ( $id_num > 1 ) {
        print STDERR
"ERROR: multiple accessions for dbname $dbname $dbxref Need version -- see developer\n";
        return (-1);
    }
}

sub get_feature_dbxref {
    my $dbh     = shift;
    my $unique  = shift;
    my @dbxrefs = ();

    my $fd_state = "select feature_dbxref.is_current, feature_dbxref.dbxref_id
         from feature_dbxref, feature where
         feature.uniquename='$unique' and
         feature.feature_id=feature_dbxref.feature_id and
         feature.is_obsolete='f'";
    my $nmm = $dbh->prepare($fd_state);
    $nmm->execute;
    while ( my ( $is_cur, $dbxrefid ) = $nmm->fetchrow_array ) {
        my ( $acc, $ver, $db ) = get_dbxref_by_id( $dbh, $dbxrefid );
        push( @dbxrefs, "$is_cur----$acc,$ver,$db" );
    }
    return @dbxrefs;
}

sub get_feature_synonym {
    my $dbh      = shift;
    my $unique   = shift;
    my @synonyms = ();

    my $statement =
"select  pub.uniquename,feature_synonym.is_current,feature_synonym.is_internal, synonym_id
                from feature,feature_synonym,pub where
                feature.uniquename='$unique' and feature.feature_id =
                feature_synonym.feature_id
                 and
                feature_synonym.pub_id=pub.pub_id";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $pub, $is_c, $is_i, $s_id ) = $nmm->fetchrow_array ) {
        my ( $s_name, $s_type, $s_sgml ) = get_synonym_by_id( $dbh, $s_id );
        push( @synonyms, "$pub----$is_c----$is_i----$s_name $s_sgml $s_type" );
    }
    return @synonyms;
}

sub get_feature_cvterm {
    my $dbh    = shift;
    my $unique = shift;
    my @cvs    = ();

    my $c_state =
      "select feature_cvterm.feature_cvterm_id, pub.uniquename, cvterm_id from
                feature_cvterm, pub, feature where
                feature.feature_id=feature_cvterm.feature_id and
                feature.uniquename='$unique' and
               
                feature_cvterm.pub_id=pub.pub_id";

    my $f_c = $dbh->prepare($c_state);
    $f_c->execute;
    while ( my ( $fcv_id, $pub, $cvterm_id ) = $f_c->fetchrow_array ) {
        my ( $fp_cv, $fp_name, $is ) =
          get_cvterm_ukeys_by_id( $dbh, $cvterm_id );

        my $cp_state =
"select value,type_id from feature_cvtermprop where feature_cvterm_id=$fcv_id";
        my $cp_nmm = $dbh->prepare($cp_state);
        $cp_nmm->execute;
        my @fprops = ();
        while ( my ( $value, $type ) = $cp_nmm->fetchrow_array ) {
            my ( $cv, $cname, $nis ) = get_cvterm_ukeys_by_id( $dbh, $type );
            push( @fprops, "$value====$cv,$cname,$nis" );
        }
        my $prop = join( ';;', @fprops );
        push( @cvs, "$pub----$fp_cv==$fp_name==$is----$prop" );
    }
    return @cvs;
}

sub get_featureprop {
    my %params = @_;

    #my $dbh =shift;
    # my $name=shift;
    my @fprops = ();
    print "ERROR -- no Database handler specified\n" and return
      unless $params{db};
    my $dbh = $params{db};

    my $statement = "select  featureprop_id, value,
	 featureprop.type_id, rank from featureprop ";

    # feature where
    #feature.feature_id=featureprop.feature_id and feature.uniquename='$name'";
    if ( $params{feature} ) {
        $statement .= ", feature ";
    }
    if ( $params{type} ) {
        $statement .= ", cvterm ";
    }
    $statement .= " where ";
    if ( $params{feature} ) {
        my $unique = $params{feature};
        $statement .= "feature.feature_id=featureprop.feature_id and
	 	  feature.uniquename='$unique' and ";
    }
    if ( $params{type} ) {
        my $type = $params{type};
        $statement .= "featureprop.type_id=cvterm.cvterm_id and
	   cvterm.name='$type' and ";
    }
    if ( $params{feature_id} ) {
        my $id = $params{feature_id};
        $statement .= " featureprop.feature_id=$id and ";
    }
    if ( $params{type_id} ) {
        my $id = $params{type_id};
        $statement .= " featureprop.type_id=$id and ";
    }
    if ( $params{featureprop_id} ) {
        my $id = $params{featureprop_id};
        $statement .= " featureprop.featureprop_id=$id and ";
    }
    if ( $params{value} ) {
        my $v = $params{value};
        $statement .= " featureprop.value='$v' and ";
    }
    if ( defined( $params{rank} ) && $params{rank} ne '' ) {
        my $r = $params{rank};
        $statement .= " featureprop.rank=$r and ";
    }
    $statement =~ s/and $//;

    # my $fp = "select featureprop_id, value, featureprop.type_id, rank from
    #            featureprop, feature where
    #            feature.feature_id=featureprop.feature_id and
    #            feature.uniquename='$unique'";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $f_id, $value, $type, $rank ) = $nmm->fetchrow_array ) {
        my ( $cv, $cvterm, $is ) = get_cvterm_ukeys_by_id( $dbh, $type );
        my @pubs = ();
        my $state =
"select pub.uniquename from featureprop_pub, pub where featureprop_id=$f_id and featureprop_pub.pub_id=pub.pub_id";
        my $fp_nmm = $dbh->prepare($state);
        $fp_nmm->execute;
        while ( my $pub = $fp_nmm->fetchrow_array ) {
            push( @pubs, $pub );
        }
        my $Pub = join( ',', @pubs );
        push( @fprops, "$value----$cv==$cvterm==$is----$rank----$Pub" );
    }

    return @fprops;
}

sub get_featureloc {
    my $dbh    = shift;
    my $unique = shift;
    my @flocs  = ();

    my $fl_state =
"select featureloc_id, srcfeature_id, fmin, fmax,is_fmin_partial, is_fmax_partial, strand,
                phase,residue_info,locgroup,rank
                from featureloc, feature f1 where
                f1.feature_id=featureloc.feature_id  and f1.is_obsolete='f' and
                f1.uniquename='$unique'";
    my $fl_nmm = $dbh->prepare($fl_state);
    $fl_nmm->execute;
    while (
        my (
            $fl_id,     $src,       $fmin,   $fmax,
            $fmin_part, $fmax_part, $strand, $phase,
            $residue,   $locgroup,  $rank
        )
        = $fl_nmm->fetchrow_array
      )
    {
        my ( $uname, $s_g, $s_s, $srctype ) =
          get_feat_ukeys_by_id( $dbh, $src );
        if ( $uname eq '0' ) {
            print STDERR "ERROR: feature may has been obsoleted $src\n";
        }
        my @pubs = ();
        my $state =
"select pub.uniquename from featureloc_pub, pub where featureloc_id=$fl_id and featureloc_pub.pub_id=pub.pub_id;";
        my $nmm = $dbh->prepare($state);
        $nmm->execute;
        while ( my $p = $nmm->fetchrow_array ) {
            push( @pubs, $p );
        }
        my $pub = join( ',', @pubs );
        push( @flocs,
"$fmin,$fmax,$strand,$fmin_part,$fmax_part,$phase,$residue,$locgroup,$rank----$uname,$s_g,$s_s,$srctype----$pub"
        );
    }
    return @flocs;
}

sub get_feature_relationship {
    my $dbh    = shift;
    my $unique = shift;
    my @frs    = ();

    my $fr_state =
        "select 'subject_id' as type, fr.feature_relationship_id, "
      . "f1.uniquename as subject_id, f2.name as name,"
      . " f2.uniquename as "
      . "object_id, cvterm.name as frtype,rank from "
      . "feature_relationship fr, "
      . "feature f1, feature f2, cvterm, pub where "
      . "cvterm.cvterm_id=fr.type_id and "
      . "fr.subject_id=f1.feature_id  and f2.is_obsolete='f' and "
      . "fr.object_id=f2.feature_id and f1.uniquename='$unique' "
      . "union "
      . "select 'object_id' as type, fr.feature_relationship_id, f1.uniquename as "
      . "subject_id, f1.name as name, f2.uniquename as "
      . "object_id, cvterm.name as frtype, rank from "
      . "feature_relationship fr,"
      . "feature f1, feature f2, cvterm where "
      . "cvterm.cvterm_id=fr.type_id and "
      . "fr.subject_id=f1.feature_id and f1.is_obsolete='f' and "
      . "fr.object_id=f2.feature_id and f2.uniquename='$unique'";

    my $fr_nmm = $dbh->prepare($fr_state);
    $fr_nmm->execute;
    while ( my $fr_hash = $fr_nmm->fetchrow_hashref ) {
        my @Pubs  = ();
        my $fr_id = $fr_hash->{feature_relationship_id};
        my $frpp_state =
"select pub.uniquename from feature_relationship_pub, pub where feature_relationship_id=$fr_id and feature_relationship_pub.pub_id=pub.pub_id";
        my $frpp_nmm = $dbh->prepare($frpp_state);
        $frpp_nmm->execute;
        while ( my $pub = $frpp_nmm->fetchrow_array ) {
            push( @Pubs, $pub );
        }
        my $frp_state =
"select value, cvterm.name, rank, pub.uniquename from feature_relationshipprop fr,
                      feature_relationshipprop_pub frp, cvterm, pub
                      where fr.feature_relationship_id=$fr_id and   fr.feature_relationshipprop_id=frp.feature_relationshipprop_id and fr.type_id=cvterm.cvterm_id and  frp.pub_id=pub.pub_id;";
        my $frp_nmm = $dbh->prepare($frp_state);
        $frp_nmm->execute;
        my @frps = ();
        while ( my ( $value, $type, $rank, $pub ) = $frp_nmm->fetchrow_array ) {
            push( @frps, "$value==$type==$rank==$pub" );
        }
        push( @frs,
                'subject_id----'
              . $fr_hash->{subject_id}
              . '----object_id----'
              . $fr_hash->{object_id} . '----'
              . $fr_hash->{frtype} . '----'
              . $fr_hash->{rank} . '----'
              . join( '==', @Pubs ) . '----'
              . join( '--', @frps ) );
    }
    return @frs;
}

sub migrate_r5_location {
    my $fmin = $_[0];
    my $fmax = $_[1];
    my $src  = $_[2];
    my $map  = $_[3];
    if ( !defined($map) ) {
        print STDERR
          "ERROR: please read mapping table first for migrate coordinates\n";
    }
    my %R5map   = %$map;
    my $newfmin = '';
    my $newfmax = '';

    # my %R5map=&read_r4_r5_map();
    my $arrayref = $R5map{$src};
    my $num      = 0;
    if ( $arrayref ne '' ) {
        $num = 0;
        foreach my $hashref (@$arrayref) {
            my %E_map = %$hashref;
            if ( $fmin > $E_map{end} || $fmax < $E_map{start} ) {
                next;
            }
            elsif ( $fmin >= $E_map{start} && $fmax <= $E_map{end} ) {
                $num++;
                $newfmin = $fmin - $E_map{start} + $E_map{newstart};
                $newfmax = $fmax - $E_map{start} + $E_map{newstart};

            }
        }
    }
    if ( $num == 1 ) {
        return ( $newfmin, $newfmax );
    }
    else {
        return ( 0, 0 );
    }

}

sub read_r3_r4_map {
    open( inf1, "/users/haiyan/lib/r3_r4_map.txt" )
      or die "could not open file\n";
    my @data = <inf1>;
    close inf1;
##### hash table
    my %r4map = ();
    foreach my $line (@data) {
        my @items  = split( /\s+/, $line );
        my %region = ();
        $region{start}    = $items[1] - 1;
        $region{end}      = $items[1] + $items[3] - 1;
        $region{length}   = $items[3];
        $region{newstart} = $items[2] - 1;
        push( @{ $r4map{ $items[0] } }, \%region );
    }
    return %r4map;
}

sub read_r4_r5_map {
    open( infile2, "/users/haiyan/lib/r4_r5_map.txt" )
      or die "could not open file\n";
    my @data = <infile2>;
    close infile2;
##### hash table
    my %r5map = ();
    foreach my $line (@data) {
        my @items  = split( /\s+/, $line );
        my %region = ();
        $region{start}    = $items[1] - 1;
        $region{end}      = $items[1] + $items[3] - 1;
        $region{length}   = $items[3];
        $region{newstart} = $items[2] - 1;
        push( @{ $r5map{ $items[0] } }, \%region );
    }
    return %r5map;
}

sub get_strain_ukeys_by_id {
    ####given name, search db for uniquename, genus, species
    my $dbh     = shift;
    my $id      = shift;
    my $genus   = '';
    my $species = '';
    my $fbid    = '';

    #print STDERR "get_strain_ukeys $id\n";
    my $statement = "select uniquename,organism.genus,
  organism.species  from strain,organism where
  strain.strain_id=$id and organism.organism_id=strain.organism_id;";

    #print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    ( $fbid, $genus, $species ) = $nmm->fetchrow_array;
    return ( $fbid, $genus, $species );
}

sub validate_strain_name {
    my $dbh  = shift;
    my $name = shift;

    print STDERR $name, "\n";
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;
    $name = convers($name);
    $name = decon($name);
    my $statement = "select uniquename from strain where name= E'$name' and
  strain.is_obsolete='f'";

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $num = $nmm->rows;
    if ( $num != 0 ) {
        print STDERR "ERROR: name '$name' has been used in the Database\n";
        return 1;
    }
    $nmm->finish;
    return 0;
}

sub get_unique_key_for_snr {

    my $dbh     = shift;
    my $subject = shift;
    my $object  = shift;
    my $unique  = shift;

    #    my $type    = shift;
    my $pub    = shift;
    my $f_type = shift;
    my @ranks  = ();
    my $statement =
"select fr.strain_relationship_id, f2.name, f2.uniquename, f2.strain_id, rank from
  strain_relationship fr,  strain f1, strain f2,cvterm cvt1, cv
  cv1 ";
    if ( defined($pub) ) {
        $statement .= ',strain_relationship_pub, pub ';
    }
    $statement .= "where
  f1.uniquename='$unique' and fr.$subject=f1.strain_id and cvt1.name='$f_type'
	  and fr.$object=f2.strain_id
	and cv1.name='relationship type' and cvt1.cv_id=cv1.cv_id and
  cvt1.cvterm_id=fr.type_id ";
    if ( defined($pub) ) {
        $statement .= "	and
  strain_relationship_pub.strain_relationship_id=fr.strain_relationship_id	and pub.pub_id=strain_relationship_pub.pub_id and pub.uniquename='$pub';";
    }

    #print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $fr_id, $f_name, $f_unique, $f_id, $rank ) = $nmm->fetchrow_array ) {
        if ( !defined($f_type)
            || ( defined($f_type) && $f_unique =~ /$f_type/ ) )
        {
            my $fr = {
                fr_id      => $fr_id,
                feature_id => $f_id,
                name       => $f_name,
                rank       => $rank
            };
            push( @ranks, $fr );
        }
    }
    $nmm->finish;
    return @ranks;

}

sub get_strain_ukeys_by_uname {
    my $dbh     = shift;
    my $uname   = shift;
    my $genus   = '';
    my $species = '';

    my $statement = "select organism.genus, organism.species
	   from strain, organism where
	  strain.uniquename='$uname' and
	  strain.organism_id=organism.organism_id";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num > 1 ) {
        print STDERR
          "Warning: duplicate unames $uname \n$statement\n exiting...\n";
        return '2';
    }
    elsif ( $id_num == 0 ) {
        print STDERR print STDERR "Warning: could not get feature for $uname\n";
        return '0';
    }
    elsif ( $id_num == 1 ) {
        ( $genus, $species ) = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return ( $genus, $species );

}

sub get_strain_ukeys_by_name {
    my $dbh     = shift;
    my $name    = shift;
    my $genus   = '';
    my $species = '';
    my $uname   = '';

    my $statement = "select strain.uniquename, organism.genus, organism.species
	   from strain, organism where
	  strain.name='$name' and
	  strain.organism_id=organism.organism_id and strain.is_obsolete = false and strain.uniquename like 'FBsn%' ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num > 1 ) {
        print STDERR
          "Warning: duplicate names $name \n$statement\n exiting...\n";
        return '2';
    }
    elsif ( $id_num == 0 ) {
        print STDERR print STDERR "Warning: could not get strain for $name\n";
        return '0';
    }
    elsif ( $id_num == 1 ) {
        ( $uname, $genus, $species ) = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return ( $uname, $genus, $species );
}

sub get_cvterm_for_strain_cvterm {
    my $dbh    = shift;
    my $unique = shift;
    my $cv     = shift;
    my $pub    = shift;
    my @result = ();
    my $statement =
      "select cvt1.name, cvt1.is_obsolete from strain_cvterm fcv, strain f,
	cvterm cvt1,  cv, pub where fcv.strain_id=f.strain_id
		and f.uniquename='$unique' and  fcv.cvterm_id=cvt1.cvterm_id and
	cvt1.cv_id=cv.cv_id and cv.name='$cv' and
	fcv.pub_id=pub.pub_id and pub.uniquename='$pub'";

    #print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $cvterm, $is_o ) = $nmm->fetchrow_array ) {
        push( @result, "$cvterm,,$is_o" );

    }
    $nmm->finish;
    return @result;
}

sub delete_strain_synonym {
    my $dbh        = shift;
    my $doc        = shift;
    my $uname      = shift;
    my $pub        = shift;
    my $stype      = shift;
    my $is_current = shift;
    my $out        = '';
    $dbh->{pg_enable_utf8} = 1;
    my $statement = "select synonym.name,synonym.synonym_sgml,cvterm.name
	from strain,synonym,strain_synonym,pub, cvterm where strain.uniquename='$uname' and strain.strain_id=strain_synonym.strain_id and  strain_synonym.synonym_id=synonym.synonym_id and strain_synonym.pub_id=pub.pub_id and pub.uniquename='$pub' and cvterm.cvterm_id=synonym.type_id and 
	cvterm.name='$stype'";

    if ( $is_current ne '' ) {
        $statement .= " and strain_synonym.is_current='$is_current'";
    }
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $name, $sgml, $type ) = $nmm->fetchrow_array ) {

        my $fs = create_ch_strain_synonym(
            doc        => $doc,
            strain_id  => $uname,
            synonym_id => create_ch_synonym(
                doc          => $doc,
                name         => $name,
                synonym_sgml => $sgml,
                type         => $type
            ),
            pub_id => $pub
        );
        $fs->setAttribute( 'op', 'delete' );
        $out .= dom_toString($fs);
        $fs->dispose();

    }
    $nmm->finish;

    #     print STDERR "delete strain_synonym\n";
    return $out;

}

sub get_snr_pub_nums {
    my $dbh   = shift;
    my $fr_id = shift;

    my $statement = "select pub_id from strain_relationship_pub where
	strain_relationship_id=$fr_id ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub write_strain_relationship {
    my $dbh     = shift;
    my $doc     = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;
    my $name    = shift;
    my $fr_type = shift;
    my $pub     = shift;
    my $f_type  = shift;
    my $id_type = shift;
    my $g       = shift;
    my $s       = shift;
    my $flag    = 0;
    my $strain;
    my $uniquename = '';
    my $type       = '';
    my $genus      = 'Drosophila';
    my $species    = 'melanogaster';
    my $out        = '';

    if ( $name =~ /^FBsn/ ) {
        if ( $name =~ /temp/ ) {
            $strain = $name;
        }
        else {
            ( $genus, $species ) = get_strain_ukeys_by_uname( $dbh, $name );
            if ( $genus eq '0' || $genus eq '2' ) {
                print STDERR "ERROR: could not find $name in DB $genus\n";
            }
            else {
                $strain = create_ch_strain(
                    doc        => $doc,
                    uniquename => $name,
                    genus      => $genus,
                    species    => $species,
                    macro_id   => $name
                );
            }
        }
    }
    else {
        if ( exists( $fbids{$name} ) ) {
            $strain = $fbids{$name};
        }
        else {
            my $sname = $name;
            ( $uniquename, $genus, $species ) =
              get_strain_ukeys_by_name( $dbh, $sname );
            if ( $uniquename eq '0' || $uniquename eq '2' ) {
                print STDERR "ERROR: could not find strain with name $name\n";

            }
            else {
                $strain = create_ch_strain(
                    doc        => $doc,
                    uniquename => $uniquename,
                    genus      => $genus,
                    species    => $species,
                    macro_id   => $uniquename
                );
                $fbids{$name} = $uniquename;
            }
        }
    }
    my $fr = create_ch_strain_relationship(
        doc      => $doc,
        $subject => $uname,
        $object  => $strain,
        rtype    => $fr_type
    );
    if ( ref($strain) ) {
        $strain->appendChild(
            create_ch_strain_pub( doc => $doc, pub_id => $pub ) );
    }
    else {
        $out = dom_toString(
            create_ch_strain_pub(
                doc       => $doc,
                strain_id => $strain,
                pub_id    => $pub
            )
        );
    }
    validate_cvterm( $dbh, $fr_type, 'relationship type' );
    my $frp = create_ch_strain_relationship_pub( doc => $doc, pub_id => $pub );
    $fr->appendChild($frp);

    #print STDERR dom_toString($fr);
    return ( $fr, $out );
}

sub update_strain_synonym {
    my $dbh    = shift;
    my $doc    = shift;
    my $fbid   = shift;
    my $symbol = shift;
    my $s_type = shift;

    $dbh->{pg_enable_utf8} = 1;
    my $out = '';
    $symbol = &convers($symbol);
    $symbol = &decon($symbol);
    my $name = $symbol;
    $symbol =~ s/\\/\\\\/g;
    $symbol =~ s/\'/\\\'/g;
    my $statement = "select pub.uniquename, synonym.synonym_sgml from
	strain_synonym, strain, synonym,cvterm, pub where
	strain.strain_id=strain_synonym.strain_id and
	strain.uniquename='$fbid' and synonym.type_id=cvterm.cvterm_id and
	cvterm.name='$s_type' and
	synonym.synonym_id=strain_synonym.synonym_id and
	synonym.name= E'$symbol' and pub.pub_id=strain_synonym.pub_id and
	strain_synonym.is_current='t'";

    #print STDERR $statement;
    my $s_el = $dbh->prepare($statement);
    $s_el->execute;
    while ( my ( $pub, $sgml ) = $s_el->fetchrow_array ) {
        my $fs = create_ch_strain_synonym(
            doc        => $doc,
            strain_id  => $fbid,
            synonym_id => create_ch_synonym(
                doc          => $doc,
                name         => $name,
                synonym_sgml => $sgml,
                type         => $s_type
            ),
            pub        => $pub,
            is_current => 'f'
        );
        $out .= dom_toString($fs);
        $fs->dispose();
    }
    $s_el->finish;
    return $out;
}

sub get_feature_for_strain_feature {
    my $dbh     = shift;
    my $strain  = shift;
    my $abbrev  = shift;
    my $fr_type = shift;
    my $pub     = shift;
    my @result  = ();
    $abbrev = $abbrev . '%';
    my $fq = $dbh->prepare(
        sprintf(
"SELECT f.uniquename FROM strain_feature snf, feature f, strain sn, strain_featureprop sfp, pub p, cvterm cvt 
where snf.feature_id=f.feature_id and sn.strain_id=snf.strain_id and sn.uniquename =? and f.uniquename like ? and f.is_obsolete = false and f.is_analysis = false 
and sfp.strain_feature_id = snf.strain_feature_id and sfp.type_id = cvt.cvterm_id and cvt.name = ? and snf.pub_id = p.pub_id and p.uniquename = ? "
        )
    );
    $fq->bind_param( 1, $strain );
    $fq->bind_param( 2, $abbrev );
    $fq->bind_param( 3, $fr_type );
    $fq->bind_param( 4, $pub );
    $fq->execute;
    while ( my ($fu) = $fq->fetchrow_array ) {
        push @result, $fu;
    }
    $fq->finish;
    return (@result);
}

sub get_unique_key_for_strainprop {
    my $dbh    = shift;
    my $unique = shift;
    my $type   = shift;
    my $pub    = shift;
    my @ranks  = ();

    #        print STDERR "CHECK: in get_unique_key_for_strainprop\n";

    my $statement =
"select strainprop.strainprop_id, rank from strainprop, strain,cvterm,strainprop_pub, pub,cv where strain.uniquename='$unique' and strainprop.strain_id=strain.strain_id and cvterm.name='$type' and cv.name='property type' and cvterm.cv_id=cv.cv_id and cvterm.cvterm_id=strainprop.type_id and strainprop_pub.strainprop_id=strainprop.strainprop_id and pub.pub_id=strainprop_pub.pub_id and pub.uniquename='$pub';";
    if ( $pub eq 'unattributed' ) {
        $statement =
"select strainprop.strainprop_id, rank from strainprop, strain,cvterm,cv where strain.uniquename='$unique' and strainprop.strain_id=strain.strain_id and cvterm.name='$type' and cv.name='property type' and cvterm.cv_id=cv.cv_id and cvterm.cvterm_id=strainprop.type_id";
    }

    # print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $fp_id, $rank ) = $nmm->fetchrow_array ) {
        my $fp = {
            fp_id => $fp_id,
            rank  => $rank
        };
        push( @ranks, $fp );
    }
    $nmm->finish;
    return @ranks;
}

sub get_strainprop_pub_nums {
    my $dbh   = shift;
    my $fr_id = shift;

    #        print STDERR "CHECK: in get_strainprop_pub_nums\n";

    my $statement = "select pub_id from strainprop_pub where
	strainprop_id=$fr_id ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub delete_strainprop {
    my $doc  = shift;
    my $rank = shift;
    my $f_id = shift;
    my $type = shift;
    my $cv   = shift;

    #        print STDERR "CHECK: in delete_strainprop\n";

    if ( !defined($cv) ) {
        $cv = 'property type';
    }

    my $fp = create_ch_strainprop(
        doc       => $doc,
        strain_id => $f_id,
        rank      => $rank,
        cvname    => $cv,
        type      => $type
    );

    $fp->setAttribute( 'op', 'delete' );

    my $out = dom_toString($fp);
    $fp->dispose();
    return $out;
}

sub delete_strainprop_pub {
    my $doc  = shift;
    my $rank = shift;
    my $f_id = shift;
    my $type = shift;
    my $pub  = shift;

    #       print STDERR "CHECK: in delete_strainprop_pub\n";
    my $fp = create_ch_strainprop(
        doc       => $doc,
        strain_id => $f_id,
        rank      => $rank,
        type      => $type
    );
    my $fpp = create_ch_strainprop_pub( doc => $doc, pub_id => $pub );
    $fpp->setAttribute( 'op', 'delete' );

    $fp->appendChild($fpp);
    my $out = dom_toString($fp);

    $frnum{$f_id}{$type}{$rank}++;
    $fp->dispose();

    #        print STDERR "CHECK: leaving delete_strainprop_pub\n";

    return $out;
}

sub write_strainprop {
    my $dbh     = shift;
    my $doc     = shift;
    my $feat_id = shift;
    my $value   = shift;
    my $type    = shift;
    my $pub     = shift;

    #    print STDERR "CHECK: in write_strainprop calling write_tableprop\n";
    my $out =
      write_tableprop( $dbh, $doc, "strain", $feat_id, $value, $type, $pub );
    return $out;
}

sub get_library_for_library_strain {
    my $dbh    = shift;
    my $unique = shift;
    my $pub    = shift;
    my $type   = shift;
    my @result = ();
    my $libq   = $dbh->prepare(
        sprintf(
"SELECT l.uniquename FROM library_strain ls, strain s, library l, pub p, library_strainprop lsp, cvterm cvt, cv where ls.strain_id=s.strain_id and l.library_id=ls.library_id and ls.pub_id = p.pub_id and ls.library_strain_id = lsp.library_strain_id and lsp.type_id = cvt.cvterm_id and cvt.cv_id and cv.name = 'library_strainprop type' and s.uniquename=? and p.uniquename = ? and cvt.name = ? "
        )
    );
    $libq->bind_param( 1, $unique );
    $libq->bind_param( 2, $pub );
    $libq->bind_param( 3, $type );
    $libq->execute;

    while ( my ($lu) = $libq->fetchrow_array ) {
        push @result, $lu;
    }
    $libq->finish;
    return (@result);
}

sub get_strain_for_library_strain {
    my $dbh    = shift;
    my $unique = shift;
    my $pub    = shift;
    my $type   = shift;

    my @result = ();
    my $libq   = $dbh->prepare(
        sprintf(
"SELECT s.uniquename FROM library_strain ls, strain s, library l, pub p, library_strainprop lsp, cvterm cvt, cv where ls.strain_id=s.strain_id and l.library_id=ls.library_id and ls.pub_id = p.pub_id and ls.library_strain_id = lsp.library_strain_id and lsp.type_id = cvt.cvterm_id and cvt.cv_id and cv.name = 'library_strainprop type' and l.uniquename=? and p.uniquename = ?  and cvt.name = ? "
        )
    );
    $libq->bind_param( 1, $unique );
    $libq->bind_param( 2, $pub );
    $libq->bind_param( 3, $type );
    $libq->execute;

    while ( my ($lu) = $libq->fetchrow_array ) {
        push @result, $lu;
    }
    $libq->finish;
    return (@result);
}

sub check_strain_synonym_is_current {
    my $dbh  = shift;
    my $fbid = shift;
    my $name = shift;
    my $type = shift;

    #    $name = convers($name);
    $name = toutf($name);
    my $statement = "select distinct synonym.synonym_sgml from
	strain_synonym, strain, synonym, cvterm where
	strain_synonym.strain_id=strain.strain_id and
	synonym.synonym_id=strain_synonym.synonym_id and
	cvterm.cvterm_id=synonym.type_id and strain.uniquename='$fbid' and
	cvterm.name='$type' and strain_synonym.is_current='t'";

    #print $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my $db_name = $nmm->fetchrow_array ) {

        if ( $db_name eq $name ) {
            return 'a';
        }
        else {
            return 'b';
        }
    }
    $nmm->finish;
    return 'b';
}

sub merge_strain_records {
    my $dbh    = shift;
    my $unique = shift;
    my $value  = shift;
    my $a1     = shift;
    my $p      = shift; # pub_id
    my $a2     = shift;
    my $out    = '';
    my $doc    = new XML::DOM::Document;

    my @items = split( /\n/, $value );

    #$a1 = decon($a1);
    ####obsolete feature
    foreach my $id (@items) {
        my $oldname = $id;
        $id =~ s/^\s+//;
        $id =~ s/\s+$//;
        print STDERR "merging $id pub $p\n";
        if ( !( $id =~ /^FB/ ) ) {
            $fbids{$id} = $unique;
            my ( $u, $g, $s ) = get_strain_ukeys_by_name( $dbh, $id );
            print STDERR "Action Items: delete $u due to merge\n";
            print STDERR "$u, $id, $g, $s, $a1, $p\n";
            if ( $u ne '0' ) {
                $id = $u;
                my $feat = create_ch_strain(
                    doc         => $doc,
                    uniquename  => $u,
                    genus       => $g,
                    species     => $s,
                    is_obsolete => 't',
                    no_lookup   => 1
                );
                $out .= dom_toString($feat);
                $feat->dispose();
            }
            else {
                print STDERR
                  "ERROR: could not get FBid for name $id for merging field\n";
            }
        }
        else {
            print STDERR "Action Items: delete $id due to merge\n";
            my ( $g, $s ) = get_strain_ukeys_by_uname( $dbh, $id );
            my $nn = get_strainname_by_uniquename( $dbh, $id );
            $fbids{$nn} = $unique;
            if ( $g ne '0' ) {
                my $feat = create_ch_strain(
                    doc         => $doc,
                    uniquename  => $id,
                    genus       => $g,
                    species     => $s,
                    no_lookup   => 1,
                    is_obsolete => 't',
                    macro_id    => $id
                );
                $out .= dom_toString($feat);
                $feat->dispose();
            }
            else {
                print STDERR
                  "ERROR: could not get FBid for  $id for merging field\n";
            }
        }
        ####_dbxref,is_current=0
        my $fdb = create_ch_strain_dbxref(
            doc       => $doc,
            strain_id => $unique,
            dbxref_id => create_ch_dbxref(
                doc       => $doc,
                db        => 'FlyBase',
                accession => $id,
                no_lookup => 1
            ),
            is_current => 'f'
        );
        $out .= dom_toString($fdb);
        $fdb->dispose();
        ###get strain_synonym
        my $statement = "select synonym.name, synonym.synonym_sgml,
		strain_synonym.is_internal, cvterm.name, pub.uniquename
		from strain,synonym,strain_synonym,pub,cvterm where
		strain.uniquename='$id' and strain.strain_id=strain_synonym.strain_id 
		and strain_synonym.synonym_id=synonym.synonym_id and
		strain_synonym.pub_id=pub.pub_id and
		cvterm.cvterm_id=synonym.type_id;";
        my $nmm = $dbh->prepare($statement);
        $nmm->execute;
        while ( my ( $name, $sgml, $is_internal, $type, $pub ) =
            $nmm->fetchrow_array )
        {
            #print STDERR "name $name, $a1\n";
            my $is_current = 'f';
            print STDERR "Warning: Checking merge symbols $a1 $sgml\n";
            if ( ( $sgml eq $a1 || $sgml eq toutf($a1) ) && $type eq 'symbol' )
            {
                print STDERR "Warning: is_current=t $sgml\n";
                $is_current = 't';
            }
            if (   defined($a2)
                && ( $sgml eq toutf($a2) )
                && ( $type eq 'fullname' ) )
            {
                print STDERR "Warning: is_current=t $sgml \n";
                $is_current = 't';
            }
            my $fs = create_ch_strain_synonym(
                doc        => $doc,
                strain_id  => $unique,
                synonym_id => create_ch_synonym(
                    doc          => $doc,
                    name         => $name,
                    synonym_sgml => $sgml,
                    type         => $type
                ),
                pub_id      => create_ch_pub( doc => $doc, uniquename => $pub ),
                is_current  => $is_current,
                is_internal => $is_internal
            );
            $out .= dom_toString($fs);
            $fs->dispose();
        }
        $nmm->finish;

        #        print STDERR "done synonym\n";
        ###get strain_dbxref
        my $d_state =
          "select db.name,accession,version,strain_dbxref.is_current from
                strain_dbxref,dbxref, db,strain where
                strain_dbxref.strain_id=strain.strain_id and
                strain_dbxref.dbxref_id=dbxref.dbxref_id and  
                db.db_id=dbxref.db_id and strain.uniquename='$id';";
        my $d_nmm = $dbh->prepare($d_state);
        $d_nmm->execute;
        while ( my ( $db, $acc, $ver, $cur ) = $d_nmm->fetchrow_array ) {
            if ( $acc eq $id ) {
                $cur = 'f';
            }
            my $dbx = create_ch_dbxref(
                doc       => $doc,
                accession => $acc,
                db        => $db
            );
            if ( $ver ne '' ) {
                $dbx->appendChild(
                    create_doc_element( $doc, 'version', $ver ) );
            }
            my $fb = create_ch_strain_dbxref(
                doc        => $doc,
                strain_id  => $unique,
                dbxref_id  => $dbx,
                is_current => $cur
            );
            $out .= dom_toString($fb);
            $fb->dispose();
        }
        $d_nmm->finish;

        #        print STDERR "done dbxref\n";

        ###get strain_cvterm,strain_cvtermprop
        my $c_state =
"select strain_cvterm_id,cvterm.name, cv.name, cvterm.is_obsolete, pub.uniquename 
		from strain_cvterm, cvterm, cv, pub,  strain 
                where
		strain.strain_id=strain_cvterm.strain_id and
		strain.uniquename='$id' and
		strain_cvterm.cvterm_id=cvterm.cvterm_id and
		cvterm.cv_id=cv.cv_id and strain_cvterm.pub_id=pub.pub_id";

        my $f_c = $dbh->prepare($c_state);
        $f_c->execute;
        while ( my ( $fc_id, $cvterm, $cv, $obsolete, $fpub ) =
            $f_c->fetchrow_array )
        {
            my $f = create_ch_strain_cvterm(
                doc       => $doc,
                cvterm_id => create_ch_cvterm(
                    doc         => $doc,
                    cv          => $cv,
                    name        => $cvterm,
                    is_obsolete => $obsolete
                ),
                pub       => $fpub,
                strain_id => $unique,
            );
            ###strain_cvtermprop type's default cv is
            #'strain_cvtermprop type'
            my $sub =
              "select value, cvterm.name,cv.name, cvterm.is_obsolete from
			strain_cvtermprop, cvterm,cv where
			strain_cvtermprop.type_id=cvterm.cvterm_id and
                        cv.cv_id=cvterm.cv_id and 
			strain_cvtermprop.strain_cvterm_id=$fc_id";
            my $s_n = $dbh->prepare($sub);
            $s_n->execute;
            while ( my ( $value, $type, $cv, $is ) = $s_n->fetchrow_array ) {
                my $rank =
                  get_strain_cvtermprop_rank( $dbh, $unique, $cv, $cvterm,
                    $type, $value, $fpub );
                my $fc = create_ch_strain_cvtermprop(
                    doc     => $doc,
                    type_id => create_ch_cvterm(
                        doc         => $doc,
                        name        => $type,
                        cv          => $cv,
                        is_obsolete => $is
                    ),
                    rank => $rank
                );
                $fc->appendChild( create_doc_element( $doc, 'value', $value ) )
                  if ( defined($value) );
                $f->appendChild($fc);
            }
            $out .= dom_toString($f);
            $f->dispose();
            $s_n->finish;
        }

        #        print STDERR "done strain_cvterm\n";

        ###get strain_phenotype,strain_phenotypeprop
        my $sp_state =
          "select strain_phenotype_id,phenotype.uniquename, pub.uniquename
		from strain_phenotype, phenotype, pub,  strain where
		strain.strain_id=strain_phenotype.strain_id and
		strain.uniquename='$id' and
		strain_phenotype.phenotype_id=phenotype.phenotype_id and strain_phenotype.pub_id=pub.pub_id";

        my $s_p = $dbh->prepare($sp_state);
        $s_p->execute;
        while ( my ( $fc_id, $phenotype, $fpub ) = $s_p->fetchrow_array ) {
            my $f = create_ch_strain_phenotype(
                doc          => $doc,
                phenotype_id => create_ch_phenotype(
                    doc        => $doc,
                    uniquename => $phenotype,
                ),
                pub       => $fpub,
                strain_id => $unique,
            );
            ###strain_phenotypeprop type's default cv is
            #'strain_phenotypeprop type'
            my $sub =
              "select value, cvterm.name,cv.name, cvterm.is_obsolete from
			strain_phenotypeprop, cvterm, cv where
			strain_phenotypeprop.type_id=cvterm.cvterm_id and
                        cv.cv_id=cvterm.cv_id and 
			strain_phenotypeprop.strain_phenotype_id=$fc_id";
            my $s_n = $dbh->prepare($sub);
            $s_n->execute;
            while ( my ( $value, $type, $cv, $is ) = $s_n->fetchrow_array ) {
                if ( !defined($value) ) {
                    $value = '';
                }

  #	      print STDERR "strain_phenotypeprop value $value type $type cv $cv \n";
                my $rank =
                  get_strain_phenotypeprop_rank( $dbh, $unique, $cv, $phenotype,
                    $type, $value, $fpub );
                my $fc = create_ch_strain_phenotypeprop(
                    doc     => $doc,
                    type_id => create_ch_cvterm(
                        doc         => $doc,
                        name        => $type,
                        cv          => $cv,
                        is_obsolete => $is
                    ),
                    rank => $rank
                );
                $fc->appendChild( create_doc_element( $doc, 'value', $value ) )
                  if ( defined($value) );
                $f->appendChild($fc);
            }
            $out .= dom_toString($f);
            $f->dispose();
            $s_n->finish;
        }
        $s_p->finish;

        #        print STDERR "done strain_phenotype\n";

        ###get strain_pub
        my $fp =
          "select strain_pub_id,pub.uniquename from strain, strain_pub,pub
		where strain.strain_id=strain_pub.strain_id and
		strain.uniquename='$id' and
		pub.pub_id=strain_pub.pub_id;";
        my $f_p = $dbh->prepare($fp);
        $f_p->execute;
        while ( my ( $fpub_id, $pub ) = $f_p->fetchrow_array ) {
            my $feat_pub = create_ch_strain_pub(
                doc        => $doc,
                strain_id  => $unique,
                uniquename => $pub
            );
            $out .= dom_toString($feat_pub);
            $feat_pub->dispose();
        }
        $f_p->finish;

        print STDERR "done pub\n";
        ###get strainprop,strainprop_pub
        $fp = "select strainprop_id,value, cvterm.name,cv.name from
		strainprop, strain,cvterm,cv where
		strain.strain_id=strainprop.strain_id and
                cv.cv_id=cvterm.cv_id and 
		 strain.uniquename='$id' and
		cvterm.cvterm_id=strainprop.type_id;";
        my $fp_nmm = $dbh->prepare($fp);
        $fp_nmm->execute;
        while ( my ( $fp_id, $value, $type, $fpcv ) = $fp_nmm->fetchrow_array )
        {
            my $rank = get_max_strainprop_rank( $dbh, $unique, $type, $value );
            my $fp_doc = create_ch_strainprop(
                doc       => $doc,
                strain_id => $unique,
                value     => $value,
                type_id   => create_ch_cvterm(
                    doc  => $doc,
                    name => $type,
                    cv   => $fpcv
                ),
                rank => $rank
            );
            my $spp = "select pub.uniquename from pub, strainprop_pub
			where strainprop_pub.pub_id=pub.pub_id and
			strainprop_pub.strainprop_id=$fp_id";
            my $sppp = $dbh->prepare($spp);
            $sppp->execute;
            while ( my ($pub) = $sppp->fetchrow_array ) {
                my $pp =
                  create_ch_strainprop_pub( doc => $doc, uniquename => $pub );
                $fp_doc->appendChild($pp);
            }
            $out .= dom_toString($fp_doc);
            $fp_doc->dispose();
        }
        $fp_nmm->finish;
        ######## get strain_feature strain_featureprop
        my $lp =
"select feature_id from strain, strain_feature where strain.strain_id=strain_feature.strain_id and strain.uniquename='$id'";
        my $lp_nmm = $dbh->prepare($lp);
        $lp_nmm->execute;
        while ( my ($f_id) = $lp_nmm->fetchrow_array ) {
            my ( $l_u, $l_g, $l_s, $l_t ) = get_feat_ukeys_by_id( $dbh, $f_id );
            if ( $l_u eq '0' ) {
                print STDERR "ERROR: feature $f_id has been obsoleted\n";
            }
            my $lib_feat = create_ch_strain_feature(
                doc        => $doc,
                strain_id  => $unique,
                feature_id => create_ch_feature(
                    doc        => $doc,
                    uniquename => $l_u,
                    genus      => $l_g,
                    species    => $l_s,
                    type       => $l_t
                )
            );
###strain_featureprop type's default cv is
            #'strain_featureprop type'
            my $sub =
              "select value, cvterm.name,cv.name, cvterm.is_obsolete from
			strain_featureprop, cvterm, cv where
			strain_featureprop.type_id=cvterm.cvterm_id and
                        cv.cv_id=cvterm.cv_id and 
			strain_featureprop.strain_feature_id=$f_id";
            my $s_n = $dbh->prepare($sub);
            $s_n->execute;
            while ( my ( $value, $type, $cv, $is ) = $s_n->fetchrow_array ) {
                if ( !defined($value) ) {
                    $value = '';
                }

    #	      print STDERR "strain_featureprop value $value type $type cv $cv \n";
                my $rank =
                  get_strain_featureprop_rank( $dbh, $unique, $cv, $l_u,
                    $type, $value, $p );
                my $fc = create_ch_strain_featureprop(
                    doc     => $doc,
                    type_id => create_ch_cvterm(
                        doc         => $doc,
                        name        => $type,
                        cv          => $cv,
                        is_obsolete => $is
                    ),
                    rank => $rank
                );
                $fc->appendChild( create_doc_element( $doc, 'value', $value ) )
                  if ( defined($value) );
                $lib_feat->appendChild($fc);
            }
            $out .= dom_toString($lib_feat);
            $lib_feat->dispose();
        }
        $lp_nmm->finish;

        ######## get library_strain
        my $sl =
"select library_id, pub.uniquename from strain, library_strain, pub where strain.strain_id=library_strain.strain_id and strain.uniquename='$id' and library_strain.pub_id=pub.pub_id";
        my $sl_nmm = $dbh->prepare($sl);
        $sl_nmm->execute;
        while ( my ( $s_id, $pub ) = $sl_nmm->fetchrow_array ) {
            my ( $s_u, $s_g, $s_s, $s_t ) = get_lib_ukeys_by_id( $dbh, $s_id );
            if ( $s_u eq '0' ) {
                print STDERR "ERROR: library $s_id has been obsoleted\n";
            }
            my $lib_strain = create_ch_library_strain(
                doc        => $doc,
                strain_id  => $unique,
                library_id => create_ch_library(
                    doc        => $doc,
                    uniquename => $s_u,
                    genus      => $s_g,
                    species    => $s_s,
                    type       => $s_t,
                ),
                pub_id => $pub,

            );
###library_strainprop type's default cv is
            #'library_strainprop type'
            my $sub =
              "select value, cvterm.name,cv.name, cvterm.is_obsolete from
			library_strainprop, cvterm, cv where
			library_strainprop.type_id=cvterm.cvterm_id and
                        cv.cv_id=cvterm.cv_id and 
			library_strainprop.library_strain_id=$s_id";
            my $s_n = $dbh->prepare($sub);
            $s_n->execute;
            while ( my ( $value, $type, $cv, $is ) = $s_n->fetchrow_array ) {
                if ( !defined($value) ) {
                    $value = '';
                }

    #	      print STDERR "library_strainprop value $value type $type cv $cv \n";
                my $rank =
                  get_library_strainprop_rank( $dbh, $unique, $cv, $id,
                    $type, $value, $pub );
                my $fc = create_ch_library_strainprop(
                    doc     => $doc,
                    type_id => create_ch_cvterm(
                        doc         => $doc,
                        name        => $type,
                        cv          => $cv,
                        is_obsolete => $is
                    ),
                    rank => $rank,
                );
                $fc->appendChild( create_doc_element( $doc, 'value', $value ) )
                  if ( defined($value) );
                $lib_strain->appendChild($fc);
            }
            $out .= dom_toString($lib_strain);
            $lib_strain->dispose();
        }
        $sl_nmm->finish;
    }
    $doc->dispose();
    print STDERR "end of merge_strain\n";

    # print STDERR "$out\n";
    return $out;

}

sub get_strainname_by_uniquename {
    my $dbh  = shift;
    my $name = shift;
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;
    my $statement = "select name from strain where uniquename='$name'  and
  library.is_obsolete='f';";

    # print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $uni = $nmm->fetchrow_array;

    return $uni;
}

sub get_strain_cvtermprop_rank {
    my $dbh    = shift;
    my $fb_id  = shift;
    my $cv     = shift;
    my $cvterm = shift;
    my $type   = shift;
    my $value  = shift;
    my $pub    = shift;
    my $rank   = 0;
    $cvterm =~ s/\\/\\\\/g;
    $cvterm =~ s/\'/\\\'/g;

    if ( defined($value) ) {
        $value =~ s/\\/\\\\/g;
        $value =~ s/\'/\\\'/g;
    }
    if (   defined($value)
        && defined( $fprank{$fb_id}{ $cvterm . $pub . $type . $value } ) )
    {
        return $fprank{$fb_id}{ $cvterm . $pub . $type . $value };
    }
    else {
        if ( defined( $fprank{$fb_id}{ $cvterm . $pub . $type } ) ) {
            $fprank{$fb_id}{ $cvterm . $pub . $type } += 1;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $cvterm . $pub . $type . $value } =
                  $fprank{$fb_id}{ $cvterm . $pub . $type };
            }
            return $fprank{$fb_id}{ $cvterm . $pub . $type };
        }
        else {
            if ( defined($value) ) {
                my $statement = "select max(strain_cvtermprop.rank) from 
			strain_cvterm,
			strain, cv, cvterm, pub, cvterm cvterm2, strain_cvtermprop
			where strain_cvterm.strain_id=strain.strain_id and
			strain.uniquename='$fb_id' and
			strain_cvtermprop.strain_cvterm_id = 
			strain_cvterm.strain_cvterm_id
			and strain_cvtermprop.type_id=cvterm2.cvterm_id and
			cvterm2.name= E'$type' 
				and
			strain_cvterm.cvterm_id=cvterm.cvterm_id and cvterm.cv_id=cv.cv_id
			and cv.name='$cv' and cvterm.name='$cvterm' and 
			strain_cvterm.pub_id=pub.pub_id and
			pub.uniquename='$pub' and strain_cvtermprop.value= E'$value'";

                #print STDERR "$statement\n";
                my $fc_el = $dbh->prepare($statement);
                $fc_el->execute;
                my $f_r = $fc_el->fetchrow_array;
                if ( defined($f_r) ) {
                    $fprank{$fb_id}{ $cvterm . $pub . $type . $value } = $f_r;
                    return $f_r;
                }
            }

            my $state = "select max(strain_cvtermprop.rank) from 
			strain_cvterm,
			strain, cv, cvterm, pub, cvterm cvterm2, strain_cvtermprop
			where strain_cvterm.strain_id=strain.strain_id and
			strain.uniquename='$fb_id' and
			strain_cvtermprop.strain_cvterm_id = 
			strain_cvterm.strain_cvterm_id
			and strain_cvtermprop.type_id=cvterm2.cvterm_id and
			cvterm2.name='$type' and
			strain_cvterm.cvterm_id=cvterm.cvterm_id and cvterm.cv_id=cv.cv_id
			and cv.name='$cv' and cvterm.name= E'$cvterm' and 
			strain_cvterm.pub_id=pub.pub_id and
			pub.uniquename='$pub'";

            my $fb_el = $dbh->prepare($state);
            $fb_el->execute;
            while ( my $p_r = $fb_el->fetchrow_array ) {
                if ( $p_r ne '' ) {
                    $rank = $p_r;
                    $rank++;
                }
            }
            $fprank{$fb_id}{ $cvterm . $pub . $type } = $rank;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $cvterm . $pub . $type . $value } = $rank;
            }
            return $rank;
        }

    }
    return $rank;
}

sub get_strain_phenotypeprop_rank {
    my $dbh       = shift;
    my $fb_id     = shift;
    my $cv        = shift;
    my $phenotype = shift;
    my $type      = shift;
    my $value     = shift;
    my $pub       = shift;
    my $rank      = 0;
    if ( defined($value) ) {
        $value =~ s/\\/\\\\/g;
        $value =~ s/\'/\\\'/g;
    }
    else {
        $value = '';
    }

#    print STDERR "get_strain_phenotypeprop_rank fb_id $fb_id cv $cv phenotype $phenotype type $type value $value pub $pub\n";
    if (   defined($value)
        && defined( $fprank{$fb_id}{ $phenotype . $pub . $type . $value } ) )
    {
        return $fprank{$fb_id}{ $phenotype . $pub . $type . $value };
    }
    else {
        if ( defined( $fprank{$fb_id}{ $phenotype . $pub . $type } ) ) {
            $fprank{$fb_id}{ $phenotype . $pub . $type } += 1;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $phenotype . $pub . $type . $value } =
                  $fprank{$fb_id}{ $phenotype . $pub . $type };
            }
            return $fprank{$fb_id}{ $phenotype . $pub . $type };
        }
        else {
            if ( defined($value) ) {
                my $statement = "select max(strain_phenotypeprop.rank) from 
			strain_phenotype,
			strain, cv, phenotype, pub, cvterm cvterm2, strain_phenotypeprop 
			where strain_phenotype.strain_id=strain.strain_id and 
			strain.uniquename='$fb_id' and 
			strain_phenotypeprop.strain_phenotype_id = 
			strain_phenotype.strain_phenotype_id 
			and strain_phenotypeprop.type_id=cvterm2.cvterm_id and
			cvterm2.name='$type'  
			and cvterm2.cv_id = cv.cv_id and cv.name = '$cv' and
			strain_phenotype.phenotype_id=phenotype.phenotype_id 
		        and 
			strain_phenotype.pub_id=pub.pub_id and
			pub.uniquename='$pub' and strain_phenotypeprop.value= E'$value'";

                #           print STDERR "$statement\n";
                my $fc_el = $dbh->prepare($statement);
                $fc_el->execute;
                my $f_r = $fc_el->fetchrow_array;
                if ( defined($f_r) ) {
                    $fprank{$fb_id}{ $phenotype . $pub . $type . $value } =
                      $f_r;
                    return $f_r;
                }
            }

            my $state = "select max(strain_phenotypeprop.rank) from 
			strain_phenotype,
			strain, cv, phenotype, pub, cvterm cvterm2, strain_phenotypeprop
			where strain_phenotype.strain_id=strain.strain_id and
			strain.uniquename='$fb_id' and
			strain_phenotypeprop.strain_phenotype_id = 
			strain_phenotype.strain_phenotype_id
			and strain_phenotypeprop.type_id=cvterm2.cvterm_id and
			cvterm2.name='$type' and
			strain_phenotype.phenotype_id=phenotype.phenotype_id and cvterm2.cv_id=cv.cv_id
			and cv.name='$cv' and phenotype.name='$phenotype' and 
			strain_phenotype.pub_id=pub.pub_id and
			pub.uniquename='$pub'";

            #            print STDERR "$state\n";

            my $fb_el = $dbh->prepare($state);
            $fb_el->execute;
            while ( my $p_r = $fb_el->fetchrow_array ) {
                if ( $p_r ne '' ) {
                    $rank = $p_r;
                    $rank++;
                }
            }
            $fprank{$fb_id}{ $phenotype . $pub . $type } = $rank;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $phenotype . $pub . $type . $value } = $rank;
            }
            return $rank;
        }

    }
    return $rank;
}

sub get_strain_featureprop_rank {
    my $dbh     = shift;
    my $fb_id   = shift;
    my $cv      = shift;
    my $feature = shift;
    my $type    = shift;
    my $value   = shift;
    my $pub     = shift;
    my $rank    = 0;
    if ( defined($value) ) {
        $value =~ s/\\/\\\\/g;
        $value =~ s/\'/\\\'/g;
    }
    else {
        $value = '';
    }

#    print STDERR "get_strain_featureprop_rank fb_id $fb_id cv $cv feature $feature type $type value $value pub $pub\n";
    if (   defined($value)
        && defined( $fprank{$fb_id}{ $feature . $pub . $type . $value } ) )
    {
        return $fprank{$fb_id}{ $feature . $pub . $type . $value };
    }
    else {
        if ( defined( $fprank{$fb_id}{ $feature . $pub . $type } ) ) {
            $fprank{$fb_id}{ $feature . $pub . $type } += 1;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $feature . $pub . $type . $value } =
                  $fprank{$fb_id}{ $feature . $pub . $type };
            }
            return $fprank{$fb_id}{ $feature . $pub . $type };
        }
        else {
            if ( defined($value) ) {
                my $statement = "select max(strain_featureprop.rank) from 
			strain_feature,
			strain, cv, feature, pub, cvterm cvterm2, strain_featureprop 
			where strain_feature.strain_id=strain.strain_id and 
			strain.uniquename='$fb_id' and 
			strain_featureprop.strain_feature_id = 
			strain_feature.strain_feature_id 
			and strain_featureprop.type_id=cvterm2.cvterm_id and
			cvterm2.name='$type'  
			and cvterm2.cv_id = cv.cv_id and cv.name = '$cv' and
			strain_feature.feature_id=feature.feature_id 
		        and 
			strain_feature.pub_id=pub.pub_id and
			pub.uniquename='$pub' and strain_featureprop.value= E'$value'";

                #           print STDERR "$statement\n";
                my $fc_el = $dbh->prepare($statement);
                $fc_el->execute;
                my $f_r = $fc_el->fetchrow_array;
                if ( defined($f_r) ) {
                    $fprank{$fb_id}{ $feature . $pub . $type . $value } = $f_r;
                    return $f_r;
                }
            }

            my $state = "select max(strain_featureprop.rank) from 
			strain_feature,
			strain, cv, feature, pub, cvterm cvterm2, strain_featureprop
			where strain_feature.strain_id=strain.strain_id and
			strain.uniquename='$fb_id' and
			strain_featureprop.strain_feature_id = 
			strain_feature.strain_feature_id
			and strain_featureprop.type_id=cvterm2.cvterm_id and
			cvterm2.name='$type' and
			strain_feature.feature_id=feature.feature_id and cvterm2.cv_id=cv.cv_id
			and cv.name='$cv' and feature.name='$feature' and 
			strain_feature.pub_id=pub.pub_id and
			pub.uniquename='$pub'";

            #            print STDERR "$state\n";

            my $fb_el = $dbh->prepare($state);
            $fb_el->execute;
            while ( my $p_r = $fb_el->fetchrow_array ) {
                if ( $p_r ne '' ) {
                    $rank = $p_r;
                    $rank++;
                }
            }
            $fprank{$fb_id}{ $feature . $pub . $type } = $rank;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $feature . $pub . $type . $value } = $rank;
            }
            return $rank;
        }

    }
    return $rank;
}

sub dissociate_with_pub_fromstrain {
    my $dbh    = shift;
    my $unique = shift;
    my $pub    = shift;
    my $out    = '';
    my $doc    = new XML::DOM::Document;
    ###get feature_synonym
    print STDERR "in method dissociate_with_pub_fromstrain\n";
    my $statement = "select synonym.name, synonym.synonym_sgml,
		cvterm.name
		from strain,synonym,strain_synonym,pub,cvterm where
		strain.uniquename='$unique' and strain.strain_id = 
		strain_synonym.strain_id 
		and strain_synonym.synonym_id=synonym.synonym_id 
                and strain_synonym.pub_id=pub.pub_id and pub.uniquename='$pub'                
                and cvterm.cvterm_id=synonym.type_id;";

    #print STDERR "$statement\n";

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $name, $sgml, $type ) = $nmm->fetchrow_array ) {
        my $fs = create_ch_strain_synonym(
            doc        => $doc,
            strain_id  => $unique,
            synonym_id => create_ch_synonym(
                doc          => $doc,
                name         => $name,
                synonym_sgml => $sgml,
                type         => $type
            ),
            pub_id => $pub
        );
        $fs->setAttribute( 'op', 'delete' );
        $out .= dom_toString($fs);
    }
    $nmm->finish;

    #print STDERR "done synonym\n";
    ###get strain_cvterm
    my $c_state = "select cvterm.name, cv.name from
		strain_cvterm, cvterm, cv, pub, strain where
		strain.strain_id=strain_cvterm.strain_id and
		strain.uniquename='$unique' and
		strain_cvterm.cvterm_id=cvterm.cvterm_id and
		cvterm.cv_id=cv.cv_id and strain_cvterm.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$c_state\n";
    my $f_c = $dbh->prepare($c_state);
    $f_c->execute;
    while ( my ( $cvterm, $cv ) = $f_c->fetchrow_array ) {
        my $f = create_ch_strain_cvterm(
            doc       => $doc,
            name      => $cvterm,
            cv        => $cv,
            pub_id    => $pub,
            strain_id => $unique
        );

        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
    }
    $f_c->finish;

    #print STDERR "done cvterm\n";
    ###get strain_pub
    my $fp = "select pub.uniquename from strain, strain_pub, pub 
		where strain.strain_id=strain_pub.strain_id and
		strain.uniquename='$unique' and
		pub.pub_id=strain_pub.pub_id and pub.uniquename='$pub';";
    my $f_p = $dbh->prepare($fp);
    $f_p->execute;
    while ( my ($fpub) = $f_p->fetchrow_array ) {
        print STDERR "got strain_pub \n";
        my $feat_pub = create_ch_strain_pub(
            doc       => $doc,
            strain_id => $unique,
            pub_id    => $pub
        );
        $feat_pub->setAttribute( 'op', 'delete' );
        $out .= dom_toString($feat_pub);
    }
    $f_p->finish;

    #print STDERR "done pub\n";
    ###get strainprop,strainprop_pub
    $fp = "select strainprop.strainprop_id, cvterm.name,rank from
		strainprop,strainprop_pub, strain,cvterm,pub where
		strain.strain_id=strainprop.strain_id and
		strainprop.strainprop_id=strainprop_pub.strainprop_id and 
		strain.uniquename='$unique' and
		cvterm.cvterm_id=strainprop.type_id and strainprop_pub.pub_id =
		pub.pub_id and pub.uniquename='$pub';";

    #print STDERR "$fp\n";
    my $fp_nmm = $dbh->prepare($fp);
    $fp_nmm->execute;
    while ( my ( $fp_id, $type, $rank ) = $fp_nmm->fetchrow_array ) {
        my $num = get_strainprop_pub_nums( $dbh, $fp_id );
        if ( $num == 1 ) {
            $out .= delete_strainprop( $doc, $rank, $unique, $type );
        }
        elsif ( $num > 1 ) {
            $out .= delete_strainprop_pub( $doc, $rank, $unique, $type, $pub );
        }
    }
    $fp_nmm->finish;
    ###get strain_relationship,fr_pub
    my $fr_state =
        "select 'subject_id' as type, fr.strain_relationship_id, "
      . "f1.uniquename as subject_id, f2.name as name, f2.strain_id,"
      . " f2.uniquename as "
      . "object_id, cvterm.name as frtype from "
      . "strain_relationship fr, strain_relationship_pub frp, "
      . "strain f1,strain f2, cvterm, pub where "
      . "frp.strain_relationship_id=fr.strain_relationship_id and "
      . "cvterm.cvterm_id=fr.type_id and frp.pub_id=pub.pub_id and "
      . "fr.subject_id=f1.strain_id and pub.uniquename='$pub' and "
      . "fr.object_id=f2.strain_id and f1.uniquename='$unique' "
      . "union "
      . "select 'object_id' as type, fr.strain_relationship_id, f2.uniquename as "
      . "subject_id, f1.name as name, f1.strain_id, f1.uniquename as "
      . "object_id, cvterm.name as frtype from "
      . "strain_relationship fr, strain_relationship_pub frp,"
      . "strain f1, strain f2, cvterm, pub where "
      . "frp.strain_relationship_id=fr.strain_relationship_id and "
      . "cvterm.cvterm_id=fr.type_id and frp.pub_id=pub.pub_id and "
      . "fr.subject_id=f1.strain_id and pub.uniquename='$pub' and "
      . "fr.object_id=f2.strain_id and f2.uniquename='$unique'";

    #print STDERR "$fr_state\n";
    my $fr_nmm = $dbh->prepare($fr_state);
    $fr_nmm->execute;
    while ( my $fr_hash = $fr_nmm->fetchrow_hashref ) {

        if ( !defined( $fr_hash->{object_id} ) ) {
            last;
        }
        my $subject_id = 'subject_id';
        my $object_id  = 'object_id';
        my $fr_subject = $fr_hash->{object_id};
        if ( $fr_hash->{type} eq 'object_id' ) {
            $subject_id = 'object_id';
            $object_id  = 'subject_id';
        }

        if ( !exists( $fr_hash->{name} ) ) {
            print STDERR "ERROR: name is not found in disassociate_fnction\n";
        }

        my $num = get_snr_pub_nums( $dbh, $fr_hash->{strain_relationship_id} );
        if ( $num == 1 ) {
            $out .=
              delete_strain_relationship( $dbh, $doc, $fr_hash, $subject_id,
                $object_id, $unique, $fr_hash->{frtype} );
        }
        elsif ( $num > 1 ) {
            $out .=
              delete_strain_relationship_pub( $dbh, $doc, $fr_hash, $subject_id,
                $object_id, $unique, $fr_hash->{frtype}, $pub );
        }
    }
    $fr_nmm->finish;

    #print STDERR "done strain_relationship\n";
    ###get strain_phenotype
    my $i_state = "select phenotype.uniquename from
		phenotype, strain_phenotype, pub, strain where
		strain.strain_id=strain_phenotype.strain_id and
		strain.uniquename='$unique' and 
		strain_phenotype.phenotype_id = phenotype.phenotype_id and
		strain_phenotype.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$i_state\n";
    my $i_e = $dbh->prepare($i_state);
    $i_e->execute;
    while ( my ($iuname) = $i_e->fetchrow_array ) {
        my $f = create_ch_strain_phenotype(
            doc => $doc,
            phenotype_id =>
              create_ch_phenotype( doc => $doc, uniquename => $iuname ),
            pub_id    => $pub,
            strain_id => $unique
        );

        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
    }
    $i_e->finish;

    #print STDERR "done strain_phenotype\n";
    ###get strain_feature
    my $f_state =
"select feature.uniquename, organism.genus, organism.species, cv.name, cvterm.name from
		feature, strain_feature, pub, strain, organism, cv, cvterm where
		strain.strain_id=strain_feature.strain_id and
		strain.uniquename='$unique' and 
		strain_feature.feature_id = feature.feature_id and feature.organism_id = organism.organism_id and 
                feature.type_id = cvterm.cvterm_id and cvterm.cv_id = cv.cv_id and 
		strain_feature.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$f_state\n";
    my $f_s = $dbh->prepare($f_state);
    $f_s->execute;
    while ( my ( $funame, $genus, $species, $cvname, $cvterm ) =
        $f_s->fetchrow_array )
    {
        my $f = create_ch_strain_feature(
            doc        => $doc,
            feature_id => create_ch_feature(
                doc        => $doc,
                uniquename => $funame,
                genus      => $genus,
                species    => $species,
                type_id    => create_ch_cvterm(
                    doc  => $doc,
                    cv   => $cvname,
                    name => $cvterm
                ),
            ),
            pub_id    => $pub,
            strain_id => $unique
        );

        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
    }
    $f_s->finish;

    #print STDERR "done strain_feature\n";

    ###get library_strain
    my $ls_state =
"select library.uniquename, organism.genus, organism.species, cv.name, cvterm.name from
		library, library_strain, pub, strain, organism, cv, cvterm where
		strain.strain_id=library_strain.strain_id and
		strain.uniquename='$unique' and 
		library_strain.library_id = library.library_id and library.organism_id = organism.organism_id and 
                library.type_id = cvterm.cvterm_id and cvterm.cv_id = cv.cv_id and 
		library_strain.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$f_state\n";
    my $l_s = $dbh->prepare($ls_state);
    $l_s->execute;
    while ( my ( $funame, $genus, $species, $cvname, $cvterm ) =
        $l_s->fetchrow_array )
    {
        my $f = create_ch_library_strain(
            doc        => $doc,
            feature_id => create_ch_library(
                doc        => $doc,
                uniquename => $funame,
                genus      => $genus,
                species    => $species,
                type_id    => create_ch_cvterm(
                    doc  => $doc,
                    cv   => $cvname,
                    name => $cvterm
                ),
            ),
            pub_id    => $pub,
            strain_id => $unique
        );

        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
    }
    $l_s->finish;

    #print STDERR "done library_strain\n";
    print STDERR "leaving method dissociate_with_pub_fromstrain\n";
    $doc->dispose();
    return $out;
}

sub get_max_strainprop_rank {
    my $dbh    = shift;
    my $unique = shift;
    my $type   = shift;
    my $value  = shift;
    my $rank;

    if ( exists( $fprank{$unique}{ $type . $value } ) ) {
        $rank = $fprank{$unique}{ $type . $value };
        return $rank;
    }
    $value =~ s/\\/\\\\/g;
    $value =~ s/\'/\\\'/g;
    $value =~ s/\|/\\\|/g;

    my $statement = "select rank from strainprop, strain, cvterm,cv
  where strain.uniquename='$unique' and
  strainprop.strain_id=strain.strain_id and cvterm.name='$type'
	  and cv.name='property type' and cv.cv_id=cvterm.cv_id and
  cvterm.cvterm_id=strainprop.type_id and strainprop.value= E'$value';";

    #print STDERR $statement,"\n";
    my $fp_p = $dbh->prepare($statement);
    $fp_p->execute;
    $rank = $fp_p->fetchrow_array;
    $fp_p->finish;
    if ( defined($rank) ) {
        $fprank{$unique}{ $type . $value } = $rank;
        return $rank;
    }
    else {
        $statement =
"select max(rank) from strainprop, strain, cvterm,cv where strain.uniquename='$unique' and strainprop.strain_id=strain.strain_id and cvterm.name='$type' and cv.name='property type' and cv.cv_id=cvterm.cv_id and cvterm.cvterm_id=strainprop.type_id;";

        my $fr_r = $dbh->prepare($statement);
        $fr_r->execute;
        $rank = $fr_r->fetchrow_array;

        if ( exists( $fprank{$unique}{$type} ) ) {

            if ( defined($rank) && $rank >= $fprank{$unique}{$type} ) {
                $fprank{$unique}{$type} = $rank + 1;
            }
            else {
                $fprank{$unique}{$type}++;
            }

        }
        else {
            if ( !defined($rank) ) {
                $fprank{$unique}{$type} = 0;
            }
            else {
                $fprank{$unique}{$type} = $rank + 1;
            }
        }
        $fprank{$unique}{ $type . $value } = $fprank{$unique}{$type};
        return $fprank{$unique}{$type};
    }
}

sub check_strain_synonym {
    my $dbh  = shift;
    my $fbid = shift;
    my $type = shift;
    my $num  = 0;

    my $statement = "select * from
	strain_synonym, strain, synonym, cvterm where
	strain_synonym.strain_id=strain.strain_id and
	synonym.synonym_id=strain_synonym.synonym_id and
	cvterm.cvterm_id=synonym.type_id and strain.uniquename='$fbid' and
	cvterm.name='$type' and strain_synonym.is_current='t'";

    #print $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

################################

sub get_hh_category {
    my $dbh    = shift;
    my $unique = shift;
    my $value  = '';

    #  print STDERR "DEBUG: In check_hh_category $unique\n";

    my $statement =
"select humanhealthprop.value from humanhealthprop, humanhealth, cvterm,cv where humanhealth.uniquename='$unique' and humanhealthprop.humanhealth_id=humanhealth.humanhealth_id and cv.name='property type' and cvterm.name = 'category' and cvterm.cv_id=cv.cv_id and cvterm.cvterm_id=humanhealthprop.type_id";

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num == 1 ) {
        $value = $nmm->fetchrow_array;
        return ($value);
    }
    elsif ( $id_num == 0 ) {
        return ('0');
    }
    elsif ( $id_num > 1 ) {
        print STDERR "ERROR: multiple values for $unique category\n";
        return ('0');
    }

}

sub get_hh_sub_datatype {
    my $dbh    = shift;
    my $unique = shift;
    my $value  = '';

    my $statement =
"select humanhealthprop.value from humanhealthprop, humanhealth, cvterm,cv where humanhealth.uniquename='$unique' and humanhealthprop.humanhealth_id=humanhealth.humanhealth_id and cv.name='property type' and cvterm.name = 'sub_datatype' and cvterm.cv_id=cv.cv_id and cvterm.cvterm_id=humanhealthprop.type_id";

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num == 1 ) {
        $value = $nmm->fetchrow_array;
        return ($value);
    }
    elsif ( $id_num == 0 ) {
        return ('0');
    }
    elsif ( $id_num > 1 ) {
        print STDERR "ERROR: multiple values for $unique sub_datatype\n";
        return ('0');
    }

}

sub get_cvterm_for_humanhealth_cvterm_withprop {
    my $dbh      = shift;
    my $unique   = shift;
    my $cv       = shift;
    my $pub      = shift;
    my $proptype = shift;
    my @result   = ();
    my $statement =
"select cvt1.name, cvt1.is_obsolete from humanhealth_cvterm fcv, humanhealth f,
	cvterm cvt1, cvterm cvt2, cv, pub, humanhealth_cvtermprop fcvp where fcv.humanhealth_id=f.humanhealth_id
		and f.uniquename='$unique' and fcv.cvterm_id=cvt1.cvterm_id and
	cvt1.cv_id=cv.cv_id and cv.name='$cv' and
	cvt2.cvterm_id=fcvp.type_id and cvt2.name='$proptype' and
	fcvp.humanhealth_cvterm_id=fcv.humanhealth_cvterm_id and
	fcv.pub_id=pub.pub_id and pub.uniquename='$pub'";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $cvterm, $is_o ) = $nmm->fetchrow_array ) {
        push( @result, "$cvterm,,$is_o" );

    }
    $nmm->finish;
    return @result;
}

sub get_cvterm_by_dbxref {
    my $dbh    = shift;
    my $dbname = shift;
    my $dbxref = shift;
    my $term   = '';

    my $state =
"select cvterm.name from dbxref, db, cvterm where db.name='$dbname' and dbxref.db_id=db.db_id and dbxref.accession='$dbxref' and cvterm.dbxref_id = dbxref.dbxref_id and cvterm.is_obsolete = 0";
    my $nmm = $dbh->prepare($state);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num == 1 ) {
        $term = $nmm->fetchrow_array;
        return ($term);
    }
    elsif ( $id_num == 0 ) {
        print STDERR "ERROR: dbname $dbname accession $dbxref not found\n";
        return ('0');
    }
    elsif ( $id_num > 1 ) {
        print STDERR
"ERROR: multiple accessions for dbname $dbname $dbxref Need version -- see developer\n";
        return ('0');
    }
}

sub get_cv_cvterm_by_dbxref {
    my $dbh    = shift;
    my $dbname = shift;
    my $dbxref = shift;
    my $cv     = '';
    my $term   = '';

    my $state =
"select cv.name, cvterm.name from dbxref, db, cvterm, cv where db.name='$dbname' and dbxref.db_id=db.db_id and dbxref.accession='$dbxref' and cvterm.dbxref_id = dbxref.dbxref_id and is_obsolete = 0 and cvterm.cv_id = cv.cv_id";
    my $nmm = $dbh->prepare($state);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num == 1 ) {
        ( $cv, $term ) = $nmm->fetchrow_array;
        return ( $cv, $term );
    }
    elsif ( $id_num == 0 ) {
        print STDERR "ERROR: dbname $dbname accession $dbxref not found\n";
        return ('0');
    }
    elsif ( $id_num > 1 ) {
        print STDERR
"ERROR: multiple accessions for dbname $dbname $dbxref Need version -- see developer\n";
        return ('0');
    }
}

sub get_feature_humanhealth_dbxref_by_pub {
    my $dbh      = shift;
    my $unique   = shift;
    my $xref     = shift;
    my $proptype = shift;
    my $pub      = shift;

    my @result = ();

    my ( $dbn, $acc ) = split( /:/, $xref, 2 );
    if ( !defined($dbn) && !defined($acc) ) {
        print STDERR "ERROR: wrong format for HH7e $xref\n";
    }

    my $statement =
"select f.uniquename, genus, species, dx.accession, dx.version from humanhealth h, humanhealth_dbxref hd, humanhealth_dbxrefprop hdp, feature_humanhealth_dbxref fhd, feature f, pub p, db, dbxref dx, cvterm cvt, organism o, cvterm cvt1, cv  where h.uniquename = '$unique' and h.humanhealth_id = hd.humanhealth_id and hd.is_current = true and hd.dbxref_id = dx.dbxref_id and dx.db_id = db.db_id and db.name = 'HGNC' and dx.accession = '$acc' and hd.humanhealth_dbxref_id = hdp.humanhealth_dbxref_id and hdp.type_id = cvt.cvterm_id and cvt.name = 'diopt_ortholog' and hd.humanhealth_dbxref_id = fhd.humanhealth_dbxref_id and fhd.feature_id = f.feature_id and f.is_obsolete = false and f.organism_id = o.organism_id and f.type_id = cvt1.cvterm_id and cvt1.name = 'gene' and  cvt1.cv_id = cv.cv_id and cv.name = 'SO' and fhd.pub_id = p.pub_id and p.uniquename = '$pub';";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $funame, $genus, $species, $acc, $ver ) =
        $nmm->fetchrow_array )
    {
        my %tt = ();
        $tt{funame}  = $funame;
        $tt{genus}   = $genus;
        $tt{species} = $species;
        $tt{acc}     = $acc;
        $tt{version} = $ver;
        push( @result, \%tt );
    }
    return @result;
}

sub get_dbxref_by_humanhealth_db {
    my $dbh      = shift;
    my $unique   = shift;
    my $db       = shift;
    my $proptype = shift;

    my @result = ();
    my $statement =
"select dbxref.accession, dbxref.version from db, dbxref, humanhealth, humanhealth_dbxref, humanhealth_dbxrefprop, cvterm, cv where humanhealth_dbxref.humanhealth_id=humanhealth.humanhealth_id and humanhealth_dbxref.dbxref_id=dbxref.dbxref_id and db.db_id=dbxref.db_id and db.name='$db' and humanhealth.uniquename='$unique' and humanhealth_dbxref.humanhealth_dbxref_id = humanhealth_dbxrefprop.humanhealth_dbxref_id and humanhealth_dbxrefprop.type_id = cvterm.cvterm_id and cvterm.name = '$proptype' and cvterm.cv_id = cv.cv_id and cv.name = 'property type';";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $acc, $ver ) = $nmm->fetchrow_array ) {
        my %tt = ();
        $tt{acc}     = $acc;
        $tt{version} = $ver;
        $tt{db}      = $db;
        push( @result, \%tt );
    }
    return @result;
}

sub get_ukey_for_humanhealth_dbxref {
    my $dbh      = shift;
    my $unique   = shift;
    my $xref     = shift;
    my $proptype = shift;

    my @result = ();
    my ( $dbn, $dbx ) = split( /:/, $xref, 2 );
    if ( !defined($dbn) && !defined($dbx) ) {
        print STDERR "ERROR: wrong format for HH7e $xref\n";
    }

    my $statement =
"select db.name, dbxref.accession, dbxref.version from db, dbxref, humanhealth, humanhealth_dbxref, humanhealth_dbxrefprop, cvterm, cv where humanhealth_dbxref.humanhealth_id=humanhealth.humanhealth_id and humanhealth_dbxref.dbxref_id=dbxref.dbxref_id and db.db_id=dbxref.db_id and db.name='$dbn' and dbxref.accession = '$dbx' and humanhealth.uniquename='$unique' and humanhealth_dbxref.humanhealth_dbxref_id = humanhealth_dbxrefprop.humanhealth_dbxref_id and humanhealth_dbxrefprop.type_id = cvterm.cvterm_id and cvterm.name = '$proptype' and cvterm.cv_id = cv.cv_id and cv.name = 'property type';";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $dbname, $acc, $ver ) = $nmm->fetchrow_array ) {
        my %tt = ();
        $tt{acc}     = $acc;
        $tt{version} = $ver;
        $tt{db}      = $dbname;
        push( @result, \%tt );
    }
    return @result;
}

sub get_unique_key_for_humanhealth_dbxrefprop {
    my $dbh    = shift;
    my $unique = shift;
    my $xref   = shift;
    my $type   = shift;
    my $pub    = shift;
    my @ranks  = ();

  #        print STDERR "CHECK: in get_unique_key_for_humanhealth_dbxrefprop\n";

    my ( $dbn, $acc ) = split( /:/, $xref, 2 );
    if ( !defined($dbn) && !defined($acc) ) {
        print STDERR "ERROR: wrong format for HH7e $xref\n";
    }

    my $statement =
"select humanhealth_dbxrefprop.humanhealth_dbxrefprop_id, rank from humanhealth_dbxrefprop, humanhealth, cvterm, humanhealth_dbxrefprop_pub, pub,cv, humanhealth_dbxref, dbxref, db where humanhealth.uniquename='$unique' and humanhealth_dbxref.humanhealth_id=humanhealth.humanhealth_id and humanhealth_dbxref.dbxref_id = dbxref.dbxref_id and humanhealth_dbxref.is_current = true and dbxref.db_id = db.db_id and db.name = 'HGNC' and dbxref.accession = '$acc' and cvterm.name='$type' and cv.name='property type' and cvterm.cv_id=cv.cv_id and cvterm.cvterm_id=humanhealth_dbxrefprop.type_id and humanhealth_dbxrefprop_pub.humanhealth_dbxrefprop_id=humanhealth_dbxrefprop.humanhealth_dbxrefprop_id and pub.pub_id=humanhealth_dbxrefprop_pub.pub_id and pub.uniquename='$pub' and humanhealth_dbxrefprop.humanhealth_dbxref_id = humanhealth_dbxref.humanhealth_dbxref_id";

    # print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $fp_id, $rank ) = $nmm->fetchrow_array ) {
        my $fp = {
            fp_id => $fp_id,
            rank  => $rank
        };
        push( @ranks, $fp );
    }
    $nmm->finish;
    return @ranks;
}

sub get_humanhealth_dbxrefprop_pub_nums {
    my $dbh   = shift;
    my $fr_id = shift;

    #        print STDERR "CHECK: in get_humanhealth_dbxrefprop_pub_nums\n";

    my $statement = "select pub_id from humanhealth_dbxrefprop_pub where
	humanhealth_dbxrefprop_id=$fr_id ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub delete_humanhealth_dbxrefprop {
    my $dbh   = shift;
    my $doc   = shift;
    my $fr_id = shift;
    my $rank  = shift;
    my $f_id  = shift;
    my $type  = shift;
    my $cv    = shift;

    #        print STDERR "CHECK: in delete_humanhealth_dbxrefprop\n";

    if ( !defined($cv) ) {
        $cv = 'property type';
    }
    my ( $dbname, $acc, $ver ) =
      get_dbxref_for_humanhealth_dbxrefprop( $dbh, $fr_id );
    my $fp = create_ch_humanhealth_dbxrefprop(
        doc                   => $doc,
        humanhealth_dbxref_id => create_ch_humanhealth_dbxref(
            doc            => $doc,
            humanhealth_id => $f_id,
            dbxref_id      => create_ch_dbxref(
                doc       => $doc,
                db        => $dbname,
                accession => $acc,
                version   => $ver,
            ),
        ),
        rank   => $rank,
        type   => $type,
        cvname => $cv,
    );
    $fp->setAttribute( 'op', 'delete' );
    my $out = dom_toString($fp);
    $fp->dispose();
    return $out;
}

sub delete_humanhealth_dbxrefprop_pub {
    my $dbh   = shift;
    my $doc   = shift;
    my $fr_id = shift;
    my $rank  = shift;
    my $f_id  = shift;
    my $type  = shift;
    my $pub   = shift;
    my $cv    = shift;

    if ( !defined($cv) ) {
        $cv = 'property type';
    }

    #       print STDERR "CHECK: in delete_humanhealth_dbxrefprop_pub\n";
    my ( $dbname, $acc, $ver ) =
      get_dbxref_for humanhealth_dbxrefprop( $dbh, $fr_id );
    my $fd = create_ch_humanhealth_dbxref(
        doc            => $doc,
        humanhealth_id => $f_id,
        dbxref_id      => create_ch_dbxref(
            doc       => $doc,
            db        => $dbname,
            accession => $acc,
            version->$ver,
        ),
    );
    my $fp = create_ch_humanhealth_dbxrefprop(
        doc    => $doc,
        rank   => $rank,
        cvname => $cv,
        type   => $type
    );

    my $fpp =
      create_ch_humanhealth_dbxrefprop_pub( doc => $doc, pub_id => $pub );
    $fpp->setAttribute( 'op', 'delete' );
    $fp->appendChild($fpp);
    $fd->appendChild($fp);

    my $out = dom_toString($fd);

    $frnum{$f_id}{$type}{$rank}++;
    $fp->dispose();

    #        print STDERR "CHECK: leaving delete_humanhealth_dbxrefprop_pub\n";

    return $out;
}

sub get_dbxref_for_humanhealth_dbxrefprop {
    my $dbh   = shift;
    my $fr_id = shift;
    my $dname = "";
    my $acc   = "";
    my $ver   = "";
    my $statement =
"select db.name, dx.accession, dx.version from db, dbxref dx, humanhealth_dbxrefprop, humanhealth_dbxref where humanhealth_dbxrefprop.humanhealth_dbxrefprop_id = $fr_id and humanhealth_dbxrefprop.humanhealth_dbxref_id = humanhealth_dbxref.humanhealth_dbxref_id and humanhealth_dbxref.dbxref_id = dx.dbxref_id and dx.db_id = db.db_id;";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    ( $dname, $acc, $ver ) = $nmm->fetchrow_array();

    return ( $dname, $acc, $ver );
}

sub get_humanhealth_ukeys_by_id {
    ####given name, search db for uniquename, genus, species
    my $dbh     = shift;
    my $id      = shift;
    my $genus   = '';
    my $species = '';
    my $fbid    = '';

    #print STDERR "get_humanhealth_ukeys $id\n";
    my $statement = "select uniquename,organism.genus,
  organism.species  from humanhealth,organism where
  humanhealth.humanhealth_id=$id and organism.organism_id=humanhealth.organism_id;";

    #print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    ( $fbid, $genus, $species ) = $nmm->fetchrow_array;
    return ( $fbid, $genus, $species );
}

sub validate_humanhealth_name {
    my $dbh  = shift;
    my $name = shift;

    print STDERR "Validate new name $name \n";
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;
    $name = convers($name);
    $name = decon($name);
    my $statement = "select uniquename from humanhealth where name= E'$name' and
  humanhealth.is_obsolete='f'";

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $num = $nmm->rows;
    if ( $num != 0 ) {
        print STDERR "ERROR: name '$name' has been used in the Database\n";
        return 1;
    }
    $nmm->finish;
    return 0;
}

sub get_unique_key_for_hhr {

    my $dbh     = shift;
    my $subject = shift;
    my $object  = shift;
    my $unique  = shift;

    #    my $type    = shift;
    my $f_type = shift;
    my $pub    = shift;
    my @ranks  = ();
    my $statement =
"select fr.humanhealth_relationship_id, f2.name, f2.uniquename, f2.humanhealth_id, rank from
  humanhealth_relationship fr,  humanhealth f1, humanhealth f2,cvterm cvt1, cv
  cv1 ";
    if ( defined($pub) ) {
        $statement .= ',humanhealth_relationship_pub, pub ';
    }
    $statement .= "where 
  f1.uniquename='$unique' and fr.$subject=f1.humanhealth_id and cvt1.name='$f_type'
	  and fr.$object=f2.humanhealth_id
	and cv1.name='relationship type' and cvt1.cv_id=cv1.cv_id and
  cvt1.cvterm_id=fr.type_id ";
    if ( defined($pub) ) {
        $statement .= "	and
  humanhealth_relationship_pub.humanhealth_relationship_id=fr.humanhealth_relationship_id 
  and pub.pub_id=humanhealth_relationship_pub.pub_id and pub.uniquename='$pub';";
    }

    print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $fr_id, $f_name, $f_unique, $f_id, $rank ) = $nmm->fetchrow_array ) {
        if ( !defined($f_type)
            || ( defined($f_type) && $f_unique =~ /$f_type/ ) )
        {
            my $fr = {
                fr_id          => $fr_id,
                humanhealth_id => $f_id,
                name           => $f_name,
                rank           => $rank
            };
            push( @ranks, $fr );
        }
    }
    $nmm->finish;
    return @ranks;

}

sub get_humanhealth_ukeys_by_uname {
    my $dbh     = shift;
    my $uname   = shift;
    my $genus   = '';
    my $species = '';

    my $statement = "select organism.genus, organism.species
	   from humanhealth, organism where
	  humanhealth.uniquename='$uname' and
	  humanhealth.organism_id=organism.organism_id";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num > 1 ) {
        print STDERR
          "Warning: duplicate unames $uname \n$statement\n exiting...\n";
        return '2';
    }
    elsif ( $id_num == 0 ) {
        print STDERR print STDERR "Warning: could not get feature for $uname\n";
        return '0';
    }
    elsif ( $id_num == 1 ) {
        ( $genus, $species ) = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return ( $genus, $species );

}

sub get_humanhealth_ukeys_by_name {
    my $dbh     = shift;
    my $name    = shift;
    my $genus   = '';
    my $species = '';
    my $uname   = '';

    my $statement =
      "select humanhealth.uniquename, organism.genus, organism.species
	   from humanhealth, organism where
	  humanhealth.name='$name' and
	  humanhealth.organism_id=organism.organism_id and humanhealth.is_obsolete = false and humanhealth.uniquename like 'FBhh%' ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num > 1 ) {
        print STDERR
          "Warning: duplicate names $name \n$statement\n exiting...\n";
        return '2';
    }
    elsif ( $id_num == 0 ) {
        print STDERR print STDERR
          "Warning: could not get humanhealth for $name\n";
        return '0';
    }
    elsif ( $id_num == 1 ) {
        ( $uname, $genus, $species ) = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return ( $uname, $genus, $species );
}

sub get_cvterm_for_humanhealth_cvterm {
    my $dbh    = shift;
    my $unique = shift;
    my $cv     = shift;
    my $pub    = shift;
    my @result = ();
    my $statement =
"select cvt1.name, cvt1.is_obsolete from humanhealth_cvterm fcv, humanhealth f,
	cvterm cvt1,  cv, pub where fcv.humanhealth_id=f.humanhealth_id
		and f.uniquename='$unique' and  fcv.cvterm_id=cvt1.cvterm_id and
	cvt1.cv_id=cv.cv_id and cv.name='$cv' and
	fcv.pub_id=pub.pub_id and pub.uniquename='$pub'";

    #print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $cvterm, $is_o ) = $nmm->fetchrow_array ) {
        push( @result, "$cvterm,,$is_o" );

    }
    $nmm->finish;
    return @result;
}

sub delete_humanhealth_synonym {
    my $dbh        = shift;
    my $doc        = shift;
    my $uname      = shift;
    my $pub        = shift;
    my $stype      = shift;
    my $is_current = shift;
    my $out        = '';
    $dbh->{pg_enable_utf8} = 1;
    my $statement = "select synonym.name,synonym.synonym_sgml,cvterm.name
	from humanhealth,synonym,humanhealth_synonym,pub, cvterm where humanhealth.uniquename='$uname' and humanhealth.humanhealth_id=humanhealth_synonym.humanhealth_id and  humanhealth_synonym.synonym_id=synonym.synonym_id and humanhealth_synonym.pub_id=pub.pub_id and pub.uniquename='$pub' and cvterm.cvterm_id=synonym.type_id and 
	cvterm.name='$stype'";

    if ( $is_current ne '' ) {
        $statement .= " and humanhealth_synonym.is_current='$is_current'";
    }
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $name, $sgml, $type ) = $nmm->fetchrow_array ) {

        my $fs = create_ch_humanhealth_synonym(
            doc            => $doc,
            humanhealth_id => $uname,
            synonym_id     => create_ch_synonym(
                doc          => $doc,
                name         => $name,
                synonym_sgml => $sgml,
                type         => $type
            ),
            pub_id => $pub
        );
        $fs->setAttribute( 'op', 'delete' );
        $out .= dom_toString($fs);
        $fs->dispose();

    }
    $nmm->finish;
    print STDERR "delete humanhealth_synonym -- finish\n";
    return $out;

}

sub get_hhr_pub_nums {
    my $dbh   = shift;
    my $fr_id = shift;

    my $statement = "select pub_id from humanhealth_relationship_pub where
	humanhealth_relationship_id=$fr_id ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub write_humanhealth_relationship {
    my $dbh     = shift;
    my $doc     = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;
    my $name    = shift;
    my $fr_type = shift;
    my $pub     = shift;
    my $f_type  = shift;
    my $id_type = shift;
    my $g       = shift;
    my $s       = shift;
    my $flag    = 0;
    my $humanhealth;
    my $uniquename = '';
    my $type       = '';
    my $genus      = 'Homo';
    my $species    = 'sapiens';
    my $out        = '';

    if ( $name =~ /^FBhh/ ) {
        if ( $name =~ /temp/ ) {
            $humanhealth = $name;
        }
        else {
            ( $genus, $species ) =
              get_humanhealth_ukeys_by_uname( $dbh, $name );
            if ( $genus eq '0' || $genus eq '2' ) {
                print STDERR "ERROR: could not find $name in DB $genus\n";
            }
            else {
                $humanhealth = create_ch_humanhealth(
                    doc        => $doc,
                    uniquename => $name,
                    genus      => $genus,
                    species    => $species,
                    macro_id   => $name
                );
            }
        }
    }
    else {
        if ( exists( $fbids{$name} ) ) {
            $humanhealth = $fbids{$name};
        }
        else {
            my $sname = $name;
            ( $uniquename, $genus, $species ) =
              get_humanhealth_ukeys_by_name( $dbh, $sname );
            if ( $uniquename eq '0' || $uniquename eq '2' ) {
                print STDERR
                  "ERROR: could not find humanhealth with name $name\n";

            }
            else {
                $humanhealth = create_ch_humanhealth(
                    doc        => $doc,
                    uniquename => $uniquename,
                    genus      => $genus,
                    species    => $species,
                    macro_id   => $uniquename
                );
                $fbids{$name} = $uniquename;
            }
        }
    }
    my $fr = create_ch_humanhealth_relationship(
        doc      => $doc,
        $subject => $uname,
        $object  => $humanhealth,
        rtype    => $fr_type
    );
    if ( ref($humanhealth) ) {
        $humanhealth->appendChild(
            create_ch_humanhealth_pub( doc => $doc, pub_id => $pub ) );
    }
    else {
        $out = dom_toString(
            create_ch_humanhealth_pub(
                doc            => $doc,
                humanhealth_id => $humanhealth,
                pub_id         => $pub
            )
        );
    }
    validate_cvterm( $dbh, $fr_type, 'relationship type' );
    my $frp =
      create_ch_humanhealth_relationship_pub( doc => $doc, pub_id => $pub );
    $fr->appendChild($frp);

    #print STDERR dom_toString($fr);
    return ( $fr, $out );
}

sub update_humanhealth_synonym {
    my $dbh    = shift;
    my $doc    = shift;
    my $fbid   = shift;
    my $symbol = shift;
    my $s_type = shift;

    $dbh->{pg_enable_utf8} = 1;
    my $out = '';
    $symbol = &convers($symbol);
    $symbol = &decon($symbol);
    my $name = $symbol;
    $symbol =~ s/\\/\\\\/g;
    $symbol =~ s/\'/\\\'/g;
    my $statement = "select pub.uniquename, synonym.synonym_sgml from
	humanhealth_synonym, humanhealth, synonym,cvterm, pub where
	humanhealth.humanhealth_id=humanhealth_synonym.humanhealth_id and
	humanhealth.uniquename='$fbid' and synonym.type_id=cvterm.cvterm_id and
	cvterm.name='$s_type' and
	synonym.synonym_id=humanhealth_synonym.synonym_id and
	synonym.name= E'$symbol' and pub.pub_id=humanhealth_synonym.pub_id and
	humanhealth_synonym.is_current='t'";

    #print STDERR $statement;
    my $s_el = $dbh->prepare($statement);
    $s_el->execute;
    while ( my ( $pub, $sgml ) = $s_el->fetchrow_array ) {
        my $fs = create_ch_humanhealth_synonym(
            doc            => $doc,
            humanhealth_id => $fbid,
            synonym_id     => create_ch_synonym(
                doc          => $doc,
                name         => $name,
                synonym_sgml => $sgml,
                type         => $s_type
            ),
            pub        => $pub,
            is_current => 'f'
        );
        $out .= dom_toString($fs);
        $fs->dispose();
    }
    $s_el->finish;
    return $out;
}

sub get_humanhealth_feature {
    my $dbh         = shift;
    my $humanhealth = shift;
    my $symbol      = shift;
    my $fr_type     = shift;
    my $pub         = shift;
    my @result      = ();
    $symbol = &convers($symbol);
    $symbol = &decon($symbol);
    my $name = $symbol;
    $symbol =~ s/\\/\\\\/g;
    $symbol =~ s/\'/\\\'/g;

    my $fq = $dbh->prepare(
        sprintf(
"SELECT f.uniquename FROM humanhealth_feature snf, feature f, humanhealth sn, humanhealth_featureprop sfp, pub p, cvterm cvt 
where snf.feature_id=f.feature_id and sn.humanhealth_id=snf.humanhealth_id and sn.uniquename =? and f.name = ? and f.is_obsolete = false and f.is_analysis = false 
and sfp.humanhealth_feature_id = snf.humanhealth_feature_id and sfp.type_id = cvt.cvterm_id and cvt.name = ? and snf.pub_id = p.pub_id and p.uniquename = ? "
        )
    );
    $fq->bind_param( 1, $humanhealth );
    $fq->bind_param( 2, $symbol );
    $fq->bind_param( 3, $fr_type );
    $fq->bind_param( 4, $pub );
    $fq->execute;
    while ( my ($fu) = $fq->fetchrow_array ) {
        push @result, $fu;
    }
    $fq->finish;
    return (@result);
}

sub get_feature_for_humanhealth_feature {
    my $dbh         = shift;
    my $humanhealth = shift;
    my $abbrev      = shift;
    my $fr_type     = shift;
    my $pub         = shift;
    my @result      = ();
    $abbrev = $abbrev . '%';
    my $fq = $dbh->prepare(
        sprintf(
"SELECT f.uniquename FROM humanhealth_feature snf, feature f, humanhealth sn, humanhealth_featureprop sfp, pub p, cvterm cvt 
where snf.feature_id=f.feature_id and sn.humanhealth_id=snf.humanhealth_id and sn.uniquename =? and f.uniquename like ? and f.is_obsolete = false and f.is_analysis = false 
and sfp.humanhealth_feature_id = snf.humanhealth_feature_id and sfp.type_id = cvt.cvterm_id and cvt.name = ? and snf.pub_id = p.pub_id and p.uniquename = ? "
        )
    );
    $fq->bind_param( 1, $humanhealth );
    $fq->bind_param( 2, $abbrev );
    $fq->bind_param( 3, $fr_type );
    $fq->bind_param( 4, $pub );
    $fq->execute;
    while ( my ($fu) = $fq->fetchrow_array ) {
        push @result, $fu;
    }
    $fq->finish;
    return (@result);
}

sub get_unique_key_for_humanhealth_featureprop {
    #########################################################
    # Setting hh_uname to Undefined in the calling routine
    # will now get ALL hh for the feature and pub specified.
    # If hh_name is define then that is added to sql query.
    # The returning list contains new hash element hh_name
    # as this can be different if hh_uname is not specified.
    #########################################################
    my $dbh    = shift;
    my $hh_uname = shift;
    my $feat_name   = shift;
    my $type   = shift;
    my $pub    = shift;
    my $cv_name = shift || 'property type';
    my @ranks  = ();

    $feat_name =~ s/\\/\\\\/g;
    $feat_name =~ s/\'/\\\'/g;
    $feat_name = convers($feat_name);
    $feat_name = decon($feat_name);

    my $statement = <<"HHFP_SQL";
        SELECT humanhealth_featureprop.humanhealth_featureprop_id, rank, feature.uniquename, humanhealth.uniquename
            FROM humanhealth_feature, humanhealth_featureprop, humanhealth, cvterm, pub, cv, feature
            WHERE humanhealth.humanhealth_id = humanhealth_feature.humanhealth_id AND
                  humanhealth_feature.feature_id = feature.feature_id AND
                  feature.name = E'$feat_name' AND
                  humanhealth_feature.pub_id = pub.pub_id AND
                  pub.uniquename = '$pub' AND
                  humanhealth_feature.humanhealth_feature_id = humanhealth_featureprop.humanhealth_feature_id AND
                  humanhealth_featureprop.type_id = cvterm.cvterm_id AND
                  cvterm.name='$type' AND
                  cv.name='$cv_name' AND
                  cvterm.cv_id=cv.cv_id
HHFP_SQL
    # We can now get all hh for an allele and pub by setting hh_name to None
    if ($hh_uname){
        $statement .= " AND humanhealth.uniquename='$hh_uname'";
    }
    # print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $fp_id, $rank, $uname, $humanhealth_name ) = $nmm->fetchrow_array ) {
        my $fp = {
            fp_id => $fp_id,
            rank  => $rank,
            uname => $uname,
            hh_name => $humanhealth_name,
        };
        push( @ranks, $fp );
    }
    $nmm->finish;
    return @ranks;
}

sub delete_humanhealth_featureprop {
    my $db     = shift;
    my $doc    = shift;
    my $unique = shift;
    my $fu     = shift;
    my $type   = shift;
    my $rank   = shift;
    my $pub    = shift;
    my $cv     = shift || 'property type';
    my $delete_humanhealth_feature = shift || undef;

    if ( !defined($cv) ) {
        $cv = 'property type';
    }
    ( my $fg, my $fs, my $ft ) = get_feat_ukeys_by_uname( $db, $fu );
    my $cname = "SO";

    my $hh_f = create_ch_humanhealth_feature(
            doc        => $doc,
            feature_id => create_ch_feature(
                doc        => $doc,
                uniquename => $fu,
                genus      => $fg,
                species    => $fs,
                cvname     => $cname,
                type       => $ft,
                macro_id   => $fu,
            ),
            humanhealth_id => create_ch_humanhealth( 
                  doc         => $doc,
                  uniquename  => $unique,
                  organism_id => create_ch_organism(
                                    doc     => $doc,
                                    genus   => 'Homo',
                                    species => 'sapiens'),
                  macro_id    => $unique,
            ),
            pub_id         => $pub,
        );

    my $fp = create_ch_humanhealth_featureprop(
        doc                    => $doc,
        humanhealth_feature_id => $hh_f,
        rank    => $rank,
        type_id => create_ch_cvterm( doc => $doc, cv => $cv, name => $type ),
    );

    $fp->setAttribute( 'op', 'delete' );

    my $out = dom_toString($fp);
 
    if (defined ($delete_humanhealth_feature)){
        $hh_f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($hh_f);
    }
    $fp->dispose();
    return $out;
}

sub get_unique_key_for_humanhealthprop {
    my $dbh    = shift;
    my $unique = shift;
    my $type   = shift;
    my $pub    = shift;
    my $cvname = shift || 'property type';
    my @ranks  = ();
    print STDERR "CHECK: in get_unique_key_for_humanhealthprop\n";
    my $statement = <<"HHFP_SQL2";
        SELECT humanhealthprop.humanhealthprop_id, rank 
            FROM humanhealthprop, humanhealth,cvterm,humanhealthprop_pub, pub,cv 
            WHERE humanhealth.uniquename='$unique' AND
                  humanhealthprop.humanhealth_id=humanhealth.humanhealth_id AND
                  cvterm.name='$type' AND
                  cv.name='$cvname' AND
                  cvterm.cv_id=cv.cv_id AND
                  cvterm.cvterm_id=humanhealthprop.type_id AND
                  humanhealthprop_pub.humanhealthprop_id=humanhealthprop.humanhealthprop_id AND
                  pub.pub_id=humanhealthprop_pub.pub_id AND
                  pub.uniquename='$pub';
HHFP_SQL2
    print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $row_num = $nmm->rows;
    print STDERR "rows returned = $row_num\n";

    while ( my ( $fp_id, $rank ) = $nmm->fetchrow_array ) {
        print STDERR "$fp_id, $rank\n";
        my $fp = {
            fp_id => $fp_id,
            rank  => $rank
        };
        push( @ranks, $fp );
    }
    $nmm->finish;
    return @ranks;
}

sub get_humanhealthprop_pub_nums {
    my $dbh   = shift;
    my $fr_id = shift;

    #        print STDERR "CHECK: in get_humanhealthprop_pub_nums\n";

    my $statement = "select pub_id from humanhealthprop_pub where
	humanhealthprop_id=$fr_id ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub delete_humanhealthprop {
    my $doc  = shift;
    my $rank = shift;
    my $f_id = shift;
    my $type = shift;
    my $cv   = shift;

    #        print STDERR "CHECK: in delete_humanhealthprop\n";

    if ( !defined($cv) ) {
        $cv = 'property type';
    }

    my $fp = create_ch_humanhealthprop(
        doc            => $doc,
        humanhealth_id => $f_id,
        rank           => $rank,
        cvname         => $cv,
        type           => $type
    );

    $fp->setAttribute( 'op', 'delete' );

    my $out = dom_toString($fp);
    $fp->dispose();
    return $out;
}

sub delete_humanhealthprop_pub {
    my $doc  = shift;
    my $rank = shift;
    my $f_id = shift;
    my $type = shift;
    my $pub  = shift;

    #       print STDERR "CHECK: in delete_humanhealthprop_pub\n";
    my $fp = create_ch_humanhealthprop(
        doc            => $doc,
        humanhealth_id => $f_id,
        rank           => $rank,
        type           => $type
    );
    my $fpp = create_ch_humanhealthprop_pub( doc => $doc, pub_id => $pub );
    $fpp->setAttribute( 'op', 'delete' );

    $fp->appendChild($fpp);
    my $out = dom_toString($fp);

    $frnum{$f_id}{$type}{$rank}++;
    $fp->dispose();

    #        print STDERR "CHECK: leaving delete_humanhealthprop_pub\n";

    return $out;
}

sub write_humanhealthprop {
    my $dbh     = shift;
    my $doc     = shift;
    my $feat_id = shift;
    my $value   = shift;
    my $type    = shift;
    my $pub     = shift;

  #    print STDERR "CHECK: in write_humanhealthprop calling write_tableprop\n";
    my $out =
      write_tableprop( $dbh, $doc, "humanhealth", $feat_id, $value, $type,
        $pub );
    return $out;
}

sub get_library_for_library_humanhealth {
    my $dbh    = shift;
    my $unique = shift;
    my $pub    = shift;
    my $type   = shift;
    my @result = ();
    my $libq   = $dbh->prepare(
        sprintf(
"SELECT l.uniquename FROM library_humanhealth ls, humanhealth s, library l, pub p, library_humanhealthprop lsp, cvterm cvt, cv where ls.humanhealth_id=s.humanhealth_id and l.library_id=ls.library_id and ls.pub_id = p.pub_id and ls.library_humanhealth_id = lsp.library_humanhealth_id and lsp.type_id = cvt.cvterm_id and cvt.cv_id and cv.name = 'library_humanhealthprop type' and s.uniquename=? and p.uniquename = ? and cvt.name = ? "
        )
    );
    $libq->bind_param( 1, $unique );
    $libq->bind_param( 2, $pub );
    $libq->bind_param( 3, $type );
    $libq->execute;

    while ( my ($lu) = $libq->fetchrow_array ) {
        push @result, $lu;
    }
    $libq->finish;
    return (@result);
}

sub get_humanhealth_for_library_humanhealth {
    my $dbh    = shift;
    my $unique = shift;
    my $pub    = shift;
    my $type   = shift;

    my @result = ();
    my $libq   = $dbh->prepare(
        sprintf(
"SELECT s.uniquename FROM library_humanhealth ls, humanhealth s, library l, pub p, library_humanhealthprop lsp, cvterm cvt, cv where ls.humanhealth_id=s.humanhealth_id and l.library_id=ls.library_id and ls.pub_id = p.pub_id and ls.library_humanhealth_id = lsp.library_humanhealth_id and lsp.type_id = cvt.cvterm_id and cvt.cv_id and cv.name = 'library_humanhealthprop type' and l.uniquename=? and p.uniquename = ?  and cvt.name = ? "
        )
    );
    $libq->bind_param( 1, $unique );
    $libq->bind_param( 2, $pub );
    $libq->bind_param( 3, $type );
    $libq->execute;

    while ( my ($lu) = $libq->fetchrow_array ) {
        push @result, $lu;
    }
    $libq->finish;
    return (@result);
}

sub check_humanhealth_synonym_is_current {
    my $dbh  = shift;
    my $fbid = shift;
    my $name = shift;
    my $type = shift;

    $name = convers($name);
    my $statement = "select distinct synonym.synonym_sgml from
	humanhealth_synonym, , synonym, cvterm where
	humanhealth_synonym.humanhealth_id=humanhealth.humanhealth_id and
	synonym.synonym_id=humanhealth_synonym.synonym_id and
	cvterm.cvterm_id=synonym.type_id and humanhealth.uniquename='$fbid' and
	cvterm.name='$type' and humanhealth_synonym.is_current='t'";

    #print $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my $db_name = $nmm->fetchrow_array ) {

        if ( $db_name eq $name ) {
            return 'a';
        }
        else {
            return 'b';
        }
    }
    $nmm->finish;
    return 'b';
}

sub merge_humanhealth_records {
    my $dbh    = shift;
    my $unique = shift;
    my $value  = shift;
    my $a1     = shift;
    my $p      = shift;
    my $a2     = shift;
    my $out    = '';
    my $doc    = new XML::DOM::Document;

    my @items = split( /\n/, $value );

    #$a1 = decon($a1);
    ####obsolete feature
    foreach my $id (@items) {
        my $oldname = $id;
        $id =~ s/^\s+//;
        $id =~ s/\s+$//;
        print STDERR "merging $id pub $p\n";
        if ( !( $id =~ /^FB/ ) ) {
            $fbids{$id} = $unique;
            my ( $u, $g, $s ) = get_humanhealth_ukeys_by_name( $dbh, $id );
            print STDERR "Action Items: delete $u due to merge\n";
            print STDERR "$u, $id, $g, $s, $a1, $p\n";
            if ( $u ne '0' ) {
                $id = $u;
                my $feat = create_ch_humanhealth(
                    doc         => $doc,
                    uniquename  => $u,
                    genus       => $g,
                    species     => $s,
                    is_obsolete => 't',
                    no_lookup   => 1
                );
                $out .= dom_toString($feat);
                $feat->dispose();
            }
            else {
                print STDERR
                  "ERROR: could not get FBid for name $id for merging field\n";
            }
        }
        else {
            print STDERR "Action Items: delete $id due to merge\n";
            my ( $g, $s ) = get_humanhealth_ukeys_by_uname( $dbh, $id );
            my $nn = get_humanhealthname_by_uniquename( $dbh, $id );
            $fbids{$nn} = $unique;
            if ( $g ne '0' ) {
                my $feat = create_ch_humanhealth(
                    doc         => $doc,
                    uniquename  => $id,
                    genus       => $g,
                    species     => $s,
                    no_lookup   => 1,
                    is_obsolete => 't',
                    macro_id    => $id
                );
                $out .= dom_toString($feat);
                $feat->dispose();
            }
            else {
                print STDERR
                  "ERROR: could not get FBid for  $id for merging field\n";
            }
        }
        ####_dbxref,is_current=0
        my $fdb = create_ch_humanhealth_dbxref(
            doc            => $doc,
            humanhealth_id => $unique,
            dbxref_id      => create_ch_dbxref(
                doc       => $doc,
                db        => 'FlyBase',
                accession => $id,
                no_lookup => 1
            ),
            is_current => 'f'
        );
        $out .= dom_toString($fdb);
        $fdb->dispose();
        ###get humanhealth_synonym
        my $statement = "select synonym.name, synonym.synonym_sgml,
		humanhealth_synonym.is_internal, cvterm.name, pub.uniquename
		from humanhealth,synonym,humanhealth_synonym,pub,cvterm where
		humanhealth.uniquename='$id' and humanhealth.humanhealth_id=humanhealth_synonym.humanhealth_id 
		and humanhealth_synonym.synonym_id=synonym.synonym_id and
		humanhealth_synonym.pub_id=pub.pub_id and
		cvterm.cvterm_id=synonym.type_id;";
        my $nmm = $dbh->prepare($statement);
        $nmm->execute;
        while ( my ( $name, $sgml, $is_internal, $type, $pub ) =
            $nmm->fetchrow_array )
        {
            #print STDERR "name $name, $a1\n";
            my $is_current = 'f';
            print STDERR "Warning: Checking merge symbols $a1 $sgml\n";
            if ( ( $sgml eq $a1 || $sgml eq toutf($a1) ) && $type eq 'symbol' )
            {
                print STDERR "Warning: is_current=t $sgml\n";
                $is_current = 't';
            }
            if (   defined($a2)
                && ( $sgml eq toutf($a2) )
                && ( $type eq 'fullname' ) )
            {
                print STDERR "Warning: is_current=t $sgml \n";
                $is_current = 't';
            }
            my $fs = create_ch_humanhealth_synonym(
                doc            => $doc,
                humanhealth_id => $unique,
                synonym_id     => create_ch_synonym(
                    doc          => $doc,
                    name         => $name,
                    synonym_sgml => $sgml,
                    type         => $type
                ),
                pub_id      => create_ch_pub( doc => $doc, uniquename => $pub ),
                is_current  => $is_current,
                is_internal => $is_internal
            );
            $out .= dom_toString($fs);
            $fs->dispose();
        }
        $nmm->finish;

        #        print STDERR "done synonym\n";
        ###get humanhealth_dbxref
        my $d_state =
          "select db.name,accession,version,humanhealth_dbxref.is_current from
                humanhealth_dbxref,dbxref, db,humanhealth where
                humanhealth_dbxref.humanhealth_id=humanhealth.humanhealth_id and
                humanhealth_dbxref.dbxref_id=dbxref.dbxref_id and  
                db.db_id=dbxref.db_id and humanhealth.uniquename='$id';";
        my $d_nmm = $dbh->prepare($d_state);
        $d_nmm->execute;
        while ( my ( $db, $acc, $ver, $cur ) = $d_nmm->fetchrow_array ) {
            if ( $acc eq $id ) {
                $cur = 'f';
            }
            my $dbx = create_ch_dbxref(
                doc       => $doc,
                accession => $acc,
                db        => $db
            );
            if ( $ver ne '' ) {
                $dbx->appendChild(
                    create_doc_element( $doc, 'version', $ver ) );
            }
            my $fb = create_ch_humanhealth_dbxref(
                doc            => $doc,
                humanhealth_id => $unique,
                dbxref_id      => $dbx,
                is_current     => $cur
            );
            $out .= dom_toString($fb);
            $fb->dispose();
        }
        $d_nmm->finish;

        #        print STDERR "done dbxref\n";

        ###get humanhealth_cvterm,humanhealth_cvtermprop
        my $c_state =
"select humanhealth_cvterm_id,cvterm.name, cv.name, cvterm.is_obsolete, pub.uniquename 
		from humanhealth_cvterm, cvterm, cv, pub,  humanhealth 
                where
		humanhealth.humanhealth_id=humanhealth_cvterm.humanhealth_id and
		humanhealth.uniquename='$id' and
		humanhealth_cvterm.cvterm_id=cvterm.cvterm_id and
		cvterm.cv_id=cv.cv_id and humanhealth_cvterm.pub_id=pub.pub_id";

        my $f_c = $dbh->prepare($c_state);
        $f_c->execute;
        while ( my ( $fc_id, $cvterm, $cv, $obsolete, $fpub, $is_not ) =
            $f_c->fetchrow_array )
        {
            my $f = create_ch_humanhealth_cvterm(
                doc       => $doc,
                cvterm_id => create_ch_cvterm(
                    doc         => $doc,
                    cv          => $cv,
                    name        => $cvterm,
                    is_obsolete => $obsolete
                ),
                pub            => $fpub,
                humanhealth_id => $unique,
            );
            ###humanhealth_cvtermprop type's default cv is
            #'humanhealth_cvtermprop type'
            my $sub =
              "select value, cvterm.name,cv.name, cvterm.is_obsolete from
			humanhealth_cvtermprop, cvterm,cv where
			humanhealth_cvtermprop.type_id=cvterm.cvterm_id and
                        cv.cv_id=cvterm.cv_id and 
			humanhealth_cvtermprop.humanhealth_cvterm_id=$fc_id";
            my $s_n = $dbh->prepare($sub);
            $s_n->execute;
            while ( my ( $value, $type, $cv, $is ) = $s_n->fetchrow_array ) {
                my $rank =
                  get_humanhealth_cvtermprop_rank( $dbh, $unique, $cv, $cvterm,
                    $type, $value, $fpub );
                my $fc = create_ch_humanhealth_cvtermprop(
                    doc     => $doc,
                    type_id => create_ch_cvterm(
                        doc         => $doc,
                        name        => $type,
                        cv          => $cv,
                        is_obsolete => $is
                    ),
                    rank => $rank
                );
                $fc->appendChild( create_doc_element( $doc, 'value', $value ) )
                  if ( defined($value) );
                $f->appendChild($fc);
            }
            $out .= dom_toString($f);
            $f->dispose();
            $s_n->finish;
        }

        #        print STDERR "done humanhealth_cvterm\n";

        ###get humanhealth_phenotype,humanhealth_phenotypeprop
        my $sp_state =
          "select humanhealth_phenotype_id,phenotype.uniquename, pub.uniquename
		from humanhealth_phenotype, phenotype, pub,  humanhealth where
		humanhealth.humanhealth_id=humanhealth_phenotype.humanhealth_id and
		humanhealth.uniquename='$id' and
		humanhealth_phenotype.phenotype_id=phenotype.phenotype_id and humanhealth_phenotype.pub_id=pub.pub_id";

        my $s_p = $dbh->prepare($sp_state);
        $s_p->execute;
        while ( my ( $fc_id, $phenotype, $fpub ) = $s_p->fetchrow_array ) {
            my $f = create_ch_humanhealth_phenotype(
                doc          => $doc,
                phenotype_id => create_ch_phenotype(
                    doc        => $doc,
                    uniquename => $phenotype,
                ),
                pub            => $fpub,
                humanhealth_id => $unique,
            );
            ###humanhealth_phenotypeprop type's default cv is
            #'humanhealth_phenotypeprop type'
            my $sub =
              "select value, cvterm.name,cv.name, cvterm.is_obsolete from
			humanhealth_phenotypeprop, cvterm, cv where
			humanhealth_phenotypeprop.type_id=cvterm.cvterm_id and
                        cv.cv_id=cvterm.cv_id and 
			humanhealth_phenotypeprop.humanhealth_phenotype_id=$fc_id";
            my $s_n = $dbh->prepare($sub);
            $s_n->execute;
            while ( my ( $value, $type, $cv, $is ) = $s_n->fetchrow_array ) {
                if ( !defined($value) ) {
                    $value = '';
                }

#	      print STDERR "humanhealth_phenotypeprop value $value type $type cv $cv \n";
                my $rank =
                  get_humanhealth_phenotypeprop_rank( $dbh, $unique, $cv,
                    $phenotype, $type, $value, $fpub );
                my $fc = create_ch_humanhealth_phenotypeprop(
                    doc     => $doc,
                    type_id => create_ch_cvterm(
                        doc         => $doc,
                        name        => $type,
                        cv          => $cv,
                        is_obsolete => $is
                    ),
                    rank => $rank
                );
                $fc->appendChild( create_doc_element( $doc, 'value', $value ) )
                  if ( defined($value) );
                $f->appendChild($fc);
            }
            $out .= dom_toString($f);
            $f->dispose();
            $s_n->finish;
        }
        $s_p->finish;

        #        print STDERR "done humanhealth_phenotype\n";

        ###get humanhealth_pub humanhealth_pubprop
        my $fp =
"select humanhealth_pub_id,pub.uniquename from humanhealth, humanhealth_pub,pub
		where humanhealth.humanhealth_id=humanhealth_pub.humanhealth_id and
		humanhealth.uniquename='$id' and
		pub.pub_id=humanhealth_pub.pub_id;";
        my $f_p = $dbh->prepare($fp);
        $f_p->execute;
        while ( my ( $fpub_id, $pub ) = $f_p->fetchrow_array ) {
            my $feat_pub = create_ch_humanhealth_pub(
                doc            => $doc,
                humanhealth_id => $unique,
                uniquename     => $pub
            );
            my $hhpp =
"select cv.name,cvt.name, hhpp.value, hhpp.rank from cv, cvterm cvt, humanhealth_pubprop hhpp
			where hhpp.humanhealth_pub_id=$fpub_id and hhpp.type_id = cvt.cvterm_id and cvt.cv_id = cv.cv_id";
            my $hhppp = $dbh->prepare($hhpp);
            $hhppp->execute;
            while ( my ( $cv, $term, $value, $rank ) = $hhppp->fetchrow_array ) {
                my $hpp = create_ch_humanhealth_pubprop(
                    doc     => $doc,
                    rank    => $rank,
                    value   => $value,
                    type_id => create_ch_cvterm(
                        doc  => $doc,
                        name => $term,
                        cv   => $cv
                    ),

                );
                $feat_pub->appendChild($hpp);
            }
            $out .= dom_toString($feat_pub);
            $feat_pub->dispose();
        }
        $f_p->finish;

        print STDERR "done humanhealth_pub humanhealth_pubprop\n";
        ###get humanhealthprop,humanhealthprop_pub
        $fp = "select humanhealthprop_id,value, cvterm.name,cv.name from
		humanhealthprop, humanhealth,cvterm,cv where
		humanhealth.humanhealth_id=humanhealthprop.humanhealth_id and
                cv.cv_id=cvterm.cv_id and 
		 humanhealth.uniquename='$id' and
		cvterm.cvterm_id=humanhealthprop.type_id;";
        my $fp_nmm = $dbh->prepare($fp);
        $fp_nmm->execute;
        while ( my ( $fp_id, $value, $type, $fpcv ) = $fp_nmm->fetchrow_array )
        {
            my $rank =
              get_max_humanhealthprop_rank( $dbh, $unique, $type, $value );
            my $fp_doc = create_ch_humanhealthprop(
                doc            => $doc,
                humanhealth_id => $unique,
                value          => $value,
                type_id        => create_ch_cvterm(
                    doc  => $doc,
                    name => $type,
                    cv   => $fpcv
                ),
                rank => $rank
            );
            my $spp = "select pub.uniquename from pub, humanhealthprop_pub
			where humanhealthprop_pub.pub_id=pub.pub_id and
			humanhealthprop_pub.humanhealthprop_id=$fp_id";
            my $sppp = $dbh->prepare($spp);
            $sppp->execute;
            while ( my ($pub) = $sppp->fetchrow_array ) {
                my $pp = create_ch_humanhealthprop_pub(
                    doc        => $doc,
                    uniquename => $pub
                );
                $fp_doc->appendChild($pp);
            }
            $out .= dom_toString($fp_doc);
            $fp_doc->dispose();
        }
        $fp_nmm->finish;
        ######## get humanhealth_feature humanhealth_featureprop
        my $lp =
"select feature_id from humanhealth, humanhealth_feature where humanhealth.humanhealth_id=humanhealth_feature.humanhealth_id and humanhealth.uniquename='$id'";
        my $lp_nmm = $dbh->prepare($lp);
        $lp_nmm->execute;
        while ( my ($f_id) = $lp_nmm->fetchrow_array ) {
            my ( $l_u, $l_g, $l_s, $l_t ) = get_feat_ukeys_by_id( $dbh, $f_id );
            if ( $l_u eq '0' ) {
                print STDERR "ERROR: feature $f_id has been obsoleted\n";
            }
            my $lib_feat = create_ch_humanhealth_feature(
                doc            => $doc,
                humanhealth_id => $unique,
                feature_id     => create_ch_feature(
                    doc        => $doc,
                    uniquename => $l_u,
                    genus      => $l_g,
                    species    => $l_s,
                    type       => $l_t
                )
            );
###humanhealth_featureprop type's default cv is
            #'humanhealth_featureprop type'
            my $sub =
              "SELECT value, cvterm.name, cv.name, cvterm.is_obsolete, pub.uniquename
                   FROM humanhealth_featureprop, cvterm, cv, humanhealth_feature, pub
			       WHERE humanhealth_feature.humanhealth_feature_id = humanhealth_featureprop.humanhealth_feature_id AND
                         humanhealth_feature.pub_id=pub.pub_id AND
			             humanhealth_featureprop.type_id=cvterm.cvterm_id AND
                         cv.cv_id=cvterm.cv_id AND
			             humanhealth_featureprop.humanhealth_feature_id=$f_id";
            my $s_n = $dbh->prepare($sub);
            $s_n->execute;
            while ( my ( $value, $type, $cv, $is, $pub_uniquename ) = $s_n->fetchrow_array ) {
                if ( !defined($value) ) {
                    $value = '';
                }

#	      print STDERR "humanhealth_featureprop value $value type $type cv $cv \n";
                my $rank =
                  get_humanhealth_featureprop_rank( $dbh, $unique, $cv, $l_u,
                    $type, $value, $pub_uniquename );
                my $fc = create_ch_humanhealth_featureprop(
                    doc     => $doc,
                    type_id => create_ch_cvterm(
                        doc         => $doc,
                        name        => $type,
                        cv          => $cv,
                        is_obsolete => $is
                    ),
                    rank => $rank
                );
                $fc->appendChild( create_doc_element( $doc, 'value', $value ) )
                  if ( defined($value) );
                $lib_feat->appendChild($fc);
            }
            $out .= dom_toString($lib_feat);
            $lib_feat->dispose();
        }
        $lp_nmm->finish;

        ######## get library_humanhealth
        my $sl =
"select library_id, pub.uniquename 
    from humanhealth, library_humanhealth, pub 
    where humanhealth.humanhealth_id=library_humanhealth.humanhealth_id and humanhealth.uniquename='$id' and library_humanhealth.pub_id=pub.pub_id";
        my $sl_nmm = $dbh->prepare($sl);
        $sl_nmm->execute;
        while ( my ( $s_id, $pub ) = $sl_nmm->fetchrow_array ) {
            my ( $s_u, $s_g, $s_s, $s_t ) = get_lib_ukeys_by_id( $dbh, $s_id );
            if ( $s_u eq '0' ) {
                print STDERR "ERROR: library $s_id has been obsoleted\n";
            }
            my $lib_humanhealth = create_ch_library_humanhealth(
                doc            => $doc,
                humanhealth_id => $unique,
                library_id     => create_ch_library(
                    doc        => $doc,
                    uniquename => $s_u,
                    genus      => $s_g,
                    species    => $s_s,
                    type       => $s_t,
                ),
                pub_id => $pub,

            );
###library_humanhealthprop type's default cv is
            #'library_humanhealthprop type'

#
# get_library_humanhealthprop_rank CANNOT find so NEVER called ????
#

#             my $sub =
#               "select value, cvterm.name,cv.name, cvterm.is_obsolete from
# 			library_humanhealthprop, cvterm, cv where
# 			library_humanhealthprop.type_id=cvterm.cvterm_id and
#                         cv.cv_id=cvterm.cv_id and 
# 			library_humanhealthprop.library_humanhealth_id=$s_id";
#             my $s_n = $dbh->prepare($sub);
#             $s_n->execute;
#             while ( my ( $value, $type, $cv, $is ) = $s_n->fetchrow_array ) {
#                 if ( !defined($value) ) {
#                     $value = '';
#                 }

# #	      print STDERR "library_humanhealthprop value $value type $type cv $cv \n";
#                 my $rank =
#                   get_library_humanhealthprop_rank( $dbh, $unique, $cv, $l_u,
#                     $type, $value, $pub );
#                 my $fc = create_ch_library_humanhealthprop(
#                     doc     => $doc,
#                     type_id => create_ch_cvterm(
#                         doc         => $doc,
#                         name        => $type,
#                         cv          => $cv,
#                         is_obsolete => $is
#                     ),
#                     rank => $rank,
#                 );
#                 $fc->appendChild( create_doc_element( $doc, 'value', $value ) )
#                   if ( defined($value) );
#                 $lib_humanhealth->appendChild($fc);
#             }
#             $out .= dom_toString($lib_humanhealth);
#             $lib_humanhealth->dispose();
        }
        $sl_nmm->finish;
    }
    $doc->dispose();
    print STDERR "end of merge_humanhealth\n";

    # print STDERR "$out\n";
    return $out;

}

sub get_humanhealthname_by_uniquename {
    my $dbh  = shift;
    my $name = shift;
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;
    my $statement = "select name from humanhealth where uniquename='$name'  and
  library.is_obsolete='f';";

    # print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $uni = $nmm->fetchrow_array;

    return $uni;
}

sub get_humanhealth_cvtermprop_rank {
    my $dbh    = shift;
    my $fb_id  = shift;
    my $cv     = shift;
    my $cvterm = shift;
    my $type   = shift;
    my $value  = shift;
    my $pub    = shift;
    my $rank   = 0;
    $cvterm =~ s/\\/\\\\/g;
    $cvterm =~ s/\'/\\\'/g;

    if ( defined($value) ) {
        $value =~ s/\\/\\\\/g;
        $value =~ s/\'/\\\'/g;
    }
    if (   defined($value)
        && defined( $fprank{$fb_id}{ $cvterm . $pub . $type . $value } ) )
    {
        return $fprank{$fb_id}{ $cvterm . $pub . $type . $value };
    }
    else {
        if ( defined( $fprank{$fb_id}{ $cvterm . $pub . $type } ) ) {
            $fprank{$fb_id}{ $cvterm . $pub . $type } += 1;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $cvterm . $pub . $type . $value } =
                  $fprank{$fb_id}{ $cvterm . $pub . $type };
            }
            return $fprank{$fb_id}{ $cvterm . $pub . $type };
        }
        else {
            if ( defined($value) ) {
                my $statement = "select max(humanhealth_cvtermprop.rank) from 
			humanhealth_cvterm,
			humanhealth, cv, cvterm, pub, cvterm cvterm2, humanhealth_cvtermprop
			where humanhealth_cvterm.humanhealth_id=humanhealth.humanhealth_id and
			humanhealth.uniquename='$fb_id' and
			humanhealth_cvtermprop.humanhealth_cvterm_id = 
			humanhealth_cvterm.humanhealth_cvterm_id
			and humanhealth_cvtermprop.type_id=cvterm2.cvterm_id and
			cvterm2.name='$type' 
				and
			humanhealth_cvterm.cvterm_id=cvterm.cvterm_id and cvterm.cv_id=cv.cv_id
			and cv.name='$cv' and cvterm.name= E'$cvterm' and 
			humanhealth_cvterm.pub_id=pub.pub_id and
			pub.uniquename='$pub' and humanhealth_cvtermprop.value= E'$value'";

                #print STDERR "$statement\n";
                my $fc_el = $dbh->prepare($statement);
                $fc_el->execute;
                my $f_r = $fc_el->fetchrow_array;
                if ( defined($f_r) ) {
                    $fprank{$fb_id}{ $cvterm . $pub . $type . $value } = $f_r;
                    return $f_r;
                }
            }

            my $state = "select max(humanhealth_cvtermprop.rank) from 
			humanhealth_cvterm,
			humanhealth, cv, cvterm, pub, cvterm cvterm2, humanhealth_cvtermprop
			where humanhealth_cvterm.humanhealth_id=humanhealth.humanhealth_id and
			humanhealth.uniquename='$fb_id' and
			humanhealth_cvtermprop.humanhealth_cvterm_id = 
			humanhealth_cvterm.humanhealth_cvterm_id
			and humanhealth_cvtermprop.type_id=cvterm2.cvterm_id and
			cvterm2.name='$type' and
			humanhealth_cvterm.cvterm_id=cvterm.cvterm_id and cvterm.cv_id=cv.cv_id
			and cv.name='$cv' and cvterm.name= E'$cvterm' and 
			humanhealth_cvterm.pub_id=pub.pub_id and
			pub.uniquename='$pub'";

            my $fb_el = $dbh->prepare($state);
            $fb_el->execute;
            while ( my $p_r = $fb_el->fetchrow_array ) {
                if ( $p_r ne '' ) {
                    $rank = $p_r;
                    $rank++;
                }
            }
            $fprank{$fb_id}{ $cvterm . $pub . $type } = $rank;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $cvterm . $pub . $type . $value } = $rank;
            }
            return $rank;
        }

    }
    return $rank;
}

sub get_humanhealth_phenotypeprop_rank {
    my $dbh       = shift;
    my $fb_id     = shift;
    my $cv        = shift;
    my $phenotype = shift;
    my $type      = shift;
    my $value     = shift;
    my $pub       = shift;
    my $rank      = 0;
    if ( defined($value) ) {
        $value =~ s/\\/\\\\/g;
        $value =~ s/\'/\\\'/g;
    }
    else {
        $value = '';
    }

#    print STDERR "get_humanhealth_phenotypeprop_rank fb_id $fb_id cv $cv phenotype $phenotype type $type value $value pub $pub\n";
    if (   defined($value)
        && defined( $fprank{$fb_id}{ $phenotype . $pub . $type . $value } ) )
    {
        return $fprank{$fb_id}{ $phenotype . $pub . $type . $value };
    }
    else {
        if ( defined( $fprank{$fb_id}{ $phenotype . $pub . $type } ) ) {
            $fprank{$fb_id}{ $phenotype . $pub . $type } += 1;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $phenotype . $pub . $type . $value } =
                  $fprank{$fb_id}{ $phenotype . $pub . $type };
            }
            return $fprank{$fb_id}{ $phenotype . $pub . $type };
        }
        else {
            if ( defined($value) ) {
                my $statement =
                  "select max(humanhealth_phenotypeprop.rank) from 
			humanhealth_phenotype,
			humanhealth, cv, phenotype, pub, cvterm cvterm2, humanhealth_phenotypeprop 
			where humanhealth_phenotype.humanhealth_id=humanhealth.humanhealth_id and 
			humanhealth.uniquename='$fb_id' and 
			humanhealth_phenotypeprop.humanhealth_phenotype_id = 
			humanhealth_phenotype.humanhealth_phenotype_id 
			and humanhealth_phenotypeprop.type_id=cvterm2.cvterm_id and
			cvterm2.name='$type'  
			and cvterm2.cv_id = cv.cv_id and cv.name = '$cv' and
			humanhealth_phenotype.phenotype_id=phenotype.phenotype_id 
		        and 
			humanhealth_phenotype.pub_id=pub.pub_id and
			pub.uniquename='$pub' and humanhealth_phenotypeprop.value= E'$value'";

                #           print STDERR "$statement\n";
                my $fc_el = $dbh->prepare($statement);
                $fc_el->execute;
                my $f_r = $fc_el->fetchrow_array;
                if ( defined($f_r) ) {
                    $fprank{$fb_id}{ $phenotype . $pub . $type . $value } =
                      $f_r;
                    return $f_r;
                }
            }

            my $state = "select max(humanhealth_phenotypeprop.rank) from 
			humanhealth_phenotype,
			humanhealth, cv, phenotype, pub, cvterm cvterm2, humanhealth_phenotypeprop
			where humanhealth_phenotype.humanhealth_id=humanhealth.humanhealth_id and
			humanhealth.uniquename='$fb_id' and
			humanhealth_phenotypeprop.humanhealth_phenotype_id = 
			humanhealth_phenotype.humanhealth_phenotype_id
			and humanhealth_phenotypeprop.type_id=cvterm2.cvterm_id and
			cvterm2.name='$type' and
			humanhealth_phenotype.phenotype_id=phenotype.phenotype_id and cvterm2.cv_id=cv.cv_id
			and cv.name='$cv' and phenotype.name='$phenotype' and 
			humanhealth_phenotype.pub_id=pub.pub_id and
			pub.uniquename='$pub'";

            #            print STDERR "$state\n";

            my $fb_el = $dbh->prepare($state);
            $fb_el->execute;
            while ( my $p_r = $fb_el->fetchrow_array ) {
                if ( $p_r ne '' ) {
                    $rank = $p_r;
                    $rank++;
                }
            }
            $fprank{$fb_id}{ $phenotype . $pub . $type } = $rank;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $phenotype . $pub . $type . $value } = $rank;
            }
            return $rank;
        }

    }
    return $rank;
}

sub get_humanhealth_featureprop_rank {
    my $dbh     = shift;
    my $fb_id   = shift;
    my $cv      = shift;
    my $feature = shift;
    my $type    = shift;
    my $value   = shift;
    my $pub     = shift;
    my $rank    = 0;
    if ( defined($value) ) {
        $value =~ s/\\/\\\\/g;
        $value =~ s/\'/\\\'/g;
    }
    else {
        $value = '';
    }

#    print STDERR "get_humanhealth_featureprop_rank fb_id $fb_id cv $cv feature $feature type $type value $value pub $pub\n";
    if (   defined($value)
        && defined( $fprank{$fb_id}{ $feature . $pub . $type . $value } ) )
    {
        return $fprank{$fb_id}{ $feature . $pub . $type . $value };
    }
    else {
        if ( defined( $fprank{$fb_id}{ $feature . $pub . $type } ) ) {
            $fprank{$fb_id}{ $feature . $pub . $type } += 1;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $feature . $pub . $type . $value } =
                  $fprank{$fb_id}{ $feature . $pub . $type };
            }
            return $fprank{$fb_id}{ $feature . $pub . $type };
        }
        else {
            if ( defined($value) ) {
                my $statement = "select max(humanhealth_featureprop.rank) from 
			humanhealth_feature,
			humanhealth, cv, feature, pub, cvterm cvterm2, humanhealth_featureprop 
			where humanhealth_feature.humanhealth_id=humanhealth.humanhealth_id and 
			humanhealth.uniquename='$fb_id' and 
			humanhealth_featureprop.humanhealth_feature_id = 
			humanhealth_feature.humanhealth_feature_id 
			and humanhealth_featureprop.type_id=cvterm2.cvterm_id and
			cvterm2.name='$type'  
			and cvterm2.cv_id = cv.cv_id and cv.name = '$cv' and
			humanhealth_feature.feature_id=feature.feature_id 
		        and 
			humanhealth_feature.pub_id=pub.pub_id and
			pub.uniquename='$pub' and humanhealth_featureprop.value= E'$value'";

                #           print STDERR "$statement\n";
                my $fc_el = $dbh->prepare($statement);
                $fc_el->execute;
                my $f_r = $fc_el->fetchrow_array;
                if ( defined($f_r) ) {
                    $fprank{$fb_id}{ $feature . $pub . $type . $value } = $f_r;
                    return $f_r;
                }
            }

            my $state = "select max(humanhealth_featureprop.rank) from 
			humanhealth_feature,
			humanhealth, cv, feature, pub, cvterm cvterm2, humanhealth_featureprop
			where humanhealth_feature.humanhealth_id=humanhealth.humanhealth_id and
			humanhealth.uniquename='$fb_id' and
			humanhealth_featureprop.humanhealth_feature_id = 
			humanhealth_feature.humanhealth_feature_id
			and humanhealth_featureprop.type_id=cvterm2.cvterm_id and
			cvterm2.name='$type' and
			humanhealth_feature.feature_id=feature.feature_id and cvterm2.cv_id=cv.cv_id
			and cv.name='$cv' and feature.name='$feature' and 
			humanhealth_feature.pub_id=pub.pub_id and
			pub.uniquename='$pub'";

            #            print STDERR "$state\n";

            my $fb_el = $dbh->prepare($state);
            $fb_el->execute;
            while ( my $p_r = $fb_el->fetchrow_array ) {
                if ( $p_r ne '' ) {
                    $rank = $p_r;
                    $rank++;
                }
            }
            $fprank{$fb_id}{ $feature . $pub . $type } = $rank;
            if ( defined($value) ) {
                $fprank{$fb_id}{ $feature . $pub . $type . $value } = $rank;
            }
            return $rank;
        }

    }
    return $rank;
}

sub dissociate_with_pub_fromhumanhealth {
    my $dbh    = shift;
    my $unique = shift;
    my $pub    = shift;
    my $out    = '';
    my $doc    = new XML::DOM::Document;
    ###get humanhealth_synonym
    print STDERR "in method dissociate_with_pub_fromhumanhealth\n";
    my $statement = "select synonym.name, synonym.synonym_sgml,
		cvterm.name
		from humanhealth,synonym,humanhealth_synonym,pub,cvterm where
		humanhealth.uniquename='$unique' and humanhealth.humanhealth_id = 
		humanhealth_synonym.humanhealth_id 
		and humanhealth_synonym.synonym_id=synonym.synonym_id 
                and humanhealth_synonym.pub_id=pub.pub_id and pub.uniquename='$pub'                
                and cvterm.cvterm_id=synonym.type_id;";

    #print STDERR "$statement\n";

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $name, $sgml, $type ) = $nmm->fetchrow_array ) {
        my $fs = create_ch_humanhealth_synonym(
            doc            => $doc,
            humanhealth_id => $unique,
            synonym_id     => create_ch_synonym(
                doc          => $doc,
                name         => $name,
                synonym_sgml => $sgml,
                type         => $type
            ),
            pub_id => $pub
        );
        $fs->setAttribute( 'op', 'delete' );
        $out .= dom_toString($fs);
    }
    $nmm->finish;

    #print STDERR "done humanhealth_synonym\n";
    ###get humanhealth_cvterm
    my $c_state = "select cvterm.name, cv.name from
		humanhealth_cvterm, cvterm, cv, pub, humanhealth where
		humanhealth.humanhealth_id=humanhealth_cvterm.humanhealth_id and
		humanhealth.uniquename='$unique' and
		humanhealth_cvterm.cvterm_id=cvterm.cvterm_id and
		cvterm.cv_id=cv.cv_id and humanhealth_cvterm.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$c_state\n";
    my $f_c = $dbh->prepare($c_state);
    $f_c->execute;
    while ( my ( $cvterm, $cv ) = $f_c->fetchrow_array ) {
        my $f = create_ch_humanhealth_cvterm(
            doc            => $doc,
            name           => $cvterm,
            cv             => $cv,
            pub_id         => $pub,
            humanhealth_id => $unique
        );

        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
    }
    $f_c->finish;

    #print STDERR "done humanhealth_cvterm\n";
    ###get humanhealth_pub humanhealth_pubprop will get deleted too
    my $fp = "select pub.uniquename from humanhealth, humanhealth_pub, pub 
		where humanhealth.humanhealth_id=humanhealth_pub.humanhealth_id and
		humanhealth.uniquename='$unique' and
		pub.pub_id=humanhealth_pub.pub_id and pub.uniquename='$pub';";
    my $f_p = $dbh->prepare($fp);
    $f_p->execute;
    while ( my ($fpub) = $f_p->fetchrow_array ) {
        print STDERR "got humanhealth_pub \n";
        my $feat_pub = create_ch_humanhealth_pub(
            doc            => $doc,
            humanhealth_id => $unique,
            pub_id         => $pub
        );
        $feat_pub->setAttribute( 'op', 'delete' );
        $out .= dom_toString($feat_pub);
    }
    $f_p->finish;

    #print STDERR "done humanhealth_pub\n";
    ###get humanhealthprop,humanhealthprop_pub
    $fp = "select humanhealthprop.humanhealthprop_id, cvterm.name,rank from
		humanhealthprop,humanhealthprop_pub, humanhealth,cvterm,pub where
		humanhealth.humanhealth_id=humanhealthprop.humanhealth_id and
		humanhealthprop.humanhealthprop_id=humanhealthprop_pub.humanhealthprop_id and 
		humanhealth.uniquename='$unique' and
		cvterm.cvterm_id=humanhealthprop.type_id and humanhealthprop_pub.pub_id =
		pub.pub_id and pub.uniquename='$pub';";

    #print STDERR "$fp\n";
    my $fp_nmm = $dbh->prepare($fp);
    $fp_nmm->execute;
    while ( my ( $fp_id, $type, $rank ) = $fp_nmm->fetchrow_array ) {
        my $num = get_humanhealthprop_pub_nums( $dbh, $fp_id );
        if ( $num == 1 ) {
            $out .= delete_humanhealthprop( $doc, $rank, $unique, $type );
        }
        elsif ( $num > 1 ) {
            $out .=
              delete_humanhealthprop_pub( $doc, $rank, $unique, $type, $pub );
        }
    }
    $fp_nmm->finish;
    ###get humanhealth_relationship,hhr_pub
    my $fr_state =
        "select 'subject_id' as type, fr.humanhealth_relationship_id, "
      . "f1.uniquename as subject_id, f2.name as name, f2.humanhealth_id,"
      . " f2.uniquename as "
      . "object_id, cvterm.name as frtype from "
      . "humanhealth_relationship fr, humanhealth_relationship_pub frp, "
      . "humanhealth f1,humanhealth f2, cvterm, pub where "
      . "frp.humanhealth_relationship_id=fr.humanhealth_relationship_id and "
      . "cvterm.cvterm_id=fr.type_id and frp.pub_id=pub.pub_id and "
      . "fr.subject_id=f1.humanhealth_id and pub.uniquename='$pub' and "
      . "fr.object_id=f2.humanhealth_id and f1.uniquename='$unique' "
      . "union "
      . "select 'object_id' as type, fr.humanhealth_relationship_id, f2.uniquename as "
      . "subject_id, f1.name as name, f1.humanhealth_id, f1.uniquename as "
      . "object_id, cvterm.name as frtype from "
      . "humanhealth_relationship fr, humanhealth_relationship_pub frp,"
      . "humanhealth f1, humanhealth f2, cvterm, pub where "
      . "frp.humanhealth_relationship_id=fr.humanhealth_relationship_id and "
      . "cvterm.cvterm_id=fr.type_id and frp.pub_id=pub.pub_id and "
      . "fr.subject_id=f1.humanhealth_id and pub.uniquename='$pub' and "
      . "fr.object_id=f2.humanhealth_id and f2.uniquename='$unique'";

    #print STDERR "$fr_state\n";
    my $fr_nmm = $dbh->prepare($fr_state);
    $fr_nmm->execute;
    while ( my $fr_hash = $fr_nmm->fetchrow_hashref ) {

        if ( !defined( $fr_hash->{object_id} ) ) {
            last;
        }
        my $subject_id = 'subject_id';
        my $object_id  = 'object_id';
        my $fr_subject = $fr_hash->{object_id};
        if ( $fr_hash->{type} eq 'object_id' ) {
            $subject_id = 'object_id';
            $object_id  = 'subject_id';
        }

        if ( !exists( $fr_hash->{name} ) ) {
            print STDERR "ERROR: name is not found in disassociate_fnction\n";
        }

        my $num =
          get_hhr_pub_nums( $dbh, $fr_hash->{humanhealth_relationship_id} );
        if ( $num == 1 ) {
            $out .=
              delete_humanhealth_relationship( $dbh, $doc, $fr_hash,
                $subject_id, $object_id, $unique, $fr_hash->{frtype} );
        }
        elsif ( $num > 1 ) {
            $out .=
              delete_humanhealth_relationship_pub( $dbh, $doc, $fr_hash,
                $subject_id, $object_id, $unique, $fr_hash->{frtype}, $pub );
        }
    }
    $fr_nmm->finish;

    #print STDERR "done humanhealth_relationship\n";
    ###get humanhealth_phenotype
    my $i_state = "select phenotype.uniquename from
		phenotype, humanhealth_phenotype, pub, humanhealth where
		humanhealth.humanhealth_id=humanhealth_phenotype.humanhealth_id and
		humanhealth.uniquename='$unique' and 
		humanhealth_phenotype.phenotype_id = phenotype.phenotype_id and
		humanhealth_phenotype.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$i_state\n";
    my $i_e = $dbh->prepare($i_state);
    $i_e->execute;
    while ( my ($iuname) = $i_e->fetchrow_array ) {
        my $f = create_ch_humanhealth_phenotype(
            doc => $doc,
            phenotype_id =>
              create_ch_phenotype( doc => $doc, uniquename => $iuname ),
            pub_id         => $pub,
            humanhealth_id => $unique
        );

        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
    }
    $i_e->finish;

    #print STDERR "done humanhealth_phenotype\n";
    ###get humanhealth_feature
    my $f_state =
"select feature.uniquename, organism.genus, organism.species, cv.name, cvterm.name from
		feature, humanhealth_feature, pub, humanhealth, organism, cv, cvterm where
		humanhealth.humanhealth_id=humanhealth_feature.humanhealth_id and
		humanhealth.uniquename='$unique' and 
		humanhealth_feature.feature_id = feature.feature_id and feature.organism_id = organism.organism_id and 
                feature.type_id = cvterm.cvterm_id and cvterm.cv_id = cv.cv_id and 
		humanhealth_feature.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$f_state\n";
    my $f_s = $dbh->prepare($f_state);
    $f_s->execute;
    while ( my ( $funame, $genus, $species, $cvname, $cvterm ) =
        $f_s->fetchrow_array )
    {
        my $f = create_ch_humanhealth_feature(
            doc        => $doc,
            feature_id => create_ch_feature(
                doc        => $doc,
                uniquename => $funame,
                genus      => $genus,
                species    => $species,
                type_id    => create_ch_cvterm(
                    doc  => $doc,
                    cv   => $cvname,
                    name => $cvterm
                ),
            ),
            pub_id         => $pub,
            humanhealth_id => $unique
        );

        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
    }
    $f_s->finish;

    #print STDERR "done humanhealth_feature\n";

    ###get feature_humanhealth_dbxref
    my $fd_state =
"select feature.uniquename, organism.genus, organism.species, cv.name, cvterm.name, db.name, dbxref.accession 
                from feature, feature_humanhealth_dbxref, pub, humanhealth, organism, cv, cvterm, humanhealth_dbxref, humanhealth_dbxrefprop, db, dbxref, cvterm cvt1
                where humanhealth.humanhealth_id=humanhealth_dbxref.humanhealth_id and humanhealth_dbxref.dbxref_id = dbxref.dbxref_id 
                and dbxref.db_id = db.db_id and humanhealth_dbxref.humanhealth_dbxref_id = humanhealth_dbxrefprop.humanhealth_dbxref_id 
                and humanhealth_dbxrefprop.type_id = cvt1.cvterm_id and cvt1.name = 'diopt_ortholog' and 
                humanhealth.is_obsolete = false and  
		humanhealth.uniquename='$unique' and humanhealth_dbxref.is_current = true and 
		feature_humanhealth_dbxref.feature_id = feature.feature_id and feature.organism_id = organism.organism_id and 
                feature.type_id = cvterm.cvterm_id and cvterm.cv_id = cv.cv_id and feature.is_obsolete = false  and
		feature_humanhealth_dbxref.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$fd_state\n";
    my $fd_s = $dbh->prepare($fd_state);
    $fd_s->execute;
    while ( my ( $funame, $genus, $species, $cvname, $cvterm, $dbname, $acc ) =
        $fd_s->fetchrow_array )
    {
        my $fd = create_ch_feature_humanhealth_dbxref(
            doc        => $doc,
            feature_id => create_ch_feature(
                doc        => $doc,
                uniquename => $funame,
                genus      => $genus,
                species    => $species,
                type_id    => create_ch_cvterm(
                    doc  => $doc,
                    cv   => $cvname,
                    name => $cvterm
                ),
            ),
            pub_id                => $pub,
            humanhealth_dbxref_id => create_ch_humanhealth_dbxref(
                doc            => $doc,
                humanhealth_id => $unique,
                dbxref_id      => create_ch_dbxref(
                    doc       => $doc,
                    db        => $dbname,
                    accession => $acc,
                ),
            ),
        );

        $fd->setAttribute( 'op', 'delete' );
        $out .= dom_toString($fd);
    }
    $fd_s->finish;

    #print STDERR "done feature_humanhealth_dbxref\n";

    ###get humanhealth_dbxrefprop_pub
    my $fx_state = << "FX_STATE";
    select db.name, dbxref.accession, cv.name, cvterm.name 
      FROM pub, humanhealth, humanhealth_dbxref, humanhealth_dbxrefprop, humanhealth_dbxrefprop_pub, 
           db, dbxref, cvterm, cv
      WHERE humanhealth.humanhealth_id=humanhealth_dbxref.humanhealth_id AND
            humanhealth_dbxref.dbxref_id = dbxref.dbxref_id AND 
            dbxref.db_id = db.db_id AND
            humanhealth_dbxref.humanhealth_dbxref_id = humanhealth_dbxrefprop.humanhealth_dbxref_id AND
            humanhealth_dbxrefprop.type_id = cvterm.cvterm_id AND
            cvterm.cv_id = cv.cv_id AND 
            humanhealth.is_obsolete = false AND  
		    humanhealth.uniquename='$unique' AND
            humanhealth_dbxref.is_current = true AND 
		    humanhealth_dbxrefprop.humanhealth_dbxrefprop_id = humanhealth_dbxrefprop_pub.humanhealth_dbxrefprop_id AND
            humanhealth_dbxrefprop_pub.pub_id=pub.pub_id AND
            pub.uniquename='$pub';
FX_STATE
    # print STDERR "$fx_state\n";
    my $fx_s = $dbh->prepare($fx_state);
    $fx_s->execute;
    my @delete_list = ();
    while ( my ( $dbname, $acc, $cv, $cvterm ) = $fx_s->fetchrow_array ) {
        print STDERR "$dbname, $acc, $cv, $cvterm\n";
        push(@delete_list, [$dbname, $acc]);
        my $hxpp = create_ch_humanhealth_dbxrefprop_pub(
            doc    => $doc,
            pub_id => $pub,
            humanhealth_dbxrefprop_id => create_ch_humanhealth_dbxrefprop(
                doc                   => $doc,
                humanhealth_dbxref_id => create_ch_humanhealth_dbxref(
                    doc            => $doc,
                    humanhealth_id => $unique,
                    dbxref_id      => create_ch_dbxref(
                        doc       => $doc,
                        db        => $dbname,
                        accession => $acc,
                    ),
                ),
                cvname => $cv,
                type => $cvterm,
            )
        );
        $hxpp->setAttribute( 'op', 'delete' );
        $out .= dom_toString($hxpp);
        # now delete the prop
        my $hxp = create_ch_humanhealth_dbxrefprop(
                doc                   => $doc,
                humanhealth_dbxref_id => create_ch_humanhealth_dbxref(
                    doc            => $doc,
                    humanhealth_id => $unique,
                    dbxref_id      => create_ch_dbxref(
                        doc       => $doc,
                        db        => $dbname,
                        accession => $acc,
                    ),
                ),
                cvname => $cv,
                type => $cvterm,
        );
        $hxp->setAttribute( 'op', 'delete' );
        $out .= dom_toString($hxp);
    }
    $fx_s->finish;
    # now delete the hh dbxref if no other pubs linked.
    my $d_state = << "D_STATE";
    select pub.uniquename
      FROM pub, humanhealth, humanhealth_dbxref, humanhealth_dbxrefprop, humanhealth_dbxrefprop_pub, 
           db, dbxref
      WHERE humanhealth.humanhealth_id=humanhealth_dbxref.humanhealth_id AND
            humanhealth_dbxref.dbxref_id = dbxref.dbxref_id AND 
            dbxref.db_id = db.db_id AND
            humanhealth_dbxref.humanhealth_dbxref_id = humanhealth_dbxrefprop.humanhealth_dbxref_id AND
            humanhealth.is_obsolete = false AND  
		    humanhealth.uniquename='$unique' AND
            humanhealth_dbxref.is_current = true AND 
		    humanhealth_dbxrefprop.humanhealth_dbxrefprop_id = humanhealth_dbxrefprop_pub.humanhealth_dbxrefprop_id AND
            humanhealth_dbxrefprop_pub.pub_id=pub.pub_id AND
            dbxref.accession = ? AND
            db.name = ? AND
            pub.uniquename != '$pub';
D_STATE
    my $sth_del = $dbh->prepare($d_state);
    for my $item (@delete_list){
        my $dbname = $$item[0];
        my $accession = $$item[1];
        my $found = 0;
        ##############################################################
        # Check humanhealth_dbxrefprop_pub for a different pub.
        # If another link then keep hh_dbxref.
        ##############################################################
        my $res = $sth_del->execute($accession, $dbname);
        while(my $new_pub = $sth_del->fetchrow_array){
            $found = 1;
        }
        if ( ! $found) {
            # print STDERR "Removing hh dbxref link.\n";
            my $hx = create_ch_humanhealth_dbxref(
                    doc            => $doc,
                    humanhealth_id => $unique,
                    dbxref_id      => create_ch_dbxref(
                        doc       => $doc,
                        db        => $dbname,
                        accession => $accession,
                    ),
            );
            $hx->setAttribute( 'op', 'delete' );
            $out .= dom_toString($hx);
        }
        #else{
        #    print STDERR "Leaving hh dbxref link as accesed by another pub\n";
        #}
    }
    print STDERR "done humanhealth_dbxrefprop_pub\n";

    ###get library_humanhealth
    my $ls_state =
"select library.uniquename, organism.genus, organism.species, cv.name, cvterm.name from
		library, library_humanhealth, pub, humanhealth, organism, cv, cvterm where
		humanhealth.humanhealth_id=library_humanhealth.humanhealth_id and
		humanhealth.uniquename='$unique' and 
		library_humanhealth.library_id = library.library_id and library.organism_id = organism.organism_id and 
                library.type_id = cvterm.cvterm_id and cvterm.cv_id = cv.cv_id and 
		library_humanhealth.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$f_state\n";
    my $l_s = $dbh->prepare($ls_state);
    $l_s->execute;
    while ( my ( $funame, $genus, $species, $cvname, $cvterm ) =
        $l_s->fetchrow_array )
    {
        my $f = create_ch_library_humanhealth(
            doc        => $doc,
            feature_id => create_ch_library(
                doc        => $doc,
                uniquename => $funame,
                genus      => $genus,
                species    => $species,
                type_id    => create_ch_cvterm(
                    doc  => $doc,
                    cv   => $cvname,
                    name => $cvterm
                ),
            ),
            pub_id         => $pub,
            humanhealth_id => $unique
        );

        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
    }
    $l_s->finish;

    #print STDERR "done library_humanhealth\n";
    print STDERR "leaving method dissociate_with_pub_fromhumanhealth\n";
    $doc->dispose();
    return $out;
}

sub get_max_humanhealthprop_rank {
    my $dbh    = shift;
    my $unique = shift;
    my $type   = shift;
    my $value  = shift;
    my $rank;

    if ( exists( $fprank{$unique}{ $type . $value } ) ) {
        $rank = $fprank{$unique}{ $type . $value };
        return $rank;
    }
    $value =~ s/\\/\\\\/g;
    $value =~ s/\'/\\\'/g;
    $value =~ s/\|/\\\|/g;

    my $statement = "select rank from humanhealthprop, humanhealth, cvterm,cv
  where humanhealth.uniquename='$unique' and
  humanhealthprop.humanhealth_id=humanhealth.humanhealth_id and cvterm.name='$type'
	  and cv.name='property type' and cv.cv_id=cvterm.cv_id and
  cvterm.cvterm_id=humanhealthprop.type_id and humanhealthprop.value= E'$value';";

    #print STDERR $statement,"\n";
    my $fp_p = $dbh->prepare($statement);
    $fp_p->execute;
    $rank = $fp_p->fetchrow_array;
    $fp_p->finish;
    if ( defined($rank) ) {
        $fprank{$unique}{ $type . $value } = $rank;
        return $rank;
    }
    else {
        $statement =
"select max(rank) from humanhealthprop, humanhealth, cvterm,cv where humanhealth.uniquename='$unique' and humanhealthprop.humanhealth_id=humanhealth.humanhealth_id and cvterm.name='$type' and cv.name='property type' and cv.cv_id=cvterm.cv_id and cvterm.cvterm_id=humanhealthprop.type_id;";

        my $fr_r = $dbh->prepare($statement);
        $fr_r->execute;
        $rank = $fr_r->fetchrow_array;

        if ( exists( $fprank{$unique}{$type} ) ) {

            if ( defined($rank) && $rank >= $fprank{$unique}{$type} ) {
                $fprank{$unique}{$type} = $rank + 1;
            }
            else {
                $fprank{$unique}{$type}++;
            }

        }
        else {
            if ( !defined($rank) ) {
                $fprank{$unique}{$type} = 0;
            }
            else {
                $fprank{$unique}{$type} = $rank + 1;
            }
        }
        $fprank{$unique}{ $type . $value } = $fprank{$unique}{$type};
        return $fprank{$unique}{$type};
    }
}

sub check_humanhealth_synonym {
    my $dbh  = shift;
    my $fbid = shift;
    my $type = shift;
    my $num  = 0;

    my $statement = "select * from
	humanhealth_synonym, humanhealth, synonym, cvterm where
	humanhealth_synonym.humanhealth_id=humanhealth.humanhealth_id and
	synonym.synonym_id=humanhealth_synonym.synonym_id and
	cvterm.cvterm_id=synonym.type_id and humanhealth.uniquename='$fbid' and
	cvterm.name='$type' and humanhealth_synonym.is_current='t'";

    #print $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub get_num_for_humanhealth_pubprop {
    my $dbh    = shift;
    my $unique = shift;
    my $cvterm = shift;
    my $fbrf   = shift;

    my $statement =
"select humanhealth_pubprop_id from humanhealth_pubprop, pub, cvterm where 
                humanhealth_pubprop.pub_id=pub.pub_id and humanhealth_pubprop.type_id=cvterm.cvterm_id
                        and pub.uniquename='$fbrf' and cvterm.name='$cvterm'";

    #print STDERR "$statement==\n";
    my $p_nmm = $dbh->prepare($statement);
    $p_nmm->execute;
    my $num = $p_nmm->num_rows;
    return $num;
}

################################
#grp functions
################################

sub get_grp_ukeys_by_uname {
    my $dbh   = shift;
    my $uname = shift;
    my $type  = '';
    my $fbid  = '';

    #    print STDERR "get_grp_ukeys_by_uname $uname\n";
    my $statement = "select uniquename,cvterm.name from grp,cvterm where
  grp.uniquename='$uname' and cvterm.cvterm_id=grp.type_id";

    #print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;

    #print " id num=$id_num\n";
    if ( $id_num > 1 ) {
        print STDERR
          "ERROR: duplicate names $uname \n$statement\n exiting...\n";
        return '2';

        #exit(0);
    }
    elsif ( $id_num == 0 ) {
        print STDERR "ERROR: could not get uniquename for $uname\n";
        return '0';
    }
    elsif ( $id_num == 1 ) {
        ( $fbid, $type ) = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return ( $fbid, $type );
}

sub get_grp_ukeys_by_name {
    ####given name, search db for uniquename and cvterm
    my $dbh  = shift;
    my $name = shift;
    my $type = '';
    my $fbid = '';

    $name = convers($name);
    $name = decon($name);
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;

    print STDERR "get_grp_ukeys_by_name $name\n";
    my $statement = "select uniquename,cvterm.name 
          from grp,cvterm where grp.name= E'$name'
	  and cvterm.cvterm_id=grp.type_id and grp.is_obsolete='f'
	  and grp.is_analysis='f' 
          and grp.uniquename like 'FBgg%' ";

    #  print STDERR $statement;

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;

    #    print  STDERR "DEBUG id num=$id_num\n";
    if ( $id_num > 1 ) {
        print STDERR
          "Warning: duplicate names $name \n$statement\n exiting...\n";
        return '2';

        #exit(0);
    }
    elsif ( $id_num == 0 ) {
        print STDERR "Warning: could not get uniquename for $name\n";
        return '0';
    }
    elsif ( $id_num == 1 ) {
        ( $fbid, $type ) = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return ( $fbid, $type );
}

sub validate_grp_uname_name {
    my $dbh   = shift;
    my $uname = shift;
    my $name  = shift;

    $uname =~ s/\\/\\\\/g;
    $uname =~ s/\'/\\\'/g;
    $name    = convers($name);
    my $aname   = decon($name);
    my $nameutf = toutf($name);
    my $statement = <<"SYMBOL";
    SELECT DISTINCT s.synonym_sgml
      FROM grp g, grp_synonym gs, synonym s, cvterm cvt
      WHERE g.is_obsolete='f' AND
            g.grp_id=gs.grp_id AND
            gs.synonym_id=s.synonym_id AND
            gs.is_current='t' AND
            s.type_id=cvt.cvterm_id AND
            cvt.name='symbol' AND
            g.uniquename='$uname';
SYMBOL
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $num = $nmm->rows;

    my ($symbol) = $nmm->fetchrow_array;
    if ( $symbol ne $nameutf && $symbol ne $name ) {
        print STDERR
          "ERROR: uniquename '$uname' and name '$name' do not match\n ";
        return 0;
    }
    else {
        return 1;
    }
    $nmm->finish;
}

sub delete_grp_synonym {
    my $dbh       = shift;
    my $doc       = shift;
    my $uname     = shift;
    my $pub       = shift;
    my $stype     = shift;
    my $out       = '';
    my $statement = "";

    $dbh->{pg_enable_utf8} = 1;

    if ( $pub eq 'unattributed' ) {
        $statement = "select synonym.name,synonym.synonym_sgml,cvterm.name
	from grp,synonym,grp_synonym,pub, cvterm where grp.uniquename='$uname' and grp.grp_id=grp_synonym.grp_id and grp_synonym.synonym_id=synonym.synonym_id and grp_synonym.pub_id=pub.pub_id and pub.uniquename='$pub' and grp_synonym.is_current = false and cvterm.cvterm_id=synonym.type_id and cvterm.name='$stype';";
    }
    else {
        $statement = "select synonym.name,synonym.synonym_sgml,cvterm.name
	from grp,synonym,grp_synonym,pub, cvterm where grp.uniquename='$uname' and grp.grp_id=grp_synonym.grp_id and grp_synonym.synonym_id=synonym.synonym_id and grp_synonym.pub_id=pub.pub_id and pub.uniquename='$pub' and cvterm.cvterm_id=synonym.type_id and cvterm.name='$stype';";
    }
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $name, $sgml, $type ) = $nmm->fetchrow_array ) {

        my $fs = create_ch_grp_synonym(
            doc        => $doc,
            grp_id     => $uname,
            synonym_id => create_ch_synonym(
                doc          => $doc,
                name         => $name,
                synonym_sgml => $sgml,
                type         => $type
            ),
            pub_id => $pub
        );
        $fs->setAttribute( 'op', 'delete' );
        $out .= dom_toString($fs);
        $fs->dispose();

    }
    $nmm->finish;
    return $out;
}

sub write_grp_synonyms {
    my $doc         = shift;
    my $fbid        = shift;
    my $symbol      = shift;
    my $field       = shift;
    my $paper       = shift;
    my $s_type      = shift;
    my $is_current  = 0;
    my $is_internal = 0;
    my $out         = '';

#    print STDERR "DEBUG: in write_grp_synonyms $fbid $symbol $field $s_type\n";

    $symbol = &convers($symbol);

    #    print STDERR "DEBUG: after convers $symbol\n";

    my $sgml_symbol = &toutf($symbol);

    #    print STDERR "DEBUG: after toutf name $symbol sgml $sgml_symbol\n";

    if ( $paper eq 'FBrf0000000' ) {
        return '';
    }

    #print "SYMBOL ",$sgml_symbol,"\n";
    $symbol = &decon($symbol);

    #    print STDERR "DEBUG: in after decon name $symbol\n";
    if ( $symbol =~ /[^\x{0}-\x{7f}]/ ) {
        print STDERR "ERROR: check symbol $symbol possible utf8 non-Greek\n";
    }

    if ( $field =~ /a/ ) {
        ###current symbol
        $is_current  = 1;
        $is_internal = 0;
    }
    elsif ( $field =~ /b/ ) {
        ### other symbols
        $is_current  = 0;
        $is_internal = 0;
    }
    my $grp_syn = create_ch_grp_synonym(
        doc          => $doc,
        grp_id       => $fbid,
        synonym_sgml => $sgml_symbol,
        name         => $symbol,
        type         => $s_type,
        is_current   => $is_current,
        is_internal  => $is_internal,
        pub_id       => $paper
    );
    print STDERR
"DEBUG: after create_ch_grp_synonym symbol $symbol sgml $sgml_symbol $s_type\n";

    $out .= dom_toString($grp_syn);
    $grp_syn->dispose();
    return $out;
}

sub update_grp_synonym {
    my $dbh    = shift;
    my $doc    = shift;
    my $fbid   = shift;
    my $symbol = shift;
    my $s_type = shift;

    $dbh->{pg_enable_utf8} = 1;
    my $out = '';
    $symbol = &convers($symbol);
    $symbol = &decon($symbol);
    my $name = $symbol;
    $symbol =~ s/\\/\\\\/g;
    $symbol =~ s/\'/\\\'/g;
    my $statement = "select pub.uniquename, synonym.synonym_sgml from
	grp_synonym, grp, synonym,cvterm, pub where
	grp.grp_id=grp_synonym.grp_id and
	grp.uniquename='$fbid' and synonym.type_id=cvterm.cvterm_id and
	cvterm.name='$s_type' and
	synonym.synonym_id=grp_synonym.synonym_id and
	synonym.name= E'$symbol' and pub.pub_id=grp_synonym.pub_id and
	grp_synonym.is_current='t'";

    #print STDERR $statement;
    my $s_el = $dbh->prepare($statement);
    $s_el->execute;
    while ( my ( $pub, $sgml ) = $s_el->fetchrow_array ) {
        my $fs = create_ch_grp_synonym(
            doc        => $doc,
            grp_id     => $fbid,
            synonym_id => create_ch_synonym(
                doc          => $doc,
                name         => $name,
                synonym_sgml => $sgml,
                type         => $s_type
            ),
            pub        => $pub,
            is_current => 'f'
        );
        $out .= dom_toString($fs);
        $fs->dispose();
    }
    $s_el->finish;
    return $out;

}

sub check_grp_synonym_is_current {
    my $dbh  = shift;
    my $fbid = shift;
    my $name = shift;
    my $type = shift;

    #    $name = decon(convers($name));
    $name = toutf($name);
    my $statement = "select distinct synonym.synonym_sgml from
	grp_synonym, grp, synonym, cvterm where
	grp_synonym.grp_id=grp.grp_id and
	synonym.synonym_id=grp_synonym.synonym_id and
	cvterm.cvterm_id=synonym.type_id and grp.uniquename='$fbid' and
	cvterm.name='$type' and grp_synonym.is_current='t'";

    #print $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my $db_name = $nmm->fetchrow_array ) {

        if ( $db_name eq $name ) {
            return 'a';
        }
        else {
            return 'b';
        }
    }
    $nmm->finish;
    return 'b';
}

sub check_grp_synonym {
    my $dbh  = shift;
    my $fbid = shift;
    my $type = shift;
    my $num  = 0;

    my $statement = "select * from
	grp_synonym, grp, synonym, cvterm where
	grp_synonym.grp_id=grp.grp_id and
	synonym.synonym_id=grp_synonym.synonym_id and
	cvterm.cvterm_id=synonym.type_id and grp.uniquename='$fbid' and
	cvterm.name='$type' and grp_synonym.is_current='t'";

    #print $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub get_current_grp_name_by_synonym {
    my $dbh   = shift;
    my $syn   = shift;
    my @names = ();
    $syn = decon( convers($syn) );
    $syn =~ s/\\/\\\\/g;
    $syn =~ s/\'/\\\'/g;

    my $statement =
"select distinct(grp.name) from grp, grp_synonym, synonym where grp.grp_id=grp_synonym.grp_id and grp.is_obsolete='f' and grp.is_analysis='f' and grp_synonym.synonym_id=synonym.synonym_id and synonym.name= E'$syn'";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ($name) = $nmm->fetchrow_array ) {
        push( @names, $name );
    }
    if ( @names > 1 ) {
        print STDERR "ERROR: more than one grp asssociated with synonym $syn\n";
    }
    elsif ( @names == 0 ) {
        print STDERR "ERROR: could not find grp with synonym $syn\n";
    }
    else {
        return $names[0];
    }
}

sub get_cvterm_for_grp_cvterm_by_cvtermprop {
    my $dbh       = shift;
    my $unique    = shift;
    my $cv        = shift;
    my $pub       = shift;
    my $propvalue = shift;    #group_descriptor
    my $proptype  = shift;    #webcv
    my @result    = ();
    $propvalue =~ s/\\/\\\\/g;
    $propvalue =~ s/\'/\\\'/g;
    my $statement = "select cvt1.name from grp_cvterm fcv, grp f,
	cvterm cvt1, cvterm cvt2, cv, pub, cvtermprop cvp 
	where fcv.grp_id=f.grp_id
	and f.uniquename='$unique' and fcv.cvterm_id=cvt1.cvterm_id and
	cvt1.cv_id=cv.cv_id and cv.name='$cv' and
	cvt2.cvterm_id=cvp.type_id and cvt2.name='$proptype' and
	cvp.value = E'$propvalue' and cvp.cvterm_id=cvt1.cvterm_id and
	fcv.pub_id=pub.pub_id and pub.uniquename='$pub'";

    #print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my $cvterm = $nmm->fetchrow_array ) {
        push( @result, $cvterm );

    }
    $nmm->finish;
    return @result;
}

sub get_unique_key_for_grpprop {
    my $dbh    = shift;
    my $unique = shift;
    my $type   = shift;
    my $pub    = shift;
    my $cv     = shift;
    if ( !defined($cv) ) {
        $cv = 'grp property type';
    }

    my @ranks = ();
    my $statement =
"select grpprop.grpprop_id, rank from grpprop, grp,cvterm,grpprop_pub, pub,cv where grp.uniquename='$unique' and grpprop.grp_id=grp.grp_id and cvterm.name='$type' and cv.name='$cv' and cvterm.cv_id=cv.cv_id and cvterm.cvterm_id=grpprop.type_id and grpprop_pub.grpprop_id=grpprop.grpprop_id and pub.pub_id=grpprop_pub.pub_id and pub.uniquename='$pub';";

    # print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $fp_id, $rank ) = $nmm->fetchrow_array ) {
        my $fp = {
            fp_id => $fp_id,
            rank  => $rank
        };
        push( @ranks, $fp );
    }
    $nmm->finish;
    return @ranks;
}

sub get_grpprop_pub_nums {
    my $dbh   = shift;
    my $fr_id = shift;

    my $statement = "select pub_id from grpprop_pub where
	grpprop_id=$fr_id ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub delete_grpprop {
    my $doc  = shift;
    my $rank = shift;
    my $f_id = shift;
    my $type = shift;
    my $cv   = shift;

    if ( !defined($cv) ) {
        $cv = 'grp property type';
    }

    my $fp = create_ch_grpprop(
        doc    => $doc,
        grp_id => $f_id,
        rank   => $rank,
        cvname => $cv,
        type   => $type
    );

    $fp->setAttribute( 'op', 'delete' );

    my $out = dom_toString($fp);
    $fp->dispose();
    return $out;
}

sub delete_grpprop_pub {
    my $doc  = shift;
    my $rank = shift;
    my $f_id = shift;
    my $type = shift;
    my $pub  = shift;

    #        print STDERR "CHECK: in delete_grpprop_pub\n";
    my $fp = create_ch_grpprop(
        doc    => $doc,
        grp_id => $f_id,
        rank   => $rank,
        type   => $type
    );
    my $fpp = create_ch_grpprop_pub( doc => $doc, pub_id => $pub );
    $fpp->setAttribute( 'op', 'delete' );

    $fp->appendChild($fpp);
    my $out = dom_toString($fp);

    $frnum{$f_id}{$type}{$rank}++;
    $fp->dispose();
    print STDERR "CHECK: leaving delete_grpprop_pub\n";

    return $out;
}

sub write_grpprop {
    my $dbh     = shift;
    my $doc     = shift;
    my $feat_id = shift;
    my $value   = shift;
    my $type    = shift;
    my $pub     = shift;
    my $rank    = shift;

    if ( !defined($rank) ) {
        $rank = get_max_grpprop_rank( $dbh, $feat_id, $type, $value );
    }
    my $cv = get_cv_by_cvterm( $dbh, $type );
    if ( !defined($cv) ) {
        print STDERR "ERROR: cvterm $type not found in DB\n";
        return;
    }
    elsif ( $cv ne 'grp property type' ) {
        print STDERR "CHECK: cv $cv not grp property type\n";
    }

#    print STDERR "write_grpprop with rank and cv $feat_id, $value, $type, $pub, $rank, $cv\n";

    my $fp = create_ch_grpprop(
        doc    => $doc,
        grp_id => $feat_id,
        rank   => $rank,
        type   => $type,
        cvname => $cv,
        value  => $value
    );
    if ( $pub ne 'FBrf0000000' ) {
        my $fppub = create_ch_grpprop_pub( doc => $doc, pub_id => $pub );
        $fp->appendChild($fppub);
    }
    my $out = dom_toString($fp);
    $fp->dispose();
    return $out;
}

sub write_grpprop_cv {
    my $dbh     = shift;
    my $doc     = shift;
    my $feat_id = shift;
    my $value   = shift;
    my $type    = shift;
    my $pub     = shift;
    my $cv      = shift;
    my $rank    = shift;

    #print "value=$value\n";
    if ( !defined($rank) ) {
        $rank = get_max_grpprop_rank( $dbh, $feat_id, $type, $value );
    }

    if ( !defined($cv) ) {
        print STDERR "ERROR: need to pass in cv for cvterm $type \n";
        return;
    }

 #    print STDERR "write_grpprop_cv $feat_id, $type, $cv, $value $rank $pub\n";

    my $fp = create_ch_grpprop(
        doc     => $doc,
        grp_id  => $feat_id,
        rank    => $rank,
        type_id => create_ch_cvterm(
            doc  => $doc,
            cv   => $cv,
            name => $type,
        ),
        value => $value
    );
    if ( $pub ne 'FBrf0000000' ) {
        my $fppub = create_ch_grpprop_pub( doc => $doc, pub_id => $pub );
        $fp->appendChild($fppub);
    }
    my $out = dom_toString($fp);
    $fp->dispose();
    return $out;
}

sub get_max_grpprop_rank {
    my $dbh    = shift;
    my $unique = shift;
    my $type   = shift;
    my $value  = shift;
    my $rank;

    if ( exists( $fprank{$unique}{ $type . $value } ) ) {
        $rank = $fprank{$unique}{ $type . $value };
        return $rank;
    }
    $value =~ s/\\/\\\\/g;
    $value =~ s/\'/\\\'/g;
    $value =~ s/\|/\\\|/g;

    my $statement = "select max(rank) from grpprop, grp, cvterm,cv
  where grp.uniquename='$unique' and
  grpprop.grp_id=grp.grp_id and cvterm.name='$type'
	  and cv.name='grp property type' and cv.cv_id=cvterm.cv_id and
  cvterm.cvterm_id=grpprop.type_id and grpprop.value= E'$value';";

    #print STDERR $statement,"\n";
    my $fp_p = $dbh->prepare($statement);
    $fp_p->execute;
    $rank = $fp_p->fetchrow_array;
    $fp_p->finish;
    if ( defined($rank) ) {
        $fprank{$unique}{ $type . $value } = $rank;
        return $rank;
    }
    else {
        $statement =
"select max(rank) from grpprop, grp, cvterm,cv where grp.uniquename='$unique' and grpprop.grp_id = grp.grp_id and cvterm.name='$type' and cv.name='grp property type' and cv.cv_id=cvterm.cv_id and cvterm.cvterm_id=grpprop.type_id;";

        my $fr_r = $dbh->prepare($statement);
        $fr_r->execute;
        $rank = $fr_r->fetchrow_array;

        if ( exists( $fprank{$unique}{$type} ) ) {

            if ( defined($rank) && $rank >= $fprank{$unique}{$type} ) {
                $fprank{$unique}{$type} = $rank + 1;
            }
            else {
                $fprank{$unique}{$type}++;
            }

        }
        else {
            if ( !defined($rank) ) {
                $fprank{$unique}{$type} = 0;
            }
            else {
                $fprank{$unique}{$type} = $rank + 1;
            }
        }
        $fprank{$unique}{ $type . $value } = $fprank{$unique}{$type};
        return $fprank{$unique}{$type};
    }
}

sub get_cvterm_for_grp_cvterm {
    my $dbh    = shift;
    my $unique = shift;
    my $cv     = shift;
    my $pub    = shift;
    my @result = ();
    my $statement =
      "select cvt1.name, cvt1.is_obsolete from grp_cvterm fcv, grp f,
	cvterm cvt1,  cv, pub where fcv.grp_id=f.grp_id
		and f.uniquename='$unique' and fcv.cvterm_id=cvt1.cvterm_id and
	cvt1.cv_id=cv.cv_id and cv.name='$cv' and
	fcv.pub_id=pub.pub_id and pub.uniquename='$pub'";

    #print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $cvterm, $is_o ) = $nmm->fetchrow_array ) {
        push( @result, "$cvterm,,$is_o" );

    }
    $nmm->finish;
    return @result;
}

sub get_unique_key_for_grp_rel {

    my $dbh     = shift;
    my $subject = shift;
    my $object  = shift;
    my $unique  = shift;
    my $type    = shift;
    my $pub     = shift;
    my $f_type  = shift;
    my @ranks   = ();
    my $statement =
"select fr.grp_relationship_id, f2.name, f2.uniquename, f2.grp_id, rank from
  grp_relationship fr,  grp f1, grp f2,cvterm cvt1, cv
  cv1 ";

    if ( defined($pub) ) {
        $statement .= ',grp_relationship_pub, pub ';
    }
    $statement .= "where
  f1.uniquename='$unique' and fr.$subject=f1.grp_id and cvt1.name='$type'
	  and fr.$object=f2.grp_id
	and cv1.name='relationship type' and cvt1.cv_id=cv1.cv_id and
  cvt1.cvterm_id=fr.type_id ";
    if ( defined($pub) ) {
        $statement .= "	and
  grp_relationship_pub.grp_relationship_id=fr.grp_relationship_id	and pub.pub_id=grp_relationship_pub.pub_id and pub.uniquename='$pub';";
    }

    #	 print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $fr_id, $f_name, $f_unique, $f_id, $rank ) =
        $nmm->fetchrow_array )
    {

        if ( !defined($f_type)
            || ( defined($f_type) && $f_unique =~ /$f_type/ ) )
        {
          #	print STDERR 	"\nCHECK f_unique = $f_unique and f_type = $f_type\n";
            my $fr = {
                fr_id  => $fr_id,
                grp_id => $f_id,
                name   => $f_name,
                rank   => $rank
            };
            push( @ranks, $fr );
        }
    }
    $nmm->finish;
    return @ranks;

}

sub get_gr_pub_nums {
    my $dbh   = shift;
    my $fr_id = shift;

    my $statement = "select pub_id from grp_relationship_pub where
	grp_relationship_id=$fr_id ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub delete_grp_relationship {
    my $dbh     = shift;
    my $doc     = shift;
    my $t       = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;
    my $fr_type = shift;

    return &delete_table_relationship( $dbh, $doc, 'grp', $t, $subject,
        $object, $uname, $fr_type );

}

sub get_grp_ukeys_by_id {
    ####given id, search db for uniquename, genus, species and cvterm
    my $dbh  = shift;
    my $id   = shift;
    my $type = '';
    my $fbid = '';
    my $is   = '';

    #print STDERR "get_grp_ukeys_by_id $id\n";
    my $statement = "select uniquename, cvterm.name, grp.is_obsolete 
    from grp, cvterm where
    grp.grp_id=$id and cvterm.cvterm_id=grp.type_id;";

    #print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    ( $fbid, $type, $is ) = $nmm->fetchrow_array;

    #      if($is eq '1' && $type ne 'EST'){
    #   return '0';
    #    }

    return ( $fbid, $type );
}

sub delete_grp_relationship_pub {
    my $dbh     = shift;
    my $doc     = shift;
    my $t       = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;
    my $fr_type = shift;
    my $pub     = shift;
    return &delete_table_relationship_pub( $dbh, $doc, 'grp', $t, $subject,
        $object, $uname, $fr_type, $pub );
}

sub write_grp_relationship {
    my $dbh     = shift;
    my $doc     = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;
    my $name    = shift;
    my $fr_type = shift;
    my $pub     = shift;
    my $f_type  = shift;
    my $flag    = 0;
    my $grp;
    my $uniquename = '';
    my $type       = '';
    my $out        = '';

    print STDERR
"DEBUG: write_grp_relationship name $name uname $uniquename fr_type $fr_type pub $pub\n";

    if ( $name =~ /^FBgg/ ) {
        if ( $name =~ /temp/ ) {
            $grp = $name;
        }
        else {
            ( $uniquename, $type ) = get_grp_ukeys_by_uname( $dbh, $name );
            if ( $uniquename eq '0' || $uniquename eq '2' ) {
                print STDERR "ERROR: could not find $name in DB $uniquename\n";
            }
            else {
                print STDERR
"DEBUG: write_grp_relationship create_ch_grp when name is uniquename $uniquename $type\n";

                $grp = create_ch_grp(
                    doc        => $doc,
                    uniquename => $name,
                    type       => $type,
                    macro_id   => $name
                );
            }
        }
    }
    else {
        if ( exists( $fbids{$name} ) ) {
            $grp = $fbids{$name};
        }
        else {
            my $sname = $name;
            print STDERR
              "DEBUG: write_grp_relationship get_grp_ukeys_by_name $sname\n";
            ( $uniquename, $type ) = get_grp_ukeys_by_name( $dbh, $sname );
            if ( $uniquename eq '0' || $uniquename eq '2' ) {
                print STDERR "ERROR: could not find grp with name $name\n";

            }
            else {
                print STDERR
"DEBUG: write_grp_relationship create_ch_grp when name $sname is symbol -- $uniquename type $type\n";
                $grp = create_ch_grp(
                    doc        => $doc,
                    uniquename => $uniquename,
                    type       => $type,
                    macro_id   => $uniquename
                );
                $fbids{$name} = $uniquename;
            }
        }
    }
    validate_cvterm( $dbh, $fr_type, 'relationship type' );
    print STDERR
"DEBUG: create_ch_grp_relationship subject $uname object $uniquename rtype $fr_type\n";

    my $fr = create_ch_grp_relationship(
        doc      => $doc,
        $subject => $uname,
        $object  => $grp,
        rtype    => $fr_type,

    );
    if ( ref($grp) ) {
        print STDERR "DEBUG: ref(grp) create_ch_grp_pub \n";
        $grp->appendChild( create_ch_grp_pub( doc => $doc, pub_id => $pub ) );
    }
    else {
        print STDERR "DEBUG: no ref(grp) create_ch_grp_pub \n";
        $out = dom_toString(
            create_ch_grp_pub( doc => $doc, grp_id => $grp, pub_id => $pub ) );
    }
    print STDERR "DEBUG: create_ch_grp_relationship_pub $pub\n";

    my $frp = create_ch_grp_relationship_pub( doc => $doc, pub_id => $pub );
    $fr->appendChild($frp);

    #print STDERR dom_toString($fr);
    return ( $fr, $out );
}

sub get_grpmember_ukeys_by_grp {
    ####given grp name, search db for grp, type, rank
    my $dbh  = shift;
    my $name = shift;
    my $type = '';
    my $fbid = '';
    my $rank = 0;

    $name = convers($name);
    $name = decon($name);
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;

    print STDERR "get_grpmember_ukeys_by_grp $name\n";
    my $statement = "select grpmember.grp_id,cvterm.name,rank 
          from grpmember,cvterm,grp where grp.name= E'$name'
	  and cvterm.cvterm_id=grpmember.type_id and grp.is_obsolete='f'
	  and grp.is_analysis='f' and grp.grp_id = grpmember.grp_id 
          and grp.uniquename like 'FBgg%' ";

    #  print STDERR $statement;

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;

    #    print  STDERR "DEBUG id num=$id_num\n";
    if ( $id_num > 1 ) {
        print STDERR
          "Warning: duplicate names $name \n$statement\n exiting...\n";
        return '2';

        #exit(0);
    }
    elsif ( $id_num == 0 ) {
        print STDERR "Warning: could not get uniquename for $name\n";
        return '0';
    }
    elsif ( $id_num == 1 ) {
        ( $fbid, $type, $rank ) = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return ( $fbid, $type, $rank );
}

sub get_grpmember_ukeys_by_grp_type {
    ####given grp name and type search db for grp, type, rank
    my $dbh    = shift;
    my $name   = shift;
    my $type   = shift;
    my $fbid   = '';
    my $gmtype = '';
    my $rank   = 0;

    $name = convers($name);
    $name = decon($name);
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;

    print STDERR "get_grpmember_ukeys_by_grp_type $name\n";
    my $statement = "select grpmember.grp_id,cvterm.name,rank 
          from grpmember,cvterm,cv,grp where grp.name= E'$name'
	  and cvterm.cvterm_id=grpmember.type_id and cv.cv.name = 'grpmember type' 
          and cvterm.cv_id = cv.cv_id and cvterm.name = '$gmtype' and grp.is_obsolete='f'
	  and grp.is_analysis='f' and grp.grp_id = grpmember.grp_id 
          and grp.uniquename like 'FBgg%' ";

    #  print STDERR $statement;

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $id_num = $nmm->rows;

    #    print  STDERR "DEBUG id num=$id_num\n";
    if ( $id_num > 1 ) {
        print STDERR
          "Warning: duplicate names $name \n$statement\n exiting...\n";
        return '2';

        #exit(0);
    }
    elsif ( $id_num == 0 ) {
        print STDERR "Warning: could not get uniquename for $name\n";
        return '0';
    }
    elsif ( $id_num == 1 ) {
        ( $fbid, $gmtype, $rank ) = $nmm->fetchrow_array;
    }
    $nmm->finish;
    return ( $fbid, $gmtype, $rank );
}

sub get_unique_key_for_feature_grpmember {
    ####given feature uniquename, pub and grpmember type search db for feature_grpmember_id, grp, type, rank
    my $dbh   = shift;
    my $uname = shift;
    my $type  = shift;
    my $pub   = shift;

    my $fbid   = '';
    my @result = ();

    ###get feature_grpmember and feature_grpmember_pub
    my $fgr_state =
"select feature_grpmember.feature_grpmember_id, grp.uniquename, cvt.name as gmtype, cv.name as cv, rank from
		grp, grpmember, feature_grpmember, feature, cv, cvterm cvt, feature_grpmember_pub, pub where
		feature.feature_id=feature_grpmember.feature_id and
		feature.uniquename='$uname' and
		feature.is_analysis='f' and
		feature_grpmember.grpmember_id=grpmember.grpmember_id and grpmember.type_id = cvt.cvterm_id and 
                cvt.cv_id = cv.cv_id and cv.name = 'grpmember type' and cvt.name = 'grpmember_feature' and grpmember.grp_id = grp.grp_id and  
                feature_grpmember.feature_grpmember_id = feature_grpmember_pub.feature_grpmember_id and 
                feature_grpmember_pub.pub_id = pub.pub_id and pub.uniquename = '$pub'";
    my $f_g = $dbh->prepare($fgr_state);
    $f_g->execute;
    while ( my ( $fi_id, $gunique, $gmtype, $cv, $rank ) =
        $f_g->fetchrow_array )
    {
        my %tmp = ();
        $tmp{fp_id}     = $fi_id;
        $tmp{grp_uname} = $gunique;
        $tmp{type}      = $gmtype;
        $tmp{cv}        = $cv;
        $tmp{rank}      = $rank;
        push( @result, \%tmp );

    }
    return @result;
}

sub dissociate_with_pub_fromgrp {
    my $dbh    = shift;
    my $unique = shift;
    my $pub    = shift;
    my $out    = '';
    my $doc    = new XML::DOM::Document;

    ###get grp_synonym

    my $statement = "select synonym.name, synonym.synonym_sgml,
		cvterm.name
		from grp,synonym,grp_synonym,pub,cvterm where
		grp.uniquename='$unique' and grp.grp_id = 
		grp_synonym.grp_id  
		and grp_synonym.synonym_id=synonym.synonym_id and 
	        grp.is_analysis='f' and 
		grp_synonym.pub_id=pub.pub_id and pub.uniquename='$pub' and 
		cvterm.cvterm_id=synonym.type_id;";

    #print STDERR "$statement\n";

    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $name, $sgml, $type ) = $nmm->fetchrow_array ) {
        my $fs = create_ch_grp_synonym(
            doc        => $doc,
            grp_id     => $unique,
            synonym_id => create_ch_synonym(
                doc          => $doc,
                name         => $name,
                synonym_sgml => $sgml,
                type         => $type
            ),
            pub_id => $pub
        );
        $fs->setAttribute( 'op', 'delete' );
        $out .= dom_toString($fs);
    }
    $nmm->finish;

    #print STDERR "done synonym\n";
    ###get grp_cvterm
    my $c_state = "select cvterm.name, cv.name from
		grp_cvterm, cvterm, cv, pub, grp where
		grp.grp_id=grp_cvterm.grp_id and
		grp.uniquename='$unique' and
		grp.is_analysis='f' and
		grp_cvterm.cvterm_id=cvterm.cvterm_id and
		cvterm.cv_id=cv.cv_id and grp_cvterm.pub_id=pub.pub_id and
		pub.uniquename='$pub'";

    #print STDERR "$c_state\n";
    my $f_c = $dbh->prepare($c_state);
    $f_c->execute;
    while ( my ( $cvterm, $cv ) = $f_c->fetchrow_array ) {
        my $f = create_ch_grp_cvterm(
            doc    => $doc,
            name   => $cvterm,
            cv     => $cv,
            pub_id    => $pub,
            grp_id => $unique
        );

        $f->setAttribute( 'op', 'delete' );
        $out .= dom_toString($f);
    }
    $f_c->finish;

    #print STDERR "done cvterm\n";
    ###get grp_pub, grp_pubprop
    my $fp = "select pub.uniquename from grp, grp_pub,pub
		where grp.grp_id=grp_pub.grp_id and
		grp.is_analysis='f' and grp.uniquename='$unique' and
		pub.pub_id=grp_pub.pub_id and pub.uniquename='$pub';";
    my $f_p = $dbh->prepare($fp);
    $f_p->execute;
    while ( my ($fpub) = $f_p->fetchrow_array ) {
        my $feat_pub = create_ch_grp_pub(
            doc        => $doc,
            grp_id     => $unique,
            uniquename => $pub
        );
        $feat_pub->setAttribute( 'op', 'delete' );
        $out .= dom_toString($feat_pub);
    }
    $f_p->finish;

    #print STDERR "done pub\n";
    ###get grpprop,grpprop_pub
    $fp = "select grpprop.grpprop_id, cvterm.name,rank from
		grpprop,grpprop_pub, grp,cvterm,pub where
		grp.grp_id=grpprop.grp_id and
		grpprop.grpprop_id=grpprop_pub.grpprop_id and 
		grp.is_analysis='f' and grp.uniquename='$unique' and
		cvterm.cvterm_id=grpprop.type_id and grpprop_pub.pub_id =
		pub.pub_id and pub.uniquename='$pub';";

    #print STDERR "$fp\n";
    my $fp_nmm = $dbh->prepare($fp);
    $fp_nmm->execute;
    while ( my ( $fp_id, $type, $rank ) = $fp_nmm->fetchrow_array ) {
        my $num = get_grpprop_pub_nums( $dbh, $fp_id );
        if ( $num == 1 ) {
            $out .= delete_grpprop( $doc, $rank, $unique, $type );
        }
        elsif ( $num > 1 ) {
            $out .= delete_grpprop_pub( $doc, $rank, $unique, $type, $pub );
        }
    }
    $fp_nmm->finish;

    #print STDERR "done grpprop\n";
    ###get grp_relationship,fr_pub,frprop,frprop_pub
    my $fr_state =
        "select 'subject_id' as type, fr.grp_relationship_id, "
      . "f1.uniquename as subject_id, f2.name as name, f2.grp_id,"
      . " f2.uniquename as "
      . "object_id, cvterm.name as frtype,rank from "
      . "grp_relationship fr, grp_relationship_pub frp, "
      . "grp f1, grp f2, cvterm, pub where "
      . "frp.grp_relationship_id=fr.grp_relationship_id and "
      . "cvterm.cvterm_id=fr.type_id and frp.pub_id=pub.pub_id and "
      . "fr.subject_id=f1.grp_id and pub.uniquename='$pub' and "
      . "fr.object_id=f2.grp_id and f1.uniquename='$unique' "
      . "union "
      . "select 'object_id' as type, fr.grp_relationship_id, f2.uniquename as "
      . "subject_id, f1.name as name, f1.grp_id, f1.uniquename as "
      . "object_id, cvterm.name as frtype, rank from "
      . "grp_relationship fr, grp_relationship_pub frp,"
      . "grp f1, grp f2, cvterm, pub where "
      . "frp.grp_relationship_id=fr.grp_relationship_id and "
      . "cvterm.cvterm_id=fr.type_id and frp.pub_id=pub.pub_id and "
      . "fr.subject_id=f1.grp_id and pub.uniquename='$pub' and "
      . "fr.object_id=f2.grp_id and f2.uniquename='$unique'";

    #print STDERR "$fr_state\n";
    my $fr_nmm = $dbh->prepare($fr_state);
    $fr_nmm->execute;
    while ( my $fr_hash = $fr_nmm->fetchrow_hashref ) {

        if ( !defined( $fr_hash->{object_id} ) ) {
            last;
        }
        my $subject_id = 'subject_id';
        my $object_id  = 'object_id';
        my $fr_subject = $fr_hash->{object_id};
        if ( $fr_hash->{type} eq 'object_id' ) {
            $subject_id = 'object_id';
            $object_id  = 'subject_id';
        }

        if ( !exists( $fr_hash->{name} ) ) {
            print STDERR "ERROR: name is not found in disassociate_fncti\n";
        }

        my $num = get_gr_pub_nums( $dbh, $fr_hash->{grp_relationship_id} );
        if ( $num == 1 ) {
            $out .=
              delete_grp_relationship( $dbh, $doc, $fr_hash, $subject_id,
                $object_id, $unique, $fr_hash->{frtype} );
        }
        elsif ( $num > 1 ) {
            $out .=
              delete_grp_relationship_pub( $dbh, $doc, $fr_hash, $subject_id,
                $object_id, $unique, $fr_hash->{frtype}, $pub );
        }
    }
    $fr_nmm->finish;

    #print STDERR "done grp_relationship\n";
    ###get feature_grpmember and feature_grpmember_pub
    my $fgr_state =
"select feature_grpmember.feature_grpmember_id, feature.uniquename, cvt.name as type, cv.name as cv, rank from
		grp, grpmember, feature_grpmember, feature, cv, cvterm cvt, feature_grpmember_pub, pub where
		feature.feature_id=feature_grpmember.feature_id and
		grp.uniquename='$unique' and
		grp.is_analysis='f' and 
		feature_grpmember.grpmember_id=grpmember.grpmember_id and grpmember.type_id = cvt.cvterm_id and 
                cvt.cv_id = cv.cv_id and cv.name = 'grpmember type' and cvt.name = 'grpmember_feature' and grpmember.grp_id = grp.grp_id and  
                feature_grpmember.feature_grpmember_id = feature_grpmember_pub.feature_grpmember_id and 
                feature_grpmember_pub.pub_id = pub.pub_id and pub.uniquename = '$pub' ";

    #print STDERR "$fgr_state\n";
    my $f_g = $dbh->prepare($fgr_state);
    $f_g->execute;
    while ( my ( $fi_id, $funame, $type, $cv, $rank ) = $f_g->fetchrow_array ) {
        my $num = get_feature_grpmember_pub_nums( $dbh, $fi_id );
        if ( $num == 1 ) {
            $out .= delete_feature_grpmember( $dbh, $doc, $funame, $type, $cv,
                $unique, $rank );
        }
        elsif ( $num > 1 ) {
            $out .=
              delete_feature_grpmember_pub( $dbh, $doc, $funame, $type, $cv,
                $unique, $rank, $pub );
        }

    }
    $f_g->finish;

    print STDERR "done feature_grpmember and feature_grpmember_pub\n";

    $doc->dispose();
    return $out;
}

# used when GG3a = y obsolete the grp but delete grpmember and grp_relationship
sub delete_grp {
    my $dbh    = shift;
    my $doc    = shift;
    my $unique = shift;
    my $name   = shift;
    my $out    = '';

    print STDERR
"GG3a delete_grp: delete grpmember implies feature_grpmember/grp_relationship implies grp_relationship_pub & grp_relationshipprop for grp $unique $name\n";

    my ( $gmid, $gmtype, $gmrank ) = get_grpmember_ukeys_by_grp( $dbh, $name );
    if ( $gmid eq '0' || $gmid eq '2' ) {
        print STDERR
"WARN: could not find grpmember for grp $unique $name in the database\n";
    }
    else {
        print STDERR "GG3a check: delete grpmember for grp $unique $name\n";
        my $grpmember = create_ch_grpmember(
            doc     => $doc,
            grp_id  => $unique,
            type_id => create_ch_cvterm(
                doc  => $doc,
                cv   => 'grpmember type',
                name => 'grpmember_feature',
            ),
            rank => $gmrank
        );
        $grpmember->setAttribute( 'op', 'delete' );
        $out .= dom_toString($grpmember);
#####################
        ###get grp_relationship
        print STDERR
          "GG3a check: delete grp_relationship for grp $unique $name\n";
        my $fr_state =
            "select 'subject_id' as type, fr.grp_relationship_id, "
          . "f1.uniquename as subject_id, f2.name as name, f2.grp_id,"
          . " f2.uniquename as "
          . "object_id, cvterm.name as frtype,rank from "
          . "grp_relationship fr, "
          . "grp f1, grp f2, cvterm where "
          . "cvterm.cvterm_id=fr.type_id and "
          . "fr.subject_id=f1.grp_id and "
          . "fr.object_id=f2.grp_id and f1.uniquename='$unique' "
          . "union "
          . "select 'object_id' as type, fr.grp_relationship_id, f2.uniquename as "
          . "subject_id, f1.name as name, f1.grp_id, f1.uniquename as "
          . "object_id, cvterm.name as frtype, rank from "
          . "grp_relationship fr,"
          . "grp f1, grp f2, cvterm where "
          . "cvterm.cvterm_id=fr.type_id and "
          . "fr.subject_id=f1.grp_id and "
          . "fr.object_id=f2.grp_id and f2.uniquename='$unique'";

        print STDERR "$fr_state\n";
        my $fr_nmm = $dbh->prepare($fr_state);
        $fr_nmm->execute;
        while ( my $fr_hash = $fr_nmm->fetchrow_hashref ) {
            if ( !defined( $fr_hash->{object_id} ) ) {
                last;
            }
            my $subject_id = 'subject_id';
            my $object_id  = 'object_id';
            my $fr_subject = $fr_hash->{object_id};
            if ( $fr_hash->{type} eq 'object_id' ) {
                $subject_id = 'object_id';
                $object_id  = 'subject_id';
            }
            if ( !exists( $fr_hash->{name} ) ) {
                print STDERR
                  "WARN: name is not found in delete_grp grp_relationship\n";
            }
            else {
                $out .=
                  delete_grp_relationship( $dbh, $doc, $fr_hash, $subject_id,
                    $object_id, $unique, $fr_hash->{frtype} );
            }
        }
        $fr_nmm->finish;
        print STDERR "GG3a: done grp_relationship\n";
    }
    $doc->dispose();
    return $out;
}

####species####

sub validate_new_organism {
    my $dbh     = shift;
    my $genus   = shift;
    my $species = shift;

    $genus = convers($genus);
    $genus = decon($genus);
    $genus =~ s/\\/\\\\/g;
    $genus =~ s/\'/\\\'/g;

    $species = convers($species);
    $species = decon($species);
    $species =~ s/\\/\\\\/g;
    $species =~ s/\'/\\\'/g;

    my $statement =
"select genus, species from organism where genus= E'$genus' and species = E'$species'";
    print STDERR "validate_ new_organism $statement \n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $num = $nmm->rows;
    if ( $num != 0 ) {
        print STDERR
"ERROR: genus $genus species $species has been used in the Database\n";
        return 1;
    }
    $nmm->finish;
    return 0;
}

sub check_abbrev {
    my $dbh     = shift;
    my $genus   = shift;
    my $species = shift;

    $genus = convers($genus);
    $genus = decon($genus);
    $genus =~ s/\\/\\\\/g;
    $genus =~ s/\'/\\\'/g;

    $species = convers($species);
    $species = decon($species);
    $species =~ s/\\/\\\\/g;
    $species =~ s/\'/\\\'/g;

    my $statement =
"select abbreviation from organism where genus = E'$genus' and species = E'$species' and abbreviation is not null";
    print STDERR "check_abbrev $statement \n";
    my $n_sl = $dbh->prepare($statement);
    $n_sl->execute;
    my $num = $n_sl->rows;
    print STDERR "check_abbrev $num \n";

    if ( $num > 1 ) {
        print STDERR
"ERROR: More than 1 abbreviation genus $genus species $species . Let Harvdev know\n";
        return 2;
    }
    elsif ( $num == 0 ) {
        return 0;
    }
    elsif ( $num == 1 ) {
        return 1;
    }
}

sub check_common_name {
    my $dbh     = shift;
    my $genus   = shift;
    my $species = shift;
    my $name    = shift;
    my $val     = "";

    $name = convers($name);
    $name = decon($name);
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\\\'/g;

    $genus = convers($genus);
    $genus = decon($genus);
    $genus =~ s/\\/\\\\/g;
    $genus =~ s/\'/\\\'/g;

    $species = convers($species);
    $species = decon($species);
    $species =~ s/\\/\\\\/g;
    $species =~ s/\'/\\\'/g;

    my $statement =
"select common_name from organism where genus =E'$genus' and species = E'$species'";

    #    print STDERR "check_common_name $statement \n";
    my $n_sl = $dbh->prepare($statement);
    $n_sl->execute;
    my $num = $n_sl->rows;

    #    print STDERR "check_common_name num_rows $num\n";

    if ( $num > 1 ) {
        print STDERR
"ERROR: More than 1 common_name genus $genus species $species. Let Harvdev know\n";
        $val = "2";
    }
    elsif ( $num == 0 ) {
        $val = "0";
    }
    elsif ( $num == 1 ) {
        $val = $n_sl->fetchrow_array;
        if ( !defined($val) ) {

            #	    print STDERR "num = $num but val empty string\n";
            $val = "0";
        }
    }
    return $val;
    $n_sl->finish;

}

sub get_organism_ukeys {
    my $dbh     = shift;
    my $genus   = shift;
    my $species = shift;

    $genus = convers($genus);
    $genus = decon($genus);
    $genus =~ s/\\/\\\\/g;
    $genus =~ s/\'/\\\'/g;

    $species = convers($species);
    $species = decon($species);
    $species =~ s/\\/\\\\/g;
    $species =~ s/\'/\\\'/g;

    my $statement =
"select genus, species from organism where genus = E'$genus' and species = E'$species'";
    print STDERR "organism_ukeys $statement \n";
    my $n_sl = $dbh->prepare($statement);
    $n_sl->execute;
    my $num = $n_sl->rows;
    if ( $n_sl->rows > 1 ) {
        print STDERR
"ERROR: More than 1 organism genus $genus species $species. Let Harvdev know\n";
        return '2';
    }
    elsif ( $n_sl->rows == 0 ) {
        return '0';
    }
    my ( $g, $s ) = $n_sl->fetchrow_array;
    $n_sl->finish;
    return ( $g, $s );
}

sub check_sp6_organismprop {
    my $dbh     = shift;
    my $genus   = shift;
    my $species = shift;
    my $type    = shift;

    $genus = convers($genus);
    $genus = decon($genus);
    $genus =~ s/\\/\\\\/g;
    $genus =~ s/\'/\\\'/g;

    $species = convers($species);
    $species = decon($species);
    $species =~ s/\\/\\\\/g;
    $species =~ s/\'/\\\'/g;

    my $statement =
"select op.value from organism o, organismprop op, cv, cvterm cvt where o.genus = E'$genus' and o.species = E'species' and o.organism_id = op.organism_id and op.type_id = cvt.cvterm_id and cvt.cv_id = cv.cv_id and cvt.name = '$type'";
    print STDERR " check_sp6_organismprop $statement \n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    my $num = $nmm->rows;
    if ( $num == 0 ) {
        return $num;
    }
    elsif ( $num == 1 ) {
        return $num;
    }
    elsif ( $num > 1 ) {
        return $num;
    }
}

sub get_organism_dbxref_by_db {
    my $dbh     = shift;
    my $genus   = shift;
    my $species = shift;
    my $dbname  = shift;

    $genus = convers($genus);
    $genus = decon($genus);
    $genus =~ s/\\/\\\\/g;
    $genus =~ s/\'/\\\'/g;

    $species = convers($species);
    $species = decon($species);
    $species =~ s/\\/\\\\/g;
    $species =~ s/\'/\\\'/g;

    my $state =
"select db.name, dx.accession, dx.version from organism o, organism_dbxref odx, db, dbxref dx where db.name='$dbname' and dx.db_id=db.db_id and dx.dbxref_id = odx.dbxref_id and odx.organism_id = o.organism_id and o.genus = E'$genus' and o.species = E'$species'";
    print STDERR "get_organism_dbxref_by_db $state \n";
    my $nmm = $dbh->prepare($state);
    $nmm->execute;
    my $id_num = $nmm->rows;
    if ( $id_num == 1 ) {
        my ( $dname, $acc, $ver ) = $nmm->fetchrow_array;
        return ( $dname, $acc, $ver );
    }
    else {
        return ('0');
    }
}

sub get_num_organism_dbxref {
    my $dbh     = shift;
    my $genus   = shift;
    my $species = shift;
    my $dbname  = shift;
    my $acc     = shift;

    $genus = convers($genus);
    $genus = decon($genus);
    $genus =~ s/\\/\\\\/g;
    $genus =~ s/\'/\\\'/g;

    $species = convers($species);
    $species = decon($species);
    $species =~ s/\\/\\\\/g;
    $species =~ s/\'/\\\'/g;

    my $state =
"select db.name, dx.accession, dx.version from organism o, organism_dbxref odx, db, dbxref dx where db.name='$dbname' and dx.db_id=db.db_id and dx.accession = '$acc' and dx.dbxref_id = odx.dbxref_id and odx.organism_id = o.organism_id and o.genus = E'$genus' and o.species = E'$species' ";
    print STDERR "get_num_organism_dbxref $state \n";
    my $nmm = $dbh->prepare($state);
    $nmm->execute;
    my $id_num = $nmm->rows;
    return $id_num;
}

sub get_num_organismprop {
    my $dbh     = shift;
    my $genus   = shift;
    my $species = shift;
    my $type    = shift;
    my $pub     = shift;
    $genus = convers($genus);
    $genus = decon($genus);
    $genus =~ s/\\/\\\\/g;
    $genus =~ s/\'/\\\'/g;

    $species = convers($species);
    $species = decon($species);
    $species =~ s/\\/\\\\/g;
    $species =~ s/\'/\\\'/g;

    my $state =
"select op.organismprop_id from organism o, organismprop op, cv, cvterm cvt, organismprop_pub opp, pub p where o.genus = E'$genus' and o.species = E'$species' and o.organism_id = op.organism_id and op.type_id = cvt.cvterm_id and cvt.cv_id = cv.cv_id and cvt.name = '$type' and op.organismprop_id = opp.organismprop_id and opp.pub_id = p.pub_id and p.uniquename = '$pub' ";
    print STDERR "get_num_organismprop $state \n";
    my $nmm = $dbh->prepare($state);
    $nmm->execute;
    my $id_num = $nmm->rows;
    return $id_num;
}

sub delete_organismprop {
    my $doc     = shift;
    my $rank    = shift;
    my $genus   = shift;
    my $species = shift;
    my $type    = shift;
    my $cv      = shift;

    print STDERR "delete_organismprop\n";
    if ( !defined($cv) ) {
        $cv = 'property type';
    }
    my $fp = create_ch_organismprop(
        doc         => $doc,
        organism_id => create_ch_organism(
            doc     => $doc,
            genus   => $genus,
            species => $species,
        ),
        cvname => $cv,
        type   => $type,
        rank   => $rank,
    );
    $fp->setAttribute( 'op', 'delete' );

    my $out = dom_toString($fp);
    $fp->dispose();
    return $out;
}

sub delete_organismprop_pub {
    my $doc     = shift;
    my $rank    = shift;
    my $genus   = shift;
    my $species = shift;
    my $type    = shift;
    my $pub     = shift;
    print STDERR "CHECK: in delete_organismprop_pub\n";
    my $fp = create_ch_organismprop(
        doc     => $doc,
        genus   => $genus,
        species => $species,
        rank    => $rank,
        type    => $type
    );
    my $fpp = create_ch_organismprop_pub( doc => $doc, pub_id => $pub );
    $fpp->setAttribute( 'op', 'delete' );

    $fp->appendChild($fpp);
    my $out = dom_toString($fp);

    $frnum{ $genus . '_' . $species }{$type}{$rank}++;
    $fp->dispose();
    print STDERR "CHECK: leaving delete_organismprop_pub\n";

    return $out;
}

sub write_organismprop {
    my $dbh     = shift;
    my $doc     = shift;
    my $genus   = shift;
    my $species = shift;
    my $value   = shift;
    my $type    = shift;
    my $pub     = shift;
    my $rank    = shift;

    print STDERR "write_organismprop\n";
    if ( !defined($rank) ) {
        $rank =
          get_max_organismprop_rank( $dbh, $genus, $species, $type, $value );
    }
    my $cv = get_cv_by_cvterm( $dbh, $type );
    if ( !defined($cv) ) {
        print STDERR "ERROR: cvterm $type not found in DB\n";
        return;
    }
    elsif ( $cv ne 'property type' ) {

        #        print STDERR "CHECK: cv $cv not property type\n";
    }

    my $fp = create_ch_organismprop(
        doc         => $doc,
        organism_id => create_ch_organism(
            doc     => $doc,
            genus   => $genus,
            species => $species,
        ),
        cvname => $cv,
        type   => $type,
        value  => $value,
        rank   => $rank,
    );
    my $fppub = create_ch_organismprop_pub( doc => $doc, pub_id => $pub );
    $fp->appendChild($fppub);
    my $out = dom_toString($fp);
    $fp->dispose();
    return $out;
}

sub get_max_organismprop_rank {
    my $dbh     = shift;
    my $genus   = shift;
    my $species = shift;
    my $type    = shift;
    my $value   = shift;
    my $rank;

    if ( exists( $fprank{ $genus . '_' . $species }{ $type . $value } ) ) {
        $rank = $fprank{ $genus . '_' . $species }{ $type . $value };
        return $rank;
    }
    $value =~ s/\\/\\\\/g;
    $value =~ s/\'/\\\'/g;
    $value =~ s/\|/\\\|/g;
    $value = conversupdown($value);

    $genus = convers($genus);
    $genus = decon($genus);
    $genus =~ s/\\/\\\\/g;
    $genus =~ s/\'/\\\'/g;

    $species = convers($species);
    $species = decon($species);
    $species =~ s/\\/\\\\/g;
    $species =~ s/\'/\\\'/g;

    my $statement = "select rank from organismprop, organism, cvterm,cv
  where organism.genus= E'$genus' and organism.species= E'$species' and
  organismprop.organism_id=organism.organism_id and cvterm.name='$type'
          and cv.name='property type' and cv.cv_id=cvterm.cv_id and
  cvterm.cvterm_id=organismprop.type_id and organismprop.value= E'$value';";

    #print STDERR $statement,"\n";
    my $fp_p = $dbh->prepare($statement);
    $fp_p->execute;
    $rank = $fp_p->fetchrow_array;
    $fp_p->finish;
    if ( defined($rank) ) {
        $fprank{ $genus . '_' . $species }{ $type . $value } = $rank;
        return $rank;
    }
    else {
        $statement =
"select max(rank) from organismprop, organism, cvterm,cv where organism.genus= E'$genus' and organism.species= E'$species' and organismprop.organism_id=organism.organism_id and cvterm.name='$type' and (cv.name='property type' or cv.name='annotation property type')  and cv.cv_id=cvterm.cv_id and cvterm.cvterm_id=organismprop.type_id;";
        my $fr_r = $dbh->prepare($statement);
        $fr_r->execute;
        $rank = $fr_r->fetchrow_array;

        if ( exists( $fprank{ $genus . '_' . $species }{$type} ) ) {

            if ( defined($rank)
                && $rank >= $fprank{ $genus . '_' . $species }{$type} )
            {
                $fprank{ $genus . '_' . $species }{$type} = $rank + 1;
            }
            else {
                $fprank{ $genus . '_' . $species }{$type}++;
            }

        }
        else {
            if ( !defined($rank) ) {
                $fprank{ $genus . '_' . $species }{$type} = 0;
            }
            else {
                $fprank{ $genus . '_' . $species }{$type} = $rank + 1;
            }
        }
        $fprank{ $genus . '_' . $species }{ $type . $value } =
          $fprank{ $genus . '_' . $species }{$type};
        return $fprank{ $genus . '_' . $species }{$type};
    }
}

sub get_organismprop_pub_nums {
    my $dbh   = shift;
    my $fr_id = shift;

    my $statement = "select pub_id from organismprop_pub where
        organismprop_id=$fr_id ";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    my $num = $nmm->rows;
    $nmm->finish;
    return $num;
}

sub get_unique_key_for_organismprop {
    my $dbh     = shift;
    my $genus   = shift;
    my $species = shift;
    my $type    = shift;
    my $pub     = shift;
    my $cv      = shift;
    if ( !defined($cv) ) {
        $cv = 'property type';
    }
    $genus = convers($genus);
    $genus = decon($genus);
    $genus =~ s/\\/\\\\/g;
    $genus =~ s/\'/\\\'/g;

    $species = convers($species);
    $species = decon($species);
    $species =~ s/\\/\\\\/g;
    $species =~ s/\'/\\\'/g;

    my @ranks = ();
    my $statement =
"select organismprop.organismprop_id, organismprop.rank from organismprop, organism,cvterm,organismprop_pub, pub,cv where organism.genus= E'$genus' and organism.species= E'$species' and organismprop.organism_id=organism.organism_id and cvterm.name='$type' and cv.name='$cv' and cvterm.cv_id=cv.cv_id and cvterm.cvterm_id=organismprop.type_id and organismprop_pub.organismprop_id=organismprop.organismprop_id and pub.pub_id=organismprop_pub.pub_id and pub.uniquename='$pub';";

    # print STDERR "$statement\n";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my ( $fp_id, $rank ) = $nmm->fetchrow_array ) {
        my $fp = {
            fp_id => $fp_id,
            rank  => $rank,
        };
        push( @ranks, $fp );
    }
    $nmm->finish;
    return @ranks;
}

###methods for new metatdata (Library)

sub check_library_synonym_for_title {
    my $dbh  = shift;
    my $fbid = shift;
    my $type = shift;
    my $num  = 0;

    my $statement = "select * from
        library_synonym, library, synonym, cvterm where 
        library_synonym.library_id=library.library_id and 
        synonym.synonym_id=library_synonym.synonym_id and 
        cvterm.cvterm_id=synonym.type_id and library.uniquename='$fbid' and 
        cvterm.name='$type'";

    #    print $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    $num = $nmm->rows;
    $nmm->finish;

    #    print STDERR "CHECK:$fbid library_synonym fullname $num\n";
    return $num;
}

sub get_cvterm_by_webcv {
    my $dbh   = shift;
    my $name  = shift;
    my $value = shift;

    #FlyBase miscellaneous CV
    ( my $cvtid ) = $dbh->selectrow_array(
        sprintf(
"SELECT cvt.cvterm_id FROM cvterm cvt, cv, cvtermprop cvp, cvterm cvt2
      WHERE  cvt.name = '$name' and cvt.cv_id = cv.cv_id
        and  cv.name = 'FlyBase miscellaneous CV' and cvt.is_obsolete = 0 and cvt.cvterm_id = cvp.cvterm_id  
        and cvp.type_id = cvt2.cvterm_id and cvt2.name = 'webcv' and cvp.value = '$value'"
        )
    );
    print "Can't find cvterm name $name for webcv value $value\n"
      and return
      unless $cvtid;
    return $cvtid;
}

sub get_webcv_for_cvterm_cv {
    my $dbh  = shift;
    my $term = shift;
    my $cv   = shift;

    #FlyBase miscellaneous CV but do not assume
    ( my $value ) = $dbh->selectrow_array(
        sprintf(
            "SELECT cvp.value FROM cvterm cvt, cv, cvtermprop cvp, cvterm cvt2
      WHERE  cvt.name = '$term' and cvt.cv_id = cv.cv_id
        and  cv.name = '$cv' and cvt.is_obsolete = 0 and cvt.cvterm_id = cvp.cvterm_id  
        and cvp.type_id = cvt2.cvterm_id and cvt2.name = 'webcv'"
        )
    );
    print "Can't find  webcv cvtermprop.value for $cv $term\n"
      and return
      unless $value;
    return $value;
}

sub get_cvterm_for_library_cvterm_withprop {
    my $dbh       = shift;
    my $unique    = shift;
    my $cv        = shift;
    my $pub       = shift;
    my $proptype  = shift;
    my @result    = ();
    my $statement = "select cvt1.name from library_cvterm fcv, library f,
	cvterm cvt1, cvterm cvt2, cv, pub, library_cvtermprop fcvp where fcv.library_id=f.library_id
		and f.uniquename='$unique' and fcv.cvterm_id=cvt1.cvterm_id and
	cvt1.cv_id=cv.cv_id and cv.name='$cv' and
	cvt2.cvterm_id=fcvp.type_id and cvt2.name='$proptype' and
	fcvp.library_cvterm_id=fcv.library_cvterm_id and
	fcv.pub_id=pub.pub_id and pub.uniquename='$pub'";
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;

    while ( my $cvterm = $nmm->fetchrow_array ) {
        push( @result, $cvterm );

    }
    $nmm->finish;
    return @result;
}

sub get_unique_key_for_lr_object {

    my $dbh     = shift;
    my $subject = shift;
    my $object  = shift;
    my $unique  = shift;
    my $olib    = shift;
    my $pub     = shift;
    my @ranks   = ();
    my $statement =
"select fr.library_relationship_id, f2.name, f2.uniquename, f2.library_id, cvt.name from 
  library_relationship fr,  library f1, library f2,cvterm cvt, cv ";

    if ( defined($pub) ) {
        $statement .= ',library_relationship_pub, pub ';
    }
    $statement .= "where 
  f1.uniquename='$unique' and fr.$subject=f1.library_id 
  and fr.$object=f2.library_id and f2.name = '$olib'
	and cv.name='relationship type' and cvt.cv_id=cv.cv_id and cvt.cvterm_id=fr.type_id ";
    if ( defined($pub) ) {
        $statement .= "	and
  library_relationship_pub.library_relationship_id=fr.library_relationship_id and pub.pub_id=library_relationship_pub.pub_id and pub.uniquename='$pub';";
    }

    #	 print STDERR $statement;
    my $nmm = $dbh->prepare($statement);
    $nmm->execute;
    while ( my ( $fr_id, $f_name, $f_unique, $f_id, $fr_term ) =
        $nmm->fetchrow_array )
    {
        my $fr = {
            fr_id      => $fr_id,
            library_id => $f_id,
            name       => $f_name,
            term       => $fr_term,
        };
        push( @ranks, $fr );
    }
    $nmm->finish;
    return @ranks;

}

sub delete_library_relationship_alltype {
    my $dbh     = shift;
    my $doc     = shift;
    my $t       = shift;
    my $subject = shift;
    my $object  = shift;
    my $uname   = shift;

    #    my $fr_type = shift;
    my %fr_h = %$t;
    my $out  = '';
    my ( $uniquename, $genus, $species, $type, $is_obsolete, $cv_name ) = '';

    my $get_ukey_function = 'get_lib_ukeys_by_id';
    ( $uniquename, $genus, $species, $type, $is_obsolete ) =
      &$get_ukey_function( $dbh, $fr_h{library_id} );
    my $create_function = "create_ch_library";
    my $feature         = &$create_function(
        doc        => $doc,
        uniquename => $uniquename,
        type       => $type,
        genus      => $genus,
        species    => $species,
        macro_id   => $uniquename
    );

    if ( defined($is_obsolete) && $is_obsolete eq 'f' ) {
        $fbids{ $fr_h{name} } = $uniquename;
    }
    my $create_fr_function = "create_ch_library_relationship";
    my $fr                 = &$create_fr_function(
        doc      => $doc,
        $subject => $uname,
        $object  => $feature,
        rtype    => $fr_h{term},

    );
    $fr->setAttribute( 'op', 'delete' );
    $out = dom_toString($fr);
    $fr->dispose();

    return $out;
}

sub get_organism_for_organism_library {
    my $dbh     = shift;
    my $library = shift;
    my @result  = ();
    my $fq      = $dbh->prepare(
        sprintf(
"SELECT o.genus,o.species FROM organism_library ol, organism o, library l where ol.organism_id = o.organism_id and l.library_id=ol.library_id and l.uniquename = ? "
        )
    );
    $fq->bind_param( 1, $library );
    $fq->execute;
    while ( my ( $genus, $species ) = $fq->fetchrow_array ) {
        push @result, $genus . '_' . $species;
    }
    $fq->finish;
    return (@result);

}

sub get_feature_for_library_feature {
    my $dbh     = shift;
    my $library = shift;
    my $feat    = shift;
    my $fr_type = shift;
    my $cname   = shift;
    my @result  = ();
    my $fq      = $dbh->prepare(
        sprintf(
"SELECT f.uniquename FROM library_feature lf, feature f, library l, library_featureprop lfp, cvterm cvt, cv  
where lf.feature_id=f.feature_id and l.library_id=lf.library_id and l.uniquename =? and f.uniquename = ? and f.is_obsolete = false and f.is_analysis = false and lfp.library_feature_id = lf.library_feature_id and lfp.type_id = cvt.cvterm_id and cvt.cv_id = cv.cv_id and cvt.name = ? and cv.name = ?"
        )
    );
    $fq->bind_param( 1, $library );
    $fq->bind_param( 2, $feat );
    $fq->bind_param( 3, $fr_type );
    $fq->bind_param( 4, $cname );
    $fq->execute;
    while ( my ($fu) = $fq->fetchrow_array ) {
        push @result, $fu;
    }
    $fq->finish;
    return (@result);
}

################################

sub toutf {
    my ($string) = $_[0];

    # $string=~s/\(/\\\(/g;
    # $string=~s/\)/\\\)/g;
    $string =~ s/&cap\;/\x{2229}/g;    # Intersection character for split-Gal4 combinations.
    $string =~ s/&agr\;/\x{03B1}/g;
    $string =~ s/&Agr\;/\x{0391}/g;
    $string =~ s/&bgr\;/\x{03B2}/g;
    $string =~ s/&Bgr\;/\x{0392}/g;
    $string =~ s/&ggr\;/\x{03B3}/g;
    $string =~ s/&Ggr\;/\x{0393}/g;
    $string =~ s/&dgr\;/\x{03B4}/g;
    $string =~ s/&Dgr\;/\x{0394}/g;
    $string =~ s/&egr\;/\x{03B5}/g;
    $string =~ s/&Egr\;/\x{0395}/g;
    $string =~ s/&zgr\;/\x{03B6}/g;
    $string =~ s/&Zgr\;/\x{0396}/g;
    $string =~ s/&eegr\;/\x{03B7}/g;
    $string =~ s/&EEgr\;/\x{0397}/g;
    $string =~ s/&thgr\;/\x{03B8}/g;
    $string =~ s/&THgr\;/\x{0398}/g;
    $string =~ s/&igr\;/\x{03B9}/g;
    $string =~ s/&Igr\;/\x{0399}/g;
    $string =~ s/&kgr\;/\x{03BA}/g;
    $string =~ s/&Kgr\;/\x{039A}/g;
    $string =~ s/&lgr\;/\x{03BB}/g;
    $string =~ s/&Lgr\;/\x{039B}/g;
    $string =~ s/&mgr\;/\x{03BC}/g;
    $string =~ s/&Mgr\;/\x{039C}/g;
    $string =~ s/&ngr\;/\x{03BD}/g;
    $string =~ s/&Ngr\;/\x{039D}/g;
    $string =~ s/&xgr\;/\x{03BE}/g;
    $string =~ s/&Xgr\;/\x{039E}/g;
    $string =~ s/&ogr\;/\x{03BF}/g;
    $string =~ s/&Ogr\;/\x{039F}/g;
    $string =~ s/&pgr\;/\x{03C0}/g;
    $string =~ s/&Pgr\;/\x{03A0}/g;
    $string =~ s/&rgr\;/\x{03C1}/g;
    $string =~ s/&Rgr\;/\x{03A1}/g;
    $string =~ s/&sgr\;/\x{03C3}/g;
    $string =~ s/&Sgr\;/\x{03A3}/g;
    $string =~ s/&tgr\;/\x{03C4}/g;
    $string =~ s/&Tgr\;/\x{03A4}/g;
    $string =~ s/&ugr\;/\x{03C5}/g;
    $string =~ s/&Ugr\;/\x{03A5}/g;
    $string =~ s/&phgr\;/\x{03C6}/g;
    $string =~ s/&PHgr\;/\x{03A6}/g;
    $string =~ s/&khgr\;/\x{03C7}/g;
    $string =~ s/&KHgr\;/\x{03A7}/g;
    $string =~ s/&psgr\;/\x{03C8}/g;
    $string =~ s/&PSgr\;/\x{03A8}/g;
    $string =~ s/&ohgr\;/\x{03C9}/g;
    $string =~ s/&OHgr\;/\x{03A9}/g;

    $string =~ s/\]\]/\<\/down\>/g;
    $string =~ s/\[\[/\<down\>/g;
    $string =~ s/\[/\<up\>/g;
    $string =~ s/\]/\<\/up\>/g;
    $string =~ s/BEFORE/\[/g;
    $string =~ s/AFTER/\]/g;

    return ($string);

}

sub utftog {
    my ($string) = $_[0];

    #print STDERR "string=$string\n";
    $string =~ s/[\x{2229}]/&cap;/g;    # Intersection character for split-Gal4 combinations
    $string =~ s/[\x{03B1}]/&agr;/g;
    $string =~ s/[\x{0391}]/&Agr;/g;
    $string =~ s/[\x{03B2}]/&bgr;/g;
    $string =~ s/[\x{0392}]/&Bgr;/g;
    $string =~ s/[\x{03B3}]/&ggr;/g;
    $string =~ s/[\x{0393}]/&Ggr;/g;
    $string =~ s/[\x{03B4}]/&dgr;/g;
    $string =~ s/[\x{0394}]/&Dgr;/g;
    $string =~ s/[\x{03B5}]/&egr;/g;
    $string =~ s/[\x{0395}]/&Egr;/g;
    $string =~ s/[\x{03B6}]/&zgr;/g;
    $string =~ s/[\x{0396}]/&Zgr;/g;
    $string =~ s/[\x{03B7}]/&eegr;/g;
    $string =~ s/[\x{0397}]/&EEgr;/g;
    $string =~ s/[\x{03B8}]/&thgr;/g;
    $string =~ s/[\x{0398}]/&THgr;/g;
    $string =~ s/[\x{03B9}]/&igr;/g;
    $string =~ s/[\x{0399}]/&Igr;/g;
    $string =~ s/[\x{03BA}]/&kgr;/g;
    $string =~ s/[\x{039A}]/&Kgr;/g;
    $string =~ s/[\x{03BB}]/&lgr;/g;
    $string =~ s/[\x{039B}]/&Lgr;/g;
    $string =~ s/[\x{03BC}]/&mgr;/g;
    $string =~ s/[\x{039C}]/&Mgr;/g;
    $string =~ s/[\x{03BD}]/&ngr;/g;
    $string =~ s/[\x{039D}]/&Ngr;/g;
    $string =~ s/[\x{03BE}]/&xgr;/g;
    $string =~ s/[\x{039E}]/&Xgr;/g;
    $string =~ s/[\x{03BF}]/&ogr;/g;
    $string =~ s/[\x{039F}]/&Ogr;/g;
    $string =~ s/[\x{03C0}]/&pgr;/g;
    $string =~ s/[\x{03A0}]/&Pgr;/g;
    $string =~ s/[\x{03C1}]/&rgr;/g;
    $string =~ s/[\x{03A1}]/&Rgr;/g;
    $string =~ s/[\x{03C3}]/&sgr;/g;
    $string =~ s/[\x{03A3}]/&Sgr;/g;
    $string =~ s/[\x{03C4}]/&tgr;/g;
    $string =~ s/[\x{03A4}]/&Tgr;/g;
    $string =~ s/[\x{03C5}]/&ugr;/g;
    $string =~ s/[\x{03A5}]/&Ugr;/g;
    $string =~ s/[\x{03C6}]/&phgr;/g;
    $string =~ s/[\x{03A6}]/&PHgr;/g;
    $string =~ s/[\x{03C7}]/&khgr;/g;
    $string =~ s/[\x{03A7}]/&KHgr;/g;
    $string =~ s/[\x{03C8}]/&psgr;/g;
    $string =~ s/[\x{03A8}]/&PSgr;/g;
    $string =~ s/[\x{03C9}]/&ohgr;/g;
    $string =~ s/[\x{03A9}]/&OHgr;/g;
    $string =~ s/\<\/down\>/\]\]/g;
    $string =~ s/\<down\>/\[\[/g;
    $string =~ s/\<up\>/\[/g;
    $string =~ s/\<\/up\>/\]/g;

    #  print STDERR "string=$string\n";
    return ($string);
}

sub recon {

    # Converts symbol_plain symbols to SGML format (modified from conv_greeks)

    my ($string) = $_[0];

    $string =~ s/INTERSECTION/&cap\;/g;    # Intersection character for split-Gal4 combinations.
    $string =~ s/alpha/&agr\;/g;
    $string =~ s/Alpha/&Agr\;/g;
    $string =~ s/beta/&bgr\;/g;
    $string =~ s/Beta/&Bgr\;/g;
    $string =~ s/gamma/&ggr\;/g;
    $string =~ s/Gamma/&Ggr\;/g;
    $string =~ s/Beta/&Bgr\;/g;
    $string =~ s/gamma/&ggr\;/g;
    $string =~ s/Gamma/&Ggr\;/g;
    $string =~ s/delta/&dgr\;/g;
    $string =~ s/Delta/&Dgr\;/g;
    $string =~ s/epsilon/&egr\;/g;
    $string =~ s/Epsilon/&Egr\;/g;
    $string =~ s/zeta/&zgr\;/g;
    $string =~ s/Zeta/&Zgr\;/g;
    $string =~ s/(\W)eta(\W)/$1&eegr\;$2/g;
    $string =~ s/Eta/&EEgr\;/g;
    $string =~ s/theta/&thgr\;/g;
    $string =~ s/Theta/&THgr\;/g;
    $string =~ s/iota/&igr\;/g;
    $string =~ s/Iota/&Igr\;/g;
    $string =~ s/kappa/&kgr\;/g;
    $string =~ s/Kappa/&Kgr\;/g;
    $string =~ s/lambda/&lgr\;/g;
    $string =~ s/Lambda/&Lgr\;/g;
    $string =~ s/(\W)mu(\W)/$1&mgr\;$2/g;
    $string =~ s/(\W)Mu(\W)/$1&Mgr\;$2/g;
    $string =~ s/(\W)nu(\W)/$1&ngr\;$2/g;
    $string =~ s/(\W)Nu(\W)/$1&Ngr\;$2/g;
    $string =~ s/(\W)xi(\W)/$1&xgr\;$2/g;
    $string =~ s/(\W)Xi(\W)/$1&Xgr\;$2/g;
    $string =~ s/omicron/&ogr\;/g;
    $string =~ s/Omicron/&Ogr\;/g;
    $string =~ s/(\W)pi(\W)/$1&pgr\;$2/g;
    $string =~ s/Pi/&Pgr\;/g;
    $string =~ s/rho/&rgr\;/g;
    $string =~ s/Rho/&Rgr\;/g;
    $string =~ s/sigma/&sgr\;/g;
    $string =~ s/Sigma/&Sgr\;/g;
    $string =~ s/(\W)tau(\W)/&tgr\;/g;
    $string =~ s/Tau/&Tgr\;/g;
    $string =~ s/upsilon/&ugr\;/g;
    $string =~ s/Upsilon/&Ugr\;/g;
    $string =~ s/phi/&phgr\;/g;
    $string =~ s/Phi/&PHgr\;/g;
    $string =~ s/(\W)chi(\W)/$1&khgr\;$2/g;
    $string =~ s/Chi/&KHgr\;/g;
    $string =~ s/psi/&psgr\;/g;
    $string =~ s/Psi/&PSgr\;/g;
    $string =~ s/omega/&ohgr\;/g;
    $string =~ s/Omega/&OHgr\;/g;
    $string =~ s/\]\]/\<\/down\>/g;
    $string =~ s/\[\[/\<down\>/g;
    $string =~ s/\[/\<up\>/g;
    $string =~ s/\]/\<\/up\>/g;

    return ($string);
}

sub decon {

# Converts SGML-formatted symbols to 'symbol_plain' format (modified from conv_greeks)

    my $string = $_[0];

    $string =~ s/&cap\;/INTERSECTION/g;    # Intersection character for split-Gal4 combinations.
    $string =~ s/&agr\;/alpha/g;
    $string =~ s/&Agr\;/Alpha/g;
    $string =~ s/&bgr\;/beta/g;
    $string =~ s/&Bgr\;/Beta/g;
    $string =~ s/&ggr\;/gamma/g;
    $string =~ s/&Ggr\;/Gamma/g;
    $string =~ s/&dgr\;/delta/g;
    $string =~ s/&Dgr\;/Delta/g;
    $string =~ s/&egr\;/epsilon/g;
    $string =~ s/&Egr\;/Epsilon/g;
    $string =~ s/&zgr\;/zeta/g;
    $string =~ s/&Zgr\;/Zeta/g;
    $string =~ s/&eegr\;/eta/g;
    $string =~ s/&EEgr\;/Eta/g;
    $string =~ s/&thgr\;/theta/g;
    $string =~ s/&THgr\;/Theta/g;
    $string =~ s/&igr\;/iota/g;
    $string =~ s/&Igr\;/Iota/g;
    $string =~ s/&kgr\;/kappa/g;
    $string =~ s/&Kgr\;/Kappa/g;
    $string =~ s/&lgr\;/lambda/g;
    $string =~ s/&Lgr\;/Lambda/g;
    $string =~ s/&mgr\;/mu/g;
    $string =~ s/&Mgr\;/Mu/g;
    $string =~ s/&ngr\;/nu/g;
    $string =~ s/&Ngr\;/Nu/g;
    $string =~ s/&xgr\;/xi/g;
    $string =~ s/&Xgr\;/Xi/g;
    $string =~ s/&ogr\;/omicron/g;
    $string =~ s/&Ogr\;/Omicron/g;
    $string =~ s/&pgr\;/pi/g;
    $string =~ s/&Pgr\;/Pi/g;
    $string =~ s/&rgr\;/rho/g;
    $string =~ s/&Rgr\;/Rho/g;
    $string =~ s/&sgr\;/sigma/g;
    $string =~ s/&Sgr\;/Sigma/g;
    $string =~ s/&tgr\;/tau/g;
    $string =~ s/&Tgr\;/Tau/g;
    $string =~ s/&ugr\;/upsilon/g;
    $string =~ s/&Ugr\;/Upsilon/g;
    $string =~ s/&phgr\;/phi/g;
    $string =~ s/&PHgr\;/Phi/g;
    $string =~ s/&khgr\;/chi/g;
    $string =~ s/&KHgr\;/Chi/g;
    $string =~ s/&psgr\;/psi/g;
    $string =~ s/&PSgr\;/Psi/g;
    $string =~ s/&ohgr\;/omega/g;
    $string =~ s/&OHgr\;/Omega/g;
    $string =~ s/\<\/down\>/\]\]/g;
    $string =~ s/\<down\>/\[\[/g;
    $string =~ s/\<up\>/\[/g;
    $string =~ s/\<\/up\>/\]/g;
    $string =~ s/BEFORE/\[/g;
    $string =~ s/AFTER/\]/g;

    return ($string);
}

sub convers {

    # Does necessary conversions on all input strings

    my $string = $_[0];

    $string =~ s/\$a/\&agr\;/g;
    $string =~ s/\$A/\&Agr\;/g;
    $string =~ s/\$b/\&bgr\;/g;
    $string =~ s/\$B/\&Bgr\;/g;
    $string =~ s/\$g/\&ggr\;/g;
    $string =~ s/\$G/\&Ggr\;/g;
    $string =~ s/\$d/\&dgr\;/g;
    $string =~ s/\$D/\&Dgr\;/g;
    $string =~ s/\$ee/\&eegr\;/g;
    $string =~ s/\$EE/\&EEgr\;/g;
    $string =~ s/\$e/\&egr\;/g;
    $string =~ s/\$E/\&Egr\;/g;
    $string =~ s/\$i/\&igr\;/g;
    $string =~ s/\$I/\&Igr\;/g;
    $string =~ s/\$kh/\&khgr\;/g;
    $string =~ s/\$KH/\&KHgr\;/g;
    $string =~ s/\$k/\&kgr\;/g;
    $string =~ s/\$K/\&Kgr\;/g;
    $string =~ s/\$l/\&lgr\;/g;
    $string =~ s/\$L/\&Lgr\;/g;
    $string =~ s/\$m/\&mgr\;/g;
    $string =~ s/\$M/\&Mgr\;/g;
    $string =~ s/\$n/\&ngr\;/g;
    $string =~ s/\$N/\&Ngr\;/g;
    $string =~ s/\$oh/\&ohgr\;/g;
    $string =~ s/\$OH/\&OHgr\;/g;
    $string =~ s/\$o/\&ogr\;/g;
    $string =~ s/\$O/\&Ogr\;/g;
    $string =~ s/\$ph/\&phgr\;/g;
    $string =~ s/\$PH/\&PHgr\;/g;
    $string =~ s/\$ps/\&psgr\;/g;
    $string =~ s/\$PS/\&PSgr\;/g;
    $string =~ s/\$p/\&pgr\;/g;
    $string =~ s/\$P/\&Pgr\;/g;
    $string =~ s/\$r/\&rgr\;/g;
    $string =~ s/\$R/\&Rgr\;/g;
    $string =~ s/\$s/\&sgr\;/g;
    $string =~ s/\$S/\&Sgr\;/g;
    $string =~ s/\$th/\&thgr\;/g;
    $string =~ s/\$TH/\&THgr\;/g;
    $string =~ s/\$t/\&tgr\;/g;
    $string =~ s/\$T/\&Tgr\;/g;
    $string =~ s/\$u/\&ugr\;/g;
    $string =~ s/\$U/\&Ugr\;/g;
    $string =~ s/\$z/\&zgr\;/g;
    $string =~ s/\$Z/\&Zgr\;/g;
    $string =~ s/\$x/\&xgr\;/g;
    $string =~ s/\$X/\&Xgr\;/g;
    $string =~ s/\"\[\"/BEFORE/g;
    $string =~ s/\"\]\"/AFTER/g;
    $string =~ s/\'\[\'/BEFORE/g;
    $string =~ s/\'\]\'/AFTER/g;
    $string =~ s/\]{2,2}/\<\/down\>/g;
    $string =~ s/\[{2,2}/\<down\>/g;
    $string =~ s/\[/\<up\>/g;
    $string =~ s/\]/\<\/up\>/g;

    #    $string =~ s/BEFORE/\[/g;
    #    $string =~ s/AFTER/\]/g;

    return ($string);
}

sub conversupdown {
    my $string = $_[0];

    #    print STDERR "convert up down string $string\n";
    $string =~ s/\"\[\"/BEFORE/g;
    $string =~ s/\"\]\"/AFTER/g;
    $string =~ s/\'\[\'/BEFORE/g;
    $string =~ s/\'\]\'/AFTER/g;
    $string =~ s/\]{2,2}/\<\/down\>/g;
    $string =~ s/\[{2,2}/\<down\>/g;
    $string =~ s/\[/\<up\>/g;
    $string =~ s/\]/\<\/up\>/g;
    $string =~ s/BEFORE/\[/g;
    $string =~ s/AFTER/\]/g;
    return ($string);
}

sub dom_toString {
    my ($node) = @_;
    my $content = '';
    if ( $node->getNodeType == ELEMENT_NODE ) {
        $docindex++;
        if ( $lindex == 0 ) { $content .= sprintf("\n"); }
        my $attrs = $node->getAttributes();
        my @lists = $attrs->getValues;
        $content .= sprintf( ' ' x $docindex . "<" . $node->getNodeName );
        foreach my $attr (@lists) {
            $content .=
              sprintf( ' '
                  . $attr->getName . '="'
                  . &encodeText( $attr->getValue, '<&>\'"' )
                  . '"' );
        }
        $content .= sprintf(">");

        foreach my $child ( $node->getChildNodes() ) {
            $content .= dom_toString($child);
        }
        if ( $lindex == 0 ) {
            $content .= sprintf( "\n" . ' ' x $docindex );
        }
        $content .= sprintf( "</" . $node->getNodeName . ">" );
        $lindex = 0;
        $docindex--;
    }
    elsif ( $node->getNodeType() == TEXT_NODE ) {

        $content .= &encodeText( $node->getData, '<&>\'"' );
        $lindex = 1;
    }
    else {
        foreach my $children ( $node->getChildNodes() ) {

            $content .= dom_toString($children);
        }
    }
    return $content;
}

sub encodeText {
    my ( $str, $default ) = @_;
    return undef unless defined $str;

    if ( $] >= 5.006 ) {
        $str =~ s/([$default])|(]]>)/
        defined ($1) ? $DecodeDefaultEntity{$1} : "]]&gt;" /egs;
    }
    else {
        $str =~
          s/([\xC0-\xDF].|[\xE0-\xEF]..|[\xF0-\xFF]...)|([$default])|(]]>)/
        defined($1) ? XmlUtf8Decode ($1) :
        defined ($2) ? $DecodeDefaultEntity{$2} : "]]&gt;" /egs;
    }

    #?? could there be references that should not be expanded?
    # e.g. should not replace &#nn; &#xAF; and &abc;
    #    $str =~ s/&(?!($ReName|#[0-9]+|#x[0-9a-fA-F]+);)/&amp;/go;

    $str;
}

sub XmlUtf8Decode {
    my ( $str, $hex ) = @_;
    my $len = length($str);
    my $n;

    if ( $len == 2 ) {
        my @n = unpack "C2", $str;
        $n = ( ( $n[0] & 0x3f ) << 6 ) + ( $n[1] & 0x3f );
    }
    elsif ( $len == 3 ) {
        my @n = unpack "C3", $str;
        $n =
          ( ( $n[0] & 0x1f ) << 12 ) +
          ( ( $n[1] & 0x3f ) << 6 ) +
          ( $n[2] & 0x3f );
    }
    elsif ( $len == 4 ) {
        my @n = unpack "C4", $str;
        $n =
          ( ( $n[0] & 0x0f ) << 18 ) +
          ( ( $n[1] & 0x3f ) << 12 ) +
          ( ( $n[2] & 0x3f ) << 6 ) +
          ( $n[3] & 0x3f );
    }
    elsif ( $len == 1 )    # just to be complete...
    {
        $n = ord($str);
    }
    else {
        print "bad value [$str] for XmlUtf8Decode";
    }
    $hex ? sprintf( "&#x%x;", $n ) : "&#$n;";
}

#### Andy's added methods - may be redundant - too many undocumented methods to scan

# taken from Andy's Utils.pm
# arg1 - database handle
# arg2 - string cvterm.name
# arg3 - string cv.name
# arg4 - optional boolean is_obsolete
#
# @ return int cvterm_id
sub get_cvterm_id_by_name_cv {
    my $dbh    = shift;
    my $name   = shift;
    my $cv     = shift;
    my $is_obs = shift if @_;

    my $obs_string = ' and is_obsolete = 0';
    $obs_string = '' if $is_obs;

    ( my $cvtid ) = $dbh->selectrow_array(
        sprintf(
            "SELECT cvterm_id FROM cvterm c, cv
      WHERE  c.name = '$name' and c.cv_id = cv.cv_id
        and  cv.name = '$cv' $obs_string"
        )
    );
    print "Can't find cvterm name $name in CV $cv\n"
      and return
      unless $cvtid;
    return $cvtid;
}

# will return uniquename given a feature name/symbol
# will take optional regex to match uniquename to
# returns 2 if more than one feature with that name
# returns undef if no feature with that name found
sub get_uniquename_by_name {
    my $dbh  = shift;
    my $name = shift;
    my $regex;
    $regex = shift if @_;
    $name  = decon($name);

    #format it for SQL
    $name =~ s/\\/\\\\/g;
    $name =~ s/\'/\'\'/g;

    my $stmt =
"SELECT uniquename FROM feature WHERE name = E'$name' and is_obsolete = false and is_analysis = false";
    my $q = $dbh->prepare($stmt);
    $q->execute or return $dbh->errstr;
    my $uniquename;
    my $cnt;
    while ( ( my $u ) = $q->fetchrow_array() ) {
        if ($regex) {
            next unless $u =~ /$regex/;
        }
        $uniquename = $u;
        $cnt++;
    }
    return 2 if $cnt and $cnt > 1;
    return $uniquename;
}

# get's the maximum existing rank value in feature_cvtermprop table for
# a given set of likely ukey values for feature_cvterm i.e. feature.uniquename,
# cvterm.name, cvterm.cv and pub.uniquename
# arg1 - database handle
# arg2 - feature.uniquename
# arg3 - cvterm.name
# arg4 - cv.name
# arg5 - pub.uniquename
# arg6 - optional rank - if this is given and is greater than max rank in db
#                                          this value will be returned
#
# return int maximum existing feature_cvtermprop.rank or undef
# will return negative number if more than one feature_cvterm with
# the same 'ukey' bits
sub get_max_feature_cvtermprop_rank {
    my $dbh   = shift;
    my $uname = shift;
    my $term  = shift;
    my $cv    = shift;
    my $pub   = shift;
    my $mrank;
    $mrank = shift if @_;

    $term = $dbh->quote($term);

    my $stmt =
"SELECT fc.feature_cvterm_id, max(rank) FROM feature_cvtermprop fcp, feature_cvterm fc, cvterm c, feature f, pub p, cv WHERE fcp.feature_cvterm_id = fc.feature_cvterm_id and fc.feature_id = f.feature_id and f.uniquename = '$uname' and f.is_obsolete = false and f.is_analysis = false and fc.cvterm_id = c.cvterm_id and c.name = $term and c.is_obsolete = 0 and c.cv_id = cv.cv_id and cv.name = '$cv' and fc.pub_id = p.pub_id and p.uniquename = '$pub' GROUP BY fc.feature_cvterm_id";

    my $q = $dbh->prepare($stmt);
    $q->execute or return $dbh->errstr;
    return -1
      if ( $q->rows > 1 )
      ;    # more than one feature_cvterm found for those identifying bits

    ( my $fcvtid, my $rank ) = $q->fetchrow_array;
    $q->finish;
    if ( !$fcvtid ) {
        return $mrank if $mrank;
        return;
    }
    else {    # we have an existing unique feature_cvterm with props
        if ($rank) {
            return $mrank if ( $mrank and $mrank > $rank );
            return $rank;
        }
        else {    # rank == 0
            return $mrank if ( $mrank and $mrank > 0 );
            return -9999999;
        }
    }
}

1;

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

FlyBase::Proforma::Util - Perl extension for blah blah blah

=head1 SYNOPSIS

  use FlyBase::Proforma::Util;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for FlyBase::Proforma::TI, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Haiyan Zhang, E<lt>haiyanmail@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
