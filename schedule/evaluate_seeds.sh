#!/bin/bash

usage() {
    echo "Usage: $0 <eprime_location> <seeds> <timeout_seconds> <data directory>"
}

isnumber() {
    [[ "$1" == ?(-)+([0-9]) ]]
}

if [ $# -lt 4 ]; then
    echo "Incorrect number of arguments supplied" && usage
    exit 1
fi

model=$1
seeds=$2
timeout=$3
data_directory=$4
granularity=10

let "seeds++"

temp_directory="temp"

test -d $data_directory/$temp_directory || mkdir $data_directory/$temp_directory

(
    cd $data_directory; 
    for f in ./*.csv; do
        cat $f | head -n $seeds > "$temp_directory/$f"
    done
)

param_name="temp.param"

./create_param_from_csv.py $data_directory/$temp_directory $param_name $granularity $timeout > /dev/null

savilerow $model $param_name -run-solver -solutions-to-stdout -chuffed -O1 2> /dev/null && cat $param_name.info 

rm $param_name*
rm -rf $data_directory/$temp_directory
