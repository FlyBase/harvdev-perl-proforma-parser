package FlyBase::Proforma::Interaction;

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

# This allows declaration	use FlyBase::Proforma::Interaction ':all';
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

FlyBase::Proforma::Interaction - Perl module for parsing the FlyBase
Interaction  proforma version 2.2, Dec 2009.

See the bottom for the proforma
                         
=head1 SYNOPSIS

  use FlyBase::Proforma::Interaction;
  use DBI;
  
  my $mdbh=DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";
  my %ph=(IN1f=>'FBin0000001',....);
  ###!c field implemented as '$fieldname.upd=>'c'' eg. 'IN6.upd'=>'c'
   
  #params db is manditory, debug and validate is optional
  my $pro=FlyBase::proforma::Interaction->new(db=>$mdbh);
  $pro->validate(%ph);
  my $chadoxml = $pro->process(%ph);
  
  # or

  my $pro=FlyBase::Proforma::Interaction->new(db=>$mdbh,debug=>1,validate=>1);
  my $chadoxml_string=$pro->process(%ph);

=head1 DESCRIPTION

FlyBase::Proforma::Interaction is a perl module for parsing FlyBase
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
    'IN1f', 'uniquename',
    'IN1g', 'merge', ## not implemented
    'IN1h', 'delete', #needs interaction.is_obsolete
    'IN1i', 'dissociate FBrf',
    'IN2a',  'description',  ## interaction.description
    'IN2b', 'PSI-MI', ### interaction.type_id
    'IN3',  'PSI-MI',           ##interaction_cvterm
    'IN4', 'library_interaction',  ##library_interaction.library_id
    'IN5a', 'interaction_cell_line',  ##interaction_cell_line.cell_line_id
    'IN5b', 'interaction_expression',  ##interaction_expression
    'IN5d', 'conditions',    ##interactionprop
    'IN5e', 'comments on source',  ##interactionprop
    'IN6', 'participating feature',  ##feature_interaction.feature_id/, feature_interactionprop
    'IN7a', 'experimental feature',  ##feature_interaction, feature_interactionprop,feature_relationship.object_id
    'IN7c', 'interacting region',   ##feature_interaction, feature_interactionprop,feature_relationship.object_id
    'IN7d', 'interacting isoform',   ##feature_interaction, feature_interactionprop,feature_relationship.object_id
    'IN7b', 'experimental comment',  ##interactionprop
    'IN8a', 'comment',  ### interactionprop
    'IN8b', 'internalnotes' ###interactionprop
  
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
  print STDERR "processing interaction.pro $ph{IN1f}...\n";
  if ( exists( $self->{v} ) && $self->{v} == 1 ) {
    $self->validate($tihash);
  }
  if(exists($fbids{$ph{IN1f}})){
    $unique=$fbids{$ph{IN1f}};
  }
  else{
    ($unique, $out)=$self->write_interaction($tihash);
  }
  if(exists($fbcheck{$ph{IN1f}}{$ph{pub}})){
    print STDERR "Warning: $ph{IN1f} $ph{pub} exists in a previous proforma\n";
  }
  $fbcheck{$ph{IN1f}}{$ph{pub}}=1;
  if(!exists($ph{IN1i})){
    print STDERR "Action Items: Interaction $unique == $ph{IN1f} with pub $ph{pub}\n"; 
    my $f_p = create_ch_interaction_pub(
					doc => $doc,
					interaction_id => $unique,
					pub_id     => $ph{pub},
				       );
    $out .= dom_toString($f_p);
    $f_p->dispose();
  }    
  else{
    $out .= dissociate_with_pub_frominteraction( $self->{db}, $unique, $ph{pub} );
    print STDERR "Action Items: dissociate $ph{LC1a} with $ph{pub}\n";
    return $out;
  }
    ##Process other field in Trangenic Insertion proforma
  foreach my $f ( keys %ph ) {
        #print $f,"\n";
    if ( $f eq 'IN1g' ) {
      print STDERR "ERROR: not implemented yet \n";
   #          my $tmp=$ph{$f};
   #         $tmp=~s/\n/ /g;
   #         if($ph{IN1f} eq 'new'){
  #              print STDERR "ERROR: Action Items: merge Interaction $tmp\n";
  #          }
 #           else{
  #              print STDERR "Action Items: merge Interaction $tmp to $ph{IN1f} \n";
  #          }
          #  $out .= merge_library_records( $self->{db}, $unique, $ph{$f},$ph{IN1f}, $ph{pub} );
          
    }
    elsif ($f eq 'IN4'){  
      print STDERR "CHECK: first use of  $f \n";
      if( exists($ph{"$f.upd"}) && $ph{ "$f.upd" } eq 'c' ) {
	print STDERR "Action Items: !c log $unique $f $ph{pub}\n";
	print STDERR "CHECK: first use of  $f !c \n";
	my ($lu,$lo,$lt)= get_library_by_interaction_pub($self->{db}, $unique,$ph{pub});
	my ($lg,$ls) = get_organism_by_id($self->{db},$lo);
	my $clp=create_ch_library_interaction(doc=>$doc,
					      library_id=>create_ch_library(doc=>$doc, uniquename=>$lu, genus=>$lg, species=>$ls, type=>$lt),
					      interaction_id=>$unique,
					      pub_id=>$ph{pub});
	$clp->setAttribute("op","delete");
	$out.=dom_toString($clp);
                         
      }
      if ( defined($ph{$f}) && $ph{$f} ne '' ) { 
	my @items = split( /\n/, $ph{$f} );
	foreach my $item (@items) {
	  $item =~ s/^\s+//;
	  $item =~ s/\s+$//;
	  my ($cu,$cg,$cs, $ct)=get_lib_ukeys_by_name($self->{db},$item);
	  my $cl=create_ch_library_interaction(
					       doc=>$doc,
					       library_id=>create_ch_library(doc=>$doc, uniquename=>$cu, genus=>$cg, species=>$cs, type=>$ct),
					       interaction_id=>$unique,
					       pub_id=>$ph{pub}                        
					      );   
	  $out.=dom_toString($cl);
	}
      }       
    }
    elsif ($f eq 'IN5a'){
     print STDERR "CHECK: first use of  $f \n";
       if( exists($ph{"$f.upd"}) && $ph{ "$f.upd" } eq 'c' ) {
	print STDERR "Action Items: !c log $unique $f $ph{pub}\n";
	print STDERR "CHECK: first use of  $f !c \n";
	my ($cellu,$cello)= get_cell_line_by_interaction_pub($self->{db}, $unique,$ph{pub});
	my ($cellg,$cells) = get_organism_by_id($self->{db},$cello);
	my $clp=create_ch_interaction_cell_line(doc=>$doc,
						cell_line_id=>create_ch_cell_line(doc=>$doc, uniquename=>$cellu, genus=>$cellg, species=>$cells),
						interaction_id=>$unique,
						pub_id=>$ph{pub});
	$clp->setAttribute("op","delete");
	$out.=dom_toString($clp);
      }
      if (defined($ph{$f}) && $ph{$f} ne '' ) { 
	my @items = split( /\n/, $ph{$f} );
	foreach my $item (@items) {
	  $item =~ s/^\s+//;
	  $item =~ s/\s+$//;
	  my ($cu,$cg,$cs)=get_cell_line_ukeys_by_name($self->{db},$item);
	  my $cl=create_ch_interaction_cell_line(
						 doc=>$doc,
						 cell_line_id=>create_ch_cell_line(doc=>$doc, uniquename=>$cu, genus=>$cg, species=>$cs),
						 interaction_id=>$unique,
						 pub_id=>$ph{pub}                        
						);   
	  $out.=dom_toString($cl);
	}
      }
    }
    elsif ($f eq 'IN5d'
            || $f eq 'IN5e'
            || $f eq 'IN7b'
            || $f eq 'IN8a'
            || $f eq 'IN8b'
	  ) 
      {
	print STDERR "CHECK: first use of  $f \n";
 	if ( exists( $ph{ "$f.upd" } ) && $ph{ "$f.upd" } eq 'c' ) {
	  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
	  my @results =
	    get_unique_key_for_interactionprop( $self->{db}, $unique,
						$fpr_type{$f},$ph{pub});
	  foreach my $t (@results) {
                    my $num = get_intprop_pub_nums( $self->{db}, $t->{fp_id} );
                    if ( $num == 1 ) {
                        $out .=
                          delete_interactionprop( $doc, $t->{rank}, $unique,
                            $fpr_type{$f} );
                    }
		    elsif ( $num > 1 ) {
                        $out .=
                          delete_interactionprop_pub( $doc, $t->{rank}, $unique,
                            $fpr_type{$f}, $ph{pub} );
                    }

                    else {
                        print STDERR "ERROR:something Wrong, please validate first\n";
		    }
	  }
	}
	if ( defined($ph{$f}) && $ph{$f} ne '' ) {
	  my @items = split( /\n/, $ph{$f} );
	  foreach my $item (@items) {
	    $item =~ s/^\s+//;
	    $item =~ s/\s+$//;

	    $out .=
	      write_interactionprop( $self->{db}, $doc, $unique, $item,
				     $fpr_type{$f}, 'interaction property type', $ph{pub});
	  }
	}
      }
    elsif ($f eq 'IN5b'){
      print STDERR "CHECK: interaction_expression module\n";
      if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
	print STDERR "Action items: !c log $unique $f  $ph{pub} \n";
	     #get interaction_expression
	my @result =get_expression_for_interaction_expression( $self->{db}, $unique, $ph{pub});
	foreach my $item (@result) {
	  my $int_exp = create_ch_interaction_expression(
							 doc        => $doc,
							 interaction_id => $unique,
							 expression_id  => create_ch_expression(
												doc  => $doc,
												uniquename => $item,
											       ),
							 pub => $ph{pub}
							);
	  $int_exp->setAttribute( 'op', 'delete' );
	  $out .= dom_toString($int_exp);
	  $int_exp->dispose();
	}
      }
      if ( $ph{$f} ne '' ) {           
	my @items=split("\n", $ph{$f});
	foreach my $item(@items){
	  $item=trim($item);
	  if($item ne ""){
	    if(!($item=~/<t>/)){
	      $item='<t>'.$item;
	    }
	    my $fe=parse_tap(doc=>$doc,db=>$self->{db}, interaction_id=>$unique, pub_id=>$ph{pub},tap=>$item, check_cvterms=>1 );
	    if(defined($fe) && $fe ne ''){
	      $out.=dom_toString($fe);
	    }
	    else{
	      print STDERR "ERROR, could not parse expression $unique, $item, $ph{pub} \n";
	    }
	  }
	}   
      }
    }
    elsif ($f eq 'IN3') {
      print STDERR "CHECK: first use of $f\n";
      if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
	print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
	my @result =
	  get_cvterm_for_interaction_cvterm( $self->{db}, $unique, $fpr_type{$f},);

	foreach my $item (@result) {
	  my ($cvterm, $obsolete)=split(/,,/,$item);
	  my $feat_cvterm = create_ch_interaction_cvterm(
							 doc        => $doc,
							 interaction_id => $unique,
							 cvterm_id  => create_ch_cvterm(
											doc  => $doc,
											cv   => $fpr_type{$f},
											name => $cvterm
										       ),
							);

	  $feat_cvterm->setAttribute( 'op', 'delete' );
	  $out .= dom_toString($feat_cvterm);
	  $feat_cvterm->dispose();
	}
      }
      if ( defined($ph{$f}) && $ph{$f} ne '' ) {

	my @items=split(/\n/,$ph{$f});
	foreach my $item(@items){
	  my $type='';
	  $item=~s/^\s//;
	  $item=~s/\s$//;
	  my $rc=validate_cvterm($self->{db},$item, $fpr_type{$f});
	  if($rc==0){   
	    print STDERR "ERROR: could not find cvterm $item in DB for IN3\n";
	  }
	  else{
	    $type=$fpr_type{$f};    
	  }
	  my $f_cvterm = &create_ch_interaction_cvterm(
						       doc => $doc,
						       interaction_id => $unique,
						       cvterm_id  => create_ch_cvterm(
										      doc  => $doc,
										      cv   => $type,
										      name => $item
										     ),
						      );
	  $out .= dom_toString($f_cvterm);
	  $f_cvterm->dispose();
	}
      }
    }
    elsif($f eq 'IN6' || $f eq 'IN7a' || $f eq 'IN7c' || $f eq 'IN7d' ){
       if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
	print STDERR "DEBUG: !c NEW implemented $unique $f $fpr_type{$f} pub $ph{pub}\n";
	#no feature_interactionprop_pub so get fip but return feature_interaction_id
	my @result =get_unique_key_for_feature_interaction( $self->{db}, $unique,  $fpr_type{$f}, $ph{pub});
	foreach my $t (@result) {
	    print STDERR "CHECK: feature_interaction_id $t->{fp_id} interaction $unique feature $t->{f_uname} role $t->{r_cv} $t->{r_type} feat_int rank $t->{fi_rank}\n";
	    my $f = create_ch_feature_interaction(
		doc => $doc,
		feature_id => create_ch_feature(doc => $doc,
			       uniquename  =>  $t->{f_uname},
			       genus => $t->{genus},
			       species =>$t->{species},  
			       type => $t->{f_type},
		),
		role_id => create_ch_cvterm(doc=>$doc, cv=>$t->{r_cv}, name=>$t->{r_type}),
		interaction_id => $unique,
		rank=>$t->{fi_rank},
		);
	    $f->setAttribute( 'op', 'delete' );
	    $out .= dom_toString($f);
	    $f->dispose();
	}
       }
#	print STDERR "CHECK:  implemention of parse tab fields\n";
       if ( $ph{$f} ne '' ) {
	   my @items=split(/\n/,$ph{$f});
	   foreach my $item(@items){
	       $item=trim($item);
	       if($item ne ""){
		   $out.=parse_tab_fields($item,$unique, $ph{pub},$f);
	       }
	   }
       }
    }
  }
  $doc->dispose();
  return $out;
}

=head2 $pro->write_interaction(%ph)

  separate the id generation and lookup from the other curation field to make two-stage parsing possible

=cut
  sub write_interaction{
    my $self    = shift;
    my $tihash  = {@_};
    my %ph      = %$tihash;
    my $unique  = '';
    my $flag    = 0;
    my $feature = '';
    my $genus='Drosophila';
    my $species='melanogaster';
    my $type = "";
    my $description = "";
    my $out = '';
   
    print STDERR "CHECK: first use of interaction proforma\n";
    if ( $ph{IN1d} eq 'y') {   
      ($unique,$type)=get_int_ukeys_by_name($db,$ph{IN1f});
      if($unique ne $ph{IN1f}){
	print STDERR "ERROR, could not get uniquename for $ph{IN1f}\n";
      }
      if(exists($fbids{$ph{IN1f}})){
	my $check=$fbids{$ph{IN1f}};
	if($unique ne $check){
	  print STDERR "ERROR: $check and $unique are not same for $ph{IN1f}\n"; 
	}
      }
      $fbids{ $ph{IN1f} } = $unique;
	# exit(0);
      if(!defined($type)){
	print STDERR "ERROR: could not get type_id for Interaction $ph{IN1f}\n";
      }

       $feature = create_ch_interaction(
            doc        => $doc,
            uniquename => $unique,
            type       => $type,
            macro_id   => $unique,
        );

      if(exists($ph{IN2a}) && $ph{IN2a} ne ""){
	$feature=add_interaction_description($doc,$feature,$ph{IN2a});
      } 
      if ( exists( $ph{IN1h} ) && $ph{IN1h} eq 'y' ) {
	print STDERR "Action Items: delete interaction $ph{IN1h}\n";
	my $op = create_doc_element( $doc, 'is_obsolete', 't' );
	$feature->appendChild($op);
      }

      $out.=dom_toString($feature);
    }
    else {
      my $va= validate_new_name($db, $ph{IN1f}, 'interaction');
      if(exists($ph{IN1c})){
	print STDERR "ERROR: Rename not implemented for interactions \n";
      }
      elsif($va == 0){
	if(exists($fbids{ $ph{IN1f}})){
	  $flag = 1;
	}
	print STDERR "CHECK: Check if new flag = $flag for Interaction $ph{IN1f}\n";       
	if ( $flag == 0 ) {
	  $unique = $ph{IN1f};
	  print STDERR "Action Items: new Interaction $ph{IN1f}\n";
	  if(exists($ph{IN2b}) && $ph{IN2b} ne ""){
	    $type=$ph{IN2b};  
	  }
	  else{
	    print STDERR "ERROR: could not get type_id for Interaction $ph{IN1f}\n";
	  }
	  if(exists($ph{IN2a}) && $ph{IN2a} ne ""){
	    $description=$ph{IN2a};  
	  }
	  $feature = create_ch_interaction(doc        => $doc,
					   uniquename => $unique,
					   type       => $type,
					   description => $description,
					   macro_id   => $unique,
					   no_lookup  => 1,
					  );
	  $out.=dom_toString($feature);
	}
	else{
	  print STDERR "ERROR, name $ph{IN1f} has been used in this load\n";
	}
	$fbids{ $ph{IN1f} } = $unique;
      }
      else{
	  print STDERR "ERROR, uniquename $ph{IN1f} has been used in the database\n";	
      }
    }   
    $doc->dispose();
    return ($out, $unique);

  }

  sub parse_tab_fields{
    my $line=shift;
    my $unique=shift;
    my $pub=shift;
    my $field=shift;

    my %tab=();
    my $output='';
    my $feature='';
    my $f_o='';

#    while($line=~/<(.*?)>(.*?)[<|\n]/g){
#        $tab{$1}=$2;
#    }

#make them like tap
    $line=~s/<symbol>/<s>/g;
    $line=~s/<link to>/<l>/g;
    $line=~s/<ID_as_reported>/<a>/g;
    $line=~s/<role>/<r>/g;
    $line=~s/<qual\/note>/<q>/g;
    $line=~s/<coordinates\/seq>/<c>/g;
    $line=~s/<note>/<n>/g;
    $line=~s/<description>/<d>/g;
    $line=~s/<identifier>/<i>/g;

     print STDERR "$line\n";

   # this split keeps the letter designators but removes the <> bits
    # also puts undef on beginning of result array so shift if off
    my @pieces = split /<([slarqcndi])>/, $line;
    shift @pieces;
    print STDERR " after split @pieces \n";
    return unless @pieces;

    if (@pieces % 2) { 
	pop @pieces; # this bit just removes a tag with no value so array has even number
    }

    for (my $i=0; $i <= $#pieces-1; $i+=2) {
	$tab{$pieces[$i]} = trim($pieces[$i + 1] ) if $pieces[$i + 1] !~ /^\s*$/;
    }
    foreach my $key ( keys %tab){
      print STDERR "$key $tab{$key}\n";
    }
    if((exists($tab{s}) && $tab{s} ne " ") && ($field eq 'IN6')){
      if (exists($fbids{ $tab{s} })){
	$feature = $fbids{$tab{s}};
      }
      else{
	my ($f_u,$f_g,$f_s,$f_t)=get_feat_ukeys_by_name($db,$tab{s});
	if($f_u ne '0' && $f_u ne '2'){
	  my $feat=create_ch_feature(
				   doc=>$doc,
				   uniquename=>$f_u,
				   genus=>$f_g,
				   species=>$f_s,
				   type=>$f_t,
				   macro_id=>$f_u,    
				  ); 
	  $output.=dom_toString($feat);   
	  $feature=$f_u;
	  $fbids{$tab{s}} = $feature;
	}
	else{
	  print STDERR "ERROR, could not find feature with symbol $tab{s} in $field for $unique\n";
	}
      }
    }
    if((exists($tab{l}) && $tab{l} ne " ") && ($field eq 'IN7a'  || $field eq 'IN7c' || $field eq 'IN7d')){
      if (exists($fbids{ $tab{l} })){
	$f_o = $fbids{$tab{l}};
      }
      else{
	my ($f_u,$f_g,$f_s,$f_t)=get_feat_ukeys_by_name($db,$tab{l});
	if($f_u ne '0' && $f_u ne '2'){
	  my $feat=create_ch_feature(
				   doc=>$doc,
				   uniquename=>$f_u,
				   genus=>$f_g,
				   species=>$f_s,
				   type=>$f_t,
				   macro_id=>$f_u    
				  );
	  $output.=dom_toString($feat);
	  $f_o = $f_u;
	  $fbids{$tab{l}}= $f_o;	  
	}
	else{
	  print STDERR "ERROR, could not find feature with symbol $tab{l} in $field for $unique\n";
	}
      }
      if($field eq 'IN7a' ){
	if(exists($tab{i}) && ($tab{i} ne " ") ){
	  if (exists($fbids{ $tab{l}."_".$tab{i} })){
	    $feature = $fbids{$tab{l}."_".$tab{i} };
	  }
	  else{
	      my $value =  $tab{i};     
## Escape single-quotes
		  $value =~ s/\'/\\\'/g;

	    my $ident=create_ch_feature(
				    doc=>$doc,
				    uniquename=>$tab{l}."_".$value,
				    genus=>'Drosophila',
				    species=>'melanogaster',
				    type=>'polypeptide',
				    name=>$value,
				    no_lookup=>1,
				    macro_id=>$tab{l}."_".$tab{i},
				   );
	    $output.=dom_toString($ident);
	    $feature=$tab{l}."_".$tab{i};
	    $fbids{$tab{l}."_".$tab{i} } = $feature;
	  }
	}
	else{
	  print STDERR "ERROR, Missing value for  identifier in $field for $unique\n";
	}
      }
      if( $field eq 'IN7c'  || $field eq 'IN7d') { 
	if(exists($tab{d}) && ($tab{d} ne " ") ){
	  if (exists($fbids{$tab{l}."_".$tab{d} })){
	    $feature = $fbids{$tab{l}."_".$tab{d}};
	  }
	  else{

	      my $value =  $tab{d};
	      ## Escape single-quotes                                                         
	      $value =~ s/\'/\\\'/g;                                        
                                          
	    my $ident=create_ch_feature(
				    doc=>$doc,
				    uniquename=>$tab{l}."_".$value,
				    genus=>'Drosophila',
				    species=>'melanogaster',
				    type=>'polypeptide',
				    name=>$value,
				    no_lookup=>1,
				    macro_id=>$tab{l}."_".$tab{d},
				   );
	    $output.=dom_toString($ident);
	    $feature=$tab{l}."_".$tab{d};
	    $fbids{$tab{l}."_".$tab{d}} = $feature;
	  }
	}
	else{
	  print STDERR "ERROR, Missing value for description in $field for $unique\n";
	}
      }
      my $fr=create_ch_fr(doc=>$doc, object_id=>$f_o, subject_id=>$feature, rtype=>"associated_with");
      my $fr_pub=create_ch_fr_pub(doc=>$doc, uniquename=>$pub);
      $fr->appendChild($fr_pub);
      $output.=dom_toString($fr);    
    }

    my $cv='PSI-MI';

    if(exists($tab{r}) && $tab{r} ne " "){     
      if($tab{r} eq 'reagent'){
	$cv='SO';
      }
    }
    else{
      print STDERR "ERROR: No role found for $field\n";
    }
# check that role is a valid cvterm
    
    my $va = validate_cvterm($db,$tab{r},$cv);
    if($va == 0){
      print STDERR "ERROR,  Not a valid cv $cv cvterm $tab{r} for $unique\n";
    }
    
    my $cvname = "feature_interaction property type";
    my $cname = "";
    my $value = "";
    my $rank;
    my $fi=create_ch_feature_interaction(
					 doc=>$doc,
					 role_id=>create_ch_cvterm(doc=>$doc,cv=>$cv, name=>$tab{r}),
					 feature_id=>$feature,
					 interaction_id=>$unique,                     
					);
    my $fipub=create_ch_feature_interaction_pub(
						doc=>$doc,
						pub_id=>$pub
					       );
    $fi->appendChild($fipub);
    
    if((exists($tab{a}) && $tab{a} ne " ") && ($field eq 'IN6' || $field eq 'IN7a')){
      $cname = "reported as";
      $value = $tab{a};
      $rank = get_feature_interactionprop_rank($db,$feature,$cvname,$unique,$cname);
      if(!defined($rank)){
	print STDERR "ERROR: No rank found for $feature,$cvname,$unique,$cname\n";
      }
	 else{
	print STDERR "OK: rank $rank found for $feature,$cvname,$unique,$cname\n";
      }
      my $fip=create_ch_feature_interactionprop(
						doc=>$doc,
						value=>$value,
						type_id=>create_ch_cvterm(doc=>$doc, cv=>$cvname,
									  name=>$cname),
						rank=>$rank,
					       );
      $fi->appendChild($fip);
    }
    if(exists($tab{q}) && $tab{q} ne ""){
      $cname = "comment";
      $value = $tab{q};
      $rank = get_feature_interactionprop_rank($db,$feature,$cvname,$unique,$cname);  
      if(!defined($rank)){
	print STDERR "ERROR: No rank found for $feature,$cvname,$unique,$cname\n";
      }
	 else{
	print STDERR "OK: rank $rank found for $feature,$cvname,$unique,$cname\n";
      }

      ## Escape single-quotes
      $value =~ s/\'/\\\'/g;
      print STDERR "value=$value\n";

      my $fip=create_ch_feature_interactionprop(
						doc=>$doc,
						value=>$value,
						type_id=>create_ch_cvterm(doc=>$doc, cv=>$cvname,
									  name=>$cname),
						rank=>$rank,
					       );
      $fi->appendChild($fip);  
    }
    if(exists($tab{n}) && $tab{n} ne " "){
      $cname = "comment";
      $value = $tab{n};
      $rank = get_feature_interactionprop_rank($db,$feature,$cvname,$unique,$cname);  
      if(!defined($rank)){
	print STDERR "ERROR: No rank found for $feature,$cvname,$unique,$cname\n";
      }
	 else{
	print STDERR "OK: rank $rank found for $feature,$cvname,$unique,$cname\n";
      }  

      ## Escape single-quotes
      $value =~ s/\'/\\\'/g;
      print STDERR "value=$value\n";  

      my $fip=create_ch_feature_interactionprop(
						doc=>$doc,
						value=>$value,
						type_id=>create_ch_cvterm(doc=>$doc, cv=>$cvname,
									  name=>$cname),
						rank=>$rank,
					       );
      $fi->appendChild($fip);  
    }
    if(exists($tab{c}) && $tab{c} ne " "){
      $cname = "subpart_info";
      $value = $tab{c};
      $rank = get_feature_interactionprop_rank($db,$feature,$cvname,$unique,$cname);  
      if(!defined($rank)){
	print STDERR "ERROR: No rank found for $feature,$cvname,$unique,$cname\n";
      }
	 else{
	print STDERR "OK: rank $rank found for $feature,$cvname,$unique,$cname\n";
      }    
      my $fip=create_ch_feature_interactionprop(
						doc=>$doc,
						value=>$value,
						type_id=>create_ch_cvterm(doc=>$doc, cv=>$cvname,
									  name=>$cname),
						rank=>$rank,
					       );
      $fi->appendChild($fip);  
    } 
    if((exists($tab{s}) && $tab{s} ne " ") && ( $field eq 'IN6')){
      $cname = "participating feature";
      $value = $tab{s};
      $rank = get_feature_interactionprop_rank($db,$feature,$cvname,$unique,$cname);   
      if(!defined($rank)){
	print STDERR "ERROR: No rank found for $feature,$cvname,$unique,$cname\n";
      }
	 else{
	print STDERR "OK: rank $rank found for $feature,$cvname,$unique,$cname\n";
      }       
      my $fip=create_ch_feature_interactionprop(
						doc=>$doc,
						value=>$value,
						type_id=>create_ch_cvterm(doc=>$doc, cv=>$cvname,
									  name=>$cname),
						rank=>$rank,
					       );
      $fi->appendChild($fip);  
    } 
    if((exists($tab{i}) && $tab{i} ne " ") && ( $field eq 'IN7a')) {
      $cname = "experimental feature";
      $value =$tab{i};
      $rank = get_feature_interactionprop_rank($db,$feature,$cvname,$unique,$cname);  
      if(!defined($rank)){
	print STDERR "ERROR: No rank found for $feature,$cvname,$unique,$cname\n";
      }
	 else{
	print STDERR "OK: rank $rank found for $feature,$cvname,$unique,$cname\n";
      }    
      my $fip=create_ch_feature_interactionprop(
						doc=>$doc,
						value=>$value,
						type_id=>create_ch_cvterm(doc=>$doc, cv=>$cvname,
									  name=>$cname),
						rank=>$rank,
					       );
      $fi->appendChild($fip);  
    } 

    if(exists($tab{d}) && $tab{d} ne " "){
      if ($field eq 'IN7c'){
	$cname = "interacting region";
      }
      elsif($field eq 'IN7d'){
	$cname = "interacting isoform";
      }
      $value = $tab{d};
      $rank = get_feature_interactionprop_rank($db,$feature,$cvname,$unique,$cname);  
      if(!defined($rank)){
	print STDERR "ERROR: No rank found for $feature,$cvname,$unique,$cname\n";
      }
	 else{
	print STDERR "OK: rank $rank found for $feature,$cvname,$unique,$cname\n";
      }    
      my $fip=create_ch_feature_interactionprop(
						doc=>$doc,
						value=>$value,
						type_id=>create_ch_cvterm(doc=>$doc, cv=>$cvname,
									  name=>$cname),
						rank=>$rank,
					       );
      $fi->appendChild($fip);  
    }
 
    $output.=dom_toString($fi);
    return $output;
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
 
    print STDERR "validating Interaction ", $tival{IN1f}, "\n";
    
    if(exists($tival{IN1f}) && ($tival{IN1f} ne 'new')){
        validate_interaction_uname($db, $tival{IN1f});
    }
    
    foreach my $f ( keys %tival ) {
        if($f eq 'IN3'){
            my @items=split(/\n/,$tival{$f});
            foreach my $item(@items){
                   $item=~s/\s+$//;
                   $item=~s/^\s+//;  
                   
                   validate_cvterm($db,$item,$fpr_type{$f});
             }
           }
            if ( $f =~ /(.*)\.upd/ && !($v_unique=~/temp/) ) {
                $f = $1;
                if ( $f eq 'IN5d'
                || $f eq 'IN5e'
                || $f eq 'IN7b'
                || $f eq 'IN8a'
                || $f eq 'IN8b')
                {
                    my $num =
                      get_unique_key_for_interactionprop( $db, $v_unique,
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
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! INTERACTION PROFORMA             Version 2.2  1 Dec 2009
!
! THAT APPLY TO A SPECIFIC INTERACTION, PATHWAY OR OTHER EVENT
!
! IN1f. Database ID for interaction  :new
	interaction.uniquename
!
! IN1c. Action - rename this event   :
! IN1g. Action - merge these events  :
! IN1h. Action - delete event record ("y"/blank) :
! IN1i. Action - dissociate EX1f from FBrf ("y"/blank):
!
! IN2.  Interaction type (oboCV)     :physical association
	interaction.type_id

! IN3.  Interaction assay (oboCV)    :
	interaction_cvterm
!
! IN4.  Library/collection           :
	library_interaction.library_id
!
! IN5a. Cell line used               :
	interaction_cell_line.cell_line_id
! IN5b. Stage and tissue (<e> <t> <a> <s> <note>) :
	interaction_expression.expression_id
! IN5d. Conditional dependencies     :
	interactionprop.value type_id = 'conditions'
! IN5e. Comments concerning source   :
	interactionprop.value type_id = 'comments_on_source'
!
! IN6.  List of interactors (FB symbol or ids), role (oboCV), qualifier:
<symbol>  <ID_as_reported>  <role>  <qual/note>
	NOTE: this is like a tap statement I split out each field below
<symbol> - symbol for an existing feature -> feature_interaction.feature_id

<ID_as_reported> - like a synonym but specific to the interaction ->
    	feature_interactionprop.value type_id = 'reported as'

<role> - feature_interaction.type_id
<qual/note> - feature_interactionprop.value type_id = comment

!
! IN7a. Experimental entities supporting participants/interactors:
<link to>  <identifier>  <ID_as_reported>  <role>  <qual/note> 
	NOTE: this is like a tap statement as well but different implementation
	      to above
<link to> symbol for an existing feature (often but not always one of participants above)
          feature_relationship.object_id type_id = ? (something fairly general - 
                                                      maybe associated_with?)

<identifier> feature.name for a new feature
             uniquename = symbol in <link to> concatenated to this value
	             eg. mor-XP_C terminal or mor-XP_MSNDLP

             this feature becomes feature_interaction.feature_id
             with feature_interactionprop.type_id = 'experimental feature'
	     and also is the feature_relationship.subject_id of the <link to> object_id
               
<ID_as_reported> feature_interactionprop.value type_id = 'reported as'

<role> feature_interaction.role_id 

<qual/note> feature_interactionprop.value type_id = 'comment'
!
! IN7c. Subregion(s) of participant(s) with role in interaction:
<link to>  <description>  <role> unspecified <coordinates/seq>  <note>
	NOTE: this is like a tap statement as well implemented similarly to IN7a 
              with a few differences

<link to> symbol for an existing feature (often but not always one of participants above)
          feature_relationship.object_id type_id = ? (something fairly general - 
                                                      maybe associated_with?)

<description> feature.name for a new feature
             uniquename = symbol in <link to> concatenated to this value
	             eg. mor-XP_C terminal or mor-XP_MSNDLP

             this feature becomes feature_interaction.feature_id
             with feature_interactionprop.type_id = 'interacting region'
             and also is the feature_relationship.subject_id of <link to> feature

<role> feature_interaction.role_id 

<coordinates/seq> feature_interactionprop.value type_id = 'subpart_info'

<qual/note> feature_interactionprop.value type_id = 'comment'

!
! IN7b. Comments concerning experimental data:
	interactionprop.value type_id = 'experimental comment'
!
! IN8a. Public comments   :
	interactionprop.value type_id = comment
! IN8b. Internal comments :
	interactionprop.value type_id = 'internal comment'
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

=head1 AUTHOR

Haiyan Zhang, E<lt>haiyan@morgan.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
