package FlyBase::Proforma::TP;

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

our @EXPORT = qw( process_moseg validate_moseg

);

our $VERSION = '0.01';

# Preloaded methods go here.
=head1 NAME

FlyBase::Proforma::TP - Perl module for parsing the FlyBase
molecular segment  proforma version 24, Jan 11, 2007.

See the bottom for the proforma
                         
=head1 SYNOPSIS

  use FlyBase::Proforma::TP;
  use DBI;
  
  my $mdbh=DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";
  my %ph=(MS1a=>'TM9',....);
  ###!c field implemented as '$fieldname.upd=>'c'' eg. 'MS16.upd'=>'c'
   
  #params db is manditory, debug and validate is optional
  my $pro=FlyBase::proforma::TP->new(db=>$mdbh);
  $pro->validate(%ph);
  my $chadoxml = $pro->process(%ph);
  
  # or

  my $pro=FlyBase::Proforma::TP->new(db=>$mdbh,debug=>1,validate=>1);
  my $chadoxml_string=$pro->process(%ph);

=head1 DESCRIPTION

FlyBase::Proforma::TP is a perl module for parsing FlyBase
molecular segment proforma and write the result as chadoxml. It is required
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

our %tp_fpr_type = (
    'MS19a', 'in_vitro_descendant_of',      #feature_relationship.object_id symbol FBtp, FBmc, FBms
    'MS19b', 'in_vitro_progenitor',         #featureprop
    'MS19c', 'isolate_of',                  #feature_relationship.object_id
    'MS19d', 'in_vitro_descendant_of',      #feature_relationship.object_id FBcl symbol
    'MS19e', 'associated_with',             #feature_relationship.object_id gene symbol only if FBmc
    'MS22',  'transgene_localized_func',    #feature_cvterm
    'MS21',  'belongs_to',                  ##feature_relationship.object_id
    'MS5a',  'original_left_end',           #featureprop
    'MS5b',  'original_right_end',          #featureprop
    'MS4h',  'gets_expression_data_from',    #feature_relationship.object_id
    'MS20',  'similiar_function_to',        #feature_relationship.object_id
    'MS4b',  'kb_length',                   #featureprop
    'MS18a', 'cloning_sites',               #featureprop
    'MS18b', 'restriction_sites',           ### featureprop
    'MS9', 'partof',                 ###Segments in feature_relationship module
    'MS1e', 'molobject_segment_type', #featureprop
    'MS14', 'transgene_uses',         #feature_cvterm
    'MS4e', 'attributes_source',      #featureprop
    'MS4g', 'transgene_features',     #feature_cvterm
    'MS4a', 'transgene_description',  #feature_cvterm
    'MS10b', 'comment',               #featureprop
    'MS16',  'molobject_type',        #featurprop
    'MS11',  'internalnotes',         #featureprop
    'MS12',  'sequence',
    'MS30', 'library_feature',               #library_feature
    'MS30a', 'library_featureprop',          #library_featureprop
    'MS14a', 'tagged_with', #feature_relationship.object_id Tagged with experimental tool (FBto symbol)
    'MS14b', 'carries_tool', #feature_relationship.object_id Other experimental tools (FBto symbol)
    'MS14c', 'encodes_tool', #feature_relationship.object_id Encoded experimental tools (FBto symbol)
    'MS14d', 'FlyBase miscellaneous CV', #feature_cvterm Encoded experimental tools (CV) feature_cvtermprop type tool_uses
    'MS14e', 'has_reg_region', #feature_relationship.object_id Regulatory region(s) present (symbol)
    'MS15', 'molecular_info', #featureprop free text
    'MS24', 'marked_with', #feature_relationship.object_id Marker allele(s) carried (symbol)
);


# Proforma expects a posible DNA_segmgnt but stored as engineered_region
# similarly for engineered_construct => engineered_plasmid
our %tp_feat_type = (
    'transgenic_transposable_element',  'tp',
    'natural_transposon',               'te',
    'engineered_transposable_element',  'tp',
    'engineered_plasmid',               'mc',
    'cloned_region',                    'ms',
);
#PDEV62 where ever tp_feat_type check if ^TI\{ and make uniquename tp


# IS this used???
# our %tp_type = (
#     'transgenic_transposon',      'synthetic construct',
#     'natural_transposon_isolate', 'synthetic construct',
#     'engineered_construct',       'synthetic construct',
#     'engineered_region',          'synthetic construct'
# );
#PDEV62 OK as long as this is organism

my %ms30a_type = ('experimental_result', 1 , 'member_of_reagent_collection', 1);
my %fcp_type = ('MS14d', 'tool_uses');

my %feat_type = (
    'MS14a', 'engineered_region',
    'MS14b', 'engineered_region',
    'MS14c', 'engineered_region',
    'MS24', 'allele',
);
my %id_type = ('MS14a', 'to', 'MS14b', 'to', 'MS14c', 'to','MS24', 'al');

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
    my $genus;
    my $species;
    my $type;
    my $out = '';

    #if ( exists( $self->{debug} ) && $self->{debug} == 1 ) {
     #   foreach my $key ( keys %ph ) {
     #       print STDERR "$key, $ph{$key}\n";
     #   }
    #}

    if ( exists( $self->{validate} ) && $self->{validate} == 1 ) {
        $self->validate_moseg($tihash);
    }
    print STDERR "processing MOSEG " . $ph{MS1f} . "==" . $ph{MS1a} . "...\n";
  
    if(exists($fbids{$ph{MS1a}})){
        $unique=$fbids{$ph{MS1a}};
    }
    else{
        ($unique, $out)=$self->write_feature($tihash);
    }
        if(exists($fbcheck{$ph{MS1a}}{$ph{pub}})){
        print STDERR "Warning: $ph{MS1a} $ph{pub} exists in a previous proforma\n";
    }
    $fbcheck{$ph{MS1a}}{$ph{pub}}=1;
    if(!exists($ph{MS1i})){
     print STDERR "Action Items: moseg $unique == $ph{MS1a} with pub $ph{pub}\n"; 
    my $fpub = create_ch_feature_pub(
        doc        => $doc,
        feature_id => $unique,
        pub_id     => $ph{pub}
    );
    $out .= dom_toString($fpub);
    }
       else {
            print STDERR "Action Items: dissociate $ph{MS1a} with $ph{pub}\n";
            $out .= dissociate_with_pub( $self->{db}, $unique, $ph{pub} );
            return $out;
        }
     if(exists($ph{MS1h}) && $ph{MS1h} eq 'y'){
        return $out;
     }
    ##Process other field in Molecular Segment proforma
    foreach my $f ( keys %ph ) {
#        print STDERR "$f\n";
        if (   $f eq 'MS1b'
            || $f eq 'MS3d'
            || $f eq 'MS3b' )
        {
            my $t = $f;
            $t =~ s/MS\d//;
            if ( $f eq 'MS3b' ) {
                $t = 'd';
            }
            elsif ( $f eq 'MS3d' ) {
                $t = 'e';
            }

            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
              print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                my $up = 'FBrf0104946';
                if ( $t eq 'b' ) {
                    $up = $ph{pub};
                }
                $out .=
                  delete_feature_synonym( $self->{db}, $doc, $unique, $up,'symbol' );
            }
            if ( defined( $ph{$f} ) && ( $ph{$f} ne '' ) ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    if($item ne 'unnamed' && $item ne ''){
                    if ( $f eq 'MS3b' && $item =~ /FB\w{2}\d+/ ) {
                        my $dbxref = create_ch_feature_dbxref(
                            doc        => $doc,
                            feature_id => $unique,
                            dbxref_id  => create_ch_dbxref(
                                doc       => $doc,
                                accession => $item,
                                db        => 'FlyBase',
                                no_lookup =>1
                            ),
                            is_current => '0'
                        );
                        $out .= dom_toString($dbxref);
                        my ( $s_g, $s_s, $s_t ) =
                          get_feat_ukeys_by_uname( $self->{db}, $item );
                        my $s_f = create_ch_feature(
                            doc         => $doc,
                            uniquename  => $item,
                            genus       => $s_g,
                            species     => $s_s,
                            type        => $s_t,
                            macro_id    => $item,
                            is_obsolete => 't'
                        );
                        $out .= dom_toString($s_f);
                        $s_f->dispose();
                    }
                    else {

                        if ( $t eq 'b' ) {
                            if($item eq $ph{MS1a}){
                            $out.=write_feature_synonyms( $doc, $unique, $item, 'a',
                                $ph{pub}, 'symbol' );
                        }else{
                            $out .=
                              write_feature_synonyms( $doc, $unique, $item, $t,
                                $ph{pub}, 'symbol' );
                            }
                        }
                        else {
                            $out .=
                              write_feature_synonyms( $doc, $unique, $item, $t,
                                'FBrf0104946', 'symbol' );
                        }
                    }
                }
                }
            }
        }
        elsif( $f eq 'MS1c'){
                    $out .=
              update_feature_synonym( $self->{db}, $doc, $unique, $ph{$f},
                'symbol' );
        }
        elsif ( $f eq 'MS3e' ) {
            if ( exists( $ph{"$f.upd"} ) ) {
                print STDERR "ERROR: havenot implementated MS3e.upd yet\n";
            }
            my @items = split( /\n/, $ph{$f} );
            foreach my $item (@items) {
                $item =~ s/^\s+//;
                $item =~ s/\s+$//;
                $out .= write_feature_synonyms( $doc, $unique, $item, 'a',
                    'FBrf0104946', 'bloomington_symbol' );
            }
        }
       
        elsif ( $f eq 'MS1g' ) {
             my $tmp=$ph{$f};
            $tmp=~s/\n/ /g;
            if($ph{MS1f} eq 'new'){
                print STDERR "Action Items: merge Moseg $tmp\n";
		$out .=
              merge_records( $self->{db}, $unique, $ph{$f}, $ph{MS1a},
                $ph{pub},$ph{MS1a} );
	      }
	     else{
                print STDERR "ERROR: merge TP $tmp to $ph{MS1f} == $ph{MS1a} NOT allowed MS1f MUST be new\n";
	      }

	   }
        elsif ($f eq 'MS19a'
            || $f eq 'MS19c'
            || $f eq 'MS20'
            || $f eq 'MS4h'
            || $f eq 'MS21' )
        {
            my $object  = 'object_id';
            my $subject = 'subject_id';

            if ( $f =~ /MS20/ || $f eq 'MS4h' ) {
                $object  = 'subject_id';
                $subject = 'object_id';
            }
            if ( exists( $ph{ "$f.upd" } ) and $ph{ "$f.upd" } eq 'c' ) {
              print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                my @results =
                  get_unique_key_for_fr( $self->{db}, $subject, $object,
                    $unique, $tp_fpr_type{$f}, $ph{pub} );
                foreach my $ta (@results) {
                    my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );
                    if ( $num == 1 || (defined($frnum{$unique}{$ta->{name}}) && $num-$frnum{$unique}{$ta->{name}}==1)) {
                        $out .=
                          delete_feature_relationship( $self->{db}, $doc, $ta,
                            $subject, $object, $unique, $tp_fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_feature_relationship_pub( $self->{db}, $doc,
                            $ta, $subject, $object, $unique, $tp_fpr_type{$f},
                            $ph{pub} );
                    }
                    else {
                        print STDERR "ERROR:something Wrong, please validate first\n";
                    }
                }
            }
            if (defined($ph{$f}) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item=~s/\s+$//;
                    $item=~s/^\s+//;
		    my $fu = ""; 
		    my $fg = ""; 
		    my $fs = ""; 
		    my $ft = "";
		    my $ftype = "";
		    ($fu, $fg, $fs, $ft) = get_feat_ukeys_by_name( $self->{db}, $item);
		    if($fu eq  '0'){
			print STDERR "ERROR: $f could not get uniquename for $item\n";
		    }
		    elsif($fu eq '2'){
			print STDERR "ERROR: $f duplicate names $item \n";
		    }
		    print STDERR "DEBUG: $f $item $fu, $fg, $fs, $ft\n";			
		    $fu =~ /^FB([a-z][a-z])/;
		    $ftype = $1;			
		    print STDERR "CHECK: $f $item $ft $ftype\n";
		    my ($fr,$f_p) = write_feature_relationship(
			$self->{db},      $doc,
			$subject,         $object,
			$unique,          $item,
			$tp_fpr_type{$f}, $ph{pub},
			$ft,            $ftype,
			);
		    $out .= dom_toString($fr);
		    $fr->dispose();
		    $out.=$f_p;
		}
	    }
	}

#MS19d
        elsif ($f eq 'MS19d')
        {
            my $object  = 'object_id';
            my $subject = 'subject_id';

            if ( exists( $ph{ "$f.upd" } ) and $ph{ "$f.upd" } eq 'c' ) {
              print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                my @results =
                  get_unique_key_for_fr( $self->{db}, $subject, $object,
                    $unique, $tp_fpr_type{$f}, $ph{pub} );
                foreach my $ta (@results) {
                    my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );
                    if ( $num == 1 || (defined($frnum{$unique}{$ta->{name}}) && $num-$frnum{$unique}{$ta->{name}}==1)) {
                        $out .=
                          delete_feature_relationship( $self->{db}, $doc, $ta,
                            $subject, $object, $unique, $tp_fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_feature_relationship_pub( $self->{db}, $doc,
                            $ta, $subject, $object, $unique, $tp_fpr_type{$f},
                            $ph{pub} );
                    }
                    else {
                        print STDERR "ERROR:something Wrong, please validate first\n";
                    }
                }
            }
            if (defined($ph{$f}) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item=~s/\s+$//;
                    $item=~s/^\s+//;
		    my $fu = ""; 
		    my $fg = ""; 
		    my $fs = ""; 
		    my $ft = "";
		    my $ftype = "";
		    ($fu, $fg, $fs, $ft) = get_clfeat_ukeys_by_name( $self->{db}, $item);
		    if ($fu eq '0'){
			print  STDERR "ERROR: $f could not get uniquename for $item\n";
		    }
		    elsif($fu eq '2'){
			print STDERR "ERROR: $f duplicate names $item \n";
		    }
		    if ( ($ft eq "genomic_clone") || ($ft eq "cDNA_clone") ){
			print STDERR "DEBUG: $f $item $fu, $fg, $fs, $ft\n";
		    }
		    else{
			print STDERR "ERROR: $f $item not genomic_clone nor cDNA_clone\n";
		    }
		    $fu =~ /^FB([a-z][a-z])/;
		    $ftype = $1;			
		    print STDERR "CHECK: $f $item $ft $ftype\n";
		    my ($fr,$f_p) = write_feature_relationship(
			$self->{db},      $doc,
			$subject,         $object,
			$unique,          $fu,
			$tp_fpr_type{$f}, $ph{pub},
			$ft,            $ftype,
			);
		    $out .= dom_toString($fr);
		    $fr->dispose();
		    $out.=$f_p;
		}
	    }
	}

        elsif ($f eq 'MS19e')
        {
            my $object  = 'object_id';
            my $subject = 'subject_id';
	    if ( $unique !~ /FBmc/ && $type ne 'engineered_plasmid') {
		print STDERR "ERROR: $f MS1f/MS1a must be FBmc\n";
            }
            if ( exists( $ph{ "$f.upd" } ) and $ph{ "$f.upd" } eq 'c' ) {
              print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                my @results =
                  get_unique_key_for_fr( $self->{db}, $subject, $object,
                    $unique, $tp_fpr_type{$f}, $ph{pub} );
                foreach my $ta (@results) {
                    my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );
                    if ( $num == 1 || (defined($frnum{$unique}{$ta->{name}}) && $num-$frnum{$unique}{$ta->{name}}==1)) {
                        $out .=
                          delete_feature_relationship( $self->{db}, $doc, $ta,
                            $subject, $object, $unique, $tp_fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_feature_relationship_pub( $self->{db}, $doc,
                            $ta, $subject, $object, $unique, $tp_fpr_type{$f},
                            $ph{pub} );
                    }
                    else {
                        print STDERR "ERROR:something Wrong, please validate first\n";
                    }
                }
            }
            if (defined($ph{$f}) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item=~s/\s+$//;
                    $item=~s/^\s+//;
		    my $fu = ""; 
		    my $fg = ""; 
		    my $fs = ""; 
		    my $ft = '';
		    my $ftype = "";
		    if($item ne ''){
			($fu, $fg, $fs, $ft) = get_feat_ukeys_by_name_type( $self->{db}, $item, 'gene');
			if($fu eq  '0'){
			    print STDERR "ERROR: $f could not get uniquename for $item type 'gene'\n";
			}
		    }
		    $fu =~ /^FB([a-z][a-z])/;
		    $ftype = $1;			
		    print STDERR "CHECK: $f $item $ft $ftype\n";
		    my ($fr,$f_p) = write_feature_relationship(
                        $self->{db},      $doc,
                        $subject,         $object,
                        $unique,          $item,
                        $tp_fpr_type{$f}, $ph{pub},
			 $ft,            $ftype,
                    );
                    $out .= dom_toString($fr);
                    $fr->dispose();
                    $out.=$f_p;
		}
	    }
	}
	elsif ($f eq 'MS4b'
	       || $f eq 'MS1e'
	       || $f =~ 'MS18'
	       || $f eq 'MS10b'
	       || $f eq 'MS11'
	       || $f eq 'MS19b'
	       || $f eq 'MS5a'
	       || $f eq 'MS5b'
	       || $f eq 'MS16'
	       || $f eq 'MS4e'
	       || $f eq 'MS12' )
        {
            if ( exists( $ph{ "$f.upd" } ) && $ph{ "$f.upd" } eq 'c' ) {
                  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                my @results =
                  get_unique_key_for_featureprop( $self->{db}, $unique,
                    $tp_fpr_type{$f}, $ph{pub} );
                foreach my $t (@results) {
                    my $num = get_fprop_pub_nums( $self->{db}, $t->{fp_id} );
                    if ( $num == 1 || (defined($frnum{$unique}{$tp_fpr_type{$f}}{$t->{rank}}) && $num-$frnum{$unique}{$tp_fpr_type{$f}}{$t->{rank}}==1)) {
                        $out .=
                          delete_featureprop( $doc, $t->{rank}, $unique,
                            $tp_fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_featureprop_pub( $doc, $t->{rank}, $unique,
                            $tp_fpr_type{$f}, $ph{pub} );
                    }
                    else {
                        print STDERR "ERROR:something Wrong, please validate first\n";
                    }
                }
            }
            if ( $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    $out .=
                      write_featureprop( $self->{db}, $doc, $unique, $item,
                        $tp_fpr_type{$f}, $ph{pub} );
                }
            }
        }
        elsif ( $f eq 'MS7a' ) {

            $out .= &parse_location( $unique, \%ph, $ph{pub} );

        }
        elsif ( $f eq 'MS7' ) {
            print STDERR "Warning: in multiple field MS7 \n";
            ##### multiple featurelocs
            my @array = @{ $ph{MS7} };
            foreach my $ref (@array) {
                $out .= &parse_location( $unique, $ref, $ph{pub} );
            }
        }
        elsif ( $f eq 'MS7e' ) {
            print STDERR "Warning: havenot implemented $f\n";
        }
        elsif ( $f eq 'MS9' ) {
            if(exists($ph{"$f.upd"})){
                print STDERR "ERROR: has not implemented MS9 yet\n";
                  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
            }
            #### composed segments
            if ( length( $ph{MS9} ) > 9 ) {
                $out .= &parse_segments( $unique, $ph{MS9}, $ph{pub} );
            }
        }

        elsif ($f eq 'MS14'
            || $f eq 'MS22'
            || $f eq 'MS4g'
            || $f eq 'MS4a' )
        {

            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                my @result =
                  get_cvterm_for_feature_cvterm( $self->{db}, $unique,
                    $tp_fpr_type{$f}, $ph{pub} );

                foreach my $item (@result) {
                 my ($cvterm, $obsolete)=split(/,,/,$item);
                    my $feat_cvterm = create_ch_feature_cvterm(
                        doc        => $doc,
                        feature_id => $unique,
                        cvterm_id  => create_ch_cvterm(
                            doc  => $doc,
                            cv   => $tp_fpr_type{$f},
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
                $item=~s/^\s+//;
                $item=~s/\s+$//;
                if($item ne ''){
                my $cvt    = '';
                my $cvprop = '';
                if ( $item =~ /(.*?)\s\|\s(.*)/ ) {
                    $cvt    = $1;
                    $cvprop = $2;
                }
                else {
                    $cvt = $item;
                }
			    validate_cvterm($self->{db}, $cvt, $tp_fpr_type{$f});
					
                my $f_cvterm = create_ch_feature_cvterm(
                    doc        => $doc,
                    feature_id => $unique,
                    cvterm_id  => create_ch_cvterm(
                        doc  => $doc,
                        cv   => $tp_fpr_type{$f},
                        name => $cvt
                    ),
                    pub_id => $ph{pub}
                );
                if ( $cvprop ne '' ) {
                    my $rank =
                      get_feature_cvtermprop_rank( $self->{db}, $unique,
                        $tp_fpr_type{$f}, $cvt, $tp_fpr_type{$f} . ' property',
                        $cvprop, $ph{pub} );
                    my $cvp = create_ch_feature_cvtermprop(
                        doc   => $doc,
                        value => $cvprop,
                        type  => $tp_fpr_type{$f} . ' property',
                        rank  => $rank
                    );
                    $f_cvterm->appendChild($cvp);
                }

                $out .= dom_toString($f_cvterm);
                $f_cvterm->dispose();
                }
            }
        }
      }

        elsif ( $f eq 'MS30' ){               
	    print STDERR "CHECK: new implemented $f  $ph{MS1a} \n";

            if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
                print STDERR "CHECK: new implemented !c $ph{MS1a} $f \n";
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
		print STDERR "ERROR: could not find record for $ph{MS30}\n";
		  #		  exit(0);
	      }
	      else{
		print STDERR "DEBUG: MS30 $ph{$f} uniquename $libu\n";		  
		if(defined ($ph{MS30a}) && $ph{MS30a} ne ""){
		  if (exists ($ms30a_type{$ph{MS30a}} ))  {
		    my $item = $ph{MS30a};
		    print STDERR "DEBUG: MS30a $ph{MS30a} found\n";
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
		    print STDERR "ERROR: wrong term for MS30a $ph{MS30a}\n";
		  }
		}
		else{
		  print STDERR "ERROR: MS30 has a library no term for MS30a\n";
		}
		
	      }
	    }

	}
	elsif( ($f eq 'MS30a' && $ph{MS30a} ne "") && ! defined ($ph{MS30})){
	  print STDERR "ERROR: MS30a has a term for MS30a but no library\n";
	}
#Tools	    
	elsif ($f eq 'MS14a'
	       || $f eq 'MS14b'
	       || $f eq 'MS14c'
	       || $f eq 'MS24'
	    )
	{ 
	    my $object  = 'object_id';
	    my $subject = 'subject_id';
	    if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
		print STDERR "Action Items: !c log,$ph{MS1a} $f  $ph{pub}\n";
		my @results = get_unique_key_for_fr_by_feattype(
		    $self->{db}, $subject,      $object,
		    $unique,  $tp_fpr_type{$f}, $ph{pub}, $feat_type{$f}
		    );
		foreach my $ta (@results) {
		    my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );
		    #print STDERR "fr number $num\n";
		    if ( $num == 1  || (defined($frnum{$unique}{$ta->{name}}) && $num-$frnum{$unique}{$ta->{name}}==1)) {
			#print STDERR "Warning: deleting feature_relationship $unique $f ",$ta->{name}," ", $ph{pub},"\n";
			$out .=
			    delete_feature_relationship( $self->{db}, $doc, $ta,
							 $subject, $object, $unique, $tp_fpr_type{$f} );
		    }
		    elsif ( $num > 1 ) {
			$out .=
			    delete_feature_relationship_pub( $self->{db}, $doc,
							     $ta, $subject, $object, $unique, $tp_fpr_type{$f},
							     $ph{pub} );
		    }
		    else {
			print STDERR "ERROR:something Wrong, please validate first\n";
		    }
		}
	    } #end !c
	    if (defined($ph{$f}) && $ph{$f} ne '' ) {
		my @items = split( /\n/, $ph{$f} );
		foreach my $item (@items) {
		    $item =~ s/^\s+//;
		    $item =~ s/\s+$//;
		    my ($fr,$f_p) = write_feature_relationship(
			$self->{db},   $doc,     $subject,
			$object,       $unique,  $item,
			$tp_fpr_type{$f}, $ph{pub}, $feat_type{$f},
			$id_type{$f}
			);
		    $out .= dom_toString($fr);
		    $out.=$f_p;
		}
	    }
	} # end elsif $f eq 'MS14a'|| $f eq 'MS14b'|| $f eq 'MS14c'|| $f eq 'MS24'

	elsif ($f eq 'MS15'){
	    if ( exists( $ph{ "$f.upd" } ) && $ph{ "$f.upd" } eq 'c' ) {
		print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
		my @results =
		    get_unique_key_for_featureprop( $self->{db}, $unique,
						$tp_fpr_type{$f}, $ph{pub} );
		foreach my $t (@results) {
		    my $num = get_fprop_pub_nums( $self->{db}, $t->{fp_id} );
		    if ( $num == 1 || (defined($frnum{$unique}{$tp_fpr_type{$f}}{$t->{rank}}) && $num-$frnum{$unique}{$tp_fpr_type{$f}}{$t->{rank}}==1)) {
			$out .=
			    delete_featureprop( $doc, $t->{rank}, $unique,
					    $tp_fpr_type{$f} );
		    }
		    elsif ( $num > 1 ) {
			$out .=
			    delete_featureprop_pub( $doc, $t->{rank}, $unique,
						$tp_fpr_type{$f}, $ph{pub} );
		    }
		    else {
			print STDERR "ERROR:something Wrong, please validate first\n";
		    }
		}
	    }
	    if ( $ph{$f} ne '' ) {
		my @items = split( /\n/, $ph{$f} );
		foreach my $item (@items) {
		    $item =~ s/^\s+//;
		    $item =~ s/\s+$//;
		    $out .=
			write_featureprop( $self->{db}, $doc, $unique, $item,
					   $tp_fpr_type{$f}, $ph{pub} );
		}
	    }
 
	} # end elsif ($f eq 'MS15

	elsif ($f eq 'MS14d')
	{
	    if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
		print STDERR "Action Items: !c log, $ph{$f} $f  $ph{pub}\n";
		my @results = get_cvterm_for_feature_cvterm_withprop( $self->{db}, $unique, $tp_fpr_type{$f}, $ph{pub}, $fcp_type{$f});
		if(@results==0){
		    print STDERR "ERROR: no previous record found for $ph{MS1a} $f $ph{pub} $ph{file}\n";
		}
		foreach my $item (@results) {
		    my $feat_cvterm = create_ch_feature_cvterm(
			doc        => $doc,
			feature_id => $unique,
			cvterm_id  => create_ch_cvterm(
			    doc  => $doc,
			    cv   => $tp_fpr_type{$f},
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
		print STDERR "DEBUG feature_cvterm $ph{MS1a} $f $ph{pub} $ph{file}\n";
		my @items = split( /\n/, $ph{$f} );
		foreach my $item (@items) {
		    $item =~ s/^\s+//;
		    $item =~ s/\s+$//;
		    print STDERR "DEBUG validate cvterm $tp_fpr_type{$f}, $item  $ph{MS1a} $f $ph{pub} $ph{file}\n";
		    validate_cvterm($self->{db},$item,$tp_fpr_type{$f});
		    my $f_cvterm = create_ch_feature_cvterm(
			doc        => $doc,
			feature_id => $unique,
			cvterm_id  => create_ch_cvterm(
			    doc  => $doc,
			    cv   => $tp_fpr_type{$f},
			    name => $item
			),
			pub_id => $ph{pub}
			);
		    my $fcvprop = create_ch_feature_cvtermprop(
			doc  => $doc,
			type_id => create_ch_cvterm(doc=>$doc,
                                                name=>$fcp_type{$f},
                                                cv=>'feature_cvtermprop type'),
			rank => '0'
			);
		    $f_cvterm->appendChild($fcvprop);
		    $out .= dom_toString($f_cvterm);
		    $f_cvterm->dispose();
		}
	    }

	} # end if MS14d

        elsif ( $f eq 'MS14e' ) {         
            my    $object  = 'object_id';
            my    $subject = 'subject_id';
            
            if ( exists( $ph{"$f.upd"} ) and $ph{"$f.upd"} eq 'c' ) {
                print STDERR "Action Items: !c log,$unique $f  $ph{pub}\n";
                my @results =
                  get_unique_key_for_fr( $self->{db}, $subject, $object,
                    $unique, $tp_fpr_type{$f}, $ph{pub} );
                foreach my $ta (@results) {
                    my $num = get_fr_pub_nums( $self->{db}, $ta->{fr_id} );
                    if ( $num == 1 || (defined($frnum{$unique}{$ta->{name}}) && $num-$frnum{$unique}{$ta->{name}}==1) ) {
                        $out .=
                          delete_feature_relationship( $self->{db}, $doc, $ta,
                            $subject, $object, $unique, $tp_fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_feature_relationship_pub( $self->{db}, $doc,
                            $ta, $subject, $object, $unique, $tp_fpr_type{$f},
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
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    my ($fr,$f_p) = write_feature_relationship( $self->{db}, $doc, $subject,
                        $object, $unique, $item, $tp_fpr_type{$f}, $ph{pub} );
                     $out.=dom_toString($fr);
                    $out.=$f_p;
                }
            }
        }

    }
    $doc->dispose();
    #print STDERR $out;
    return $out;
  }

sub moseg_name_change_action {
    my $dbh      = shift;
    my $doc      = shift;
    my $o_unique = shift;
    my $old      = shift;
    my $new      = shift;
    my $ncout    = '';
    my $state = "select f1.uniquename, f1.name, f1.organism_id, f1.type_id from
	 feature f1, feature f2, feature_relationship fr where
	 f1.feature_id=fr.subject_id and f2.feature_id=fr.object_id and
	 fr.type_id=27 and f2.uniquename=?;";    #type_id=27 is 'producedby'

    my $nc_nmm = $dbh->prepare($state);
    $nc_nmm->bind_param(1,$o_unique);
    $nc_nmm->execute;
    while ( my ( $u, $n, $o, $t ) = $nc_nmm->fetchrow_array ) {
        my $n_s = $n;
        $old =~ s/([\#\(\)\.\\\/\{\}\@\$\'\"\?\*\&])/\\\$1/g;
        $n_s =~ s/$old/$new/;
        my ( $g, $s ) = get_organism_by_id( $dbh, $o );
        $ncout .= create_ch_feature(
            doc        => $doc,
            uniquename => $u,
            genus      => $g,
            species    => $s,
            type       => get_type_by_id( $dbh, $t ),
            name       => $n_s,
            macro_id   => $u
        );
        $ncout .=
          write_feature_synonyms( $doc, $u, $n, 'c', 'FBrf0105495', 'symbol' );
        $ncout .= write_feature_synonyms( $doc, $u, $n_s, 'a', 'FBrf0105495',
            'symbol' );

    }

    return $ncout;
}

sub parse_location {
    my $fbid    = shift;
    my $value   = shift;
    my $pub_id  = shift;
    my $fmin    = 0;
    my $fmax    = 0;
    my $strand  = 1;
    my $locgroup =0;
    my $rank     =0;
    my $out     = '';
    my %loc_ref = %$value;
    if(defined($loc_ref{MS7b}) && defined($loc_ref{MS7c})){
    if ( $loc_ref{MS7b} < $loc_ref{MS7c} ) {
        $fmin   = $loc_ref{MS7b} - 1;
        $fmax   = $loc_ref{MS7c};
        $strand = 1;
    }
    else {
        $fmin   = $loc_ref{MS7c} - 1;
        $fmax   = $loc_ref{MS7b};
        $strand = -1;
    }
   
    }
    if(exists($loc_ref{"MS7a.upd"})){
        print STDERR "ERROR: has not implemented MS7a.upd yet\n";
          print STDERR "Action Items: !c log, $fbid MS7a $pub_id\n";
    }
    my ($id) = split( /\|/, $loc_ref{MS7a} );
    $id =~ s/^\s+//;
    $id =~ s/\s+$//;
    my ( $srcfeature, $ver ) = split( /\./, $id );
   
    my $dbxref = create_ch_dbxref(
        doc       => $doc,
        accession => $srcfeature,
      
        db        => 'GB',
        macro_id  => $id,
        no_lookup => 1
    );
    if(defined($ver)){
      $dbxref->appendChild(create_doc_element($doc,'version',$ver));
    }
    $out .= dom_toString($dbxref);
    $dbxref->dispose();
    my $src = create_ch_feature(
        doc        => $doc,
        uniquename => $srcfeature,
        name       => $srcfeature,
        genus      => 'Computational',
        species    => 'result',
        type       => 'so',
        dbxref_id  => $id,
        no_lookup  => 1,
        macro_id   => $srcfeature
    );
    $out .= dom_toString($src);
    $src->dispose();
    $out .=
      write_featureprop( $db, $doc, $srcfeature, $loc_ref{MS7a}, 'comment',
        $pub_id );

    my $f_dbxref = create_ch_feature_dbxref(
        doc        => $doc,
        feature_id => $srcfeature,
        dbxref_id  => $id
    );
    $out .= dom_toString($f_dbxref);
    $f_dbxref->dispose();
    my $fl;
    if(defined($loc_ref{MS7b}) && defined($loc_ref{MS7c})){
    $locgroup=get_max_locgroup($db,$fbid,$srcfeature,$fmin,$fmax,$strand);
     $fl = create_ch_featureloc(
        doc           => $doc,
        feature_id    => $fbid,
        fmin          => $fmin,
        fmax          => $fmax,
        strand        => $strand,
        rank          => $rank,
        locgroup      => $locgroup,
        srcfeature_id => $srcfeature
    );
    }
    else{
       $locgroup=get_max_locgroup($db,$fbid,$srcfeature);
      $fl = create_ch_featureloc(
        doc           => $doc,
        feature_id    => $fbid,
        srcfeature_id => $srcfeature,
        rank          => $rank,
        locgroup      => $locgroup
      );
    }
    my $fl_pub = create_ch_featureloc_pub( doc => $doc, pub_id => $pub_id );
    $fl->appendChild($fl_pub);
    $out .= dom_toString($fl);
    $fl->dispose();
    return $out;
}

###parse MS9a, format like 1:10223   | +
sub parse_segments {
    my $fbti   = shift;
    my $value  = shift;
    my $pub_id = shift;
    my $out    = '';
    $value=trim($value);
    my @items = split( /\n/, $value );
    foreach my $item (@items) {
        if ( $item =~ /^(\d+)\:(.*)\s+\|\s+([+|-])/ ) {
            my $rank   = $1;
            my $name   = $2;
            my $orient = $3;
          #  print STDERR "$rank, $name, $orient\n";
            my ($fr,$f_p) =
              write_feature_relationship( $db, $doc, 'object_id', 'subject_id',
                $fbti, $name, $tp_fpr_type{'MS9'}, $pub_id );
				 my $frank;
				 my $frank_new=create_doc_element($doc,"rank",$rank);
			
                my @list=$fr->getElementsByTagName("rank");
                 
				 if(@list!=0){
				 $frank=$list[0];
			     $fr->replaceChild($frank_new,$frank);
			    #  print STDERR "list is not null\n";
                 }
                 else{
                   # print STDERR "list is null\n";
                     my $first=$fr->getFirstChild;
                   $fr->insertBefore($frank_new, $first);
                     }
                   #  print STDERR dom_toString($fr);
                my $fr_prop = create_ch_frprop(
                    doc   => $doc,
                    value => $orient,
                    type  => 'relative_orientation'
                    );
            my $frprop_pub =
              create_ch_frprop_pub( doc => $doc, uniquename => $pub_id );
                $fr_prop->appendChild($frprop_pub);
                $fr->appendChild($fr_prop);
               $out.=$f_p;
            $out .= dom_toString($fr);
                $fr->dispose();
        }
        else {
            print STDERR "ERROR: $fbti could not parse $item\n";
        }

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
    my $genus='synthetic';
    my $species='construct';
    my $type;
    my $out = '';
    
    ## process MS1f, MS1a first to get feature information
    if ( exists( $ph{MS1f} ) && $ph{MS1f} ne 'new' ) {
        ( $genus, $species, $type ) =
          get_feat_ukeys_by_uname( $self->{db}, $ph{MS1f});
          if($genus eq '0' or $genus eq '2'){
            print STDERR "ERROR: could not find $ph{MS1f} in DB\n";
	    exit(0);
          }
	if(!exists($ph{MS1c})){
	    ($unique,$genus,$species,$type)=get_feat_ukeys_by_name($self->{db},$ph{MS1a}) ;
	    if($unique ne $ph{MS1f}){
		print STDERR "ERROR: name and uniquename not match $ph{MS1f}  $ph{MS1a} \n";
		exit(0);
	    }
	} 
	$unique=$ph{MS1f};
	if(!exists($ph{MS1a})){
	  print STDERR "ERROR: no MS1a field\n";
	}
        $feature = create_ch_feature(
            doc        => $doc,
            uniquename => $ph{MS1f},
            species    => $species,
            genus      => $genus,
            type       => $type,
            macro_id   => $ph{MS1f},
            no_lookup  => 1
				    );
        if ( exists( $ph{MS1h} ) && $ph{MS1h} eq 'y' ) {
            print STDERR "Action Items: delete moseg $ph{MS1f} == $ph{MS1a}\n";
            my $op = create_doc_element( $doc, 'is_obsolete', 't' );
            $feature->appendChild($op);
        
            $out.=dom_toString($feature);
        } 
        elsif ( exists( $ph{MS1c} ) ) {
	 if(exists($fbids{$ph{MS1c}})){
	     print STDERR "ERROR: Rename MS1c $ph{MS1c} exists in a previous proforma\n";
	 }
	 if(exists($fbids{$ph{MS1a}})){                                    
	     print STDERR "ERROR: Rename MS1a $ph{MS1a} exists in a previous proforma \n";
	 }  
	 print STDERR "Action Items: rename moseg $ph{MS1c} to $ph{MS1a}\n";
	 $feature->appendChild(
                create_doc_element(
                    $doc, 'name', decon( convers( $ph{MS1a} ) )
	     )
	     );
            $out.=dom_toString($feature);
            $out .= write_feature_synonyms( $doc, $unique, $ph{MS1a}, 'a',
                'FBrf0104946', 'symbol' );
            my $oldname = $ph{MS1c};
            my $newname = $ph{MS1a};
            $out .=
              moseg_name_change_action( $self->{db}, $doc, $oldname, $newname );
            
            $fbids{$ph{MS1c}}=$unique;
        }
        else{
            $out.=dom_toString($feature);
        }
        $fbids{$ph{MS1a}}=$unique;
      
    }
    elsif ( exists( $ph{MS1f} ) && $ph{MS1f} eq 'new' ) {
  
        ### if the temp id has been used before, $flag will be 1 to avoid
        ### the DB Trigger reassign a new id to the same symbol.
        if(!exists($ph{MS1g})){
            my $va=validate_new_name($db, $ph{MS1a});
               $flag=0;
             
             #  ($unique,$genus,$species,$type)=get_feat_ukeys_by_name($db,$ph{MS1a});
            #    $fbids{$ph{MS1a}}=$unique;
        }
       
        if(!exists($ph{MS16})){
           print STDERR "ERROR: must have MS16 for a new feature $ph{MS1a} \n";
        }
	my $feat_type = "";
	if($ph{MS1a}  =~ /^TI\{/){
	    $feat_type = "tp";
	}
	else{
	    $feat_type = $tp_feat_type{ $ph{MS16} };
        if ( !defined($feat_type) || $feat_type eq "" ) {
            print STDERR "ERROR: type key is '$ph{MS16}\n";
            foreach my $f ( keys %tp_feat_type ){
                my $val = $tp_feat_type{$f};
                print STDERR "ERROR:  '$f' ->  '$val'/n";
            }
        }	    
	}

       ( $unique, $flag ) =
          get_tempid( $feat_type, $ph{MS1a} );
        if(exists($ph{MS1g}) && $ph{MS1f} eq 'new' && $unique !~/temp/){
            print STDERR "ERROR: merge tps should have a FB..:temp id not $unique\n";
        }
        print STDERR "Action Items: new moseg $ph{MS1a}\n";
        #print STDERR "$unique, $flag\n";
        $genus   = 'synthetic';
        $species = 'construct';
        if(exists($ph{MS16})){
        $type = $ph{MS16};
        }
        else{
            print STDERR "ERROR: please fill in MS16 for a new transposon\n";
        }
         validate_cvterm($self->{db},$ph{MS16}, 'SO');
        if ( $flag == 0 ) {
            $feature = create_ch_feature(
                uniquename => $unique,
                name       => decon( convers($ph{MS1a} )),
                genus      => $genus,
                species    => $species,
                type       => $type,
                doc        => $doc,
                macro_id   => $unique,
                no_lookup  => '1'
            );
            $out.=dom_toString($feature);
           
	    $fbids{$ph{MS1a}}=$unique;
            $out.=write_feature_synonyms( $doc, $unique, $ph{MS1a}, 'a',
                'FBrf0104946', 'symbol' );
        }
        else{
         $out.=write_feature_synonyms( $doc, $unique, $ph{MS1a}, 'a',
                'FBrf0104946', 'symbol' );
            print STDERR "Warning, name $ph{MS1a} has been used in this load\n";
        }
    } 
    else{
      print STDERR "ERROR: MS1f must be new or an FBtp/FBmc\n";
    }     

     $doc->dispose();
    return ($out, $unique);
    }
# validate Moseg.
# 1. if MS1f is new, MS16 have to exists
# 2. validate name and uniquename matches, if new, should not be found
# in DB
# 3. validate featureprop, feature_relationship existence if !c
# 4. validate MS9a field, if segment name not found, ERROR! should be
# loaded later.
# 5. MS7e has not been implemented yet
sub validate {
    my $self   = shift;
    my $tihash = {@_};
    my %tival  = %$tihash;
    my $v_unique ='';
    print STDERR "Validating Moseg ", $tival{MS1a}, " ....\n";
    
    if(!exists($tival{MS1a})){
        print STDERR "ERROR: MS1a not exists\n";
    }
    
    if(exists($tival{MS1f}) && ($tival{MS1f} ne 'new')){
    validate_uname_name($db, $tival{MS1f}, $tival{MS1a});
    }

    if ( exists( $tival{MS7e} ) ) {
        print STDERR "ERROR: $tival{MS1a} MS7e not be implemented\n";
    }
    if ( exists( $fbids{$tival{MS1a}})){
        $v_unique=$fbids{$tival{MS1a}};    
    }
    else{
        print STDERR "ERROR: could not validate $tival{MS1a}\n";
        return;
    }
    if($v_unique =~/temp/){
        foreach my $f (keys %tival){
            if($f=~/(.*)\.upd/){
                print STDERR "ERROR: !c is not allowed for a new feature\n";
            }
        }
    }
    foreach my $f ( keys %tival ) {
        if($f eq 'MS19a' || $f eq 'MS19c' || $f eq 'MS20' || $f eq 'MS4h'){
             my @items = split( /\n/, $tival{$f} );
            foreach my $item (@items) {
                $item =~ s/^\s+//;
                $item =~ s/\s+$//;
                if($item =~/^FB\w{2}\d+/){
                    validate_uname($db,$item);
                    
                }
                else{ if(!exists($fbids{$item})){
                    validate_name($db,$item);
                    }
                }
            }
        }
        elsif( $f eq 'MS14' || $f eq  'MS4a' || $f eq  'MS4g' ){
             my @items = split( /\n/, $tival{$f} );
            foreach my $item (@items) {
                $item =~ s/^\s+//;
                $item =~ s/\s+$//;
                ($item)=split(/\s\|\s/,$item);
                
                validate_cvterm($db,$item, $tp_fpr_type{$f});
            }
        }
 
    
    elsif ( $f eq 'MS9'  && length( $tival{MS9} ) > 10 ) {
        my @items = split( /\n/, $tival{MS9} );
        foreach my $item (@items) {
            if ( $item =~ /^(\d+)\:(.*)\s+\[(?)\]/ ) {
                my $segname = $1;
                if(!exists($fbids{$segname})){
                my ( $s_unique, $s_genus, $s_species, $s_type ) =
                  get_feat_ukeys_by_name( $db, $segname );
                if ( $s_unique eq '0' || $s_unique eq '2') {
                    print STDERR "ERROR: ", $tival{MS1a},
                      ": MS9 could not found feature name as $segname\n";
                }
                }
            }
        }
    }
    }
    
    if ( !($v_unique=~/temp/) ) {
        foreach my $f ( keys %tival ) {
            if ( $f =~ /(.*)\.upd/ ) {
                $f = $1;
                if (   $f eq 'MS5a'
                    || $f eq 'MS19b'
                    || $f eq 'MS1e'
                    || $f eq 'MS5b'
                    || $f eq 'MS18a'
                    || $f eq 'MS4b'
                    || $f eq 'MS18b'
                    || $f eq 'MS10b'
                    || $f eq 'MS11' )
                {
                    my $num =
                      get_unique_key_for_featureprop( $db, $v_unique,
                        $tp_fpr_type{$f}, $tival{pub} );
                    if ( $num == 0 ) {
                        print STDERR
                          "ERROR: there is no previous record for $f field.\n";
                    }
                } 
                elsif ($f eq 'MS19a'
                    || $f eq 'MS19c'
                    || $f eq 'MS20'
                    || $f eq 'MS4h'
                    || $f eq 'MS9a' )
                {
						  my $object  = 'object_id';
						  my $subject = 'subject_id';
		              if ( $f eq 'MS20' || $f eq 'MS4h' ) {
							       $object  = 'subject_id';
				              $subject = 'object_id';
						    }
                    my $num =
                      get_unique_key_for_fr( $db,$subject,$object, $v_unique,
                        $tp_fpr_type{$f}, $tival{pub} );
                    if ( $num == 0 ) {
                        print STDERR
                          "ERROR: There is no previous record for $f field\n";
                    }
                }
            }
        }
    }
    else {
        foreach my $fu ( keys %tival ) {
            if ( $fu =~ /(.*)\.upd/ ) {
                print STDERR "ERROR: Wrong !c fields  $1 for a new record \n";
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

        elsif($f eq 'MS23a'){
        print STDERR "Warning: havenot implemented $f\n";
        }
        elsif($f eq 'MS23'){
        print STDERR "Warning: havenot implemented $f\n";
        }

# Below is stub documentation for your module. You'd better edit it!


=head1 SUPPORT

proformas can be found in http://flystocks.bio.indiana.edu/flybase/curation-docs/genetic-literature/

proforma mapping table can be found in ~haiyan/Documents/mosegmapping.sxw 

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
! MS. MOLECULAR SEGMENT AND CONSTRUCT PROFORMA       Version 24: 11 January 2007

! MS1f. Database ID for segment (FBid or "new") :new
! MS1a. Segment symbol to use in database       :
! MS1b. Symbol used in paper                    :
! MS16. Segment category (type of entity) [CV]  :transgenic_transposon

! MS4a. Description [CV]                        :transposon
! MS21. Transposon class (generic)              :
! MS14. Uses [CV]                               :
! MS22. Localized function [CV]                 :

! MS1c. Action - replace this segment symbol :
! MS1g. Action - merge these segment(s)      :
! MS1h. Action - delete segment record  ("y"/blank)    :
! MS1i. Action - dissociate MS1f from FBrf ("y"/blank) :

! MS3b. Other synonym(s) for segment symbol  :
! MS3d. Silent synonym(s) for segment symbol :
! MS3e. Bloomington symbol variant           :

! MS19a. Progenitor(s) [in FB] :
! MS19b. Progenitor(s) [other] :
! MS19c. Isolate of [generic natTE] :
! MS20.  Related constructs    :

! MS18a. Cloning sites [CV]    :
! MS4b.  Length in kb          :

! MS4h.  Component allele(s)         :
! MS4g.  Component features [CV]     :
! MS17.  Transcript (expression data):

! MS1e.  Type of DNA_segment [CV]              :
! MS4e.  Component segment source (species)    :
! MS5a.  Original left end (in + orientation)  :
! MS5b.  Original right end (in + orientation) :

! MS7a.  AC no. | gi no. | date | D or ND      :
!   MS7b.  Location of MS5a in database entry  :
!   MS7c.  Location of MS5b in database entry  :
! MS7e.  Comparable segment, sequenced strain  :
! MS12.  Sequence:

! MS9.  Segments in order | orientation :
1:
2:

! MS18b. Junction restriction sites | position :

! MS10b. General comments :
! MS11.  Internal notes   :
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

=head1 AUTHOR

Haiyan Zhang, E<lt>haiyan@morgan.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
