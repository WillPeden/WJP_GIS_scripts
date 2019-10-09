#required packages
library(jsonlite); library(sf); library(lubridate); library(zoo); library("rnaturalearth"); library("rnaturalearthdata"); library(ggplot2)

x <- jsonlite::fromJSON("<YOUR GOOGLE LOCATION DATA (JSON) FILEPATH HERE>.json")

# extracting the locations dataframe
loc = x$locations

# converting time column from posix milliseconds into a readable time scale
loc$time = as.POSIXct(as.numeric(x$locations$timestampMs)/1000, origin = "1970-01-01")

# converting longitude and latitude from E7 to GPS coordinates, save as vectors
lat = loc$latitudeE7 / 1e7
lon = loc$longitudeE7 / 1e7

# extract dates as vector
date <- as.Date(loc$time, format = '%Y/%m/%d')

# combine vectors to create data frame for use with sf
t <- data.frame(id = 1:length(date),date=date, lon = lon, lat = lat)
locations = st_as_sf(t, coords = c("lon", "lat"), crs = 4326, agr = "constant", remove=F)

# remove scary erroneous points in India(!)
locations <- locations[locations$lon < 70,]

# load in some country polygons
world <- ne_countries(scale = "large", returnclass = "sf")
europe <- world[world$region_un=="Europe",]

# all points plot
all <- ggplot() +
  geom_sf(data=europe, fill= "antiquewhite") +
  geom_sf(data = locations, col = "red") +
  coord_sf(xlim = c(min(locations$lon)-2.5, max(locations$lon)+2.5), 
           ylim = c(min(locations$lat)-2.5, max(locations$lat)+2.5), expand = FALSE, datum =NA) +
  theme(panel.grid.major = element_line(color = gray(.5), linetype = "dashed", size = 0.5), 
        panel.background = element_rect(fill = "aliceblue"))

# UK points plot (can change coord_sf to cover all your data)
UK <- ggplot() +
  geom_sf(data=europe, fill= "antiquewhite") +
  geom_sf(data = locations, col = "red") +
  coord_sf(xlim = c(-6.5, 2), 
           ylim = c(50, 57), expand = FALSE, datum = NA) +
  theme(panel.grid.major = element_line(color = gray(.5), linetype = "dashed", size = 0.5), 
        panel.background = element_rect(fill = "aliceblue"))

# The following just combines the two maps onto one plot
p2 <- ggplot() +
  coord_equal(xlim = c(0, 2), ylim = c(0, 1.3), expand = FALSE) +
  annotation_custom(ggplotGrob(all), xmin = 0, xmax = 1, ymin = 0, 
                    ymax = 1) +
  annotation_custom(ggplotGrob(UK), xmin = 1, xmax = 2, ymin = 0, 
                    ymax = 1.3) +
  theme_void()

# save as a png
ggsave("<YOUR MAP OUTPUT LOCATION HERE>.png", plot = p2, dpi=600, scale = 2.5)

# can also create an interactive map with mapview
mapview::mapview(locations)