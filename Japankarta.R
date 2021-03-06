library(ggplot2)
library(rgdal) 
library(ggmap)
library(scales)
library(dplyr)
#library(Cairo) # Use with ggsave when saving as an image for interpolation/smoothness
library(rgeos) # Must be loaded before maptools to avoid issues with gpclib license
library(maptools)
library(downloader)

# Laddar ned japans shapefiler (b�de region och kommunniv�) i zipfil
download(url = "http://biogeo.ucdavis.edu/data/diva/adm/JPN_adm.zip", 
         dest = "shapefiles.zip",
         mode = "wb")

# Unzippar shapefilerna i mappen shapefiles
unzip(zipfile = "shapefiles.zip", exdir = "./shapefiles")

# L�ser shapefiler
# JPN_adm1 �r f�r regionerna (prefectures), JPN_adm2 om du vill ha kommunniv� (tror jag)
geo <- readOGR(dsn = "shapefiles",
                 layer = "JPN_adm1")

# �ndra stavning p� vissa prefectures till den stavning japans statistiska byr� anv�nder.
levels(geo$NAME_1)[levels(geo$NAME_1) == "Gunma"] <- "Gumma"
levels(geo$NAME_1)[levels(geo$NAME_1) == "Naoasaki"] <- "Nagasaki"

# G�r om shapefilerna till format som ggplot kan plotta
geo <- fortify(geo, region = "NAME_1")

mydata <- read.csv2(file = "https://github.com/Lauler/Japan-map-chart/raw/master/data/japanpopdens.csv", 
                  dec = ".",
                  stringsAsFactors = FALSE)

# Regionerna (prefectures) b�r vara i kolumn 1 om f�ljande kod ska fungera p� andra datafiler
names(mydata)[1] <- "id"
merged_geo <- merge(geo, mydata, by = "id") 


p <- ggplot() +
  geom_polygon(data = merged_geo, 
               aes(x = long, y = lat, group = group, fill = Density),
               color = "black",
               size = 0.1) +
  coord_map() + # Ser till att kartan inte f�r f�rvr�ngda proportioner
  theme_nothing(legend = TRUE) + # Tar bort grids och axlar men l�mnar legenden
  scale_fill_gradient(name = "Density", limits = c(0, 6500), low = "white", high = "red")

p


# Anv�nd kodsnutten nedan f�r att testa om regionerna i shapefilen matchar regionerna
# i datafilen. Den printar alla regionerna i din datafil som inte matchar med n�gon str�ng
# i shapefilerna. K�r den endast p� geo _innan_ du fortifyat geo.

# v <- as.character(geo$NAME_1)
# 
# for (word in 1:length(mydata$id)){
#   if (!is.element(mydata$id[word], v)){
#     print(mydata$id[word])
#     
#   }
# }
