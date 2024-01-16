melville_m
coral_m
sapmer_m
atlantis_m

View(combined_data)

# see how temperature varies across seamounts 

# calculate average temperature per seamount 

library(dplyr)

average_temp <- combined_data %>% 
  group_by(Seamount) %>%
  summarise(average_temperature = mean(CTD.Temperature, na.rm = TRUE), 
  n = n(),
   std_dev = sd(CTD.Temperature, na.rm = TRUE)
  ) %>%
  mutate(sem = std_dev / sqrt(n)) 


average_temp




ggplot(average_temp, aes(x = Seamount, y = average_temperature)) +
  geom_col() +
  geom_errorbar(aes(ymin = average_temperature - sem, ymax = average_temperature + sem), width = 0.3) +
  labs(title = "Average Temperature per Seamount with Standard Errors",
       x = "Seamount",
       y = "Average Temperature (°C)")


hist(average_temp$average_temperature)
hist(combined_data$sqrt_temp)

combined_data$sqrt_temp <- sqrt(combined_data$CTD.Temperature)
anova <- aov(CTD.Temperature ~Seamount, combined_data)
summary(anova)

TukeyHSD(anova)

# look at average salinity across seamounts

average_salinity <- combined_data %>% 
  group_by(Seamount) %>%
  summarise(average_salinity = mean(CTD.Salinity, na.rm = TRUE), 
            n = n(),
            std_dev = sd(CTD.Salinity, na.rm = TRUE)
  ) %>%
  mutate(sem = std_dev / sqrt(n)) 

average_salinity

ggplot(average_salinity, aes(x= Seamount, y = average_salinity)) + 
  geom_col() + 
  geom_errorbar(aes(ymin = average_salinity - sem, ymax = average_salinity + sem), width = 0.3) + 
  labs(title = "Average Salinity per Seamount with Standard Errors",
       x = "Seamount",
       y = "Average Salinity")

# no differences in salinity 


