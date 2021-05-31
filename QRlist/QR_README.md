---
title: "QRlist.R Tutorial"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Two Main Functions (not including helper functions)

### 1. FullListPDF

**Description:**

This function uses the `plotQR()` and `FillPage()` helper functions to create a QR code (using the
QRcode package) and pair it with descriptive plot information, filling up multiple temporary pdf 
files, and stitching them together into a single multi-page output pdf using the pdftools package.

**Usage:**

    FullListPDF(listin, listout)

**Arguments:**

* `listin` -- A csv with four required columns named "Row", "Plot", "X2021.Fieldbook.ID", and "Spreadsheet.Map.Name".  "X2021.Fieldbook.ID" will be used to generate the QR code and the 
rest will be included as descriptive information in each label.

* `listout` -- A character string describing the file location, name, and extension of the new
QR code list to be created


### 2. AllLists()

**Description:**

This function uses vectorizes the `FullListPDF()` function to work across an entire directory
of input lists.  This function provides a loading bar through the tcltk package to track 
progress as lists are generated.  Also, `FullListPDF()` calls the `dircheck()` helper function
to first check if the output directory exists.  If not, a new directory is created for output
pdf files.

**Usage:**

    AllLists(inDir, outDir)

**Arguments:**

* `inDir` -- A character string describing the path to the directory containing input csv files
that meet the requirements of `FullListPDF()`.

* `outDir` -- A character string describing the path to the directory that output PDF files should
be saved to.  The output directory may either be a new folder or one that already exists.

### Example Output:

![QRexample]("https://github.com/mchizk1/UA_Fruit_Breeding/blob/main/QRlist/QRpic.png")

