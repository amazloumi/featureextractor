#!/bin/bash

if [ ! $# == 2 ]; then
    echo "Dude! Invoke like this: $0 <bgpdump-file> <interval-in-seconds>";
    exit;
fi

file=$1
interval=$2

if [[ $interval -lt 1 ]]; then
   echo "Dude! Really! interval should be greater than 0"
   exit
fi

start_time=$(head -n 1 $file | cut -d'|' -f2)
finish_time=$(tail -n 1 $file | cut -d'|' -f2)
finish_time=$(date -d "$finish_time" '+%m/%d/%Y %H:%M:%S')

start_line=1
numLine=$(wc -l < $file)
end_line=0

finish=false

i=1

# write functions here
function withdrow_annonced_prefixes {
  n_wp=$(grep -c "|W|" tmp) 
  n_ap=$(grep -c "|A|" tmp)
  n_up=$((n_ap + n_wp))
  echo -n "$i: WithdwPrefix: $n_wp | AnnouPrefix: $n_ap | UpdatedPrefix: $n_up"
}

function ww_aa_dup {
	n_wwdup=$(sort tmp | grep "|W|" | cut -d'|' -f3- | uniq -d | wc -l)
	n_aadup1=$(sort tmp | grep "|A|" | cut -d'|' -f3- | rev | cut -d'|' -f2- | rev | uniq -d | wc -l)
	n_aadup2=$(sort tmp | grep "|A|" | cut -d'|' -f6-7 | uniq -d | wc -l)

	grep "|A|" tmp | cut -d'|' -f5-6 | sort | uniq > tmp2
	grep "|W|" tmp | cut -d'|' -f5-6 | sort | uniq >> tmp2

	n_aw_mix=$(sort tmp2 | uniq -cd | wc -l)

	rm tmp2

	echo " | WWDup: $n_wwdup | AADupType1: $n_aadup1 | AADupType2: $n_aadup2 | n_aw_mix: $n_aw_mix"
}

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

withdrow_annonced_prefixes
ww_aa_dup

# ---------------------------
# end of calling functin area
# ---------------------------

rm -f tmp
let i++
done
