#!/usr/bin/Rscript

# this is to merge tsv/txt files according to the first column. Note : merge(all=T)

library(stringr)

gene_families=list.files("./", pattern = "*.tsv")

n=length(gene_families)

origin=read.csv(file=gene_families[1], header=T, sep = "\t", quote ="")

sample=str_replace(gene_families[1], "kneaddata_merged_genefamilies.tsv", "RPK")

names(origin)=c("Gene_family", sample)

sample

for(i in 2:n){
  
  print(i)
  
  add=read.csv(file=gene_families[i], header=T, sep = "\t")
  
  sample=str_replace(gene_families[i], "kneaddata_merged_gene_families.tsv", "RPK")
  
  names(add)=c("Gene_family", sample)
  
  print(gene_families[i])
  
  origin=merge(origin, add, by="Gene_family", all=T)
  
}

write.csv(origin, file="./Gene_family_merge.csv")
