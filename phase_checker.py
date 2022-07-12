#!/usr/bin/env python3
import argparse
from pathlib import Path

import re
import sys

parser = argparse.ArgumentParser(description='Check for the existence of Camcur PHASE output.')
parser.add_argument('-p', '--phase',
                    help='The current PHASE being loaded. For example, \'PHASE4\'', required=True)
parser.add_argument('-e', '--epicycle',
                    help='The current epicycle being loaded. For example, \'epicycle4\'.', required=True)
parser.add_argument('-r', '--release',
                    help='The current release being loaded. For example, \'2018_04\'.', required=True)
args = parser.parse_args()

phase = args.phase
epicycle = args.epicycle
release = args.release

phase_number_simple = 0
epicycle_number_simple = 0

try:
    phase_number_simple = int(re.match("PHASE([0-9]+)$", phase).group(1))
except AttributeError:
    print('Please enter the PHASE number in the format: PHASE + number. e.g. PHASE4')
    sys.exit(-1)

try:
    epicycle_number_simple = int(re.match("epicycle([0-9]+)$", epicycle).group(1))
except AttributeError:
    print('Please enter the epicycle number in the format: epicycle + number. e.g. epicycle4')
    sys.exit(-1)

# Create all the possible output files for all previous (and current) PHASEs.
# Check for their existence.

for i in range(0, phase_number_simple):
    i = i + 1
    load_file = Path("/data/repositories/harvdev-perl-proforma-parser/cam_" + release + '_e'
                     + str(epicycle_number_simple) + '_p' + str(i) + '.load')
    xml_file = Path("/data/repositories/harvdev-perl-proforma-parser/cam_" + release + '_e'
                    + str(epicycle_number_simple) + '_p' + str(i) + '.xml')
    log_file = Path("/data/repositories/harvdev-perl-proforma-parser/cam_" + release + '_e'
                    + str(epicycle_number_simple) + '_p' + str(i) + '.log')

    file_list = [load_file, xml_file, log_file]

    for each_file in file_list:
        try:
            load_file_path = each_file.resolve()
            print('Successfully found %s' % each_file)
        except FileNotFoundError:
            print('FATAL ERROR!')
            print('Cannot find the file %s' % each_file)
            print('Please be sure this file exists before proceeding!')
            print('Did something not get parsered or loaded?')
            sys.exit(-1)
