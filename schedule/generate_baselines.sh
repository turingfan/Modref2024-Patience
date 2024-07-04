#!/bin/bash

usage() {
    echo "Usage: $0 <output_csv>"
}

isnumber() {
    [[ "$1" == ?(-)+([0-9]) ]]
}

if [ $# -lt 1 ]; then
    echo "Incorrect number of arguments supplied" && usage
    exit 1
fi

csv=$1
seeds=1000
total_seeds=10000
granularity=10

echo "timeout,test_par10_solvitaire_no_streamliner,test_fraction_solvitaire_no_streamliner,test_par10_streamliner,test_fraction_streamliner,test_par10_relaxed,test_fraction_relaxed,test_par10_strict,test_fraction_strict,test_par10_relaxed-solvitaire_no_streamliner,test_fraction_relaxed-solvitaire_no_streamliner,test_par10_strict-solvitaire_no_streamliner,test_fraction_strict-solvitaire_no_streamliner,test_par10_streamliner-solvitaire_no_streamliner,test_fraction_streamliner-solvitaire_no_streamliner" > $csv

for i in $(seq 1 10); do
    echo "Processing timeout $i"
    echo -n "$i," >> $csv
    ./generate_baseline.sh $seeds $total_seeds $i $granularity >> $csv
done

for i in $(seq 12 2 28); do
    echo "Processing timeout $i"
    echo -n "$i," >> $csv
    ./generate_baseline.sh $seeds $total_seeds $i $granularity >> $csv
done

for i in $(seq 30 10 120); do
    echo "Processing timeout $i"
    echo -n "$i," >> $csv
    ./generate_baseline.sh $seeds $total_seeds $i $granularity >> $csv
done
