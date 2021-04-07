sink("/dev/null")
library(tidyverse)
library(VariantAnnotation)
library(updog)

# This points to the vcf file with only AR samples
smallvcfpath <- "/home/tmchizk/smallVCF.vcf"

# Grabbing only the VCF data that updog needs which includes:
# read depth (DP), reference allele counts (RO), SNP names, and Sample names
param <- ScanVcfParam(info=NA, geno = c("DP", "RO"))
VCF <- scanVcf(smallvcfpath, param = param)

# Parsing the data that was scanned from the VCF file into updog format
## Read depth
DP <- as.data.frame(VCF$`*:*-*`$GENO$DP)[1:1050,]
## Reference allele count
RO <- as.data.frame(VCF$`*:*-*`$GENO$RO)[1:1050,]
## SNP deduplication and rownames
SNPs <- names(ranges(VCF$`*:*-*`$rowRanges))[1:1050]

DP <- cbind(SNPs, DP) %>% unique()
rownames(DP) <- NULL
DP <- column_to_rownames(DP, var="SNPs") %>% as.matrix()

RO <- cbind(SNPs, RO) %>% unique()
rownames(RO) <- NULL
RO <- column_to_rownames(RO, var="SNPs") %>% as.matrix()

# Running tetraploid SNP calls in multidog
# tetrasnp <- multidog(refmat = RO, sizemat = DP, ploidy = 4)


# small 100 SNP test version
#smallDP <- DP[1:10000,]
#smallRO <- RO[1:10000,]
# starttime <- as.numeric(Sys.time())
# tetrasnp <- multidog(refmat = smallRO, sizemat = smallDP, ploidy = 4, nc = 32)
# endtime <- as.numeric(Sys.time())
# runtimedays <- ((endtime-starttime)/(100*60*60*24))*125000

DogToPoly <- function(call, ref_allele, alt_allele){
  call = as.character(call) %>%
    replace_na("unknown")
  call = str_replace(call, "4", paste0(ref_allele,ref_allele,ref_allele,ref_allele))
  call = str_replace(call, "3", paste0(alt_allele,ref_allele,ref_allele,ref_allele))
  call = str_replace(call, "2", paste0(alt_allele,alt_allele,ref_allele,ref_allele))
  call = str_replace(call, "1", paste0(alt_allele,alt_allele,alt_allele,ref_allele))
  call = str_replace(call, "0", paste0(alt_allele,alt_allele,alt_allele,alt_allele))
  return(call)
}

# This function uses multidog in small batches to prevent memory exhaustion and formats for GWASpoly as it goes
CallThemSNPS <- function(DP, RO, ploidy, nc, batch){
  i = 1
  Polyfied <- c()
  increment <- batch
  while(i <= length(rownames(DP))){
    # If there is only one snp left to process, extra formatting is required
    # to coerce the vector into a matrix for multidog
    if(batch == 1){
      smref = matrix(RO[i:(i+batch-1),], nrow = 1)
      smsiz = matrix(DP[i:(i+batch-1),], nrow = 1)
      rownames(smref) <- tail(rownames(RO), n=1)
      rownames(smsiz) <- tail(rownames(RO), n=1)
      colnames(smref) <- colnames(RO)
      colnames(smsiz) <- colnames(RO)
      Batch_i <- multidog(refmat = smref, sizemat = smsiz, ploidy=ploidy, nc=nc)$inddf[,c(1:5)]
    } else {
      # This part runs a larger batch of snps through updog 
      Batch_i <- multidog(refmat = RO[i:(i+batch-1),], sizemat = DP[i:(i+batch-1),], ploidy=ploidy, nc=nc)$inddf[,c(1:5)]
    }
    # Formatting for GWASpoly
    batch_poly <- as.data.frame(str_extract(Batch_i$snp, '(?<=_)[:upper:]/[:upper:]$'))
    batch_poly$sample <- Batch_i[,2]
    batch_poly <- separate(batch_poly, col=1, sep="/", into = c("ref_allele", "alt_allele"))
    batch_poly$GWASpoly <- DogToPoly(Batch_i[,5], batch_poly$ref_allele, batch_poly$alt_allele)
    batch_poly <- batch_poly[,-c(1,2)]
    batch_poly$Marker <- Batch_i$snp
    batch_poly$Chrom <- str_extract(Batch_i$snp, "^[:print:]+(?=:)")
    batch_poly$Position <- str_extract(Batch_i$snp, "(?<=:)[:digit:]+(?=_)")
    batch_poly <- pivot_wider(batch_poly, names_from = sample, values_from = GWASpoly)
    Polyfied <- rbind(Polyfied, batch_poly)
    i=i+increment
    # This conditional handles situations where the final batch exceeds the entries remaining
    if (i+increment >= length(rownames(DP))){
      batch = i-length(rownames(DP))+1
    }
  }
  return(Polyfied)
}

Polyfied <- CallThemSNPS(DP, RO, ploidy = 4, nc = 32, batch = 100)
sink()
write.csv(Polyfied)
