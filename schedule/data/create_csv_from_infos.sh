#!/bin/bash

usage() {
    echo "Usage: $0 <tar archive location>"
}

if [ $# -lt 1 ]; then
    echo "Incorrect number of arguments supplied" && usage
    exit 1
fi

tar_location=$1


if [ ! -f "$tar_location" ]; then
    echo "The tarfile location provided doesn't exist" && usage && exit 2
fi

base=$(basename -- "$tar_location")

dirname="${base%.*}"

echo "Unzipping"

test -d $dirname || tar -xvzf $tar_location > /dev/null

strict_dirname="strict_stock"
relaxed_dirname="relaxed_stock"

strict_path="$dirname/$strict_dirname"
relaxed_path="$dirname/$relaxed_dirname"

deal_1="deal_1"
deal_3="deal_3"

first_10k_dirname="first_10k"
hardest_1k_dirname="hardest_1000"
directly_unknown_dirname="directly_unknown"

echo "Making subdirectories"

test -d "$strict_path" || mkdir "$strict_path"
test -d "$relaxed_path" || mkdir "$relaxed_path"

test -d "$strict_path/$first_10k_dirname" || mkdir "$strict_path/$first_10k_dirname"
test -d "$strict_path/$hardest_1k_dirname" || mkdir "$strict_path/$hardest_1k_dirname"
test -d "$strict_path/$directly_unknown_dirname" || mkdir "$strict_path/$directly_unknown_dirname"

test -d "$relaxed_path/$first_10k_dirname" || mkdir "$relaxed_path/$first_10k_dirname"
test -d "$relaxed_path/$hardest_1k_dirname" || mkdir "$relaxed_path/$hardest_1k_dirname"
test -d "$relaxed_path/$directly_unknown_dirname" || mkdir "$relaxed_path/$directly_unknown_dirname"

test -d "$strict_path/$first_10k_dirname/$deal_1" || mkdir "$strict_path/$first_10k_dirname/$deal_1"
test -d "$strict_path/$first_10k_dirname/$deal_3" || mkdir "$strict_path/$first_10k_dirname/$deal_3"
test -d "$strict_path/$hardest_1k_dirname/$deal_1" || mkdir "$strict_path/$hardest_1k_dirname/$deal_1"
test -d "$strict_path/$hardest_1k_dirname/$deal_3" || mkdir "$strict_path/$hardest_1k_dirname/$deal_3"
test -d "$strict_path/$directly_unknown_dirname/$deal_1" || mkdir "$strict_path/$directly_unknown_dirname/$deal_1"
test -d "$strict_path/$directly_unknown_dirname/$deal_3" || mkdir "$strict_path/$directly_unknown_dirname/$deal_3"

test -d "$relaxed_path/$first_10k_dirname/$deal_1" || mkdir "$relaxed_path/$first_10k_dirname/$deal_1"
test -d "$relaxed_path/$first_10k_dirname/$deal_3" || mkdir "$relaxed_path/$first_10k_dirname/$deal_3"
test -d "$relaxed_path/$hardest_1k_dirname/$deal_1" || mkdir "$relaxed_path/$hardest_1k_dirname/$deal_1"
test -d "$relaxed_path/$hardest_1k_dirname/$deal_3" || mkdir "$relaxed_path/$hardest_1k_dirname/$deal_3"
test -d "$relaxed_path/$directly_unknown_dirname/$deal_1" || mkdir "$relaxed_path/$directly_unknown_dirname/$deal_1"
test -d "$relaxed_path/$directly_unknown_dirname/$deal_3" || mkdir "$relaxed_path/$directly_unknown_dirname/$deal_3"

echo "Organising files"

( cd $dirname ; mv *v1.2* "$strict_dirname" 2> /dev/null ) &
( cd $dirname ; mv *v1.0* "$relaxed_dirname" 2> /dev/null ) &

wait

( cd "$dirname/$strict_dirname" ; mv *first_10k* "$first_10k_dirname" 2> /dev/null ) &
( cd "$dirname/$strict_dirname" ; mv *hardest_1000* "$hardest_1k_dirname" 2> /dev/null ) &
( cd "$dirname/$strict_dirname" ; mv *directly_unknown* "$directly_unknown_dirname" 2> /dev/null ) &

( cd "$dirname/$relaxed_dirname" ; mv *first_10k* "$first_10k_dirname" 2> /dev/null ) &
( cd "$dirname/$relaxed_dirname" ; mv *hardest_1000* "$hardest_1k_dirname" 2> /dev/null ) &
( cd "$dirname/$relaxed_dirname" ; mv *directly_unknown* "$directly_unknown_dirname" 2> /dev/null ) &

wait

( cd "$dirname/$strict_dirname/$first_10k_dirname" ; mv *deal1* "$deal_1" 2> /dev/null ) &
( cd "$dirname/$strict_dirname/$first_10k_dirname" ; mv *deal3* "$deal_3" 2> /dev/null ) &
( cd "$dirname/$strict_dirname/$hardest_1k_dirname" ; mv *deal1* "$deal_1" 2> /dev/null ) &
( cd "$dirname/$strict_dirname/$hardest_1k_dirname" ; mv *deal3* "$deal_3" 2> /dev/null ) &
( cd "$dirname/$strict_dirname/$directly_unknown_dirname" ; mv *deal1* "$deal_1" 2> /dev/null ) &
( cd "$dirname/$strict_dirname/$directly_unknown_dirname" ; mv *deal3* "$deal_3" 2> /dev/null ) &

( cd "$dirname/$relaxed_dirname/$first_10k_dirname" ; mv *deal1* "$deal_1" 2> /dev/null ) &
( cd "$dirname/$relaxed_dirname/$first_10k_dirname" ; mv *deal3* "$deal_3" 2> /dev/null ) &
( cd "$dirname/$relaxed_dirname/$hardest_1k_dirname" ; mv *deal1* "$deal_1" 2> /dev/null ) &
( cd "$dirname/$relaxed_dirname/$hardest_1k_dirname" ; mv *deal3* "$deal_3" 2> /dev/null ) &
( cd "$dirname/$relaxed_dirname/$directly_unknown_dirname" ; mv *deal1* "$deal_1" 2> /dev/null ) &
( cd "$dirname/$relaxed_dirname/$directly_unknown_dirname" ; mv *deal3* "$deal_3" 2> /dev/null ) &

wait

echo "Converting to csvs"

./collate_infos.py "$strict_path/$first_10k_dirname/$deal_1" "$dirname/$strict_dirname-$first_10k_dirname-$deal_1-infos.csv" &
./collate_infos.py "$strict_path/$first_10k_dirname/$deal_3" "$dirname/$strict_dirname-$first_10k_dirname-$deal_3-infos.csv" &
./collate_infos.py "$strict_path/$hardest_1k_dirname/$deal_1" "$dirname/$strict_dirname-$hardest_1k_dirname-$deal_1-infos.csv" &
./collate_infos.py "$strict_path/$hardest_1k_dirname/$deal_3" "$dirname/$strict_dirname-$hardest_1k_dirname-$deal_3-infos.csv" &
./collate_infos.py "$strict_path/$directly_unknown_dirname/$deal_1" "$dirname/$strict_dirname-$directly_unknown_dirname-$deal_1-infos.csv" &
./collate_infos.py "$strict_path/$directly_unknown_dirname/$deal_3" "$dirname/$strict_dirname-$directly_unknown_dirname-$deal_3-infos.csv" &
./collate_infos.py "$relaxed_path/$first_10k_dirname/$deal_1" "$dirname/$relaxed_dirname-$first_10k_dirname-$deal_1-infos.csv" &
./collate_infos.py "$relaxed_path/$first_10k_dirname/$deal_3" "$dirname/$relaxed_dirname-$first_10k_dirname-$deal_3-infos.csv" &
./collate_infos.py "$relaxed_path/$hardest_1k_dirname/$deal_1" "$dirname/$relaxed_dirname-$hardest_1k_dirname-$deal_1-infos.csv" &
./collate_infos.py "$relaxed_path/$hardest_1k_dirname/$deal_3" "$dirname/$relaxed_dirname-$hardest_1k_dirname-$deal_3-infos.csv" &
./collate_infos.py "$relaxed_path/$directly_unknown_dirname/$deal_1" "$dirname/$relaxed_dirname-$directly_unknown_dirname-$deal_1-infos.csv" &
./collate_infos.py "$relaxed_path/$directly_unknown_dirname/$deal_3" "$dirname/$relaxed_dirname-$directly_unknown_dirname-$deal_3-infos.csv" &

wait

echo "Cleaning temporary directories"

rm -rf "$strict_path"
rm -rf "$relaxed_path"

echo "Done!"
