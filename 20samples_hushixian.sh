#!/bin/bash
#SBATCH --job-name=20_samples_hushixian
#SBATCH --error=20_samples_hushixian.err
#SBATCH --output=20_samples_hushixian.out
#SBATCH --mem=30gb
#SBATCH --time=10:00:00
#SBATCH --cpus-per-task=6

########################## basic settings ################################################## 

module load picard
module load Python/2.7.11-foss-2015b

########################## load module that will be used ####################################

export PATH=$PATH:/groups/umcg-gastrocol/tmp03/metagenomic_tools/metaphlan_2/
export PATH=$PATH:~/.local/bin/

########################## point out where to load your software ############################

dir=$(ls -l /groups/umcg-tifn/tmp03/LLD2/good/husx_test/Samples/ | awk '{print $9}')

for sample in $dir

do

  i=$(echo ${sample%.bam}) 
  
  echo Starting $i analysis 
  echo Creating files
  
  mkdir -p ./$i
  mkdir -p ./$i/filtering_data/
  mkdir -p ./$i/clean_reads/
  mkdir -p ./$i/metaphlan/
  mkdir -p ./$i/humann2/
  mkdir -p ./$i/DUDes/

########################### list all samples, creat files to storage processed and final data ################

  echo Starting Picard

  java -jar ${EBROOTPICARD}/picard.jar SamToFastq I=/groups/umcg-tifn/tmp03/LLD2/good/husx_test/Samples/$i.bam F=./$i/filtering_data/$i.fastq1 F2=./$i/filtering_data/$i.fastq2
 
############################ convert bam to fastq ################
#### I: path+the input file that must be a bam file; F: path+fastq_1; F2:path+fastq_2 ##############


  echo Picard finished
  echo Starting reads cleaning
  
  module load Python/2.7.11-foss-2015b
  
  echo Loading Python_2
 
  kneaddata --input ./$i/filtering_data/$i.fastq1 -t 6 -p 7 --input ./$i/filtering_data/$i.fastq2 -db /groups/umcg-gastrocol/tmp03/metagenomic_tools/kneaddata-0.5.4/Homo_sapiens_Bowtie2_v0.1/ --output ./$i/filtering_data/ --log ./$i/clean_reads/$i.log
  
### kneaddata --input ./$SAMPLE_ID/filtering_data/$SAMPLE_ID_1.fq -t 6 -p 7 --input ./$SAMPLE_ID/filtering_data/$SAMPLE_ID_2.fq -db /groups/umcg-gastrocol/tmp03/metagenomic_tools/kneaddata-0.5.4/Homo_sapiens_Bowtie2_v0.1/ --output ./$SAMPLE_ID/filtering_data/ --log ./$SAMPLE_ID/clean_reads/$SAMPLE_ID.log
  
########################### remove human genome ################
### --input: must be fastq file; -t: number of threads; -p: number of processes; -db: path+reference database; --output: path; log:log file ###################3

  echo kneaddata finished
  echo Moving files
  
  cat ./$i/filtering_data/$i\_kneaddata_paired_1.fastq > ./$i/filtering_data/$i\_kneaddata_merged.fastq 
  cat ./$i/filtering_data/$i\_kneaddata_paired_2.fastq >> ./$i/filtering_data/$i\_kneaddata_merged.fastq 
  mv ./$i/filtering_data/*kneaddata_paired_1.fastq ./$i/clean_reads/
  mv ./$i/filtering_data/*kneaddata_paired_2.fastq ./$i/clean_reads/ 
  mv ./$i/filtering_data/*kneaddata_merged.fastq ./$i/clean_reads/
  
########################### merge filtered_fastq_1 and filtered_fastq_2 together, move them to clean_reads, delete unfiltered fastq files ##################
  
  echo Starting taxonomy classification using Metaphlan
  
  metaphlan2.py ./$i/clean_reads/$i\_kneaddata_merged.fastq  --input_type multifastq --mpa_pkl /groups/umcg-gastrocol/tmp03/metagenomic_tools/metaphlan_2/db_v20/mpa_v20_m200.pkl --nproc 6 -o ./$i/metaphlan/$i\_metaphlan.txt --tmp_dir ./$i/clean_reads/
  
##### --input_type: {fastq,fasta,multifasta,multifastq,bowtie2out,sam}; --mpa_pkl: the metadata pickled MetaPhlAn file; --nproc: The number of CPUs to use for parallelizing the mapping; -o: output file, --output_file: output file #######
  
  echo Metaphlan finished
  echo Starting taxonomy profiling using DUDes
  
  bowtie2 -x /groups/umcg-gastrocol/tmp03/metagenomic_tools/dudes_v0_07/custom_db/db_refseq_20052017 --no-unal --fast -p 6 -k 50 -1 ./$i/clean_reads/$i\_kneaddata_paired_1.fastq -2 ./$i/clean_reads/$i\_kneaddata_paired_2.fastq -S ./$i/DUDes/$i\_output.sam 
  
#### -x: The basename of the index for the reference genome. The basename is the name of any of the index files up to but not including the final .1.bt2 / .rev.1.bt2 / etc; \
#### -1: Comma-separated list of files containing mate 1s (filename usually includes _1), e.g. -1 flyA_1.fq,flyB_1.fq. \
#### -2: Comma-separated list of files containing mate 2s (filename usually includes _2), e.g. -2 flyA_2.fq,flyB_2.fq. \
#### -p: When -k is specified, however, bowtie2 behaves differently. Instead, it searches for at most <int> distinct, valid alignments for each read. \
#### --no-unal: Suppress SAM records for reads that failed to align. \
#### --fast: Same as: -D 10 -R 2 -N 0 -L 22 -i S,0,2.50

  
  module load Python/3.4.1-foss-2015b
  
  echo Loading Python_3
  
  python3 /groups/umcg-gastrocol/tmp03/metagenomic_tools/dudes_v0_07/DUDes.py -s ./$i/DUDes/$i\_output.sam -d /groups/umcg-gastrocol/tmp03/metagenomic_tools/dudes_v0_07/custom_db/DUDES_refseq_db.npz -t 6 -m 50 -a 0.0005 -l strain -o ./$i/DUDes/$i 

  echo UDUes finished
  
done
