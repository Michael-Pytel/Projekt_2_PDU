setwd("C:\\Users\\admin\\Documents\\Github\\Projekt_2_PDU")
Df <- read.csv("Dane/2007.csv")
Aircafts <- read.csv("Dane/plane-data.csv")

df_test <- Df %>%
  filter(Month == 1) %>%
  select(DepDelay, ArrDelay, CarrierDelay, WeatherDelay, NASDelay, SecurityDelay, LateAircraftDelay)

model_catching_up <- function(Df, Aircrafts){
  diff <- Df %>%
    filter(DepDelay > 0) %>%
    mutate(DiffDelay = DepDelay - ArrDelay) %>%
    select(TailNum, DiffDelay) 
  
  total_diff <- diff %>%
    
   
}

test <- model_catching_up(Df, Aircrafts)

year_of_issue_delay <- function(Df, Aircrafts){
  DepDelay <- Df %>%
    filter(Cancelled == 0) %>%
    group_by(TailNum) %>%
    summarise(MeanDepDelay = mean(DepDelay))
  
  ArrDelay <- Df %>% 
    filter(c(Cancelled == 0)) %>%
    filter(!is.na(ArrDelay)) %>%
    group_by(TailNum) %>%
    summarise(MeanArrDelay = mean(ArrDelay))
  
  CarrierDelay <- Df %>% 
    filter(c(Cancelled == 0)) %>%
    filter(!is.na(CarrierDelay)) %>%
    group_by(TailNum) %>%
    summarise(MeanCarrierDelay = mean(CarrierDelay))
  
  WeatherDelay <- Df %>% 
    filter(c(Cancelled == 0)) %>%
    filter(!is.na(WeatherDelay)) %>%
    group_by(TailNum) %>%
    summarise(MeanWeatherDelay = mean(WeatherDelay))
  
  NASDelay <- Df %>% 
    filter(c(Cancelled == 0)) %>%
    filter(!is.na(NASDelay)) %>%
    group_by(Month) %>%
    summarise(MeanNASDelay = mean(NASDelay))
  
  SecurityDelay <- Df %>% 
    filter(!is.na(SecurityDelay)) %>%
    filter(c(Cancelled == 0)) %>%
    group_by(TailNum) %>%
    summarise(MeanSecurityDelay = mean(SecurityDelay))
  
  LateAircraftDelay <- Df %>% 
    filter(c(Cancelled == 0)) %>%
    group_by(TailNum) %>%
    summarise(MeanLateAircraftDelay = mean(LateAircraftDelay))
  
  
  df_merged <- DepDelay %>%
    left_join(ArrDelay, by = "TailNum") %>%
    left_join(CarrierDelay, by = "TailNum") %>%
    left_join(WeatherDelay, by = "TailNum") %>%
    # left_join(NASDelay, by = "TailNum") %>%
    left_join(SecurityDelay, by = "TailNum") %>%
    left_join(LateAircraftDelay, by = "TailNum")
  
  df_summed <- df_merged %>%
    mutate(TotalMeanDelay = 
             MeanCarrierDelay + MeanWeatherDelay + MeanSecurityDelay + MeanLateAircraftDelay +
             MeanDepDelay + MeanArrDelay) %>%
    select(TailNum, TotalMeanDelay) %>%
    filter(TailNum != 0)
  
  result <- merge(df_summed, Aicrafts, by.x = "TailNum", by.y = "tailnum" )
  
  result <- result %>%
    filter(year != "") %>%
    group_by(year) %>%
    summarise(TotalMeanDelayModel = mean(TotalMeanDelay)) %>%
    arrange(desc(year))
}
year_of_issue_delay(Df, Aicrafts)
