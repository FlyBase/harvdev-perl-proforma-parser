# $Id: WriteChadoAuto.pm 2010-07-30 
# An automatically generated perl module to write chado xml element
# 
# Pleae direct questions and support issues to <haiyan@morgan.harvard.edu>
#
# Cared for by Haiyan Zhang <haiyan@morgan.harvard.edu>
#
# Copyright Haiyan Zhang@2010
#
# you may distribute this module under the same terms as perl itself

=head1 NAME

  WriteChadoAuto.pm - A automatically generated module to write chado xml element

=head1 SYNOPSIS

  use XML::DOM;
  use FlyBase::Proforma::WriteChadoAuto; 
  
  my $doc = new XML::DOM::Document;
  my $feat_el=create_ch_feature(doc=>$doc,
                                uniquename=>"FBgn0001020",
                                organism_id=>create_ch_organism( doc=>$doc,
                                                    genus=>"Drosophila",
                                                    species=>"melanogaster"
                                                    ),
                                type_id=>create_ch_cvterm(doc=>$doc,
                                               cv_id=>create_ch_cv(doc=>$doc,
                                                                  name=>"SO"),
                                               name=>"gene", 
                                               macro_id=>"gene"
                                          ),
                                macro_id=>"FBgn0001020",
                                no_lookup=>1
                                          
                                );
  All functions has default no_lookup=0, which means the created XML::DOM element
  will have attributes "op" value is "lookup", this will not insert a new row 
  in the database. 
  If the XML::DOM element is new to the database, add "no_lookup=>1" to the parameters

=head1 DESCRIPTION

=head1 EXAMPLE

=head1 SUPPORT and FEEDBACK

    Haiyan Zhang <haiyan@morgan.harvard.edu>

=head1 AUTHORS

    Haiyan Zhang <haiyan@morgan.harvard.edu>

=head1 CONSTRIBUTORS

    Andy Shroeder <andy@morgan.harvard.edu>


package FlyBase::Proforma::WriteChado;
use strict;
use warnings;
     
use XML::DOM;
use vars qw($VERSION @ISA @EXPORT);
require Exporter;
use AutoLoader qw(AUTOLOAD);
our @ISA = qw(Exporter);
    
our @EXPORT = qw(create_ch_analysis create_ch_analysisfeature create_ch_analysisprop create_ch_audit_chado create_ch_cell_line create_ch_cell_line_cvterm create_ch_cell_line_cvtermprop create_ch_cell_line_dbxref create_ch_cell_line_feature create_ch_cell_line_library create_ch_cell_line_pub create_ch_cell_line_relationship create_ch_cell_line_synonym create_ch_cell_lineprop create_ch_cell_lineprop_pub create_ch_contact create_ch_cv create_ch_cvterm create_ch_cvterm_dbxref create_ch_cvterm_relationship create_ch_cvtermpath create_ch_cvtermprop create_ch_cvtermsynonym create_ch_db create_ch_dbxref create_ch_dbxrefprop create_ch_eimage create_ch_environment create_ch_environment_cvterm create_ch_expression create_ch_expression_cvterm create_ch_expression_cvtermprop create_ch_expression_image create_ch_expression_pub create_ch_expressionprop create_ch_feature create_ch_feature_cvterm create_ch_feature_cvterm_dbxref create_ch_feature_cvtermprop create_ch_feature_dbxref create_ch_feature_expression create_ch_feature_expressionprop create_ch_feature_genotype create_ch_feature_interaction create_ch_feature_interaction_pub create_ch_feature_interactionprop create_ch_feature_phenotype create_ch_feature_pub create_ch_feature_pubprop create_ch_feature_relationship create_ch_feature_relationship_pub create_ch_feature_relationshipprop create_ch_feature_relationshipprop_pub create_ch_feature_synonym create_ch_featureloc create_ch_featureloc_pub create_ch_featuremap create_ch_featuremap_pub create_ch_featurepos create_ch_featureprop create_ch_featureprop_pub create_ch_featurerange create_ch_genotype create_ch_interaction create_ch_interaction_cell_line create_ch_interaction_cvterm create_ch_interaction_cvtermprop create_ch_interaction_expression create_ch_interaction_expressionprop create_ch_interaction_pub create_ch_interactionprop create_ch_library create_ch_library_cvterm create_ch_library_dbxref create_ch_library_expression create_ch_library_expressionprop create_ch_library_feature create_ch_library_featureprop create_ch_library_interaction create_ch_library_pub create_ch_library_relationship create_ch_library_relationship_pub create_ch_library_synonym create_ch_libraryprop create_ch_libraryprop_pub create_ch_lock create_ch_organism create_ch_organism_dbxref create_ch_organismprop create_ch_phendesc create_ch_phenotype create_ch_phenotype_comparison create_ch_phenotype_comparison_cvterm create_ch_phenotype_cvterm create_ch_phenstatement create_ch_project create_ch_pub create_ch_pub_dbxref create_ch_pub_relationship create_ch_pubauthor create_ch_pubprop create_ch_synonym create_ch_tableinfo create_ch_update_track );

our $VERSION = "1.0";



=head2 create_ch_analysis

  Title   : create_ch_analysis 

  Usage   : my $cdom=create_ch_analysis(%param);

  Parameters: doc - required. XML::DOM::Document
              sourcename - string, optional. 
              algorithm - string, optional. 
              name - string, optional. 
              description - string, optional. 
              timeexecuted - timestamp without time zone, optional. 
              program - string, required. 
              sourceversion - string, optional. 
              programversion - string, required. 
              sourceuri - string, optional. 

  Function: create_ch_analysis returns a XML::DOM element

=cut

sub create_ch_analysis {
   my %params = @_;
   my %paramitems=('sourcename',1,'algorithm',1,'name',1,'description',1,'timeexecuted',1,'program',1,'sourceversion',1,'programversion',1,'sourceuri',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("analysis");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{program} && unless($param{programversion}  {
       print "WARNING -- you have not provided params to make program or programversion, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_analysisfeature

  Title   : create_ch_analysisfeature 

  Usage   : my $cdom=create_ch_analysisfeature(%param);

  Parameters: doc - required. XML::DOM::Document
              feature_id - required. macro_id(string) for feature element or XML::DOM feature element
              significance - double, optional. 
              rawscore - double, optional. 
              identity - double, optional. 
              normscore - double, optional. 
              analysis_id - required. macro_id(string) for analysis element or XML::DOM analysis element

  Function: create_ch_analysisfeature returns a XML::DOM element

=cut

sub create_ch_analysisfeature {
   my %params = @_;
   my %paramitems=('feature_id',1,'significance',1,'rawscore',1,'identity',1,'normscore',1,'analysis_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("analysisfeature");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_id} && unless($param{analysis_id}  {
       print "WARNING -- you have not provided params to make feature_id or analysis_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_analysisprop

  Title   : create_ch_analysisprop 

  Usage   : my $cdom=create_ch_analysisprop(%param);

  Parameters: doc - required. XML::DOM::Document
              value - string, optional. 
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              analysis_id - required. macro_id(string) for analysis element or XML::DOM analysis element

  Function: create_ch_analysisprop returns a XML::DOM element

=cut

sub create_ch_analysisprop {
   my %params = @_;
   my %paramitems=('value',1,'type_id',1,'analysis_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("analysisprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{type_id} && unless($param{analysis_id}  {
       print "WARNING -- you have not provided params to make type_id or analysis_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_audit_chado

  Title   : create_ch_audit_chado 

  Usage   : my $cdom=create_ch_audit_chado(%param);

  Parameters: doc - required. XML::DOM::Document
              record_ukey_cols - string, required. 
              audited_vals - string, required. 
              userid - string, required. 
              audited_table - string, required. 
              record_ukey_vals - string, required. 
              transaction_timestamp - timestamp without time zone, required. 
              audit_transaction - character, required. 
              record_pkey - integer, required. 
              audited_cols - string, required. 

  Function: create_ch_audit_chado returns a XML::DOM element

=cut

sub create_ch_audit_chado {
   my %params = @_;
   my %paramitems=('record_ukey_cols',1,'audited_vals',1,'userid',1,'audited_table',1,'record_ukey_vals',1,'transaction_timestamp',1,'audit_transaction',1,'record_pkey',1,'audited_cols',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("audit_chado");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{record_ukey_cols} && unless($param{audited_vals} && unless($param{userid} && unless($param{audited_table} && unless($param{record_ukey_vals} && unless($param{transaction_timestamp} && unless($param{audit_transaction} && unless($param{record_pkey} && unless($param{audited_cols}  {
       print "WARNING -- you have not provided params to make record_ukey_cols or audited_vals or userid or audited_table or record_ukey_vals or transaction_timestamp or audit_transaction or record_pkey or audited_cols, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_cell_line

  Title   : create_ch_cell_line 

  Usage   : my $cdom=create_ch_cell_line(%param);

  Parameters: doc - required. XML::DOM::Document
              uniquename - string, required. 
              name - string, optional. 
              timeaccessioned - timestamp without time zone, optional. 
              organism_id - required. macro_id(string) for organism element or XML::DOM organism element
              timelastmodified - timestamp without time zone, optional. 

  Function: create_ch_cell_line returns a XML::DOM element

=cut

sub create_ch_cell_line {
   my %params = @_;
   my %paramitems=('uniquename',1,'name',1,'timeaccessioned',1,'organism_id',1,'timelastmodified',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("cell_line");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{uniquename} && unless($param{organism_id}  {
       print "WARNING -- you have not provided params to make uniquename or organism_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_cell_line_cvterm

  Title   : create_ch_cell_line_cvterm 

  Usage   : my $cdom=create_ch_cell_line_cvterm(%param);

  Parameters: doc - required. XML::DOM::Document
              cell_line_id - required. macro_id(string) for cell_line element or XML::DOM cell_line element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element
              cvterm_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_cell_line_cvterm returns a XML::DOM element

=cut

sub create_ch_cell_line_cvterm {
   my %params = @_;
   my %paramitems=('cell_line_id',1,'pub_id',1,'cvterm_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("cell_line_cvterm");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{cell_line_id} && unless($param{pub_id} && unless($param{cvterm_id}  {
       print "WARNING -- you have not provided params to make cell_line_id or pub_id or cvterm_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_cell_line_cvtermprop

  Title   : create_ch_cell_line_cvtermprop 

  Usage   : my $cdom=create_ch_cell_line_cvtermprop(%param);

  Parameters: doc - required. XML::DOM::Document
              value - string, optional. 
              cell_line_cvterm_id - required. macro_id(string) for cell_line_cvterm element or XML::DOM cell_line_cvterm element
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_cell_line_cvtermprop returns a XML::DOM element

=cut

sub create_ch_cell_line_cvtermprop {
   my %params = @_;
   my %paramitems=('value',1,'cell_line_cvterm_id',1,'type_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("cell_line_cvtermprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{cell_line_cvterm_id} && unless($param{type_id}  {
       print "WARNING -- you have not provided params to make cell_line_cvterm_id or type_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_cell_line_dbxref

  Title   : create_ch_cell_line_dbxref 

  Usage   : my $cdom=create_ch_cell_line_dbxref(%param);

  Parameters: doc - required. XML::DOM::Document
              dbxref_id - required. macro_id(string) for dbxref element or XML::DOM dbxref element
              cell_line_id - required. macro_id(string) for cell_line element or XML::DOM cell_line element
              is_current - boolean, optional. 

  Function: create_ch_cell_line_dbxref returns a XML::DOM element

=cut

sub create_ch_cell_line_dbxref {
   my %params = @_;
   my %paramitems=('dbxref_id',1,'cell_line_id',1,'is_current',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("cell_line_dbxref");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{dbxref_id} && unless($param{cell_line_id}  {
       print "WARNING -- you have not provided params to make dbxref_id or cell_line_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_cell_line_feature

  Title   : create_ch_cell_line_feature 

  Usage   : my $cdom=create_ch_cell_line_feature(%param);

  Parameters: doc - required. XML::DOM::Document
              feature_id - required. macro_id(string) for feature element or XML::DOM feature element
              cell_line_id - required. macro_id(string) for cell_line element or XML::DOM cell_line element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_cell_line_feature returns a XML::DOM element

=cut

sub create_ch_cell_line_feature {
   my %params = @_;
   my %paramitems=('feature_id',1,'cell_line_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("cell_line_feature");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_id} && unless($param{cell_line_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make feature_id or cell_line_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_cell_line_library

  Title   : create_ch_cell_line_library 

  Usage   : my $cdom=create_ch_cell_line_library(%param);

  Parameters: doc - required. XML::DOM::Document
              library_id - required. macro_id(string) for library element or XML::DOM library element
              cell_line_id - required. macro_id(string) for cell_line element or XML::DOM cell_line element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_cell_line_library returns a XML::DOM element

=cut

sub create_ch_cell_line_library {
   my %params = @_;
   my %paramitems=('library_id',1,'cell_line_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("cell_line_library");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{library_id} && unless($param{cell_line_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make library_id or cell_line_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_cell_line_pub

  Title   : create_ch_cell_line_pub 

  Usage   : my $cdom=create_ch_cell_line_pub(%param);

  Parameters: doc - required. XML::DOM::Document
              cell_line_id - required. macro_id(string) for cell_line element or XML::DOM cell_line element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_cell_line_pub returns a XML::DOM element

=cut

sub create_ch_cell_line_pub {
   my %params = @_;
   my %paramitems=('cell_line_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("cell_line_pub");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{cell_line_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make cell_line_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_cell_line_relationship

  Title   : create_ch_cell_line_relationship 

  Usage   : my $cdom=create_ch_cell_line_relationship(%param);

  Parameters: doc - required. XML::DOM::Document
              subject_id - required. macro_id(string) for cell_line element or XML::DOM cell_line element
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              object_id - required. macro_id(string) for cell_line element or XML::DOM cell_line element

  Function: create_ch_cell_line_relationship returns a XML::DOM element

=cut

sub create_ch_cell_line_relationship {
   my %params = @_;
   my %paramitems=('subject_id',1,'type_id',1,'object_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("cell_line_relationship");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{subject_id} && unless($param{type_id} && unless($param{object_id}  {
       print "WARNING -- you have not provided params to make subject_id or type_id or object_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_cell_line_synonym

  Title   : create_ch_cell_line_synonym 

  Usage   : my $cdom=create_ch_cell_line_synonym(%param);

  Parameters: doc - required. XML::DOM::Document
              synonym_id - required. macro_id(string) for synonym element or XML::DOM synonym element
              cell_line_id - required. macro_id(string) for cell_line element or XML::DOM cell_line element
              is_current - boolean, optional. 
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element
              is_internal - boolean, optional. 

  Function: create_ch_cell_line_synonym returns a XML::DOM element

=cut

sub create_ch_cell_line_synonym {
   my %params = @_;
   my %paramitems=('synonym_id',1,'cell_line_id',1,'is_current',1,'pub_id',1,'is_internal',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("cell_line_synonym");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{synonym_id} && unless($param{cell_line_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make synonym_id or cell_line_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_cell_lineprop

  Title   : create_ch_cell_lineprop 

  Usage   : my $cdom=create_ch_cell_lineprop(%param);

  Parameters: doc - required. XML::DOM::Document
              value - string, optional. 
              cell_line_id - required. macro_id(string) for cell_line element or XML::DOM cell_line element
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_cell_lineprop returns a XML::DOM element

=cut

sub create_ch_cell_lineprop {
   my %params = @_;
   my %paramitems=('value',1,'cell_line_id',1,'type_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("cell_lineprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{cell_line_id} && unless($param{type_id}  {
       print "WARNING -- you have not provided params to make cell_line_id or type_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_cell_lineprop_pub

  Title   : create_ch_cell_lineprop_pub 

  Usage   : my $cdom=create_ch_cell_lineprop_pub(%param);

  Parameters: doc - required. XML::DOM::Document
              cell_lineprop_id - required. macro_id(string) for cell_lineprop element or XML::DOM cell_lineprop element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_cell_lineprop_pub returns a XML::DOM element

=cut

sub create_ch_cell_lineprop_pub {
   my %params = @_;
   my %paramitems=('cell_lineprop_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("cell_lineprop_pub");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{cell_lineprop_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make cell_lineprop_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_contact

  Title   : create_ch_contact 

  Usage   : my $cdom=create_ch_contact(%param);

  Parameters: doc - required. XML::DOM::Document
              name - string, required. 
              description - string, optional. 

  Function: create_ch_contact returns a XML::DOM element

=cut

sub create_ch_contact {
   my %params = @_;
   my %paramitems=('name',1,'description',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("contact");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{name}  {
       print "WARNING -- you have not provided params to make name, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_cv

  Title   : create_ch_cv 

  Usage   : my $cdom=create_ch_cv(%param);

  Parameters: doc - required. XML::DOM::Document
              name - string, required. 
              definition - string, optional. 

  Function: create_ch_cv returns a XML::DOM element

=cut

sub create_ch_cv {
   my %params = @_;
   my %paramitems=('name',1,'definition',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("cv");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{name}  {
       print "WARNING -- you have not provided params to make name, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_cvterm

  Title   : create_ch_cvterm 

  Usage   : my $cdom=create_ch_cvterm(%param);

  Parameters: doc - required. XML::DOM::Document
              dbxref_id - required. macro_id(string) for dbxref element or XML::DOM dbxref element
              name - string, required. 
              definition - string, optional. 
              cv_id - required. macro_id(string) for cv element or XML::DOM cv element
              is_relationshiptype - integer, optional. 
              is_obsolete - integer, optional. 

  Function: create_ch_cvterm returns a XML::DOM element

=cut

sub create_ch_cvterm {
   my %params = @_;
   my %paramitems=('dbxref_id',1,'name',1,'definition',1,'cv_id',1,'is_relationshiptype',1,'is_obsolete',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("cvterm");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{dbxref_id} && unless($param{name} && unless($param{cv_id}  {
       print "WARNING -- you have not provided params to make dbxref_id or name or cv_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_cvterm_dbxref

  Title   : create_ch_cvterm_dbxref 

  Usage   : my $cdom=create_ch_cvterm_dbxref(%param);

  Parameters: doc - required. XML::DOM::Document
              dbxref_id - required. macro_id(string) for dbxref element or XML::DOM dbxref element
              cvterm_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              is_for_definition - integer, optional. 

  Function: create_ch_cvterm_dbxref returns a XML::DOM element

=cut

sub create_ch_cvterm_dbxref {
   my %params = @_;
   my %paramitems=('dbxref_id',1,'cvterm_id',1,'is_for_definition',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("cvterm_dbxref");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{dbxref_id} && unless($param{cvterm_id}  {
       print "WARNING -- you have not provided params to make dbxref_id or cvterm_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_cvterm_relationship

  Title   : create_ch_cvterm_relationship 

  Usage   : my $cdom=create_ch_cvterm_relationship(%param);

  Parameters: doc - required. XML::DOM::Document
              subject_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              object_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element

  Function: create_ch_cvterm_relationship returns a XML::DOM element

=cut

sub create_ch_cvterm_relationship {
   my %params = @_;
   my %paramitems=('subject_id',1,'type_id',1,'object_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("cvterm_relationship");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{subject_id} && unless($param{type_id} && unless($param{object_id}  {
       print "WARNING -- you have not provided params to make subject_id or type_id or object_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_cvtermpath

  Title   : create_ch_cvtermpath 

  Usage   : my $cdom=create_ch_cvtermpath(%param);

  Parameters: doc - required. XML::DOM::Document
              pathdistance - integer, optional. 
              subject_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              cv_id - integer, required. 
              type_id - optional. macro_id(string) for cvterm element or XML::DOM cvterm element
              object_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element

  Function: create_ch_cvtermpath returns a XML::DOM element

=cut

sub create_ch_cvtermpath {
   my %params = @_;
   my %paramitems=('pathdistance',1,'subject_id',1,'cv_id',1,'type_id',1,'object_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("cvtermpath");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{subject_id} && unless($param{cv_id} && unless($param{object_id}  {
       print "WARNING -- you have not provided params to make subject_id or cv_id or object_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_cvtermprop

  Title   : create_ch_cvtermprop 

  Usage   : my $cdom=create_ch_cvtermprop(%param);

  Parameters: doc - required. XML::DOM::Document
              value - string, optional. 
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              cvterm_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_cvtermprop returns a XML::DOM element

=cut

sub create_ch_cvtermprop {
   my %params = @_;
   my %paramitems=('value',1,'type_id',1,'cvterm_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("cvtermprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{type_id} && unless($param{cvterm_id}  {
       print "WARNING -- you have not provided params to make type_id or cvterm_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_cvtermsynonym

  Title   : create_ch_cvtermsynonym 

  Usage   : my $cdom=create_ch_cvtermsynonym(%param);

  Parameters: doc - required. XML::DOM::Document
              name - string, required. 
              type_id - optional. macro_id(string) for cvterm element or XML::DOM cvterm element
              cvterm_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element

  Function: create_ch_cvtermsynonym returns a XML::DOM element

=cut

sub create_ch_cvtermsynonym {
   my %params = @_;
   my %paramitems=('name',1,'type_id',1,'cvterm_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("cvtermsynonym");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{name} && unless($param{cvterm_id}  {
       print "WARNING -- you have not provided params to make name or cvterm_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_db

  Title   : create_ch_db 

  Usage   : my $cdom=create_ch_db(%param);

  Parameters: doc - required. XML::DOM::Document
              name - string, required. 
              description - string, optional. 
              urlprefix - string, optional. 
              url - string, optional. 
              contact_id - optional. macro_id(string) for contact element or XML::DOM contact element

  Function: create_ch_db returns a XML::DOM element

=cut

sub create_ch_db {
   my %params = @_;
   my %paramitems=('name',1,'description',1,'urlprefix',1,'url',1,'contact_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("db");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{name}  {
       print "WARNING -- you have not provided params to make name, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_dbxref

  Title   : create_ch_dbxref 

  Usage   : my $cdom=create_ch_dbxref(%param);

  Parameters: doc - required. XML::DOM::Document
              version - string, optional. 
              description - string, optional. 
              accession - string, required. 
              db_id - required. macro_id(string) for db element or XML::DOM db element
              url - string, optional. 

  Function: create_ch_dbxref returns a XML::DOM element

=cut

sub create_ch_dbxref {
   my %params = @_;
   my %paramitems=('version',1,'description',1,'accession',1,'db_id',1,'url',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("dbxref");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{accession} && unless($param{db_id}  {
       print "WARNING -- you have not provided params to make accession or db_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_dbxrefprop

  Title   : create_ch_dbxrefprop 

  Usage   : my $cdom=create_ch_dbxrefprop(%param);

  Parameters: doc - required. XML::DOM::Document
              dbxref_id - required. macro_id(string) for dbxref element or XML::DOM dbxref element
              value - string, optional. 
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_dbxrefprop returns a XML::DOM element

=cut

sub create_ch_dbxrefprop {
   my %params = @_;
   my %paramitems=('dbxref_id',1,'value',1,'type_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("dbxrefprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{dbxref_id} && unless($param{type_id}  {
       print "WARNING -- you have not provided params to make dbxref_id or type_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_eimage

  Title   : create_ch_eimage 

  Usage   : my $cdom=create_ch_eimage(%param);

  Parameters: doc - required. XML::DOM::Document
              eimage_type - string, required. 
              eimage_data - string, optional. 
              image_uri - string, optional. 

  Function: create_ch_eimage returns a XML::DOM element

=cut

sub create_ch_eimage {
   my %params = @_;
   my %paramitems=('eimage_type',1,'eimage_data',1,'image_uri',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("eimage");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{eimage_type}  {
       print "WARNING -- you have not provided params to make eimage_type, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_environment

  Title   : create_ch_environment 

  Usage   : my $cdom=create_ch_environment(%param);

  Parameters: doc - required. XML::DOM::Document
              uniquename - string, required. 
              description - string, optional. 

  Function: create_ch_environment returns a XML::DOM element

=cut

sub create_ch_environment {
   my %params = @_;
   my %paramitems=('uniquename',1,'description',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("environment");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{uniquename}  {
       print "WARNING -- you have not provided params to make uniquename, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_environment_cvterm

  Title   : create_ch_environment_cvterm 

  Usage   : my $cdom=create_ch_environment_cvterm(%param);

  Parameters: doc - required. XML::DOM::Document
              environment_id - required. macro_id(string) for environment element or XML::DOM environment element
              cvterm_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element

  Function: create_ch_environment_cvterm returns a XML::DOM element

=cut

sub create_ch_environment_cvterm {
   my %params = @_;
   my %paramitems=('environment_id',1,'cvterm_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("environment_cvterm");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{environment_id} && unless($param{cvterm_id}  {
       print "WARNING -- you have not provided params to make environment_id or cvterm_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_expression

  Title   : create_ch_expression 

  Usage   : my $cdom=create_ch_expression(%param);

  Parameters: doc - required. XML::DOM::Document
              uniquename - string, required. 
              description - string, optional. 
              md5checksum - character, optional. 

  Function: create_ch_expression returns a XML::DOM element

=cut

sub create_ch_expression {
   my %params = @_;
   my %paramitems=('uniquename',1,'description',1,'md5checksum',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("expression");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{uniquename}  {
       print "WARNING -- you have not provided params to make uniquename, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_expression_cvterm

  Title   : create_ch_expression_cvterm 

  Usage   : my $cdom=create_ch_expression_cvterm(%param);

  Parameters: doc - required. XML::DOM::Document
              cvterm_type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              expression_id - required. macro_id(string) for expression element or XML::DOM expression element
              cvterm_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_expression_cvterm returns a XML::DOM element

=cut

sub create_ch_expression_cvterm {
   my %params = @_;
   my %paramitems=('cvterm_type_id',1,'expression_id',1,'cvterm_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("expression_cvterm");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{cvterm_type_id} && unless($param{expression_id} && unless($param{cvterm_id}  {
       print "WARNING -- you have not provided params to make cvterm_type_id or expression_id or cvterm_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_expression_cvtermprop

  Title   : create_ch_expression_cvtermprop 

  Usage   : my $cdom=create_ch_expression_cvtermprop(%param);

  Parameters: doc - required. XML::DOM::Document
              value - string, optional. 
              expression_cvterm_id - required. macro_id(string) for expression_cvterm element or XML::DOM expression_cvterm element
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_expression_cvtermprop returns a XML::DOM element

=cut

sub create_ch_expression_cvtermprop {
   my %params = @_;
   my %paramitems=('value',1,'expression_cvterm_id',1,'type_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("expression_cvtermprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{expression_cvterm_id} && unless($param{type_id}  {
       print "WARNING -- you have not provided params to make expression_cvterm_id or type_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_expression_image

  Title   : create_ch_expression_image 

  Usage   : my $cdom=create_ch_expression_image(%param);

  Parameters: doc - required. XML::DOM::Document
              expression_id - required. macro_id(string) for expression element or XML::DOM expression element
              eimage_id - required. macro_id(string) for eimage element or XML::DOM eimage element

  Function: create_ch_expression_image returns a XML::DOM element

=cut

sub create_ch_expression_image {
   my %params = @_;
   my %paramitems=('expression_id',1,'eimage_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("expression_image");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{expression_id} && unless($param{eimage_id}  {
       print "WARNING -- you have not provided params to make expression_id or eimage_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_expression_pub

  Title   : create_ch_expression_pub 

  Usage   : my $cdom=create_ch_expression_pub(%param);

  Parameters: doc - required. XML::DOM::Document
              expression_id - required. macro_id(string) for expression element or XML::DOM expression element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_expression_pub returns a XML::DOM element

=cut

sub create_ch_expression_pub {
   my %params = @_;
   my %paramitems=('expression_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("expression_pub");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{expression_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make expression_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_expressionprop

  Title   : create_ch_expressionprop 

  Usage   : my $cdom=create_ch_expressionprop(%param);

  Parameters: doc - required. XML::DOM::Document
              value - string, optional. 
              expression_id - required. macro_id(string) for expression element or XML::DOM expression element
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_expressionprop returns a XML::DOM element

=cut

sub create_ch_expressionprop {
   my %params = @_;
   my %paramitems=('value',1,'expression_id',1,'type_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("expressionprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{expression_id} && unless($param{type_id}  {
       print "WARNING -- you have not provided params to make expression_id or type_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_feature

  Title   : create_ch_feature 

  Usage   : my $cdom=create_ch_feature(%param);

  Parameters: doc - required. XML::DOM::Document
              dbxref_id - optional. macro_id(string) for dbxref element or XML::DOM dbxref element
              uniquename - string, required. 
              name - string, optional. 
              timeaccessioned - timestamp without time zone, optional. 
              md5checksum - character, optional. 
              residues - string, optional. 
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              organism_id - required. macro_id(string) for organism element or XML::DOM organism element
              seqlen - integer, optional. 
              is_obsolete - boolean, optional. 
              is_analysis - boolean, optional. 
              timelastmodified - timestamp without time zone, optional. 

  Function: create_ch_feature returns a XML::DOM element

=cut

sub create_ch_feature {
   my %params = @_;
   my %paramitems=('dbxref_id',1,'uniquename',1,'name',1,'timeaccessioned',1,'md5checksum',1,'residues',1,'type_id',1,'organism_id',1,'seqlen',1,'is_obsolete',1,'is_analysis',1,'timelastmodified',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("feature");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{uniquename} && unless($param{type_id} && unless($param{organism_id}  {
       print "WARNING -- you have not provided params to make uniquename or type_id or organism_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_feature_cvterm

  Title   : create_ch_feature_cvterm 

  Usage   : my $cdom=create_ch_feature_cvterm(%param);

  Parameters: doc - required. XML::DOM::Document
              feature_id - required. macro_id(string) for feature element or XML::DOM feature element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element
              cvterm_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              is_not - boolean, optional. 

  Function: create_ch_feature_cvterm returns a XML::DOM element

=cut

sub create_ch_feature_cvterm {
   my %params = @_;
   my %paramitems=('feature_id',1,'pub_id',1,'cvterm_id',1,'is_not',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("feature_cvterm");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_id} && unless($param{pub_id} && unless($param{cvterm_id}  {
       print "WARNING -- you have not provided params to make feature_id or pub_id or cvterm_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_feature_cvterm_dbxref

  Title   : create_ch_feature_cvterm_dbxref 

  Usage   : my $cdom=create_ch_feature_cvterm_dbxref(%param);

  Parameters: doc - required. XML::DOM::Document
              dbxref_id - required. macro_id(string) for dbxref element or XML::DOM dbxref element
              feature_cvterm_id - required. macro_id(string) for feature_cvterm element or XML::DOM feature_cvterm element

  Function: create_ch_feature_cvterm_dbxref returns a XML::DOM element

=cut

sub create_ch_feature_cvterm_dbxref {
   my %params = @_;
   my %paramitems=('dbxref_id',1,'feature_cvterm_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("feature_cvterm_dbxref");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{dbxref_id} && unless($param{feature_cvterm_id}  {
       print "WARNING -- you have not provided params to make dbxref_id or feature_cvterm_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_feature_cvtermprop

  Title   : create_ch_feature_cvtermprop 

  Usage   : my $cdom=create_ch_feature_cvtermprop(%param);

  Parameters: doc - required. XML::DOM::Document
              value - string, optional. 
              feature_cvterm_id - required. macro_id(string) for feature_cvterm element or XML::DOM feature_cvterm element
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_feature_cvtermprop returns a XML::DOM element

=cut

sub create_ch_feature_cvtermprop {
   my %params = @_;
   my %paramitems=('value',1,'feature_cvterm_id',1,'type_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("feature_cvtermprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_cvterm_id} && unless($param{type_id}  {
       print "WARNING -- you have not provided params to make feature_cvterm_id or type_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_feature_dbxref

  Title   : create_ch_feature_dbxref 

  Usage   : my $cdom=create_ch_feature_dbxref(%param);

  Parameters: doc - required. XML::DOM::Document
              dbxref_id - required. macro_id(string) for dbxref element or XML::DOM dbxref element
              feature_id - required. macro_id(string) for feature element or XML::DOM feature element
              is_current - boolean, optional. 

  Function: create_ch_feature_dbxref returns a XML::DOM element

=cut

sub create_ch_feature_dbxref {
   my %params = @_;
   my %paramitems=('dbxref_id',1,'feature_id',1,'is_current',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("feature_dbxref");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{dbxref_id} && unless($param{feature_id}  {
       print "WARNING -- you have not provided params to make dbxref_id or feature_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_feature_expression

  Title   : create_ch_feature_expression 

  Usage   : my $cdom=create_ch_feature_expression(%param);

  Parameters: doc - required. XML::DOM::Document
              feature_id - required. macro_id(string) for feature element or XML::DOM feature element
              expression_id - required. macro_id(string) for expression element or XML::DOM expression element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_feature_expression returns a XML::DOM element

=cut

sub create_ch_feature_expression {
   my %params = @_;
   my %paramitems=('feature_id',1,'expression_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("feature_expression");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_id} && unless($param{expression_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make feature_id or expression_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_feature_expressionprop

  Title   : create_ch_feature_expressionprop 

  Usage   : my $cdom=create_ch_feature_expressionprop(%param);

  Parameters: doc - required. XML::DOM::Document
              feature_expression_id - required. macro_id(string) for feature_expression element or XML::DOM feature_expression element
              value - string, optional. 
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_feature_expressionprop returns a XML::DOM element

=cut

sub create_ch_feature_expressionprop {
   my %params = @_;
   my %paramitems=('feature_expression_id',1,'value',1,'type_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("feature_expressionprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_expression_id} && unless($param{type_id}  {
       print "WARNING -- you have not provided params to make feature_expression_id or type_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_feature_genotype

  Title   : create_ch_feature_genotype 

  Usage   : my $cdom=create_ch_feature_genotype(%param);

  Parameters: doc - required. XML::DOM::Document
              chromosome_id - optional. macro_id(string) for feature element or XML::DOM feature element
              feature_id - required. macro_id(string) for feature element or XML::DOM feature element
              cgroup - integer, required. 
              genotype_id - required. macro_id(string) for genotype element or XML::DOM genotype element
              cvterm_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, required. 

  Function: create_ch_feature_genotype returns a XML::DOM element

=cut

sub create_ch_feature_genotype {
   my %params = @_;
   my %paramitems=('chromosome_id',1,'feature_id',1,'cgroup',1,'genotype_id',1,'cvterm_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("feature_genotype");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_id} && unless($param{cgroup} && unless($param{genotype_id} && unless($param{cvterm_id} && unless($param{rank}  {
       print "WARNING -- you have not provided params to make feature_id or cgroup or genotype_id or cvterm_id or rank, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_feature_interaction

  Title   : create_ch_feature_interaction 

  Usage   : my $cdom=create_ch_feature_interaction(%param);

  Parameters: doc - required. XML::DOM::Document
              feature_id - required. macro_id(string) for feature element or XML::DOM feature element
              interaction_id - required. macro_id(string) for interaction element or XML::DOM interaction element
              role_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_feature_interaction returns a XML::DOM element

=cut

sub create_ch_feature_interaction {
   my %params = @_;
   my %paramitems=('feature_id',1,'interaction_id',1,'role_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("feature_interaction");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_id} && unless($param{interaction_id} && unless($param{role_id}  {
       print "WARNING -- you have not provided params to make feature_id or interaction_id or role_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_feature_interaction_pub

  Title   : create_ch_feature_interaction_pub 

  Usage   : my $cdom=create_ch_feature_interaction_pub(%param);

  Parameters: doc - required. XML::DOM::Document
              feature_interaction_id - required. macro_id(string) for feature_interaction element or XML::DOM feature_interaction element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_feature_interaction_pub returns a XML::DOM element

=cut

sub create_ch_feature_interaction_pub {
   my %params = @_;
   my %paramitems=('feature_interaction_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("feature_interaction_pub");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_interaction_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make feature_interaction_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_feature_interactionprop

  Title   : create_ch_feature_interactionprop 

  Usage   : my $cdom=create_ch_feature_interactionprop(%param);

  Parameters: doc - required. XML::DOM::Document
              value - string, optional. 
              feature_interaction_id - required. macro_id(string) for feature_interaction element or XML::DOM feature_interaction element
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_feature_interactionprop returns a XML::DOM element

=cut

sub create_ch_feature_interactionprop {
   my %params = @_;
   my %paramitems=('value',1,'feature_interaction_id',1,'type_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("feature_interactionprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_interaction_id} && unless($param{type_id}  {
       print "WARNING -- you have not provided params to make feature_interaction_id or type_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_feature_phenotype

  Title   : create_ch_feature_phenotype 

  Usage   : my $cdom=create_ch_feature_phenotype(%param);

  Parameters: doc - required. XML::DOM::Document
              feature_id - required. macro_id(string) for feature element or XML::DOM feature element
              phenotype_id - required. macro_id(string) for phenotype element or XML::DOM phenotype element

  Function: create_ch_feature_phenotype returns a XML::DOM element

=cut

sub create_ch_feature_phenotype {
   my %params = @_;
   my %paramitems=('feature_id',1,'phenotype_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("feature_phenotype");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_id} && unless($param{phenotype_id}  {
       print "WARNING -- you have not provided params to make feature_id or phenotype_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_feature_pub

  Title   : create_ch_feature_pub 

  Usage   : my $cdom=create_ch_feature_pub(%param);

  Parameters: doc - required. XML::DOM::Document
              feature_id - required. macro_id(string) for feature element or XML::DOM feature element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_feature_pub returns a XML::DOM element

=cut

sub create_ch_feature_pub {
   my %params = @_;
   my %paramitems=('feature_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("feature_pub");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make feature_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_feature_pubprop

  Title   : create_ch_feature_pubprop 

  Usage   : my $cdom=create_ch_feature_pubprop(%param);

  Parameters: doc - required. XML::DOM::Document
              value - string, optional. 
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              feature_pub_id - required. macro_id(string) for feature_pub element or XML::DOM feature_pub element
              rank - integer, optional. 

  Function: create_ch_feature_pubprop returns a XML::DOM element

=cut

sub create_ch_feature_pubprop {
   my %params = @_;
   my %paramitems=('value',1,'type_id',1,'feature_pub_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("feature_pubprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{type_id} && unless($param{feature_pub_id}  {
       print "WARNING -- you have not provided params to make type_id or feature_pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_feature_relationship

  Title   : create_ch_feature_relationship 

  Usage   : my $cdom=create_ch_feature_relationship(%param);

  Parameters: doc - required. XML::DOM::Document
              value - string, optional. 
              subject_id - required. macro_id(string) for feature element or XML::DOM feature element
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              object_id - required. macro_id(string) for feature element or XML::DOM feature element
              rank - integer, optional. 

  Function: create_ch_feature_relationship returns a XML::DOM element

=cut

sub create_ch_feature_relationship {
   my %params = @_;
   my %paramitems=('value',1,'subject_id',1,'type_id',1,'object_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("feature_relationship");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{subject_id} && unless($param{type_id} && unless($param{object_id}  {
       print "WARNING -- you have not provided params to make subject_id or type_id or object_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_feature_relationship_pub

  Title   : create_ch_feature_relationship_pub 

  Usage   : my $cdom=create_ch_feature_relationship_pub(%param);

  Parameters: doc - required. XML::DOM::Document
              feature_relationship_id - required. macro_id(string) for feature_relationship element or XML::DOM feature_relationship element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_feature_relationship_pub returns a XML::DOM element

=cut

sub create_ch_feature_relationship_pub {
   my %params = @_;
   my %paramitems=('feature_relationship_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("feature_relationship_pub");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_relationship_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make feature_relationship_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_feature_relationshipprop

  Title   : create_ch_feature_relationshipprop 

  Usage   : my $cdom=create_ch_feature_relationshipprop(%param);

  Parameters: doc - required. XML::DOM::Document
              value - string, optional. 
              feature_relationship_id - required. macro_id(string) for feature_relationship element or XML::DOM feature_relationship element
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_feature_relationshipprop returns a XML::DOM element

=cut

sub create_ch_feature_relationshipprop {
   my %params = @_;
   my %paramitems=('value',1,'feature_relationship_id',1,'type_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("feature_relationshipprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_relationship_id} && unless($param{type_id}  {
       print "WARNING -- you have not provided params to make feature_relationship_id or type_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_feature_relationshipprop_pub

  Title   : create_ch_feature_relationshipprop_pub 

  Usage   : my $cdom=create_ch_feature_relationshipprop_pub(%param);

  Parameters: doc - required. XML::DOM::Document
              feature_relationshipprop_id - required. macro_id(string) for feature_relationshipprop element or XML::DOM feature_relationshipprop element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_feature_relationshipprop_pub returns a XML::DOM element

=cut

sub create_ch_feature_relationshipprop_pub {
   my %params = @_;
   my %paramitems=('feature_relationshipprop_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("feature_relationshipprop_pub");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_relationshipprop_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make feature_relationshipprop_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_feature_synonym

  Title   : create_ch_feature_synonym 

  Usage   : my $cdom=create_ch_feature_synonym(%param);

  Parameters: doc - required. XML::DOM::Document
              feature_id - required. macro_id(string) for feature element or XML::DOM feature element
              synonym_id - required. macro_id(string) for synonym element or XML::DOM synonym element
              is_current - boolean, optional. 
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element
              is_internal - boolean, optional. 

  Function: create_ch_feature_synonym returns a XML::DOM element

=cut

sub create_ch_feature_synonym {
   my %params = @_;
   my %paramitems=('feature_id',1,'synonym_id',1,'is_current',1,'pub_id',1,'is_internal',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("feature_synonym");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_id} && unless($param{synonym_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make feature_id or synonym_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_featureloc

  Title   : create_ch_featureloc 

  Usage   : my $cdom=create_ch_featureloc(%param);

  Parameters: doc - required. XML::DOM::Document
              feature_id - required. macro_id(string) for feature element or XML::DOM feature element
              residue_info - string, optional. 
              fmax - integer, optional. 
              is_fmin_partial - boolean, optional. 
              fmin - integer, optional. 
              phase - integer, optional. 
              strand - smallint, optional. 
              rank - integer, optional. 
              is_fmax_partial - boolean, optional. 
              locgroup - integer, optional. 
              srcfeature_id - optional. macro_id(string) for feature element or XML::DOM feature element

  Function: create_ch_featureloc returns a XML::DOM element

=cut

sub create_ch_featureloc {
   my %params = @_;
   my %paramitems=('feature_id',1,'residue_info',1,'fmax',1,'is_fmin_partial',1,'fmin',1,'phase',1,'strand',1,'rank',1,'is_fmax_partial',1,'locgroup',1,'srcfeature_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("featureloc");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_id}  {
       print "WARNING -- you have not provided params to make feature_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_featureloc_pub

  Title   : create_ch_featureloc_pub 

  Usage   : my $cdom=create_ch_featureloc_pub(%param);

  Parameters: doc - required. XML::DOM::Document
              featureloc_id - required. macro_id(string) for featureloc element or XML::DOM featureloc element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_featureloc_pub returns a XML::DOM element

=cut

sub create_ch_featureloc_pub {
   my %params = @_;
   my %paramitems=('featureloc_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("featureloc_pub");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{featureloc_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make featureloc_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_featuremap

  Title   : create_ch_featuremap 

  Usage   : my $cdom=create_ch_featuremap(%param);

  Parameters: doc - required. XML::DOM::Document
              name - string, optional. 
              description - string, optional. 
              unittype_id - optional. macro_id(string) for cvterm element or XML::DOM cvterm element

  Function: create_ch_featuremap returns a XML::DOM element

=cut

sub create_ch_featuremap {
   my %params = @_;
   my %paramitems=('name',1,'description',1,'unittype_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("featuremap");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
    {
       print "WARNING -- you have not provided params to make , Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_featuremap_pub

  Title   : create_ch_featuremap_pub 

  Usage   : my $cdom=create_ch_featuremap_pub(%param);

  Parameters: doc - required. XML::DOM::Document
              featuremap_id - required. macro_id(string) for featuremap element or XML::DOM featuremap element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_featuremap_pub returns a XML::DOM element

=cut

sub create_ch_featuremap_pub {
   my %params = @_;
   my %paramitems=('featuremap_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("featuremap_pub");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{featuremap_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make featuremap_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_featurepos

  Title   : create_ch_featurepos 

  Usage   : my $cdom=create_ch_featurepos(%param);

  Parameters: doc - required. XML::DOM::Document
              mappos - double, required. 
              feature_id - required. macro_id(string) for feature element or XML::DOM feature element
              featuremap_id - optional. macro_id(string) for featuremap element or XML::DOM featuremap element
              map_feature_id - required. macro_id(string) for feature element or XML::DOM feature element

  Function: create_ch_featurepos returns a XML::DOM element

=cut

sub create_ch_featurepos {
   my %params = @_;
   my %paramitems=('mappos',1,'feature_id',1,'featuremap_id',1,'map_feature_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("featurepos");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{mappos} && unless($param{feature_id} && unless($param{map_feature_id}  {
       print "WARNING -- you have not provided params to make mappos or feature_id or map_feature_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_featureprop

  Title   : create_ch_featureprop 

  Usage   : my $cdom=create_ch_featureprop(%param);

  Parameters: doc - required. XML::DOM::Document
              feature_id - required. macro_id(string) for feature element or XML::DOM feature element
              value - string, optional. 
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_featureprop returns a XML::DOM element

=cut

sub create_ch_featureprop {
   my %params = @_;
   my %paramitems=('feature_id',1,'value',1,'type_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("featureprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_id} && unless($param{type_id}  {
       print "WARNING -- you have not provided params to make feature_id or type_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_featureprop_pub

  Title   : create_ch_featureprop_pub 

  Usage   : my $cdom=create_ch_featureprop_pub(%param);

  Parameters: doc - required. XML::DOM::Document
              featureprop_id - required. macro_id(string) for featureprop element or XML::DOM featureprop element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_featureprop_pub returns a XML::DOM element

=cut

sub create_ch_featureprop_pub {
   my %params = @_;
   my %paramitems=('featureprop_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("featureprop_pub");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{featureprop_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make featureprop_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_featurerange

  Title   : create_ch_featurerange 

  Usage   : my $cdom=create_ch_featurerange(%param);

  Parameters: doc - required. XML::DOM::Document
              feature_id - required. macro_id(string) for feature element or XML::DOM feature element
              featuremap_id - required. macro_id(string) for featuremap element or XML::DOM featuremap element
              rangestr - string, optional. 
              leftstartf_id - required. macro_id(string) for feature element or XML::DOM feature element
              rightendf_id - required. macro_id(string) for feature element or XML::DOM feature element
              rightstartf_id - optional. macro_id(string) for feature element or XML::DOM feature element
              leftendf_id - optional. macro_id(string) for feature element or XML::DOM feature element

  Function: create_ch_featurerange returns a XML::DOM element

=cut

sub create_ch_featurerange {
   my %params = @_;
   my %paramitems=('feature_id',1,'featuremap_id',1,'rangestr',1,'leftstartf_id',1,'rightendf_id',1,'rightstartf_id',1,'leftendf_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("featurerange");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_id} && unless($param{featuremap_id} && unless($param{leftstartf_id} && unless($param{rightendf_id}  {
       print "WARNING -- you have not provided params to make feature_id or featuremap_id or leftstartf_id or rightendf_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_genotype

  Title   : create_ch_genotype 

  Usage   : my $cdom=create_ch_genotype(%param);

  Parameters: doc - required. XML::DOM::Document
              uniquename - string, required. 
              name - string, optional. 
              description - string, optional. 

  Function: create_ch_genotype returns a XML::DOM element

=cut

sub create_ch_genotype {
   my %params = @_;
   my %paramitems=('uniquename',1,'name',1,'description',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("genotype");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{uniquename}  {
       print "WARNING -- you have not provided params to make uniquename, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_interaction

  Title   : create_ch_interaction 

  Usage   : my $cdom=create_ch_interaction(%param);

  Parameters: doc - required. XML::DOM::Document
              uniquename - string, required. 
              description - string, optional. 
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element

  Function: create_ch_interaction returns a XML::DOM element

=cut

sub create_ch_interaction {
   my %params = @_;
   my %paramitems=('uniquename',1,'description',1,'type_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("interaction");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{uniquename} && unless($param{type_id}  {
       print "WARNING -- you have not provided params to make uniquename or type_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_interaction_cell_line

  Title   : create_ch_interaction_cell_line 

  Usage   : my $cdom=create_ch_interaction_cell_line(%param);

  Parameters: doc - required. XML::DOM::Document
              interaction_id - required. macro_id(string) for interaction element or XML::DOM interaction element
              cell_line_id - required. macro_id(string) for cell_line element or XML::DOM cell_line element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_interaction_cell_line returns a XML::DOM element

=cut

sub create_ch_interaction_cell_line {
   my %params = @_;
   my %paramitems=('interaction_id',1,'cell_line_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("interaction_cell_line");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{interaction_id} && unless($param{cell_line_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make interaction_id or cell_line_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_interaction_cvterm

  Title   : create_ch_interaction_cvterm 

  Usage   : my $cdom=create_ch_interaction_cvterm(%param);

  Parameters: doc - required. XML::DOM::Document
              interaction_id - required. macro_id(string) for interaction element or XML::DOM interaction element
              cvterm_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element

  Function: create_ch_interaction_cvterm returns a XML::DOM element

=cut

sub create_ch_interaction_cvterm {
   my %params = @_;
   my %paramitems=('interaction_id',1,'cvterm_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("interaction_cvterm");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{interaction_id} && unless($param{cvterm_id}  {
       print "WARNING -- you have not provided params to make interaction_id or cvterm_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_interaction_cvtermprop

  Title   : create_ch_interaction_cvtermprop 

  Usage   : my $cdom=create_ch_interaction_cvtermprop(%param);

  Parameters: doc - required. XML::DOM::Document
              value - string, optional. 
              interaction_cvterm_id - required. macro_id(string) for interaction_cvterm element or XML::DOM interaction_cvterm element
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_interaction_cvtermprop returns a XML::DOM element

=cut

sub create_ch_interaction_cvtermprop {
   my %params = @_;
   my %paramitems=('value',1,'interaction_cvterm_id',1,'type_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("interaction_cvtermprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{interaction_cvterm_id} && unless($param{type_id}  {
       print "WARNING -- you have not provided params to make interaction_cvterm_id or type_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_interaction_expression

  Title   : create_ch_interaction_expression 

  Usage   : my $cdom=create_ch_interaction_expression(%param);

  Parameters: doc - required. XML::DOM::Document
              interaction_id - required. macro_id(string) for interaction element or XML::DOM interaction element
              expression_id - required. macro_id(string) for expression element or XML::DOM expression element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_interaction_expression returns a XML::DOM element

=cut

sub create_ch_interaction_expression {
   my %params = @_;
   my %paramitems=('interaction_id',1,'expression_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("interaction_expression");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{interaction_id} && unless($param{expression_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make interaction_id or expression_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_interaction_expressionprop

  Title   : create_ch_interaction_expressionprop 

  Usage   : my $cdom=create_ch_interaction_expressionprop(%param);

  Parameters: doc - required. XML::DOM::Document
              value - string, optional. 
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 
              interaction_expression_id - required. macro_id(string) for interaction_expression element or XML::DOM interaction_expression element

  Function: create_ch_interaction_expressionprop returns a XML::DOM element

=cut

sub create_ch_interaction_expressionprop {
   my %params = @_;
   my %paramitems=('value',1,'type_id',1,'rank',1,'interaction_expression_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("interaction_expressionprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{type_id} && unless($param{interaction_expression_id}  {
       print "WARNING -- you have not provided params to make type_id or interaction_expression_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_interaction_pub

  Title   : create_ch_interaction_pub 

  Usage   : my $cdom=create_ch_interaction_pub(%param);

  Parameters: doc - required. XML::DOM::Document
              interaction_id - required. macro_id(string) for interaction element or XML::DOM interaction element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_interaction_pub returns a XML::DOM element

=cut

sub create_ch_interaction_pub {
   my %params = @_;
   my %paramitems=('interaction_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("interaction_pub");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{interaction_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make interaction_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_interactionprop

  Title   : create_ch_interactionprop 

  Usage   : my $cdom=create_ch_interactionprop(%param);

  Parameters: doc - required. XML::DOM::Document
              value - string, optional. 
              interaction_id - required. macro_id(string) for interaction element or XML::DOM interaction element
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_interactionprop returns a XML::DOM element

=cut

sub create_ch_interactionprop {
   my %params = @_;
   my %paramitems=('value',1,'interaction_id',1,'type_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("interactionprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{interaction_id} && unless($param{type_id}  {
       print "WARNING -- you have not provided params to make interaction_id or type_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_library

  Title   : create_ch_library 

  Usage   : my $cdom=create_ch_library(%param);

  Parameters: doc - required. XML::DOM::Document
              uniquename - string, required. 
              name - string, optional. 
              timeaccessioned - timestamp without time zone, optional. 
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              organism_id - required. macro_id(string) for organism element or XML::DOM organism element
              is_obsolete - boolean, optional. 
              timelastmodified - timestamp without time zone, optional. 

  Function: create_ch_library returns a XML::DOM element

=cut

sub create_ch_library {
   my %params = @_;
   my %paramitems=('uniquename',1,'name',1,'timeaccessioned',1,'type_id',1,'organism_id',1,'is_obsolete',1,'timelastmodified',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("library");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{uniquename} && unless($param{type_id} && unless($param{organism_id}  {
       print "WARNING -- you have not provided params to make uniquename or type_id or organism_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_library_cvterm

  Title   : create_ch_library_cvterm 

  Usage   : my $cdom=create_ch_library_cvterm(%param);

  Parameters: doc - required. XML::DOM::Document
              library_id - required. macro_id(string) for library element or XML::DOM library element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element
              cvterm_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element

  Function: create_ch_library_cvterm returns a XML::DOM element

=cut

sub create_ch_library_cvterm {
   my %params = @_;
   my %paramitems=('library_id',1,'pub_id',1,'cvterm_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("library_cvterm");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{library_id} && unless($param{pub_id} && unless($param{cvterm_id}  {
       print "WARNING -- you have not provided params to make library_id or pub_id or cvterm_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_library_dbxref

  Title   : create_ch_library_dbxref 

  Usage   : my $cdom=create_ch_library_dbxref(%param);

  Parameters: doc - required. XML::DOM::Document
              dbxref_id - required. macro_id(string) for dbxref element or XML::DOM dbxref element
              library_id - required. macro_id(string) for library element or XML::DOM library element
              is_current - boolean, optional. 

  Function: create_ch_library_dbxref returns a XML::DOM element

=cut

sub create_ch_library_dbxref {
   my %params = @_;
   my %paramitems=('dbxref_id',1,'library_id',1,'is_current',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("library_dbxref");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{dbxref_id} && unless($param{library_id}  {
       print "WARNING -- you have not provided params to make dbxref_id or library_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_library_expression

  Title   : create_ch_library_expression 

  Usage   : my $cdom=create_ch_library_expression(%param);

  Parameters: doc - required. XML::DOM::Document
              library_id - required. macro_id(string) for library element or XML::DOM library element
              expression_id - required. macro_id(string) for expression element or XML::DOM expression element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_library_expression returns a XML::DOM element

=cut

sub create_ch_library_expression {
   my %params = @_;
   my %paramitems=('library_id',1,'expression_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("library_expression");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{library_id} && unless($param{expression_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make library_id or expression_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_library_expressionprop

  Title   : create_ch_library_expressionprop 

  Usage   : my $cdom=create_ch_library_expressionprop(%param);

  Parameters: doc - required. XML::DOM::Document
              value - string, optional. 
              library_expression_id - required. macro_id(string) for library_expression element or XML::DOM library_expression element
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_library_expressionprop returns a XML::DOM element

=cut

sub create_ch_library_expressionprop {
   my %params = @_;
   my %paramitems=('value',1,'library_expression_id',1,'type_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("library_expressionprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{library_expression_id} && unless($param{type_id}  {
       print "WARNING -- you have not provided params to make library_expression_id or type_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_library_feature

  Title   : create_ch_library_feature 

  Usage   : my $cdom=create_ch_library_feature(%param);

  Parameters: doc - required. XML::DOM::Document
              feature_id - required. macro_id(string) for feature element or XML::DOM feature element
              library_id - required. macro_id(string) for library element or XML::DOM library element

  Function: create_ch_library_feature returns a XML::DOM element

=cut

sub create_ch_library_feature {
   my %params = @_;
   my %paramitems=('feature_id',1,'library_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("library_feature");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{feature_id} && unless($param{library_id}  {
       print "WARNING -- you have not provided params to make feature_id or library_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_library_featureprop

  Title   : create_ch_library_featureprop 

  Usage   : my $cdom=create_ch_library_featureprop(%param);

  Parameters: doc - required. XML::DOM::Document
              value - string, optional. 
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 
              library_feature_id - required. macro_id(string) for library_feature element or XML::DOM library_feature element

  Function: create_ch_library_featureprop returns a XML::DOM element

=cut

sub create_ch_library_featureprop {
   my %params = @_;
   my %paramitems=('value',1,'type_id',1,'rank',1,'library_feature_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("library_featureprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{type_id} && unless($param{library_feature_id}  {
       print "WARNING -- you have not provided params to make type_id or library_feature_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_library_interaction

  Title   : create_ch_library_interaction 

  Usage   : my $cdom=create_ch_library_interaction(%param);

  Parameters: doc - required. XML::DOM::Document
              interaction_id - required. macro_id(string) for interaction element or XML::DOM interaction element
              library_id - required. macro_id(string) for library element or XML::DOM library element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_library_interaction returns a XML::DOM element

=cut

sub create_ch_library_interaction {
   my %params = @_;
   my %paramitems=('interaction_id',1,'library_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("library_interaction");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{interaction_id} && unless($param{library_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make interaction_id or library_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_library_pub

  Title   : create_ch_library_pub 

  Usage   : my $cdom=create_ch_library_pub(%param);

  Parameters: doc - required. XML::DOM::Document
              library_id - required. macro_id(string) for library element or XML::DOM library element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_library_pub returns a XML::DOM element

=cut

sub create_ch_library_pub {
   my %params = @_;
   my %paramitems=('library_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("library_pub");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{library_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make library_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_library_relationship

  Title   : create_ch_library_relationship 

  Usage   : my $cdom=create_ch_library_relationship(%param);

  Parameters: doc - required. XML::DOM::Document
              subject_id - required. macro_id(string) for library element or XML::DOM library element
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              object_id - required. macro_id(string) for library element or XML::DOM library element

  Function: create_ch_library_relationship returns a XML::DOM element

=cut

sub create_ch_library_relationship {
   my %params = @_;
   my %paramitems=('subject_id',1,'type_id',1,'object_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("library_relationship");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{subject_id} && unless($param{type_id} && unless($param{object_id}  {
       print "WARNING -- you have not provided params to make subject_id or type_id or object_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_library_relationship_pub

  Title   : create_ch_library_relationship_pub 

  Usage   : my $cdom=create_ch_library_relationship_pub(%param);

  Parameters: doc - required. XML::DOM::Document
              library_relationship_id - required. macro_id(string) for library_relationship element or XML::DOM library_relationship element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_library_relationship_pub returns a XML::DOM element

=cut

sub create_ch_library_relationship_pub {
   my %params = @_;
   my %paramitems=('library_relationship_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("library_relationship_pub");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{library_relationship_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make library_relationship_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_library_synonym

  Title   : create_ch_library_synonym 

  Usage   : my $cdom=create_ch_library_synonym(%param);

  Parameters: doc - required. XML::DOM::Document
              library_id - required. macro_id(string) for library element or XML::DOM library element
              synonym_id - required. macro_id(string) for synonym element or XML::DOM synonym element
              is_current - boolean, optional. 
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element
              is_internal - boolean, optional. 

  Function: create_ch_library_synonym returns a XML::DOM element

=cut

sub create_ch_library_synonym {
   my %params = @_;
   my %paramitems=('library_id',1,'synonym_id',1,'is_current',1,'pub_id',1,'is_internal',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("library_synonym");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{library_id} && unless($param{synonym_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make library_id or synonym_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_libraryprop

  Title   : create_ch_libraryprop 

  Usage   : my $cdom=create_ch_libraryprop(%param);

  Parameters: doc - required. XML::DOM::Document
              value - string, optional. 
              library_id - required. macro_id(string) for library element or XML::DOM library element
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_libraryprop returns a XML::DOM element

=cut

sub create_ch_libraryprop {
   my %params = @_;
   my %paramitems=('value',1,'library_id',1,'type_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("libraryprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{library_id} && unless($param{type_id}  {
       print "WARNING -- you have not provided params to make library_id or type_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_libraryprop_pub

  Title   : create_ch_libraryprop_pub 

  Usage   : my $cdom=create_ch_libraryprop_pub(%param);

  Parameters: doc - required. XML::DOM::Document
              libraryprop_id - required. macro_id(string) for libraryprop element or XML::DOM libraryprop element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_libraryprop_pub returns a XML::DOM element

=cut

sub create_ch_libraryprop_pub {
   my %params = @_;
   my %paramitems=('libraryprop_id',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("libraryprop_pub");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{libraryprop_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make libraryprop_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_lock

  Title   : create_ch_lock 

  Usage   : my $cdom=create_ch_lock(%param);

  Parameters: doc - required. XML::DOM::Document
              task - string, optional. 
              username - string, optional. 
              lockstatus - boolean, optional. 
              lockrank - integer, optional. 
              comment - string, optional. 
              chadoxmlfile - string, optional. 
              lockname - string, required. 
              locktype - string, optional. 
              timelastmodified - timestamp without time zone, optional. 
              timeaccessioend - timestamp without time zone, optional. 

  Function: create_ch_lock returns a XML::DOM element

=cut

sub create_ch_lock {
   my %params = @_;
   my %paramitems=('task',1,'username',1,'lockstatus',1,'lockrank',1,'comment',1,'chadoxmlfile',1,'lockname',1,'locktype',1,'timelastmodified',1,'timeaccessioend',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("lock");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{lockname}  {
       print "WARNING -- you have not provided params to make lockname, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_organism

  Title   : create_ch_organism 

  Usage   : my $cdom=create_ch_organism(%param);

  Parameters: doc - required. XML::DOM::Document
              genus - string, required. 
              species - string, required. 
              common_name - string, optional. 
              comment - string, optional. 
              abbreviation - string, optional. 

  Function: create_ch_organism returns a XML::DOM element

=cut

sub create_ch_organism {
   my %params = @_;
   my %paramitems=('genus',1,'species',1,'common_name',1,'comment',1,'abbreviation',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("organism");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{genus} && unless($param{species}  {
       print "WARNING -- you have not provided params to make genus or species, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_organism_dbxref

  Title   : create_ch_organism_dbxref 

  Usage   : my $cdom=create_ch_organism_dbxref(%param);

  Parameters: doc - required. XML::DOM::Document
              dbxref_id - required. macro_id(string) for dbxref element or XML::DOM dbxref element
              organism_id - required. macro_id(string) for organism element or XML::DOM organism element

  Function: create_ch_organism_dbxref returns a XML::DOM element

=cut

sub create_ch_organism_dbxref {
   my %params = @_;
   my %paramitems=('dbxref_id',1,'organism_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("organism_dbxref");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{dbxref_id} && unless($param{organism_id}  {
       print "WARNING -- you have not provided params to make dbxref_id or organism_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_organismprop

  Title   : create_ch_organismprop 

  Usage   : my $cdom=create_ch_organismprop(%param);

  Parameters: doc - required. XML::DOM::Document
              value - string, optional. 
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              organism_id - required. macro_id(string) for organism element or XML::DOM organism element
              rank - integer, optional. 

  Function: create_ch_organismprop returns a XML::DOM element

=cut

sub create_ch_organismprop {
   my %params = @_;
   my %paramitems=('value',1,'type_id',1,'organism_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("organismprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{type_id} && unless($param{organism_id}  {
       print "WARNING -- you have not provided params to make type_id or organism_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_phendesc

  Title   : create_ch_phendesc 

  Usage   : my $cdom=create_ch_phendesc(%param);

  Parameters: doc - required. XML::DOM::Document
              description - string, required. 
              genotype_id - required. macro_id(string) for genotype element or XML::DOM genotype element
              environment_id - required. macro_id(string) for environment element or XML::DOM environment element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element

  Function: create_ch_phendesc returns a XML::DOM element

=cut

sub create_ch_phendesc {
   my %params = @_;
   my %paramitems=('description',1,'genotype_id',1,'environment_id',1,'pub_id',1,'type_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("phendesc");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{description} && unless($param{genotype_id} && unless($param{environment_id} && unless($param{pub_id} && unless($param{type_id}  {
       print "WARNING -- you have not provided params to make description or genotype_id or environment_id or pub_id or type_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_phenotype

  Title   : create_ch_phenotype 

  Usage   : my $cdom=create_ch_phenotype(%param);

  Parameters: doc - required. XML::DOM::Document
              observable_id - optional. macro_id(string) for cvterm element or XML::DOM cvterm element
              uniquename - string, required. 
              cvalue_id - optional. macro_id(string) for cvterm element or XML::DOM cvterm element
              value - string, optional. 
              assay_id - optional. macro_id(string) for cvterm element or XML::DOM cvterm element
              attr_id - optional. macro_id(string) for cvterm element or XML::DOM cvterm element

  Function: create_ch_phenotype returns a XML::DOM element

=cut

sub create_ch_phenotype {
   my %params = @_;
   my %paramitems=('observable_id',1,'uniquename',1,'cvalue_id',1,'value',1,'assay_id',1,'attr_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("phenotype");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{uniquename}  {
       print "WARNING -- you have not provided params to make uniquename, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_phenotype_comparison

  Title   : create_ch_phenotype_comparison 

  Usage   : my $cdom=create_ch_phenotype_comparison(%param);

  Parameters: doc - required. XML::DOM::Document
              phenotype1_id - required. macro_id(string) for phenotype element or XML::DOM phenotype element
              genotype1_id - required. macro_id(string) for genotype element or XML::DOM genotype element
              environment1_id - required. macro_id(string) for environment element or XML::DOM environment element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element
              genotype2_id - required. macro_id(string) for genotype element or XML::DOM genotype element
              phenotype2_id - optional. macro_id(string) for phenotype element or XML::DOM phenotype element
              organism_id - required. macro_id(string) for organism element or XML::DOM organism element
              environment2_id - required. macro_id(string) for environment element or XML::DOM environment element

  Function: create_ch_phenotype_comparison returns a XML::DOM element

=cut

sub create_ch_phenotype_comparison {
   my %params = @_;
   my %paramitems=('phenotype1_id',1,'genotype1_id',1,'environment1_id',1,'pub_id',1,'genotype2_id',1,'phenotype2_id',1,'organism_id',1,'environment2_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("phenotype_comparison");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{phenotype1_id} && unless($param{genotype1_id} && unless($param{environment1_id} && unless($param{pub_id} && unless($param{genotype2_id} && unless($param{organism_id} && unless($param{environment2_id}  {
       print "WARNING -- you have not provided params to make phenotype1_id or genotype1_id or environment1_id or pub_id or genotype2_id or organism_id or environment2_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_phenotype_comparison_cvterm

  Title   : create_ch_phenotype_comparison_cvterm 

  Usage   : my $cdom=create_ch_phenotype_comparison_cvterm(%param);

  Parameters: doc - required. XML::DOM::Document
              phenotype_comparison_id - required. macro_id(string) for phenotype_comparison element or XML::DOM phenotype_comparison element
              cvterm_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_phenotype_comparison_cvterm returns a XML::DOM element

=cut

sub create_ch_phenotype_comparison_cvterm {
   my %params = @_;
   my %paramitems=('phenotype_comparison_id',1,'cvterm_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("phenotype_comparison_cvterm");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{phenotype_comparison_id} && unless($param{cvterm_id}  {
       print "WARNING -- you have not provided params to make phenotype_comparison_id or cvterm_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_phenotype_cvterm

  Title   : create_ch_phenotype_cvterm 

  Usage   : my $cdom=create_ch_phenotype_cvterm(%param);

  Parameters: doc - required. XML::DOM::Document
              cvterm_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 
              phenotype_id - required. macro_id(string) for phenotype element or XML::DOM phenotype element

  Function: create_ch_phenotype_cvterm returns a XML::DOM element

=cut

sub create_ch_phenotype_cvterm {
   my %params = @_;
   my %paramitems=('cvterm_id',1,'rank',1,'phenotype_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("phenotype_cvterm");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{cvterm_id} && unless($param{phenotype_id}  {
       print "WARNING -- you have not provided params to make cvterm_id or phenotype_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_phenstatement

  Title   : create_ch_phenstatement 

  Usage   : my $cdom=create_ch_phenstatement(%param);

  Parameters: doc - required. XML::DOM::Document
              genotype_id - required. macro_id(string) for genotype element or XML::DOM genotype element
              environment_id - required. macro_id(string) for environment element or XML::DOM environment element
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              phenotype_id - required. macro_id(string) for phenotype element or XML::DOM phenotype element

  Function: create_ch_phenstatement returns a XML::DOM element

=cut

sub create_ch_phenstatement {
   my %params = @_;
   my %paramitems=('genotype_id',1,'environment_id',1,'pub_id',1,'type_id',1,'phenotype_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("phenstatement");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{genotype_id} && unless($param{environment_id} && unless($param{pub_id} && unless($param{type_id} && unless($param{phenotype_id}  {
       print "WARNING -- you have not provided params to make genotype_id or environment_id or pub_id or type_id or phenotype_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_project

  Title   : create_ch_project 

  Usage   : my $cdom=create_ch_project(%param);

  Parameters: doc - required. XML::DOM::Document
              name - string, required. 
              description - string, required. 

  Function: create_ch_project returns a XML::DOM element

=cut

sub create_ch_project {
   my %params = @_;
   my %paramitems=('name',1,'description',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("project");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{name} && unless($param{description}  {
       print "WARNING -- you have not provided params to make name or description, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_pub

  Title   : create_ch_pub 

  Usage   : my $cdom=create_ch_pub(%param);

  Parameters: doc - required. XML::DOM::Document
              uniquename - string, required. 
              volume - string, optional. 
              pyear - string, optional. 
              issue - string, optional. 
              series_name - string, optional. 
              volumetitle - string, optional. 
              miniref - string, optional. 
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              title - string, optional. 
              publisher - string, optional. 
              is_obsolete - boolean, optional. 
              pubplace - string, optional. 
              pages - string, optional. 

  Function: create_ch_pub returns a XML::DOM element

=cut

sub create_ch_pub {
   my %params = @_;
   my %paramitems=('uniquename',1,'volume',1,'pyear',1,'issue',1,'series_name',1,'volumetitle',1,'miniref',1,'type_id',1,'title',1,'publisher',1,'is_obsolete',1,'pubplace',1,'pages',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("pub");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{uniquename} && unless($param{type_id}  {
       print "WARNING -- you have not provided params to make uniquename or type_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_pub_dbxref

  Title   : create_ch_pub_dbxref 

  Usage   : my $cdom=create_ch_pub_dbxref(%param);

  Parameters: doc - required. XML::DOM::Document
              dbxref_id - required. macro_id(string) for dbxref element or XML::DOM dbxref element
              is_current - boolean, optional. 
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_pub_dbxref returns a XML::DOM element

=cut

sub create_ch_pub_dbxref {
   my %params = @_;
   my %paramitems=('dbxref_id',1,'is_current',1,'pub_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("pub_dbxref");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{dbxref_id} && unless($param{pub_id}  {
       print "WARNING -- you have not provided params to make dbxref_id or pub_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_pub_relationship

  Title   : create_ch_pub_relationship 

  Usage   : my $cdom=create_ch_pub_relationship(%param);

  Parameters: doc - required. XML::DOM::Document
              subject_id - required. macro_id(string) for pub element or XML::DOM pub element
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              object_id - required. macro_id(string) for pub element or XML::DOM pub element

  Function: create_ch_pub_relationship returns a XML::DOM element

=cut

sub create_ch_pub_relationship {
   my %params = @_;
   my %paramitems=('subject_id',1,'type_id',1,'object_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("pub_relationship");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{subject_id} && unless($param{type_id} && unless($param{object_id}  {
       print "WARNING -- you have not provided params to make subject_id or type_id or object_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_pubauthor

  Title   : create_ch_pubauthor 

  Usage   : my $cdom=create_ch_pubauthor(%param);

  Parameters: doc - required. XML::DOM::Document
              surname - string, required. 
              givennames - string, optional. 
              editor - boolean, optional. 
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element
              suffix - string, optional. 
              rank - integer, required. 

  Function: create_ch_pubauthor returns a XML::DOM element

=cut

sub create_ch_pubauthor {
   my %params = @_;
   my %paramitems=('surname',1,'givennames',1,'editor',1,'pub_id',1,'suffix',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("pubauthor");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{surname} && unless($param{pub_id} && unless($param{rank}  {
       print "WARNING -- you have not provided params to make surname or pub_id or rank, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_pubprop

  Title   : create_ch_pubprop 

  Usage   : my $cdom=create_ch_pubprop(%param);

  Parameters: doc - required. XML::DOM::Document
              value - string, required. 
              pub_id - required. macro_id(string) for pub element or XML::DOM pub element
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element
              rank - integer, optional. 

  Function: create_ch_pubprop returns a XML::DOM element

=cut

sub create_ch_pubprop {
   my %params = @_;
   my %paramitems=('value',1,'pub_id',1,'type_id',1,'rank',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("pubprop");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{value} && unless($param{pub_id} && unless($param{type_id}  {
       print "WARNING -- you have not provided params to make value or pub_id or type_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_synonym

  Title   : create_ch_synonym 

  Usage   : my $cdom=create_ch_synonym(%param);

  Parameters: doc - required. XML::DOM::Document
              synonym_sgml - string, required. 
              name - string, required. 
              type_id - required. macro_id(string) for cvterm element or XML::DOM cvterm element

  Function: create_ch_synonym returns a XML::DOM element

=cut

sub create_ch_synonym {
   my %params = @_;
   my %paramitems=('synonym_sgml',1,'name',1,'type_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("synonym");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{synonym_sgml} && unless($param{name} && unless($param{type_id}  {
       print "WARNING -- you have not provided params to make synonym_sgml or name or type_id, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_tableinfo

  Title   : create_ch_tableinfo 

  Usage   : my $cdom=create_ch_tableinfo(%param);

  Parameters: doc - required. XML::DOM::Document
              primary_key_column - string, optional. 
              superclass_table_id - integer, optional. 
              name - string, required. 
              is_updateable - integer, optional. 
              modification_date - date, optional. 
              is_view - integer, optional. 
              view_on_table_id - integer, optional. 

  Function: create_ch_tableinfo returns a XML::DOM element

=cut

sub create_ch_tableinfo {
   my %params = @_;
   my %paramitems=('primary_key_column',1,'superclass_table_id',1,'name',1,'is_updateable',1,'modification_date',1,'is_view',1,'view_on_table_id',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("tableinfo");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{name}  {
       print "WARNING -- you have not provided params to make name, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


=head2 create_ch_update_track

  Title   : create_ch_update_track 

  Usage   : my $cdom=create_ch_update_track(%param);

  Parameters: doc - required. XML::DOM::Document
              fbid - string, required. 
              author - string, required. 
              release - string, required. 
              time_update - timestamp without time zone, optional. 
              annotation_id - string, optional. 
              comment - string, optional. 
              statement - string, required. 

  Function: create_ch_update_track returns a XML::DOM element

=cut

sub create_ch_update_track {
   my %params = @_;
   my %paramitems=('fbid',1,'author',1,'release',1,'time_update',1,'annotation_id',1,'comment',1,'statement',1);

   print "WARNING -- no XML::DOM::Document specified\n" and return unless $params{doc};
   my $ldoc = $params{doc};    ## XML::DOM::Document
   my $fd_el = $ldoc->createElement("update_track");
    
   $fd_el->setAttribute("id",$params{macro_id}) if $params{macro_id};     
    
   unless($param{fbid} && unless($param{author} && unless($param{release} && unless($param{statement}  {
       print "WARNING -- you have not provided params to make fbid or author or release or statement, Sorry\n" and return;
   }

   foreach my $p (keys %params){
        next if (!exists($paramitems{$p}));
        if(exists($params{$p}) && $params{$p} ne ""){
            $fd_el->appendChild(_create_doc_element($ldoc,$p,$params{$p}));
        }
   }

    return $fd_el;
}


##function for building doc elements

sub _create_doc_element{
    my $doc=shift;
    my $name=shift;
    my $val=shift;
    
    my $eval;
    my $el = doc->createElement($name);
    if(!ref($val)){
        $eval = $doc->createTextNode($val);
    } else{
        $eval = $val;
    }
    $el->appendChild($eval);
    return $el;
}
1;
__END__
