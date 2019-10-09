## points to polygon script

# assumes points are in correct order for drawing polygon

library(tidyverse)
library(sf)


temp <- read.csv("<YOUR CSV FILE PATH HERE>.csv")
# optional subset of data we require and removal of duplicates
temp<- subset(temp, select = c("licence", "area_name", "lat", "long"))
temp <- temp[!duplicated(temp),]

polygon <- temp %>%
  st_as_sf(coords = c("long", "lat"), crs = 4326) %>%
  group_by(area_name) %>%
  summarise(geometry = st_combine(geometry)) %>%
  st_cast("POLYGON") 

# add licence number column, or can add any other descriptive information as required
polygon$licence <- NA
for (i in 1:nrow(polygon)){
  dr <- as.character(polygon[i,]$area_name)
  polygon[i,]$licence <- as.character(temp[temp$area_name==dr,]$licence[1])
}

st_write(polygon, "<YOUR OUTPUT PATH HERE>/polygon_name_here.shp", delete_layer=TRUE)

