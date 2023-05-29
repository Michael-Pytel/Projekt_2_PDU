library('usmap')
library('data.table')
library(ggplot2)
library(ggrepel)

rm(list = ls())
data_dir <-"~/laby_PDU/Projekt_2_outer/Projekt_2_PDU/Dane/"
years_dir <- paste(data_dir,"pliczki/", sep = "")

airports <- as.data.table(read.csv(file.path(data_dir, "airports.csv")))
#colnames(airports)
#View(head(airports[airports$country == "USA", .(iata,lat,long)],10))

ap <- airports[airports$country == "USA", .("lon" = long, lat, iata)]

ap_transformed <- usmap_transform(ap)

#test
#plot_usmap() +
#  geom_point(data = ap_transformed, aes(x = x, y = y),
#             color = "red", alpha = 0.25)

#?usmap_transform
#?aes
#rm(num_of_flights_daily)


###preparing first frame
df_1996 <- as.data.table(read.csv(file.path(years_dir,"1996.csv")))

df_1996 <- df_1996[, .( "totalFlights" = .N), keyby = .(Origin,Dest)]
df_1996 <- df_1996[order(totalFlights, decreasing = T),]

#merging routes (adding count of flights in both ways on the same route/path)
df_1 <- df_1996[,.(Origin,Dest, totalFlights, "Route" = paste(Origin,Dest))]
df_2 <- df_1996[,.(totalFlights, 
                   "Route" = paste(Dest,Origin))]
total_routes <- merge.data.table(df_1,df_2, 
                              by = c("Route") 
                              )
route <- total_routes$Route
origin <- substring(route,1,3)
destination <- substring(route,5,7)
idx <-  (origin > destination)

total_routes <- total_routes[idx,]
total_routes <- total_routes[,.("totalFlights" = sum(totalFlights.x,totalFlights.y)),
                          keyby = .(Origin,Dest)]
total_routes <- total_routes[order(totalFlights,decreasing = T),]

####

s <- c(1996) # for setting suffixes in merge() function
for(y in 1997:2008){
  cat(paste("current year: ", y,"\n", sep = ""))
  df_name <- paste("df_", y, sep = "")
  
  assign(df_name, as.data.table(read.csv(file.path(years_dir,
                                                   paste(y,
                                                         ".csv", 
                                                         sep = "")))))
  cat("Reading data complete\n")
  
  assign(df_name,get(df_name)[, .( "totalFlights" = .N), keyby = .(Origin,Dest)])
  assign(df_name,get(df_name)[order(totalFlights, decreasing = T),])
  
  #merging routes (adding count of flights in both ways on the same route/path)
  df_1 <- get(df_name)[,.(Origin,Dest, totalFlights, "Route" = paste(Origin,Dest))]
  df_2 <- get(df_name)[,.(totalFlights, 
                     "Route" = paste(Dest,Origin))]
  tmp <- merge.data.table(df_1,df_2, 
                                   by = c("Route"))
  route <- tmp$Route
  origin <- substring(route,1,3)
  destination <- substring(route,5,7)
  idx <-  (origin > destination)
  
  tmp <- tmp[idx,]
  tmp <- tmp[,.("totalFlights" = sum(totalFlights.x,totalFlights.y)),
                               keyby = .(Origin,Dest)]
  tmp <- tmp[order(totalFlights,decreasing = T),]
  
  cat("Second step complete\n")
  
  s <- c("", y)
  total_routes <- merge.data.table(total_routes,tmp, 
                                   all = T, 
                                   by = c("Origin", "Dest"),
                                   suffixes = s)
  cat("Third step complete\n")
  
  rm(list = ls(pattern = df_name)) # we only need total_routes frame
  gc()
  cat("Cleaning complete\n")
}

total_routes <- total_routes[,
                             .("totalFlights" = sum(totalFlights,
                                                    totalFlights1997,
                                                    totalFlights1998,
                                                    totalFlights1999,
                                                    totalFlights2000,
                                                    totalFlights2001,
                                                    totalFlights2002,
                                                    totalFlights2003,
                                                    totalFlights2004,
                                                    totalFlights2005,
                                                    totalFlights2006,
                                                    totalFlights2007,
                                                    totalFlights2008,
                                                    na.rm = T)), 
                             keyby = .(Origin,Dest)]
total_routes <- total_routes[order(totalFlights,decreasing = T)]

top_50 <- head(total_routes,50)

# adding coordinates of airports
origins_transformed <- merge.data.table(top_50, ap_transformed, 
                 by.x = "Origin", by.y = "iata", suffixes = "Origin")
origins_transformed2 <- merge.data.table(origins_transformed, 
                                        ap_transformed, 
                                        by.x = "Dest", by.y = "iata", 
                                        suffixes = c("Origin", "Dest"))
total_ap <- merge.data.table(origins_transformed2[,.(Origin), 
                                                  by = .(Origin, xOrigin,yOrigin)][,1:3],
                             origins_transformed2[,.(Dest),
                                                  by = .(Dest, xDest, yDest)][,1:3],
                             by.x = "Origin", by.y= "Dest", all = T)
total_ap <- total_ap[is.na(xOrigin), xOrigin:=xDest]
total_ap <- total_ap[is.na(yOrigin), yOrigin:=yDest] 
total_ap <- total_ap[,.(Origin,xOrigin,yOrigin)]
#end of prepairng data

# plot
plot_usmap() +
  geom_segment(data = origins_transformed2, 
               aes(x = xOrigin, y = yOrigin, xend = xDest, yend = yDest, 
                   linewidth = totalFlights),
               color = "green") +
  geom_segment(data = origins_transformed2, 
               aes(x = xOrigin, y = yOrigin, xend = xDest, yend = yDest),
               color = "blue") +
  geom_point(data = origins_transformed2, aes(x = xOrigin, y = yOrigin),
             color = "blue", size = 5) + 
  geom_point(data = origins_transformed2, aes(x = xDest, y = yDest),
             color = "blue", size = 5)+
  geom_label_repel(data = total_ap,
                  aes(x = xOrigin, y = yOrigin, label = Origin),
                  box.padding   = 0.35, 
                  point.padding = 0.5,
                  segment.color = 'grey50') +
  ggtitle("50 najpopularniejszych tras lotniczych w latach 1996-2008") +
  labs(linewidth = "Loty")+
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size= 16), 
        legend.title = element_text(face = "bold", size= 11),
        legend.position = c(0.95, 0.4))
  

#?geom_line
#?geom_segment
#?guide_legend
#?geom_text_repel

#################tests
#year_1996 <- read.csv(file.path("~/laby_PDU/Projekt_2_outer/Projekt_2_PDU/Dane/",
#                                paste("year_1996", ".csv", sep ="")))
#year_1996 <- as.data.table(year_1996)[,.(Dest, Total)]


#dest_transformed <- merge.data.table(year_1996, ap_transformed, 
#                                        by.x = "Dest", by.y = "iata", suffixes = "Dest")
#plot_usmap() +
#  geom_point(data = dest_transformed, aes(x = x, 
#                                         y = y,                                         size = Total,
#                                         alpha = Total),color = "blue") +
#  scale_fill_discrete(labels=c("Count"), ) + 
#  ggtitle("Cancelled flights on 08.01.1996") +
#  theme(plot.title = element_text(hjust = 0.5, face = "bold", size= 20), 
#        legend.position = c(0.9, 0.5),
#        legend.text = element_text(size = 12),
#        legend.title = element_text(size = 14)) 


