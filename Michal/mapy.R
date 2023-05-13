library(tidyverse)
library(sf)
library(mapview)

airports <- read.csv("../Dane/airports.csv")

mapview(airports, xcol = "long", ycol = "lat", crs = 4269, grid = FALSE)

