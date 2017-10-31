#!/bin/bash

echo -e "sample_name \t out1_file \t out1_file_status \t out2_file \t out2_file_status" > check_out.txt

dir=$(ls -l /groups/umcg-tifn/tmp03/LLD2/good/SN0131490 | grep .bam |awk '{print $9}')

for n in $dir

do

  i=$(echo ${n%.bam})

  if [ ! -e /groups/umcg-tifn/tmp03/LLD2/good/SN0131490/$i.out ] && [ ! -e /groups/umcg-tifn/tmp03/LLD2/good/SN0131490/$i.out2 ] 
  then 
  echo -e "$i \t NA \t NA \t NA \t NA \t" >> check_out.txt
  
  elif [ -e /groups/umcg-tifn/tmp03/LLD2/good/SN0131490/$i.out ] && [ ! -e /groups/umcg-tifn/tmp03/LLD2/good/SN0131490/$i.out2 ]
  then
  status=$(cat /groups/umcg-tifn/tmp03/LLD2/good/SN0131490/$i.out | grep -q "Total elapsed time" && echo "finised" || echo "erro")
  echo -e "$i \t Yes \t $status \t NA \t NA \t" >> check_out.txt
  
  elif [ ! -e /groups/umcg-tifn/tmp03/LLD2/good/SN0131490/$i.out ] && [ -e /groups/umcg-tifn/tmp03/LLD2/good/SN0131490/$i.out2 ]
  then
  status=$(cat /groups/umcg-tifn/tmp03/LLD2/good/SN0131490/$i.out2 | grep -q "Output files created" && echo "finised" || echo "erro")
  echo -e "$i \t NA \t NA \t Yes \t $status \t" >> check_out.txt
  
  else [ -e /groups/umcg-tifn/tmp03/LLD2/good/SN0131490/$i.out ] && [ -e /groups/umcg-tifn/tmp03/LLD2/good/SN0131490/$i.out2 ]
  status1=$(cat /groups/umcg-tifn/tmp03/LLD2/good/SN0131490/$i.out | grep -q "Total elapsed time" && echo "finised" || echo "erro")
  status2=$(cat /groups/umcg-tifn/tmp03/LLD2/good/SN0131490/$i.out2 | grep -q "Output files created" && echo "finised" || echo "erro")
  echo -e  "$i \t Yes \t $status1 \t Yes \t $status2 \t" >> check_out.txt

  fi
  
done
