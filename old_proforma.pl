#!/usr/local/bin/perl
# parse_proforma
#
#	Perl script parses proforma ...  preliminary to producing chadoXML
#	for loading
#
#-----------------------------------------------------------------------------#
#	NOTES:
#       USAGE: new_tiproforma.pl inputfile1 inputfile2....  output 
#-----------------------------------------------------------------------------# 

use XML::DOM;
use DBI;
use IO::Handle;
use File::stat;
use Time::Local;
use lib '/users/falls/Projects/proforma/NEW/lib/perl5';
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
#use Encode;
#### input files can be one or more, or like  *.com ...
#### The last argument has to be output file


if(@ARGV <2){
  print "Usage: new_proforma.pl [-v] inputfile1 *.file2 ... outputfile\n";
  exit(0);
}

my @infiles=();
my $validate=0;
foreach (my $i=0;$i<=$#ARGV;$i++){
	if($ARGV[$i] eq '-v'){
		$validate=1;
	}
	else{
		push(@infiles,$ARGV[$i]);
	}
}
#### open output file
my $outfile=pop(@infiles);
#if(-e $outfile){
#  print "file $outfile exists, Do you want to overwrite it?\n";
#  my $answer=getc();
#  if($answer =~/y/i){
#  open(OUT,">:utf8","$outfile") or die "could not open $outfile for
#  write\n";  
#  }
#  else{
#    print "please rerun the program and specify another output file\n";
#    exit(0);
#  }
#}
#else {
if(!$validate){
  open(OUT,">:utf8",$outfile) or die "could not open output file $outfile\n";  
#open(OUT,">$outfile") or die "could not open output file $outfile\n";

#}

OUT->autoflush(1);
}

my $data_source = $ENV{'PARSER_DATA_SOURCE'};
my $user = $ENV{'PARSER_USER'};
my $pwd = $ENV{'PARSER_PASSWORD'};
my $mdbh = DBI->connect($data_source,$user,$pwd) or die "cannot connect to $data_source\n";

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
####################################################
#### Open input file and parse, proforma by proforma
####################################################

#### read file. 
foreach my $inf (@infiles) {
	my @files=glob($inf);
	foreach $file(@files){
		print STDERR "\n==Opening: .$file.==\n";
		print STDERR "ERROR: $file either not readable or not a plain file or not a text file.\n" unless ( -r $file  && (-f $file &&  -T _));
		#open(INF,"<:utf8",$file) or die "ERROR: Cannot open input: .$file.\n";
			 open(INF,$file) or die "ERROR: Cannot open input: .$file.\n";
		my $st=stat($file);
		my $timestring=localtime($st->mtime);
		my $cur='';
		$c1='';
		$c3='';
		$aberr='';
		$gene='';
		my @arraysf5=();
		my @arraysf4=();
	        my @arraysfd=();
		my @arraysf21=();
		my @arraysf22=();
		my @array19=();
		my @array23=();
#		my @array21=();
		my @array7=();
		my @array5=();
		my @array11=();
		my @array16=();
		my @arraya90=();
		my @arrayga90=();
		my @arraya91=();
		my @arraya92=();
		my @arraysn10=();
		my @arraylc12=();
		my @arraylc99=();
		my @arrayhh5=();
		my @arrayhh14=();
		my @arrayhh7=();
		my @arrayhh8=();
		my @arraygg8=();
		my @arrayto6=();

		my @all_pros=();
		while (<INF>) {
		chop($_) if ($_ =~ /\n$/);
		## When we hit the long line of !!!!!!, we generate chXML...
		
		if (($_ =~ /\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!\!/) ) {
		## write chadoxml out to the file
			if(@array19>0) {
				$ph{MA19}=[ @array19 ];
			}
			if(@array23>0){
				$ph{MA23}=[ @array23];
			}
#			if(@array21>0){
#				$ph{MA21}=[ @array21];
#			}
			if(@array7>0){
				$ph{MS7}=[ @array7 ];
			}
			if(@array5>0){
				$ph{TE5}=[ @array5 ];
			}
			if(@array11>0){
				$ph{F11c}=[ @array11 ];
			}
			if(@array16>0){
				$ph{F16}=[ @array16 ];
			}
			if(@arraysf5>0){
				$ph{SF5}=[ @arraysf5 ];
			}
			if(@arraysf21>0){
				$ph{SF21}=[@arraysf21] ;
			}
			 if(@arraysf22>0){
			   $ph{SF22}=[@arraysf22] ;
         }
			if(@arraysf4>0){
				$ph{SF4}=[@arraysf4];
			}
			if(@arraya90>0){
				$ph{A90}=[@arraya90];
			}
			if(@arrayga90>0){
				$ph{GA90}=[@arrayga90];
			}
			if(@arraya91>0){
				$ph{A91}=[@arraya91];
			}
			if(@arraya92>0){
				$ph{A92}=[@arraya92];
			}
			 if(@arraysfd>0){
			             $ph{SFd}=[@arraysfd];
			}
			 if(@arraylc12>0){
			             $ph{LC12}=[@arraylc12];
			}			 
			 if(@arraylc99>0){
			             $ph{LC99}=[@arraylc99];
			}			 
			 if(@arraysn10>0){
			             $ph{SN10}=[@arraysn10];
			}
			 if(@arrayhh5>0){
			             $ph{HH5}=[@arrayhh5];
			}			 
			 if(@arrayhh14>0){
			             $ph{HH14}=[@arrayhh14];
			}			 
		    	 if(@arrayhh7>0){
			             $ph{HH7}=[@arrayhh7];
			}			 
		    	 if(@arrayhh8>0){
			             $ph{HH8}=[@arrayhh8];
			}			 
		    	 if(@arraygg8>0){
			             $ph{GG8}=[@arraygg8];
			}			 
		    	 if(@arrayto6>0){
			             $ph{TO6}=[@arrayto6];
			}			 
			if($cur eq ''){
				if($file=~/.*\/([a-z]{2})\d+/ || $file=~/^([a-z]{2})\d+/){
					$cur=$1;
				}
           elsif($file=~/.*\/\d+\.(\w+)\./ ||
					 $file=~/^\d+\.(\w+)\./ || $file=~/.*\/.*?\.(\w+)\./
				    || $file=~/^.*?\.(\w+)\./){
              #print STDERR "$cur\n";
                         $cur=$1;
             }
				 #    else { print STDERR "ERROR: could not find curator's name\n";}
				 }
                       else{
                          #print STDERR "cur=$cur\n";
                        }
			if($ph{key} eq 'PUBLICATION' || $ph{key} eq 'MULTIPUBLICATION'){
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
#	print STDERR "WRAPPER before write_chadoxmls file = $ph{file}\n";
			
			my %newph=%ph;
			push(@all_pros,\%newph);
#			  foreach my $key(keys %ph){
#	print STDERR "WRAPPER all_pros: $key, $ph{$key}\n";
#  } 
			#&write_chadoxml(\%ph,$cur);
			undef @array7=(); @array19=();@array23=();@array5=();
			@arraysf21=(); @arraysf22=();@arraysf5=(); @arraysf4=();
			@arraysfd=();@arraya90=();@arrayga90=();@arraysn10=();@arraylc12=();@arraylc99=();
                        @arrayhh5=();@arrayhh14=();@arrayhh7=();@arrayhh8=();@arraygg8=();@arrayto6=();
	 		undef(%ph);
	 }

   elsif ($_ =~ /^\!\s+(\w+)\.{1}?.*?\:{1}(.*)$/ ) {
		my $fld = $1;	
		my $val = $2;
		$val=~s/^\s+//;
		$val=~s/\s+$//;	
#		print "\tSetting hash: $fld: $val\n";
      if($val eq ''){
			$last_fld=$fld;
		}
		else{
#			print "\tSetting hash: $fld: $val\n";
			if($fld=~/^[A-Z]+$/){
				$ph{key}=$fld;
			}
			if($fld=~/^[A-Z]{1,2}\d/ && !($fld=~/^[C]/)){
				if($fld eq 'P22'){
					$pub=$val;
				}
				if(exists($ph{$fld})){
					if($fld eq 'MS7a'){
						my %hash7=();
						foreach $key('MS7a','MS7b','MS7c'){
							if(exists($ph{$key})){
								$hash7{$key}=$ph{$key};
								if($ph{"$key.upd"}){
									$hash7{"$key.upd"}=$ph{"$key.upd"};
									delete $ph{"$key.upd"};
								}
								delete $ph{$key};
							}
						}
						push(@array7,\%hash7);  
						$ph{$fld}=$val;
					}
					elsif($fld eq 'TE5a'){
						my %hash=();
						foreach $key('TE5a','TE5b'){
							if(exists($ph{$key})){
								$hash{$key}=$ph{$key};
								if($ph{"$key.upd"}){
									$hash{"$key.upd"}=$ph{"$key.upd"};
									delete $ph{"$key.upd"};
								}
								delete $ph{$key};
							}
						}
						push(@array5,\%hash);
						$ph{$fld}=$val;
					}
                                        elsif($fld eq 'SF22a'){
                                                my %hash=();
                                                foreach $key('SF22a','SF22b','SF22c','SF22d',){
                                                        if(exists($ph{$key})){
                                                                $hash{$key}=$ph{$key};                                                                
								if($ph{"$key.upd"}){
                                                                        $hash{"$key.upd"}=$ph{"$key.upd"};
                                                                        delete $ph{"$key.upd"};
                                                                }
                                                                delete $ph{$key};
                                                        }
                                                }
                                                push(@arraysf22,\%hash);
                                                $ph{$fld}=$val;
                                        }
                                        elsif($fld eq 'SF21a'){
                                                my %hash=();
                                                foreach $key('SF21a','SF21b','SF21c','SF21d'){
                                                        if(exists($ph{$key})){
                                                                $hash{$key}=$ph{$key};                                                                
								if($ph{"$key.upd"}){
                                                                        $hash{"$key.upd"}=$ph{"$key.upd"};
                                                                        delete $ph{"$key.upd"};
                                                                }
                                                                delete $ph{$key};
                                                        }
                                                }
                                                push(@arraysf21,\%hash);
                                                $ph{$fld}=$val;
                                        }
                                        elsif($fld eq 'SF4d'){
                                                my %hash=();
                                                foreach $key('SF4d','SF4f','SF4e'){
                                                        if(exists($ph{$key})){
                                                                $hash{$key}=$ph{$key};                                                                
								if($ph{"$key.upd"}){
                                                                        $hash{"$key.upd"}=$ph{"$key.upd"};
                                                                        delete $ph{"$key.upd"};
                                                                }
                                                                delete $ph{$key};
                                                        }
                                                }
                                                push(@arraysfd,\%hash);
                                                $ph{$fld}=$val;
                                        }
                                        elsif($fld eq 'SF4a'){
                                                my %hash=();
                                                foreach $key('SF4a','SF4b','SF4h'){
                                                        if(exists($ph{$key})){
                                                                $hash{$key}=$ph{$key};                                                                
								if($ph{"$key.upd"}){
                                                                        $hash{"$key.upd"}=$ph{"$key.upd"};
                                                                        delete $ph{"$key.upd"};
                                                                }
                                                                delete $ph{$key};
                                                        }
                                                }
                                                push(@arraysf4,\%hash);
                                                $ph{$fld}=$val;
                                        }
                                        elsif($fld eq 'SF5a'){
                                                my %hash=();
                                                foreach $key('SF5a','SF5e','SF5f'){
                                                        if(exists($ph{$key})){
																			  
							  # print STDERR "$key $ph{$key}\n";
                                                                $hash{$key}=$ph{$key};  
								if($ph{"$key.upd"}){
                                                                        $hash{"$key.upd"}=$ph{"$key.upd"};
                                                                        delete $ph{"$key.upd"};
                                                                }
                                                                delete $ph{$key};
                                                        }
                                                }
                                                push(@arraysf5,\%hash);
                                                $ph{$fld}=$val;
                                        }

				   elsif($fld eq 'F16a'){
						my %hash=();
						foreach $key('F16a','F16b','F16c'){
							if(exists($ph{$key})){
								$hash{$key}=$ph{$key};
								if($ph{"$key.upd"}){
									$hash{"$key.upd"}=$ph{"$key.upd"};
									delete $ph{"$key.upd"};
								}
								delete $ph{$key};
							}
						}
						push(@array16,\%hash);
						$ph{$fld}=$val;
					}	
					elsif($fld eq 'F11'){
						my %hash=();
						foreach $key('F11','F11a','F11b'){
							if(exists($ph{$key})){
								$hash{$key}=$ph{$key};
								if($ph{"$key.upd"}){
									$hash{"$key.upd"}=$ph{"$key.upd"};
									delete $ph{"$key.upd"};
								}
								delete $ph{$key};
							}
						}
						push(@array11,\%hash);
						$ph{$fld}=$val;
					}
					elsif($fld eq 'TE5c'){
						my %hash=();
						foreach $key('TE5c','TE5d'){
							if(exists($ph{$key})){
								$hash{$key}=$ph{$key};
								if($ph{"$key.upd"}){
									$hash{"$key.upd"}=$ph{"$key.upd"};
									delete $ph{"$key.upd"};
								}
								delete $ph{$key};
							}
						}
						push(@array5,\%hash);
						$ph{$fld}=$val;
					}
					elsif($fld eq 'A90a'){
					  my %hash=();
					  foreach $key('A90a','A90b','A90c','A90h','A90j'){
					    if(exists($ph{$key})){
					      $hash{$key}=$ph{$key};
					      if($ph{"$key.upd"}){
						$hash{"$key.upd"}=$ph{"$key.upd"};
						delete $ph{"$key.upd"};
					      }
					      delete $ph{$key};
					    }
					  }
					  push(@arraya90,\%hash);
					  $ph{$fld}=$val;
					}
					elsif($fld eq 'A91a'){
					  my %hash=();
					  foreach $key('A91a','A91b','A91c','A91d','A91e'){
					    if(exists($ph{$key})){
								$hash{$key}=$ph{$key};
								if($ph{"$key.upd"}){
									$hash{"$key.upd"}=$ph{"$key.upd"};
									delete $ph{"$key.upd"};
								}
								delete $ph{$key};
							}
						}
						push(@arraya91,\%hash);
						$ph{$fld}=$val;
					      }	
					elsif($fld eq 'A92a'){
						my %hash=();
						foreach $key('A92a','A92b','A92c','A92d','A92e'){
							if(exists($ph{$key})){
								$hash{$key}=$ph{$key};
								if($ph{"$key.upd"}){
									$hash{"$key.upd"}=$ph{"$key.upd"};
									delete $ph{"$key.upd"};
								}
								delete $ph{$key};
							}
						}
						push(@arraya92,\%hash);
						$ph{$fld}=$val;
					      }
						elsif($fld eq 'GA90a'){
						my %hash=();
						foreach $key('GA90a','GA90b','GA90c','GA90d', 'GA90e', 'GA90f', 'GA90g', 'GA90i', 'GA90h', 'GA90j','GA90k'){
							if(exists($ph{$key})){
								$hash{$key}=$ph{$key};
								if($ph{"$key.upd"}){
									$hash{"$key.upd"}=$ph{"$key.upd"};
									delete $ph{"$key.upd"};
								}
								delete $ph{$key};
							}
						}
						push(@arrayga90,\%hash);
						$ph{$fld}=$val;
					}
					elsif($fld eq 'MA19a'){
						my %hash19=();
						foreach $key('MA19a','MA19b','MA19c','MA19d','MA19e'){
							if(exists($ph{$key})){
								$hash19{$key}=$ph{$key};
								if($ph{"$key.upd"}){
									$hash19{"$key.upd"}=$ph{"$key.upd"};
									delete $ph{"$key.upd"};
								}
								delete $ph{$key};
							}
						}     
						push(@array19,\%hash19);
						$ph{$fld} = $val;	 
					}
					elsif($fld eq 'MA23a'){
						my %hash23=();
						foreach $key('MA23a','MA23b','MA23c','MA23g'){
							if(exists($ph{$key})){
								$hash23{$key}=$ph{$key};
								if($ph{"$key.upd"}){
									$hash23{"$key.upd"}=$ph{"$key.upd"};
									delete $ph{"$key.upd"};
								}
								delete $ph{$key};
							}
						}
						push(@array23,\%hash23);
						$ph{$fld} = $val;
					}	   
					elsif($fld eq 'LC12a'){
						my %hashlc12=();
						foreach $key('LC12a','LC12b','LC12c'){
							if(exists($ph{$key})){
								$hashlc12{$key}=$ph{$key};
								if($ph{"$key.upd"}){
									$hashlc12{"$key.upd"}=$ph{"$key.upd"};
									delete $ph{"$key.upd"};
								}
								delete $ph{$key};
							}
						}
					   	push(@arraylc12, \%hashlc12 );
						$ph{$fld} = $val;
					      }
					elsif($fld eq 'LC99a'){
						my %hashlc99=();
						foreach $key('LC99a','LC99b', 'LC99c', 'LC99d'){
							if(exists($ph{$key})){
								$hashlc99{$key}=$ph{$key};
								if($ph{"$key.upd"}){
									$hashlc99{"$key.upd"}=$ph{"$key.upd"};
									delete $ph{"$key.upd"};
								}
								delete $ph{$key};
							}
						}
					   	push(@arraylc99, \%hashlc99 );
						$ph{$fld} = $val;
					      }

					elsif($fld eq 'SN10a'){
						my %hashsn10=();
						foreach $key('SN10a','SN10b','SN10c'){
							if(exists($ph{$key})){
								$hashsn10{$key}=$ph{$key};
								if($ph{"$key.upd"}){
									$hashsn10{"$key.upd"}=$ph{"$key.upd"};
									delete $ph{"$key.upd"};
								}
								delete $ph{$key};
							}
						}
					   	push(@arraysn10, \%hashsn10 );
						$ph{$fld} = $val;
					      }
					elsif($fld eq 'HH7e'){
						my %hashhh7=();
						foreach $key('HH7e','HH7d', 'HH7c', 'HH7f'){
							if(exists($ph{$key})){
								$hashhh7{$key}=$ph{$key};
								if($ph{"$key.upd"}){
									$hashhh7{"$key.upd"}=$ph{"$key.upd"};
									delete $ph{"$key.upd"};
								}
								delete $ph{$key};
							}
						}
					   	push(@arrayhh7, \%hashhh7 );
						$ph{$fld} = $val;
					      }
					elsif($fld eq 'HH8a'){
						my %hashhh8=();
						foreach $key('HH8a','HH8c','HH8d'){
							if(exists($ph{$key})){
								$hashhh8{$key}=$ph{$key};
								if($ph{"$key.upd"}){
									$hashhh8{"$key.upd"}=$ph{"$key.upd"};
									delete $ph{"$key.upd"};
								}
								delete $ph{$key};
							}
						}
					   	push(@arrayhh8, \%hashhh8 );
						$ph{$fld} = $val;
					      }
					elsif($fld eq 'HH5a'){
						my %hashhh5=();
						foreach $key('HH5a','HH5b', 'HH5c', 'HH5d'){
							if(exists($ph{$key})){
								$hashhh5{$key}=$ph{$key};
								if($ph{"$key.upd"}){
									$hashhh5{"$key.upd"}=$ph{"$key.upd"};
									delete $ph{"$key.upd"};
								}
								delete $ph{$key};
							}
						}
					   	push(@arrayhh5, \%hashhh5 );
						$ph{$fld} = $val;
					      }
					elsif($fld eq 'HH14a'){
						my %hashhh14=();
						foreach $key('HH14a','HH14b', 'HH14c', 'HH14d'){
							if(exists($ph{$key})){
								$hashhh14{$key}=$ph{$key};
								if($ph{"$key.upd"}){
									$hashhh14{"$key.upd"}=$ph{"$key.upd"};
									delete $ph{"$key.upd"};
								}
								delete $ph{$key};
							}
						}
					   	push(@arrayhh14, \%hashhh14 );
						$ph{$fld} = $val;
					      }
					elsif($fld eq 'GG8a'){
						my %hashgg8=();
						foreach $key('GG8a','GG8b','GG8c','GG8d'){
							if(exists($ph{$key})){
								$hashgg8{$key}=$ph{$key};
								if($ph{"$key.upd"}){
									$hashgg8{"$key.upd"}=$ph{"$key.upd"};
									delete $ph{"$key.upd"};
								}
								delete $ph{$key};
							}
						}
					   	push(@arraygg8, \%hashgg8 );
						$ph{$fld} = $val;
					      }
					elsif($fld eq 'TO6a'){
						my %hashto6=();
						foreach $key('TO6a','TO6b','TO6c','TO6d'){
							if(exists($ph{$key})){
								$hashto6{$key}=$ph{$key};
								if($ph{"$key.upd"}){
									$hashto6{"$key.upd"}=$ph{"$key.upd"};
									delete $ph{"$key.upd"};
								}
								delete $ph{$key};
							}
						}
					   	push(@arrayto6, \%hashto6 );
						$ph{$fld} = $val;
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
					$c1=$val;
				}
				elsif($fld eq 'C3'){
				    $c3=$val;
				}
			}
		}
	}
      ## Get bang c (!c) fields
   elsif (($_ =~ /^\!c\s+(\w+)\.{1}?.*?\:{1}?(.*)$/) && ($_ !~ /^\!c\s+(\w+)\.{1}?.*\:{1}?\s+$/)) { 
		my $fld = $1;
		my $val = $2;
		$val=~s/^\s+//;
		$val=~s/\s+$//;
#	 print "\tSetting BANG C hash: $fld: $val\n";
		if($fld=~/^\w{1,2}\d/ && !($fld=~/^[C]/)){
			$ph{$fld} = $val;
			$ph{"$fld.upd"} = 'c';
			$last_fld = $fld;
		}	
   }

      ## Handle appending values in multi-line proforma fields
   elsif (($_ !~ /^\s*$/) && ($_ !~
	/^\!\s+(\w+)\.{1}?.*?\:\s*$/) && ($_ !~ /^\s*\!+\s*$/) && ($_ !~
	/^\!/)) {
#		print "\t\tAppending to $last_fld: $_\n";
		if($last_fld =~/^\w{1,2}\d/ && !($fld=~/^[C]/)){
			$ph{$last_fld} = $ph{$last_fld} . "\n" . $_;
		}
   }
      ## Everything else is a throw-away line	
   elsif ($_=~/\!\s+(.*?)\s+.*PROFORMA/){
			$ph{key}=$1;
#			print "\tThis is a throw-away line?  .$_.\n";
   }
  }
  close(INF);
foreach $ph_ref(@all_pros){
    write_chadoxml_first($ph_ref,$cur);
}
print STDERR "-----------------------\n";
foreach $ph_ref(@all_pros){
    write_chadoxml_second($ph_ref,$cur);
}
}
}
## write dom structure to file
print OUT "\n</chado>\n";
close(OUT);
foreach my $d(keys %fbids){
 print STDERR $fbids{$d}, "   $d\n";
}
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
      $zeros='0'x(7-length($pub));
      $pub_id='FBrf'.$zeros.$pub;
 }else{
      $pub_id=$pub;
 }
 
  $cur_id=$cur_name{$curator};
  
  if($cur_id eq ''){
    $cur_id=$curator;
  }
  $ph{pub}=$pub_id;
  if($p1 ne ''){
   $ph{p_type}=$p1;
  }
  $ph{cur}=$cur_id;
  $ph{c3}=$c3;
  $ph{c1}=$c1;

  if($ph{key} eq 'MULTIPUBLICATION'){
		my $pro=FlyBase::Proforma::MultiPub->new(db=>$mdbh);
		 if($validate==1){
		 $pro->validate(%ph);
		 }
		 else{
		$feature=$pro->process(%ph);
		print OUT $feature if(!$validate);
		}
	}
#	elsif($ph{key} eq 'PUBLICATION'){
#		my $pro=FlyBase::Proforma::Pub->new(db=>$mdbh);
#		 if($validate==1){
#		 $pro->validate(%ph);
#		 }
#		 else{
#		($feature,$id)=$pro->process(%ph);
#		$pub=$id;	
#		$p1=$ph{P1};
#		print OUT $feature;
#	}
#}
  elsif($ph{key}eq 'MA' || $ph{key} eq 'TRANSPOSON' || exists($ph{MA1a})){
	my @items=split(/\s\#\s/,$ph{MA1a});
	my $num=@items;
	my $i=0;
	for ($i=0;$i<$num;$i++){
		my %newph=();
		foreach my $key(keys %ph){
			my @fiels=split(/\s\#\s/,$ph{$key} );
			my $n=@fiels;
			if($n==1){
				$newph{$key}=$ph{$key};
			}
			else{
				$newph{$key}=@fiels[$i];
			}
		}
		my $pro=FlyBase::Proforma::TI->new(db=>$mdbh);
		
			($feature,$id)=$pro->write_feature(%newph);
			print OUT $feature if(!$validate);
		
	}
}
  elsif($ph{key} eq 'INTERACTION' || exists($ph{IN1f})){
    my @items=split(/\s\#\s/,$ph{IN1f});
    my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
			my $pro=FlyBase::Proforma::Interaction->new(db=>$mdbh);
			
			($feature,$id)=$pro->write_interaction(%newph);
			print OUT $feature if(!$validate);
		
		}
   } 
  elsif($ph{key} eq 'TC' || $ph{key} eq 'CULTURED' || exists($ph{TC1a})){
		my @items=split(/\s\#\s/,$ph{TC1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
			my $pro=FlyBase::Proforma::Cell_line->new(db=>$mdbh);
			
			($feature,$id)=$pro->write_cell_line(%newph);
			print OUT $feature if(!$validate);
		
		}
  }
  elsif($ph{key} eq 'MS' || $ph{key} eq 'MOLECULAR' || exists($ph{MS1a})){
		my @items=split(/\s\#\s/,$ph{MS1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
			my $pro=FlyBase::Proforma::TP->new(db=>$mdbh);
			
			($feature,$id)=$pro->write_feature(%newph);
			print OUT $feature if(!$validate);
		
		}
  }
   elsif($ph{key} eq 'DATASET/COLLECTION' || exists($ph{LC1a})){
		my @items=split(/\s\#\s/,$ph{LC1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
			my $pro=FlyBase::Proforma::Library->new(db=>$mdbh);
			
			($feature,$id)=$pro->write_library(%newph);
			print OUT $feature if(!$validate);
		
		}
  }
  elsif($ph{key} eq 'TE' || $ph{key} eq 'NATURAL'  || exists($ph{TE1a})){
		my @items=split(/\s\#\s/,$ph{TE1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
			my $pro=FlyBase::Proforma::TE->new(db=>$mdbh);
		
			($feature,$temp)=$pro->write_feature(%newph);
			print OUT $feature if(!$validate);
			
		}
 }
   elsif($ph{key} eq 'ABERRATION' || exists($ph{A1a})){
	  	my @items=split(/\s\#\s/,$ph{A1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
			else{
					$newph{$key}=@fiels[$i];
				}
			}
		my $pro=FlyBase::Proforma::Aberr->new(db=>$mdbh);
		
			($feature,$id)=$pro->write_feature(%newph);
			$aberr=$id;
			print OUT $feature if(!$validate);
		
	}
 }
  elsif($ph{key} eq 'GENOTYPE VARIANT' || exists($ph{AB1a})){	
  	 		my @items=split(/\s\#\s/,$ph{AB1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
		my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
	  my $pro=FlyBase::Proforma::Balancer->new(db=>$mdbh);
	  
	 ($feature,$temp)=$pro->write_feature(%newph);
	 print OUT $feature if(!$validate);
	 
}
 } elsif( exists($ph{F1a}) || $ph{key} eq 'GENEPRODUCT'){
		my @items=split(/\s\#\s/,$ph{F1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
		 my $pro=FlyBase::Proforma::Feature->new(db=>$mdbh);
		 ($feature,$id)=$pro->write_feature(%newph);
		 print OUT $feature if(!$validate);
		}
  }
 elsif($ph{key} eq 'GENE' || exists($ph{G1a})){
			my @items=split(/\s\#\s/,$ph{G1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
		 my $pro=FlyBase::Proforma::Gene->new(db=>$mdbh);
	
			 ($feature,$gene)=$pro->write_feature(%newph);
			 print OUT $feature if(!$validate);
		}
  } elsif($ph{key} eq 'SEQUENCE' || exists($ph{SF1a})){
	  	my @items=split(/\s\#\s/,$ph{SF1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
		my $pro=FlyBase::Proforma::SF->new(db=>$mdbh);
		($feature,$temp)=$pro->write_feature(%newph);
		print OUT $feature if(!$validate);
	}
	}
   elsif($ph{key} eq 'ALLELE' || exists($ph{GA1a})){
	  	my @items=split(/\s\#\s/,$ph{GA1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
		my $pro=FlyBase::Proforma::Allele->new(db=>$mdbh);
		($feature,$temp)=$pro->write_feature(%newph);
		print OUT $feature if(!$validate);
	}
}
  elsif($ph{key} eq 'STRAIN' || exists($ph{SN1a})){
    my @items=split(/\s\#\s/,$ph{SN1a});
    my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
			my $pro=FlyBase::Proforma::Strain->new(db=>$mdbh);
			($feature,$id)=$pro->write_strain(%newph);
			print OUT $feature if(!$validate);
		
		}
   } 
  elsif($ph{key} eq 'DATABASE' || exists($ph{DB1a})){
#    print STDERR "write_chadoxml_first DATABASE\n";
    my @items=split(/\s\#\s/,$ph{DB1a});
    my $num=@items;
#    print STDERR "num = $num items\n";
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
#			  print STDERR "$key\n";
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
			my $pro=FlyBase::Proforma::DB->new(db=>$mdbh);
			($feature,$id)=$pro->write_db_table(%newph);
			print OUT $feature if(!$validate);
		
		}
   }
#HUMAN HEALTH MODEL PROFORMA
  elsif($ph{key} eq 'HUMAN HEALTH' || exists($ph{HH1b})){
    my @items=split(/\s\#\s/,$ph{HH1b});
    my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
			my $pro=FlyBase::Proforma::HH->new(db=>$mdbh);
			($feature,$id)=$pro->write_humanhealth(%newph);
			print OUT $feature if(!$validate);
		
		}
   } 
#GENEGROUP PROFORMA
  elsif( exists($ph{GG1A}) || $ph{key} eq 'GENEGROUP'){
    my @items=split(/\s\#\s/,$ph{GG1a});
    my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
			my $pro=FlyBase::Proforma::GG->new(db=>$mdbh);
			($feature,$id)=$pro->write_genegroup(%newph);
			print OUT $feature if(!$validate);
		
		}
   }

 #EXPERIMENTAL TOOL PROFORMA
  elsif( $ph{key} eq 'EXPERIMENTAL TOOL' || exists($ph{TO1a}) ){
    print STDERR "write_chadoxml_first EXPERIMENTAL TOOL pub $ph{pub}\n";
    my @items=split(/\s\#\s/,$ph{TO1a});
    my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
			my $pro=FlyBase::Proforma::Tool->new(db=>$mdbh);
			($feature,$id)=$pro->write_feature(%newph);
			print OUT $feature if(!$validate);
		
		}
   }

  elsif($ph{key} eq 'SPECIES' || exists($ph{SP1a})){
#    print STDERR "write_chadoxml_first SPECIES \n";
    my @items=split(/\s\#\s/,$ph{SP1a});
    my $num=@items;
    print STDERR "num = $num items\n";
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
			  print STDERR "$key\n";
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
			my $pro=FlyBase::Proforma::Species->new(db=>$mdbh);
			($feature,$id)=$pro->write_species(%newph);
			print OUT $feature if(!$validate);
		
		}
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
  print STDERR "-----------------------\n";

  
 if($pub=~/^\d+$/){
      $zeros='0'x(7-length($pub));
      $pub_id='FBrf'.$zeros.$pub;
 }else{
      $pub_id=$pub;
 }

 
  $cur_id=$cur_name{$curator};
  
  if($cur_id eq ''){
    $cur_id=$curator;
  }
  $ph{pub}=$pub_id;
  if($p1 ne ""){
  $ph{p_type}=$p1;
  }
  $ph{cur}=$cur_id;
 
  if($aberr ne ''){
	$ph{aberr}=$aberr;
  }
  if($gene ne ''){
	$ph{gene}=$gene;
  }

  if($ph{key}eq 'MA' || exists($ph{MA1a})){
	my @items=split(/\s\#\s/,$ph{MA1a});
	my $num=@items;
	my $i=0;
	for ($i=0;$i<$num;$i++){
		my %newph=();
		foreach my $key(keys %ph){
			my @fiels=split(/\s\#\s/,$ph{$key} );
			my $n=@fiels;
			if($n==1){
				$newph{$key}=$ph{$key};
			}
			else{
				$newph{$key}=@fiels[$i];
			}
		}
		my $pro=FlyBase::Proforma::TI->new(db=>$mdbh);
		 if($validate==1){
			$pro->validate(%newph);
		 }
		 else{
			$feature=$pro->process(%newph);
			print OUT $feature;
		}
	}
}
  elsif($ph{key} eq 'PUBLICATION'){
                my $pro=FlyBase::Proforma::Pub->new(db=>$mdbh);
                 if($validate==1){
                    $pro->validate(%ph);
                }
                 else{
                   ($feature,$id)=$pro->process(%ph);
                   $pub=$id;
                  $p1=$ph{P1};
                  print OUT $feature if(!$validate && $pub ne 'FBrf0000000');
        }
 }
  elsif($ph{key} eq 'MS' || $ph{key} eq 'MOLECULAR' || exists($ph{MS1a})){
		my @items=split(/\s\#\s/,$ph{MS1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
			my $pro=FlyBase::Proforma::TP->new(db=>$mdbh);
			 if($validate==1){
		 $pro->validate(%newph);
		 }
		 else{
			$feature=$pro->process(%newph);
			print OUT $feature if(!$validate);
		}
		}
  }
     elsif($ph{key} eq 'CULTURED' || exists($ph{TC1a})){
		my @items=split(/\s\#\s/,$ph{TC1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
			my $pro=FlyBase::Proforma::Cell_line->new(db=>$mdbh);
			 if($validate==1){
		 $pro->validate(%newph);
		 }
		 else{
			$feature=$pro->process(%newph);
			print OUT $feature if(!$validate);
		}
		}
  }
      elsif($ph{key} eq 'INTERACTION' || exists($ph{IN1f})){
		my @items=split(/\s\#\s/,$ph{IN1f});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
			my $pro=FlyBase::Proforma::Interaction->new(db=>$mdbh);
			 if($validate==1){
		      $pro->validate(%newph);
		  }
		  else{
			$feature=$pro->process(%newph);
			print OUT $feature if(!$validate);
		}
		}
  }
    elsif($ph{key} eq 'DATASET/COLLECTION' || exists($ph{LC1a})){
		my @items=split(/\s\#\s/,$ph{LC1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
			my $pro=FlyBase::Proforma::Library->new(db=>$mdbh);
			 if($validate==1){
		 $pro->validate(%newph);
		 }
		 else{
			$feature=$pro->process(%newph);
			print OUT $feature if(!$validate);
		}
		}
  }
     elsif($ph{key} eq 'SEQUENCE FEATURE/MAPPED ENTITIES PROFORMA' || exists($ph{SF1a})){
		my @items=split(/\s\#\s/,$ph{SF1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
			my $pro=FlyBase::Proforma::SF->new(db=>$mdbh);
			 if($validate==1){
		 $pro->validate(%newph);
		 }
		 else{
			$feature=$pro->process(%newph);
			print OUT $feature if(!$validate);
		}
		}
  }
  elsif($ph{key} eq 'TE' || exists($ph{TE1a})){
		my @items=split(/\s\#\s/,$ph{TE1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
			my $pro=FlyBase::Proforma::TE->new(db=>$mdbh);
			 if($validate==1){
		 $pro->validate(%newph);
		 }
		 else{
			$feature=$pro->process(%newph);
			print OUT $feature if(!$validate);
			}
		}
 }
   elsif($ph{key} eq 'ABERRATION' || exists($ph{A1a})){
	  	my @items=split(/\s\#\s/,$ph{A1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
			else{
					$newph{$key}=@fiels[$i];
				}
			}
		my $pro=FlyBase::Proforma::Aberr->new(db=>$mdbh);
		 if($validate==1){
			$pro->validate(%newph);
		 }
		 else{
			($feature,$id)=$pro->process(%newph);
			$aberr=$id;
			print OUT $feature if(!$validate);
		}
	}
 }
  elsif($ph{key} eq 'GENOTYPE VARIANT' || exists($ph{AB1a})){	
  	 		my @items=split(/\s\#\s/,$ph{AB1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
		my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
	  my $pro=FlyBase::Proforma::Balancer->new(db=>$mdbh);
	   if($validate==1){
		 $pro->validate(%newph);
		 }
		 else{
	 $feature=$pro->process(%newph);
	 print OUT $feature if(!$validate);
	 }
}
 }
 elsif($ph{key} eq 'GENE' || exists($ph{G1a})){
			my @items=split(/\s\#\s/,$ph{G1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
		 my $pro=FlyBase::Proforma::Gene->new(db=>$mdbh);
		 if($validate==1){
		 $pro->validate(%newph);
		 }
		 else{
			 ($feature,$gene)=$pro->process(%newph);
			 print OUT $feature if(!$validate);
		}
		}
  }
   elsif($ph{key} eq 'GENEPRODUCT' || exists($ph{F1a})){
			my @items=split(/\s\#\s/,$ph{F1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
		 my $pro=FlyBase::Proforma::Feature->new(db=>$mdbh);
		 if($validate==1){
		 $pro->validate(%newph);
		 }
		 else{
			 $feature=$pro->process(%newph);
			 print OUT $feature if(!$validate);
		}
		}
  }
   elsif($ph{key} eq 'ALLELE' || exists($ph{GA1a})){
	  	my @items=split(/\s\#\s/,$ph{GA1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
		my $pro=FlyBase::Proforma::Allele->new(db=>$mdbh);
		if($validate==1){
		 $pro->validate(%newph);
		 }
		 else{
		$feature=$pro->process(%newph);
		print OUT $feature if(!$validate);
	}
	}
  }

   elsif($ph{key} eq 'STRAIN' || exists($ph{SN1a})){
	  	my @items=split(/\s\#\s/,$ph{SN1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
		my $pro=FlyBase::Proforma::Strain->new(db=>$mdbh);
		if($validate==1){
		 $pro->validate(%newph);
		 }
		 else{
		   $feature=$pro->process(%newph);
		   print OUT $feature if(!$validate);
		 }
		      }
	      }
  elsif($ph{key} eq 'DATABASE' || exists($ph{DB1a})){
#    print STDERR "write_chadoxml_second DATABASE\n";
    my @items=split(/\s\#\s/,$ph{DB1a});
    my $num=@items;
    my $i=0;
    for ($i=0;$i<$num;$i++){
      my %newph=();
      foreach my $key(keys %ph){
	my @fiels=split(/\s\#\s/,$ph{$key} );
	my $n=@fiels;
	if($n==1){
	  $newph{$key}=$ph{$key};
	}
	else{
	  $newph{$key}=@fiels[$i];
	}
      }
      my $pro=FlyBase::Proforma::DB->new(db=>$mdbh);
      if($validate==1){
	$pro->validate(%newph);
      }
      else{
#	print STDERR "calling process\n";
	$feature=$pro->process(%newph);
	print OUT $feature if(!$validate);
      }
    }
  }
#HUMAN HEALTH MODEL PROFORMA
   elsif($ph{key} eq 'HUMAN HEALTH' || exists($ph{HH1b})){
	  	my @items=split(/\s\#\s/,$ph{HH1b});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
		my $pro=FlyBase::Proforma::HH->new(db=>$mdbh);
		if($validate==1){
		 $pro->validate(%newph);
		 }
		 else{
		   $feature=$pro->process(%newph);
		   print OUT $feature if(!$validate);
		 }
		      }
	      }
#GENEGROUP PROFORMA
 elsif($ph{key} eq 'GENEGROUP' || exists($ph{GG1a})){
			my @items=split(/\s\#\s/,$ph{GG1a});
		my $num=@items;
		my $i=0;
		for ($i=0;$i<$num;$i++){
			my %newph=();
			foreach my $key(keys %ph){
				my @fiels=split(/\s\#\s/,$ph{$key} );
				my $n=@fiels;
				if($n==1){
					$newph{$key}=$ph{$key};
				}
				else{
					$newph{$key}=@fiels[$i];
				}
			}
		 my $pro=FlyBase::Proforma::GG->new(db=>$mdbh);
		 if($validate==1){
		 $pro->validate(%newph);
		 }
		 else{
			 $feature=$pro->process(%newph);
			 print OUT $feature if(!$validate);
		}
		}
  }
  elsif($ph{key} eq 'SPECIES' || exists($ph{SP1a})){
#    print STDERR "write_chadoxml_second SPECIES\n";
    my @items=split(/\s\#\s/,$ph{SP1a});
    my $num=@items;
    my $i=0;
    for ($i=0;$i<$num;$i++){
      my %newph=();
      foreach my $key(keys %ph){
	my @fiels=split(/\s\#\s/,$ph{$key} );
	my $n=@fiels;
	if($n==1){
	  $newph{$key}=$ph{$key};
	}
	else{
	  $newph{$key}=@fiels[$i];
	}
      }
      my $pro=FlyBase::Proforma::Species->new(db=>$mdbh);
      if($validate==1){
	$pro->validate(%newph);
      }
      else{
#	print STDERR "calling process\n";
	$feature=$pro->process(%newph);
	print OUT $feature if(!$validate);
      }
    }
  }
  elsif($ph{key} eq 'EXPERIMENTAL TOOL' || exists($ph{TO1a})){	
    print STDERR "write_chadoxml_second EXPERIMENTAL TOOL $ph{pub}\n";
      my @items=split(/\s\#\s/,$ph{TO1a});
      my $num=@items;
      my $i=0;
      for ($i=0;$i<$num;$i++){
	  my %newph=();
	  foreach my $key(keys %ph){
	      my @fiels=split(/\s\#\s/,$ph{$key} );
	      my $n=@fiels;
	      if($n==1){
		  $newph{$key}=$ph{$key};
	      }
	      else{
		  $newph{$key}=@fiels[$i];
	      }
	  }
	  my $pro=FlyBase::Proforma::Tool->new(db=>$mdbh);
	  if($validate==1){
	      $pro->validate(%newph);
	  }
	  else{
	      $feature=$pro->process(%newph);
	      print OUT $feature if(!$validate);
	  }
      }
  }

} 

__END__

    © 2019 GitHub, Inc.
    Terms
    Privacy
    Security
    Status
    Help

    Contact GitHub
    Pricing
    API
    Training
    Blog
    About

