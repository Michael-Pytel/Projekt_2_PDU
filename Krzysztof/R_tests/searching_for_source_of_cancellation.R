data_dir <-"~/laby_PDU/Projekt_2_outer/Projekt_2_PDU/Dane/"
years_dir <- paste(data_dir,"pliczki/", sep = "")
library(data.table)
library(ggplot2)
library(usmap)
library(gridExtra)
library(grid)
library('Dict')

can_stats <- read.csv(file.path(data_dir, "cancellationsStatsPerYear.csv"))
can_stats <- as.data.table(can_stats)
#View(can_stats)


interesting_ones <- can_stats[GrThanCanPercMean == T, ] 
length(interesting_ones$Year)
#interesting_ones <-  within(interesting_ones,rm(MostCanAt))
interesting_ones[,"MostCanAt"] <- as.Date("1 6 2023", format = "%d %m %Y")

#preparing data
# important frames (results) are interesing_ones and test 

for(y in 1:length(interesting_ones$Year)){
  cat(paste("current year: ", interesting_ones$Year[y],"\n", sep = ""))
  df_name <- paste("df_", interesting_ones$Year[y], sep = "")
  assign(df_name, as.data.table(read.csv(paste(years_dir, 
                                               paste(interesting_ones$Year[y], 
                                                     ".csv", 
                                                     sep = ""), 
                                               sep = ""))))
  cat("Reading data complete\n")
  tmp <- get(df_name)[Cancelled != 0, 
                      .("FlightsCancelled" = .N),
                      keyby = .(Month, DayofMonth)]
  tmp <- tmp[order(FlightsCancelled, decreasing = T)]
  assign(paste(df_name, "_2", sep = ""), tmp[1,])
  cat("First step of analysis complete\n")
  m <- tmp[1, Month]
  d <-tmp[1, DayofMonth]
  interesting_ones[y,"MostCanAt"] <- as.Date(paste(d,m,interesting_ones$Year[y]), 
                                             format = "%d %m %Y")
  
  tmp <- get(df_name)[Month == m & DayofMonth == d & Cancelled == 1,
                      .("Total" = .N), 
                      keyby=.(Dest)]
  tmp <- tmp[order(Total,decreasing = T)]
  assign(df_name, tmp)
  cat("Second step complete\n")
  
  gc()
}


airports <- as.data.table(read.csv(file.path(data_dir, "airports.csv")))
colnames(airports)
#View(head(airports[airports$country == "USA", .(iata,lat,long)],10))

ap <- airports[airports$country == "USA", .("lon" = long, lat, iata)]

ap_transformed <- usmap_transform(ap)
rm(tmp)

test <- df_1996 
s <- c(1996)
for (y in 2:length(interesting_ones$Year)){
  current_year <- interesting_ones$Year[y]
  df_name <- paste("df_", current_year, sep = "")
  s <- c("", current_year)
  test <- merge.data.table(test, get(df_name), by = "Dest", all.y = T, all.x = T,
                           suffixes = s)
}
colnames(test)[2] <- "Total1996"

#length(test$Total2007[!is.na(test$Total2007)])

max_flights <- max(sapply(test[,2:9], max, na.rm = T))
min_flights <- min(sapply(test[,2:9], min, na.rm = T))


#plotting

for(y in 1:length(interesting_ones$Year)){
  df_name <- paste("df_", interesting_ones$Year[y], sep = "")  

  dest_transformed <- merge.data.table(get(df_name), ap_transformed, 
                                     by.x = "Dest", by.y = "iata", suffixes = "Dest")
  if(y == 7){
    tmp <- plot_usmap() +
      geom_point(data = dest_transformed, aes(x = x, 
                                              y = y,
                                              size = Total,
                                              alpha = Total),color = "blue") +
      #    scale_fill_discrete(labels=c("Count"), ) + 
      scale_size(limits = c(min_flights,max_flights)) +
      scale_alpha(limits = c(min_flights,max_flights)) +
      ggtitle(paste(interesting_ones[Year == interesting_ones$Year[y], MostCanAt])) +
      theme(plot.title = element_text(hjust = 0.5, face = "bold", size= 16), 
            legend.position = c(-0.5,-0.2),
            legend.direction = "horizontal",
            legend.text = element_text(size = 10),
            legend.title = element_text(size = 11))
  } else {
    tmp <- plot_usmap() +
      geom_point(data = dest_transformed, aes(x = x, 
                                              y = y,
                                              size = Total,
                                              alpha = Total),color = "blue") +
      #    scale_fill_discrete(labels=c("Count"), ) + 
      scale_size(limits = c(min_flights,max_flights)) +
      scale_alpha(limits = c(min_flights,max_flights)) +
      ggtitle(paste(interesting_ones[Year == interesting_ones$Year[y], MostCanAt])) +
      theme(plot.title = element_text(hjust = 0.5, face = "bold", size= 16), 
            legend.position = "none")
    #         legend.direction = "vertical",
    #          legend.text = element_text(size = 10),
    #          legend.title = element_text(size = 11))
  }
  assign(paste("p", y, sep = ""), tmp)
}




grid.arrange(
  p1,
  p2,
  p3,
  p4,
  p5,
  p6,
  p7,
  p8,
  nrow = 2,
  top = textGrob("Mapy liczby odwołanych lotów dla lotnisk w dniu: ", 
                 gp = gpar(fontface = "bold", fontsize = 20), 
                 y = 1, just = c(0.5, 2.6))
)


#additional analysys
check <- read.csv(file.path(years_dir, "2004.csv"))
check <- as.data.table(check)[Cancelled != 0, 
                    .("FlightsCancelled" = .N),
                    keyby = .(Month, DayofMonth)]
check <- check[order(FlightsCancelled, decreasing = T)]
rm(check)

##### part 2
cancellation_sources <- as.data.frame(LETTERS[1:4])
colnames(cancellation_sources) <- c("Code")
cancellation_sources['Total'] <- rep(0, times = 4)

for(y in 2003:2008){
  cat(paste("current year: ", y,"\n", sep = ""))
  df_name <- paste("df2_", y, sep = "")
  assign(df_name, as.data.table(read.csv(paste(data_dir, 
                                               paste("df_",
                                                     y,
                                                     ".csv", 
                                                     sep = ""), 
                                               sep = ""))))
  cat("Reading data complete\n")
  cancellation_sources["Total"] <-cancellation_sources$Total + get(df_name)[!is.na(CancellationCode), .(Count)]
  gc()
}

#changing CancellationCode values
n_codes <- Dict$new(
  "A" = "carrier", 
  "B" = "weather", 
  "C" = "NAS", 
  "D" = "security")

for(row in 1:length(cancellation_sources$Code)){
  value <- cancellation_sources$Code[row]
  cancellation_sources$Code[row] <- n_codes$get(value)
}

#cleaning
rm(row,value,xlim)  

ggplot(data = cancellation_sources, 
       aes(reorder(Code, Total), Total, fill = Code))+
  geom_col() +
  scale_y_continuous(expand = c(0, 0), 
                     limits = c(0, max(cancellation_sources$Total) + 30000))+
  geom_text(aes(label = Total),
            angle = 0,
            vjust = -0.5) +
  theme_gray()+
  xlab("Code")+
  theme(legend.position = "none", 
        axis.text.y = element_blank(),
        axis.title.y = element_text( family = "Arial"),
        axis.title.x = element_text( family = "Arial"))

  
  
