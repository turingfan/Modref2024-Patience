#!/bin/bash

usage() {
    echo "Usage: $0 <train_seeds> <total_seeds> <timeout_seconds>"
}

isnumber() {
    [[ "$1" == ?(-)+([0-9]) ]]
}

if [ $# -lt 3 ]; then
    echo "Incorrect number of arguments supplied" && usage
    exit 1
fi

seeds=$1
total_seeds=$2
timeout=$3
granularity=10

let "seeds++"

./calculate_par10.py data/1_solvitaire_no_streamliner.csv $timeout $1 | tr -d '\n'
echo -n ','
./calculate_fraction_certain.py data/1_solvitaire_no_streamliner.csv $timeout $1 | tr -d '\n'
echo -n ','

./calculate_par10.py data/2_solvitaire_streamliner.csv $timeout $1 | tr -d '\n'
echo -n ','
./calculate_fraction_certain.py data/2_solvitaire_streamliner.csv $timeout $1 | tr -d '\n'
echo -n ','

./calculate_par10.py data/4_unblocked_relaxed_stock.csv $timeout $1 | tr -d '\n'
echo -n ','
./calculate_fraction_certain.py data/4_unblocked_relaxed_stock.csv $timeout $1 | tr -d '\n'
echo -n ','

./calculate_par10.py data/3_unblocked_full_stock.csv $timeout $1 | tr -d '\n'
echo -n ','
./calculate_fraction_certain.py data/3_unblocked_full_stock.csv $timeout $1 | tr -d '\n'
echo -n ','

./calculate_par10.py data/4_unblocked_relaxed_stock.csv,data/1_solvitaire_no_streamliner.csv $timeout $1 | tr -d '\n'
echo -n ','
./calculate_fraction_certain.py data/4_unblocked_relaxed_stock.csv,data/1_solvitaire_no_streamliner.csv $timeout $1 | tr -d '\n'
echo -n ','

./calculate_par10.py data/3_unblocked_full_stock.csv,data/1_solvitaire_no_streamliner.csv $timeout $1 | tr -d '\n'
echo -n ','
./calculate_fraction_certain.py data/3_unblocked_full_stock.csv,data/1_solvitaire_no_streamliner.csv $timeout $1 | tr -d '\n'
echo -n ','

./calculate_par10.py data/2_solvitaire_streamliner.csv,data/1_solvitaire_no_streamliner.csv $timeout $1 | tr -d '\n'
echo -n ','
./calculate_fraction_certain.py data/2_solvitaire_streamliner.csv,data/1_solvitaire_no_streamliner.csv $timeout $1

