#!/bin/bash

##### this script is to calculate reads_count from sample.log(trimming)

echo -e "sample_ID \t total_input \t both_survive \t both_ratio \t forward_survive \t forward_ratio \t reverse_survive \t reverse_ratio \t drop \t drop_ratio" >../reads_count/trimming_count.txt

for sample in *bam

do

  i=$(echo ${sample%.bam})
  
##### to take a look at if the file exist   
  
  if [ ! -e ./$i/$i.log ]
  
  then
  
  echo "$i.log can not be found "
  echo -e "$i.not_exist \t"  >> ../reads_count/trimming_count.txt
  
  else
  
  input=$(cat ./$i/$i.log | grep "Input Read Pairs")
  
  total=$(echo $input | awk -F " " '{print $4}')
  both=$(echo $input | awk -F " " '{print $7}')
  both_ratio=$(echo $input | awk -F " " '{print $8}')
  forward=$(echo $input | awk -F " " '{print $12}')
  forward_ratio=$(echo $input | awk -F " " '{print $13}')
  reverse=$(echo $input | awk -F " " '{print $17}')
  reverse_ratio=$(echo $input | awk -F " " '{print $18}')
  drop=$(echo $input | awk -F " " '{print $20}')
  drop_ratio=$(echo $input | awk -F " " '{print $21}')
  
  echo -e "$i \t $total \t $both \t $both_ratio \t $forward \t $forward_ratio \t $reverse \t $reverse_ratio \t $drop \t $drop_ratio" >> ../reads_count/trimming_count.txt

  fi
  
done
