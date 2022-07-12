package FlyBase::ReadChado;

use 5.008004;
use strict;
use warnings;
use Carp qw(croak);
require Exporter;
our @ISA = qw(Exporter);
use encoding 'utf-8';
use DBI;

our %EXPORT_TAGS = (
    'all' => [
        qw(get_feature get_dbxref get_analysis get_analysisfeature get_cv get_cvterm get_cvterm_dbxref 
         get_cvtermprop get_db get_dbxref get_dbxrefprop get_environment get_environment_cvterm get_expression
         get_expression_cvterm get_expression_image get_expression_pub get_feature_cvterm get_feature_cvtermprop
         get_feature_dbxref get_feature_expression get_feature_genotype get_feature_phenotype get_feature_pub 
         get_feature_pubprop get_feature_relationship get_feature_relationship_pub get_feature_relationshipprop
         get_feature_relationshipprop_pub get_feature_synonym get_featureloc get_featureloc_pub get_genotype
         get_library get_library_cvterm get_library_feature get_library_pub get_library_synonym get_libraryprop
         get_organism get_phendesc get_phenotype get_phenotype_comparison get_phenotype_comparison_cvterm 
         get_phenotype_cvterm get_phenstatement get_pub get_pub_dbxref get_pub_relationship get_pubauthor
         get_pubprop get_synonym)
    ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = (
    @{ $EXPORT_TAGS{'all'} }

);

our $VERSION = '0.01';

sub get_feature{
    my %params=@_;
    my @result=();
    my $state="select * from feature where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        if(exists($feature->{dbxref_id})){
            $feature->{dbxref_id}=get_dbxref(DB=>$params{DB}, dbxref_id=>$feature->{dbxref_id});
        }
        $feature->{organism_id}=get_organism(DB=>$params{DB}, organism_id=>$feature->{organism_id});
        $feature->{type_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{type_id});
        push(@result,$feature);
    }
    return \@result;
}
sub get_dbxref{
    my %params=@_;
    my @result=();
    my $state="select * from dbxref where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{db_id}=get_organism(DB=>$params{DB}, db_id=>$feature->{db_id});
        push(@result,$feature);
    }
    return \@result;
}

sub get_db{
    my %params=@_;
    my @result=();
    my $state="select * from db where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        push(@result,$feature);
    }
    return \@result; 
}

sub get_orgnaism{
    my %params=@_;
    my @result=();
    my $state="select * from organism where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        push(@result,$feature);
    }
    return \@result; 
}
sub get_cvterm{
    my %params=@_;
    my @result=();
    my $state="select * from cvterm where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{dbxref_id}=get_dbxref(DB=>$params{DB}, dbxref_id=>$feature->{dbxref_id});
        $feature->{cv_id}=get_cv(DB=>$params{DB}, cv_id=>$feature->{cv_id});
        push(@result,$feature);
    }
    return \@result; 
}

sub get_cv{
    my %params=@_;
    my @result=();
    my $state="select * from cv where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        push(@result,$feature);
    }
    return \@result; 
}

sub get_analysis{
    my %params=@_;
    my @result=();
    my $state="select * from analysis where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        push(@result,$feature);
    }
    return \@result;   
}
sub get_analysisfeature{
    my %params=@_;
    my @result=();
    my $state="select * from analysisfeature where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{analysis_id}=get_analysis(DB=>$params{DB},analysis_id=>$feature->{analysis_id});
        $feature->{feature_id}=get_feature(DB=>$params{DB},feature_id=>$feature->{feature_id});
        push(@result,$feature);
    }
    return \@result;   
}
### analysisprop
### audit_chado
### contact
### cvterm_dbxref
### cvterm_relationship
### cvtermpath
### cvtermsynonym
sub get_cvtermprop{
    my %params=@_;
    my @result=();
    my $state="select * from cvtermprop where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{cvterm_id}=get_cvterm(DB=>$params{DB},cvterm_id=>$feature->{cvterm_id});
        $feature->{type_id}=get_cvterm(DB=>$params{DB},type_id=>$feature->{type_id});
        push(@result,$feature);
    }
    return \@result;       
}
### dbxrefprop
### eimage
sub get_eimage{
    my %params=@_;
    my @result=();
    my $state="select * from eimage where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
               push(@result,$feature);
    }
    return \@result;   
}
### environment
sub get_environment{
    my %params=@_;
    my @result=();
    my $state="select * from environment where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
       
        push(@result,$feature);
    }
    return \@result;   
}
### environment_cvterm
sub get_environment_cvterm{
    my %params=@_;
    my @result=();
    my $state="select * from environment_cvterm where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{cvterm_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{cvterm_id});
        $feature->{environment_id}=get_environment(DB=>$params{DB},environment_id=>$feature->{environment_id});
        push(@result,$feature);
    }
    return \@result;   
}
### expression
sub get_expression{
    my %params=@_;
    my @result=();
    my $state="select * from expression where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        push(@result,$feature);
    }
    return \@result;   
}
### expression_cvterm          
sub get_expression_cvterm{
    my %params=@_;
    my @result=();
    my $state="select * from expression_cvterm where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{cvterm_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{cvterm_id});
        $feature->{expression_id}=get_expression(DB=>$params{DB},expression_id=>$feature->{expression_id});
        push(@result,$feature);
    }
    return \@result;   
}
### expression_image
sub get_expression_image{
    my %params=@_;
    my @result=();
    my $state="select * from expression_image where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{eimage_id}=get_cvterm(DB=>$params{DB}, eimage_id=>$feature->{eimage_id});
        $feature->{expression_id}=get_expression(DB=>$params{DB},expression_id=>$feature->{expression_id});
        push(@result,$feature);
    }
    return \@result;   
}      
### expression_pub
sub get_expression_pub{
    my %params=@_;
    my @result=();
    my $state="select * from expression_pub where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{expression_id}=get_expression(DB=>$params{DB}, expression_id=>$feature->{expression_id});
        $feature->{pub_id}=get_pub(DB=>$params{DB},pub_id=>$feature->{pub_id});
        push(@result,$feature);
    }
    return \@result;   
}          
### feature_cvterm 
sub get_feature_cvterm{
    my %params=@_;
    my @result=();
    my $state="select * from feature_cvterm where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{cvterm_id}=get_cvterm(DB=>$params{DB},cvterm_id=>$feature->{cvterm_id});
        $feature->{feature_id}=get_cvterm(DB=>$params{DB},type_id=>$feature->{feature_id});
        $feature->{pub_id}=get_pub(DB=>$params{DB}, pub_id=>$feature->{pub_id});
        push(@result,$feature);
    }
    return \@result;   
}
### feature_cvterm_dbxref
### feature_cvtermprop
sub get_feature_cvtermprop{
    my %params=@_;
    my @result=();
    my $state="select * from feature_cvtermprop where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{type_id}=get_cvterm(DB=>$params{DB},cvterm_id=>$feature->{type_id});
        $feature->{feature_cvterm_id}=get_feature_cvterm(DB=>$params{DB},feature_cvterm_id=>$feature->{feature_cvterm_id});
        push(@result,$feature);
    }
    return \@result;   
}
###feature_dbxref
sub get_feature_dbxref{
    my %params=@_;
    my @result=();
    my $state="select * from feature_dbxref where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{dbxref_id}=get_cvterm(DB=>$params{DB},dbxref_id=>$feature->{dbxref_id});
        $feature->{feature_id}=get_feature(DB=>$params{DB},feature_id=>$feature->{feature_id});
        push(@result,$feature);
    }
    return \@result;   
}
### feature_expression  
sub get_feature_expression{
    my %params=@_;
    my @result=();
    my $state="select * from feature_expression where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{expression_id}=get_expression(DB=>$params{DB},expression_id=>$feature->{expression_id});
        $feature->{feature_id}=get_feature(DB=>$params{DB},feature_id=>$feature->{feature_id});
        push(@result,$feature);
    }
    return \@result;   
}
### feature_genotype          
sub get_feature_genotype{
    my %params=@_;
    my @result=();
    my $state="select * from feature_genotype where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{genotype_id}=get_genotype(DB=>$params{DB}, genotype_id=>$feature->{genotype_id});
        $feature->{feature_id}=get_feature(DB=>$params{DB},feature_id=>$feature->{feature_id});
        push(@result,$feature);
    }
    return \@result;   
}
### feature_phenotype
### feature_pub  
sub get_feature_pub{
    my %params=@_;
    my @result=();
    my $state="select * from feature_pub where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{pub_id}=get_pub(DB=>$params{DB}, pub_id=>$feature->{pub_id});
        $feature->{feature_id}=get_feature(DB=>$params{DB},feature_id=>$feature->{feature_id});
        push(@result,$feature);
    }
    return \@result;   
}
### feature_pubprop
sub get_feature_pubprop{
    my %params=@_;
    my @result=();
    my $state="select * from feature_pubprop where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{type_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{type_id});
        $feature->{feature_pub_id}=get_feature_pub(DB=>$params{DB},feature_pub_id=>$feature->{feature_pub_id});
        push(@result,$feature);
    }
    return \@result;   
}
### feature_relationship     
sub get_feature_relationship{
    my %params=@_;
    my @result=();
    my $state="select * from feature_relationship where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{type_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{type_id});
        $feature->{subject_id}=get_feature(DB=>$params{DB},feature_id=>$feature->{subject_id});
        $feature->{object_id}=get_feature(DB=>$params{DB},feature_id=>$feature->{object_id});
        push(@result,$feature);
    }
    return \@result;   
}

###feature_relationship_pub
sub get_feature_relationship_pub{
    my %params=@_;
    my @result=();
    my $state="select * from feature_relationship_pub where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{feature_relationship_id}=get_feature_relationship(DB=>$params{DB},feature_relationship_id=>$feature->{feature_relationship_id});
        $feature->{pub_id}=get_pub(DB=>$params{DB},pub_id=>$feature->{pub_id});
        push(@result,$feature);
    }
    return \@result;   
}

### feature_relationshipprop 
sub get_feature_relationshipprop{
    my %params=@_;
    my @result=();
    my $state="select * from feature_relationshipprop where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{feature_relationship_id}=get_feature_relationship(DB=>$params{DB},feature_relationship_id=>$feature->{feature_relationship_id});
        $feature->{cvterm_id}=get_cvterm(DB=>$params{DB},cvterm_id=>$feature->{cvterm_id});
        push(@result,$feature);
    }
    return \@result;   
}
### feature_relationshipprop_pub
sub get_feature_relationshipprop_pub{
    my %params=@_;
    my @result=();
    my $state="select * from feature_relationshipprop_pub where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{feature_relationshipprop_id}=get_feature_relationshipprop(DB=>$params{DB},feature_relationshipprop_id=>$feature->{feature_relationshipprop_id});
        $feature->{pub_id}=get_pub(DB=>$params{DB},pub_id=>$feature->{pub_id});
        push(@result,$feature);
    }
    return \@result;   
}
### feature_synonym           
sub get_feature_synonym{
    my %params=@_;
    my @result=();
    my $state="select * from feature_synonym where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{synonym_id}=get_synonym(DB=>$params{DB},synonym_id=>$feature->{synonym_id});
        $feature->{feature_id}=get_feature(DB=>$params{DB},feature_id=>$feature->{feature_id});
        $feature->{pub_id}=get_pub(DB=>$params{DB},pub_id=>$feature->{pub_id});
        push(@result,$feature);
    }
    return \@result;   
}   
### featureloc  
 sub get_featureloc{
    my %params=@_;
    my @result=();
    my $state="select * from featureloc where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{srcfeature_id}=get_feature(DB=>$params{DB},feature_id=>$feature->{srcfeature_id});
        $feature->{feature_id}=get_feature(DB=>$params{DB},feature_id=>$feature->{feature_id});
     
        push(@result,$feature);
    }
    return \@result;   
}                
### featureloc_pub              
sub get_featureloc_pub{
    my %params=@_;
    my @result=();
    my $state="select * from featureloc_pub where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{featureloc_id}=get_featureloc(DB=>$params{DB},featureloc_id=>$feature->{featureloc_id});
        $feature->{pub_id}=get_pub(DB=>$params{DB},pub_id=>$feature->{pub_id});
        push(@result,$feature);
    }
    return \@result;   
}
### featuremap                 
### featuremap_pub               
### featurepos                  
### featureprop                
sub get_featureprop{
    my %params=@_;
    my @result=();
    my $state="select * from featureprop where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{type_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{type_id});
        $feature->{feature_id}=get_feature(DB=>$params{DB},feature_id=>$feature->{feature_id});
        push(@result,$feature);
    }
    return \@result;   
}
### featureprop_pub 
sub get_featureprop_pub{
    my %params=@_;
    my @result=();
    my $state="select * from featureprop_pub where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{featureprop_id}=get_featureprop(DB=>$params{DB}, featureprop_id=>$feature->{featureprop_id});
        $feature->{pub_id}=get_pub(DB=>$params{DB},pub_id=>$feature->{pub_id});
        push(@result,$feature);
    }
    return \@result;   
}            
### featurerange                
### genotype                    
sub get_genotype{
    my %params=@_;
    my @result=();
    my $state="select * from genotype where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        push(@result,$feature);
    }
    return \@result;   
}
### library                     
sub get_library{
    my %params=@_;
    my @result=();
    my $state="select * from library where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{type_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{type_id});
        $feature->{organism_id}=get_organism(DB=>$params{DB}, organism_id=>$feature->{organism_id});
        push(@result,$feature);
    }
    return \@result;   
}
### library_cvterm               
sub get_library_cvterm{
    my %params=@_;
    my @result=();
    my $state="select * from library_cvterm where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{library_id}=get_library(DB=>$params{DB}, library_id=>$feature->{library_id});
        $feature->{cvterm_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{cvterm_id});
        push(@result,$feature);
    }
    return \@result;   
}            
### library_feature 
sub get_library_feature{
    my %params=@_;
    my @result=();
    my $state="select * from library_feature where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{library_id}=get_library(DB=>$params{DB}, library_id=>$feature->{library_id});
        $feature->{feature_id}=get_feature(DB=>$params{DB}, feature_id=>$feature->{feature_id});
        push(@result,$feature);
    }
    return \@result;   
}            
### library_pub    
sub get_library_pub{
    my %params=@_;
    my @result=();
    my $state="select * from library_pub where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{library_id}=get_library(DB=>$params{DB}, library_id=>$feature->{library_id});
        $feature->{pub_id}=get_pub(DB=>$params{DB},pub_id=>$feature->{pub_id});
        push(@result,$feature);
    }
    return \@result;   
}
### library_synonym            
sub get_library_synonym{
    my %params=@_;
    my @result=();
    my $state="select * from library_synonym where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{synonym_id}=get_synonym(DB=>$params{DB}, synonym_id=>$feature->{synonym_id});
        $feature->{library_id}=get_library(DB=>$params{DB}, library_id=>$feature->{library_id});
        $feature->{pub_id}=get_pub(DB=>$params{DB},pub_id=>$feature->{pub_id});
        push(@result,$feature);
    }
    return \@result;   
}
### libraryprop         
sub get_libraryprop{
    my %params=@_;
    my @result=();
    my $state="select * from libraryprop where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{type_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{type_id});
        $feature->{library_id}=get_library(DB=>$params{DB},library_id=>$feature->{library_id});
        push(@result,$feature);
    }
    return \@result;   
}
### organism_dbxref            
### organismprop                 
### phendesc                  
sub get_phendesc{
    my %params=@_;
    my @result=();
    my $state="select * from phendesc where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{type_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{type_id});
        $feature->{genotype_id}=get_genotype(DB=>$params{DB},genotype_id=>$feature->{genotype_id});
        $feature->{environment_id}=get_environment(DB=>$params{DB}, environment_id=>$feature->{environment_id});
        $feature->{pub_id}=get_pub(DB=>$params{DB},pub_id=>$feature->{pub_id});
        push(@result,$feature);
    }
    return \@result;   
}
### phenotype         
sub get_phenotype{
    my %params=@_;
    my @result=();
    my $state="select * from phenotype where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{observable_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{observable_id});
        $feature->{cvalue_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{cvalue_id});
        $feature->{attr_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{attr_id}); 
        $feature->{assay_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{assay_id}); 
        push(@result,$feature);
    }
    return \@result;   
}
### phenotype_comparison         
sub get_phenotype_comparison{
    my %params=@_;
    my @result=();
    my $state="select * from phenotype_comparison where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
      
        $feature->{genotype1_id}=get_genotype(DB=>$params{DB},genotype_id=>$feature->{genotype1_id});
        $feature->{genotype2_id}=get_genotype(DB=>$params{DB},genotype_id=>$feature->{genotype2_id}); 
        $feature->{phenotype1_id}=get_phenotype(DB=>$params{DB},phenotype_id=>$feature->{phenotype1_id});
       $feature->{phenotype2_id}=get_phenotype(DB=>$params{DB},phenotype_id=>$feature->{phenotype2_id}); 
       $feature->{environment1_id}=get_environment(DB=>$params{DB}, environment_id=>$feature->{environment1_id});
      $feature->{environment2_id}=get_environment(DB=>$params{DB}, environment_id=>$feature->{environment2_id}); 
       $feature->{organism_id}=get_organism(DB=>$params{DB}, organism_id=>$feature->{organism_id}
        $feature->{pub_id}=get_pub(DB=>$params{DB},pub_id=>$feature->{pub_id});
        push(@result,$feature);
    }
    return \@result;   
}
### phenotype_comparison_cvterm 
sub get_phenotype_comparison_cvterm{
    my %params=@_;
    my @result=();
    my $state="select * from phenotype_comparison_cvterm where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{cvterm_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{cvterm_id});
        $feature->{phentotype_comparison_id}=get_phenotype_comparison(DB=>$params{DB},phenotype_comparison_id=>$feature->{phenotype_comparison_id});
        push(@result,$feature);
    }
    return \@result;   
}  
### phenotype_cvterm
sub get_phenotype_cvterm{
    my %params=@_;
    my @result=();
    my $state="select * from phenotype_cvterm where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{cvterm_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{cvterm_id});
        $feature->{phentotype_id}=get_phenotype(DB=>$params{DB},phenotype_id=>$feature->{phenotype_id});
        push(@result,$feature);
    }
    return \@result;   
} 
             
### phenstatement              
sub get_phenstatement{
    my %params=@_;
    my @result=();
    my $state="select * from phenstatement where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{type_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{type_id});
        $feature->{genotype_id}=get_genotype(DB=>$params{DB},genotype_id=>$feature->{genotype_id});
        $feature->{phenotype_id}=get_phenotype(DB=>$params{DB},phenotype_id=>$feature->{phenotype_id});
        $feature->{environment_id}=get_environment(DB=>$params{DB}, environment_id=>$feature->{environment_id});
        $feature->{pub_id}=get_pub(DB=>$params{DB},pub_id=>$feature->{pub_id});
        push(@result,$feature);
    }
    return \@result;   
}
### pub                         
sub get_pub{
    my %params=@_;
    my @result=();
    my $state="select * from pub where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{type_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{type_id});
        push(@result,$feature);
    }
    return \@result;   
}
### pub_dbxref                  
sub get_pub_dbxref{
    my %params=@_;
    my @result=();
    my $state="select * from pub_dbxref where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{dbxref_id}=get_dbxref(DB=>$params{DB}, dbxref_id=>$feature->{dbxref_id});
        $feature->{pub_id}=get_pub(DB=>$params{DB},pub_id=>$feature->{pub_id});
        push(@result,$feature);
    }
    return \@result;   
}
### pub_relationship  
sub get_pub_relationship{
    my %params=@_;
    my @result=();
    my $state="select * from pub_relationship where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{type_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{type_id});
        $feature->{object_id}=get_pub(DB=>$params{DB}, pub_id=>$feature->{object_id});
        $feature->{subject_id}=get_pub(DB=>$params{DB}, pub_id=>$feature->{subject_id});
        push(@result,$feature);
    }
    return \@result;   
}           
### pubauthor                   
sub get_pubauthor{
    my %params=@_;
    my @result=();
    my $state="select * from pubauthor where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{pub_id}=get_pub(DB=>$params{DB},pub_id=>$feature->{pub_id});
        push(@result,$feature);
    }
    return \@result;   
}
### pubprop                      
sub get_pubprop{
    my %params=@_;
    my @result=();
    my $state="select * from pubprop where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{type_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{type_id});
        $feature->{pub_id}=get_pub(DB=>$params{DB},pub_id=>$feature->{pub_id});
        push(@result,$feature);
    }
    return \@result;   
}
### synonym 
sub get_synonym{
    my %params=@_;
    my @result=();
    my $state="select * from synonym where ";
    foreach my $key(keys %params){
       my $tmp=$params{$key};
       $tmp=~s/\\/\\\\\\\\/g;
       $tmp=~s/\'/\\\'/g;
       $state.="$key like '".$tmp."' and ";
    }  
    $state=~s/and $//;
    my $nmm=$params{DB}->prepare($state);
    $nmm->execute;
    while(my $feature=$nmm->fetchrow_hashref){
        $feature->{type_id}=get_cvterm(DB=>$params{DB}, cvterm_id=>$feature->{type_id});
        push(@result,$feature);
    }
    return \@result;   

}
 ### stock                       
 ### stock_cvterm               
 ### stock_dbxref                
 ### stock_genotype              
 ### stock_pub                   
 ### stock_relationship          
 ### stock_relationship_pub      
 ### stockcollection             
 ### stockcollection_stock      
 ### stockcollectionprop         
 ### stockprop                   
 ### stockprop_pub              
                     
 

1;
