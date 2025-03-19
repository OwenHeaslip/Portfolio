# LOAD PACKAGES AND DATA #######################################################
library(Lahman)
library(dplyr)
library(tidyr)
library(ggplot2)

#Creation of Dataset ###########################################################

#Import Lahman’s Teams data
data(Teams)
Teams <- Teams

#Filter the data to only include years 2018-2019 and 2021-2023 
#(excluding COVID 2020) AND Add a new variable (walks) which is BB + HBP
Teams <- Teams |>
  filter(yearID %in% c(2018,2019,2021,2022,2023)) |>
  mutate(Walks = BB + HBP
  )

#Analysis of Doubles, Triples, and Home Runs ###################################

#Summarize the average number of doubles, triples, and home runs per team in each year
DTHR <- Teams |>
  group_by(yearID, teamID) |>
  mutate(X2B = mean(X2B), 
         X3B = mean(X3B), 
         HR = mean(HR)) |>
  select(yearID, teamID, X2B, X3B, HR)

#Provide the five-number summary for doubles, triples, and home runs
summary(DTHR$X2B)
summary(DTHR$X3B)
summary(DTHR$HR)

#Regression Modeling############################################################

model <- lm(R ~ Walks + H + X2B + X3B + HR + SB + CS, data = Teams)

summary(model)

new_model <- lm(R ~ Walks + H + X2B + HR + SB + CS, data = Teams)

summary(new_model)

#I would move forward with the original model even though X3B has a usually unacceptable p-value
# because keeping it resulted in a lower standard error

#Assessing Accuracy or regression model########################################
MAD_prediction <- Teams |>
  mutate(Predicted_R = predict(new_model, type = "response"),
         PRED_AbsDev = abs(R - Predicted_R),
         Difference = R - Predicted_R)|>
  select(teamID, yearID, R, Predicted_R, Difference, PRED_AbsDev)
# this outputs a final overall MAD value (see top-right quadrant under Values)
model_MAD = mean(MAD_prediction$PRED_AbsDev)


