cancellations_stats <- function(dataFrame){
  #Uses data.table package
  #returns a data.table
  
  #Useful columns: Cancelled, CancellationCode
  
  result <- as.data.table(dataFrame)[(Cancelled != 0), 
                                     .("Count" = .N),
                                     keyby = CancellationCode]
  result <- result[order(Count, decreasing = T),]
  
}

massUnpack_bzip2 <- function(files, ext = '.csv.bz2'){
  #files: a character vector of files' names, 
  #returns logical vector (TRUE if file was extracted successfully)
  
  info <- logical(length(files))
  names(info) <- files
  
  for( i in 1:length(files)){
    tryCatch(
      expr = {
        system2("bzip2", args = sprintf("-d %s", paste(files[i], ext, sep='')))
        TRUE
      }, 
      error = function(e) {
        FALSE
      }
    ) -> info[i]
  }
  invisible(info)
}


data_dir <-"~/laby_PDU/Projekt_2_outer/Projekt_2_PDU/Dane/pliczki"
files <- as.character(1987:2008)
paths <- file.path(data_dir, paste(files,".csv", sep = ""))

#u_paths <- file.path(data_dir,files)
#info <- massUnpack_bzip2(u_paths)


x <- file.exists(paths)
x[x!=T]

library('data.table')
library('ggplot2')

df <- as.data.frame(files)
df['sum'] <- rep(0, times = length(files))
df['All'] <- rep(0, times = length(files))
colnames(df) <- c("Year", "SumCancelled", "All")
#df <- df[, c("Year", "SumCancelled"), drop = F]

for(i in 1:length(paths)){
  cat(paste("current year: ", files[i],"\n", sep = ""))
  
  #create variable
  df_name <- paste("df_", files[i], sep = "")
  assign(df_name, read.csv(paths[i]))
  
  #execute function
  df[i,"All"] <- nrow(get(df_name))
  assign(df_name, cancellations_stats(get(df_name)))
  df[i, "SumCancelled"] <- sum(get(df_name)$Count)
  cat('Analysis complete\n')
  
  #clean memory
  gc() # free unused memory
  
  cat('Cleaning complete\n')
}
?geom_bar


#plot
colnames(df) <- c("Year", "CancelledFlights", "AllFlights")
m <- mean(df$CancelledFlights)
df["GreaterThanMean"] <- df$CancelledFlights > m
df["CancelledPercentage"] <- df$CancelledFlights/df$AllFlights * 100
mp <- mean(df$CancelledPercentage)
df["GrThanCanPercMean"] <- df$CancelledPercentage > mp 


##cancellations (simple)
ggplot(data = df, aes(x = Year, 
                      y = CancelledFlights, 
                      fill = GreaterThanMean))+ 
  geom_col() + 
  scale_fill_manual(values = c("blue", "lightblue"))+
  geom_hline(yintercept = m, 
             linetype = "dashed", 
             colour = "red") +
  scale_y_continuous(expand = c(0, 0), 
                     limits = c(0, max(df$CancelledFlights) + 1000))+
  geom_text(aes(label = CancelledFlights),
            angle = 90,
            hjust = 1.1) +
  theme_gray()+
  theme(legend.position = "none")

##cancellations (percentage)
perc <- ggplot(data = df, aes(x = Year, 
                      y = CancelledPercentage, 
                      fill = GrThanCanPercMean))+ 
  geom_col() + 
  scale_fill_manual(values = c("blue", "lightblue"))+
  geom_hline(yintercept = mp, 
             linetype = "dashed", 
             colour = "red") +
  scale_y_continuous(expand = c(0, 0), 
                     limits = c(0, max(df$CancelledPercentage)*1.5))+
  geom_text(aes(label = round(CancelledPercentage, 2)),
            angle = 0,
            vjust = -0.5,
            ) +
  theme_gray()+
  theme(legend.position = "none")

##total flights per year 
perc + ggplot(data = df, aes(x = Year, 
                      y = AllFlights,
                      label = AllFlights, 
                      angle = 90 , hjust = 1.1))+ 
  geom_col(fill = "green") + geom_text() +
  scale_y_continuous(expand = c(0, 0), 
                     limits = c(0, max(df$AllFlights)*1.1)) +
  theme(legend.position = "none")

###save data
write.csv(df, file = file.path("~/laby_PDU/Projekt_2_outer/Projekt_2_PDU/Dane/",
                               "cancellationsStatsPerYear.csv"))

for(i in 2003:2008){
  df_name <- paste("df_", i, sep="")
  write.csv(get(df_name), file = file.path("~/laby_PDU/Projekt_2_outer/Projekt_2_PDU/Dane/",
                                 paste(df_name, ".csv", sep ="")))
}

?geom_text
paths[1996-1987+1]

year_1996 <- read.csv(paths[1996-1987+1])
year_1996 <- as.data.table(year_1996) 

check_1996 <- read.csv(paths[1996-1987+1])
check_1996 <- as.data.table(check_1996)
#View(head(check_2006,1000))

check_1996 <- check_1996[Cancelled != 0, .("FlightsCancelled" = .N, ""),keyby = .(Month, DayofMonth)]
check_1996 <- check_1996[order(FlightsCancelled, decreasing = T)]
colnames(year_1996)

year_1996_2 <- year_1996[Month == 1 & DayofMonth == 8 & Cancelled == 1,
                       .("Total" = .N), keyby=.(Dest)]
year_1996_2 <- year_1996_2[order(Total,decreasing = T)]

write.csv(year_1996_2, file.path("~/laby_PDU/Projekt_2_outer/Projekt_2_PDU/Dane/",
                                 paste("year_1996", ".csv", sep ="")))
#rm(check_2006)
#gc()


