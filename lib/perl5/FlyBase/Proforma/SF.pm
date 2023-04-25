package FlyBase::Proforma::SF;

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

# This allows declaration	use FlyBase::Proforma::SF ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = (
    'all' => [
        qw(

          )
    ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( process_sf validate_sf

);

our $VERSION = '0.01';

# Preloaded methods go here.
=head1 NAME

FlyBase::Proforma::SF - Perl module for parsing the FlyBase
Sequence Feature  proforma version 1.2, March, 2008.

See the bottom for the proforma
                         
=head1 SYNOPSIS

  use FlyBase::Proforma::SF;
  use DBI;
  
  my $mdbh=DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";
  my %ph=(SF1a=>'TM9',....);
  ###!c field implemented as '$fieldname.upd=>'c'' eg. 'SF16.upd'=>'c'
   
  #params db is manditory, debug and validate is optional
  my $pro=FlyBase::proforma::SF->new(db=>$mdbh);
  $pro->validate(%ph);
  my $chadoxml = $pro->process(%ph);
  
  # or

  my $pro=FlyBase::Proforma::SF->new(db=>$mdbh,debug=>1,validate=>1);
  my $chadoxml_string=$pro->process(%ph);

=head1 DESCRIPTION

FlyBase::Proforma::SF is a perl module for parsing FlyBase
Sequence Feature proforma and write the result as chadoxml. It is required
to connected to a chado database for validating and processing.
See Proforma for the proforma template.

The module also requires FlyBase::Proforma::Writechado and
FlyBase::Proforma::Util. The results can be loaded into a chado
database by XML::Xort.

=head2 EXPORT

  process
  validate

=cut
our %pm = ( 'p', '+', '+', '+', 'm', '-', '-', '-' );

our %sftype = (
    'satellite_DNA', 'sf',
    'repeat_region', 'sf',
    'polyA_site', 'sf',
    'enhancer', 'sf',
    'protein_binding_site', 'sf',
#    'rescue_fragment', 'sf',
    'TSS', 'sf',
    'origin_of_replication', 'sf',
    'RNAi_reagent','sf',
#    'oligonucleotide mapping set', 'sf',
#    'predicted amplicon','sf',
    'insulator','sf',
    'region','sf',
    'regulatory_region','sf',
    'silencer', 'sf',
    'TF_binding_site','sf',
    'exon_junction', 'sf',
    'modified_RNA_base_feature' , 'sf',
    'experimental_result_region' , 'sf',
#    'CDS', 'sf',
    'sgRNA', 'sf',
    'polypeptide_region', 'sf',
);

our %feat_type = (
    'SF5c',   'transgenic_transposable_element',
    'SF5a',  'gene',
    'SF5b', 'allele',
    'SF5d', '',
    'SF5h', 'engineered_plasmid',
    'SF3a',  'library',
    'SF4d',   'so',
    'SF22a', 'cell_line',
    'SF11a', 'polypeptide',
);
our %ftype=(
    'SF5c', 'tp',
    'SF5b', 'al',
    'SF5a', 'gn',
    'SF5h', 'mc',
);
our %fpr_type = (
    'SF2a', 'SO',
    'SF4d',  'associated_with',
    'SF5d', 'associated_with',
    'SF5c',   'associated_with',
    'SF5b',  'associated_with',
    'SF5a',  'associated_with',
    'SF5h',  'associated_with',
    'SF5e',  'score',
    'SF5f',  'comment',
    'SF1b',   'symbol',
    'SF4a',  'featureloc',
    'SF4b',  'featureloc',
    'SF4h',  'featureloc',
    'SF4e',   'start_location',
    'SF4f',   'end_location',
    'SF4c',  'gen_loc_comment',
    'SF4g',  'residues',
    'SF3a',   'library_feature',
    'SF20a', 'PCR_template',
    'SF20b', 'primer_progenitor_of',                    #primer seq
    'SF20c', 'primer_progenitor_of',             ##primer seq
    'SF20d', 'primer_comment',                          #primer
    'SF6',   'comment',
    'SF7',  'availability',
    'SF8',  'internalnotes',
    'SF22a', 'cell_line_feature',
    'SF22b', '',
    'SF22c', '',
    'SF22g', '',
    'SF21a', 'feature_genotype',
    'SF21c', 'phenstatement',
    'SF21b', 'phenstetement',
    'SF21d', 'phendesc',
    'SF10a', 'evidence',  ##featureprop -- GenBank feature qualifier 
    'SF11a', 'bound_moiety', ####feature_relationship.object_id = -XP must exist
    'SF11b', 'bound_moiety', ###featureprop -- GenBank feature qualifier
    'SF11c', 'bound_moiety_comment', #featureprop --property type
    'SF12',  'linked_to'   ###  featureprop -- GenBank feature qualifier
);

my %sf3c_type = ('experimental_result',1, 'member_of_reagent_collection',1 );

our %ti_type = (
    'RNAi_reagent',          'RNAi_reagent'
);
our %appendix=('SF20b','1','SF20c','2');
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
    my $type    = '';
    my $out     = '';

    print STDERR "processing Sequence Feature ", $ph{SF1a}, "...\n";
    if ( exists( $self->{debug} ) && $self->{debug} == 1 ) {
        foreach my $key ( keys %ph ) {
            print STDERR "$key, $ph{$key}\n";
        }
    }

    if ( exists( $self->{v} ) && $self->{v} == 1 ) {
        $self->validate($tihash);
    }
     if(exists($fbids{$ph{SF1a}})){
        $unique=$fbids{$ph{SF1a}};
    }
    else{
        ($unique, $out)=$self->write_feature($tihash);
    }
    if(exists($fbcheck{$ph{SF1a}}{$ph{pub}})){
        print STDERR "Warning: $ph{SF1a} $ph{pub} exists in a previous proforma\n";
    }
    $fbcheck{$ph{SF1a}}{$ph{pub}}=1;
    #print "$unique\n";
    if(!exists($ph{SF1i})){
      print STDERR "Action Items: SF $unique == $ph{SF1a} with pub $ph{pub}\n"; 
      my $fpub = create_ch_feature_pub(
        doc        => $doc,
        feature_id => $unique,
        pub_id     => $ph{pub}
    );
    $out .= dom_toString($fpub);
    $fpub->dispose();
    }
    else{
          print STDERR "Action items: dissociate $ph{SF1a} with pub $ph{pub} \n";
          $out .= dissociate_with_pub( $self->{db}, $unique, $ph{pub} );
          return $out;
    }
    ##Process other field in Trangenic Insertion proforma
    foreach my $f ( keys %ph ) {
         #print STDERR "$f\n";
        if ( $f eq 'SF1b'  ) {
           
            my @items = split( /\n/, $ph{$f} );
            foreach my $item (@items) {
                $item =~ s/^\s+//;
                $item =~ s/\s+$//;
                my $t = $f;
                $t =~ s/SF1//;
                if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                   my  $up = $ph{pub};                  
                    $out .=
                      delete_feature_synonym( $self->{db}, $doc, $unique, $up ,'symbol');
                }
                if($item eq $ph{"SF1a"}){
                   $t='a';
                }
                if($item ne '' && $item ne 'unamed'){
                  $out .=
                              write_feature_synonyms( $doc, $unique, $item, $t,
                                $ph{pub}, 'symbol' );                  
                }            
            }
        }
        elsif( $f eq 'SF1c'){
            $out .=
              update_feature_synonym( $self->{db}, $doc, $unique, $ph{$f},  'symbol' );
              $fbids{$unique}=$ph{SF1a};
        }
      
        elsif ( $f eq 'SF1g' ) {
            my $tmp=$ph{$f};
            $tmp=~s/\n/ /g;
            if($ph{SF1f} eq 'new'){
                print STDERR "Action Items: merge SF $tmp\n";
            }
            else{
                print STDERR "Action Items: merge SF $tmp to $ph{SF1f} == $ph{SF1a} \n";
            }
            
            $out .= merge_records( $self->{db}, $unique, $ph{$f}, $ph{SF1a},$ph{pub},$ph{SF1a} );
            $fbids{$unique}=$ph{SF1a};
        }
        elsif($f eq 'SF5a'){
			   print STDERR "Warning: in single field SF5a \n";

            $out.=&parse_affected_gene($unique,\%ph,$ph{pub});
        }
        elsif($f eq 'SF5'){
			  print STDERR "Warning: in multiple field SF5\n";
            ##### feature_relationship multiple affected_gene
            my @array = @{ $ph{$f} };
					print STDERR " there are $#array \n";
            foreach my $ref (@array) {
					#	 print STDERR "Warning: $ref->{SF5a}\n";
                $out .= &parse_affected_gene( $unique, $ref, $ph{pub} );
            }
        }
        elsif ($f eq 'SF5b'
            || $f eq 'SF5c'
            || $f eq 'SF5d'
            || $f eq 'SF5h'
            || $f eq 'SF11a'
          )
        {
            my $object  = 'object_id';
            my $subject = 'subject_id';
  
            if ( exists( $ph{"$f.upd"} ) and $ph{"$f.upd"} eq 'c' ) {
                  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
               
                my @results =
                  get_unique_key_for_fr( $self->{db}, $subject, $object,
                    $unique, $fpr_type{$f}, $ph{pub},$ftype{$f} );
                    foreach my $ta (@results) {
                        my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );
                        if ( $num == 1  || (defined($frnum{$unique}{$ta->{name}}) && $num-$frnum{$unique}{$ta->{name}}==1)) {
                            $out .=
                              delete_feature_relationship( $self->{db}, $doc,
                                $ta, $subject, $object, $unique,
                                $fpr_type{$f}  );
                        }
                        elsif ( $num > 1 ) {
                            $out .=
                              delete_feature_relationship_pub( $self->{db},
                                $doc, $ta, $subject, $object, $unique,
                                $fpr_type{$f}, $ph{pub});
                        }
                        else {
                            print STDERR "ERROR: $f something Wrong, please validate first\n";
                        }
                    
                }
            }
            if ( defined($ph{$f}) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
		    my ($fu, $fg, $fs, $ft) = get_feat_ukeys_by_name( $self->{db}, $item);
		    if($fu eq  '0'){
			print STDERR "ERROR: could not get uniquename for $item\n";
		    }
		    elsif($fu eq '2'){
			print STDERR "ERROR: duplicate names $item \n";
		    }
		    elsif($ft ne $feat_type{$f}){
			print STDERR "ERROR: Wrong type key:$f name:$item type: $ft ne '$feat_type{$f}' in $unique\n";
		    }
		    else{
			my ($fr,$f_p) = write_feature_relationship(
			    $self->{db},       $doc,
			    $subject,           $object,
			    $unique,           $item,
			    $fpr_type{$f},  $ph{pub},
			    $ft, $ftype{$f}
			    );
			$out .= dom_toString($fr);
			$fr->dispose();
			$out.=$f_p;
		    }
                }
            }
        }
        elsif ($f eq 'SF11b'
            || $f eq 'SF11c'
            || $f eq 'SF12'
            || $f eq 'SF7'
            || $f eq 'SF6'
            || $f eq 'SF8'
            || $f eq 'SF20d'
            || $f eq 'SF20a'
            || $f eq 'SF10a'
            || $f eq 'SF4c'
            )
        {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                 print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
		 my $cv = "property type";
		 if ( $f eq 'SF11b' || $f eq 'SF12'){
		   $cv = "GenBank feature qualifier";
		 }
                   my @results = get_unique_key_for_featureprop( $self->{db}, $unique,
                    $fpr_type{$f}, $ph{pub},$cv );
                foreach my $t (@results) {
                    my $num = get_fprop_pub_nums( $self->{db}, $t->{fp_id} );
                    if ( $num == 1  || (defined($frnum{$unique}{$fpr_type{$f}}{$t->{rank}}) && $num-$frnum{$unique}{$fpr_type{$f}}{$t->{rank}}==1)) {
                        $out .=
                          delete_featureprop( $doc, $t->{rank}, $unique,
                            $fpr_type{$f},$cv );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_featureprop_pub( $doc, $t, $unique,
                            $fpr_type{$f}, $ph{pub} );
                    }
                    else {
                        print STDERR "ERROR: something Wrong, please validate first\n";
                    }
                }
            }
            if (defined($ph{$f}) && $ph{$f} ne '' ) {
	      my $cv = "property type";
	      if ( $f eq 'SF11b' || $f eq 'SF12'){
		$cv = "GenBank feature qualifier";
	      }
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                   
                    $out .=
                      write_featureprop_cv( $self->{db}, $doc, $unique, $item,
                        $fpr_type{$f}, $ph{pub} , $cv);
                }
            }
        }

        elsif ( $f eq 'SF3a' ){               
	    print STDERR "CHECK: new implemented $f  $ph{SF1a} \n";

            if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
                print STDERR "CHECK: new implemented !c $ph{SF1a} $f \n";
            #get library_feature
		my @result =get_library_for_library_feature( $self->{db}, $unique);
                foreach my $item (@result) {          
                    (my $libu, my $libg, my $libs, my $libt)=get_lib_ukeys_by_name($self->{db},$item);
                    my $lib_feat = create_ch_library_feature(
                                   doc        => $doc,
                                   library_id => create_ch_library(doc => $doc, 
                                                                   uniquename => $libu, 
                                                                   genus => $libg, 
                                                                   species=>$libs, 
                                                                   type=>$libt,),
                                   feature_id  => $unique,
			);
                    $lib_feat->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($lib_feat);
                    $lib_feat->dispose();
                }               
            }
            if (defined ($ph{$f}) && $ph{$f} ne ""){
	      (my $libu, my $libg, my $libs, my $libt)=get_lib_ukeys_by_name($self->{db},$ph{$f});
	      if ( $libu eq '0' ) {
		print STDERR "ERROR: could not find record for $ph{SF3a}\n";
		  #		  exit(0);
	      }
	      elsif( $libg ne $genus || $libs ne $species){
		  print STDERR "ERROR: In SF3a $ph{SF3a} library genus/species $libg $libs does not match sf $genus $species\n";
		  #  exit(0);
	      }

	      else{
		print STDERR "DEBUG: SF3a $ph{$f} uniquename $libu\n";		  
		if(defined ($ph{SF3c}) && $ph{SF3c} ne ""){
		  if (exists ($sf3c_type{$ph{SF3c}} ))  {
		    my $item = $ph{SF3c};
		    print STDERR "DEBUG: SF3c $ph{SF3c} found\n";
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
		    print STDERR "ERROR: wrong term for SF3c $ph{SF3c}\n";
		  }
		}
		else{
		  print STDERR "ERROR: SF3a has a library no term for SF3c\n";
		}
		
	      }
	    }

	}
	elsif( ($f eq 'SF3c' && $ph{SF3c} ne "") && ! defined ($ph{SF3a})){
	  print STDERR "ERROR: SF3c has a term for SF3c but no library\n";
	}	    


        elsif ( $f eq 'SF4a'  ) {

            $out .= &parse_genome_location( $unique, \%ph, $ph{pub} );

        }
        elsif ( $f eq 'SF4' ) {
           print STDERR "Warning: in multiple field SF4\n";
            ##### multiple featurelocs
            my @array = @{ $ph{$f} };
            foreach my $ref (@array) {
                $out .= &parse_genome_location( $unique, $ref, $ph{pub} );
            }
        }
        elsif ( $f eq 'SFd' ) {
            print STDERR "Warning: in multiple field SF4d\n";
            ##### feature_relationship multiple flanking_regions
            my @array = @{ $ph{$f} };
            foreach my $ref (@array) {
                $out .= &parse_flanking_seq( $unique, $ref, $ph{pub} );
            }
        }
        elsif ( $f eq 'SF4d' ) {
      
            ##### feature_relationship flanking_region
            $out .= &parse_flanking_seq( $unique, \%ph, $ph{pub} );
        }
        elsif ( $f eq 'SF21' ) {
           print STDERR "CHECK: implemented field SF21\n";
            ##### feature_relationship multiple affected_gene
            my @array = @{ $ph{$f} };
            foreach my $ref (@array) {
                $out .= &parse_affected_gene( $unique, $ref, $ph{pub} );
            }
        }
        elsif( $f eq 'SF20b' || $f eq 'SF20c'){
	  if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
	    print STDERR "ERROR: has not implemented !c$f yet\n"; 
	  }
	  else{
	    my $pn=decon(convers($ph{SF1a})).'_'.$appendix{$f};
	    my $pg;
	    my $ps;
	    if(exists($ph{SF3b})){
	      ($pg,$ps)= get_organism_by_abbrev( $self->{db}, $ph{SF3b} );
	    }
	    elsif($ph{SF1f} ne 'new'){
	      ($pg,$ps)=get_feat_ukeys_by_uname($self->{db},$ph{SF1f});
	    }
	    else {
	      print STDERR "Warning: set Dmel as default organism_id for primers $f\n";
	      $pg='Drosophila';
	      $ps='melanogaster';
	    }
	    my $pt='oligo';
	    my $pr=$ph{$f};
	    $pr=~s/\s+//g;
	    my $pfeature=create_ch_feature(doc=>$doc, uniquename=>$pn, name=>$pn,genus=>$pg,
                             species=>$ps,type=>$pt, residues=>$pr, seqlen=>length($pr), no_lookup=>1, macro_id=>$pn);
	    my $pfr=create_ch_fr(doc=>$doc, subject_id=>$pn,
					object_id=>$unique,  rtype=>'primer_progenitor_of',
					rank=>$appendix{$f});
	    my $pfr_p=create_ch_fr_pub(doc=>$doc, pub_id=>$ph{pub});
	    $pfr->appendChild($pfr_p);
	    $out.=dom_toString($pfeature);
	    $out.=dom_toString($pfr);
	  }
        }
        elsif ( $f eq 'SF21a' ) {
            print STDERR "ERROR: field $f not implemented yet\n";
            #$out .= &parse_affected_gene( $unique, \%ph, $ph{pub} );
        }
        elsif($f eq 'SF22'){
            print STDERR "ERROR: field $f not implemented yet\n";
        
        }
        elsif($f eq 'SF22a'){
            print STDERR "ERROR: field $f not implemented yet\n";
        }
        elsif ( $f eq 'SF2a' ) {
            if ( exists( $ph{'SF2a.upd'} ) && $ph{'SF2a.upd'} eq 'c' ) {
              print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                my @result =
                  get_cvterm_for_feature_cvterm( $self->{db}, $unique,
                    'SO', 'unattributed' );

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
                        pub => 'unattributed'
                    );

                    $feat_cvterm->setAttribute( 'op', 'delete' );
                    $out .= dom_toString($feat_cvterm);
                    $feat_cvterm->dispose();
                }
            }
            if ( $ph{$f} ne '' ) {
                my $f_cvterm = &create_ch_feature_cvterm(
                    doc        => $doc,
                    feature_id => $unique,
                    cvterm_id  => create_ch_cvterm(
                        doc  => $doc,
                        cv   => 'SO',
                        name => $ph{$f}
                    ),
                    pub_id => 'unattributed'
                );

                $out .= dom_toString($f_cvterm);
                $f_cvterm->dispose();
            }
        }

    }
  $doc->dispose();
    return $out;
}

sub parse_genome_location {
    my $fbti    = shift;
    my $hashref = shift;       ##reference to hash
    my $pub_id  = shift;
    my %gen_loc = %$hashref;
    my $srcfeat = '';
    my $featureloc;
    my $locgroup;
    my $out     = '';
    my $strand = '';
    my $genus   = 'Drosophila';
    my $species = 'melanogaster';
    
    if (exists($gen_loc{'SF4a.upd'}) && $gen_loc{'SF4a.upd'} eq 'c' ) {
      print STDERR "Action Items: !c log, $fbti SF4a $pub_id\n";
        $out .= delete_featureloc( $db, $doc, $fbti, $pub_id );
    }
    if ( defined( $gen_loc{SF4a} ) && $gen_loc{SF4a} ne '' ) {
        my $fmin;
        my $fmax;
	my $cstrand;
        my ( $arm,  $location ) = split( /:/,    $gen_loc{SF4a} );
        if(defined($location)){
         ( $fmin, $fmax )     = split( /\.\./, $location );
        if(!defined($fmax) && defined($fmin)){
            $fmax=$fmin;
        }
	 if(exists($gen_loc{SF4h})){
	   if($pm{$gen_loc{SF4h}} eq '+'){
	     $cstrand=1;
	   }
	   elsif($pm{$gen_loc{SF4h}} eq '-'){
	     $cstrand=-1;
	   }
	 }
       }
	else{
            print STDERR "ERROR: Something wrong with SF4a $gen_loc{SF4a} please fix \n";
	}

        if($arm eq '1'){
            $arm='X';
          }
           $srcfeat=$arm; 
        if ( $gen_loc{SF4b} ) {
            if ( $gen_loc{SF4b} eq '4' ) {
                $srcfeat = $arm . '_r4';
                print STDERR "ERROR WARN: SF4b Release 4 will not be reported\n";
            }
            elsif($gen_loc{SF4b} eq '3'){
                $srcfeat=$arm.'_r3';
                print STDERR "ERROR WARN: SF4b Release 3 will not be reported\n";
            }
	    elsif($gen_loc{SF4b} eq '5'){
                $srcfeat=$arm.'_r5';
                print STDERR "ERROR WARN: SF4b Release 5 will not be reported\n";
            }
        }
	my $type='golden_path';
	# if($srcfeat eq 'mitochondrion_genome'){
	#   $type='chromosome'; 
	# }
	if ( exists ($gen_loc{SF4b}) && $gen_loc{SF4b} eq '6' ) {
	
	    my $src = &create_ch_feature(
		doc        => $doc,
		genus      => $genus,
		species    => $species,
		uniquename => $arm,
		type       => $type
		);


	    if(defined($fmin) && defined($fmax)){

	    # see Jira DB-151       
#        if($fmin !=$fmax){
		$fmin-=1;
#        }
		$locgroup = &get_max_locgroup($db, $fbti,$arm,$fmin, $fmax);
		$featureloc = create_ch_featureloc(
		    doc           => $doc,
		    feature_id    => $fbti,
		    srcfeature_id => $src,
		    fmin          => $fmin,
		    fmax          => $fmax,
		    strand        => $cstrand,
		    locgroup      => $locgroup,
		    );
	    }
	    else{
		my $locgroup = &get_max_locgroup($db, $fbti,$arm);
		$featureloc = create_ch_featureloc(
		    doc           => $doc,
		    feature_id    => $fbti,
		    srcfeature_id => $src,
		    locgroup      => $locgroup,
		    );
	    }
	    my $fl_pub =
		create_ch_featureloc_pub( doc => $doc, pub_id => $pub_id );
	    $featureloc->appendChild($fl_pub);
	    $out .= dom_toString($featureloc);
	    $featureloc->dispose();
	}
        if (!($srcfeat=~/.*_r?/)){
           if(exists( $gen_loc{SF4b})){
            $srcfeat.="_r".$gen_loc{SF4b};
           }
           else{
            $srcfeat.='_r6';
           }    
        }     
        my $value=$srcfeat.":".$fmin.'..'.$fmax.$strand;
        my $rank=get_max_featureprop_rank($db,$fbti,'reported_genomic_loc',$value);
        my $fp=create_ch_featureprop(doc=>$doc,feature_id=>$fbti, rank=>$rank, 
                                     cvname=>'GenBank feature qualifier', type=>'reported_genomic_loc',value=>$value);
        my $fpp=create_ch_featureprop_pub(doc=>$doc, pub_id=>$pub_id);
        $fp->appendChild($fpp);
        $out.=dom_toString($fp);
    }
    return $out;
}

sub parse_flanking_seq {
    my $fbti     = shift;
    my $flankref = shift;        ##reference to hash
    my $pub_id   = shift;
    my $out      = '';
    my %flanking = %$flankref;
    my $feature;
    if ( exists( $flanking{'SF4d.upd'} ) && $flanking{'SF4d.upd'} eq 'c' ) {
      print STDERR "Action Items: !c log, $fbti SF4d $pub_id\n";
        my @results =
          get_unique_key_for_fr( $db, 'subject_id', 'object_id', $fbti,
            $fpr_type{SF4d}, $pub_id );
        foreach my $ta (@results) {
            my $num = get_fr_pub_nums( $db, $ta->{fr_id} );
            if ( $num == 1 ) {
                $out .=
                  delete_feature_relationship( $db, $doc, $ta, 'subject_id',
                    'object_id', $fbti, $fpr_type{SF4d} );
            }
            elsif ( $num > 1 ) {
                $out .=
                  delete_feature_relationship_pub( $db, $doc, $ta, 'subject_id',
                    'object_id', $fbti, $fpr_type{SF4d}, $pub_id );
            }
            else {
                print STDERR "ERROR:  something Wrong, please validate first\n";
            }
        }
    }
     if(defined($flanking{SF4d}) && $flanking{SF4d} ne ''){
     my $gbid = $flanking{SF4d};
   
    my ( $genus, $species, $type ) = get_feat_ukeys_by_uname( $db, $gbid );
    if ( $genus eq '0' || $genus eq '2' ) {
        print STDERR "$gbid record not found\n";
        $type    = $feat_type{SF4d};
        $genus   = 'Computational';
        $species = 'result';
        $feature = create_ch_feature(
            doc        => $doc,
            uniquename => $gbid,
            type       => $type,
            genus      => $genus,
            species    => $species,
            name       => $gbid,
            no_lookup  => 1,
            macro_id   => $gbid
        );
    }
    else {
        $feature = create_ch_feature(
            doc        => $doc,
            uniquename => $gbid,
            type       => $type,
            genus      => $genus,
            species    => $species,
    #        name       => $gbid,
            macro_id   => $gbid
        );
    }

    my $fr = create_ch_fr(
        doc        => $doc,
        subject_id => $fbti,
        object_id  => $feature,
        rtype      => $fpr_type{SF4d}
    );

    my $frp = create_ch_fr_pub( doc => $doc, pub_id => $pub_id );
    $fr->appendChild($frp);

    if ( exists( $flanking{SF4e} ) ) {
        my $rank=get_frprop_rank($db,'subject_id','object_id',$fbti,$gbid,$fpr_type{SF4e}, $flanking{SF4e});
      my $fro=create_ch_frprop(doc=>$doc, value=>$flanking{SF4e}, type=>$fpr_type{SF4e}, rank=>$rank);
        my $frpp=create_ch_frprop_pub(doc=>$doc, pub_id=>$pub_id);
        $fro->appendChild($frpp);
        $fr->appendChild($fro);
    }
    if ( exists( $flanking{SF4f} ) ) {
        my $rank=get_frprop_rank($db,'subject_id','object_id',$fbti,$gbid,$fpr_type{SF4e}, $flanking{SF4e});
        my $fro=create_ch_frprop(doc=>$doc, value=>$flanking{SF4f}, type=>$fpr_type{SF4f}, rank=>$rank);
        my $frpp=create_ch_frprop_pub(doc=>$doc, pub_id=>$pub_id);
        $fro->appendChild($frpp);
        $fr->appendChild($fro);
    }
        $out = dom_toString($fr);
    $fr->dispose();
}
    return $out;
}

sub parse_affected_gene {
    my $unique  = shift;
    my $generef = shift;
    my $pub     = shift;
    my %affgene = %$generef;
    my $gene    = '';
    my $genus   = '';
    my $species = '';
    my $out     = '';
    

    if ( defined($affgene{"SF5a.upd"}) && $affgene{'SF5a.upd'} eq 'c' ) {
      print STDERR "Action Items: !c log, $unique SF5a $pub\n";
           my @results =
          get_unique_key_for_fr( $db, 'subject_id', 'object_id', $unique,
            $fpr_type{SF5a},$pub, $ftype{SF5a});
        foreach my $ta (@results) {
            
            my $num = get_fr_pub_nums( $db, $ta->{fr_id} );
            if ( $num == 1 || (defined($frnum{$unique}{$ta->{name}}) && $num-$frnum{$unique}{$ta->{name}}==1) ) {
                $out .=
                  delete_feature_relationship( $db, $doc, $ta, 'subject_id',
                    'object_id', $unique, $fpr_type{SF5a} );
                   
            }
            elsif ( $num > 1 ) {
                $out .=
                  delete_feature_relationship_pub( $db, $doc, $ta, 'subject_id',
                    'object_id', $unique, $fpr_type{SF5a}, $pub );
            }
            else {
                print STDERR "ERROR:  something Wrong, please validate first\n";
            }
        }   
    }
    my $fr='';
    if(defined($affgene{SF5a}) && $affgene{SF5a} ne ''){
    
    if ( $affgene{SF5a} =~ /FBgn/ ) {
        $gene = $affgene{SF5a};
        ( $genus, $species ) =
          get_feat_ukeys_by_uname_type( $db, $affgene{SF5a}, $feat_type{SF5a} );
    }
    else {
        ( $gene, $genus, $species ) =
          get_feat_ukeys_by_name_type( $db, $affgene{SF5a}, $feat_type{SF5a} );
    }
    if(($genus eq '0' && $species eq '2')){
	print STDERR "ERROR: Could not get feature for $affgene{SF5a}, $feat_type{SF5a}\n";
    }
    my $feature = create_ch_feature(
        doc        => $doc,
        uniquename => $gene,
        type       => 'gene',
        genus      => $genus,
        species    => $species
    );

     $fr = create_ch_fr(
        doc        => $doc,
        subject_id => $unique,
        object_id  => $feature,
        rtype      => $fpr_type{SF5a}
    );
    my $frp = create_ch_fr_pub( doc => $doc, pub_id => $pub );
    $fr->appendChild($frp);
    
    
    if ( exists( $affgene{SF5e} ) && ($affgene{SF5e} ne "") ) {
        print STDERR "in SF5e == $affgene{SF5e}=== \n";
        my $value = $affgene{SF5e} ;
        my $rank = get_frprop_rank( $db,'subject_id','object_id', $unique, $gene, $fpr_type{SF5e}, $value );
        my $frprop = create_ch_frprop(
            doc   => $doc,
            value => $value,
            type  => $fpr_type{SF5e},
            rank  => $rank
        );
        $fr->appendChild($frprop);
    }
    if ( exists( $affgene{SF5f} ) ) {
     print STDERR "in SF5f $affgene{SF5f}\n";
        my $value = $affgene{SF5f};
        my @items = split( /\n/, $value );
        foreach my $item (@items) {
            my $rank =
              get_frprop_rank( $db,'subject_id','object_id', $unique, $gene, $fpr_type{SF5f},$value );
            my $frprop = create_ch_frprop(
                doc   => $doc,
                value => $item,
                type  => $fpr_type{SF5f},
                rank  => $rank
            );
            $fr->appendChild($frprop);
        }
    }
    $out.=dom_toString($fr);
    }
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
  my $type = '';
  my $out = '';
  
  if ( exists( $ph{SF1f} ) && $ph{SF1f} ne 'new' ){

    ( $genus, $species, $type ) =
      get_feat_ukeys_by_uname( $self->{db}, $ph{SF1f});
    if($genus eq '0' || $genus eq '2'){
      print STDERR "ERROR: could not find $ph{SF1f} for symbol $ph{SF1a} in DB\n";
      
    }
    if(!exists($ph{SF1c})){
     	($unique,$genus,$species,$type)=get_sffeat_ukeys_by_name($self->{db},$ph{SF1a}) ;
	    if($unique ne $ph{SF1f}){
	      print STDERR "ERROR: name and uniquename not match $ph{SF1f}  $ph{SF1a} Instead we have '$unique'\n";
	      exit(0);
	    }
    } 

    $unique = $ph{SF1f};
    if(!exists($ph{SF1a})){
      print STDERR "ERROR: no SF1a field\n";
    }
    if(exists($fbids{$unique})){
      print STDERR "ERROR: $unique has been in previous proforma with an action item, separate loading\n";
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
    if(exists($ph{SF4g})){
      $feature=add_feature_residue($doc,$feature,$ph{SF4g});
    } 
    if ( exists( $ph{SF1h} ) && $ph{SF1h} eq 'y' ) {
      print STDERR "Action Items: delete SF $ph{SF1f} == $ph{SF1a}\n";
      my $op = create_doc_element( $doc, 'is_obsolete', 't' );
      $feature->appendChild($op);
    }
    if(exists($ph{SF1c})){
	 if(exists($fbids{$ph{SF1c}})){
	     print STDERR "ERROR: Rename SF1c $ph{SF1c} exists in a previous proforma\n";
	 }
	 if(exists($fbids{$ph{SF1a}})){                                    
	     print STDERR "ERROR: Rename SF1a $ph{SF1a} exists in a previous proforma \n";
	 }  

      print STDERR "Action Items: Rename $ph{SF1c} to $ph{SF1a}\n";
      my $va=validate_new_name($db, $ph{SF1a});
      if ($va == 0){
	my $n=create_doc_element($doc,'name',decon(convers($ph{SF1a})));
	$feature->appendChild($n);
	$out.= dom_toString($feature);
	$out .= write_feature_synonyms( $doc, $unique, $ph{SF1a}, 'a', 'unattributed', 'symbol' );
	$fbids{$ph{SF1c}}=$unique;
      }
    }
    else{
      $out.=dom_toString($feature);
    }
    $fbids{ $ph{SF1a} } = $unique;
  }
  elsif (  exists( $ph{SF1f} ) && $ph{SF1f} eq 'new')  {
    if(!exists($ph{SF1g})){
      $flag=0;
      my $va=validate_new_name($db, $ph{SF1a});
      if($va==1){
	$flag=0;
	($unique,$genus,$species,$type)=get_feat_ukeys_by_name($db,$ph{SF1a});
	$fbids{$ph{SF1a}}=$unique;
      }
    }
    if(exists($ph{SF2b})){
      $type=$ph{SF2b};
      if(exists($sftype{$type})){
	  validate_cvterm($db,$type,'SO');
      }
      else{
	  print STDERR "ERROR: $type Not valid type for SF2b needs this SO term added to SF.pm\n";
      }	  
    }
    ( $unique, $flag ) = get_tempid( $sftype{$type}, $ph{SF1a} );
    if(exists($ph{SF1g}) && $ph{SF1f} eq 'new' && $unique !~/temp/){
      print STDERR "ERROR: merge sfs should have a FB..:temp id not $unique\n";
    }
    print STDERR "Action Items: new SF $ph{SF1a} \n";
    if ( exists( $ph{SF3b} ) ) {
      ( $genus, $species ) =
	get_organism_by_abbrev( $self->{db}, $ph{SF3b} );
    }
    elsif ( $ph{SF1a} =~ /^(.{2,14}?)\\(.*)/ ){
      ( $genus, $species ) = get_organism_by_abbrev( $self->{db}, $1 );
    }
    if($genus eq '0'){
      print STDERR "ERROR: could not get genus for Feature $ph{SF1a}\n";
      exit(0);
    }
    if ( $flag == 0 ) {
      $feature = create_ch_feature(
                uniquename => $unique,
                name       => decon( convers( $ph{SF1a} ) ),
                genus      => $genus,
                species    => $species,
                type       => $type,
                doc        => $doc,
                macro_id   => $unique,
                no_lookup  => '1'
				  );
      if(exists($ph{SF4g})){
	$feature=add_feature_residue($doc,$feature,$ph{SF4g});
      } 
      $out.=dom_toString($feature);
      $out .=
	write_feature_synonyms( $doc, $unique, $ph{SF1a}, 'a',
                'unattributed', 'symbol' );
    }
    else{
      print STDERR "ERROR, name $ph{SF1a} has been used in this load\n";
    }
  }
    else{
      print STDERR "ERROR: SF1f must be new or an FBsf\n";
    }     
  
  $doc->dispose();
  return ($out, $unique);
}

#Checking points:
#I. when SF1f is new
#1. check existance of SF3b(organism) SF2b(feature type)
#2. check for the SF1a name existance in DB.
#3. check abbrevation of organism in DB.
#4. check SF2b cvterm existance.
#5. check !c fields
#II. when MA1f has valid id
#1. check for the MA1a existance
#1. name and uniquename consistence
#2. if MA1c exists, check MA1f and MA1c consistence and MA1a existance
#in DB, otherwise only check MA1f and MA1a consistence
#3. check !c on
#4. check !c on MA21a for existance of the featureloc+pub
#ALL:
#1. if MA4, MA19, MA18, new accession/symbol is allowed
#
sub validate {
    my $self   = shift;
    my $tihash = {@_};
    my %tival  = %$tihash;
    my $v_unique='';
    
    print STDERR "Validating SF ", $tival{SF1a}, " ....\n";
    if(exists($tival{SF1f}) && ($tival{SF1f} ne 'new') && !exists($tival{SF1c})){
    validate_uname_name($db, $tival{SF1f}, $tival{SF1a});
    }
    if ( exists( $fbids{$tival{SF1a}})){
        $v_unique=$fbids{$tival{SF1a}};    
    }
    else{
        print STDERR "ERROR: could not validate $tival{MA1a}\n";
        return;
    }
    if($v_unique =~/FB.*:temp/){
        foreach my $f (keys %tival){
            if($f=~/(.*)\.upd/){
                print STDERR "ERROR: !c is not allowed for a new TI\n";
            }
        }
    }
    foreach my $f ( keys %tival ) {
            if ( $f =~ /(.*)\.upd/ && !($v_unique=~/FB.*:temp/) ) {
                $f = $1;
                if (  $f eq 'SF4c'
                    || $f eq 'SF10a'
                    || $f eq 'SF11b'
                    || $f eq 'SF11c'
                    || $f eq 'SF12'
                    || $f eq 'SF20a'
                    || $f eq 'SF6'
                    || $f eq 'SF7'
                    || $f eq 'SF8'
                  )
                {
                    my @num =
                      get_unique_key_for_featureprop( $db, $v_unique,
                        $fpr_type{$f}, $tival{pub} );
                    if ( @num == 0 ) {
                        print STDERR "ERROR: !c: there is no previous record for $f field.\n";
                    }
                }
                elsif ($f eq 'SF5a'
                    || $f eq 'SF4d'
                    || $f eq 'SF5b'
                    || $f eq 'SF5c'
                    || $f eq 'SF5d'
                    || $f eq 'SF11a'
                    || $f eq 'SF20b'
                    || $f eq 'SF20c'
                    )
                {
                    my $subject = 'subject_id';
                    my $object  = 'object_id';
                    my @num =
                      get_unique_key_for_fr( $db, $subject, $object,
                        $v_unique, $fpr_type{$f}, $tival{pub} );
                    if ( @num == 0 ) {
                        print STDERR "ERROR !c: There is no previous record for $f field\n";
                    }
                }
                elsif ( $f eq 'SF4a' ) {
                    my @num =
                      get_ukeys_from_featureloc( $db, $v_unique,
                        $tival{pub} );
                    if ( @num == 0 ) {
                        print STDERR "ERROR !c: There is no previous record for $f field\n";
                    }

                }
       }
    elsif ( $f eq 'SF5a' || $f eq 'SF5c' || $f eq 'SF5b' || $f eq 'SF5d' || $f eq 'SF4d' 
    || $f eq 'SF11a' ) {
        if(defined($tival{$f})){
        my @items=split(/\n/,$tival{$f});
        foreach my $item(@items){
            $item=~s/^\s+//;
            $item=~s/\s+$//;
            if(!exists($fbids{$item})){
                my ( $g_u, $g_g, $g_s, $g_t ) =
                 get_feat_ukeys_by_name( $db,  $item );
                if ( $g_u eq '0' ) {
                    print STDERR "ERROR: ", $tival{SF1a}, " $f:", $item, "symbol could not be found in the Database\n";
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
! MA. TRANSPOSON INSERTION PROFORMA [ti.pro]      Version 22: 06 Dec 2006
!
! MA1f. Database ID for insertion (FBti)       :new
! MA1a. Insertion symbol to use in database    :
! MA1b. Symbol used in paper                   :
! MA27. Insertion category [CV]                :synTE_insertion
! MA4.  Symbol of inserted transposon          :
! MA20. Species of host genome                 :

! MA1c. Action - rename this insertion symbol    :
! MA1g. Action - merge these insertion(s) (FBti) :
! MA1h. Action - delete insertion record ("y"/blank)   :
! MA1i. Action - dissociate MA1f from FBrf ("y"/blank) :

! MA1d. Other synonym(s) for insertion symbol  :
! MA1e. Silent synonym(s) for insertion symbol :
! MA22. Line id associated with insertion      :

! MA5a. Chromosomal location of insert                     :
! MA5c. Cytological location of insert (in situ)           :
! MA5e. Cytological location (inferred from sequence)      :
!   MA5f. Genomic release number for data reported in MA5e :
! MA5d. Insertion maps to/near gene                        :

! MA7.  Associated chromosomal aberration      :
! MA14. Associated balancer                    :
! MA12. Consequent allele(s)                   :

! MA8.  Phenotype [viable, fertile]            :

! MA21a. Genomic location of insertion (dupl for multiple) :
!   MA21b. Genome release number for entry in MA21a        :
! MA21e. Comments concerning genomic location              :
! MA6.   Orientation of insert relative to chromosome      :

! MA21c. Insertion into natTE (identified, in FB)             :
! MA21f. Insertion into other TE or repeat region ("y"/blank) :
! MA21d. Distance from insertion site to end of natTE/repeat  :

! MA19a. Accession for insertion flanking sequence (dupl for multiple) :
!   MA19b. Insertion site accession type (5', 3', b)                   :
!   MA19c. Position of first base of target sequence in accession      :
!   MA19d. First base of unique sequence in accession if in natTE      :
!   MA19e. Accession invalidation or assessment                        :
! MA26.  Accession for this instance of natTE                          :

! MA23a. Insertion-affected gene reported (dupl for multiple) :
!   MA23b. Affected gene criteria [CV]                        :
!   MA23c. Comment, affected gene criteria [free text]        :
!   MA23g. Orientation relative to affected gene              :

! MA15a. FBti progenitor (via transposition) at distinct location :
! MA15b. FBti progenitor (via recombination) at distinct location :
! MA15c. Replaced FBti progenitor, recombination substrate        :
! MA15d. Modified FBti progenitor (in situ)                       :

! MA24. Arose in multiple insertion line ("y"/"p"/blank) :
! MA18. Co-isolated insertion(s)                         :

! MA9.  Comments [free text]        :
! MA16. Information on availability :
! MA10. Internal notes              :
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

=head1 AUTHOR

Haiyan Zhang, E<lt>haiyan@morgan.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
