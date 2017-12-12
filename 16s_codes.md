16s Data Codes
-----------

This pipeline is based on qiime2:https://docs.qiime2.org/2017.10/tutorials

Creators: microbiome group (Sana, Shixian, Lianmin)

Year: 2017

1.Pipeline install and data preparation
```
# install minicoda and the latest qiime2. Please make sure the qiime2 is updated, or it would get errors.
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
sh ./Miniconda3-latest-Linux-x86_64.sh
conda create -n qiime2-2017.10 --file https://data.qiime2.org/distro/core/qiime2-2017.7-conda-linux-64.txt
# activate qiime2
source activate qiime2-2017.10
```

```
# prepare the demultiplexed data (without barcode and primer), the reads length is around 200bp
# move all the R1.fastq.gz and R2.fastq.gz files in one folder
# rename as BAQ2420.1.2_55_L001_R1_001.fastq.gz (sample identifier, the barcode sequence or a barcode identifier, the lane number, the read number, and the set number)
for i in *.gz
do
  juged=$(echo $i | awk -F "[._]" '{print $4}')
  keep1=$(echo $i | awk -F "[._]" '{print $1}')
  keep2=$(echo $i | awk -F "[._]" '{print $3}')
  if [[ "$juged" -eq "1" ]]
  then
    mv ./$i ./$keep1.$keep2.\1_22_L001_R1_001.fastq.gz
  elif [[ "$juged" -eq "2" ]]
  then
    mv ./$i ./$keep1.$keep2.\1_22_L001_R2_001.fastq.gz
  fi 
done
```

2.Importing data
```
# generate qza file 
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path clean_data/ \
  --source-format CasavaOneEightSingleLanePerSampleDirFmt \
  --output-path demux.qza
```
```
# transfer qza to qzv which is able to be visualized in https://view.qiime2.org/visualization/ , where you can also find the quality score and decide cut-off for DADA2 step
qiime demux summarize \
  --i-data demux.qza \
  --o-visualization demux.qzv
```
```
# if on mac, please use command
qiime tools view demux.qzv 
```

3.Sequence quality control and feature table construction
```
# trimming low quality bp ,generating feature table and representative sequences, the output is table.qza and rep-seqs.qza
# --p-trim-left-f and --p-trim-left-r: how many bp do you want to trim from 5'end
# --p-trunc-len-f and --p-trunc-len-r: the trim position on 3'end
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs demux.qza \
  --o-table table \
  --o-representative-sequences rep-seqs \
  --p-trim-left-f 0 \
  --p-trim-left-r 0 \
  --p-trunc-len-f 200 \
  --p-trunc-len-r 200
```
```
# transfer table.qza and rep-seqs.qza to qzv
qiime feature-table summarize \
  --i-table table.qza \
  --o-visualization table.qzv \
  --m-sample-metadata-file sample-metadata.tsv

qiime feature-table tabulate-seqs \
  --i-data rep-seqs.qza \
  --o-visualization rep-seqs.qzv
```

4.Generate a tree for phylogenetic diversity analyses
```
# multiple alignment of the representative sequences, using mafft program
qiime alignment mafft \
  --i-sequences rep-seqs.qza \
  --o-alignment aligned-rep-seqs.qza
```
``` 
# remove positions that are highly variable
qiime alignment mask \
  --i-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza
```
```
# generate a phylogenetic tree from the masked alignment
qiime phylogeny fasttree \
  --i-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza
```
```
# place the root of the tree at the midpoint of the longest tip-to-tip distance in the unrooted tree
qiime phylogeny midpoint-root \
  --i-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza
```

5.Alpha and beta diversity analysis
```
# compute alpha and beta diversity metrics, including:
#   alpha:core-metrics-results/evenness_vector.qza
#         core-metrics-results/faith_pd_vector.qza
#         core-metrics-results/observed_otus_vector.qza
#         core-metrics-results/rarefied_table.qza
#         core-metrics-results/shannon_vector.qza
#    beta:core-metrics-results/bray_curtis_distance_matrix.qza   
#         core-metrics-results/bray_curtis_pcoa_results.qza
#         core-metrics-results/jaccard_distance_matrix.qza
#         core-metrics-results/jaccard_pcoa_results.qza
#         core-metrics-results/unweighted_unifrac_distance_matrix.qza
#         core-metrics-results/unweighted_unifrac_pcoa_results.qza
#         core-metrics-results/weighted_unifrac_distance_matrix.qza
#         core-metrics-results/weighted_unifrac_pcoa_results.qza
# generate principle coordinates analysis (PCoA) plots, including:
#         core-metrics-results/bray_curtis_emperor.qzv
#         core-metrics-results/jaccard_emperor.qzv
#         core-metrics-results/unweighted_unifrac_emperor.qzv
#         core-metrics-results/weighted_unifrac_emperor.qzv
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table table.qza \
  --p-sampling-depth 5000 \
  --m-metadata-file sample-metadata.tsv \
  --output-dir core-metrics-results
```
```
Shannon’s diversity index  (a quantitative measure of community richness)
# testing for associations between discrete metadata categories and alpha diversity data
qiime diversity alpha-group-significance \
--i-alpha-diversity core-metrics-results/shannon_vector.qza \
--m-metadata-file Metadata_16S.tsv  \
--o-visualization core-metrics-results/shannon-significance.qzv
```
```
# looking at the continuous data correlation with Shannon’s index
qiime diversity alpha-correlation \
--i-alpha-diversity core-metrics-results/shannon_vector.qza \
--m-metadata-file Metadata_16S.tsv \
--o-visualization core-metrics-results/shannon-significance-association.qzv
```
```
Observed OTUs (a qualitative measure of community richness)
# testing for associations between discrete metadata categories and alpha diversity data
qiime diversity alpha-group-significance \
--i-alpha-diversity core-metrics-results/observed_otus_vector.qza \
--m-metadata-file Metadata_16S.tsv \
--o-visualization core-metrics-results/observed_otus-significance.qzv
```
```
#looking at the continuous data correlation with observed OTUs
qiime diversity alpha-correlation \
--i-alpha-diversity core-metrics-results/observed_otus_vector.qza \
--m-metadata-file Metadata_16S.tsv \
--o-visualization core-metrics-results/observed-otus-significance-association.qzv
```
Bray-Curtis distance (a quantitative measure of community dissimilarity)
```
# analyzing sample composition in the context of discrete metadata
qiime diversity beta-group-significance \
--i-distance-matrix core-metrics-results/bray_curtis_distance_matrix.qza \
--m-metadata-file Metadata_16S.tsv \
--m-metadata-category Group \
--o-visualization core-metrics-results/bray-curtis-group-significance.qzv \
--p-pairwise
```
Unweighted UniFrac distance (a qualitative measure of community dissimilarity that incorporates phylogenetic relationships between the features)
```
qiime diversity beta-group-significance \
--i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
--m-metadata-file Metadata_16S.tsv \
--m-metadata-category Group \
--o-visualization core-metrics-results/unweighted-unifrac-group-site-significance.qzv \
--p-pairwise
```
Weighted UniFrac distance (a quantitative measure of community dissimilarity that incorporates phylogenetic relationships between the features)
```
qiime diversity beta-group-significance \
--i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
--m-metadata-file Metadata_16S.tsv \
--m-metadata-category Group \
--o-visualization
```