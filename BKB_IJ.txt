// "Filter Grain images"
//
// This macro batch processes all the files in a folder and any
// subfolders in that folder. It will run the color threshold on any pictures
// in the folders and output to the specified directory.
// Swap out filterImage() in the processFile() method if you need other functionality.
// The input directory should contain only picture files such as 1.jpg, 2.jpg, 3.jpeg or
// other image files. 

   requires("1.33s");
   // ****************************
   // If you want to set a static directory, you need double slashes '\\'. A '\' is an escape character.
   // Similarly if you need an apostrophe ', you'd need to do \'
   // ****************************
   //This prompts the user to pick an input/output directory
   dir = getDirectory("Choose an input directory ");
   destDir = getDirectory("Choose an image output directory");
   File.makeDirectory(destDir+"ProcessedImages\\");
   imageDir = destDir+"ProcessedImages\\";
   setBatchMode(true);
   count = 0;
   countFiles(dir);
   n = 0;
   processFiles(dir, destDir);
   selectWindow("Summary");
   saveAs("Measurements",destDir+"BlackSummary.xls"); 
   
   function countFiles(dir) {
      list = getFileList(dir);
      for (picNum=0; picNum<list.length; picNum++) {
          if (endsWith(list[picNum], "/"))
              countFiles(dir+list[picNum]);
          else
              count++;
      }
  }

  function makeMontage() {
      setBatchMode(true);
      id=getImageID;
      n= nSlices;
      columns=floor(sqrt(n));
      if (columns*columns<n) columns++;
      rows = columns;
      if (n<=columns*(rows-1)) rows--;
      sw=getWidth; sh=getHeight;
      type = ""+bitDepth;
      if (type=="24") type = "RGB";
      newImage("test", type+" black", columns*getWidth, rows*getHeight, 1);
      iw=getWidth/columns; ih=getHeight/rows;
      montage=getImageID;
      selectImage(id);
      for (i=0; i<n; i++) {
          selectImage(id);
          setSlice(i+1);
          run("Select All");
          run("Copy");
          selectImage(montage);
          makeRectangle((i%columns)*iw, floor(i/columns)*ih, sw, sh);
          run("Paste");
      }
      resetMinAndMax();
 }

   function processFiles(dir, destDir) {
      list = getFileList(dir);
      for (fileNum=0; fileNum<list.length; fileNum++) {
          if (endsWith(list[fileNum], "/"))
              processFiles(dir+list[fileNum],destDir+list[fileNum]);
          else {
             showProgress(n++, count);
             path = dir+list[fileNum];
             File.makeDirectory(destDir+"temp\\");
             tempDir = destDir+"temp\\";
             imagePath = imageDir+list[fileNum];
             editPath = tempDir+"A_"+list[fileNum];
             blackPath = tempDir+"B_"+list[fileNum];
             redPath = tempDir+"C_"+list[fileNum];
             drupePath = tempDir+"D_"+list[fileNum];
             picName = list[fileNum];
             processFile(path, editPath, blackPath, redPath, drupePath, imagePath, picName);
             File.delete(editPath);
             File.delete(blackPath);
             File.delete(redPath);
             File.delete(drupePath);
             File.delete(tempDir);
          }
      }
  }

  function processFile(path, editPath, blackPath, redPath, drupePath, imagePath, picName) {
           open(path);
           run("Size...", "width=1000 height=666");
           makeLine(947,350,947,586);
           run("Set Scale...", "distance=1 known=1 unit=pixel");
           run("Chart White Balance", "chart=[Small MacBeth ColorChecker Chart] include");
           makeRectangle(760,280,1000,666);
	   setForegroundColor(50, 168, 82);
	   run("Fill", "slice");
           //run("Crop");
           saveAs("jpeg", editPath);
	   close();
	   open(editPath);
           filterImage1();
           saveAs("jpeg", blackPath);
           close();
           open(editPath);
           filterImage2();
           saveAs("jpeg", redPath);
           close();
           open(editPath);
           filterImage3();
           saveAs("jpeg", drupePath);
           close(); close(); close(); close();
           open(editPath);
	   open(drupePath);
           open(blackPath);
           open(redPath);
           run("Images to Stack", "name=stack title=[] use");
           makeMontage();
           saveAs("jpeg", imagePath);
           close();

  }
  
  //This is the filter for whole berries
  function filterImage1(){
  min=newArray(3);
  max=newArray(3);
  filter=newArray(3);
  a=getTitle();
  call("ij.plugin.frame.ColorThresholder.RGBtoLab");
  run("RGB Stack");
  run("Convert Stack to Images");
  selectWindow("Red");
  rename("0");
  selectWindow("Green");
  rename("1");
  selectWindow("Blue");
  rename("2");
  min[0]=0;
  max[0]=255;
  filter[0]="pass";
  min[1]=110;
  max[1]=255;
  filter[1]="pass";
  min[2]=0;
  max[2]=255;
  filter[2]="pass";
  for (i=0;i<3;i++){
      selectWindow(""+i);
      setThreshold(min[i], max[i]);
    run("Convert to Mask");
    if (filter[i]=="stop")  run("Invert");
}
imageCalculator("AND create", "0","1");
imageCalculator("AND create", "Result of 0","2");
for (i=0;i<3;i++){
  selectWindow(""+i);
  close();
}
selectWindow("Result of 0");
close();
selectWindow("Result of Result of 0");
rename(a);
  run("Analyze Particles...", "size=50-Infinity circularity=0.00-1.00 show=Masks include summarize");

  }

  //This is the filter for red regions
  function filterImage2(){
  min=newArray(3);
  max=newArray(3);
  filter=newArray(3);
  a=getTitle();
  call("ij.plugin.frame.ColorThresholder.RGBtoLab");
  run("RGB Stack");
  run("Convert Stack to Images");
  selectWindow("Red");
  rename("0");
  selectWindow("Green");
  rename("1");
  selectWindow("Blue");
  rename("2");
  min[0]=0;
  max[0]=100;
  filter[0]="pass";
  min[1]=138;
  max[1]=255;
  filter[1]="pass";
  min[2]=0;
  max[2]=255;
  filter[2]="pass";
  for (i=0;i<3;i++){
      selectWindow(""+i);
      setThreshold(min[i], max[i]);
    run("Convert to Mask");
    if (filter[i]=="stop")  run("Invert");
}
imageCalculator("AND create", "0","1");
imageCalculator("AND create", "Result of 0","2");
for (i=0;i<3;i++){
  selectWindow(""+i);
  close();
}
selectWindow("Result of 0");
close();
selectWindow("Result of Result of 0");
rename(a);
  run("Analyze Particles...", "size=5-Infinity circularity=0.00-1.00 show=Masks include summarize");
  
  }

//This is the filter for counting drupelets
  function filterImage3(){
  min=newArray(3);
  max=newArray(3);
  filter=newArray(3);
  a=getTitle();
  call("ij.plugin.frame.ColorThresholder.RGBtoLab");
  run("RGB Stack");
  run("Convert Stack to Images");
  selectWindow("Red");
  rename("0");
  selectWindow("Green");
  rename("1");
  selectWindow("Blue");
  rename("2");
  min[0]=25;
  max[0]=255;
  filter[0]="pass";
  min[1]=110;
  max[1]=255;
  filter[1]="pass";
  min[2]=0;
  max[2]=255;
  filter[2]="pass";
  for (i=0;i<3;i++){
      selectWindow(""+i);
      setThreshold(min[i], max[i]);
    run("Convert to Mask");
    if (filter[i]=="stop")  run("Invert");
}
imageCalculator("AND create", "0","1");
imageCalculator("AND create", "Result of 0","2");
for (i=0;i<3;i++){
  selectWindow(""+i);
  close();
}
selectWindow("Result of 0");
close();
selectWindow("Result of Result of 0");
rename(a);
run("Watershed");
  run("Analyze Particles...", "size=5-Infinity show=Outlines include summarize");
  
  }