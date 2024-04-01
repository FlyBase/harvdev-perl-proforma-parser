package FlyBase::Proforma::Cell_line;

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
# names by default without a very very very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use FlyBase::Proforma::Cell_line ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.

#
#~emmert/work/gmod/schema/chado/cell_lines/work/init_cell_lines
#~emmert/work/gmod/schema/chado/cell_lines/work/newCLMac.pm 
our %EXPORT_TAGS = (
    'all' => [
        qw(

          )
    ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( process validate write_cell_line

);

our $VERSION = '0.01';

# Preloaded methods go here.

=head1 NAME

FlyBase::Proforma::Cell_line - Perl module for parsing the FlyBase
Cell Line  proforma version 1, Feb 2009.

See the bottom for the proforma
                         
=head1 SYNOPSIS

  use FlyBase::Proforma::Cell_line;
  use DBI;
  
  my $mdbh=DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";
  my %ph=(TC1a=>'AT',....);
  ###!c field implemented as '$fieldname.upd=>'c'' eg. 'LC6.upd'=>'c'
   
  #params db is manditory, debug and validate is optional
  my $pro=FlyBase::proforma::Cell_line->new(db=>$mdbh);
  $pro->validate(%ph);
  my $chadoxml = $pro->process(%ph);
  
  # or

  my $pro=FlyBase::Proforma::Cell_line->new(db=>$mdbh,debug=>1,validate=>1);
  my $chadoxml_string=$pro->process(%ph);

=head1 DESCRIPTION

FlyBase::Proforma::Cell_line is a perl module for parsing FlyBase
Cell_line proforma and write the result as chadoxml. It is required
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
    'TC1f', 'uniquename',
    'TC1a', 'symbol',
    'TC1b', 'symbol',
    'TC1c', 'symbol',
    'TC1j', 'DGRC_cell_line', ###cell_line_dbxref db = 'DGRC_cel_line' accession = decimal part of FBte0000000
    'TC1d', 'organism.abbreviation',###cell_line.organism_id
    
    'TC1e', 'rename',##action items
    'TC1g', 'merge', ## action items
#    'TC1h', 'delete',##action items
    'TC1i', 'dissociate_FBrf', ## action items
    
    'TC2a', 'source_strain',  ### cell_lineprop
    'TC2b', 'source_genotype',  ## cell_lineprop
    'TC2c', 'source_cross',  ## cell_lineprop
    'TC2d', 'FlyBase anatomy CV', ##cell_line_cvterm
    'TC2e', 'FlyBase development CV',  ##cell_line_cvterm
    
    'TC3a', 'lab_of_origin',  ##cell_lineprop
#    'TC4a', 'transformed_from',  ### parent cell_line_relationship.object_id on field mapping but check DB default cv = 'cell_line_relationship'
#    'TC4b', '',      #cell_line_relationship.type_id (isolate_of, targeted_mutant_from, cloned_from, selected_from, transformed_from)
    'TC5a', 'cell_line_feature', ###cell_line_feature FBti
    'TC5b', 'karyotype',      ###cell_lineprop   
    'TC5c',  'FlyBase miscellaneous CV',  ##cell_line_cvterm
    'TC5d', 'basis',  ##cell_line_cvtermprop
    'TC8', 'member_of_reagent_collection', #cell_line_library, cell_line_libraryprop    
    'TC9',  'comment', ## cell_lineprop
    'TC10', 'internalnotes' ##cell_lineprop
);

# 20160511 changed back to the cvterm.name of the cell_line_relationship 
our %clr_type = (
    'transformed_from', 1,
    'selected_from', 1,
    'cloned_from', 1,
    'targeted_mutant_from', 1,
    'isolate_of', 1
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
    my $genus   = '';
    my $species = '';
    my $type;
    my $out = '';
    
#    print STDERR "ERROR: first use of Cell_line proforma\n";
    if ( exists( $self->{debug} ) && $self->{debug} == 1 ) {
        foreach my $key ( keys %ph ) {
            print STDERR "$key, $ph{$key}\n";
        }
    }
    print STDERR "processing Cell_line proforma $ph{TC1a}...\n";

    if ( exists( $self->{v} ) && $self->{v} == 1 ) {
        $self->validate($tihash);
    }
    if(exists($fbids{$ph{TC1a}})){
        $unique=$fbids{$ph{TC1a}};
    }
    else{
#       print "ERROR: could not get uniquename for $ph{TC1a}\n";
      ($unique, $out)=$self->write_cell_line($tihash);
#        return $out;
    }

    if(exists($fbcheck{$ph{TC1a}}{$ph{pub}})){
        print STDERR "Warning: $ph{TC1a} $ph{pub} exists in a previous proforma\n";
    }
    $fbcheck{$ph{TC1a}}{$ph{pub}}=1;
    if(!exists($ph{TC1i})){
      print STDERR "Action Items: Cell line $unique == $ph{TC1a} with pub $ph{pub}\n"; 
        my $f_p = create_ch_cell_line_pub(
        doc        => $doc,
        cell_line_id => $unique,
        pub_id     => $ph{pub}
    );
    $out .= dom_toString($f_p);
    $f_p->dispose();
    }    
    else{
            $out .= dissociate_with_pub_fromcell_line( $self->{db}, $unique, $ph{pub} );
            print STDERR "Action Items: dissociate $ph{TC1a} with $ph{pub}\n";
            return $out;
        }
    ##Process other field in Trangenic Insertion proforma
    foreach my $f ( keys %ph ) {

        if (   $f eq 'TC1b'  || $f eq 'TC1c' )
        {  
          if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
            print STDERR "CHECK: first use !c for $f\n";
            print STDERR "Action Items: !c log,$ph{TC1a} $f  $ph{pub}\n";
              my $t=$f;
              $t=~s/TC1//;
              my $s_pub='unattributed';
              if($t eq 'b'){
                $s_pub=$ph{pub};
              }
              my $current='';
              if($t eq 'c'){
                $current='f';
              }
              $out .= delete_cell_line_synonym( $self->{db}, $doc, $unique, $s_pub, $fpr_type{$f}, $current );
	      # $out .=
              #        delete_cell_line_synonym( $self->{db}, $doc, $unique, $ph{pub}, $fpr_type{$f} );
            }
	  if(defined ($ph{$f}) && $ph{$f} ne ''){
	    my @items = split( /\n/, $ph{$f} );
            foreach my $item (@items) {
                if($item == $ph{'TC1a'}){
                    next;
                }
                $item =~ s/^\s+//;
                $item =~ s/\s+$//;
                my $t = $f;
                $t =~ s/TC1//;
                    my $tt     = $t;
                    my $s_type = 'symbol';
                    my $s_pub  = '';
                    if ( $t eq 'b' ) {
                        $s_pub = $ph{pub};
                        $tt    = 'b';
                        if($t eq 'b' && $item eq $ph{TC1a} ){
                            $tt='a';
                        }
                    }
                    else {
                        $s_pub = 'unattributed';    
                    }
                    $out .=
                      write_cell_line_synonyms( $doc, $unique, $item, $tt, $s_pub,
                        $s_type );
                }
	  }
        }
        elsif($f eq 'TC1e'){
              $out .=
                 update_cell_line_synonym( $self->{db}, $doc, $unique, $ph{$f}, 'symbol');    
              $fbids{$unique}=$ph{TC1a};
        
           }
        elsif ( $f eq 'TC1g' ) {
            my $tmp=$ph{TC1g};
            $tmp=~s/\n/ /g;
            if($ph{TC1f} eq 'new'){
            print STDERR "Action Items: merge Cell line $tmp\n";
            }
            else{
                print STDERR "Action Items: merge Cell line $tmp to $ph{TC1f} == $ph{TC1a} \n";
            }
            $out .= merge_cell_line_records( $self->{db}, $unique, $ph{$f},$ph{TC1a}, $ph{pub} );
          
        }
        elsif ($f eq 'TC2a'
            || $f eq 'TC9'
            || $f eq 'TC10'
            || $f eq 'TC2b'
            || $f eq 'TC2c'
            || $f eq 'TC5b'
            || $f eq 'TC3a'
			) 
        {
            if ( exists( $ph{ "$f.upd" } ) && $ph{ "$f.upd" } eq 'c' ) {
                  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                my @results =
                  get_unique_key_for_cell_lineprop( $self->{db}, $unique,
                    $fpr_type{$f}, $ph{pub} );
                foreach my $t (@results) {
                    my $num = get_cellprop_pub_nums( $self->{db}, $t->{fp_id} );
                    if ( $num == 1 || (defined($frnum{$unique}{$fpr_type{$f}}{$t->{rank}}) && $num-$frnum{$unique}{$fpr_type{$f}}{$t->{rank}}==1) ) {
                        $out .=
                          delete_cell_lineprop( $doc, $t->{rank}, $unique,
                            $fpr_type{$f} );
                    }
                    elsif ( $num > 1 ) {
                        $out .=
                          delete_cell_lineprop_pub( $doc, $t->{rank}, $unique,
                            $fpr_type{$f}, $ph{pub} );
                    }
                    else {
                        print STDERR "ERROR:something Wrong, please validate first\n";
                         $out .=
                          delete_cell_lineprop( $doc, $t->{rank}, $unique,
                            $fpr_type{$f} );
                    }
                }
            }
            if ( defined($ph{$f}) && $ph{$f} ne '' ) {
                my @items = split( /\n/, $ph{$f} );
                foreach my $item (@items) {
                    $item =~ s/^\s+//;
                    $item =~ s/\s+$//;
                    $out .=
                      write_tableprop( $self->{db}, $doc,"cell_line", $unique, $item,
                        $fpr_type{$f}, $ph{pub} );
                }
            }
        }
        elsif ($f eq 'TC2d' || $f eq 'TC2e' || $f eq 'TC5c') {
            if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
                  print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
                my @result =
                  get_cvterm_for_cell_line_cvterm( $self->{db}, $unique, $fpr_type{$f},
                    $ph{pub} );

                foreach my $item (@result) {
                    my ($cvterm, $obsolete)=split(/,,/,$item);
                    my $feat_cvterm = create_ch_cell_line_cvterm(
                        doc        => $doc,
                        cell_line_id => $unique,
                        cvterm_id  => create_ch_cvterm(
                            doc  => $doc,
                            cv   => $fpr_type{$f},
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
                    my $type='';
                    $item=~s/^\s//;
                    $item=~s/\s$//;
			       my $rc=validate_cvterm($self->{db},$item, $fpr_type{$f});
                   
                  my $f_cvterm = &create_ch_cell_line_cvterm(
                    doc        => $doc,
                    cell_line_id => $unique,
                    cvterm_id  => create_ch_cvterm(
                        doc  => $doc,
                        cv   => $fpr_type{$f},
                        name => $item
                    ),
                    pub_id => $ph{pub},
                );
                if($f eq 'TC5c' && exists($ph{'TC5d'}) && $ph{'TC5d'} ne ''){
                    my $rank=get_rank_for_cell_line_cvtermprop($self->{db},$unique, 'FlyBase miscellaneous CV', $item, $fpr_type{'TC5d'}, $ph{'TC5d'}, $ph{pub});
                    my $fcvprop=create_ch_cell_line_cvtermprop(
                        doc=>$doc,
                        value=>$ph{'TC5d'},
                        type=>$fpr_type{'TC5d'},
                        rank=>$rank);
                    
                    $f_cvterm->appendChild($fcvprop);
					  }
			   $out .= dom_toString($f_cvterm);
                $f_cvterm->dispose();
                }

                }
            }
        
        elsif($f eq 'TC5a'){
	  print STDERR "CHECK: $f first use \n";
	  if(exists($ph{"$f.upd"}) && $ph{"$f.upd"} eq 'c'){
	    print STDERR "CHECK: implemention !c$f \n";
	    my @result= get_feature_by_cell_line_pub($self->{db}, $unique,$ph{pub});
	    foreach my $item (@result) {
	      (my $fgen, my $fsp, my $ftype )=get_feat_ukeys_by_uname ($self->{db},$item);
	      if($ftype eq 'transposable_element_insertion_site' || $ftype eq 'transposable_element' ){
		my $clp=create_ch_cell_line_feature(doc=>$doc,
						  feature_id=>create_ch_feature(doc=>$doc, uniquename=>$item, genus=>$fgen, species=>$fsp,type=>$ftype,),
                         cell_line_id=>$unique,
                         pub_id=>$ph{pub},);
		$clp->setAttribute("op","delete");
		$out.=dom_toString($clp);
		$clp->dispose();
	      }
	    }
	  }
	  if(defined($ph{$f}) && $ph{$f} ne ''){
	      my @items = split( /\n/, $ph{$f} );
	      foreach my $item (@items) {
		  $item =~ s/^\s+//;
		  $item =~ s/\s+$//;
		  my $funame = $item;
		  print STDERR "CHECK: implemention multi $f cell_line $unique feature $funame\n";
		  
		  (my $fgen, my $fsp, my $ftype )=get_feat_ukeys_by_uname ($self->{db},$funame);
		  my $feat=create_ch_feature(
		      doc=>$doc,
		      uniquename=>$funame,
		      genus=>$fgen,
		      species=>$fsp,
		      type=>$ftype,
		      macro_id=>$funame,
		      );
		  $out.=dom_toString($feat);  
		  $fbids{ $ph{TC5a} } = $funame;	    
		  my $f_cl=create_ch_cell_line_feature(doc=>$doc,
						       cell_line_id=>$unique,
						       feature_id=>$feat,
						       pub_id=>$ph{pub},);
		  $out.=dom_toString($f_cl);
	      }  
	  }
	}
	elsif($f eq 'TC4a'){
          my $object  = 'object_id';
          my $subject = 'subject_id';
	  if ( exists( $ph{"$f.upd"} ) && $ph{"$f.upd"} eq 'c' ) {
	    print STDERR "Action Items: !c log, $unique $f $ph{pub}\n";
	    my @results=
	      get_unique_key_for_clr( $self->{db}, $subject, $object,
					       $unique );
		      
	    foreach my $ta(@results){
#                        my $num = get_clr_pub_nums( $self->{db}, $ta->{fr_id} );
#                        if ( $num == 1  || (defined($frnum{$unique}{$ta->{name}}) && $num-$frnum{$unique}{$ta->{name}}==1)) {
                            $out .=
                              delete_cell_line_relationship( $self->{db}, $doc,
                                $ta, $subject, $object, $unique);
#                        }
 #                       elsif ( $num > 1 ) {
#                            $out .=
#                              delete_cell_line_relationship_pub( $self->{db},
#                                $doc, $ta, $subject, $object, $unique,, $ph{pub});
#                        }
#                        else {
#                            print STDERR "ERROR: $f something Wrong, please validate first\n";
#                        }
		      }   
                  }
	  if(defined($ph{$f}) && $ph{$f} ne ''){
	    if(!exists($ph{TC4b})){
	      print STDERR "ERROR: $f something Wrong, need value in TC4b\n";
	    }
	    elsif(!exists $clr_type{$ph{TC4b}}){
	      print STDERR "ERROR: $f something Wrong,with value in TC4b $ph{TC4b}\n";
	    }
	    else{
	      my @items=split(/\n/,$ph{$f});
	      foreach my $item(@items){
		$item =~ s/^\s+//;
		$item =~ s/\s+$//;
		my ($fr) = write_cell_line_relationship(
                            $self->{db},      $doc,    $subject,
                            $object,          $unique, $item,
                            $ph{TC4b}, 
							     );
		$out.=dom_toString($fr);                    
	      }
	    }
	  } 
	}
      elsif ($f eq 'TC8'){
	print STDERR "CHECK: use of TC8\n";
	
	if( exists($ph{"$f.upd"}) && $ph{ "$f.upd" } eq 'c' ) {
	  print STDERR "Action Items: !c log $unique $f $ph{pub}\n";
	  print STDERR "CHECK: use of  $f !c \n";
	  my @result = get_library_for_cell_line_library($self->{db}, $unique, $ph{pub}, $fpr_type{$f});
	  foreach my $item (@result) {
	    my ($lg,$ls,$lt)=get_library_ukeys_by_uname($self->{db},$item);	    
	    my $clp=create_ch_cell_line_library(doc=>$doc,
                         library_id=>create_ch_library(doc=>$doc, uniquename=>$item, genus=>$lg, species=>$ls, type=>$lt,),
                         cell_line_id_id=>$unique,
			 pub_id=>$ph{pub},
			);
	    $clp->setAttribute("op","delete");
	    $out.=dom_toString($clp);
	  }
	}
	if ( defined($ph{$f}) && $ph{$f} ne '' ) { 
	  my @items = split( /\n/, $ph{$f} );
	  foreach my $item (@items) {
	    $item =~ s/^\s+//;
	    $item =~ s/\s+$//;
	    print STDERR "DEBUG: TC8 $item\n";
	    
	    my ($lu,$lg,$ls,$lt)=get_lib_ukeys_by_name($self->{db},$item);
	    if(defined($lu) && defined($lg) && defined($ls) && defined($lt)){
	      my $cl=create_ch_cell_line_library(
					      doc=>$doc,
					      library_id=>create_ch_library(doc=>$doc, uniquename=>$lu, genus=>$lg, species=>$ls, type=>$lt),
					      cell_line_id=>$unique,
					      pub_id=>$ph{pub},
					     ); 
	      my $clp = create_ch_cell_line_libraryprop(
					       doc=>$doc,
					       type_id=>create_ch_cvterm(
									 doc  => $doc,
									 name => $fpr_type{$f},
									 cv   => "cell_line_libraryprop type",
									),
					       );
	      $cl->appendChild($clp);    
	      $out.=dom_toString($cl);
	    }
	    else{
	      print STDERR "ERROR:  unique key missing for $f $item\n";
	    }
	  }
	}
      }              

      }
  $doc->dispose();
    return $out;
}
=head2 $pro->write_cell_line(%ph)
  separate the id generation and lookup from the other curation field to make two-stage parsing possible
=cut
sub write_cell_line{
    my $self    = shift;
    my $tihash  = {@_};
    my %ph      = %$tihash;
    my $unique  = '';
    my $flag    = 0;
    my $feature = '';
    my $genus='';
    my $species='';
    my $type;
    my $out = '';
 
    if($ph{TC1f} eq 'new') {
       
       my $va=validate_new_name($db, $ph{TC1a}, 'cell_line');
       
       if($va==1 && !exists($ph{TC1g})){
          $flag=0;
          ($unique,$genus,$species)=get_cell_line_ukeys_by_name($db,$ph{TC1a});
          $fbids{$ph{TC1a}}=$unique;
       }
       elsif($va==0 && exists($ph{TC1j})){
        $unique=$ph{TC1j};   
        $flag=0;
       }
       else{
            print STDERR "Action Items: new Cell line $ph{TC1a}\n";
            ( $unique, $flag ) = get_tempid( 'tc', $ph{TC1a} );
            
            if(exists($ph{TC1g}) && $ph{TC1f} eq 'new' && $unique !~/temp/){
              print STDERR "ERROR: merge cell_line should have a FB..:temp id not $unique\n";
            }  
       }
        if (! exists( $ph{TC1d} ) ) {
	    print STDERR "ERROR: TC1d must be filled in for new $ph{TC1a}\n";
	    exit(0);
	}
       else{
	   ( $genus, $species ) =
	       get_organism_by_abbrev( $self->{db}, $ph{TC1d} );
	   if($genus eq '0'){
               print STDERR "ERROR: could not get genus for cell line $ph{TC1a}\n";
               exit(0);
	   }
       }
       if ( $flag == 0 ) {
	   if(exists($ph{TC1j}) && $ph{TC1j} ne ''){
	       $feature = create_ch_cell_line(
		   uniquename => $unique,
		   name       => decon( convers( $ph{TC1a} ) ),
		   genus      => $genus,
		   species    => $species,
		   doc        => $doc,
		   no_lookup =>1,
		   macro_id   => $unique
		   );

	   }
	   else{
	       $feature = create_ch_cell_line(
		   uniquename => $unique,
		   name       => decon( convers( $ph{TC1a} ) ),
		   genus      => $genus,
		   species    => $species,
		   doc        => $doc,
		   macro_id   => $unique
		   );
	   }
	   $fbids{$ph{TC1a}}=$unique;

	   $out.=dom_toString($feature);
	   if(exists($ph{TC1j}) && $ph{TC1j} ne ''){
	       my $cdd=create_ch_cell_line_dbxref(doc=>$doc,
						  cell_line_id=>$unique, 
						  dbxref_id=>create_ch_dbxref( doc=>$doc,
									       db_id=>create_ch_db(doc=>$doc, 
												   name=>'FlyBase'),
									       accession=>$unique,
									       no_lookup=>1 
						  ),
						  is_current=>'t'
		   );   
               # print STDERR dom_toString($cdd);
	       $out.=dom_toString($cdd);
	       if ($ph{TC1f} eq 'new'){
		   my $dbxref = "";
		   if ($unique =~ /^FBtc9[0-9]{6}$/){
		       print STDERR "DEBUG, name $ph{TC1a} uniquename = $ph{TC1j} ($unique) NOT DGRC_cell_line\n";
#		       next;
		   }
		   else{
		       $unique =~ /^FBtc(\d+)$/;
		       $dbxref = $1;
		       print STDERR "DEBUG, name $ph{TC1a} uniquename = $ph{TC1j} ($unique) DGRC ID = DGRC_cell_line:$dbxref\n";
		       my $cdx=create_ch_cell_line_dbxref(doc=>$doc,
						      cell_line_id=>$unique, 
						      dbxref_id=>create_ch_dbxref( doc=>$doc,
										   db_id=>create_ch_db(doc=>$doc, name=>'DGRC_cell_line'),
										   accession=>$dbxref,
										   no_lookup=>1 
						      ),
						      is_current=>'t'
			   );   
               # print STDERR dom_toString($cdx);
		       $out.=dom_toString($cdx);
		   }
	       }
	   }
	   $out .=
	       write_cell_line_synonyms( $doc, $unique, $ph{TC1a}, 'a',
                'unattributed', 'symbol' );
       }
       else{
	   print STDERR "ERROR, name $ph{TC1a} has been used in this load\n";
       }
    }
 
    elsif($ph{TC1f} ne 'new'){   
        if(defined($fbids{$ph{TC1a}}) && !exists($ph{TC1e}) && !exists( $ph{TC1g} ))    {
	    $unique=$fbids{$ph{TC1a}};
	    if($unique ne $ph{TC1f}){
		print STDERR "ERROR: something is wrong! previously used uniquename $unique != $ph{TC1f} for $ph{TC1a} Harvcur maybe clash with gene proforma and same symbol hold back file with $ph{TC1f} / $ph{TC1a} and resubmit after file with $unique loaded\n";
		exit(0);
	    }
	}
	else{
	    ( $genus, $species) =
		get_cell_line_ukeys_by_uname( $self->{db}, $ph{TC1f} );
	    if(!exists($ph{TC1e})){
		($unique,$genus,$species)=get_cell_line_ukeys_by_name($self->{db},$ph{TC1a}) ;
		if($unique ne $ph{TC1f}){
		    print STDERR "ERROR: name and uniquename not match $ph{TC1f}  $ph{TC1a} \n";
		    exit(0);
		}
	    }
	    $unique=$ph{TC1f};
	    if(exists($ph{TC1a})){
		$fbids{$ph{TC1a}} = $unique;
	    }
	    else{
		print STDERR "ERROR: no TC1a field\n";
	    }
	    $feature = create_ch_cell_line(
		doc        => $doc,
		uniquename => $unique,
		species    => $species,
		genus      => $genus,
		macro_id   => $unique,
		no_lookup =>1,
		);
	    if ( exists( $ph{TC1h} ) && $ph{T1h} eq 'y' ) {
		print STDERR "ERROR: TC1h NOT implemented! Would need change to chado ddl, WriteChado, IU dumpspecs/scripts and alert GMOD to change in ddl to add is_obsolete and set all to default false before can use\n";
#            my $op = create_doc_element( $doc, 'is_obsolete', 't' );
#            $feature->appendChild($op);
	    }
	    elsif(exists($ph{TC1e})){
		print STDERR "Action Items: rename $ph{TC1f} from $ph{TC1e} to $ph{TC1a}\n";
		my $va=validate_new_name($db, $ph{TC1a}, 'cell_line');

		my $n=create_doc_element($doc,'name',decon(convers($ph{TC1a})));
		$feature->appendChild($n);
		$out.=dom_toString($feature);
		$out .=
		    write_cell_line_synonyms( $doc, $unique, $ph{TC1a}, 'a',
					      'unattributed', 'symbol' );
		$fbids{$ph{TC1e}}=$unique;
	    }
	    else{
		$out.=dom_toString($feature);
	    }
	}
    }
    else{
	print STDERR "ERROR: could not find $ph{TC1f} in database\n";
    }
     #  if(exists($ph{TC1h})){
     #   feature->setAttribute('op','delete');
     #  }
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
 
    print STDERR "validating Cell_Line ", $tival{TC1a}, "\n";
    
    if(exists($tival{TC1f}) && ($tival{TC1f} ne 'new')){
        validate_uname_name($db, $tival{TC1f}, $tival{TC1a});
    }
    if ( exists( $fbids{$tival{TC1a}})){
        $v_unique=$fbids{$tival{TC1a}};    
    }
    else{
        print STDERR "ERROR: could not validate $tival{TC1a}\n";
        return;
    }
    
        foreach my $f ( keys %tival ) {
          if($f eq 'LC4c'){
            my @items=split(/\n/,$tival{$f});
            foreach my $item(@items){
                   $item=~s/\s+$//;
                   $item=~s/^\s+//;  
                   
                   validate_cvterm($db,$item,$fpr_type{$f});
             }
           }
            if ( $f =~ /(.*)\.upd/ && !($v_unique=~/temp/) ) {
                $f = $1;
                if (  $f eq 'LC10'
            || $f eq 'LC9'
            || $f eq 'LC8a'
            || $f eq 'LC8b'
            || $f eq 'LC7b'
            || $f eq 'LC7a'
            || $f eq 'LC6b'
            || $f eq 'LC6a'
            || $f eq 'LC5'
            || $f eq 'LC4e'
            || $f eq 'LC4b'
            || $f eq 'LC4d')
                {
                    my $num =
                      get_unique_key_for_featureprop( $db, $v_unique,
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
! CULTURED CELL LINE PROFORMA            Version 1:   Feb 2009
!
! TC1f. FB ID for cell line (FBtc or "new")  :
! TC1a. Cell line symbol to use in database  :
! TC1b. Symbol used in paper/source          :
! TC1c. Symbol synonym   (free text)         :
! TC1d. Species of source [CV]               :
!
! TC1e. Action - rename this cell line         :
! TC1g. Action - merge these cell lines        :
! TC1h. Action - delete cell line record ("y"/blank)  :
! TC1i. Action - dissociate TC1f from FBrf ("y"/blank):
!
! TC2a. Source strain (soft CV)            :
! TC2b. Source genotype (components in FB) :
! TC2c. Source cross  (components in FB)   :
! TC2d. Tissue source  [CV]                :
! TC2e. Developmental stage of source [CV] :
!
! TC3a. Lab of origin (free text) :
! TC4a. Parental cell line (valid FBtc symbol)    :
!   TC4b. Derived from parental line by (free text) :
!
! TC5a. Integrated construct insertion (FBti symbol) :
! TC5b. Karotype (free text)      :
! TC5c. Sex ("male" or "female")  :
!   TC5d. Basis for sex (free text) :
!
! TC9.  Comment(s) (free text)       :
! TC10. Internal note(s) (free text) :
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


=head1 AUTHOR

Haiyan Zhang, E<lt>haiyan@morgan.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Haiyan Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
