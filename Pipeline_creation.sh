#######################################################
#                                                     #
#													                                        #
#		            Creation Pipelines for WMS				         #
#				            					                                #
#													                                        #
#													                                        #
#######################################################													


###################################################################################################################################
####################################################### From QC to Taxonomy #######################################################
###################################################################################################################################

##### step_1: extract samples name

for sample in *.bam

 do i=$(echo ${sample%.bam})

##### step_2: basic settings

  echo "#!/bin/bash" > ./$i.QC_to_Taxa.sh
  echo "#SBATCH --job-name=$i.QC_Taxa_hu" >> ./$i.QC_to_Taxa.sh
  echo "#SBATCH --error=$i.QC_Taxa_hu.err" >> ./$i.QC_to_Taxa.sh
  echo "#SBATCH --output=$i.QC_Taxa_hu.out" >> ./$i.QC_to_Taxa.sh
  echo "#SBATCH --mem=60gb" >> ./$i.QC_to_Taxa.sh
  echo "#SBATCH --time=10:00:00" >> ./$i.QC_to_Taxa.sh
  echo "#SBATCH --cpus-per-task=6" >> ./$i.QC_to_Taxa.sh

##### step_3: module load

  echo "module load picard" >> ./$i.QC_to_Taxa.sh
  echo "module load Python/2.7.11-foss-2015b" >> ./$i.QC_to_Taxa.sh

##### step_4: export path

  echo "export PATH=\$PATH:/groups/umcg-gastrocol/tmp03/metagenomic_tools/metaphlan_2/" >> ./$i.QC_to_Taxa.sh
  echo "export PATH=\$PATH:~/.local/bin/" >> ./$i.QC_to_Taxa.sh

##### step_5: create files
  
  echo "echo _______________________________________Starting $i analysis________________________________________" >> ./$i.QC_to_Taxa.sh
  echo "echo Creating files" >> ./$i.QC_to_Taxa.sh
  
  echo "mkdir -p ./$i" >> ./$i.QC_to_Taxa.sh
  echo "mkdir -p ./$i/filtering_data/" >> ./$i.QC_to_Taxa.sh
  echo "mkdir -p ./$i/clean_reads/" >> ./$i.QC_to_Taxa.sh
  echo "mkdir -p ./$i/metaphlan/" >> ./$i.QC_to_Taxa.sh
  echo "mkdir -p ./$i/humann2/" >> ./$i.QC_to_Taxa.sh
  echo "mkdir -p ./$i/DUDes/" >> ./$i.QC_to_Taxa.sh

  echo "echo Starting reads cleaning" >> ./$i.QC_to_Taxa.sh
  
##### step_6: picard 

  echo "echo Starting Picard" >> ./$i.QC_to_Taxa.sh

  echo "java -jar \${EBROOTPICARD}/picard.jar SamToFastq I=/groups/umcg-tifn/tmp03/LLD2/good/husx_test/Samples/$i.bam F=./$i/filtering_data/$i.fastq1 F2=./$i/filtering_data/$i.fastq2" >> ./$i.QC_to_Taxa.sh
 
  echo "echo Picard finished" >> ./$i.QC_to_Taxa.sh
  
##### step_7: kneaddata
  
  echo "module load Python/2.7.11-foss-2015b" >> ./$i.QC_to_Taxa.sh
  
  echo "echo Loading Python_2" >> ./$i.QC_to_Taxa.sh
 
  echo "kneaddata --input ./$i/filtering_data/$i.fastq1 -t 6 -p 7 --input ./$i/filtering_data/$i.fastq2 -db /groups/umcg-gastrocol/tmp03/metagenomic_tools/kneaddata-0.5.4/Homo_sapiens_Bowtie2_v0.1/ --output ./$i/filtering_data/ --log ./$i/clean_reads/$i.log" >> ./$i.QC_to_Taxa.sh

  echo "echo kneaddata finished" >> ./$i.QC_to_Taxa.sh
  
##### step_8: move files
  
  echo "echo Moving files" >> ./$i.QC_to_Taxa.sh
  
  echo "cat ./$i/filtering_data/$i\_kneaddata_paired_1.fastq > ./$i/filtering_data/$i\_kneaddata_merged.fastq" >> ./$i.QC_to_Taxa.sh
  echo "cat ./$i/filtering_data/$i\_kneaddata_paired_2.fastq >> ./$i/filtering_data/$i\_kneaddata_merged.fastq" >> ./$i.QC_to_Taxa.sh 
  echo "mv ./$i/filtering_data/*kneaddata_paired_1.fastq ./$i/clean_reads/" >> ./$i.QC_to_Taxa.sh
  echo "mv ./$i/filtering_data/*kneaddata_paired_2.fastq ./$i/clean_reads/" >> ./$i.QC_to_Taxa.sh
  echo "mv ./$i/filtering_data/*kneaddata_merged.fastq ./$i/clean_reads/" >> ./$i.QC_to_Taxa.sh
  
###### step_9: metaphlan
  
  echo "echo Starting taxonomy classification using Metaphlan" >> ./$i.QC_to_Taxa.sh
  
  echo "metaphlan2.py ./$i/clean_reads/$i\_kneaddata_merged.fastq  --input_type multifastq --mpa_pkl /groups/umcg-gastrocol/tmp03/metagenomic_tools/metaphlan_2/db_v20/mpa_v20_m200.pkl --nproc 6 -o ./$i/metaphlan/$i\_metaphlan.txt --tmp_dir ./$i/clean_reads/" >> ./$i.QC_to_Taxa.sh
    
  echo "echo Metaphlan finished" >> ./$i.QC_to_Taxa.sh
  
##### step_10:DUDes
  
  echo "echo Starting taxonomy profiling using DUDes" >> ./$i.QC_to_Taxa.sh
  
  echo "echo bowtie_2 start" >> ./$i.QC_to_Taxa.sh
  
  echo "bowtie2 -x /groups/umcg-gastrocol/tmp03/metagenomic_tools/dudes_v0_07/custom_db/db_refseq_20052017 --no-unal --fast -p 6 -k 50 -1 ./$i/clean_reads/$i\_kneaddata_paired_1.fastq -2 ./$i/clean_reads/$i\_kneaddata_paired_2.fastq -S ./$i/DUDes/$i\_output.sam" >> ./$i.QC_to_Taxa.sh
  
  echo "echo bowtie_2 finished" >> ./$i.QC_to_Taxa.sh
  
  echo "module load Python/3.4.1-foss-2015b" >> ./$i.QC_to_Taxa.sh
  
  echo "echo Loading Python_3" >> ./$i.QC_to_Taxa.sh
  
  echo "echo DUDes.py start" >> ./$i.QC_to_Taxa.sh
  
  echo "python3 /groups/umcg-gastrocol/tmp03/metagenomic_tools/dudes_v0_07/DUDes.py -s ./$i/DUDes/$i\_output.sam -d /groups/umcg-gastrocol/tmp03/metagenomic_tools/dudes_v0_07/custom_db/DUDES_refseq_db.npz -t 6 -m 50 -a 0.0005 -l strain -o ./$i/DUDes/$i" >> ./$i.QC_to_Taxa.sh

  echo "echo UDUes finished" >> ./$i.QC_to_Taxa.sh
  
  echo "echo sbatch ./$i.Function.sh" >> ./$i.QC_to_Taxa.sh
  

###################################################################################################################################
######################################## Functional profiling / pathway identification ############################################
###################################################################################################################################
  
##### step_1: basic settings

  echo "#!/bin/bash" > ./$i.Function.sh
  echo "#SBATCH --job-name=$i.Function_hu" >> ./$i.Function.sh 
  echo "#SBATCH --error=$i.Function_hu.err" >> ./$i.Function.sh
  echo "#SBATCH --output=$i.Function_hu.out" >> ./$i.Function.sh 
  echo "#SBATCH --mem=40gb" >> ./$i.Function.sh
  echo "#SBATCH --time=24:00:00" >> ./$i.Function.sh
  echo "#SBATCH --cpus-per-task=6" >> ./$i.Function.sh
  
##### step_2: module load
  
  echo "module load picard" >> ./$i.Function.sh
  echo "module load Python/3.4.1-foss-2015b" >> ./$i.Function.sh
  echo "module load Bowtie2" >> ./$i.Function.sh
  
##### step_3: export path
  
  echo "export PATH=\$PATH:/groups/umcg-gastrocol/tmp03/metagenomic_tools/metaphlan_2/" >> ./$i.Function.sh
  echo "export PATH=\$PATH:~/.local/bin" >> ./$i.Function.sh
  
##### step_4: humman2
  
  echo "echo Starting pathways prediction using Humann2" >> ./$i.Function.sh

  echo "humann2 --input ./$i/clean_reads/$i\_kneaddata_merged.fastq --output ./$i/humann2/ --taxonomic-profile ./$i/metaphlan/$i\_metaphlan.txt --threads 6 --o-log ./$i/clean_reads/$i.full.humann2.log --remove-temp-output" >> ./$i.Function.sh

  echo "mv ./$i/clean_reads/*.log ./$i/" >> ./$i.Function.sh
  
  echo "echo humman2 finished" >> ./$i.Function.sh

done





