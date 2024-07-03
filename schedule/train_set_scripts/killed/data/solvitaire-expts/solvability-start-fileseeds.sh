#!/bin/bash


if [ "$#" != 5 ]; then
    echo "Usage: cores> \"<solvitaire_command>\" <output_file>"
    echo "e.g.: ./solvability-start.sh seeds-to-run.txt 40 50G \"./solvitaire --type alpha-star --timeout 6000 --str smart-solvability\" results"
    exit 1
fi

seeds="$1"
cores="$2"
minramfree="$3"
sol_command="$4"
out=`mktemp $5-XXXXXZ`

sort -R $seeds > $out

PARALLEL_ID_FIELD=\$25
echo $out 



time_command="/usr/bin/time -f \" %e, %U, %S, %M\""
combine_command="sed -e 'H;\${x;s/\n/,/g;s/^,//;p;};d'"

#completejobs=10


echo "CL: $0 $@" >> "$out.experiment"
echo "Host: $HOSTNAME: " >> "$out.experiment"
echo "StartDate: " `date` >> "$out.experiment"

echo "Attempted Seed, Outcome, Time Taken(ms), States Searched, Unique States Searched, Backtracks, Dominance Moves, States Removed From Cache, Final States In Cache, Final Buckets In Cache, Maximum Search Depth, Final Search Depth, real (time), user (time), sys (time) " >> "$out.experiment"

cat $out | parallel --joblog $out.log --memfree $minramfree -j"$cores" "exec $time_command $sol_command --ra {} --class 2>&1 | $combine_command >> $out.csv"

echo "MainRunEndDate: " `date` >> "$out.experiment"

# parallel --nice 4 --joblog $out.log --progress --retry-failed -j"$completejobs" 2>&1 

grep solved $out.csv | awk '{print $1}' | sed 's/,//' > $out.solved.txt
grep "[a-z].* unsolvable" $out.csv | awk '{print $1}' | sed 's/,//' > $out.unsolvable.txt
grep "[a-z].* timed" $out.csv | awk '{print $1}' | sed 's/,//' > $out.timedout.txt
grep "[a-z].* mem" $out.csv | awk '{print $1}' | sed 's/,//' > $out.memout.txt
grep "\s-1\s" $out.log | awk "{print $PARALLEL_ID_FIELD}" > $out.failed.txt

sort -n $out $out.solved.txt $out.unsolvable.txt $out.timedout.txt $out.memout.txt | uniq -u > $out.unrun.txt

echo "EndDate: " `date` >> "$out.experiment"

exit




