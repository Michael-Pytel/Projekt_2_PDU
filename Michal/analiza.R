Flights_2021 <- read.csv("./Dane/2001.csv")
library(dplyr)

dplyr <- function(Flights_2021){
  result <- Flights_2021 %>%
    mutate(One, 1) %>%
    group_by(Month) %>%
    summarize(Total = sum(One)) %>%
    arrange(desc(Total)) %>%
    slice_head(n=10)
  
  return(result)
}

dplyr(Flights_2021)
