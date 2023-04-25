package FlyBase::Proforma::TE;

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

our @EXPORT = qw( process_ti validate_ti

);

our $VERSION = '0.01';

# Preloaded methods go here.

=head1 NAME

FlyBase::Proforma::TE - Perl module for parsing the FlyBase
natural transposon  proforma version 4, Jan 26, 2007.

See the bottom for the proforma
                         
=head1 SYNOPSIS

  use FlyBase::Proforma::TE;
  use DBI;
  
  my $mdbh=DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";
  my %ph=(TE1a=>'TM9',....);
  ###!c field implemented as '$fieldname.upd=>'c'' eg. 'TE16.upd'=>'c'
   
  #params db is manditory, debug and validate is optional
  my $pro=FlyBase::proforma::TE->new(db=>$mdbh);
  $pro->validate(%ph);
  my $chadoxml = $pro->process(%ph);
  
  # or

  my $pro=FlyBase::Proforma::TE->new(db=>$mdbh,debug=>1,validate=>1);
  my $chadoxml_string=$pro->process(%ph);

=head1 DESCRIPTION

FlyBase::Proforma::TE is a perl module for parsing FlyBase
natural transposon proforma and write the result as chadoxml. It is required
to connected to a chado database for validating and processing.
See Proforma for the proforma template.

The module also requires FlyBase::Proforma::Writechado and
FlyBase::Proforma::Util. The results can be loaded into a chado
database by XML::Xort.

=head2 EXPORT

  process
  validate

=cut
our %ti_feat_type =
  ( 'TE8', 'gene', 'TE6c', 'transposable_element_flanking_region' );

our %ti_fpr_type = (
    'TE1a', 'symbol',
    'TE1b', 'symbol',
#    'TE2a', 'symbol',
#    'TE2b', 'symbol',
    'TE1c', 'symbol', #rename TE1a
#    'TE14a', 'fullname',
#    'TE14b', 'fullname',
#    'TE14c', 'fullname', #replace TE14a
    'TE4a', 'SO',
    'TE4b', 'TE_total_length',
    'TE4c', 'TE_repeat_length',
    'TE4d', 'TE_duplication_length',
    'TE4e', 'TE_target_sequence',
    'TE5a', 'TE_copies_in_sequenced_genome',
    'TE5c', 'TE_copies_in_genome',
    'TE6a', 'sequence',
    'TE6b', 'feature_dbxref',
    'TE6c', 'associated_with',                ###?feature_relationship object_id
    'TE7',  'phylogenetic_range',
    'TE8',  'has_component_gene',
    'TE9',  'isolate_of',                     ###?
    'TE10', 'in_vitro_descendant_of',         ###???Engineered constructs
    'TE11', 'alleleof',       # 'homologue', ###???feature_relationship
    'TE12', 'comment',
    'TE13', 'internalnotes'
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
    print STDERR "processing Gen.NatTE $ph{TE1a}...\n";
    if ( exists( $self->{v} ) && $self->{v} == 1 ) {
        $self->validate($tihash);
    }
    if(exists($fbids{$ph{TE1a}})){
        $unique=$fbids{$ph{TE1a}};
    }
    else{
        ($unique, $out)=$self->write_feature($tihash);
    }
        if(exists($fbcheck{$ph{TE1a}}{$ph{pub}})){
        print STDERR "Warning: $ph{TE1a} $ph{pub} exists in a previous proforma\n";
    }
    $fbcheck{$ph{TE1a}}{$ph{pub}}=1;
    if(!exists($ph{TE1i})){
      print STDERR "Action Items: TE $unique == $ph{TE1a} with pub $ph{pub}\n"; 
my $f_p = create_ch_feature_pub(
        doc        => $doc,
        feature_id => $unique,
        pub_id     => $ph{pub}
    );
    $out .= dom_toString($f_p);
    $f_p->dispose();
    }     
    else{
      $out .= dissociate_with_pub( $self->{db}, $unique, $ph{pub} );
      print STDERR "Action Items: dissociate $ph{TE1a} with $ph{pub}\n";
      return $out;
    }
    if(exists($ph{TE1h}) && $ph{TE1h} eq 'y'){
      return $out;
    }

    ##Process other field in Trangenic Insertion proforma
    foreach my $f ( keys %ph ) {

      #print $f,"\n";
      if ( $f eq 'TE1b'){
	if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
	  print STDERR "CHECK: !c for $f\n";
	  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
	  $out .= delete_feature_synonym( $self->{db}, $doc, $unique, $ph{pub} ,$ti_fpr_type{$f} );
	}
	if(defined($ph{$f}) && $ph{$f} ne ''){
	  my @items = split( /\n/, $ph{$f} );
	  foreach my $item (@items) {
	    $item =~ s/^\s+//;
	    $item =~ s/\s+$//;
	    my $t = $f;
	    $t =~ s/TE//;
	    if ( $f eq 'TE2a' && $item =~ /FBte/ ) {
	      my $dbxref = create_ch_feature_dbxref(
			doc        => $doc,
                        feature_id => $unique,
                        dbxref_id  => create_ch_dbxref(
                            doc       => $doc,
                            accession => $item,
                            db        => 'FlyBase'
                        ),
                        is_current => 'f'
                    );
                    $out .= dom_toString($dbxref);
                    $dbxref->dispose();
	      my ( $s_g, $s_s, $s_t ) =
		  get_feat_ukeys_by_uname( $self->{db}, $item );
	      my $s_f = create_ch_feature(
					    doc         => $doc,
					    uniquename  => $item,
					    genus       => $s_g,
					    species     => $s_s,
					    type        => $s_t,
					    is_obsolete => 't'
					   );
	      $out .= dom_toString($s_f);
	      $s_f->dispose();
	    }
	    else {
	      my $tt     = '';
	      my $s_type = 'symbol';
	      my $s_pub  = '';
	      if ( $t eq '1b' || $t eq '' ) {
		$s_pub = $ph{pub};
		$tt    = 'b';
		if($t eq '1b' && $item eq $ph{TE1a} ){
		  $tt='a';
		}
	      }
	      else {
		$s_pub = 'unattributed';
		if ( $t =~ /1a/ ) {
		  $tt = 'a';
		}
		else { 
		  $tt = 'd'; 
		}
	      }
	      $out .= write_feature_synonyms( $doc, $unique, $item, $tt, $s_pub,
                        $s_type );

	    }
	  }
        }
      }
      elsif($f eq 'TE1c' || $f eq 'TE14c'){
	if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
	  print STDERR "ERROR: $f can not accept !c\n";
	}
	$out .=
	  update_feature_synonym( $self->{db}, $doc, $unique, $ph{$f},
				    $ti_fpr_type{$f} );
	if($f eq 'TE1c'){
	  $fbids{$unique}=$ph{TE1a};
	}
      }
      elsif ( $f eq 'TE1g' ) {
	my $tmp=$ph{TE1g};
	$tmp=~s/\n/ /g;
	if($ph{TE1f} eq 'new'){
	  print STDERR "Action Items: merge TE $tmp\n";
	}
	else{
	  print STDERR "Action Items: merge TE $tmp to $ph{TE1f} == $ph{TE1a} \n";
	}
	$out .= merge_records( $self->{db}, $unique, $ph{$f},$ph{TE1a}, $ph{pub},$ph{TE14a} );
      }
      elsif ( $f eq 'TE6b' ) {
	if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
	  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
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
	    $item =~ s/^\s+//;
	    $item =~ s/\s+$//;
	    if( $item=~/(.*)\.(\d+)/){
	      my  $acc=$1; my $ver=$2;
	      $out .= dom_toString(create_ch_feature_dbxref(doc=>$doc, feature_id=>$unique, 
                      dbxref_id=>create_ch_dbxref(doc=>$doc, db=>'GB',accession=>$acc, version=>$ver)));
	    }
	  }
        }
      }
      elsif ($f eq 'TE6c'
	     || $f eq 'TE10'
	     || $f eq 'TE11'
	     || $f eq 'TE9'
	     || $f eq 'TE8' ){
	my $object  = 'object_id';
	my $subject = 'subject_id';
	if ( $f eq 'TE6c' || $f eq 'TE11' || $f eq 'TE8') {
	  $object  = 'subject_id';
	  $subject = 'object_id';
	}
	if ( exists( $ph{ $f . "upd" } ) and $ph{ $f . "upd" } eq 'c' ) {
	  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
	  my @results =
	    get_unique_key_for_fr( $self->{db}, $subject, $object,
				   $unique, $ti_fpr_type{$f}, $ph{pub} );
	  foreach my $ta (@results) {
	    my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );
	    if ( $num == 1 || (defined($frnum{$unique}{$ta->{name}}) && $num-$frnum{$unique}{$ta->{name}}==1) ) {
	      $out .=
		delete_feature_relationship( $self->{db}, $doc, $ta,
					     $object, $subject, $unique, $ti_fpr_type{$f} );
	    }
	    elsif ( $num > 1 ) {
	      $out .=
		delete_feature_relationship_pub( $self->{db}, $doc,
						 $ta, $object, $subject, $unique, $ti_fpr_type{$f},
						 $ph{pub} );
	    }
	    else {
	      print STDERR "ERROR:something Wrong, please validate first\n";
	    }
	  }
	}
	if ( $ph{$f} ne '' ) {
	  my @items = split( /\n/, $ph{$f} );
	  foreach my $item (@items) {

	    #my @temps=split(/\s\#\s/,$item);
	    #if($temps[0] eq ''){
	    #	$temps[0]=$ph{$f};
	    #}
	    my ($fr,$f_p)=
	      write_feature_relationship( $self->{db}, $doc, $subject,
					  $object, $unique, $item,
					  $ti_fpr_type{$f},$ph{pub},
					  $ti_feat_type{$f}  );
	    $out .=dom_toString($fr);
	    $out.=$f_p;
	  }
	}
      }
      elsif ($f eq 'TE5c'
            || $f eq 'TE5a'
            || $f eq 'TE4e'
            || $f eq 'TE7'
            || $f eq 'TE12'
            || $f eq 'TE13'
            || $f eq 'TE4b'
            || $f eq 'TE4c'
            || $f eq 'TE4d'
	     || $f eq 'TE6a' ){
	if ( exists( $ph{ $f . 'upd' } ) && $ph{ $f . 'upd' } eq 'c' ) {
	  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
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
	if ( $ph{$f} ne '' ) {
	  my @items = split( /\n/, $ph{$f} );
	  foreach my $item (@items) {
	    $item =~ s/^\s+//;
	    $item =~ s/\s+$//;
	    if ( $f eq 'TE5a' ) {
	      if(exists($ph{TE5b})){
		$item = $ph{TE5b} . ':' . $item;
	      }
	    }
	    elsif ( $f eq 'TE5c' ) {
	      if(exists($ph{TE5d})){
		$item = $ph{TE5d} . ':' . $item;
	      }
	    }
	    $out .=
	      write_featureprop( $self->{db}, $doc, $unique, $item,
				 $ti_fpr_type{$f}, $ph{pub} );
	  }
	}
      }
      elsif ( $f eq 'TE5' ) {
        print STDERR "Warning : in multiple field TE5\n";
            ##### multiple TE_copies_in_genome
	my @array = @{ $ph{TE5} };
	foreach my $ref (@array) {
	  my %te5 = %$ref;
	  foreach my $key ( keys %te5 ) {
	    my $value = '';
	    if ( $key eq 'TE5a' ) {
	      $value = $ph{TE5b} . ":" . $ph{TE5a};
	      $out .=
                          write_featureprop( $self->{db}, $doc, $unique, $value,
                            $ti_fpr_type{$key}, $ph{pub} );
	    }
	    elsif ( $key eq 'TE5c' ) {
	      $value = $ph{TE5d} . ":" . $ph{TE5c};
	      $out .=
		write_featureprop( $self->{db}, $doc, $unique, $value,
				   $ti_fpr_type{$key}, $ph{pub} );
	    }

	  }
	}
      }
      elsif ( $f eq 'TE4a' ) {
	if ( exists( $ph{'TE4a.upd'} ) && $ph{'TE4a.upd'} eq 'c' ) {
	  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
	  my @result =
	    get_cvterm_for_feature_cvterm( $self->{db}, $unique, 'SO',
					   $ph{pub} );

	  foreach my $item (@result) {
	    my ($cvterm, $obsolete)=split(/,,/,$item);
	    my $feat_cvterm = create_ch_feature_cvterm(
						       doc        => $doc,
						       feature_id => $unique,
						       cvterm_id  => create_ch_cvterm(
										      doc  => $doc,
										      cv   => 'SO',
										      name => $cvterm
										     ),
						       pub_id => $ph{pub}
						      );

	    $feat_cvterm->setAttribute( 'op', 'delete' );
	    $out .= dom_toString($feat_cvterm);
	    $feat_cvterm->dispose();
	  }
	}
	if ( defined($ph{$f}) && $ph{$f} ne '' ) {
	  my @items=split(/\n/,$ph{$f});
	  foreach my $item(@items){
	    $item=~s/^\s//;
	    $item=~s/\s$//;
	    if($item=~/(.*)\s+;\s+SO/){
	      $item=$1;
	    }
	    if($item ne ''){
	      validate_cvterm($self->{db},$item,'SO');
	      my $f_cvterm = &create_ch_feature_cvterm(
						       doc        => $doc,
						       feature_id => $unique,
						       cvterm_id  => create_ch_cvterm(
										      doc  => $doc,
										      cv   => 'SO',
										      name => $item
										     ),
						       pub_id => $ph{pub}
						      );
	      $out .= dom_toString($f_cvterm);
	      $f_cvterm->dispose();
	    }
	  }
	}
      }

    }
    $doc->dispose();
    return $out;
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
   
 
    if ( $ph{TE1f} ne 'new') {
        if(defined($fbids{$ph{TE1a}}) && !exists($ph{TE1c}) && !exists($ph{TE1h})){
            $unique=$fbids{$ph{TE1a}};
        }
        else{
        ( $genus, $species, $type ) =
          get_feat_ukeys_by_uname( $self->{db}, $ph{TE1f} );
         if ( $genus eq '0' ) {
            print STDERR "ERROR: could not find record for $ph{TE1f}\n";
            exit(0);
        }
        $unique=$ph{TE1f};
            $feature = create_ch_feature(
            doc        => $doc,
            uniquename => $unique,
            species    => $species,
            genus      => $genus,
            type       => $type,
            macro_id   => $unique,
            no_lookup  => 1
        );
        if ( exists( $ph{TE1h} ) && $ph{TE1h} eq 'y' ) {
            print STDERR "Action Items: delete natural transposon $ph{TE1f} == $ph{TE1a}\n";
            my $op = create_doc_element( $doc, 'is_obsolete', 't' );
            $feature->appendChild($op);
        }
         if(exists($ph{TE1c})){
	     if(exists($fbids{$ph{TE1c}})){
		 print STDERR "ERROR: Rename TE1c $ph{TE1c} exists in a previous proforma\n";
	     }
	     if(exists($fbids{$ph{TE1a}})){                                    
		 print STDERR "ERROR: Rename TE1a $ph{TE1a} exists in a previous proforma \n";
	     }  

            print STDERR "Action Items: rename $ph{TE1f} from $ph{TE1c} to $ph{TE1a}\n";
            my $n=create_doc_element($doc,'name',decon(convers($ph{TE1a})));
            $feature->appendChild($n);
            $out.=dom_toString($feature);
            $out .=
              write_feature_synonyms( $doc, $unique, $ph{TE1a}, 'a',
                'unattributed', 'symbol' );
            $fbids{$ph{TE1c}}=$unique;
        }
        else{
            $out.=dom_toString($feature);
        }
        $fbids{ $ph{TE1a} } = $unique;
       }
    }
    else {
      if(!exists($ph{TE1g})){
	$flag=0;       
	my $va=validate_new_name($db, $ph{TE1a});
      }
      ( $unique, $flag ) = get_tempid( 'te', $ph{TE1a} );
      print STDERR "$unique =", $ph{TE1a}, "\n";        
      $fbids{$ph{TE1a}}=$unique;
      ### if the temp id has been used before, $flag will be 1 to avoid
        ### the DB Trigger reassign a new id to the same symbol.
      if(exists($ph{TE1g}) && $ph{TE1f} eq 'new' && $unique !~/temp/){
	print STDERR "ERROR: merge tes should have a FB..:temp id not $unique\n";
      }
      print STDERR "Action Items: new TE $ph{TE1a}\n";        
      if ( exists( $ph{TE3} ) ) {
	( $genus, $species ) =
	  get_organism_by_abbrev( $self->{db}, $ph{TE3} );
      }
      elsif ( $ph{TE1a} =~ /^(.{2,14}?)\\(.*)/ ) {
	( $genus, $species ) = get_organism_by_abbrev( $self->{db}, $1 );
	if($genus eq '0'){
	  print STDERR "ERROR: could not get genus for TE $ph{TE1a}\n";
	  exit(0);
	}
      }
      if ( $flag == 0 ) {
	$feature = create_ch_feature(
				   uniquename => $unique,
				   name       => decon( convers( $ph{TE1a} ) ),
				   genus      => $genus,
				   species    => $species,
				   type       => 'natural_transposable_element',
				   doc        => $doc,
				   macro_id   => $unique,
				   no_lookup  => '1'
				  );
	$out.=dom_toString($feature);
	$out .=
	  write_feature_synonyms( $doc, $unique, $ph{TE1a}, 'a',
                'unattributed', 'symbol' );
      }
      else{
	print STDERR "ERROR, name $ph{TE1a} has been used in this load\n";
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
 
    print STDERR "validating TE ", $tival{TE1a}, "\n";
    
    if(exists($tival{TE1f}) && ($tival{TE1f} ne 'new')){
        validate_uname_name($db, $tival{TE1f}, $tival{TE1a});
    }
    if ( exists( $fbids{$tival{TE1a}})){
        $v_unique=$fbids{$tival{TE1a}};    
    }
    else{
        print STDERR "ERROR: could not validate $tival{TE1a}\n";
        return;
    }
    
        foreach my $f ( keys %tival ) {
          if($f eq 'TE8' || $f eq 'TE9' || $f eq 'TE10' || $f =~ 'TE11'){
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
            if ( $f =~ /(.*)\.upd/ && !($v_unique=~/temp/) ) {
                $f = $1;
                if (   $f eq 'TE5c'
                    || $f eq 'TE5a'
                    || $f eq 'TE4e'
                    || $f eq 'TE7'
                    || $f eq 'TE12'
                    || $f eq 'TE13'
                    || $f eq 'TE4b'
                    || $f eq 'TE4c'
                    || $f eq 'TE4d' )
                {
                    my $num =
                      get_unique_key_for_featureprop( $db, $v_unique,
                        $ti_fpr_type{$f}, $tival{pub} );
                    if ( $num == 0 ) {
                        print STDERR
                          "ERROR: there is no previous record for $f field.\n";
                    }
                }
                elsif ($f eq 'TE6c'
                    || $f eq 'TE10'
                    || $f eq 'TE11'
                    || $f eq 'TE9'
                    || $f eq 'TE8' )
                {    my $object  = 'object_id';
            my $subject = 'subject_id';
            if ( $f eq 'TE6c' ) {
                $object  = 'subject_id';
                $subject = 'object_id';
            }
                    my $num =
                      get_unique_key_for_fr( $db,$subject,$object, $v_unique,
                        $ti_fpr_type{$f}, $tival{pub} );
                    if ( $num == 0 ) {
                        print STDERR
                          "ERROR: There is no previous record for $f field\n";
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

! TE. NATURAL TRANSPOSON, GENERIC DATA PROFORMA      Version 4: 26 January 2007

! TE1f. ID for gen.natTE (FBte or "new")       :new
! TE1a. gen.natTE symbol to use in database    :
! TE1b. gen.natTE symbol used in paper         :
! TE3.  Species                                :

! TE14a.  gen.natTE name to use in database      :
! TE14b.  gen.natTE name used in paper           :
! TE14c.  Database gen.natTE name(s) to replace  :

! TE1c. Action - rename this gen.natTE symbol    :
! TE1g. Action - merge these gen.natTE(s) (FBte) :
! TE1h. Action - delete gen.natTE record ("y"/blank)   :
! TE1i. Action - dissociate TE1f from FBrf ("y"/blank) :

! TE2a. Other synonym(s) for gen.natTE symbol  :
! TE2b. Silent synonym(s) for gen.natTE symbol :

! TE4a. Transposon type [CV]                :
! TE4b. Length of complete element, bp      :
! TE4c. Terminal repeat length, bp          :
! TE4d. Target site duplication, bp         :
! TE4e. Target site sequence (if consensus) :

! TE5a. Number of copies in sequenced genome (dupl for multiple):
!   TE5b. Description of sequenced genome    :
! TE5c. Number of copies in reported genome (dupl for multiple) :
!   TE5d. Description of reported genome(s)  :

! TE6a. Reference sequence for complete element :
! TE6b. Accession(s) for gen.natTE              :
! TE6c. Accession(s) for flanking sequence      :
! TE7.  Phylogenetic range  :
! TE8.  Component gene(s)   :

! TE9.  Named isolates        :
! TE10. Engineered constructs :
! TE11. Other variants        :

! TE12. Comments            :
! TE13. Internal comments   :
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

=head1 AUTHOR

Haiyan Zhang, E<lt>haiyan@morgan.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
