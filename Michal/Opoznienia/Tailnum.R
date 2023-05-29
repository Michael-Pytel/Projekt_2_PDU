setwd("C:\\Users\\admin\\Documents\\Github\\Projekt_2_PDU")
Df <- read.csv("Dane/2004.csv")
Aircrafts <- read.csv("Dane/plane-data.csv")
library(dplyr)
library(ggplot2)



diff <- Df %>%
  filter(DepDelay > 0) %>%
  mutate(DiffDelay = DepDelay - ArrDelay) %>%
  select(TailNum, DiffDelay) 

diff_with_models <- merge(diff, Aircrafts, by.x = "TailNum", by.y = "tailnum")

overall_delays <- merge(Df, Aircrafts, by.x = "TailNum", by.y = "tailnum")

overall_delays_final <- overall_delays %>%
  filter(type == "Corporation") %>%
  group_by(year) %>%
  summarize(MeanArrDelay = mean(ArrDelay, na.rm = T), MeanDepDelay = mean(DepDelay, na.rm = T), count = n())

# overall_delays_final <- overall_delays_final[3:43,]


result <- diff_with_models %>%
  filter(type == "Corporation") %>%
  group_by(year) %>%
  summarize(AvgCatchUp = mean(DiffDelay, na.rm = TRUE), count = n()) %>%
  arrange(desc(year))


result <- result[c(3:43),]


ggplot(result, aes(x=year, y=AvgCatchUp, size=count, color=count)) +
  geom_point(alpha = 0.6) +
  geom_hline(yintercept = 0, linetype="dashed", color = "red") +
  theme_minimal() +
  scale_size_continuous(range = c(1, 20), labels = scales::comma) +  
  scale_color_gradient(low="blue", high="red", labels = scales::comma) + # dodane labels dla 2004
  guides(color = guide_legend(), size = guide_legend()) +
  labs(title = "Średni czas nadgonienia opóźnienia w zależności od roku produkcji samolotu dla lotów w roku 2004",
       x = "Rok Produkcji",
       y = "Średni czas nadgonienia (w minutach)",
       color = "Ilość samolotów dla danego roku produkcji",
       size = "Ilość samolotów dla danego roku produkcji")




df_long <- tidyr::pivot_longer(overall_delays_final, cols = c(MeanArrDelay, MeanDepDelay), names_to = "variable", values_to = "value")


ggplot(df_long, aes(x = year, y = value, fill = variable)) +
  geom_col(position = "dodge") +
  theme_minimal() +
  labs(x = "Rok Produkcji",
       y = "Średnie opóźnienie dla danego typu i roku produkcji",
       fill = "Typ Opóźnienia",
       title = "Średnie opóźnienie w zależności od roku prodkukcji samolotu dla lotów z roku 2007")


