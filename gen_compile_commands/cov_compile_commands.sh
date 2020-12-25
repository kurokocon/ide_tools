#!/usr/bin/bash

set -x

params=("$@")

cc_param=${params[0]}
root_param=${params[1]}
file_params=${params[@]:2}

find $root_param \( -name '*.cc' -o -name '*.cpp' -o -name '*.h' -o -name '*.hpp' -o -name '*.c' \) ${file_params[@]} | python3 $(dirname $(realpath $0))/cov_compile_commands.py --cc_file $cc_param --interactive
