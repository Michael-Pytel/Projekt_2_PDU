setwd("C:\\Users\\admin\\Documents\\Github\\Projekt_2_PDU")
Df <- read.csv("Dane/2006.csv")
Aircrafts <- read.csv("Dane/plane-data.csv")
library(dplyr)
library(ggplot2)
Df_selected <- Df %>%
  select(TailNum,ArrDelay)

Aircrafts_selected <- Aircrafts %>%
  select(tailnum, manufacturer, model)

result <- merge(Df_selected, Aircrafts_selected, by.x = "TailNum", by.y = "tailnum")


result_model <- result %>% 
  filter(model != "") %>%
  group_by(manufacturer, model) %>%
  summarize(MeanArrDelay = mean(ArrDelay, na.rm = T), count = n()) %>%
  filter(count > 150000) %>% # dla 2007 i 2006 (150k) dla 2000 (75k) i dla 1995 (60k)
  arrange(desc(MeanArrDelay))



ggplot(result_model, aes(x=reorder(model, -MeanArrDelay), y=MeanArrDelay, fill=manufacturer)) +
  geom_bar(stat="identity") +
  scale_fill_brewer(palette = "Set1") +
  coord_flip() +
  theme_minimal() +
  labs(x="Model", y="Średnie opóżnienie przylotu w minutach", title="Średnie opóźnienie przylotu dla najczęstszych modeli samolotów dla lotów z roku 2006 ", fill="Producent") +
  theme(axis.text.x = element_text(angle = 0, hjust = 1))


