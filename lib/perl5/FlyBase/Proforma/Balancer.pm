package FlyBase::Proforma::Balancer;

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

=head1 NAME

FlyBase::Proforma::Balancer - Perl module for parsing the FlyBase
Genotype Variant  proforma version 17, May 9, 2007.

See the bottom for the proforma
                         
=head1 SYNOPSIS

  use FlyBase::Proforma::Balancer;
  use DBI;
  
  my $mdbh=DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";
  my %ph=(AB1a=>'TM9', AB8=>'y',....);
  ###!c field implemented as '$fieldname.upd=>'c'' eg. 'AB5a.upd'=>'c'
   
  #params db is manditory, debug and validate is optional
  my $pro=FlyBase::proforma::Balancer->new(db=>$mdbh);
  $pro->validate(%ph);
  my $chadoxml = $pro->process(%ph);
  
  # or

  my $pro=FlyBase::Proforma::Balancer->new(db=>$mdbh,debug=>1,validate=>1);
  my $chadoxml_string=$pro->process(%ph);

=head1 DESCRIPTION

FlyBase::Proforma::Balancer is a perl module for parsing FlyBase
publication proforma and write the result as chadoxml. it is required
to connected to a chado database for validating and processing.
The module also requires FlyBase::Proforma::Writechado and
FlyBase::Proforma::Util. The results can be loaded into a chado
database by XML::Xort.

=head2 EXPORT

  process
  validate

=cut

our %ti_fpr_type = (
    'AB1a',  'symbol',          'AB1b',  'symbol',
    'AB1e',  'symbol',          'AB1f',  'merge',
    'AB1g',  'new',             'AB2a',  'fullname',
    'AB2b',  'fullname',        'AB2c',  'fullname',
    'AB11a', 'is_obsolete',     'AB11b', 'dissociate_pub',
    'AB10',  'nickname',        'AB8',   'balancer_status',
    'AB3',   'discoverer',      'AB9',   'progenitor',
    'AB5a',  'associated_with', 'AB5b',  'carried_on',
    'AB6',   'misc',            'AB7',   'internal_notes',
    'aberr', 'variant_of'
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

=head1 METHODS

=head2 $pro->process(%ph)
	
	Process each element in the hash table and returns a string of chadoxml.
	if there is a Aberration Proforma under which the Genotype Variant
	Proforma hangs, make feature_relationship variant_of object_id FBab

=cut

#if AB5a is new symbol, will create feature_synonym,
#feature_relationship with tp...
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
        $self->validate_ti($tihash);
    }
     if(exists($fbids{$ph{AB1a}})){
        $unique=$fbids{$ph{AB1a}};
    }
    else{
        ($out,$unique)=$self->write_feature($tihash);
    }
     if(exists($fbcheck{$ph{AB1a}}{$ph{pub}})){
        print STDERR "Warning: $ph{AB1a} $ph{pub} exists in a previous proforma\n";
    }
    $fbcheck{$ph{AB1a}}{$ph{pub}}=1;
    
   if(!exists($ph{AB11b})){
      print STDERR "Action Items: balancer $unique == $ph{AB1a} with pub $ph{pub}\n"; 
        my $f_p = create_ch_feature_pub(
        doc        => $doc,
        feature_id => $unique,
        pub_id     => $ph{pub}
    );
    $out .= dom_toString($f_p);
    $f_p->dispose();
   } else {
            print STDERR "Action Items: dissociate $unique == $ph{AB1a} with $ph{pub}\n";
            $out .= dissociate_with_pub( $self->{db}, $unique, $ph{pub} );
        return $out;
    }
    ##Process other field in Trangenic Insertion proforma
    foreach my $f ( keys %ph ) {
        #print STDERR  $f, "\n";
        
              if ( $f eq 'AB1b' || $f eq 'AB2b' || $f eq 'AB10' ) {
      if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
          print STDERR "Action Items: !c log,$ph{AB1a} $f  $ph{pub}\n";
            $out .=
                      delete_feature_synonym( $self->{db}, $doc, $unique, $ph{pub} , $ti_fpr_type{$f});
            
            }
        if(defined($ph{$f}) && $ph{$f} ne ''){
            my @items = split( /\n/, $ph{$f} );
            foreach my $item (@items) {
                $item =~ s/^\s+//;
                $item =~ s/\s+$//;
                 my $t = $f;
            $t =~ s/^AB\d//;
                if ( $item ne 'unnamed' && $item ne '' ) {
                    if ( ( $f eq 'AB1b' ) && ( $item eq $ph{AB1a} ) ) {
                        $t = 'a';
                    }
                    elsif (( $f eq 'AB2b' )
                        && exists( $ph{AB2a} )
                        && ( $item eq $ph{AB2a} ) )
                    {
                        $t = 'a';
                    }
                    elsif ( !exists( $ph{AB2a} ) && $f eq 'AB2b' ) {
                        $t =
                          check_feature_synonym_is_current( $self->{db},
                            $unique, $item, 'fullname' );
                    }
                    elsif($f eq 'AB10'){
                        $t ='a';
                    }
                    $out .=
                      write_feature_synonyms( $doc, $unique, $item, $t,
                        $ph{pub}, $ti_fpr_type{$f} );
                }
            }
        }
        }
	      elsif($f eq 'AB2a' && $ph{$f} ne ''){
	  if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
	    print STDERR "ERROR: AB2a can not accept !c\n";
	  }
	  my $num = check_feature_synonym( $self->{db},
                            $unique,  'fullname' );
	  if( $num != 0){
	    if ((defined($ph{AB2c}) && $ph{AB2c} eq '' && !defined($ph{AB1f})) || (!defined($ph{AB2c}) && !defined($ph{AB1f}) )) {
	      print STDERR "ERROR: AB2a must have AB2c filled in unless a merge\n";
	    }
	    else{
	      $out.=write_feature_synonyms($doc,$unique,$ph{$f},'a','unattributed',$ti_fpr_type{$f});
	    }
	  }
	  else{
	    $out.=write_feature_synonyms($doc,$unique,$ph{$f},'a','unattributed',$ti_fpr_type{$f});
	  }
#Was just this but assume need same checks as Gene
#		 	$out.=write_feature_synonyms($doc,$unique,$ph{$f},'a','unattributed',$ti_fpr_type{$f});
	  }
        elsif($f eq 'AB1e' || $f eq 'AB2c'){
             $out .=
              update_feature_synonym( $self->{db}, $doc, $unique, $ph{$f},
                $ti_fpr_type{$f} );
        }

        elsif ( $f eq 'AB1f' ) {
            $out .= merge_records( $self->{db}, $unique, $ph{$f},$ph{AB1a}, $ph{pub}, $ph{AB2a} );
            if(exists($ph{AB2a})){
            	$out.=write_feature_synonyms($doc,$unique,$ph{AB2a},'a','unattributed',$ti_fpr_type{AB2a});
            	}
        }
        elsif ( $f eq 'AB9' || $f eq 'AB5a' || $f eq 'aberr' || $f eq 'AB5b' ) {
            my $object  = 'object_id';
            my $subject = 'subject_id';
            if ( $f eq 'AB5b' ) {
                $object  = 'subject_id';
                $subject = 'object_id';
            }
            if ( exists( $ph{"$f.upd"} ) and $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{AB1a} $f  $ph{pub}\n";
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
                        print STDERR "ERROR: something Wrong, please validate first\n";
                    }
                }
            }
            if (defined($ph{$f}) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
						  print STDERR "AB5a $item ;\n";
						  print STDERR $fbids{$item}, "\n";
						  if($item ne 'P{UAS-mCD8.mRFP}2'){
						    print STDERR "Not equal \n $item \n P{UAS-mCD8.mRFP}2\n"; 
						  }
                    my ($fr, $f_p)=
                      write_feature_relationship( $self->{db}, $doc, $subject,
                        $object, $unique, $item, $ti_fpr_type{$f}, $ph{pub} );
                    $out.=dom_toString($fr);
                    $out.=$f_p;
                                }
            }
        }
        elsif ( $f eq 'AB8' || $f eq 'AB3' || $f eq 'AB6' || $f eq 'AB7' ) {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$ph{AB1a} $f  $ph{pub}\n";
                my @results =
                  get_unique_key_for_featureprop( $self->{db}, $unique,
                    $ti_fpr_type{$f}, $ph{pub} );
					   
                foreach my $t (@results) {
                    my $num = get_fprop_pub_nums( $self->{db}, $t->{fp_id} );
					#	  print STDERR "num of fprop=$num\n";
                    if ( $num == 1 || (defined($frnum{$unique}{$ti_fpr_type{$f}}{$t->{rank}}) && $num-$frnum{$unique}{$ti_fpr_type{$f}}{$t->{rank}}==1)) {
                        $out .=
                          delete_featureprop( $doc, $t->{rank}, $unique,
                            $ti_fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_featureprop_pub( $doc, $t->{rank}, $unique,
                            $ti_fpr_type{$f}, $ph{pub} );
                    }
                    else {
                        print STDERR "ERROR: something Wrong, please validate first\n";
                    }
                }
            }
            if ( defined($ph{$f}) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
						  if($f eq 'AB8' && $item eq 'y'){
						   $item='true';
						  }
                    $out .=
                      write_featureprop( $self->{db}, $doc, $unique, $item,
                        $ti_fpr_type{$f}, $ph{pub} );
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
    
    
      if(exists($ph{AB1f})){
	if ($ph{AB1g} eq 'n' ) {
	    print STDERR "Balancer Merge  AB1g = n check: does AB1a $ph{AB1a} exist\n";
	    my $va = validate_new_name($db, $ph{AB1a});
	    if($va == 1){
	    print STDERR "ERROR: Balancer Merge  AB1g = n and AB1a $ph{AB1a} exists\n";
		exit(0);
	    }
	}

          ( $unique, $flag ) = get_tempid( 'ba', $ph{AB1a} );
          my $tmp=$ph{AB1f};
          $tmp=~s/\n/ /g;
        print STDERR "Action Items: balancer merge $tmp", $ph{AB1a},"\n";
        if ( $ph{AB1a} =~ /^(.{4})\\(.*)/ ) {
            ( $genus, $species ) = get_organism_by_abbrev( $self->{db}, $1 );
        }
        if($genus eq '0'){
            $genus='Drosophila';
            $species='melanogaster';
        }
        if($flag ==1){
            print STDERR "ERROR: could not assign temp id for $ph{AB1a}\n";
            exit(0);
        }
        else{
             $feature = create_ch_feature(
                uniquename => $unique,
                name       => decon( convers( $ph{AB1a} ) ),
                genus      => $genus,
                species    => $species,
                type_id       => create_ch_cvterm(doc=>$doc, cv=> 'SO',
                                                  name => 'chromosome_structure_variation'),
                doc        => $doc,
                macro_id   => $unique,
                no_lookup  => '1'
            );
            $out.=dom_toString($feature);
             $out .=
              write_feature_synonyms( $doc, $unique, $ph{AB1a}, 'a',
                'unattributed', 'symbol' );
        }
   }
   else{
   if ( $ph{AB1g} eq 'y' ) {
        ( $unique, $genus, $species, $type ) =
          get_feat_ukeys_by_name( $self->{db}, $ph{AB1a} );
       if($unique eq '0' or $unique eq '2'){
          print STDERR "ERROR: could not find $ph{AB1a} in the database\n"; 
       }
          else{
            if (exists($ph{AB1h})){
             if($ph{AB1h} ne $unique){
                print STDERR "ERROR: AB1h and AB1a not match\n";
             }
        }
        $feature = &create_ch_feature(
            doc        => $doc,
            uniquename => $unique,
            species    => $species,
            genus      => $genus,
            type_id       => create_ch_cvterm(
                doc  => $doc,
                cv   => 'SO',
                name => 'chromosome_structure_variation'
            ),
            macro_id   => $unique,
            no_lookup  => 1
        );
        if ( exists( $ph{AB11a} ) && $ph{AB11a} eq 'y' ) {
            print STDERR "Action Items: delete balancer $ph{AB1a}\n";
            my $op = create_doc_element( $doc, 'is_obsolete', 't' );
            $feature->appendChild($op);
        }
         if(exists($fbids{$ph{AB1a}})){
            my $check=$fbids{$ph{AB1a}};
            if($unique ne $check){
                print STDERR "ERROR: $check and $unique are not same for $ph{G1a}\n"; 
                   
            }
        }
        $out.=dom_toString($feature);
        $fbids{$ph{AB1a}}=$unique;
    }
    }
    else {
     my $va=validate_new_name($db, $ph{AB1a});
     if(exists($ph{AB1e})){
	 if(exists($fbids{$ph{AB1e}})){
	     print STDERR "ERROR: Rename AB1e $ph{AB1e} exists in a previous proforma\n";
	 }
	 if(exists($fbids{$ph{AB1a}})){                                    
	     print STDERR "ERROR: Rename AB1a $ph{AB1a} exists in a previous proforma \n";
	 }  
	 print STDERR "Action Items: balancer rename $ph{AB1e} to $ph{AB1a}\n";
            ( $unique, $genus, $species, $type ) =
          get_feat_ukeys_by_name( $self->{db}, $ph{AB1e} );
              $feature = create_ch_feature(
                uniquename => $unique,
                name       => decon( convers( $ph{AB1a} ) ),
                genus      => $genus,
                species    => $species,
                type_id       => create_ch_cvterm(
                doc  => $doc,
                cv   => 'SO',
                name => 'chromosome_structure_variation',
                no_lookup => 1
                
            ),,
                doc        => $doc,
                macro_id   => $unique,
                no_lookup  => '1'
            );
              $fbids{$ph{AB1a}}=$unique;
            $fbids{$ph{AB1e}}=$unique;
            $out.=dom_toString($feature);
             $out .=
              write_feature_synonyms( $doc, $unique, $ph{AB1a}, 'a',
                'unattributed', 'symbol' );
        }
        
        else{
        ### if the temp id has been used before, $flag will be 1 to avoid
        ### the DB Trigger reassign a new id to the same symbol.
        if($va==1){
            $flag=0;
            ($unique,$genus,$species,$type)=get_feat_ukeys_by_name($db,$ph{AB1a});
             $fbids{$ph{AB1a}}=$unique;
        }
        else{
            print STDERR "Action Items: new balancer $ph{AB1a}\n";
        ( $unique, $flag ) = get_tempid( 'ba', $ph{AB1a} );

        if ( $ph{AB1a} =~ /^(.{4})\\(.*)$/ ) {

            ( $genus, $species ) = get_organism_by_abbrev( $self->{db}, $1 );
        }
        else {
            $genus   = 'Drosophila';
            $species = 'melanogaster';
        }
        }
        if ( $flag == 0 ) {
            $feature = &create_ch_feature(
                uniquename => $unique,
                name       => decon(convers($ph{AB1a})),
                genus      => $genus,
                species    => $species,
                type_id    => create_ch_cvterm(
                doc  => $doc,
                cv   => 'SO',
                name => 'chromosome_structure_variation'
            ),
                doc        => $doc,
                macro_id   => $unique,
                no_lookup  => '1'
            );
       
            $out.=dom_toString($feature);
       
         $out .=
              write_feature_synonyms( $doc, $unique, $ph{AB1a}, 'a',
                'unattributed', 'symbol' );
        }
        else{
            print STDERR "ERROR, name $ph{AB1a} has been used in this load\n";
               }
    }
    }
   }
    $doc->dispose();
    return ($out,$unique);
}
=head2 $pro->validate(%ph)

   validate the following:
   1. if AB8 is 'y', check whether AB1a is a valid feature.name in the
	   DB. if AB8 is 'n', check whether AB1a is already in the DB.
	2. validate AB5a, AB5b, AB9, the values following those fields have
	   to be a valid symbol in the database.
	3. if !c exists, check whether this record already in the DB.
	4. if AB1a like '*\*', the organism is the value before '\', check
	   the abbreviation.
	5. if AB5a transposon insertion is new, return error if
	   transgenic_construct is not in the DB or this file. 
=cut

sub validate {
    my $self   = shift;
    my $tihash = {@_};
    my %tival  = %$tihash;

    my $v_unique = '';

    print STDERR "Validating Balancer ", $tival{AB1a}, " ....\n";

    if ( !exists( $tival{aberr} ) ) {
        print STDERR "ERROR:balance did not follow an Aberration\n";
    }
    if(exists($fbids{$tival{AB1a}})){
        $v_unique=$fbids{$tival{AB1a}};
    }
    else{
        print STDERR "ERROR: did not have the first parse\n";
    }
    foreach my $f ( keys %tival ) {
        if ( $f =~ /(.*)\.upd/ && !($v_unique =~/FBba:temp/)) {
             $f = $1;
             if ( $f eq 'AB3' || $f eq 'AB6' || $f eq 'AB7' ) {
                my $num =
                      get_unique_key_for_featureprop( $db, $v_unique,
                        $ti_fpr_type{$f}, $tival{pub} );
                if ( $num == 0 ) {
                        print STDERR
                          "ERROR: there is no previous record for $f field.\n";
                    }
             }
            elsif ( $f eq 'AB5a' || $f eq 'AB5b' || $f eq 'AB9' ) {
                 my $subject='subject_id';
 		my $object='object_id';
                if($f eq 'AB5b'){
                    $subject='object_id';
                    $object='subject_id';
                }
                    my $num =
                      get_unique_key_for_fr( $db,$subject,$object, $v_unique, $ti_fpr_type{$f},
                        $tival{pub} );
                    if ( $num == 0 ) {
                        print STDERR
                          "ERROR: There is no previous record for $f field\n";
                    }
                }
        }
       elsif ( $f =~ /(.*)\.upd/ ) {
                print STDERR "ERROR: !c fields  $1 for a new record \n";
       }
       elsif( $f eq 'AB9' || $f eq 'AB5b'||  $f eq 'AB5a'){
          if(defined($tival{$f}) && $tival{$f} ne ''){
           my @items=split(/\n/,$tival{$f});
           foreach my $item (@items) {
                $item =~ s/^\s+//;
                $item =~ s/\s+$//;
                if(!exists($fbids{$item})){
                    my ( $uuu, $g, $s, $t ) =
                      get_feat_ukeys_by_name( $db, $item );
                    if ( $uuu eq '0' || $uuu eq '2' ) {
                        print STDERR
                          "ERROR: Could not find feature $item in the database\n";
                    }
                }
            }
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


=head1 NAME

FlyBase::Proforma::TI - Perl module for parsing the FlyBase transgenic insertion proforma

=head1 SYNOPSIS

  use FlyBase::Proforma::TI;
  

=head1 DESCRIPTION

Stub documentation for FlyBase::Proforma::TI, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

  process_ti


=head1 SUPPORT

proformas can be found in http://flystocks.bio.indiana.edu/flybase/curation-docs/genetic-literature/

proforma mapping table can be found in ~haiyan/Documents/balancermapping.sxw 

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

! GENOTYPE VARIANT PROFORMA                 Version 17: 5 December 2006
!
! AB1a.  Genotype variant symbol to use in database              *I :
! AB1b.  Genotype variant symbol used in paper                   *i :
! AB1e.  Action - rename this genotype variant symbol               :
! AB1f.  Action - merge genotype variants                           :
! AB1g.  Is AB1a the valid symbol of a genotype variant in FlyBase? :y
! AB2a.  Genotype variant name to use in database                *e :
! AB2b.  Genotype variant name used in paper                     *Q :
! AB2c.  Database genotype variant name(s) to replace            *Q :
! AB11a. Action - delete genotype variant   - TAKE CARE :
! AB11b. Action - dissociate AB1a from FBrf - TAKE CARE :
! AB10.  Nickname                                            *U :
! AB8.   Is AB1a used/usable as a balancer?                  *u :y
! AB3.   Culprit                *w :
! AB9.   Progenitor chromosome  *u :
! AB5a.  Transposon insertions  *P :
! AB5b.  Non-insert alleles     *S :
! AB6.   Comments               *u :
! AB7.   Internal notes         *K :
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

=head1 AUTHOR

Haiyan Zhang, E<lt>haiyan@morgan.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
