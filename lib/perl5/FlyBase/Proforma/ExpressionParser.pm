package FlyBase::Proforma::ExpressionParser;

# contains functions to parse tap statements and convert them into feature_expression
# XML::DOM elements
use strict;
use warnings;
use FlyBase::Proforma::Assays;
use FlyBase::Proforma::Util;
use Digest::MD5 qw(md5_hex);
require Exporter;
use Carp qw(croak);
our @ISA = qw(Exporter);
use FlyBase::WriteChado;

# This allows declaration       use
# FlyBase::Proforma::ExpressionParser ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = (
     'all' => [
             qw(
     parse_tap
                       )
                           ]
                           );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( parse_tap );

=head1 NAME

  ExpressionParser.pm - A module containing functions to turn proforma tap statements
                        into expression, feature_expression, library_expression 
                        or interaction_expression chado-xml elements

=head1 SYNOPSIS

 use XML::DOM;
 use WriteChadoMac;
 use PrettyPrintDom;
 use ExpressionParser;

 $doc = new XML::DOM::Document;

 $expression_el = parse_tap(doc => $doc,
                            db => $database_handle,
                            tap => 'tap statement string',
                            check_cvterms => 1,
                            FBdv => \%FBdv,
                            );

  pretty_print($expression_el,\*STDOUT);


 $feature_expression_el = parse_tap(doc => $doc,
                                    db => $database_handle,
                                    feature_id => $feature,
                                    pub_id => $pub,
                                    tap => 'tap statement string',
                                    check_cvterms => 1,
                                    FBdv => \%FBdv,
                                    );

  pretty_print($feature_expression_el,\*STDOUT);

 $library_expression_el = parse_tap(doc => $doc,
                                    db => $database_handle,
                                    library_id => $library,
                                    pub_id => $pub,
                                    tap => 'tap statement string',
                                    check_cvterms => 1,
                                    FBdv => \%FBdv,
                                    );

  pretty_print($library_expression_el,\*STDOUT);

  $interaction_expression_el = parse_tap(doc => $doc,
                                         db => $database_handle,
                                         interaction_id => $interaction,
                                         pub_id => $pub,
                                         tap => 'tap statement string',
                                         check_cvterms => 1,
                                         FBdv => \%FBdv,
                                        );

  pretty_print($interaction_expression_el,\*STDOUT);

  parse_tap is the method to call to get a fully formed expression, feature_expression 
  or library_expression XML::DOM element that implements the tap statement into the 
  expression tables unless that expression already exists (which is checked based on 
  the md5checksum generated for the parsed tap statement and compared to those already 
  in the db

  you need to pass as parameters:
  - a XML::DOM Document object
  - a live database handle to check for existing expressions (and to check for cvterm
      validity if the check_cvterms parameter is set to true)

  optionally
  - a XML::DOM feature or library element or an id that refers to such an element
  - a XML::DOM pub element or an id that refers to such an element
  - a hashref to a hash keyed by FBdv cvterms with the
    cvterm_ids as values - this facilitates some validation and checking and is recommended
    but will do live check on db now as long as database handle is passed as parameter

  NOTE: if you create a stand alone expression element then neither the curated tap statement
        nor the <note> fields will be converted into the *_expressionprop elements that you
        will get if you provide feature, library or interaction info
      

  This module contains the following functions:
  parse_tap
  check_exp_ds
  create_term_list
  tap2hash
  parse_assay
  parse_dev_stage
  parse_stage
  expression_from_tap
  parse_anat_cc
  create_expression_dom
  check4expression
  generate_checksum
  by_term_qual
  get_term_info_by_cv
  _get_numbers_at_end
  expand_stage_root
  decompose_stage
  by_stage
  expand_egg
  expand_adult
  expand_pupal
  expand_oogenesis
  expand_larval
  expand_embryo
  check_qualifiers
  parse_number_bits
  get_range
  _get_subclass_range
  _get_letter_range
  check_comparator
  check_range
  trim

  fuller descriptions to follow

=head1 AUTHOR

Andy Schroeder - andy@morgan.harvard.edu

=head1 SEE ALSO

Assays, WriteChadoMac, PrettyPrintDom,  XML::DOM, 

=cut

#our %ASSAYS = %Assays::ASSAYS;

# simple lookup tables and stage ordering
our %stages =  (egg => 'egg stage',
		E => 'embryonic stage',
		L => 'larval stage',
		PP => 'prepupal stage',
		P => 'pupal stage',
		PA => 'pharate adult stage',
		'P-stage' => 'P-stage',
		A => 'adult stage',
		O => 'oogenesis',
		S => 'spermatogenesis',
	       );
our %stage2abbr = reverse %stages;
our @stage_order = qw(E L PP P PA A);

our %seen_md5s;
our $crank = 0;
our $tmpcnt = 1; # counter for temp ids

# top level function to parse a tap statement
sub parse_tap {
  my %params = @_;


  print STDERR "ERROR: you are missing a required parameter - NO GO!\n" and return
    unless ($params{db} and $params{doc} #and ($params{feature_id} or $params{library_id}) and $params{pub_id}
	    and $params{tap});

  my $dbh = $params{db};

  my $tap = $params{tap};
#  delete $params{tap};

  # have an option to include the terms in the FlyBase development CV which
  # allow lookups so that curations can include  any valid development term 
  # (not dependent on shorthand or just the simple terms
  my $fbdv;
  if ($params{FBdv}) {
    $fbdv = $params{FBdv};
    delete $params{FBdv};
  }

  my $ex = expression_from_tap($tap, $fbdv, $dbh);
#  print "$tap\n";
#  print Dumper($ex);
  print STDERR "ERROR: couldn't parse statement\n\t\"$tap\"\n" and return unless $ex;

  # quick sanity check on the structure of the expression data structure
  # - there needs to be a defined term at least in each existing slot
  my $ok = check_exp_ds($ex);
  print STDERR "ERROR: problem with expression data structure - missing or duplicated term!\n\t$tap\n" 
    and return unless $ok;

#  print Dumper($ex);


  $params{exp} = $ex;

  # add an optional cvterm check?
  if ($params{check_cvterms}) {
    my %exterms = create_term_list($ex);
    my $badterm;
    my $t_query = $dbh->prepare
      (sprintf
       ("SELECT count(distinct cvterm_id)
         FROM   cvterm c, cv
         WHERE  c.name = ? and c.cv_id = cv.cv_id
           and  c.is_obsolete = 0 and cv.name = ?"));
    foreach my $t (keys %exterms) {
      $t_query->bind_param(1, $t);
      $t_query->bind_param(2, $exterms{$t});
      $t_query->execute or die "Can't do cvterm check";
      (my $cnt) = $t_query->fetchrow_array();

      unless ($cnt == 1) {
	print STDERR "ERROR: $t is not a valid term in $exterms{$t}\n";
	$badterm = 1;
      }
    }
    return if $badterm;
    delete $params{check_cvterms};
  }

  my $f_e_dom = create_expression_dom(%params);
  return $f_e_dom;

}

# quick sanity check so don't bomb on problem with expression data structure
sub check_exp_ds {
  my %ex = %{+shift};
#  print Dumper(\%ex);

  foreach my $sl (keys %ex) {
    my %slterms; # tracker for repeated terms in a slot
    if ($sl eq 'comment') {
      print STDERR "Undefined comment\n" and return unless defined($ex{$sl});
    } else {
      foreach my $t (@{$ex{$sl}}) {
	print STDERR "Empty term\n" and return unless (defined($t->{term}) and $t->{term} !~ /^\s*$/);
#	print STDERR "REPEATED term\n" and return if $slterms{$t->{term}};
	$slterms{$t->{term}} = 1;
      }
    }
  }
  return 1;
}


# helper to gather all cvterms from an expression list with the expected cv as value
sub create_term_list {
  my %ex = %{+shift};

  my %terms;
  # mapping hash
  my %SLOT2CV = (
		 assay => 'experimental assays',
		 stage => 'FlyBase development CV',
		 anatomy => 'FlyBase anatomy CV',
		 cellular => 'cellular_component',
		 qualifier => 'FlyBase miscellaneous CV',
		 operator => 'expression_cvterm property type',
		);

  foreach my $sl (keys %ex) {
    next if $sl eq 'comment'; # skip comments
    foreach my $t (@{$ex{$sl}}) {
      if ($t->{term}) {
	$terms{$t->{term}} = $SLOT2CV{$sl};
      }
      if ($t->{qualifier}) {
	foreach my $q (@{$t->{qualifier}}) {
	  next if $q =~ /(OF|FROM|TO)/;
	  $terms{$q} = $SLOT2CV{qualifier};
	}
      }
    }
  }

  return %terms;
}

# will take individual tap statements and put them in a hash structure with 
# tag letters as keys and values as values
# NOTE: will change <as> tag to <e> for convenience but think about doing this wholesale
# arg is individual tap string
# return hash
sub tap2hash {
    my $prop = shift;
    $prop =~ s/<as>/<e>/g;
    $prop =~ s/<note>/<n>/g;

    if ($prop =~ /<p>.*\w+.*<s>/ or $prop =~ /<p>.*\w+.*!<.*$/) {
      # there is something in the p field
      if ($prop =~ /<a>\s*<p>/) { # case where empty <a> with <p> qualifier
	$prop =~ s/<p>/organism \|/;
      } elsif ($prop =~ /<a>.*\|.*\w.*<p>/) {
	$prop =~ s/<p>/ & /;
      } else {
	$prop =~ s/<p>/ \| /;
      }
    }
    $prop = trim($prop);
    return unless $prop; #something is messed up with prop i.e. no tags so return

    # this split keeps the letter designators but removes the <> bits
    # also puts undef on beginning of result array so shift if off
    my @pieces = split /<([tapsclen])>/, $prop;
    shift @pieces;
    return unless @pieces;
    @pieces = trim(@pieces);
    if (@pieces % 2) { 
	pop @pieces; # this bit just removes a tag with no value so array has even number
    }

    my %terms;
    for (my $i=0; $i <= $#pieces-1; $i+=2) {
	$terms{$pieces[$i]} = $pieces[$i + 1] if $pieces[$i + 1] !~ /^\s*$/;
    }
    return %terms;
}

# checks for assay abbreviation and returns a list of full assay terms
# multiple assays must be comma separated
# mix of full and abbreviations are OK
# arg is the assay string
# return arrayref of assays sorted alpha
sub parse_assay {
  my $assay = shift;
#  my %ASSAYS = %{+shift};
  my @assays; # to return
  $assay = trim($assay);
  return unless $assay;
  if ($assay =~ /(yeast hybrid \(one, two, three\))/) {
    $assay =~ s/$1/yh/g;
  }

  if ($assay =~ /(transfection assay, non-insect cells)/) {
    $assay =~ s/$1/tani/g;
  }

  if ($assay =~ /(RNase protection, primer extension, SI map)/) {# | RNase protection,  primer extension,  SI map)/) {
    $assay =~ s/$1/rp/g;
  }

  if ($assay =~ /(RNase protection,  primer extension,  SI map)/) {
    $assay =~ s/$1/rp/g;
  }


  my @bits = trim(split ',', $assay);
  foreach my $a (@bits) {
    if ($ASSAYS{$a}) {
      push @assays, {term => $ASSAYS{$a}};
    } elsif (grep $_ eq $a, values %ASSAYS) {
      push @assays, {term => $a};
    } else {
      return;
    }
  }

  my @toreturn;
  foreach my $as (sort {$a->{term} cmp $b->{term}} @assays) {
    push @toreturn, $as;
  }
  return \@toreturn;
}


# will expand shorthand dev syntax or check longhand cvterms
# and convert to a data structure that can be converted to 
# appropriate expression chado-xml
sub parse_dev_stage {
  my $term = shift;
  my $fbdv; my $dbh;
  $fbdv = shift;
  $dbh = shift;
  my %FBdv;
  %FBdv = %{$fbdv} if defined($fbdv); # a hashref to valid cvterms
  $term = trim($term);
  my @stage_info; # ordered list of hashrefs of expanded stages with qualifiers
                  # this or a ref to this will be the returned datastructure
  my %stage_tracker; # tracking hash for intermediate processing prior to producing
                     # final returned array of hash structure

  # simple check to make sure value is present
  if ($term =~ /^\s*$/) {
    print STDERR "NO TERM TO CHECK!\n";
    return;
  }

  # these next two bits check for very simple stage formats so as to avoid
  # all the other rigaramole
  if (%FBdv and $FBdv{$term}) {
    # it's a valid FBdv term already
    return [{term => $term}]; # array of hashref
  } elsif (defined $dbh) {
    my $id;
    ($id) = $dbh->selectrow_array
      (sprintf
       ("SELECT cvterm_id FROM cvterm WHERE name = '$term'"));
    return [{term => $term}] if (defined $id);
  }

  my $simplestage;
  $simplestage = expand_stage_root($term);
  return [{term => $simplestage}] if defined $simplestage;

  # split up the stage into various range or list bits keeping the
  # separators as part of the list
  my @st_parts = trim(split /(--|&&)/, $term);

  # check if only a single term
  if (scalar @st_parts == 1) {
#    print "CHECKING SINGLE TERM\n";
    # don't need to worry about lists or ranges
    my @parsed = parse_stage($st_parts[0], \%FBdv, $dbh);
    if (! @parsed) {
      print STDERR "PROBLEM PARSING $term\n";
      return;
    } elsif (scalar @parsed == 1) {
#      print "RETURNING SINGLE VALUE\n";
      return \@parsed;
    } else {
#      print "RETURNING FIRST AND LAST\n";
      return [$parsed[0], $parsed[-1]];
    }
  } else {
    my @list;
    my $i = 0;
    while ($i < @st_parts) {
      if ($st_parts[$i] eq '--') {
	my %range;
	print STDERR "PROBLEM WITH STAGE -- $term" and return
	  unless ($st_parts[$i - 1] and $st_parts[$i + 1]);
	$range{from} = $st_parts[$i - 1];
	$range{to} = $st_parts[$i + 1];
	shift @list;
	push @list, \%range;
	$i = $i + 2;
      } elsif ($st_parts[$i] eq '&&') {
	$i++;
	next;
      } else {
	push @list, $st_parts[$i];
	$i++;
      }
    }

    # now process each single bit of the list and add to array to return
    my @stageterms;
    my $problem;
    foreach my $stage (@list) {
#      print "$stage\n";
      if (ref($stage) eq 'HASH') {
	# deal with the from and to bits
	my @from = parse_stage($stage->{from}, \%FBdv, $dbh);
	my @to = parse_stage($stage->{to}, \%FBdv, $dbh);
	print STDERR "Problem with range format, more than one term returned for first or last term\n"
	  and return unless (@from and @to and scalar @from == 1 and scalar @to == 1);
	unshift @{$from[0]{qualifier}}, 'FROM';
	unshift @{$to[0]{qualifier}}, 'TO';
	push @stageterms, $from[0];
	push @stageterms, $to[0];
      } else {
	# deal with the bit
	my @parsed = parse_stage($stage, \%FBdv, $dbh);

	if (! @parsed) {
	  print STDERR "NO TERM IDENTIFIED\n";
	  push @stageterms, undef;
	  $problem = 1;
	} elsif (scalar @parsed == 1) {
	  push @stageterms, $parsed[0];
	} else {
	  my $from = $parsed[0];
	  my $to = $parsed[-1];
	  unshift @{$from->{qualifier}}, 'FROM' unless (grep $_ eq 'FROM', @{$from->{qualifier}});
	  unshift @{$to->{qualifier}}, 'TO' unless (grep $_ eq 'TO', @{$to->{qualifier}});;
	  push @stageterms, $from;
	  push @stageterms, $to;
	}	
      }
    }
    return \@stageterms if @stageterms and ! $problem;
    print STDERR "PROBLEM WITH STAGE: $term\n" and return;
  }
}

sub parse_stage {
  my $stage = shift;
  my $fbdv; my $dbh;
  $fbdv = shift;
  $dbh = shift;
  my %FBdv;
  %FBdv = %{$fbdv} if defined($fbdv); # a hashref to valid cvterms

#  print "PARSING STAGE $stage\n";
  (my $st, my $qual) = trim(split '\|', $stage, 2);
  my %sds;
#  print "WHICH HAS stage = $st and qual = $qual\n";

  if (%FBdv and $FBdv{$st}) {
    # stuff before pipe (note there may not be a pipe at all) is a valid FBdv term
    unless (grep $st eq $_, values %stages) {
      $sds{term} = $st;
    }
  } else {
    print "WORKING ON STAGE $st\n";
    if (defined $dbh) {
      my $id;
      ($id) = $dbh->selectrow_array
	(sprintf
	 ("SELECT cvterm_id FROM cvterm WHERE name = '$st'"));
      if (defined $id) {
	unless (grep $st eq $_, values %stages) {
	  $sds{term} = $st;
	}
      } else {
	$st = expand_stage_root($st);
      }
    } else {
      $st = expand_stage_root($st);
      print STDERR "Can't identify proper stage for $stage\n" and return unless defined($st);
    }
  }

  my @expanded;
  # if we get here we have a valid stage root
  if (! $sds{term}) {
    # we need to possibly expand root term based on qualifier
    if (defined($qual)) {
      if ($st eq 'embryonic stage') {
	# expand embryonic stage
	@expanded = expand_embryo($st, $qual);
      } elsif ($st eq 'larval stage') {
	# expand larval stage
	@expanded = expand_larval($st,$qual);
      } elsif ($st eq 'oogenesis') {
	# expand oogenesis stage
	@expanded = expand_oogenesis($st,$qual);
      } elsif ($st =~ /pupal/ or $st eq 'pharate adult stage' or $st eq 'P-stage') {
	# expand pupal stages
	@expanded = expand_pupal($st,$qual);
      } elsif ($st eq 'adult stage') {
	@expanded = expand_adult($st,$qual);
      } elsif ($st eq 'egg stage') {
	@expanded = expand_egg($st,$qual);
      } elsif ($st eq 'spermatogenesis') {
	@expanded = ({term => 'spermatogenesis'})
      } else {
	print STDERR "INVALID qualifier for UNRECOGNIZED STAGE\n";
      }
    } else {
      # no qualifier so we're all done
      $sds{term} = $st;
      return (\%sds);
    }
  } else {
    if (defined($qual)) {
      $sds{qualifier} = [$qual];
    }
    return (\%sds);
  }

  if (@expanded) {
    if (scalar @expanded == 1) {
      return @expanded;
    } else {
      unshift @{$expanded[0]->{qualifier}}, 'FROM';
      unshift @{$expanded[-1]->{qualifier}}, 'TO';
      # assuming that comma delineation of discontinuous stages is not allowed
      return ($expanded[0], $expanded[-1]);
    }
  } else {
    return;
  }
}

# parses single tap statement into component bits
# separating terms from qualifiers and terms from terms
# 
sub expression_from_tap {
  my $statement = shift;
  my $fbdv; my $dbh;
  $fbdv = shift;
  $dbh = shift;
  my %expression;

  print STDERR "WARNING -- missing statement - returning!\n" and return
    unless $statement;

  my %tap = tap2hash($statement);

  print STDERR "WARNING -- problem with initial tap parsing!\n" and return unless %tap;

  if ($tap{e}) {
    my $assays = parse_assay($tap{e}, \%ASSAYS);
    if ($assays) {
      $expression{assay} = $assays;
    } else {
      print STDERR "PROBLEM WITH ASSAY <$tap{e}> -- NO GO!\n";
      return;
    }
  }

  if ($tap{t}) {
    my $stages = parse_dev_stage($tap{t}, $fbdv, $dbh);
    if ($stages) {
      $expression{stage} = $stages;
    } else {
      print STDERR "PROBLEM WITH STAGE <$tap{t}> -- NO GO!\n";
      return;
    }
  }

  if ($tap{a}) {
    my $anats = parse_anat_cc($tap{a});
    if ($anats) {
      $expression{anatomy} = $anats;
    } else {
      print STDERR "PROBLEM WITH ANATOMY <$tap{a}> -- NO GO!\n";
      return;
    }
  }

  if ($tap{'s'}) {
    my $subs = parse_anat_cc($tap{'s'});
    if ($subs) {
      $expression{cellular} = $subs;
    } else {
      print STDERR "PROBLEM WITH SUBCELLULAR <$tap{s}> -- NO GO!\n";
      return;
    }
  }

  if ($tap{n}) {
    $expression{comment} = $tap{n};
  }

  return \%expression;
}


# will parse an anatomy, subcellular into its component terms and qualifiers
sub parse_anat_cc {
  my $term = shift;

  my @info;

  my $OF = 'OFTERM';

  $term = trim($term);
  $term =~ s/&&of/$OF/g;

#  print "TERM FOR CHECKING $term\n";

  my @bits = trim(split /&&/, $term);
  print STDERR "WARNING -- NO TERM TO PARSE\n" and return unless @bits;

  # now we can check for <of> terms split them and store a bit to track by appending
  # to the end of the term
  my @mbits;
  foreach my $t (@bits) {
    if ($t =~ /$OF/) {
      my @ofterms = trim(split /$OF/, $t);
      my $inof;
      foreach my $ot (@ofterms) {
	unless ($inof) { #skip first term
	  push @mbits, $ot;
	  $inof = 1;
	  next;
	}

	if ($ot =~ /\|/) {
	  (my $t, my $q) = trim(split /\|/, $ot);
	  $t .= ' !OF';
	  $ot = $t." | ".$q;
	} else {
	  $ot .= ' !OF';
	}
	push @mbits, $ot;
      }
    } else {
      push @mbits, $t;
    }
  }

  foreach my $tq (@mbits) {
    my %term;
#    print "STARTING ON $tq\n";

    (my $term, my $quals) = trim(split /\|/, $tq);

#    print "TERM IS $term\n";
#    print "QUAL IS $quals\n";

    my @qs;
    if ($term =~ /\d+\s*--\s*\d+/) {
#      print "CHECKING A TERM WITH DOUBLE DASH\n";
      my $ofop;
      if ($term =~ / !OF$/) {
	$ofop = 'OF';
	$term =~ s/ !OF//;
      }
      # deal with a range / number term
      (my $firstpart, my $numbers, my $lastpart) = split /(\d+\s*--\s*\d+)/, $term;
        (my $firstnum, my $lastnum) = trim(split /--/, $numbers);
      my $fromterm = "$firstpart$firstnum";
      $fromterm .= "$lastpart" if $lastpart;

      my $toterm = "$firstpart$lastnum";
      $toterm .= "$lastpart" if $lastpart;

      if ($fromterm and $toterm) {
#	print "WE'VE GOT BOTH PARTS\n";
	if ($ofop) {
	  push @info, {term => $fromterm,
		       operator => ['OF','FROM']};
	} else {
	  push @info, {term => $fromterm,
		       operator => ['FROM']};
	}
	push @info, {term => $toterm,
		     operator => ['TO']};
      }
      next;
    } elsif ($term =~ /\d\s*,\d+( !OF)*$/) {
#      print "FOR SOME REASON WE ENDED UP HERE\n";
      # have a comma delim list of digits at end of term
      # so should end up with an array of terms (this precludes it being an OF term).
      my $ofop;
      if ($term =~ / !OF$/) {
	$ofop = 'OF';
	$term =~ s/ !OF//;
      }	

      my @terms;
      my @nums = _get_numbers_at_end($term);
      my $base = pop @nums; # should have the base of the term without the numbers
      foreach my $n (@nums) {
	if ($ofop) {
	  push @info, {term => "$base $n",
		       operator => [$ofop],};
	  undef $ofop;
	} else {
	  push @info, {term => "$base $n"};
	}
      }
      next;
    } elsif ($term =~ / !OF$/) {
      $term =~ s/ !OF//;
      $term{term} = $term;
      $term{operator} = ['OF'];
#      push @info, {term => $term,
#		   qualifier => ['OF']};
#      next;
    } else {
      $term{term} = $term;
    }

    if ($quals) {
#      print "HERE IS OUR QUALS: $quals\n";
#      my @qs;
      if ($quals =~ / !OF$/) {
	$term =~ s/ !OF//;
	$term{operator} = ['OF'];
      }

      # this bit to deal with old style syntax - remove before committing
      $quals =~ s/<and>/&/g;
      $quals =~ s/<of>/&/g;

      my @oqs = sort(trim(split /&/, $quals));
      push @qs, @oqs;
#      print "$_\n" for @qs;
#      my $qu = \@qs;
#      $term{qualifier} = $qu;
    }
    if (@qs) {
      my $qu = \@qs;
      $term{qualifier} = $qu;
    }
    my %finterm = %term;

    push @info, \%finterm;
  }
#  print Dumper(\@info);
  return \@info;
}



sub create_expression_dom {
  my %params = @_;

  print STDERR "ERROR -- you must provide an expression data structure, XML::DOM document object and\nan active database handle - RETURNING!\n" unless ($params{doc} and $params{exp} and $params{db});

  my $doc = $params{doc};
  my $expression = $params{exp};
  my $dbh = $params{db};

  my $fmacro; my $lmacro; my $pmacro; my $imacro;
  $fmacro = $params{feature_id} if $params{feature_id};
  $lmacro = $params{library_id} if $params{library_id};
  $imacro = $params{interaction_id} if $params{interaction_id};
  $pmacro = $params{pub_id} if $params{pub_id};

  # figure out any optional parameters
  my $tap = $params{tap} if $params{tap}; # the original statement to turn into a f_ep

  my $SLOTCV = 'expression slots';
  my %SLOT2CV = (
		 assay => 'experimental assays',
		 stage => 'FlyBase development CV',
		 anatomy => 'FlyBase anatomy CV',
		 cellular => 'cellular_component',
		 qualifier => 'FlyBase miscellaneous CV',
		 operator => 'expression_cvterm property type',
		);


  my $f_e_el; #
  # optional feature_expressionprop to hold the note
  my $f_ep_el;
  # and another to hold the original tap statement if provided as param
  my $tap_f_ep_el;
  my $gal4_f_ep_el;

  # print Dumper($expression);
  # first we want to generate an MD5 checksum and see if expression already exists
  my $md5 = generate_checksum($expression);

  my $exp_el;
  my $seen;
  if ($seen_md5s{$md5}) {
    # existing temp_id or already seen expression
    $exp_el = $seen_md5s{$md5};
    $seen = 1;
  } else {
    my $exp_uname = check4expression($dbh,$md5);
    # if we find an existing expression with matching checksum then use uniquename
    # otherwise we need a temp uniquename (how to assign?)
    if ($exp_uname) {
      $exp_el = create_ch_expression(doc => $doc,uniquename => $exp_uname, macro_id => $exp_uname);
      $seen_md5s{$md5} = $exp_uname;
      $seen = 1;
    } else {
      my $uname = "FBex:temp${tmpcnt}";
      $exp_el = create_ch_expression(doc => $doc, uniquename => $uname,
				     md5checksum => $md5,
				     macro_id => $uname, );
      $seen_md5s{$md5} = $uname;

      $tmpcnt++;
    }
  }

  foreach my $slottype (keys %{$expression}) {
    if ($slottype eq 'comment') {
      # need to set up a feature_expressionprop element for the comment - this can
      # go with an existing or brand new expression so don't ignore
      # NOTE: need to set up a rank check so we don't overwrite???
      if (defined $fmacro) {
	  if($pmacro eq "FBrf0237128"){
	      $f_ep_el = create_ch_feature_expressionprop(doc => $doc,
						    value => $expression->{$slottype},
						    type => 'GAL4_table_note',
						    cvname => 'feature_expression property type',
						 );
	  }
	  else{
	      print STDERR "fep before get_feature_expressionprop_rank: feature $fmacro, expression $seen_md5s{$md5}, pub $pmacro, type comment, value $expression->{$slottype}\n";
	      my $exuname = $seen_md5s{$md5};
	      $crank = get_feature_expressionprop_rank($dbh,$fmacro,"feature_expression property type",$exuname,"comment",$expression->{$slottype},$pmacro);
              print STDERR "fep after get_feature_expressionprop_rank: feature $fmacro, expression $seen_md5s{$md5}, pub $pmacro, type comment, value $expression->{$slottype}, rank $crank\n";
	      $f_ep_el = create_ch_feature_expressionprop(doc => $doc,
						    value => $expression->{$slottype},
						    type => 'comment',
						    cvname => 'feature_expression property type',
						     rank => $crank,
    );
	  }
      } elsif (defined $lmacro) {
	$f_ep_el = create_ch_library_expressionprop(doc => $doc,
						    value => $expression->{$slottype},
						    type => 'comment',
						    cvname => 'library_expression property type',
						 );
      } elsif (defined $imacro) {
	$f_ep_el = create_ch_interaction_expressionprop(doc => $doc,
						        value => $expression->{$slottype},
						        type => 'comment',
						        cvname => 'interaction_expression property type',
						       );
      }
      next;
    } elsif ($seen) {
      next;
    }

    my $ecrank = 0;
    foreach my $ec (@{$expression->{$slottype}}) {
      my $e_c_el = create_ch_expression_cvterm(
					       doc => $doc,
					       cvterm_id => create_ch_cvterm(
									     doc => $doc,
									     name => $ec->{term},
									     cv => $SLOT2CV{$slottype},
									    ),
					       rank => $ecrank,
					       cvterm_type_id => create_ch_cvterm(
										  doc => $doc,
										  name => $slottype,
										  cv => $SLOTCV,
										 ),
					      );

      if ($ec->{qualifier}) {
	my $ecprank = 0;
	my $type = 'qualifier';
	my $cv = "$SLOT2CV{qualifier}";

	foreach my $q (sort @{$ec->{qualifier}}) {
	  my $value = '';
	  # add this bit to deal with different type of operator type qualifiers (from stage)
	  if (grep $q eq $_, ('FROM','TO','OF')) {
	    # we've got an operator (should be first but want to decrement $ecprank so set flag?)
	    $type = 'operator';
	    $cv = $SLOT2CV{operator};
	    $value = $q;
	    my $ecp_el = create_ch_expression_cvtermprop(
							 doc => $doc,
							 value => $q,
							 type => $type,
							 cvname => $cv,
							 rank => $ecprank,
							);
	    $e_c_el->appendChild($ecp_el);
	    $ecprank++;
	  } else {
	    $ecrank++;
	    my $qec_el = create_ch_expression_cvterm(
						     doc => $doc,
						     cvterm_id => create_ch_cvterm(
										   doc => $doc,
										   name => $q,
										   cv => $SLOT2CV{qualifier},
										  ),
						     rank => $ecrank,
						     cvterm_type_id => create_ch_cvterm(
											doc => $doc,
											name => $slottype,
											cv => $SLOTCV,
										       ),
						    );
	    my $qecp_el = create_ch_expression_cvtermprop(
							  doc => $doc,
							  value => '',
							  type => $type,
							  cvname => $cv,
							 );
	    $qec_el->appendChild($qecp_el);
	    $exp_el->appendChild($qec_el);
	  }
	}
      }

      if ($ec->{operator}) {
	#can have multiple
	my @ops = @{$ec->{operator}};
	my $orank=0;
	foreach my $o (@ops) {
	  my $ecpo_el = create_ch_expression_cvtermprop(
							doc => $doc,
							value => $o,
							type => 'operator',
							cvname => $SLOT2CV{operator},
							rank => $orank
						       );
	  $e_c_el->appendChild($ecpo_el);
	 $orank++;
	}
      }
      $ecrank++;
      $exp_el->appendChild($e_c_el);
    }
  }

  if (defined $fmacro) {
    $f_e_el = create_ch_feature_expression(doc => $doc,
					   expression_id => $exp_el,
					   feature_id => $fmacro,
					   pub_id => $pmacro,
					  );

    # check to see if original tap statement provided
    if ($tap) {
	if($pmacro eq "FBrf0237128"){
	    $gal4_f_ep_el = create_ch_feature_expressionprop(doc => $doc,
						      type => 'for_GAL4_table',
						      cvname => 'feature_expression property type',
						     );
	    $f_e_el->appendChild($gal4_f_ep_el);
	}
      $tap_f_ep_el = create_ch_feature_expressionprop(doc => $doc,
						      value => $tap,
						      type => 'curated_as',
						      cvname => 'feature_expression property type',
						      rank => $crank,
						     );
      $f_e_el->appendChild($tap_f_ep_el);
    }
  } elsif (defined $lmacro) {
    $f_e_el = create_ch_library_expression(doc => $doc,
					   expression_id => $exp_el,
					   library_id => $lmacro,
					   pub_id => $pmacro,
					  );

    # check to see if original tap statement provided
    if ($tap) {
      $tap_f_ep_el = create_ch_library_expressionprop(doc => $doc,
						      value => $tap,
						      type => 'curated_as',
						      cvname => 'library_expression property type',
						     );
      $f_e_el->appendChild($tap_f_ep_el);
    }
  } elsif (defined $imacro) {
    $f_e_el = create_ch_interaction_expression(doc => $doc,
					       expression_id => $exp_el,
					       interaction_id => $imacro,
					       pub_id => $pmacro,
					      );

    # check to see if original tap statement provided
    if ($tap) {
      $tap_f_ep_el = create_ch_interaction_expressionprop(doc => $doc,
							  value => $tap,
							  type => 'curated_as',
							  cvname => 'interaction_expression property type',
						     );
      $f_e_el->appendChild($tap_f_ep_el);
    }
  } else {
    return $exp_el;
  }
  $f_e_el->appendChild($f_ep_el) if $f_ep_el;

  return $f_e_el;
}

sub check4expression {
  my $dbh = shift;
  my $checksum = shift;
  my $exp_uname;
  ($exp_uname) = $dbh->selectrow_array
    (sprintf("SELECT uniquename FROM expression WHERE md5checksum = '$checksum'"));
  return $exp_uname;
}

# method to generate MD5 checksum from array of info on expression cvterms
# may need to retrofit existing md5 checksums as I realize that I didn't include
# a sort of the qualifiers - F#!*/
sub generate_checksum {
  my %terms = %{+shift};
  my $string;

  foreach my $s (sort keys %terms) {
    next if $s eq 'comment'; # want to skip comment

    foreach my $l (sort by_term_qual @{$terms{$s}}) {
      $string .= $l->{term};
      if ($l->{qualifier}) {
#	$string .= $_ for @{$l->{qualifier}};
	$string .= $_ for sort @{$l->{qualifier}};
      }

      if ($l->{operator}) {
	$string .= $_ for sort @{$l->{operator}};
      }
    }
  }
#  print "STRING=$string\n";

  return unless $string;

  my $checksum = md5_hex($string);
#  print "$checksum\n";
  return $checksum;

}

# takes an existing expression in chado and checks to see if a new checksum
# is needed based on the cvterms and expression_cvtermprops association with the
# expression
# params
# arg1 database handle
# arg2 expression_id or expression.uniquename
# return md5checksum
sub update_checksum {
  my $dbh = shift;
  my $exid = shift;
  my $exuname;

  if ($exid =~ /^FBex/) {
    $exuname = $exid;
    $exid = get_expression_id($dbh, $exid);
  }

  if (! defined $exid or $exid !~ /[0-9]+/) {
    print "ERROR - Can't find expression id for $exid\n";
    return;
  }

  (my $exu) = $dbh->selectrow_array(sprintf("SELECT uniquename FROM expression WHERE expression_id = $exid"));
  if ($exu) {
    $exuname = $exu;
  } else {
    print "ERROR - $exid IS NOT A VALID EXPRESSION ID - NO GO!\n";
    return;
  }

  # now we should have an expression_id to work with
  my $curr_md5;
  ($curr_md5) = $dbh->selectrow_array(sprintf("SELECT md5checksum FROM expression WHERE expression_id = $exid"));
#  print "CURRENTLY: $curr_md5\n";

  unless (defined $curr_md5) {
    print "WARNING - $exuname does not have a current md5checksum\n";
  }

  # now we know we have a valid expression_id and may or may not have it's current md5checksum

  # call function to build ex datastructure
  my $ex = expression_ds_from_chado($dbh, $exid);
#  print Dumper($ex);

  # generate a checksum
  my $new_md5 = generate_checksum($ex);
#  print "NEW = $new_md5\n";
  unless ($new_md5) {
    print STDERR "WARNING -- NO NEW CHECKSUM GENERATED for $exuname- WTF!\n";
  }

  # here is some log info that we may want to comment out
#  if ($new_md5 eq $curr_md5) {
#    print "$exuname CHECKSUM $new_md5 MATCHES\n";
#  } else {
#    print "$exuname NEED UPDATE $curr_md5 TO $new_md5\n";
#  }

  return $new_md5;
}

# takes an database handle and expression_id and builds a datastructure that is identical
# to that created in expression_from_tap which is the data structure that is passed to
# create_expression_dom - one of the first steps in that function is the creation of the
# md5checksum value
# @params
# arg1 database handle
# arg2 expression_id
# return hashref to expression data structure
sub expression_ds_from_chado {
  my $dbh = shift;
  my $exid = shift;
#  print "EXPRESSION ID = $exid\n";
  my %ex;
  my @slots = qw(assay stage anatomy cellular);
  my %id2slot;
  $id2slot{get_cvterm_id_by_name_cv($dbh, $_, 'expression slots')} = $_ for @slots;

  my $qtyid = get_cvterm_id_by_name_cv($dbh, 'qualifier', 'FlyBase miscellaneous CV');
  my $otyid = get_cvterm_id_by_name_cv($dbh, 'operator', 'expression_cvterm property type');

  my $ec_q = $dbh->prepare
    (sprintf
     ("SELECT ec.expression_cvterm_id, c.name
       FROM   expression_cvterm ec, cvterm c
       WHERE  ec.expression_id = $exid
         and  ec.cvterm_type_id = ?
         and  ec.cvterm_id = c.cvterm_id
       ORDER BY ec.rank DESC"
     )
    );

  my $ecp_q = $dbh->prepare
    (sprintf
     ("SELECT value
       FROM   expression_cvtermprop
       WHERE  expression_cvterm_id = ?
         and  type_id = $otyid"
     )
    );


  foreach my $sid (keys %id2slot) {
    $ec_q->bind_param(1, $sid);
    $ec_q->execute or die "Can't do query for $exid\n";
    my %terminfo;
    my @quals; my @opers;
    while ((my $ecid, my $term) = $ec_q->fetchrow_array()) {
#      print "$ecid\t$term\n";
      my $isq;
      ($isq) = $dbh->selectrow_array
	(sprintf("SELECT expression_cvtermprop_id FROM expression_cvtermprop
                  WHERE  expression_cvterm_id = $ecid and type_id = $qtyid"));
      if ($isq) {
	push @quals, $term;
	next;
      }

      $ecp_q->bind_param(1, $ecid);
      $ecp_q->execute or die "Can't do query for expression_cvtermprops of $ecid\n";

      while ((my $val) = $ecp_q->fetchrow_array()) {
	push @opers, $val;
      }

      if ($id2slot{$sid} eq 'stage') {
        push @quals, @opers if @opers;
	undef @opers;
      }

      $terminfo{term} = $term;
      $terminfo{qualifier} = [@quals] if @quals;
      $terminfo{operator} = [@opers] if @opers;
      push @{$ex{$id2slot{$sid}}}, {%terminfo};
      undef %terminfo; undef @quals; undef @opers;
    }
  }

#  print Dumper(\%ex);
  return \%ex;
}


sub by_term_qual {
  my $astring = ''; my $bstring = '';
  $astring = join ('', sort @{$a->{operator}}) if $a->{operator};
  $astring = join ('', sort @{$a->{qualifier}}) if $a->{qualifier};
  $bstring = join ('', sort @{$b->{operator}}) if $b->{operator};
  $bstring = join ('', sort @{$b->{qualifier}}) if $b->{qualifier};
  $a->{term} cmp $b->{term}
    or
  $astring cmp $bstring;
}



# takes cv names provided as an array at gets info on those terms returning
# a hashref with cvname as outer key and term name as inner key and cvterm info
# 
sub get_term_info_by_cv {
    my $dbh = shift;
    my @cvs = @_;
    my %terms;
    foreach my $cv (@cvs) {
      my $query = $dbh->prepare
	(sprintf
	 ("SELECT c.cvterm_id, c.name, c.is_obsolete, c.dbxref_id, cv.name as cv, 
                  d.accession, db.name as db
           FROM   cvterm c, cv, dbxref d, db 
           WHERE  c.cv_id = cv.cv_id and cv.name = '$cv'
             and  c.dbxref_id = d.dbxref_id and d.db_id = db.db_id"
	 )
	);

      $query->execute or die "Can't get terms from cv $cv\n";
	
      while (my $tref = $query->fetchrow_hashref()) {
	$terms{$cv}{$tref->{name}} = $tref;
      }
    }
    return \%terms;
}


sub _get_numbers_at_end {
  my @numbers; # array of numbers in order to return
  my $term = shift;
  $term = reverse $term;
  $term = trim($term);
  my $MIN = 1;
  my $MAX = 99;

  $term =~ /^(\d+[-\s,0-9]+)[^-\s,0-9]/;
  my $numbers = $1;
  $term =~ s/$numbers//;
  $numbers = reverse $numbers;
  $term = reverse $term;

  my @parts = trim(split /,/, $numbers);

  foreach my $p (@parts) {
    if ($p =~ /--/) {
      (my $beg, my $end) = trim(split /--/,$p);
      my @range = get_range("$beg-$end",$MIN,$MAX,$term);
      print STDERR "WARNING - couldn't get range\n" and return unless @range;
      push @numbers,@range;
    } else {
      print STDERR "WARNING -- non-numerics not allowed\n" and return unless $p =~ /^\d+$/;
      push @numbers, $p;
    }
  }
  @numbers = sort {$a <=> $b} @numbers;
  push @numbers, $term;
  return @numbers;
}

sub expand_stage_root {
  my $stage = shift;
  # simple lookup tables

  if ($stage2abbr{$stage}) {
    return $stage;
  } elsif ($stages{$stage}) {
    return $stages{$stage};
  } else {
    return;
  }
}


sub decompose_stage {
  my $term = shift;
  return trim(split '\|', $term);
}




sub by_stage {
  my %stages = ('embryonic stage' => 1,
		'larval stage' => 2,
		'prepupal stage' => 3,
		'pupal stage' => 4,
	        'pharate adult stage' => 5,
		'adult stage' => 6,
		'oogenesis' => 7,
		'spermatogenesis' => 8,
	       );
    $stages{$a} <=> $stages{$b};
}

sub expand_egg {
  my $st = shift;
  my $qual = shift;
  my $orig_term = "$st | $qual";
  my @stages;

  if ($qual =~ /unfertilized/) {
    push @stages, {term => 'unfertilized egg stage'};
  } elsif ($qual =~ /fertilized/) {
    push @stages, {term => 'fertilized egg stage'};
  } else {
    print "WARNING - problem with $orig_term\n";
    return;
  }
  return @stages;
}


sub expand_adult {
  my $st = shift;
  my $qual = shift;
  my $orig_term = "$st | $qual";
  my @stages;

  my $MIN_SCO = 1; # lowest valid adult stage
  my $MAX_STAGE = 3; # highest

  if ($qual =~ /stage/) {
    my @numbers = parse_number_bits($qual,'stage\s*(>=|>|<=|<)*\s*A',$MIN_SCO,$MAX_STAGE,$orig_term);
    foreach my $n (sort {$a <=> $b} @numbers) {
      push @stages, {term => "$st A$n"};
    }
    return @stages if @stages;
    print STDERR "WARNING -- no stages to return -- $orig_term\n" and return;
  } elsif ($qual =~ 'eclosion') {
    push @stages, {term => 'whatever stage is decided on'};
    return @stages;
  } else {
    my $st_w_qual = check_qualifiers($st,$qual,$orig_term);
    print STDERR "WARNING -- unrecognized qualifier for -- $orig_term\n" and return unless $st_w_qual;
    push @stages, $st_w_qual;
    return @stages;
  }
}


sub expand_pupal {
  my $st = shift;
  my $qual = shift;
  my $orig_term = "$st | $qual";
  my @stages;

  my $MIN_SCO = 1; # lowest valid pupal stage
  my $MAX_STAGE = 15; # highest

  # deal with pupal stages
  # have to deal with the comparator first 
  if ($qual =~ /stage/) {
    # lookup table to associate with correct stage PX term with right cv prefix
    my %pstages = (1 => 'prepupal stage',
		   2 => 'prepupal stage',
		   3 => 'prepupal stage',
		   4 => 'prepupal stage',
		   5 => 'pupal stage',
		   6 => 'pupal stage',
		   7 => 'pupal stage',
		   8 => 'pharate adult stage',
		   9 => 'pharate adult stage',
		   10 => 'pharate adult stage',
		   11 => 'pharate adult stage',
		   12 => 'pharate adult stage',
		   13 => 'pharate adult stage',
		   14 => 'pharate adult stage',
		   15 => 'pharate adult stage',);


    my @numbers = parse_number_bits($qual,'stage\s*(>=|>|<=|<)*\s*P',$MIN_SCO,$MAX_STAGE,$orig_term);
    foreach my $n (sort {$a <=> $b} @numbers) {
      push @stages, {term => "$pstages{$n} P$n"};
    }
    return @stages if @stages;
    print STDERR "WARNING -- no stages to return -- $orig_term\n" and return;
  } elsif ($qual eq 'puparium formation') {
    push @stages, {term => 'whatever stage is decided on'};
    return @stages;
  } else {
    my $st_w_qual = check_qualifiers($st,$qual,$orig_term);
    print STDERR "WARNING -- unrecognized qualifier for -- $orig_term\n" and return unless $st_w_qual;
    push @stages, $st_w_qual;
    return @stages;
  }
}



sub expand_oogenesis {
  my $st = shift;
  my $qual = shift;
  my $orig_term = "$st | $qual";
  my @stages;

  my $MIN_SCO = 1; # lowest valid stage, cycle or oogenesis stage
  my $MAX_STAGE = 14;

  my $substage = {
		  10 => ['A','B'],
		  12 => ['A','B','C'],
		  13 => ['A','B','C','D'],
		  14 => ['A','B'],
		 };

  # deal with oocyte stages
  # have to deal with the comparator first 
  if ($qual =~ /stage/) {
    my @numbers = parse_number_bits($qual,'stage\s*(>=|>|<=|<)*\s*S',$MIN_SCO,$MAX_STAGE,$orig_term,$substage);
    foreach my $n (sort {$a <=> $b} @numbers) {
      push @stages, {term => "$st stage S$n"};
    }
    return @stages if @stages;
    print STDERR "WARNING -- no stages to return -- $orig_term\n" and return;
  } else {
    my $st_w_qual = check_qualifiers($st,$qual,$orig_term);
    print STDERR "WARNING -- unrecognized qualifier for -- $orig_term\n" and return unless $st_w_qual;
    push @stages, $st_w_qual;
    return @stages;
  }
}


sub expand_larval {
  my $st = shift;
  my $qual = shift;
  my $orig_term = "$st | $qual";
  my @stages;

  my @lq = ('first instar','second instar','third instar', 'third instar stage 1','third instar stage 2','late third instar larval stage','early third instar larval stage');

  if (grep $_ eq $qual, @lq) {
    if ($qual eq 'third instar stage 2' or $qual eq 'late third instar larval stage') {
      push @stages, {term => 'wandering third instar larval stage'};
    } elsif ($qual eq 'third instar stage 1' or $qual eq 'early third instar larval stage') {
      push @stages, {term => 'early third instar larval stage'};
    } else {
      push @stages, {term => "$qual larval stage"};
    }
    return @stages;
  } else {
    # not dealing with ranges yet
    my $st_w_qual = check_qualifiers($st,$qual,$orig_term);
    print STDERR "WARNING -- unrecognized larval qualifier for -- $orig_term\n" 
      and return unless $st_w_qual;
    push @stages, $st_w_qual;
    return @stages;
  }
}


sub expand_embryo {
  my $st = shift;
  my $qual = trim(shift);
  
  my $orig_term = "$st | $qual";
  my @stages;

  my $MIN_SCO = 1; # lowest valid stage, cycle or oogenesis stage
  my $MAX_STAGE = 17;
  my $MAX_CYCLE = 16;

  my %ot = ('blastoderm' => 'blastoderm stage',
	    'pre-blastoderm' => 'pre-blastoderm stage',
	    'syncytial blastoderm' => 'embryonic stage 4',
	    'cellular blastoderm' => 'embryonic stage 5',
	    'contracted germ band' => 'embryonic stage 13',
	    'extended germ band' => 'extended germ band stage',
	    'early extended germ band' => 'early extended germ band stage',
	    'late extended germ band' => 'late extended germ band stage',
	    'gastrula' => 'gastrula stage',
	    'dorsal closure' => 'dorsal closure stage',
	    'cleavage' => 'cleavage stage',
	   );

  # first deal with embryonic stage specifications
  if ($qual =~ /stage/) {
    my @numbers = parse_number_bits($qual,'stage',$MIN_SCO,$MAX_STAGE,$orig_term);
    foreach my $n (sort {$a <=> $b} @numbers) {
      push @stages, {term => "$st $n"};
    }
    return @stages;
  } elsif ($qual =~ /cycle/) {
    my $substage = {14 => ['A','B']};
    my @numbers = parse_number_bits($qual,'cycle',$MIN_SCO,$MAX_CYCLE,$orig_term,$substage);
    foreach my $n (sort {$a <=> $b} @numbers) {
      push @stages, {term => "embryonic cycle $n"};
    }
    return @stages;
  } elsif ($ot{$qual}) {
    ### deal with blastula, gastrula etc.
    push @stages, {term => $ot{$qual}};
    return @stages;
  } else {
    my $st_w_qual = check_qualifiers($st,$qual,$orig_term);
    print STDERR "WARNING -- unrecognized qualifier for -- $orig_term\n" and return unless $st_w_qual;
    push @stages, $st_w_qual;
#    print "DUMPING STAGES IN EXP EMB\n";
#    print Dumper(\@stages);
    return @stages;
  }
  return;
}


sub check_qualifiers {
  ####### here we are dealing with qualifiers that will actually become qualifier props ###########
  my $st = shift;
  my $qual = shift;
  my $term = shift;

  ### deal with valid early, mid, late values
  my @rq = ('early','mid','late','early-mid','mid-late','male','female','mated female','virgin female','mated male','virgin male');
  my @quals;

  my @qcands = trim(split /&/, $qual);

  foreach my $q (@qcands) {
    if (grep $_ eq $q, @rq) {
      push @quals, $q;
      #return {term => $st,qualifier => [$qual]};
    } elsif ($q =~ /(hr|day)/) {
      my $unit = $1;
      $q =~ s/$unit//;
      $q = trim($q);
      my $comp = '';
      $comp = $1 if ($q =~ /((>=)|>|(<=)|<)/); # check for <, <=, >=, >
      print STDERR "WARNING -- misplaced comparator - $term\n" and return unless $q =~ /^$comp/;
      $q =~ s/$comp// if $comp; #remove the comparison from rest of qualifier
      $q = trim($q);
      print STDERR "WARNING -- qualifier contains unexpected characters - $term\n"
	and return unless $q =~ /^\d+(\.\d+)?\s*((-\s*\d+(\.\d+)?\s*)|((,\s*\d+(\.\d+)?\s*)+))?$/;
      my $qstring = '';
      if ($unit eq 'hr') {
	$qstring = "$comp$q hours";
      } elsif ($unit eq 'day') {
	$qstring = "$comp$unit $q";
      }
#      return {term => $st, qualifier => [$qstring]};
      push @quals, $qstring;
    }
  }
  if (@quals) {
    return {term => $st, qualifier => \@quals};
  }
  return;
}


# try to make a generic function that will accept stage, cycle, or something for oogenesis
# and number part of the term and 
sub parse_number_bits {
  my $qual = shift;
  my $type = shift;
  my $min = shift;
  my $max = shift;
  my $term = shift;
  my $subclasses = shift if @_; # hashref to substage lookup table
  my @numbers; # array to return

  my $comp; # to hold >, >=, <, <=

  # check to make sure that there is no funny business going on with multiple pipes
  # or and'ed phrases in the context of number expansion
  print STDERR "INVALID SYNTAX FOR -- $term\n"
      and return if ($qual =~ /&/ or $qual =~ /\|/);

  $qual =~ /$type/;
  if ($1) {
    $qual =~ s/$type/$1/; #get rid of extraneous prefix bits
  } else {
    $qual =~ s/$type//;
  }
  # this is to allow 'embryonic cycle X' deprecated syntax
  $qual =~ s/embryonic// if $qual =~ /embryonic/;

  $comp = $1 if ($qual =~ /((>=)|>|(<=)|<)/); # check for <, <=, >=, >
  $qual =~ s/$comp// if $comp; #remove the comparison from rest of qualifier
  $qual = trim($qual);
	
  # now we should just have numbers, either single, range with hyphen or comma separated
  # note that for a few cases 'A-D' are valid - so we won't check til later
  print STDERR "INVALID -- YOU CANNOT HAVE BOTH comp (i.e. > or <) and a range! -- $term\n"
    and return if (($qual =~ /[,-]/) and $comp);

  # if a term has something other than a number with allowable separators and no substage
  # lookup table was provided then return with invalid syntax
  print STDERR "INVALID -- unexpected characters present whoopsie -- $term\n" and return
    if ($qual !~ /^\d+\s*((-\s*\d+\s*)|((,\s*\d+\s*)+))?$/ and ! defined($subclasses));

  if ($qual =~ /,/) { #have multiple and'ed stages 
    my @sts = trim(split /,/, $qual);
    # we could also have ranges so need to check each bit
    foreach my $s (@sts) {
      if ($s =~ /-/) {
	my @range = get_range($s,$min,$max,$term,$subclasses);
	print STDERR "PROBLEM WITH RANGE\n" and return unless @range;
	push @numbers, @range;
      } else {
	if ($s =~ /^(\d{2})([A-D])$/) {
	  my $num = $1; my $suff = $2;
	  my %subs = %{$subclasses};
	  print STDERR "INVALID substage -- $term\n" and return
	    unless ($subs{$num} and grep $suff eq $_, @{$subs{$num}});
	}
	push @numbers, $s;
      }
    }
    return @numbers;
  } elsif ($qual =~ /-/) {
    # we've got only a range so should be straightforward using existing function
    return get_range($qual,$min,$max,$term,$subclasses);
  } else {
    # a single number although there could be a comparative operator
    # as well as substage info
    # first deal with possible substage BS
    if ($qual =~ /^(\d{2})([A-D])$/) {
      my $num = $1; my $suff = $2;
      my %subs = %{$subclasses};
      print STDERR "INVALID substage -- $term\n" and return
	unless ($subs{$num} and grep $suff eq $_, @{$subs{$num}});
      print STDERR "INVALID - value out of valid range -- $term\n" and return
	unless (check_range($min,$max,$num));

      if ($comp) {
	# there is a comparison
	my $first, my $last;
	if ($comp =~ /</) {
	  ($first, $last) = check_comparator($comp,$min,$max,$num-1);
	  $last = $qual;
	} elsif ($comp =~ />/) {
	  ($first, $last) = check_comparator($comp,$min,$max,$num+1);
#	  print "CHANGING FIRST <$first> TO ";
	  $first = $qual;
	}
	my $range = "$first - $last";
	@numbers  = get_range($range,$min,$max,$term,$subclasses);
	print STDERR "INVALID comparison with subterm -- $term\n" and return
	  unless @numbers;
	return @numbers;
      } else {
	return ($qual);
      }
    } else {
      print STDERR "INVALID - value out of valid range -- $term\n" and return
	unless (check_range($min,$max,$qual));
      if ($comp) {
	my $first; my $last;
	($first, $last) = check_comparator($comp,$min,$max,$qual);
#	print "FIRST = $first -- LAST = $last\n";
	my $range = "$first - $last";
	@numbers  = get_range($range,$min,$max,$term,$subclasses);
	print STDERR "INVALID comparison -- $term\n" and return
	  unless @numbers;
	return @numbers;
      } else {
	return ($qual);
      }
    }
  }
}

# returns an array of numbers or numbers-letter combos to append to terms
sub get_range {
  my $range = shift;
  my $min = shift;
  my $max = shift;
  my $term = shift;
  my $subclasses = shift if @_;

  my @r; # array to return

  (my $first, my $last) = trim(split /-/, $range);

  # pain in the neck substages get their own special function as they are likely
  # not too common in ranges
  if ($first !~ /^\d+$/ or $last !~ /^\d+$/) {
    print STDERR "INVALID -- unexpected characters present -- $term\n"
      and return unless defined $subclasses;
    @r = _get_subclass_range($first,$last,$min,$max,$term,$subclasses);
    return @r;
  }

  print STDERR "INVALID! numbers out of order -- $term\n" and return unless $first <= $last;
  print STDERR "INVALID! -- numbers out of range -- $term\n" and
    return unless (check_range($min,$max,$first,$last));

  for (my $i = $first; $i <= $last; $i++) {
    push @r, $i;
  }
  return @r;
}

# this at the moment is specific for those few cases where there can be substages
# for embryonic cycles or oogenesis stages (hopefully there will not be more need
# for extension to other things
sub _get_subclass_range {
  my $first = shift;
  my $last = shift;
  my $min = shift;
  my $max = shift;
  my $term = shift;
  my %subclasses = %{+shift};

  my @oknums = keys %subclasses;

  my $fnum; my $fsuf;
  my $lnum; my $lsuf;
  if ($first  =~ /^(\d{2})([A-D])$/) {
    $fnum = $1;
    $fsuf = $2;
    $first++;
  } elsif ($first !~ /^\d+$/) {
    print STDERR "INVALID - problem with first part of range -- $term\n";
    return;
  }
  if ($last  =~ /^(\d{2})([A-D])$/) {
    $lnum = $1;
    $lsuf = $2;
    $last--;
  } elsif ($last !~ /^\d+$/) {
    print STDERR "INVALID - problem with last part of range -- $term\n";
    return;
  }

  if ($fnum and $lnum) {
    if ($fnum == $lnum) {
      # range of substages eg. 13A-13C
      my @subst = @{$subclasses{$fnum}};
      unless
	(grep $_ == $fnum, @oknums
	 and 
	 grep $_ eq $fsuf, @subst
	 and
	 grep $_ eq $lsuf, @subst
	) {
	  print STDERR "INVALID - subranges are no good for given value -- $term\n";
	  return;
	}
      return _get_letter_range($fnum,$fsuf,$lsuf,@subst);
      # make an array to return
    } else {
      # we've got substages on both ends
      my @fsubst = @{$subclasses{$fnum}};
      my @front = _get_letter_range($fnum, $fsuf, $fsubst[-1], @fsubst);

      my @mid = get_range("$first - $last", $min, $max, $term);

      my @lsubst = @{$subclasses{$lnum}};
      my @back = _get_letter_range($lnum, $lsubst[0], $lsuf, @lsubst);
      push @front, @mid;
      push @front, @back;
      return @front;
    }
  } elsif ($fnum) {
    # substages are only on the front end
    my @fsubst = @{$subclasses{$fnum}};
    my @front = _get_letter_range($fnum, $fsuf, $fsubst[-1], @fsubst);

    my @rest = get_range("$first - $last", $min, $max, $term);
    push @front, @rest;
    return @front;
  } elsif ($lnum) {
    # substages are only on the back end
    my @rest = get_range("$first - $last", $min, $max, $term);
    my @lsubst = @{$subclasses{$lnum}};
    my @back = _get_letter_range($lnum, $lsubst[0], $lsuf, @lsubst);
    push @rest, @back;
    return @rest;
  } else {
    print STDERR "INVALID -- couldn't process your subrange term -- $term\n";
    return;
  }
}

sub _get_letter_range {
  my $num = shift;
  my $first = shift;
  my $last = shift;
  my @range = @_;
  my @subs;

  my $pr;
  foreach my $r (@range) {
    $pr = 1 if $r eq $first;
    push @subs, "$num$r" if $pr;
    last if $r eq $last;
  }
  return @subs;
}


# if there is a >, >=, <, <= term with number will return first and last
# params three ints 
# int 1 = min allowable value
# int 2 = max allowable value
# int 3 = value to expand out
sub check_comparator {
    my $comp = shift;
    my $min = shift;
    my $max = shift;
    my $val = shift;
    my $first; my $last;
    # ugly bit here but will change from number to valid range
    if ($comp eq '>=') {
	$first = $val;
	$last = $max;
    } elsif ($comp eq '>') {
	$first = $val + 1;
	$last = $max;
    } elsif ($comp eq '<=') {
	$first = $min;
	$last = $val;
    } elsif ($comp eq '<') {
	$first = $min;
	$last = $val - 1;
    }
    print STDERR "out of order\n" and return unless $first < $last;
    return unless (check_range($min,$max,$first,$last));
    return ($first,$last);
}

sub check_range {
    my $min = shift;
    my $max = shift;
    my @st = @_;
    for (@st) {
	return unless ($_ >= $min and $_ <= $max);
    }
    return 1;
}

sub trim {
  my @out = @_;
  for (@out) {
    s/^\s+//;
    s/\s+$//;
  }
  return wantarray ? @out : $out[0];
}
1;
