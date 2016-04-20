library(ggplot2)
library(rgdal) 
library(ggmap)
library(scales)
library(dplyr)
#library(Cairo) # Use with ggsave when saving as an image for interpolation/smoothness
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
geo <- readOGR(dsn = "shapefiles",
                 layer = "JPN_adm1")

# Ändra stavning på vissa prefectures till den stavning japans statistiska byrå använder.
levels(geo$NAME_1)[levels(geo$NAME_1) == "Gunma"] <- "Gumma"
levels(geo$NAME_1)[levels(geo$NAME_1) == "Naoasaki"] <- "Nagasaki"

# Gör om shapefilerna till format som ggplot kan plotta
geo <- fortify(geo, region = "NAME_1")

mydata <- read.csv2(file = "https://github.com/Lauler/Japan-map-chart/raw/master/data/japanpopdens.csv", 
                  dec = ".",
                  stringsAsFactors = FALSE)

# Regionerna (prefectures) bör vara i kolumn 1 om följande kod ska fungera på andra datafiler
names(mydata)[1] <- "id"
merged_geo <- merge(geo, mydata, by = "id") 


p <- ggplot() +
  geom_polygon(data = merged_geo, 
               aes(x = long, y = lat, group = group, fill = Density),
               color = "black",
               size = 0.1) +
  coord_map() + # Ser till att kartan inte får förvrängda proportioner
  theme_nothing(legend = TRUE) + # Tar bort grids och axlar men lämnar legenden
  scale_fill_gradient(name = "Density", limits = c(0, 6500), low = "white", high = "red")

p


# Använd kodsnutten nedan för att testa om regionerna i shapefilen matchar regionerna
# i datafilen. Den printar alla regionerna i din datafil som inte matchar med någon sträng
# i shapefilerna. Kör den endast på geo _innan_ du fortifyat geo.

# v <- as.character(geo$NAME_1)
# 
# for (word in 1:length(mydata$id)){
#   if (!is.element(mydata$id[word], v)){
#     print(mydata$id[word])
#     
#   }
# }
