package FlyBase::Proforma::Assays;

use strict;
use warnings;
require Exporter;
use Carp qw(croak);
our @ISA = qw(Exporter);

our %EXPORT_TAGS = (
    'all' => [
	         qw(
                  %ASSAYS 				
				          )
						     ]
 );
					  
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );
our %ASSAYS = (is => 'in situ',
	       rs => 'RNA-seq',
	       scrs => 'single cell RNA-seq',
	       vis => 'virtual in situ hybridization',
	       nb => 'northern blot',
	       db => 'dot blot',
	       de => 'distribution deduced from reporter',
	       debs => 'distribution deduced from reporter (Gal4 UAS)',
	       rp => 'RNase protection, primer extension, SI map',
	       mi => 'miscellaneous',
	       pc => 'pcr',
	       race => 'RACE',
	       ri => 'radioisotope in situ',
	       rtpc => 'RT-PCR',
	       dt => 'dissected tissue',
	       vc => 'votage clamp',
	       er => 'electrical recording',
	       em => 'electron microscopy',
	       as => 'antisense RNA probes',
	       ema => 'expression microarray',
	       il => 'immunolocalization',
	       ea => 'enzyme assay or biochemical detection',
	       wb => 'western blot',
	       sp => 'spectrophotometric analysis',
	       id => 'immunodetection (other than il)',
	       ih => 'immunohistochemistry',
	       vc => 'voltage clamp',
	       er => 'electrical recording',
	       em => 'electron microscopy',
	       dt => 'dissected tissue',
	       el => 'electrophoresis',
	       et => 'epitope tag',
	       ms => 'mass spectroscopy',
	       dep => 'distribution deduced from reporter or direct label',
	       cef => 'cell fractionation',
	       xr => 'x-ray crystallography',
	       ip => 'immunoprecipitation',
	       yh => 'yeast hybrid (one, two, three)',
	       cl => 'crosslink',
	       cc => 'column chromatography',
	       gs => 'gel shift assay',
	       fp => 'foot print',
	       ta => 'transfection assay',
	       ib => 'in vitro binding assay',
	       ov => 'overlay assay',
	       act => 'activity',
	       aff => 'affinity binding',
	       ias => 'inferred from author statements',
	       ga => 'genetic assay',
	       tani => 'transfection assay, non-insect cells',
	       tai => 'transfection assay insect cells',
	       tad => 'transfection assay Drosophila cells',
	       cf => 'co-fractionation',
	       y1h => 'yeast one hybrid assay',
	       mi => 'microinjection',
	       ir => 'inferred from reporter assay',
	       nda => 'inferred from assay with non-Drosophila orthologs',
	       ma => 'mutational analysis',
	       cca => 'cell culture assay',
	       pa => 'peptide analysis',
	       hplc => 'HPLC',
	       aa => 'aggregation assay',
	       rca => 'reporter complementation assay',
	       imem => 'immuno-electron microscopy',
	       isrp => 'in situ RT-PCR'
	  );

1;
