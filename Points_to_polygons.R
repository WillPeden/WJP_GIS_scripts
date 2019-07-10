##points to polygon script

library(tidyverse)
library(sf)

temp <- read.csv("C:/Users/WP01/OneDrive - CEFAS/Temp/For_jemma/20190624 Scottish Dredge Areas Coords.csv")
temp<- subset(temp, select = c("Licence", "Dredge.Area.Name", "Lat", "Long"))
temp <- temp[!duplicated(temp),]

polygon<-temp %>%
  st_as_sf(coords = c("Long", "Lat"), crs = 4326) %>%
  group_by(Dredge.Area.Name) %>%
  summarise(geometry = st_combine(geometry)) %>%
  st_cast("POLYGON") 

#add licence number column
polygon$Licence<-NA
for (i in 1:nrow(polygon)){
  dr <- as.character(polygon[i,]$Dredge.Area.Name)
  polygon[i,]$Licence <- as.character(temp[temp$Dredge.Area.Name==dr,]$Licence[1])
}

st_write(polygon, "C:/Users/WP01/OneDrive - CEFAS/Temp/For_jemma/Dredge_areas.shp", delete_layer=TRUE)

