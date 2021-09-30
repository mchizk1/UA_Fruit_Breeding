
## **UA Blackberry GWAS Project**

### **Step 1. Filtering original VCF data in [readVCF_ARonly.R](https://github.com/mchizk1/UA_Fruit_Breeding/blob/main/Blackberry%20GWAS/readVCF_ARonly.R)**

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

### **Step 2. Tetraploid SNP calls and GWASpoly formatting in [Dogify.R](https://github.com/mchizk1/UA_Fruit_Breeding/blob/main/Blackberry%20GWAS/Dogify.R)**

**Description:** This script makes tetraploid SNP calls using the `multidog()` function in the [updog]("https://github.com/dcgerard/updog") package, which supports parallel computing. This script runs multidog incrementally over a user-assigned number of SNPS to avoid memory exhaustion.  Then, the estimated SNP allele dosage calls in the 'inddf' data frame are reformatted for [GWASpoly]("https://github.com/jendelman/GWASpoly").  This script will take a while and should be run on a high performance computing system if available. 

**Installing R package dependencies:**

    if (!requireNamespace("BiocManager", quietly = TRUE))
      install.packages("BiocManager")
    BiocManager::install("VariantAnnotation")
    install.packages("tidyverse")
    install.packages("updog")
    
**Inputs:** 

* Uncompressed VCF file
* [SLURM job file](https://github.com/mchizk1/UA_Fruit_Breeding/edit/main/Blackberry%20GWAS/updog_job.slurm) (Optional. For running on AHPCC pinnacle)

**Output:**

* CSV file containing tetraploid SNP calls formatted for [GWASpoly]("https://github.com/jendelman/GWASpoly")

### **Step 3. Using [GWASpoly]("https://github.com/jendelman/GWASpoly") to perform association analysis**

**Description:** GWASpoly reads in formatted genotypic and phenotypic data with `read.GWASpoly()` to generate a covariance matrix with `set.K()` (accounting for population structure). Finally, `GWASpoly()` does the heavy-lifting by performing the association analysis on the dataset returned by `set.K()`.  A detailed vignette and manual are available on the github page (see link above). Below is a sample script with placeholders for user-specific inputs.

**Installing R package dependencies:**

    library(devtools)
    install_github("jendelman/GWASpoly")
    install.packages("ggplot2")
    install.packages("rrBLUP")
    
**Sample Script for UA blackberry GWAS:**

    library(GWASpoly)
    library(ggplot2)
    library("rrBLUP")
    
    # reading in genotypic and phenotypic datasets
    data1 <- read.GWASpoly(ploidy = 4, pheno.file= "YourPathToPheno.csv", geno.file= "YourPathToGeno.csv", format= "numeric", , n.traits = YourNumber, delim = ",")
    
    # set the covariance matrix for population structure
    data2 <- set.K(data1)
    
    # run the association analysis
    data3 <- GWASpoly(mydata2, models = c("additive", "1-dom"), traits = c("trait1", "trait2", "etc..."))
    
    # set the significance threshold
    data4 <- set.threshold(MarkerSig, method="Bonferroni", level=0.05)
    
    # extract the significant QTLs into a dataframe
    myQTLs <- get.QTLs(data4)
    
    # inspect qqplots
    qqplot(data4)
    
    # inspect Manhattan plots
    manhattan.plot(plot4)

### **References**

>Gerard, D., Ferrao, L. F. V., Garcia, A. A. F., & Stephens, M. (2018). Genotyping Polyploids from Messy Sequencing Data. >*Genetics*, 210(3), 789-807. doi: [10.1534/genetics.118.301468](https://doi.org/10.1534/genetics.118.301468).

>Rosyara, U. R., De Jong, W. S., Douches, D. S., & Endelman, J. B. (2016). Software for genome-wide association studies in >autopolyploids and its application to potato. The plant genome, 9(2), plantgenome2015-08.



