#!/bin/bash
input=${1}
#"weight_mem_batch2.mem"
i=0
while IFS= read -r line
do
    touch weight_mem${i}.mem
    echo "$line" > weight_mem${i}.mem
    i=$((i+1))
  #echo "$line"
done < "$input"
