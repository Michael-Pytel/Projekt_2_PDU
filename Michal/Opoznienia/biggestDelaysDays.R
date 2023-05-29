setwd("C:\\Users\\admin\\Documents\\Github\\Projekt_2_PDU")
df <- read.csv("Dane/2008.csv")

df_delays <- df %>%
  group_by(Month) %>%
  summarise(CarrierDelays = mean(CarrierDelay, na.rm = TRUE),
            WeatherDelays = mean(WeatherDelay, na.rm = TRUE),
            NASDelays = mean(NASDelay, na.rm = TRUE),
            SecurityDelays = mean(SecurityDelay, na.rm = T),
            LateAircraftDelays = mean(LateAircraftDelay, na.rm = TRUE),
            count = n()) 
  

# Convert data from wide to long format for the bar chart
df_delays_long <- df_delays %>%
  gather(key = "DelayType", value = "DelayMean", -Month, -count)

# Polish month names
polish_months <- c("Styczeń", "Luty", "Marzec", "Kwiecień", "Maj", "Czerwiec", "Lipiec", "Sierpień", "Wrzesień", "Październik", "Listopad", "Grudzień")

# Plot the data
ggplot(df_delays_long, aes(x = Month, y = DelayMean)) +
  geom_bar(aes(fill = DelayType), stat = "identity", position = "stack") +
  scale_x_continuous(breaks = 1:12, labels = polish_months) +
  labs(x = "Miesiąc", y = "Średnie opóźnienie", fill = "Typ opóźnienia") +
  ggtitle("Średnie opóźnienia lotów według miesiąca dla roku 2004") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Plot the data
ggplot(df_delays, aes(x = Month, y = count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  scale_x_continuous(breaks = 1:12, labels = polish_months) +
  labs(x = "Miesiąc", y = "Liczba lotów") +
  ggtitle("Liczba lotów według miesiąca dla roku 2007") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))



