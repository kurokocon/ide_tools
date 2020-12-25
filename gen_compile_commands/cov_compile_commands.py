#!/usr/bin/python3

import sys, os
from argparse import ArgumentParser
import json
from collections import defaultdict

def get_file_names(params):
    if params.interactive:
        return [line.strip() for line in sys.stdin]
    elif params.file == None:
        raise Error('Non-interactive mode with no file list specified; don\'t know what files to calc coverage for')

arg_parser = ArgumentParser()
arg_parser.add_argument('--interactive', action = 'store_true')
arg_parser.add_argument('--file')
arg_parser.add_argument('--cc_file', required=True)

result = arg_parser.parse_args(sys.argv[1:])

file_names = get_file_names(result)

compile_commands = json.loads(''.join(open(result.cc_file, 'rt').readlines()))

src_file_lst = sorted([f.split('/') for f in file_names])

compile_files = set([command['file'] for command in compile_commands])

path_total = defaultdict(lambda:0)
path_covered = defaultdict(lambda:0)

file_coverage = []

for f in src_file_lst:
    name = '/'.join(f)
    covered = 0
    if name in compile_files:
        covered = 1
        file_coverage.append('+' + name)
    else:
        file_coverage.append('-' + name)
    for i in range(1, len(f)):
        path = '/'.join(f[:i])
        path_total[path]+=1
        path_covered[path]+=covered
cov_output = open('coverage.txt', 'wt')
file_output = open('coverage_files.txt', 'wt')

for path,total in path_total.items():
    if path not in path_covered:
        print('Error:mismatched path:' + path,file=cov_output)
    print(path + ':' + str(path_covered[path] / total), file=cov_output)
for f in file_coverage:
    print(f, file=file_output)
