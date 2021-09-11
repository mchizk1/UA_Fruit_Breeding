
#Uncomment and install packages as needed
#install.packages("tidyverse")

#THis attaches the packages needed to run
library(tidyverse)

#This chunk of script creates a function for making pedigrees tracing back 4 generations
#WARNING-- this function MUST use the source file I provided in Box.  The original file was messy
#and needed to be cleaned up in Excel before loading in R
QuickPed <- function(source, genotype){
g <- genotype
unabridged <- read.csv2(source, header=T, skip=3, sep=",")
unabridged <- unabridged[,-c(2,4)]
colnames(unabridged) <- c("Selection", "Parent1", "Parent2", "Sdate", "Discard", "Cultivar", "Rdate")
idcol <- as.data.frame(matrix(nrow=length(unabridged[,1]), ncol=1))
newunab <- bind_cols(unabridged, idcol)
unabridged <- as.matrix(newunab)
i <- 1
repeat{
  if (unabridged[i,6] == ""){
    unabridged[i,8] = unabridged[i,1]
  } else {
    unabridged[i,8] = unabridged[i,6]
  }
  if (unabridged[i,2] == ""){
    unabridged[i,2] = NA
  } 
  if (unabridged[i,3] == ""){
    unabridged[i,3] = NA
  }
  if (i == length(unabridged[,1])){
    break
  }
  i=i+1
}
colnames(unabridged) <- c("Selection", "Parent1", "Parent2", "Sdate", "Discard", "Cultivar", "Rdate", "id")
unabridged <- as.data.frame(unabridged)
p <- (unabridged[ifelse(unabridged$id == g, T,F),2:3])
gp1 <- (unabridged[ifelse(unabridged$id == p[1,1], T,F),2:3])
gp2 <- (unabridged[ifelse(unabridged$id == p[1,2], T,F),2:3])
gg1 <- (unabridged[ifelse(unabridged$id == gp1[1,1], T,F),2:3])
gg2 <- (unabridged[ifelse(unabridged$id == gp1[1,2], T,F),2:3])
gg3 <- (unabridged[ifelse(unabridged$id == gp2[1,1], T,F),2:3])
gg4 <- (unabridged[ifelse(unabridged$id == gp2[1,2], T,F),2:3])
ggg1 <- (unabridged[ifelse(unabridged$id == gg1[1,1], T,F),2:3])
ggg2 <- (unabridged[ifelse(unabridged$id == gg1[1,2], T,F),2:3])
ggg3 <- (unabridged[ifelse(unabridged$id == gg2[1,1], T,F),2:3])
ggg4 <- (unabridged[ifelse(unabridged$id == gg2[1,2], T,F),2:3])
ggg5 <- (unabridged[ifelse(unabridged$id == gg3[1,1], T,F),2:3])
ggg6 <- (unabridged[ifelse(unabridged$id == gg3[1,2], T,F),2:3])
ggg7 <- (unabridged[ifelse(unabridged$id == gg4[1,1], T,F),2:3])
ggg8 <- (unabridged[ifelse(unabridged$id == gg4[1,2], T,F),2:3])
gggg1 <- (unabridged[ifelse(unabridged$id == ggg1[1,1], T,F),2:3])
gggg2 <- (unabridged[ifelse(unabridged$id == ggg1[1,2], T,F),2:3])
gggg3 <- (unabridged[ifelse(unabridged$id == ggg2[1,1], T,F),2:3])
gggg4 <- (unabridged[ifelse(unabridged$id == ggg2[1,2], T,F),2:3])
gggg5 <- (unabridged[ifelse(unabridged$id == ggg3[1,1], T,F),2:3])
gggg6 <- (unabridged[ifelse(unabridged$id == ggg3[1,2], T,F),2:3])
gggg7 <- (unabridged[ifelse(unabridged$id == ggg4[1,1], T,F),2:3])
gggg8 <- (unabridged[ifelse(unabridged$id == ggg4[1,2], T,F),2:3])
gggg9 <- (unabridged[ifelse(unabridged$id == ggg5[1,1], T,F),2:3])
gggg10 <- (unabridged[ifelse(unabridged$id == ggg5[1,2], T,F),2:3])
gggg11 <- (unabridged[ifelse(unabridged$id == ggg6[1,1], T,F),2:3])
gggg12 <- (unabridged[ifelse(unabridged$id == ggg6[1,2], T,F),2:3])
gggg13 <- (unabridged[ifelse(unabridged$id == ggg7[1,1], T,F),2:3])
gggg14 <- (unabridged[ifelse(unabridged$id == ggg7[1,2], T,F),2:3])
gggg15 <- (unabridged[ifelse(unabridged$id == ggg8[1,1], T,F),2:3])
gggg16 <- (unabridged[ifelse(unabridged$id == ggg8[1,2], T,F),2:3])
pedigree <- matrix(c(""), nrow=10, ncol=17)
pedigree[10,9] <- g
pedigree[8,5] <- p[1,1]
pedigree[8,13] <- p[1,2]
pedigree[6,4] <- gp1[1,1]
pedigree[6,6] <- gp1[1,2]
pedigree[6,12] <- gp2[1,1]
pedigree[6,14] <- gp2[1,2]
pedigree[4,2] <- gg1[1,1]
pedigree[4,4] <- gg1[1,2]
pedigree[4,6] <- gg2[1,1]
pedigree[4,8] <- gg2[1,2]
pedigree[4,10] <- gg3[1,1]
pedigree[4,12] <- gg3[1,2]
pedigree[4,14] <- gg4[1,1]
pedigree[4,16] <- gg4[1,2]
pedigree[2,1] <- ggg1[1,1]
pedigree[2,2] <- ggg1[1,2]
pedigree[2,3] <- ggg2[1,1]
pedigree[2,4] <- ggg2[1,2]
pedigree[2,5] <- ggg3[1,1]
pedigree[2,6] <- ggg3[1,2]
pedigree[2,7] <- ggg4[1,1]
pedigree[2,8] <- ggg4[1,2]
pedigree[2,10] <- ggg5[1,1]
pedigree[2,11] <- ggg5[1,2]
pedigree[2,12] <- ggg6[1,1]
pedigree[2,13] <- ggg6[1,2]
pedigree[2,14] <- ggg7[1,1]
pedigree[2,15] <- ggg7[1,2]
pedigree[2,16] <- ggg8[1,1]
pedigree[2,17] <- ggg8[1,2]
return(pedigree)
}

#Use the new QuickPed function with the arguments for "Source" for Unabrideged file location and "genotype"
Pedigree <- QuickPed("C:/whatever your path is", "selection or cultivar name")
