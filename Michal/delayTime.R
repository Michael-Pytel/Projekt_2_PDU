setwd("C:\\Users\\admin\\Documents\\Github\\Projekt_2_PDU")
df_2007 <- read.csv("Dane/2006.csv")

library("dplyr")

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

df_merged

df_summed <- df_merged %>%
  mutate(TotalDelay = 
           MeanCarrierDelay + MeanWeatherDelay + MeanNASDelay + MeanSecurityDelay + MeanLateAircraftDelay +
           MeanDepDelay + MeanArrDelay)
df_summed

# install.packages("ggplot2")
# library("ggplot2")

barplot(height = df_summed$TotalDelay, names = df_summed$Month)

m <- mean(df_summed$TotalDelay)
df_summed["GreaterThanMean"] <- df_summed$TotalDelay > m
# df["CancelledPercentage"] <- df$CancelledFlights/df$AllFlights * 100
# mp <- mean(df$CancelledPercentage)
# df["GrThanCanPercMean"] <- df$CancelledPercentage > mp 





# ggplot(data = df_summed, aes(x = Month, 
#                       y = TotalDelay, 
#                       fill = GreaterThanMean))+ 
#   geom_col() + 
#   scale_fill_manual(values = c("blue", "lightblue"))+
#   geom_hline(yintercept = m, 
#              linetype = "dashed", 
#              colour = "red") +
#   scale_y_continuous(expand = c(0, 0), 
#                      limits = c(0, max(df_summed$TotalDelay)))+
#   geom_text(aes(label = TotalDelay),
#             angle = 90,
#             hjust = 1.1) +
#   theme_gray()+
#   theme(legend.position = "none")


ggplot(data = df_summed, aes(x = Month, y = TotalDelay, fill = GreaterThanMean)) + 
  geom_col() + 
  scale_fill_manual(values = c("yellow", "lightblue")) +
  geom_hline(yintercept = m, linetype = "dashed", colour = "red") +
  scale_y_continuous(expand = c(0, 0), limits = c(0, max(df_summed$TotalDelay)+5)) +
  scale_x_continuous(breaks = 1:12, labels = month.abb) +
  geom_text(aes(label = sprintf("%.2f", TotalDelay)), angle = 90, hjust = 1.1) +
  theme_gray() +
  theme(legend.position = "none") +
  labs(x = "Month", 
       y = "Total Delay", 
       title = "Total Delay by Month")


