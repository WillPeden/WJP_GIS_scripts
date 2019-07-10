
##################################################
## Project: Handy GIS script
## Script purpose: kml files to shapefiles
## Date: 10/07/2019
## Author: William J Peden
##################################################

#  This script takes a folder of 1 or more kml files (usually generated in Google Earth) and extracts the 
#  spatial features, while preserving names, and then saves as shapefiles.  

#  If the kml contains a combination of lines, polygons and/or points, the script will save the shapefiles 
#  separately according to type.

#  You need to input the path to the folder containing the kmls you wish to convert, as well as the output 
#  folder path, and the output name for shapefile.

#  Input folder containing kmls, e.g. "C:/Users/WP01/OneDrive - CEFAS/Temp"
input_folder_path <- "C:/Users/YOUR_INPUT_FOLDER_PATH_HERE"

#  output folder for shapefiles
output_folder_path <- "C:/Users/YOUR_OUTPUT_FOLDER_PATH_HERE"

#  shapefile output name
output_name <- "shapefile1"

#  requires sf package, if not already installed use: install.packages("sf")
library(sf)


##################################################


##function to read features from kml using sf package
read.kml <- function(kmlfile){
  lyr <- st_layers(kmlfile)
  mykml<- NA
  for (i in 1:length(lyr$name)) {
    if(is.na(mykml)[1]){mykml <- st_read(dsn=kmlfile,lyr$name[i]); mykml$lyr_nm <- lyr$name[i]}else{
    mykml_temp <- st_read(dsn=kmlfile,lyr$name[i])
    mykml_temp$lyr_nm <- lyr$name[i]
    mykml <- rbind(mykml, mykml_temp)}
  }
  return(mykml)
}

#get kml files from folder
kmls <-list.files(input_folder_path)[grep(paste0(c(".kml", ".KML"), collapse = "|"), list.files(input_folder_path))]

first_poly<-T
first_point<-T
first_line<-T
for (k in 1:length(kmls)){
  kmlfile <- paste0(input_folder_path,"/", kmls[k])
  mykml <- read.kml(kmlfile)
  mykml$kml_nm <- kmls[k]
  #now we have read the kml, we need to save separately depending on geometry type (point, polygon or line)
  for (i in 1:nrow(mykml))
  {
  if(st_geometry_type(mykml[i,])=="POLYGON"){
    if(first_poly==F){output_poly <- rbind(output_poly, mykml[i,])}else{output_poly <- mykml[i,]}
    first_poly=F
  }
  if(st_geometry_type(mykml[i,])=="POINT"){
    if(first_point==F){output_point <- rbind(output_point,mykml[i,])}else{output_point <- mykml[i,]}
    first_point=F
  }
  if(st_geometry_type(mykml[i,])=="LINESTRING"){
    if(first_line==F){output_line <- rbind(output_line,mykml[i,])}else{output_line <- mykml[i,]}
    first_line=F
  }}
}

#drop Z geometry (3D shapefiles to 2D shapefiles) for shapefile compatibility 
if(first_poly==F) {output_poly  <- st_zm(output_poly,  drop = TRUE, what = "ZM")}
if(first_point==F){output_point <- st_zm(output_point, drop = TRUE, what = "ZM")}
if(first_line==F) {output_line  <- st_zm(output_line,  drop = TRUE, what = "ZM")}

#write output as shapefiles
if(first_poly==F) {st_write(output_poly,   paste0(output_folder_path, "/", output_name, "_poly.shp"),  driver="ESRI Shapefile")}
if(first_point==F){st_write(output_point,  paste0(output_folder_path, "/", output_name, "_point.shp"), driver="ESRI Shapefile")}
if(first_line==F) {st_write(output_line,   paste0(output_folder_path, "/", output_name, "_line.shp"),  driver="ESRI Shapefile")}

