---
title: "IJ"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## ImageJ Phenotyping of Red Drupelet Reversion (RDR)

### General Description:

The following step-by-step tutorial describes how to use the ImageJ macro script, `IJ_RDR.java` to estimate RDR, berry size, and drupelet number in a batch of .jpg files.  This script also assumes the implementation of an X-Rite ColorChecker Classic Mini color chip to standardize white balance across all images.

### Step 1. Identify coordinates of the X-Rite color chip.

In its current state, the color chip must be in the exact same location for each image processed in the same batch, but we have future plans to expand functionality by supporting automatic detection of the color chip.

### Step 2. Identify Lab* thresholds for isolating berries.

Next we must determine the Lab* color space thresholds that may be used to isolate blackberry pixels from all of the background pixels.  But first, to get accurate threshold values, white balance must be manually calibrated with the color chip.

### Step 3. Identify Lab* thresholds for isolating red drupelets.

Keeping the same color threshold window open, adjust the color thresholds until only read drupelet pixels are detected. 

### Step 4. Run the macro!!!


