#!/usr/local/bin/perl
# new_proforma
#
#	Perl script parses proforma ...  preliminary to producing chadoXML
#	for loading
#
#       Script expects to find input files on the command line and 
#       write the xml to the output file specified
#-----------------------------------------------------------------------------#
#	NOTES:
#       USAGE: new_proforma.pl input_dir/*  output_file
#-----------------------------------------------------------------------------# 
use strict;
use warnings;
use XML::DOM;
use DBI;
use IO::Handle;
use File::stat;
use Time::Local;
use FlyBase::Proforma::TI;
use FlyBase::Proforma::TP;
use FlyBase::Proforma::TE;
use FlyBase::Proforma::Pub;
use FlyBase::Proforma::Balancer;
use FlyBase::Proforma::Aberr;
use FlyBase::Proforma::Gene;
use FlyBase::Proforma::Allele;
use FlyBase::Proforma::MultiPub;
use FlyBase::Proforma::Util;
use FlyBase::Proforma::Feature;
use FlyBase::Proforma::SF;
use FlyBase::Proforma::Library;
use FlyBase::Proforma::Cell_line;
use FlyBase::Proforma::Interaction;
use FlyBase::Proforma::Strain;
use FlyBase::Proforma::DB;
use FlyBase::Proforma::HH;
use FlyBase::Proforma::GG;
use FlyBase::Proforma::Species;
use FlyBase::Proforma::Tool;

use Data::Dumper;

use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

my %ph;


if(@ARGV <2){
    print "Usage: new_proforma.pl [-v] [-d] /input_dir1/* /input_dir2 ...  outputfile\n";
    exit(0);
}


my @infiles=();
my $validate=0;
my $debug = 0;
my $file_count = 0;
foreach (my $i=0;$i<=$#ARGV;$i++){
    if($ARGV[$i] eq '-v'){
        $validate=1;
    }
    elsif($ARGV[$i] eq '-d'){
        $debug = 1;
    }
    else{
        push(@infiles, $ARGV[$i]);
    }
}
my $outfile=pop(@infiles);

my $data_source = $ENV{'PARSER_DATA_SOURCE'};
my $user = $ENV{'PARSER_USER'};
my $pwd = $ENV{'PARSER_PASSWORD'};
# If enviroments are not set then see if we have a credentails file
my $mdbh = DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";


#
# List of dependent keys. 
# We can have multiple values for these keys so we cannot keep them in a straight forward
# hash. If we have a value already we instead store the hashes in an array.
# The values are a list of related keys that need to be checked.
#

# NOTE: (Order is very important in the proforma file)
# if other sub keys come before the main key here then we can get unpredicatble
# behaviour.
# i.e. if we have 
# A90a, A90b, A90b then A90a
# then we key A90 (due to chopping) with the two A90b concanted together with '/n'
# followed by A90a with no A90b field.

my %key_dependents = (
    'A90a'  => ['A90a', 'A90b', 'A90c', 'A90h', 'A90j'],
    'A91a'  => ['A91a', 'A91b', 'A91c', 'A91d', 'A91e'],
    'A92a'  => ['A92a', 'A92b', 'A92c', 'A92d', 'A92e'],
    'F11'   => ['F11', 'F11a', 'F11b'],
    'F16a'  => ['F16a', 'F16b', 'F16c'],
    'GA80a' => ['GA80a', 'GA80b'],
    'GA83a' => ['GA83a', 'GA83b', 'GA83c', 'GA83d'],
    'GA90a' => ['GA90a', 'GA90b', 'GA90c', 'GA90d', 'GA90e', 'GA90f', 'GA90g', 'GA90i', 'GA90h', 'GA90j', 'GA90k'],
    'GG8a'  => ['GG8a', 'GG8b', 'GG8c', 'GG8d'],
    'HH5a'  => ['HH5a','HH5b', 'HH5c', 'HH5d'],
    'HH7e'  => ['HH7e', 'HH7d', 'HH7c', 'HH7f'],
    'HH8a'  => ['HH8a', 'HH8c', 'HH8d'],
    'HH14a' => ['HH14a', 'HH14b', 'HH14c', 'HH14d'],
    'LC12a' => ['LC12a', 'LC12b', 'LC12c'],
    'LC99a' => ['LC99a', 'LC99b', 'LC99c', 'LC99d'],
    'MA19a' => ['MA19a', 'MA19b', 'MA19c', 'MA19d', 'MA19e'],
    'MA23a' => ['MA23a', 'MA23b', 'MA23c', 'MA23g'],
    'MS7a'  => ['MS7a', 'MS7b', 'MS7c'],
    'SF4d'  => ['SF4d', 'SF4f', 'SF4e'],
    'SF5a'  => ['SF5a', 'SF5e', 'SF5f'],
    'SF21a' => ['SF21a', 'SF21b', 'SF21c', 'SF21d'],
    'SF22a' => ['SF22a', 'SF22b', 'SF22c', 'SF22d'],
    'SN10a' => ['SN10a', 'SN10b', 'SN10c'],
    'TE5a'  => ['TE5a', 'TE5b'],
    'TE5c'  => ['TE5c', 'TE5d'],
    'TO6a'  => ['TO6a', 'TO6b', 'TO6c','TO6d']);

#
# An (@array_set) array of hashes is used store the info for the record key.
# short_array_index gives the index into the array_set for a particular short key (i.e. 'GA90')
# array_index gives the index into the array_set for a particular key (i.e. 'GA90a')
#
my @array_set;
my %short_array_index;
my %array_index;

=head2 reset_array_set

  Title   : reset_array_set

  Usage   : reset_array_set()

  Parameters: None
 
  Function: Reinitialises the @array_set, %short_array_index and %array_index.
            Needs to be done for before each file is processed.
=cut
sub reset_array_set {
    my $index = 0;
    @array_set = ();
    for my $key (keys %key_dependents){
       
	    $array_index{$key} = $index;
        if($key ne 'F11') {
            chop($key);
        }
        $short_array_index{$key} = $index;
        push(@array_set, []);
        $index += 1;
    }
}

=head2 add_arrays_to_ph

  Title   : add_arrays_to_ph

  Usage   : add_arrays_to_ph()

  Parameters: $pf_ref reference to the %ph to be updated
 
  Function: Adds the data from the @array_set to the %ph using
            short_array_index to get key and the array index for that.
=cut
sub add_arrays_to_ph {
    my ($ph_ref) = @_;
    for my $key (keys %short_array_index){
        my $index = $short_array_index{$key}; 
 	if  (@{$array_set[$index]}>0) {
            $$ph_ref{$key} = [@{$array_set[$index]}];
        }
    }
}


=head2 process_doc_line

  Title   : process_doc_line

  Usage   : my $new_hash = process_doc_line($key, \%ph)

  Parameters: key:    record key e.g. MA19a
              pf_ref: reference to the %ph to be updated
 
  Function: For each of a keys "dependents" store this in a hash whoich is retured
            and remove it form the original (ph_ref)

  Returns: New Hash for that record key.
=cut
sub process_doc_line {
    my ($fld, $ph_ref) = @_;
    my %hash={};

    foreach my $key (@{$key_dependents{$fld}}){
        if(exists($$ph_ref{$key})){
	        $hash{$key}=$$ph_ref{$key};
	        if($$ph_ref{"$key.upd"}){
	            $hash{"$key.upd"}=$$ph_ref{"$key.upd"};
		        delete $$ph_ref{"$key.upd"};
	        }
	        delete $$ph_ref{$key};
	    }
    }
    return %hash
}


=head2 write_new_process

  Title   : write_new_process

  Usage   : $id = write_new_process(\%ph, 'TC1a', 'Cell_line', 'write_cell_line', 0);
            write_new_process(\%ph, 'MA1a', 'TI');

  Parameters: ph_ref: reference to the %ph to be updated
              ph_key: record key e.g. MA19a
              proforma_type: Type of object to be created e.g. "Allele"
              func_name: function to be called after new object created. Defaults to "process"
              do_validate: Wether to do extra validation or not ($validate needs to be set else has no effect) Default is 0.
  Function: For each of a keys "dependents" store this in a hash which is returned
            and remove it form the original (ph_ref)

  Returns: New Hash for that record key.
=cut
sub write_new_process {
    #
    #Used in write_chadoxml_* as most follow this rule
    #
    my ($ph_ref, $ph_key, $proforma_type, $func_name, $do_validate) = @_;
    if (!defined $func_name ) {
        $func_name = "process";
    }
    if (!defined $do_validate) {
        $do_validate = 1;
    }

    my @items=split(/\s\#\s/,$$ph_ref{$ph_key});
    my $num=@items;
    my $return_data = undef;
    for (my $i=0;$i<$num;$i++){
        my %newph=();
	    foreach my $key(keys %$ph_ref){
	        my @fiels=split(/\s\#\s/,$$ph_ref{$key} );
	        my $n=@fiels;
	        if($n==1){
	            $newph{$key}=$$ph_ref{$key};
	        }
	        else{
	            $newph{$key}=$fiels[$i];
	        }
	    }
 
        my $pro="FlyBase::Proforma::$proforma_type"->new(db=>$mdbh, debug=>1);
 
        if($validate==1 and $do_validate){
	        $pro->validate(%newph);
	    }
	    else{
	        my ($feature, $other)=$pro->$func_name(%newph);
            $return_data = $other;
	        print OUT $feature if(!$validate);
        }		
    }
    return $return_data;
}

#### open output file

if(!$validate){
  open(OUT,">:utf8",$outfile) or die "could not open output file $outfile\n";  
  OUT->autoflush(1);
}

if(!$validate){
print OUT "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<chado>\n";
print OUT " <pub id=\"unattributed\">
<uniquename>unattributed</uniquename>
 </pub>
<pub id=\"FBrf0104946\">
  <uniquename>FBrf0104946</uniquename>
 </pub>
 <pub id=\"FBrf0105495\">
  <uniquename>FBrf0105495</uniquename>
 </pub>
 <environment id=\"unspecified\" op=\"lookup\">
    <uniquename>unspecified</uniquename>
 </environment>
 <phenotype id='unspecified'>
	<uniquename>unspecified</uniquename>
 </phenotype>
 <cvterm id=\"unspecified\" op=\"lookup\">
    <name>unspecified</name>
    <cv_id><cv><name>FlyBase miscellaneous CV</name></cv></cv_id>
 </cvterm>
 <genotype id='+/+'><uniquename>+/+</uniquename></genotype>
 <feature id='unspecified'  op=\"lookup\">
   <uniquename>unspecified</uniquename>
   <organism_id><organism><genus>Drosophila</genus>
    <species>melanogaster</species>
   </organism></organism_id>
   <type_id><cvterm><name>chromosome</name><cv_id><cv><name>SO</name></cv></cv_id>
   </cvterm></type_id>
 </feature>
 <organism id='autogenetic'><genus>Unknown</genus><species>autogenetic</species></organism>
  <organism id='xenogenetic'><genus>Unknown</genus><species>xenogenetic</species></organism>";
}
my $pub='';
my $file='';
my $p1='';
my $aberr='';
my $gene='';
my $c3='';
my $c1='';
####################################################
#### Open input file and parse, proforma by proforma
####################################################

#### read file. 
foreach my $inf (@infiles) {
    my @files=glob($inf);
    foreach $file(@files){
        print STDERR "\n==Opening: .$file.==\n";
	    print STDERR "ERROR: $file either not readable or not a plain file or not a text file.\n" unless ( -r $file  && (-f $file &&  -T _));
 	    open(INF,$file) or die "ERROR: Cannot open input: .$file.\n";
        my $st=stat($file);
        my $timestring=localtime($st->mtime);
        my $cur='';
        my $aberr='';
        my $gene='';
        my $last_fld='';
        $c1='';
	    $c3='';
        reset_array_set();
        my @all_pros;
        while (<INF>) {
            my $fld = '';
            chop($_) if ($_ =~ /\n$/);
            ## When we hit the long line of !!!!!!, we generate chXML...
	
            if (($_ =~ /\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!/) ) {
	        ## write chadoxml out to the file
  
                add_arrays_to_ph(\%ph);	 
		        if($cur eq ''){
		            if($file=~/.*\/([a-z]{2})\d+/ || $file=~/^([a-z]{2})\d+/){
		                $cur=$1;
                    }
                    elsif($file=~/.*\/\d+\.(\w+)\./ ||
		                  $file=~/^\d+\.(\w+)\./ || 
                          $file=~/.*\/.*?\.(\w+)\./ ||
		                  $file=~/^.*?\.(\w+)\./){
                      $cur=$1;
                    }
                }
 
	            if(defined($ph{key}) and ($ph{key} eq 'PUBLICATION' || $ph{key} eq 'MULTIPUBLICATION')){
	                $ph{created}=$timestring;
	                my $f=$file;
	                $f=~s/.*\/(.*)/$1/;
                    $f=~s/(^\w{2}\d+?)\.\d+/$1/;
	                $ph{file}=$f;
	            }
	            if(!defined($ph{file})){
	                my $f=$file;
		            $f=~s/.*\/(.*)/$1/;
		            $f=~s/(^\w{2}\d+?)\.\d+/$1/;
		            $ph{file}=$f;
	            }
	            my %newph=%ph;
	            push(@all_pros,\%newph);

	            reset_array_set();
	            undef(%ph);
	        }

            elsif ($_ =~ /^\!\s+(\w+)\.{1}.*?\:{1}(.*)$/ ) {
	            $fld = $1;	
	            my $val = $2;
 	            $val=~s/^\s+//;
	            $val=~s/\s+$//;
                if($val eq ''){
	                $last_fld=$fld;
	            }
	            else{
	                if($fld=~/^[A-Z]+$/){
	                    $ph{key}=$fld;
	                }
	                if($fld=~/^[A-Z]{1,2}\d/ && !($fld=~/^[C]/)){
	                    if($fld eq 'P22'){
	                        $pub=$val;
       	                }
		                if(exists($ph{$fld})){
                            if(exists($array_index{$fld})){
              		            my %hash = process_doc_line($fld, \%ph);
                                push(@{$array_set[$array_index{$fld}]}, \%hash);
 			                    $ph{$fld}=$val;
			                }
			                else{
			                    $ph{$fld}.="\n".$val;
			                }
		                }	
		                else{
		                    $ph{$fld} = $val;
		                }
		                $last_fld = $fld;
		            }
		            else {
		                if($fld eq 'P22'){
			                $pub=$val;
			            }
			            elsif($fld eq 'C1'){
                            if ($debug){
                                print STDERR "setting C1 to $val\n";
                            }
			                $c1=$val;
			            }
			            elsif($fld eq 'C3'){
			                $c3=$val;
			            }
		            }
	            }
	        }
            ## Get bang c (!c) fields
            elsif (($_ =~ /^\!c\s+(\w+)\.{1}.*?\:{1}(.*)$/) && ($_ !~ /^\!c\s+(\w+)\.{1}.*\:{1}\s+$/)) { 
	            $fld = $1;
	            my $val = $2;
	            $val=~s/^\s+//;
	            $val=~s/\s+$//;
#	            print STDERR "\tSetting BANG C hash: $fld: $val\n";
	            if($fld=~/^\w{1,2}\d/ && !($fld=~/^[C]/)){
		            $ph{$fld} = $val;
		            $ph{"$fld.upd"} = 'c';
		            $last_fld = $fld;
	            }	
            }

            ## Handle appending values in multi-line proforma fields
            elsif (($_ !~ /^\s*$/) && 
                   ($_ !~ /^\!\s+(\w+)\.{1}.*?\:\s*$/) && 
                   ($_ !~ /^\s*\!+\s*$/) && 
                   ($_ !~ /^\!/)) {
#		        print STDERR "\t\tAppending to $last_fld: $_\n";
                if($last_fld =~/^\w{1,2}\d/ && !($fld=~/^[C]/)){
	                $ph{$last_fld} = $ph{$last_fld} . "\n" . $_;
	            }
            }
            ## Everything else is a throw-away line	
            elsif ($_=~/\!\s+(.*?)\s+.*PROFORMA/){
	            $ph{key}=$1;
	            print STDERR "key = $1\n" if $debug;
            }
            elsif ($debug) {
                print STDERR "ignoring $_\n";
            }
        }
        close(INF);

        if ($debug) {
            $file_count += 1;
            my $new_file = $outfile . ".$file_count";
	        print STDERR "dumping data to --> $new_file\n";
            open(DEBUG,">:utf8","$new_file") or die "could not open debug file $new_file\n";  
            DEBUG->autoflush(1);
            print DEBUG Data::Dumper->Dump(\@all_pros);
            close(DEBUG)
        }
        foreach my $ph_ref (@all_pros){
            write_chadoxml_first($ph_ref,$cur);
        }
        foreach my $ph_ref (@all_pros){
            write_chadoxml_second($ph_ref,$cur);
        }
    }
}

## write dom structure to file
print OUT "\n</chado>\n";
close(OUT);

print STDERR "========END========\n";

sub write_chadoxml_first{
    my $refhash=shift;
    my $curator=shift;
    my %ph=%$refhash;
    my %cur_name=('Lynn','crosby','Sian','sian','lc','crosby',);
    my $pub_id='';
    my $cur_id='';
    my $feature='';
    my $temp='';
    my $id='';
 
    if($pub=~/^\d+$/){
        my $zeros='0'x(7-length($pub));
        $pub_id='FBrf'.$zeros.$pub;
    }else{
        $pub_id=$pub;
    }
    if(exists($cur_name{$curator})){    
        $cur_id=$cur_name{$curator};
    }
    else{
        $cur_id=$curator;
    }
    $ph{pub}=$pub_id;
    if($p1 ne ''){
        $ph{p_type}=$p1;
    }
    $ph{cur}=$cur_id;
    $ph{c3}=$c3;
    $$refhash{c1} = $ph{c1} = $c1;

    my $key = '';
    if(exists $ph{key}){
        $key = $ph{key}
    }
    if($key eq 'CHEMICAL'){
        print STDERR "ERROR: CHEMICAL PROFORMA can only be processed by the python parser.";
    }
    if($key eq 'MULTIPUBLICATION'){
        my $pro=FlyBase::Proforma::MultiPub->new(db=>$mdbh);
	if($validate==1){
	    $pro->validate(%ph);
	}
	else{
	    $feature=$pro->process(%ph);
	    print OUT $feature if(!$validate);
	}
    }
    elsif(exists($ph{MA1a})){
        $id = write_new_process(\%ph, 'MA1a', 'TI', 'write_feature', 0);
    }
    elsif(exists($ph{IN1f})){
        $id = write_new_process(\%ph, 'IN1f', 'Interaction', 'write_interaction', 0);
    } 
    elsif(exists($ph{TC1a})){
        $id = write_new_process(\%ph, 'TC1a', 'Cell_line', 'write_cell_line', 0);
    }
    elsif(exists($ph{MS1a})){
        $id = write_new_process(\%ph, 'MS1a', 'TP', 'write_feature', 0);
    }
    elsif(exists($ph{LC1a})){
        $id = write_new_process(\%ph, 'LC1a', 'Library', 'write_library', 0);
    }
    elsif(exists($ph{TE1a})){
        $temp = write_new_process(\%ph, 'TE1a', 'TE', 'write_feature', 0);
    }
    elsif(exists($ph{A1a})){
         $aberr = write_new_process(\%ph, 'A1a', 'Aberr', 'write_feature', 0);
    }
    elsif(exists($ph{AB1a})){	
         write_new_process(\%ph, 'AB1a', 'Balancer', 'write_feature', 0);
    } 
    elsif(exists($ph{F1a})){
        write_new_process(\%ph, 'F1a', 'Feature', 'write_feature', 0);
    }
    elsif(exists($ph{G1a})){
        $gene = write_new_process(\%ph, 'G1a', 'Gene', 'write_feature', 0);
    }
    elsif(exists($ph{SF1a})){
        $temp = write_new_process(\%ph, 'SF1a', 'SF', 'write_feature', 0);
    }
    elsif(exists($ph{GA1a})){
        write_new_process(\%ph, 'GA1a', 'Allele', 'write_feature', 0);
    }
    elsif(exists($ph{SN1a})){
        write_new_process(\%ph, 'SN1a', 'Strain', 'write_strain', 0);
    } 
    elsif(exists($ph{DB1a})){
#       print STDERR "write_chadoxml_first DATABASE\n";
        write_new_process(\%ph, 'DB1a', 'DB', 'write_db_table', 0);
   }
    #HUMAN HEALTH MODEL PROFORMA
    elsif(exists($ph{HH1b})){
        write_new_process(\%ph, 'HH1b', 'HH', 'write_humanhealth', 0);
    } 
    #GENEGROUP PROFORMA
    elsif(exists($ph{GG1a}) || (exists($ph{key}) and $ph{key} eq 'GENEGROUP')){
        write_new_process(\%ph, 'GG1a', 'GG', 'write_genegroup', 0);
    }
    #EXPERIMENTAL TOOL PROFORMA
    elsif(exists($ph{TO1a}) ){
        print STDERR "write_chadoxml_first EXPERIMENTAL TOOL pub $ph{pub}\n";
        write_new_process(\%ph, 'TO1a', 'Tool', 'write_feature', 0);
    }
    elsif(exists($ph{SP1a})){
#       print STDERR "write_chadoxml_first SPECIES \n";
        write_new_process(\%ph, 'SP1a', 'Species', 'write_species', 0);
    }
 }

#### main function to write chadoxml
sub write_chadoxml_second{ 
    my $refhash=shift;
    my $curator=shift;
    my %ph=%$refhash;
    my %cur_name=('Lynn','crosby','Sian','sian');
    my $pub_id='';
    my $cur_id='';
    my $feature='';
    my $id='';
    ####### get curator and pub information, if they are not filled, exit program
    print STDERR "------------------\n";
  
    if($pub=~/^\d+$/){
        my $zeros='0'x(7-length($pub));
        $pub_id='FBrf'.$zeros.$pub;
    }else{
        $pub_id=$pub;
    }

    if(exists($cur_name{$curator})){    
        $cur_id=$cur_name{$curator};
    }
    else{
        $cur_id=$curator;
    }

    $ph{pub}=$pub_id;
    if(defined($p1) and $p1 ne ""){
        $ph{p_type}=$p1;
    }
    $ph{cur}=$cur_id;
 
    if($aberr ne ''){
        $ph{aberr}=$aberr;
    }
    if(defined($gene) and $gene ne ''){
	    $ph{gene}=$gene;
    }
    my $key = '';
    if(exists $ph{key}){
        $key = $ph{key}
    }
    if($key eq 'MA' || exists($ph{MA1a})){
       write_new_process(\%ph, 'MA1a', 'TI');
    }
    elsif($key eq 'PUBLICATION'){
        my $pro=FlyBase::Proforma::Pub->new(db=>$mdbh);
        if($validate==1){
            $pro->validate(%ph);
        }
        else{
            ($feature,$id)=$pro->process(%ph);
            $pub=$id;
            if(defined($ph{P1})){
                $p1=$ph{P1};
            }
            print OUT $feature if(!$validate && $pub ne 'FBrf0000000');
        }
    }
    elsif(exists($ph{MS1a})){
        write_new_process(\%ph, 'MS1a', 'TP');
    }
    elsif(exists($ph{TC1a})){
	 write_new_process(\%ph, 'TC1a', 'Cell_line');	
    }
    elsif(exists($ph{IN1f})){
         write_new_process(\%ph, 'IN1f', 'Interaction');
    }
    elsif(exists($ph{LC1a})){
         write_new_process(\%ph, 'LC1a', 'Library');
    }
    elsif(exists($ph{SF1a})){
         write_new_process(\%ph, 'SF1a', 'SF');
    }
    elsif(exists($ph{TE1a})){
         write_new_process(\%ph, 'TE1a', 'TE');
    }
    elsif(exists($ph{A1a})){
        $aberr = write_new_process(\%ph, 'A1a', 'Aberr');
    }
    elsif(exists($ph{AB1a})){	
        write_new_process(\%ph, 'AB1a', 'Balancer');
    }
    elsif(exists($ph{G1a})){
       $gene = write_new_process(\%ph, 'G1a', 'Gene');
    }
    elsif(exists($ph{F1a})){
        write_new_process(\%ph, 'F1a', 'Feature');
    }
    elsif(exists($ph{GA1a})){
        write_new_process(\%ph, 'GA1a', 'Allele');
    }
    elsif(exists($ph{SN1a})){
        write_new_process(\%ph, 'SN1a', 'Strain');
    }
    elsif(exists($ph{DB1a})){
        write_new_process(\%ph, 'DB1a', 'DB');
    }
#HUMAN HEALTH MODEL PROFORMA
    elsif(exists($ph{HH1b})){
        write_new_process(\%ph, 'HH1b', 'HH');
    }
#GENEGROUP PROFORMA
    elsif(exists($ph{GG1a}) || (exists($ph{key}) and $ph{key} eq 'GENEGROUP')){
        write_new_process(\%ph, 'GG1a', 'GG');
    }
    elsif(exists($ph{SP1a})){
        write_new_process(\%ph, 'SP1a', 'Species');
    }
    elsif(exists($ph{TO1a})){
        print STDERR "write_chadoxml_second EXPERIMENTAL TOOL $ph{pub}\n";
        write_new_process(\%ph, 'TO1a', 'Tool');
    }
}

__END__

