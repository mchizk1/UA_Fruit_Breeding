rm(list=ls())
# Installing/loading VariantAnnotation package
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
#BiocManager::install(version = "3.12")
#BiocManager::install("VariantAnnotation")
library(VariantAnnotation)

# Setting paths to compressed vcf and tabix file
compressed <- "C:/Users/Mason/filtered.vcf.gz"
tabix <- "C:/Users/Mason/filtered.vcf.gz.tbi"

# This command provides instructions for how many lines should be
# filtered at at time with filterVcf()
tabix.file <- TabixFile(compressed, yieldSize = 10000)

# Output file path
smallvcfpath <- "E:/UA/GWAS/VCF/smallVCF.vcf"

# List of samples that we want to keep (Arkansas only)
ARonly <- as.vector(read.table("C:/Users/Mason/ARonly.txt")[,1])
ARfilter <- ScanVcfParam(samples=ARonly, trimEmpty = T)

# Filter out the variants that no longer have polymorphisms
## after removing non-AR samples
isSNP <- function(x){
  test <- c()
  tall <- length(geno(x)$AO[,1])
  AO <- as.data.frame(geno(x)$AO)
  for(i in 1:tall){
    newline = sum(as.numeric(unlist(AO[i,])), na.rm=T) > 1
    test = c(test, newline)
  }  
  return(test)
}
filter <- FilterRules(list(isSNP=isSNP))

# Run the filters!!
filterVcf(tabix.file, "Hillquist", destination = smallvcfpath, param = ARfilter, filters = filter)

DPparam <- ScanVcfParam(info=NA, geno = "DP")
DP <- scanVcf(smallvcfpath, param = DPparam)
DP <- as.data.frame(DP)

GTparam <- ScanVcfParam(info=NA, geno = "GT")
GT <- scanVcf(smallvcfpath, param = GTparam)
x <- GT[[1]][7]
x2 <- x[[1]][1]
x3 <- x2[[1]]
unique(x3[26,])
isSNV(x3[26,])

testVcf <- readVcf("E:/UA/GWAS/VCF - Copy/FiltStep1_minQ10.0_minDP3_DPrange15-maxMeanDepth750_miss0.4_maf0.01_mac1_ARK_133901_SNPs_Raw.vcf" , "Hillquist", param = ARfilter)
isSNV(testVcf)
SNP <- isSNP(testVcf)
SNV <- isSNV(testVcf)
GT <- geno(testVcf)$GT
AD <- geno(testVcf)$AD
AD2 <- AD[,1,drop=F]

