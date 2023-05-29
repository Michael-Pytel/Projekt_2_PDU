setwd("C:\\Users\\admin\\Documents\\Github\\Projekt_2_PDU")
Df <- read.csv("Dane/1995.csv")
Aircrafts <- read.csv("Dane/plane-data.csv")

diff <- Df %>%
  filter(DepDelay > 0) %>%
  mutate(DiffDelay = DepDelay - ArrDelay) %>%
  select(TailNum, DiffDelay, AirTime) 

diff_with_models <- merge(diff, Aircrafts, by.x = "TailNum", by.y = "tailnum")

result <- diff_with_models %>%
  filter(type == "Corporation") %>%
  filter(year != "None") %>%
  group_by(manufacturer,model) %>%
  summarize(AvgCatchUp = mean(DiffDelay, na.rm = TRUE), count = n(), MeanAirTime = mean(AirTime, na.rm = T)) %>%
  filter(count > 22000) %>% # dla 2007 i 2006 (50K) dla 2000 (30k), dla 1995 (22k)
  arrange(desc(AvgCatchUp))

result_manufacturer <- diff_with_models %>%
  filter(type == "Corporation") %>%
  # filter(model == "737-7H4") %>%
  group_by(manufacturer) %>%
  summarize(AvgCatchUp = mean(DiffDelay, na.rm = TRUE), count = n(), MeanAirTime = mean(AirTime, na.rm = T)) %>%
  filter(count > 30000) %>% #dla 2007 i 2006 (50k) dla 2000 (30k) 
  arrange(desc(AvgCatchUp))

ggplot(result, aes(x=reorder(model, AvgCatchUp), y=AvgCatchUp, fill=manufacturer)) +
  geom_bar(stat="identity", width = 0.5) +
  scale_fill_brewer(palette = "Set1") +
  coord_flip() +
  theme_minimal() +
  labs(x="Model", y="Średni czas nadgonienia w minutach", title="Średni czas nadgonienia dla najczęstrzych modeli dla lotów z roku 1995", fill="Producent") +
  theme(axis.text.x = element_text(angle = 0, hjust = 1))


ggplot(result_manufacturer, aes(x=reorder(manufacturer, AvgCatchUp), y=AvgCatchUp)) +
  geom_bar(stat="identity", fill="steelblue", width = 0.5) +
  coord_flip() +
  theme_minimal() +
  labs(y="Średni czas nadgonienia w minutach", x="Producent", title="Średni czas nadgonienia opóżnienia największych producentów dla lotów z roku 1995")
