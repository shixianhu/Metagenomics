1osihcvanv
fdvadfffffffff
---
fdvadfvad

'''


#!/bin/bash


#!/bin/bash
#SBATCH --job-name=bamtofastq
#SBATCH --error=bamtofastq.err

#SBATCH --output=bamtofastq.out
#SBATCH --mem=30gb
#SBATCH --time=9:59:00

#SBATCH --cpus-per-task=6


module load picard 
module load Python/3.4.1-foss-2015b

export 

'''

PATH=$PATH:~/.local/bin

mkdir -p /groups/umcg-weersma/tmp03/husx/WES/rawdata/fastq/LLDeep_1375

java -jar ${EBROOTPICARD}/picard.jar SamToFastq I=LLDeep_1375.bam F=../fastq/LLDeep_1375/LLDeep_1375.fastq1 F2=../fastq/LLDeep_1375/LLDeep_1375.fastq2

gzip ../fastq/LLDeep_1375/LLDeep_1375.fastq1
gzip ../fastq/LLDeep_1375/LLDeep_1375.fastq2