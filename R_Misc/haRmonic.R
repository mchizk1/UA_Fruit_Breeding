##########################################################
# A flexible harmonic means function for heritability    #
##########################################################

#This package will need to be installed and loaded if not already
#install.packages("dplyr")
library(dplyr)

dataset= read.csv("C:/whatever your path is")

#Replace with your own local dataset here
dataset <- read.table(file = "your csv path", header=T, sep=",")

#This function takes two vectors (columns) from the same dataset and produces a single harmonic mean
#The first vector argument is the class that you wish to group by.  For example
#I may want to look at imbalanced reps represented as levels within GENOTYPE classes.
#So the genotype column "dataset$genotype" would be the first argument.
#The second argument is the column that you want to calculate a harmonic mean for (i.e. REP, YEAR, or LOCATION)

harmonic_mean <- function(groupby, factor){
  dataset <- data.frame(groupby=groupby, factor=factor)
  tally <- as.data.frame(unique(groupby))
  for(i in 1:length(unique(groupby))){
    groupfilter <- filter(dataset, groupby == unique(groupby)[i])
    tally$factor[i]   <- length(unique(groupfilter$factor))
    tally$facinv[i] <- tally$factor[i]^-1
  }
  harmonic_mean <- length(tally$factor)/sum(tally$facinv)
  return(harmonic_mean)
}

#To use the function created above, 
harmonic_mean(dataset$ColumnToGroupBy, dataset$ColumnToGetMeansFor)
