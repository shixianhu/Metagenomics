#!/bin/bash

echo -e "Sample_name \t metaphlan \t humann2" > metagenomics_checkout.txt

dir=$(ls -l /groups/umcg-tifn/tmp03/LLD2/good/husx_test/fix_err/samples/ | grep .bam |awk '{print $9}')

for n in $dir

do

  i=$(echo ${n%.bam})

  if [ ! -e /groups/umcg-tifn/tmp03/LLD2/good/husx_test/fix_err/samples/$i/metaphlan/$i\_metaphlan.txt ] && [ ! -e /groups/umcg-tifn/tmp03/LLD2/good/husx_test/fix_err/samples/$i/humann2/$i\_kneaddata_merged_genefamilies.tsv ] 
  then 
  echo -e "$i \t error \t error \t" >> metagenomics_checkout.txt
  
  elif [ -e /groups/umcg-tifn/tmp03/LLD2/good/husx_test/fix_err/samples/$i/metaphlan/$i\_metaphlan.txt ] && [ ! -e /groups/umcg-tifn/tmp03/LLD2/good/husx_test/fix_err/samples/$i/humann2/$i\_kneaddata_merged_genefamilies.tsv ]
  then
  echo -e "$i \t Yes \t error \t" >> metagenomics_checkout.txt
  
  elif [ ! -e /groups/umcg-tifn/tmp03/LLD2/good/husx_test/fix_err/samples/$i/metaphlan/$i\_metaphlan.txt ] && [ -e /groups/umcg-tifn/tmp03/LLD2/good/husx_test/fix_err/samples/$i/humann2/$i\_kneaddata_merged_genefamilies.tsv ]
  then
  echo -e "$i \t error \t yes \t" >> metagenomics_checkout.txt

  elif [ -e /groups/umcg-tifn/tmp03/LLD2/good/husx_test/fix_err/samples/$i/metaphlan/$i\_metaphlan.txt ] && [ -e /groups/umcg-tifn/tmp03/LLD2/good/husx_test/fix_err/samples/$i/humann2/$i\_kneaddata_merged_genefamilies.tsv ]
  then
  echo -e "$i \t yes \t yes \t" >> metagenomics_checkout.txt
  
  fi
  
done