---
title: "GST_README"
author: "Mason"
date: "9/29/2021"
output: html_document
---

# Muscadine GST4 Validation

Short-read sequencing data for eight [muscadine genotypes](https://www.ncbi.nlm.nih.gov/sra/?term=PRJNA397021) were trimmed for quality 
and sequence size, aligned to the [Trayshed](http://www.grapegenomics.com/pages/Mrot/download.php) muscadine genome, and finally formatted in samtools and seqtk. All analyses 
detailed below were performed using AHPCC resources with parallel processing (when possible).

## Step 1: Trimming with Trimmomatic

For the raw fastq reads, pre and post trim quality checks were run in fastqc, 
using the default settings:

    fastqc [filepath.fasq]
    
Each file was trimmed in trimmomatic in paired end mode, using the same settings
for each file.  Sliding window quality checks removed average quality levels of 25
or less for a 4 base window.  After trimming, sequences below 70 bases in length 
were dropped, since this is the minimum length recommended for BWA MEM alignment:

    trimmomatic PE -threads 32 [in_forward.fastq] [in_reverse.fastq] \ 
    [out_forward.fastq] [out_reverse.fastq] ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:keepBothReads \
    TRAILING:3 SLIDINGWINDOW:2:25 MINLEN:70
    
Resulting fastqc reports demonstrated improvement, but with some poor quality reads,
like the one shown below (Fry), as much as 30% of raw reads were dropped.

**PRE-trim fastqc quality report**

![pretrim](https://github.com/mchizk1/UA_Fruit_Breeding/blob/main/GST_validation/Fry_pretrim.png)

**POST-trim fastqc quality report**

![pretrim](https://github.com/mchizk1/UA_Fruit_Breeding/blob/main/GST_validation/Fry_posttrim.png)
    
## Step 2: Alignments with BWA MEM

First, the [Trayshed](http://www.grapegenomics.com/pages/Mrot/download.php) fasta
formatted muscadine genome was indexed in BWA:

    bwa index [genome.fasta]
    
Next, each genotype was aligned to the indexed reference genome using BWA MEM on
the following settings:

    bwa mem -t 32 [reference.fasta] [forward.fastq] [reverse.fastq] > output_alignment.sam
    
Using this method, we achieved around 70-90% genome coverage per haplotype with around 3-6x 
mean read depth per haplotype depending on the quality of the individual sample.

**Sample of Coverage Histogram for Carlos hap1 alignment**

![coverage](https://github.com/mchizk1/UA_Fruit_Breeding/blob/main/GST_validation/Carlos_coverage.png)

## Step 3: Post Alignment Formatting and Cleanup in SAMtools

Resulting SAM files were converted to BAM format, sorted, scored for quality, 
and deduplicated using samtools:

    # SAM to BAM
    samtools view -S -b [sample.sam] > [sample.bam]
    
    # Sorted based on name for samtools fixmate
    samtools sort --threads 32 [sample.bam] -n -0 [sample.srt.bam]
    
    # Fixmate was used to flag alignment quality for deduplication
    samtools fixmate -@ 32 -m [sample.srt.bam] [sample.flag.bam]
    
    # Re-sorted based on coordinates in reference genome
    samtools sort --threads 32 [sample.flag.bam] [sample.resort.bam]
    
    # Deduplication and indexing
    samtools markdup -@ 32 -r -s --write-index [sample.resort.bam] [sample.ddp.bam]
    
## Step 4: Cendidate Gene Extraction and Variant Calling in BCFtools

Using deduplicated BAM files, variants were called only for the VrGST4, VrGST12, and VrMyb1A
candidate regions.  The final VCF was subsequently formatted in R using the VariantAnnotation
package.

    # Variant calling for candidate regions
    bcftools mpileup --threads 32 -f [reference.fasta] -b genolist.txt \
    -R regions.txt -o GST_candidates.vcf -O 'z'
    
    bcftools call [cadidates.vcf.gz] --threads 32 -c -o GST_calls.vcf.gz -O 'z'



