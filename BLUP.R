
#########################################################
# BLUP calculations
# Author: Mason Chizk
#########################################################

# load packages
library(tidyverse)
library(lme4)

# This one is a private UA package
library(fRuit)

# Reading input files (replace as necessary)
input_location <- c("C:/wherever.csv")
BLUPS.X <- read.csv(input_location) %>%
  rename(Genotype = rowname)
traits <- c("RDR_prop", "Force_N", "TenBerWt", "L_sf", "W_sf", "DrpPerBer")

H_bs <- function(blup_lst){
  numerator <- filter(blup_lst[[2]], rownames(blup_lst[[2]]) == "Genotype")
  varcomp <- filter(blup_lst[[2]], rownames(blup_lst[[2]]) %in% c("Genotype", "Genotype:year", "Residual"))
  denom_pp <- colSums(varcomp)
  varcomp["Genotype:year",] <- varcomp["Genotype:year",]/blup_lst[[3]]["year",]
  repXyear <- (blup_lst[[3]]["year",]) * (blup_lst[[3]]["Dnum",])
  varcomp["Residual",] <- varcomp["Residual",]/repXyear
  denom_em <- colSums(varcomp)
  H_pp <- numerator/denom_pp
  H_em <- numerator/denom_em
  H_df <- rbind(H_pp, H_em)
  rownames(H_df) <- c("Per_Plot", "Entry_Mean")
  return(H_df)
}

BLUP_XYear <- function(df, traits, yr = NULL){
  blup <- list()
  varcomp <- list()
  harmn <- list()
  if(!is.null(yr)){
    df = filter(df, df$year == yr)
  }
  for(i in traits){
    if(is.null(yr)){
      formula <- paste0(i," ~ (1|Genotype) + (1|year/Dnum) + (1|Genotype:year)") %>%
        as.formula()
      harmn_vec <- harmonic_mean(paste0(df$Genotype, "_", df$Dnum), df$year, trait= df[i])
      harmn_vec[2] <- harmonic_mean(df$Genotype, df$Dnum, trait= df[i])
      harmn[[i]] <- data.frame(i = harmn_vec)
      colnames(harmn[[i]]) <- i
      rownames(harmn[[i]]) <- c("year", "Dnum")
    } else {
      formula <- paste0(i," ~ (1|Genotype) + (1|Dnum)") %>%
        as.formula()
      harmn[[i]] <- data.frame(i = harmonic_mean(df$Genotype, df$Dnum, trait= df[i]))
      colnames(harmn[[i]]) <- i
      rownames(harmn[[i]]) <- c("Dnum")
    }
    blup[[i]] <- lmer(formula = formula, data = df, na.action = na.omit)
    varcomp[[i]] <- VarCorr(blup[[i]]) %>%
      as.data.frame() %>%
      column_to_rownames("grp") %>%
      select(vcov)
    colnames(varcomp[[i]]) <- i
    blup[[i]] <- coef(blup[[i]])$Genotype #+ getME(blup[[i]], "fixef")
    #blup[[i]] <- coef(blup[[i]])$Genotype
    colnames(blup[[i]]) <- i
  }
  blup_df <- rownames_to_column(blup[[1]])
  var_df <- rownames_to_column(varcomp[[1]])
  harmn_df <- rownames_to_column(harmn[[1]])
  if(length(traits > 1)){
    for(i in 2:length(traits)){
      blup_df <- full_join(blup_df, rownames_to_column(blup[[i]]))
      var_df <- full_join(var_df, rownames_to_column(varcomp[[i]]))
      harmn_df <- full_join(harmn_df, rownames_to_column(harmn[[i]]))
    }
  }
  blup_lst <- list(blup_df, var_df, harmn_df)
  for(i in 1:length(blup_lst)){
    rownames(blup_lst[[i]]) <- NULL
    blup_lst[[i]] <- column_to_rownames(blup_lst[[i]], "rowname")
  }
  blup_lst[[4]] <- H_bs(blup_lst)
  names(blup_lst) <- c("blup_df", "var_df", "harmn_df", "H_df")
  return(blup_lst)
}


# ShinyData analysis
BLUPS.shiny <- BLUP_XYear(BLUPS.X, traits)
BLUPS.shiny <- BLUP_XYear(BLUPS.X, traits)$blup_df %>%
  rownames_to_column() %>%
  rename(L_sf = L, W_sf = W, Size_sf = Size) %>%
  full_join(rownames_to_column(BLUPS.X$blup_df)) %>%
  filter((!is.na(Force_N))&(!is.na(RDR)))
H <- rbind(BLUPS.shiny$H_df, BLUPS.shiny$var_df)

# Output results
write.csv(BLUPS.shiny, file = "C:/wherever.csv", row.names = F)
