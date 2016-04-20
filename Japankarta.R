library(ggplot2)
library(rgdal)
library(ggmap)
library(scales)
library(dplyr)
library(Cairo)
library(rgeos) # Must be loaded before maptools to avoid issues with gpclib license
library(maptools)
library(downloader)

# Laddar ned japans shapefiler (både region och kommunnivå) i zipfil
download(url = "http://biogeo.ucdavis.edu/data/diva/adm/JPN_adm.zip", 
         dest = "shapefiles.zip",
         mode = "wb")

# Unzippar shapefilerna i mappen shapefiles
unzip(zipfile = "shapefiles.zip", exdir = "./shapefiles")

# Läser shapefiler
# JPN_adm1 är för regionerna (prefectures), JPN_adm2 om du vill ha kommunnivå (tror jag)
tract <- readOGR(dsn = "shapefiles",
                 layer = "JPN_adm1")

# Ändra stavning på vissa prefectures till den stavning japans statistiska byrå använder.
levels(tract$NAME_1)[levels(tract$NAME_1) == "Gunma"] <- "Gumma"
levels(tract$NAME_1)[levels(tract$NAME_1) == "Naoasaki"] <- "Nagasaki"

# Gör om shapefilerna till format som ggplot kan plotta
tract <- fortify(tract, region = "NAME_1")

mydata <- read.csv2(file = "C:/Users/Faton/Desktop/R-ovning/Japan grid/japanpopdens.csv", 
                  dec = ".",
                  stringsAsFactors = FALSE)

names(mydata)[1] <- "id"

merged_tract <- merge(tract, mydata, by = "id") 


p <- ggplot() +
  geom_polygon(data = merged_tract, 
               aes(x = long, y = lat, group = group, fill = Density),
               color = "black",
               size = 0.1) +
  coord_map() +
  theme_nothing(legend = TRUE) +
  scale_fill_gradient(name = "Density", limits = c(0, 6500), low = "white", high = "red")

p

names(merged_tract)






# v <- as.character(tract$NAME_1)
# 
# for (word in 1:length(mydata$id)){
#   if (!is.element(mydata$id[word], v)){
#     print(mydata$id[word])
#     
#   }
# }
