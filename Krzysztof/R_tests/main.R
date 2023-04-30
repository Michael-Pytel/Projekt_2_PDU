library('data.table')
library('Dict')


df_project <- read.csv("~/laby_PDU/Projekt_2_outer/Projekt_2_PDU/Dane/2007.csv")
View(head(df_project,10))

df_project <- as.data.table(df_project)
paste(colnames(df_project), collapse = ', ')

#rm(result)

num_of_flights_daily <- function(dataFrame){
  #Uses data.table package
  #returns a data.table with grouped rows by month and day values
  
  result <- as.data.table(dataFrame)[,.("Count" = .N), 
                                     keyby = .(Month, DayofMonth)]
}

cancellations_stats <- function(dataFrame){
  #Uses data.table package
  #returns a data.table
  
  #Useful columns: Cancelled, CancellationCode
  
  result <- as.data.table(dataFrame)[(Cancelled != 0), 
                                     .("Count" = .N),
                                     keyby = CancellationCode]
  result <- result[order(Count, decreasing = T),]
  
}

tmp <- num_of_flights_daily(df_project)
class(tmp)
tmp[(Month == 9 & DayofMonth == 11),]
mean(tmp$Count)

cancelled <- cancellations_stats(df_project)
View(cancelled)


#changing CancellationCode values
n_codes <- Dict$new(
  "A" = "przewoźnik", 
  "B" = "pogoda", 
  "C" = "NAS", 
  "D" = "bezpieczeństwo")

for(row in 1:length(cancelled$Count)){
  value <- cancelled$CancellationCode[row]
  cancelled$CancellationCode[row] <- n_codes$get(value)
}

#cleaning
rm(row,value,xlim)
#class(cancelled)

#drawing a histogram
tab <- as.table(matrix(cancelled$Count, nrow = 1))
colnames(tab) <- cancelled$CancellationCode
row.names(tab) <- c("Count")
tab

barplot(tab,
        beside = T, 
        col = c("green", "blue", "yellow", "red"))

     