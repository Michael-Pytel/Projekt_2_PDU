df_2007 <- read.csv("../Dane/2007.csv")

DepDelay <- df_2007 %>%
  filter(Cancelled == 0) %>%
  group_by(Month) %>%
  summarise(MeanDepDelay = mean(DepDelay))

ArrDelay <- df_2007 %>% 
  filter(c(Cancelled == 0)) %>%
  filter(!is.na(ArrDelay)) %>%
  group_by(Month) %>%
  summarise(MeanArrDelay = mean(ArrDelay))

CarrierDelay <- df_2007 %>% 
  filter(c(Cancelled == 0)) %>%
  group_by(Month) %>%
  summarise(MeanCarrierDelay = mean(CarrierDelay))

WeatherDelay <- df_2007 %>% 
  filter(c(Cancelled == 0)) %>%
  group_by(Month) %>%
  summarise(MeanWeatherDelay = mean(WeatherDelay))

NASDelay <- df_2007 %>% 
  filter(c(Cancelled == 0)) %>%
  group_by(Month) %>%
  summarise(MeanNASDelay = mean(NASDelay))

SecurityDelay <- df_2007 %>% 
  filter(c(Cancelled == 0)) %>%
  group_by(Month) %>%
  summarise(MeanSecurityDelay = mean(SecurityDelay))

LateAircraftDelay <- df_2007 %>% 
  filter(c(Cancelled == 0)) %>%
  group_by(Month) %>%
  summarise(MeanLateAircraftDelay = mean(LateAircraftDelay))


df_merged <- DepDelay %>%
  left_join(ArrDelay, by = "Month") %>%
  left_join(CarrierDelay, by = "Month") %>%
  left_join(WeatherDelay, by = "Month") %>%
  left_join(NASDelay, by = "Month") %>%
  left_join(SecurityDelay, by = "Month") %>%
  left_join(LateAircraftDelay, by = "Month")

df_summed <- df_merged %>%
  mutate(TotalDelay = MeanCarrierDelay + MeanWeatherDelay + MeanNASDelay + MeanSecurityDelay + MeanLateAircraftDelay)


