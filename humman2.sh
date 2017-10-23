#!/bin/bash
#SBATCH --job-name=humman2_hushixian
#SBATCH --error=humman2_hushixian.err2
#SBATCH --output=humman2_hushixian.out2
#SBATCH --mem=40gb
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=6
module load picard 
module load Python/3.4.1-foss-2015b
module load Bowtie2
export PATH=$PATH:/groups/umcg-gastrocol/tmp03/metagenomic_tools/metaphlan_2/
export PATH=$PATH:~/.local/bin
echo Starting pathways prediction using Humann2

i="MagMAX.BM2pos2F"

humann2 --input ./$i/clean_reads/$i\_kneaddata_merged.fastq --output ./$i/humann2/ --taxonomic-profile ./$i/metaphlan/$i\_metaphlan.txt --threads 6 --o-log ./$i/clean_reads/$i.full.humann2.log --remove-temp-output
mv ./$i/clean_reads/*.log ./$i/


