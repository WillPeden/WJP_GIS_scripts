#required packages
library(jsonlite); library(sf); library(lubridate); library(zoo); library("rnaturalearth"); library("rnaturalearthdata"); library(ggplot2)

x <- jsonlite::fromJSON("C:/Users/WP01/OneDrive - CEFAS/Temp/my_google_data/takeout-20191008T161813Z-001/Takeout/Location History/Location History.json")

# extracting the locations dataframe
loc = x$locations

# converting time column from posix milliseconds into a readable time scale
loc$time = as.POSIXct(as.numeric(x$locations$timestampMs)/1000, origin = "1970-01-01")

# converting longitude and latitude from E7 to GPS coordinates
lat = loc$latitudeE7 / 1e7
lon = loc$longitudeE7 / 1e7

# calculate the number of data points per day, month and year
loc$date <- as.Date(loc$time, format = '%Y/%m/%d')
date <- as.Date(loc$time, format = '%Y/%m/%d')

t <- data.frame(id = 1:length(date),date=date, lon = lon, lat = lat)
locations = st_as_sf(t, coords = c("lon", "lat"), crs = 4326, agr = "constant", remove=F)

#remove scary erroneous points in India(!)
locations <- locations[locations$lon < 70,]

#create sf from 
world <- ne_countries(scale = "large", returnclass = "sf")
europe <- world[world$region_un=="Europe",]

all <- ggplot() +
  geom_sf(data=europe, fill= "antiquewhite") +
  geom_sf(data = locations, col = "red") +
  coord_sf(xlim = c(min(locations$lon)-2.5, max(locations$lon)+2.5), 
           ylim = c(min(locations$lat)-2.5, max(locations$lat)+2.5), expand = FALSE, datum =NA) +
  theme(panel.grid.major = element_line(color = gray(.5), linetype = "dashed", size = 0.5), 
        panel.background = element_rect(fill = "aliceblue"))

UK <- ggplot() +
  geom_sf(data=europe, fill= "antiquewhite") +
  geom_sf(data = locations, col = "red") +
  coord_sf(xlim = c(-6.5, 2), 
           ylim = c(50, 57), expand = FALSE, datum = NA) +
  theme(panel.grid.major = element_line(color = gray(.5), linetype = "dashed", size = 0.5), 
        panel.background = element_rect(fill = "aliceblue"))

p2 <- ggplot() +
  coord_equal(xlim = c(0, 2), ylim = c(0, 1.3), expand = FALSE) +
  annotation_custom(ggplotGrob(all), xmin = 0, xmax = 1, ymin = 0, 
                    ymax = 1) +
  annotation_custom(ggplotGrob(UK), xmin = 1, xmax = 2, ymin = 0, 
                    ymax = 1.3) +
  theme_void()

ggsave("C:/Users/WP01/OneDrive - CEFAS/Temp/my_google_data/map3.png", plot = p2, dpi=600, scale = 2.5)

##can also creat interactive map with mapview
#mapview::mapview(locations)