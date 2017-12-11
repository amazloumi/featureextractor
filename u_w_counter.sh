#!/bin/bash

if [ ! $# == 2 ]; then
    echo "Dude! Invoke like this: $0 <print_all-file> <interval-in-seconds>";
    exit;
fi

file=$1
interval=$2

if [[ $interval -lt 1 ]]; then
   echo "Dude! Really! interval should be greater than 0"
   exit
fi

start_time=$(grep -m 1 "Timestamp" $file | cut -d' ' -f6-7 | cut -d'(' -f2 | cut -d')' -f1)
finish_time=$(grep "Timestamp" $file | tail -n 1 | cut -d' ' -f6-7 | cut -d'(' -f2 | cut -d')' -f1)
finish_time=$(date -d "$finish_time" '+%m/%d/%Y %H:%M:%S')

start_line=1
numLine=$(wc -l < $file)
end_line=0

finish=false

i=1

# main program
while [[ $end_line -lt $numLine ]]; do
next_time=$(date -d "$start_time $interval seconds" '+%m/%d/%Y %H:%M:%S')
start_time=$next_time
next_time=$(echo $next_time | cut -d' ' -f2)

end_line=$(grep -n -m 1 "$next_time" $file | cut -d':' -f1)

if [[ $end_line -eq 0 ]]; then

  next_time=$start_time
  while [[ ($end_line -eq 0) && ($next_time < $finish_time) ]]; do
     next_time=$(date -d "$next_time 1 seconds" '+%m/%d/%Y %H:%M:%S')
     temp_time=$(echo $next_time | cut -d' ' -f2)
     end_line=$(grep -n -m 1 "$temp_time" $file | cut -d':' -f1)
  done

  if [[ $end_line -eq 0 ]]; then
     end_line=$numLine
     finish=true;
  fi

fi

tail_line=$((end_line - start_line))
start_line=$end_line

if [[ $finish = false ]]; then
let end_line--
else
let tail_line++
fi

head -n $end_line $file | tail -n $tail_line > tmp

# ---------------------------
# calling functions
# ---------------------------

n_updates=$(grep -n -c "Withdrawn Routes Length:" tmp)
n_annonce=$(grep -n -c "Withdrawn Routes Length: 0" tmp)
n_withrow=$((n_updates - n_annonce))

echo "$i: numUpdates: $n_updates | numWithdrow: $n_withrow | numAnnounce: $n_annonce"

# ---------------------------
# end of calling functin area
# ---------------------------

rm -f tmp
let i++
done
