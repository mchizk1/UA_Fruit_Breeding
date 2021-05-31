library(pdftools)
library(raster)
library(qrcode)
library(stringr)
library(tidyr)
library(tcltk)

# This function provides the basic framework for generating a QRcode, with
# the qrcode package, and includes extra plot info such as plot#, row#, plotID, 
# and StakeID

plotQR <- function(rownum, plotnum, plotid, stakeid, qrcoord, labcoord){
  QRmat <- qrcode_gen(plotid, dataOutput = T, plotQRcode = F)
  QRras <- raster(QRmat)
  par(mfrow=c(1,1))
  par(mar=c(0.5,0,0,0))
  par(fig=qrcoord)
  plot(QRras, box=F, legend=F, axes=F, col=grey(c(100:1/100)))
  par(fig=labcoord)
  par(new=T)
  par(mar=c(0,0,0,0))
  plot(c(0, 1), c(0, 1), ann = F, type = 'n', xaxt = 'n', yaxt = 'n')
  text(x = 0.5, y = 0.5, paste("Row:", rownum,"Plot:", plotnum,"\n",
                               "Plot ID:", plotid,"\n",
                               "Stake ID:", stakeid), 
       cex = .8, col = "black")
  par(new=T)
}

# This function fills a graphics window with 20 QR/label combinations

FillPage <- function(field_df, start){
  entry <- start
  for(i in 0:9){
    plotQR(field_df$Row[entry], field_df$Plot[entry], field_df$X2021.Fieldbook.ID[entry], 
           field_df$Spreadsheet.Map.Name[entry], c(0,2,9-i,10-i)/10, c(2,5,9-i,10-i)/10)
    entry=entry+1
    if(entry >= length(rownames(field_df))){
      break
    }
  }
  for(j in 0:9){
    plotQR(field_df$Row[entry], field_df$Plot[entry], field_df$X2021.Fieldbook.ID[entry], 
           field_df$Spreadsheet.Map.Name[entry], c(5,7,9-j,10-j)/10, c(7,10,9-j,10-j)/10)
    entry=entry+1
    if(entry >= length(rownames(field_df))){
      break
    }
  }
}

# This function creates a series of pdf files in a temporary directory
# and combines all files into one multi-page pdf (using pdftools) for printing

FullListPDF <- function(listin, listout){
  MAP <- read.csv(listin, header=T)
  i=1
  pdfpages <- c()
  tdir <- tempdir()
  repeat{
    filename <- tempfile(pattern = "MAP_LIST", tmpdir = tdir, fileext = ".pdf")
    pdf(filename, paper = "letter", height = 9)
    FillPage(MAP, i)
    dev.off()
    pdfpages <- c(pdfpages, filename)
    i=i+20
    if(i >= length(rownames(MAP))){
      break
    }
  }
  pdf_combine(pdfpages, listout)
}

# This function checks if a directory exists.  If not, it creates a new directory.

dircheck <- function(dircheck){
  paths <- unlist(str_split(dircheck,"/"))
  if(dir.exists(paste0(paths[1],"/"))){
    for(i in 2:length(paths)-1){
      checkdir <- paste0(str_c(paths[1:i], collapse = "/"),"/")
      if(dir.exists(checkdir)){
        next
      } else {
        dir.create(checkdir)
      }
    }
  } else {
    print("ERROR: Root directory doesn't exist. Check path validity.")
  }
}

# This function vectorizes the FullListPDF() function to create lists for all map
# lists in a directory at once

AllLists <- function(inDir, outDir){
  dircheck(outDir)
  fileQueue <- list.files(inDir)
  fileNames <- str_extract(exlist, "[:print:]+(?=.csv)")
  pb <- tkProgressBar("Generating QR code lists...", paste("0 of",length(fileQueue),"PDFs created"), 0, length(fileQueue), 50)
  for(i in 1:length(fileQueue)){
    FullListPDF(paste0(inDir,fileQueue[i]), paste0(outDir,fileNames[i],".pdf"))
    setTkProgressBar(pb, i, label = paste(i, "of",length(fileQueue),"PDFs created"))
  }
  close(pb)
}

AllLists("C:/Where_ever_your_map_lists_are...", "C:/Wherever_you_want_your_new_files")
