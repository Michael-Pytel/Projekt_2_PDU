library('usmap')
library('data.table')
library(ggplot2)


data_dir <-"~/laby_PDU/Projekt_2_outer/Projekt_2_PDU/Dane"
rm(airposts)
airports <- as.data.table(read.csv(file.path(data_dir, "airports.csv")))
colnames(airports)
View(head(airports[airports$country == "USA", .(iata,lat,long)],10))

ap <- airports[airports$country == "USA", .("lon" = long, lat, iata)]

ap_transformed <- usmap_transform(ap)


plot_usmap() +
  geom_point(data = ap_transformed, aes(x = x, y = y),
             color = "red", alpha = 0.25)

?usmap_transform
?aes
rm(num_of_flights_daily)

df_2007 <- as.data.table(read.csv(file.path(data_dir,"2007.csv")))
View(head(df_2007,100))
View(head(ap_transformed,10))
colnames(df_2007)

df_2007 <- df_2007[, .( "totalFlights" = .N), keyby = .(Origin,Dest)]
df_2007 <- df_2007[order(totalFlights, decreasing = T),]

#scalanie tras (sumowanie lotow w dwie strony)
df_1 <- df_2007[,.(Origin,Dest, totalFlights, "Route" = paste(Origin,Dest))]
df_2 <- df_2007[,.(totalFlights, 
                   "Route" = paste(Dest,Origin))]
df_2007_2 <- merge.data.table(df_1,df_2, 
                              by = c("Route") 
                              )
test <- df_2007_2$Route
test1 <- substring(test,1,3)
test2 <- substring(test,5,7)
idx <-  (test1 > test2)
test3 <- test[idx]

df_2007_2 <- df_2007_2[idx,]
df_2007_2 <- df_2007_2[,.("totalFlights" = sum(totalFlights.x,totalFlights.y)),
                          keyby = .(Origin,Dest)]
df_2007_2 <- df_2007_2[order(totalFlights,decreasing = T),]



top_50 <- head(df_2007_2,50)

origins_transformed <- merge.data.table(top_50, ap_transformed, 
                 by.x = "Origin", by.y = "iata", suffixes = "Origin")
origins_transformed2 <- merge.data.table(origins_transformed, 
                                        ap_transformed, 
                                        by.x = "Dest", by.y = "iata", 
                                        suffixes = c("Origin", "Dest"))
plot_usmap() +
  geom_point(data = origins_transformed2, aes(x = xOrigin, y = yOrigin),
             color = "red", alpha = 0.25) + 
  geom_segment(data = origins_transformed2, 
               aes(x = xOrigin, y = yOrigin, xend = xDest, yend = yDest, 
                   linewidth = totalFlights/1000),
               color = "green")
?geom_line
?geom_segment
