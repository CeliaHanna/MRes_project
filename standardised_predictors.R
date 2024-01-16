library(lme4)
library(MASS)
library(ggplot2)


model_baseline <- glmer.nb(Richness ~ 1 + (1 | Seamount), data = all_transects)
# Standardize variables
even_rows$StandardizedTemp <- scale(even_rows$AverageTemperature)
even_rows$StandardizedDepth <- scale(even_rows$AverageDepth)
even_rows$StandardizedSalinity <- scale(even_rows$AverageSalinity)
even_rows$StandardizedGradient <- scale(even_rows$AverageGradient)
even_rows$StandardizedProductivity <- scale(even_rows$AverageProductivity)

all_transects$StandardizedTemp <- scale(all_transects$AverageTemperature)
all_transects$StandardizedDepth <- scale(all_transects$AverageDepth)
all_transects$StandardizedSalinity <- scale(all_transects$AverageSalinity)
all_transects$StandardizedGradient <- scale(all_transects$AverageGradient)
all_transects$StandardizedProductivity <- scale(all_transects$AverageProductivity)

ggplot(all_transects, aes(x = Seamount, y = AverageTemperature)) +
  geom_violin() +
  labs(title = "Productivity vs Seamount", x = "Seamount", y = "Temperature")


hist(even_rows$Richness)

# Rerun the model with standardized predictors
model_temp <- glmer.nb(Richness ~ StandardizedTemp + (1 | Seamount), data = even_rows, 
                       control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

model_depth <- glmer.nb(Richness ~ StandardizedDepth + (1 | Seamount), data = even_rows, 
                        control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))


model_salinity <- glmer.nb(Richness ~ StandardizedSalinity + (1 | Seamount), data = even_rows, 
                        control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))


model_gradient <- glmer.nb(Richness ~ StandardizedGradient + (1 | Seamount), data = even_rows, 
                           control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))


model_productivity<- glmer.nb(Richness ~ StandardizedProductivity + (1 | Seamount), data = even_rows, 
                           control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

summary(model_productivity)
# Create the combined model with all standardized predictors

model_combined_no_random <- glm.nb(Richness ~ AverageProductivity + AverageTemperature + AverageDepth + AverageSalinity + AverageGradient, 
                                   data = even_rows, 
                                   control = glm.control(maxit = 100000))

summary(model_combined)

# Fit a negative binomial GLM with a specified dispersion parameter
model_glm <- glm.nb(Richness ~ StandardizedTemp + StandardizedDepth + StandardizedSalinity + StandardizedGradient, 
                    data = even_rows)

# Summarize the model
summary(model_glm)


lm <- lm(StandardizedProductivity~Richness, even_rows)
lm_model <- lm(Richness ~StandardizedProductivity + StandardizedTemp + StandardizedDepth + StandardizedSalinity, data = even_rows)
summary(lm_model)


write.csv(all_transects, "/Users/user/Desktop/all_transects.csv")

# chat gpt model idea

all_transects <- read.csv("/Users/user/Desktop/all_transects.csv")

# Assuming your data frame is named all_transects

# Standardizing the environmental variables
all_transects$AverageTemperature <- scale(all_transects$AverageTemperature)
all_transects$AveragePressure <- scale(all_transects$AveragePressure)
all_transects$AverageSalinity <- scale(all_transects$AverageSalinity)
all_transects$AverageDepth <- scale(all_transects$AverageDepth)
all_transects$AverageGradient <- scale(all_transects$AverageGradient)
all_transects$AverageProductivity <- scale(all_transects$AverageProductivity)

# Fit the GLMM model
library(lme4)
glmm_model_nb <- glmer.nb(Richness ~ AverageTemperature + AverageSalinity + AverageGradient +
                            (1 | Seamount), data = all_transects)


# View the summary of the model
summary(glmm_model_nb)

hist(all_transects$Richness)
