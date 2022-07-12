package FlyBase::Proforma::Tool;

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

our $VERSION = '0.02';

=head1 NAME

FlyBase::Proforma::Tool - Perl module for parsing the FlyBase
EXPERIMENTAL TOOL PROFORMA                       Version 4:  31 Oct 2017
See the bottom for the proforma
                         
=head1 SYNOPSIS

  use FlyBase::Proforma::Tool;
  use DBI;
  
  my $mdbh=DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";
  my %ph=(A1a=>'TM9', A1g=>'y',....);
  ###!c field implemented as '$fieldname.upd=>'c'' eg. 'A16.upd'=>'c'
   
  #params db is manditory, debug and validate is optional
  my $pro=FlyBase::proforma::Tool->new(db=>$mdbh);
  $pro->validate(%ph);
  my $chadoxml = $pro->process(%ph);
  
  # or

  my $pro=FlyBase::Proforma::Tool->new(db=>$mdbh,debug=>1,validate=>1);
  my $chadoxml_string=$pro->process(%ph);

=head1 DESCRIPTION

FlyBase::Proforma::Tool is a perl module for parsing FlyBase
Tool proforma and write the result as chadoxml. It is required
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
#    'TO1f'     #uniquename new or FBid 
    'TO1a', 'symbol',      #feature_synonym MA1a
    'TO1b', 'symbol',      #feature_synonym MA1b
#    'TO10' #species abbrev organism_id -- MA20 default Ssss
    'TO1c', 'symbol',  #rename MA1c
#    'TO1g'  #merge_function MA1g
    'TO1h', 'is_obsolete',       #feature.is_obsolete MA1h
    'TO1i', 'dissociate_pub',    #feature_pub... MAli
    'TO2a', 'fullname',    #feature_synonym G2a
    'TO2b', 'fullname',    #feature_synonym G2b
    'TO2c', 'fullname',    #feature_synonym G2c
    'TO4',  'FlyBase miscellaneous CV',        #feature_cvterm G30, feature_cvtermprop type 'tool_uses' cv 'feature_cvtermprop type'
    'TO5', 'description', #featureprop single
#    'TO6a', #feature_dbxref TO6a = dbxref.accession, TO6b = db.name, TO6c = dbxref.description GG8c, TO6d change accession GG8d
    'TO7a', 'compatible_tool',  # feature_relationship.object  valid tool symbol GA11 multiple
    'TO7b', 'related_tool',  # feature_relationship.object valid tool GA11 multiple
    'TO7c',  'originates_from',  # feature_relationship.object Valid Gene symbol GA11 single
    'TO8', 'misc',     #featureprop MA9
    'TO9',  'internal_notes',    #featureprop MA10
);

my %feat_type = (
    'TO7a', 'engineered_region',
    'TO7b', 'engineered_region',
    'TO7c', 'gene',
);
my %id_type = ( 'TO7a', 'to', 'TO7b', 'to', 'TO7c', 'gn');

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
#

sub process {
    my $self    = shift;
    my $tihash  = {@_};
    my %ph      = %$tihash;
    my $unique  = '';
    my $flag    = 0;
    my $feature = '';
    my $genus='synthetic';
    my $species='construct';
    my $type='engineered_region';
    my $out = '';


   if ( exists( $self->{debug} ) && $self->{debug} == 1 ) {
        foreach my $key ( keys %ph ) {
            print STDERR "$key, $ph{$key}\n";
        }
    }

    if ( exists( $self->{validate} ) && $self->{validate} == 1 ) {
        $self->validate(%ph);
    }
    
    if(exists($fbids{$ph{TO1a}})){
        $unique=$fbids{$ph{TO1a}};
    }
    else{
       print "ERROR: $ph{file} $ph{pub} could not get uniquename for $ph{TO1a}\n";
        #($unique, $out)=$self->write_feature($tihash);
        return $out;
    }
    print STDERR "processing Tool $ph{file} $ph{pub} " . $ph{TO1a} . "...\n";
    if(exists($fbcheck{$ph{TO1a}}{$ph{pub}})){
    print STDERR "Warning: $ph{TO1a} $ph{pub} in this file $ph{file} exists in a previous proforma\n";
    }

    $fbcheck{$ph{TO1a}}{$ph{pub}}=1;
    if(!exists($ph{TO1i}) ){
    if( $ph{pub} ne 'FBrf0000000'){
     print STDERR "Action Items: tool $unique == $ph{TO1a} with pub $ph{pub}\n"; 
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
	print STDERR "Action Items: $ph{TO1a} dissociate with pub $ph{pub} $ph{file}\n";
	$out .= dissociate_with_pub( $self->{db}, $unique, $ph{pub} );
	return ($out);
    }

    ##Process other field in Tool proforma
    foreach my $f ( keys %ph ) {
        if ( $f eq 'TO1b' || $f eq 'TO2b' ) {
            if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
            print STDERR "Action Items: !c log, $ph{TO1a} $f  $ph{pub} $ph{file}\n";
            $out .=
                      delete_feature_synonym( $self->{db}, $doc, $unique, $ph{pub}, $ti_fpr_type{$f} );
            
            }
            if(defined ($ph{$f}) && $ph{$f} ne ''){
            my @items = split( /\n/, $ph{$f} );
            foreach my $item (@items) {
                $item =~ s/^\s+//;
                $item =~ s/\s+$//;
                my $t = $f;
                $t =~ s/^TO\d//;
               
                if ( $item ne 'unnamed' && $item ne '' ) {
                    if ( ( $f eq 'TO1b' ) && ( $item eq $ph{TO1a} ) ) {
                        $t = 'a';
                    }
                    elsif (( $f eq 'TO2b' )
                        && exists( $ph{TO2a} )
                        && ( $item eq $ph{TO2a} ) )
                    {
                        $t = 'a';
                    }
                    elsif ( !exists( $ph{TO2a} ) && $f eq 'TO2b' ) {
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
	  elsif($f eq 'TO2a'){
	        if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
	           print STDERR "ERROR: TO2a can not accept !c $ph{TO1a} $ph{pub} $ph{file}\n";
	         }
		my $num = check_feature_synonym( $self->{db},
                            $unique,  'fullname' );
		if( $num != 0){
		  if ((defined($ph{TO2c}) && $ph{TO2c} eq '' && !defined($ph{TO1g})) || (!defined($ph{TO2c}) && !defined($ph{TO1g}) )) {
		    print STDERR "ERROR: TO2a must have TO2c filled in unless a merge  $ph{TO1a} $ph{pub} $ph{file}\n";
		  }
		  else{
		    $out.=write_feature_synonyms($doc,$unique,$ph{$f},'a','unattributed',$ti_fpr_type{$f});
		  }
		}
		else{
		  $out.=write_feature_synonyms($doc,$unique,$ph{$f},'a','unattributed',$ti_fpr_type{$f});
		}
	  }
        elsif ( $f eq 'TO1c' || $f eq 'TO2c' ) {
           if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
	           print STDERR "ERROR: $f can not accept !c\n";
	         }
	   if ( $f eq 'TO2c' ) { 
	       my $t = check_feature_synonym_is_current( $self->{db},
                            $unique, $ph{$f}, $ti_fpr_type{$f} );
	       if ($t ne 'a'){
		   print STDERR "ERROR: $f $ph{$f} is not the current synonym $ph{TO1a} $ph{pub} $ph{file}\n";
	       }
	   }
	   $out .=
              update_feature_synonym( $self->{db}, $doc, $unique, $ph{$f},
                $ti_fpr_type{$f} );
              
        }
        elsif ( $f eq 'TO1i' ) {
            print STDERR "Action Items in process other fields: $ph{TO1a} dissociate with pub $ph{pub}  $ph{file}\n";
            $out .= dissociate_with_pub( $self->{db}, $unique, $ph{pub} );
        }
        elsif ( $f eq 'TO1g' ) {
        
            $out .=
              merge_records( $self->{db}, $unique, $ph{$f},$ph{TO1a}, $ph{pub} , $ph{TO2a});	
                if(defined($ph{TO2a})){
                $out.=write_feature_synonyms($doc,$unique,$ph{TO2a},'a','unattributed',$ti_fpr_type{TO2a});
                }
        }       
        elsif ( $f eq 'TO4' ) {
	    if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
              print STDERR "Action Items: !c log,$ph{TO1a} $f  $ph{pub} $ph{file}\n";
                my @results = get_cvterm_for_feature_cvterm_withprop(
                    $self->{db}, $unique, $ti_fpr_type{$f},
                    $ph{pub},    'tool_uses'
                );
	      if(@results==0){
		  print STDERR "ERROR: not previous record found for $ph{TO1a} $f $ph{pub} $ph{file}\n";
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
              print STDERR "DEBUG feature_cvterm $ph{TO1a} $f $ph{pub} $ph{file}\n";
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
		    print STDERR "DEBUG validate cvterm $ti_fpr_type{$f}, $item  $ph{TO1a} $f $ph{pub} $ph{file}\n";
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
                                name=>'tool_uses',
                                cv=>'feature_cvtermprop type'),
                        rank => '0'
                    );
                    $f_cvterm->appendChild($fcvprop);
                    $out .= dom_toString($f_cvterm);
                    $f_cvterm->dispose();
                }
            }

        }

	elsif ($f eq 'TO7a'
	   || $f eq 'TO7b'
	   || $f eq 'TO7c'
	    )
	{ 
	    my $object  = 'object_id';
	    my $subject = 'subject_id';
	    if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
		print STDERR "Action Items: !c log,$ph{TO1a} $f  $ph{pub}\n";
		my @results = get_unique_key_for_fr_by_feattype(
		    $self->{db}, $subject,      $object,
		    $unique,     $ti_fpr_type{$f}, $ph{pub}, $feat_type{$f}
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
	    if (defined($ph{$f}) && $ph{$f} ne '' ) {
		if ($f eq 'TO7a'
		    || $f eq 'TO7b')
		{ 
		    my @items = split( /\n/, $ph{$f} );
		    foreach my $item (@items) {
			$item =~ s/^\s+//;
			$item =~ s/\s+$//;
			my ($fr,$f_p) = write_feature_relationship(
			    $self->{db},   $doc,     $subject,
			    $object,       $unique,  $item,
			    $ti_fpr_type{$f}, $ph{pub}, $feat_type{$f},
			    $id_type{$f}
			    );
			$out .= dom_toString($fr);
			$out.=$f_p;
		    }
		}
		elsif($f eq 'TO7c'){
			my ($fr,$f_p) = write_feature_relationship(
			    $self->{db},   $doc,     $subject,
			    $object,       $unique,  $ph{TO7c},
			    $ti_fpr_type{$f}, $ph{pub}, $feat_type{$f},
			    $id_type{$f}
			    );
			$out .= dom_toString($fr);
			$out.=$f_p;
		    }
		    
	    }		
	} # end elsif ($f eq 'TO7a' || $f eq 'TO7b' || $f eq 'TO7c')

        elsif ( $f eq 'TO5' 
		|| $f eq 'TO8'
		|| $f eq 'TO9'
	    )
        {
            my $rn=0;
            if ( exists( $ph{ "$f.upd" } ) && $ph{ "$f.upd" } eq 'c' ) {
		print STDERR "Action Items: !c log, $unique $ph{TO1a} $f  $ph{pub} $ph{file}\n";
                my @results =
		    get_unique_key_for_featureprop( $self->{db}, $unique,
						    $ti_fpr_type{$f},, $ph{pub} );
                $rn+=@results;  
                foreach my $t (@results) {
                    print STDERR $t->{fp_id},"\n";   
                    my $num = get_fprop_pub_nums( $self->{db}, $t->{fp_id} );
                    if ( $num == 1 || (defined($frnum{$unique}{$ti_fpr_type{$f}}{$t->{rank}}) && $num-$frnum{$unique}{$ti_fpr_type{$f}}{$t->{rank}}==1)) {
			$out .=
			    delete_featureprop( $doc, $t->{rank}, $unique,
						$ti_fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
			    delete_featureprop_pub( $doc, $t->{rank}, $unique,
						    $ti_fpr_type{$f},$ph{pub} );
                    }
                    else {
                        print STDERR "something Wrong, please validate first\n";
                    }
                }
		if($rn==0){
                    print STDERR "ERROR: there is no previous record for $f $ph{TO1a} $ph{pub} $ph{file}\n";
		}
            } #end !c
            if (defined($ph{$f}) && $ph{$f} ne '' ) {
                if($f eq 'TO5'){
#one per pub
                    if(exists( $ph{ "$f.upd" } ) && $ph{ "$f.upd" } eq 'c' ){
                        $out .=
                            write_featureprop( $self->{db}, $doc, $unique, $ph{$f},
                                               $ti_fpr_type{$f}, $ph{pub} );
                    }
                    else{
                        print STDERR "DEBUG: $f $ph{TO1a} $ph{pub} $ph{file} not !c\n";
                        my @results = get_unique_key_for_featureprop( $self->{db}, $unique,
                                                                       $ti_fpr_type{$f}, $ph{pub} );
                        my $num = scalar(@results);
                       print STDERR "DEBUG: $f $ph{TO1a} $ph{pub} $ph{file} not !c num = $num\n";                        
                        if($num == 0){
                            $out .= 
                                write_featureprop( $self->{db}, $doc, $unique, $ph{$f},
                                                $ti_fpr_type{$f}, $ph{pub} );
                        }
                        else{
                            print STDERR "ERROR: $f previous record found for $unique $ph{TO1a} $ph{pub} $ph{file}\n";
                        }
                    }   
                }
		else{
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
	} #end TO5, TO8, TO9

        elsif($f eq 'TO6a'){
		print STDERR "CHECK: field $f $ph{TO1a} $ph{pub} $ph{file}\n";
	  $out.= &parse_dataset($unique,\%ph);
        }
        elsif($f eq 'TO6'){
	  print STDERR "CHECK: in multiple field TO6\n";
	  ##### feature_dbxref multiple db/accessions
	  my @array = @{ $ph{$f} };
	  print STDERR "CHECK: there are ".  ($#array+1) ." \n";
	  foreach my $ref (@array) {
	    print STDERR "CHECK: field $f $ph{TO1a} $ph{pub} $ph{file}\n";
	    $out .= &parse_dataset( $unique, $ref);
	  }
        }

    }#end foreach
    $doc->dispose();
    return ( $out);
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
    my $genus='synthetic';
    my $species='construct';
    my $type='engineered_region';
    my $out = '';

  if ( exists( $ph{TO1f} ) && $ph{TO1f} ne 'new' ){
    ( $genus, $species, $type ) =
      get_feat_ukeys_by_uname( $self->{db}, $ph{TO1f});
    if($genus eq '0' || $genus eq '2'){
      print STDERR "ERROR: could not find $ph{TO1f} for symbol $ph{TO1a} in DB $ph{pub} $ph{file}\n";
      
    }
    if(!exists($ph{TO1c})){
	($unique,$genus,$species,$type)=get_feat_ukeys_by_name($self->{db},$ph{TO1a}) ;
	if($unique ne $ph{TO1f}){
	    print STDERR "ERROR: name and uniquename not match $ph{TO1f}  $ph{TO1a}  $ph{pub} $ph{file}\n";
	    exit(0);
	}
    } 

    $unique = $ph{TO1f};
    if(!exists($ph{TO1a})){
      print STDERR "ERROR: no TO1a field $ph{pub} $ph{file}\n";
    }
    if(exists($fbids{$unique})){
      print STDERR "ERROR:  $ph{pub} $ph{file} $unique has been in previous proforma with an action item, separate loading\n";
      return ($out,$unique);
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
    if ( exists( $ph{TO1h} ) && $ph{TO1h} eq 'y' ) {
      print STDERR "Action Items: delete Tool $ph{TO1f} == $ph{TO1a}\n";
      my $op = create_doc_element( $doc, 'is_obsolete', 't' );
      $feature->appendChild($op);
    }
    if(exists($ph{TO1c})){
	if(exists($fbids{$ph{TO1c}})){
	    print STDERR "ERROR: Rename TO1c $ph{TO1c} exists in a previous proforma\n";
	}
	if(exists($fbids{$ph{TO1a}})){                                    
	    print STDERR "ERROR: Rename TO1a $ph{TO1a} exists in a previous proforma \n";
	}  
	print STDERR "Action Items: Rename $ph{TO1c} to $ph{TO1a} $ph{pub} $ph{file}\n";
	my $va=validate_new_name($db, $ph{TO1a});
	if ($va == 0){
	    my $n=create_doc_element($doc,'name',decon(convers($ph{TO1a})));
	    $feature->appendChild($n);
	    $out.= dom_toString($feature);
	    $out .= write_feature_synonyms( $doc, $unique, $ph{TO1a}, 'a', 'unattributed', 'symbol' );
	    $fbids{$ph{TO1c}}=$unique;
	}
    }
    else{
      $out.=dom_toString($feature);
    }
    $fbids{ $ph{TO1a} } = $unique;
  }
  elsif (  exists( $ph{TO1f} ) && $ph{TO1f} eq 'new')  {
    if(!exists($ph{TO1g})){
      $flag=0;
      my $va=validate_new_name($db, $ph{TO1a});
      if($va==1){
	$flag=0;
	($unique,$genus,$species,$type)=get_feat_ukeys_by_name($db,$ph{TO1a});
	$fbids{$ph{TO1a}}=$unique;
      }
    }
    ( $unique, $flag ) = get_tempid( 'to', $ph{TO1a} );
    if(exists($ph{TO1g}) && $ph{TO1f} eq 'new' && $unique !~/temp/){
      print STDERR "ERROR: merge tools should have a FB..:temp id not $unique $ph{pub} $ph{file}\n";
    }
    print STDERR "Action Items: new Tool $ph{TO1a} \n";
    if ( exists( $ph{TO10} ) ) {
      ( $genus, $species ) =
	get_organism_by_abbrev( $self->{db}, $ph{TO10} );
      if($genus eq '0'){
	  print STDERR "ERROR: could not get genus for Tool $ph{TO1a} $ph{pub} $ph{file} \n";
	  exit(0);
      }
    }
    else{
	print STDERR "ERROR: TO10 must be filled in for new Tool $ph{TO1a} $ph{pub} $ph{file} \n";
    }
      
    if ( $flag == 0 ) {
      $feature = create_ch_feature(
                uniquename => $unique,
                name       => decon( convers( $ph{TO1a} ) ),
                genus      => $genus,
                species    => $species,
                type       => $type,
                doc        => $doc,
                macro_id   => $unique,
                no_lookup  => '1'
				  );
      $out.=dom_toString($feature);
      $out .=
	write_feature_synonyms( $doc, $unique, $ph{TO1a}, 'a',
                'unattributed', 'symbol' );
    }
    else{
      print STDERR "ERROR,  $ph{pub} $ph{file} name $ph{TO1a} has been used in this load\n";
    }
  }
    else{
      print STDERR "ERROR: TO1f must be new or FBto id $ph{pub} $ph{file} \n";
    }     
  
  $doc->dispose();
  return ($out, $unique);
}

  sub parse_dataset {
    my $unique  = shift;
    my $generef = shift;
    my %affgene = %$generef;
    my $dbname    = '';
    my $dbxref   = '';
    my $descr = '';
    my $out     = '';
    
    print STDERR "DEBUG: $affgene{TO6a} $affgene{file} $affgene{pub}\n";

    if ( defined($affgene{"TO6a.upd"}) && $affgene{'TO6a.upd'} eq 'c' ) {
      print STDERR "ERROR: !c not allowed in dbxref TO6a $affgene{TO1a} $affgene{file} $affgene{pub} \n";
      return $out;
    }

    if((defined($affgene{TO6a}) && $affgene{TO6a} ne '') && $affgene{TO6d} eq 'y'){
	print STDERR "Action item: dissociate dbxref (data_link) $affgene{TO6b}:$affgene{TO6a} with Dataset $unique\n";
	if(defined($affgene{TO6b}) && $affgene{TO6b} ne ''){
	    my ($dname,$acc,$ver) = get_unique_key_for_tool_dbxref($db,$unique, $affgene{TO6b},$affgene{TO6a});
	    print STDERR "back from get_unique_key_for_tool_dbxref db $dname accession $acc version $ver \n";
	    
	    if ($dname eq "0"){
		print STDERR "ERROR:cannot dissociate dbxref (data_link) $affgene{TO6b}:$affgene{TO6a} with Tool $unique $affgene{file} $affgene{pub} \n";
		return $out;
	    }
	    else{
		print STDERR "in Tool.pm  $affgene{file} $affgene{pub} $unique: db.name = $dname acc = $acc version = $ver\n";
		my $fd;
		if ($ver ne "NA"){
		    $fd=create_ch_feature_dbxref(doc=>$doc, 
                                            feature_id=>$unique,
					    dbxref_id => create_ch_dbxref(doc => $doc,
									  db => $dname,
									  accession => $acc,
									  version=> $ver,
					    ),
			);
		}
		else{
		    $fd=create_ch_feature_dbxref(doc=>$doc, 
                                            feature_id=>$unique,
					    dbxref_id => create_ch_dbxref(doc => $doc,
									  db => $dname,
									  accession => $acc,
					    ),
			);
		}		
		$fd->setAttribute( 'op', 'delete' );
		$out.= dom_toString($fd);         
		return $out;
	    }
	}
	else{
	    print STDERR "ERROR: TO6b required for dbxref with TO6a TO6d $unique $affgene{file} $affgene{pub}\n";
	    return $out;
	}
    }

    if(defined($affgene{TO6b}) && $affgene{TO6b} ne ''){
      my $dbxref_dom = "";
      my $dbname=validate_dbname($db,$affgene{TO6b});
      if($dbname ne ''){
#          print STDERR "DEBUG: found valid dbname = $dbname matches $affgene{TO6b}\n";
          #get accession
          if(defined($affgene{TO6a}) && $affgene{TO6a} ne ''){ 
              my $val=get_dbxref_by_db_dbxref($db,$dbname,$affgene{TO6a});
              if($val == 0){
                  $dbxref = $affgene{TO6a};

                  if(exists($fbdbs{$dbname.$dbxref})){
                      $dbxref_dom=$fbdbs{$dbname.$dbxref};
#                      print STDERR "DEBUG: exists $dbname.$dbxref in val= 0\n";

                  }
                  else{
#                      print STDERR "DEBUG: new accession in TO6a $affgene{TO6a} $affgene{TO6b}\n";  
                      if(defined($affgene{TO6c}) && $affgene{TO6c} ne ''){
                          print STDERR "DEBUG: $dbname $affgene{TO6a} description TO6c $affgene{TO6c}\n";
                          $descr = $affgene{TO6c};
                      }
                      else{
                          $descr = $affgene{TO6a};
                      }
                      $dbxref_dom=create_ch_dbxref(doc=>$doc, 
                                           accession=>$dbxref, db=>$dbname, version=>'1',
                                           description=>$descr, macro_id=>$dbname.$dbxref, no_lookup=>1);
                      $fbdbs{$dbname.$dbxref}=$dbname.$dbxref;
                      $out.=dom_toString($dbxref_dom);
                  }
                  my $fd=create_ch_feature_dbxref(doc=>$doc, 
                                          feature_id=>$unique,
                                          dbxref_id=>$dbname.$dbxref);                          
                  $out.=dom_toString($fd);
              }
              elsif($val == 1){

                  $dbxref = $affgene{TO6a};
                  if(exists($fbdbs{$dbname.$dbxref})){
                      $dbxref_dom=$dbname.$dbxref;
                      print STDERR "DEBUG: exists $dbname.$dbxref in val= 1\n";

		  }
                  else{
                      my $version = &get_version_from_dbxref($db,$dbname,$affgene{TO6a});
                      if($version eq "0"){
                          print STDERR "ERROR: Multiple accessions in chado with  $affgene{TO6b} $affgene{TO6a} need to know version $affgene{file} $affgene{pub}\n";
                      }
                      else{
#                          print STDERR "DEBUG: accession in TO6a $affgene{TO6a} version $version found\n";  
                          if(defined($affgene{TO6c}) && $affgene{TO6c} ne ''){
                              print STDERR "WARN: $dbname.$affgene{TO6a} exists TO6c $affgene{TO6c} will be ignored\n"; 
                          }
			  if($version ne ""){
			      $dbxref_dom=create_ch_dbxref(doc=>$doc, 
							   accession=>$dbxref, db=>$dbname, version=>$version,
							   macro_id=>$dbname.$dbxref,);
			  }
			  else{
			      $dbxref_dom=create_ch_dbxref(doc=>$doc, 
							   accession=>$dbxref, db=>$dbname,
							   macro_id=>$dbname.$dbxref,);
			  }
			  $fbdbs{$dbname.$dbxref}=$dbname.$dbxref;
                          $out.=dom_toString($dbxref_dom);
                      }
		  }
		  my $fd=create_ch_feature_dbxref(doc=>$doc, 
                                            feature_id=>$unique,
                                            dbxref_id=>$dbxref_dom);
                                                      
		  $out.=dom_toString($fd);
              }
          }
        else{
          print STDERR "ERROR: NO accession in TO6a $affgene{TO6a} $affgene{TO1a} $affgene{file} $affgene{pub}\n";
        }
      }
      else{
        print STDERR "ERROR: NO dbname found for $affgene{TO6b} -- create DB first $affgene{TO1a} $affgene{file} $affgene{pub} \n";
      }
    }
    return $out;
  }


=head2 $pro->validate(%ph)

   validate the following:
    2. if a new record, !c can not be exists.
    3. validate TO4 for the current cvterm in DB (FBcv)
    4. !c validation: has to have records in DB

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

    print STDERR "Validating Tool ", $tival{TO1a}, " ....\n";
    
    if(exists($fbids{$tival{TO1a}})){
        $v_unique=$fbids{$tival{TO1a}};
    }
    else{
        print STDERR "ERROR: did not have the first parse\n";
    }
    if ( exists( $tival{TO2c} ) ) {
        if ( !exists( $tival{TO2a} ) ) {
            print STDERR "ERROR: TO2a has to be existed when TO2c is filled\n";
        }
    }
   
    if ( $v_unique =~ 'FBto:temp' ) {
        foreach my $fu ( keys %tival ) {
            if ( $fu =~ /(.*)\.upd/ ) {
                print STDERR "Wrong !c fields  $1 for a new record \n";
            }
        }
    }

    foreach my $f ( keys %tival ) {
        if($f eq 'TO4' ){
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

proformas can be found in svn https://svn.flybase.org/documents/curation/proformae/

proforma mapping table can be found in ?

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

! EXPERIMENTAL TOOL PROFORMA                       Version 4:  31 Oct 2017
!
! TO1f. Database ID for experimental tool (FBto)       :new
! TO1a. Experimental tool symbol to use in database    :
! TO1b.  Experimental tool symbol synonym(s)           :
! TO10. Species of tool (organism.abbreviation)        :
!
! TO1c. Action - rename this experimental tool symbol  :
! TO1g. Action - merge these experimental tools (FBto) :
! TO1h. Action - obsolete TO1a in FlyBase (y/blank)       :
! TO1i. Action - dissociate TO1a from reference (y/blank) :
!
! TO2a.  Action - experimental tool name to use in FlyBase       :
! TO2b.  Experimental tool name synonym(s)                       :
! TO2c.  Action - rename this experimental tool name             :
!
! TO4.   Experimental tool uses [CV]                             :
! TO5.   Description of experimental tool [free text]            :
!
! TO6a. Accession number for tool (dupl section for multiple)    :
! TO6b. FlyBase database symbol (DB1a) for accession in TO6a     :
! TO6c. Title for TO6a (if desired) [free text]                  :
! TO6d. Action - dissociate accession in TO6a/TO6b from tool in TO1a? (blank/y) :
!
! TO7a. Compatible tools(s) (symbol) :
! TO7b. Other related tools(s) (symbol) :
! TO7c. Gene of origin (symbol)   :
!
! TO8.  Comments [free text] :
! TO9.  Internal notes       :
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!




