
## **Call Them SNPs!!!**

### **Step 1. Filtering original VCF data in [readVCF_ARonly.R]()**

**Description:** Because not all samples in the ARK_133901 GWAS panel are tetraploid, it is necessary to remove the higher ploidy Oregon materials and then remove entries that no longer contain variants.  This R script hard codes the location of a local [text file]() containing the sample IDs of samples that we wish to include.  All others are removed.  This script processed a 125,000 SNP x 495 sample vcf in about 15 minutes on a normal laptop.

**Installing R package dependencies:**

    if (!requireNamespace("BiocManager", quietly = TRUE))
      install.packages("BiocManager")
    BiocManager::install("VariantAnnotation")

**inputs:**

* The original, compressed and tabix indexed vcf file containing all samples
* [Text file]() containing subset sample IDs
  
**output:**

* An uncompressed, filtered vcf file containing only the desired samples with non-variants removed

### **Step 2. Tetraploid SNP calls and GWASpoly formatting in [Dogify.R]()**

**Description:** This script makes tetraploid SNP calls using the `multidog()` function in the [updog]("https://github.com/dcgerard/updog") package, which supports parallel computing. This script runs multidog incrementally over a user-assigned number of SNPS to avoid memory exhaustion.  Then, the estimated SNP allele dosage calls in the 'inddf' data frame are reformatted for [GWASpoly]("https://github.com/jendelman/GWASpoly").  This script will take a while and should be run on a high performance computing system if available. 

**Installing R package dependencies:**

    if (!requireNamespace("BiocManager", quietly = TRUE))
      install.packages("BiocManager")
    BiocManager::install("VariantAnnotation")
    install.packages("tidyverse")
    install.packages("updog")
    
**Inputs:** 

* Uncompressed VCF file
* SLURM job file (Optional. For running on AHPCC pinnacle)

**Output:**

* CSV file containing tetraploid SNP calls formatted for [GWASpoly]("https://github.com/jendelman/GWASpoly")

### **References**

>Gerard, D., Ferrao, L. F. V., Garcia, A. A. F., & Stephens, M. (2018). Genotyping Polyploids from Messy Sequencing Data. >*Genetics*, 210(3), 789-807. doi: [10.1534/genetics.118.301468](https://doi.org/10.1534/genetics.118.301468).

>Rosyara, U. R., De Jong, W. S., Douches, D. S., & Endelman, J. B. (2016). Software for genome-wide association studies in >autopolyploids and its application to potato. The plant genome, 9(2), plantgenome2015-08.



