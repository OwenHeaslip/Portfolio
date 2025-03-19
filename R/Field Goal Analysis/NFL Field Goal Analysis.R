# LOAD PACKAGES AND DATA #######################################################
library(nflfastR) 
library(dplyr)
library(tidyr)
library(ggplot2)
library(caret) 

# Import play-by-play NFL data for seasons of interest
pbp_data <- load_pbp(2020:2024)

#filter data, create fg made and distance bin variables, 
#and select variables to use
outdoor_fg_data <- pbp_data |>
  filter(field_goal_attempt == 1,
         roof == "outdoors",
         (!is.na(wind)),
         (!is.na(temp))) |>
  mutate(fg_made = ifelse(field_goal_result == "made", 1,0),
         distance_bin = cut(kick_distance, breaks = seq (15, 75, by = 5), 
                            right = FALSE)) |> 
  select(play_id, game_id, season, home_team, away_team, season_type, week, 
         half_seconds_remaining, game_half, down, ydstogo, desc, play_type, 
         fg_made, field_goal_result, kick_distance, field_goal_attempt, 
         distance_bin, ep, epa, roof, temp, wind
  )

# quick stats of outdoor kicks by season
outdoor_fg_season <- outdoor_fg_data |>
  group_by(season) |>
  summarize(fg_made = sum(fg_made),
            fg_attempt = sum(field_goal_attempt),
            fg_percent = sum(fg_made)/sum(fg_attempt),
            .groups = "drop"
  )

## Histogram of accuracy by distance
#set data
outdoor_fg_hist <- outdoor_fg_data |>
  group_by(distance_bin) |>
  summarize(fg_percent = sum(fg_made)/sum(field_goal_attempt),
            .groups = "drop"
  )

#plot
ggplot(outdoor_fg_hist, aes(x = distance_bin, y = fg_percent)) +
  geom_col(fill = "steelblue") +
  geom_text(aes(label = scales::percent(fg_percent, accuracy = 0.1)), 
            vjust = -0.5, size = 3) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(title = "Outdoor Field Goal Accuracy by Distance",
       x = "Field Goal Distance (5-yard bins)",
       y = "Accuracy") +
  theme_minimal()

#regression models

#fg_made ~ kick_distance
outdoor_fg_model <- glm(fg_made ~ kick_distance, data = outdoor_fg_data, family = binomial)
summary(outdoor_fg_model)
#AIC: 2290

#fg_made ~ kick_distance + wind
outdoor_fg_model <- glm(fg_made ~ kick_distance + wind, data = outdoor_fg_data, family = binomial)
summary(outdoor_fg_model)
        #AIC: 2289

#fg_made ~ kick_distance + temp
outdoor_fg_model <- glm(fg_made ~ kick_distance + temp, data = outdoor_fg_data, family = binomial)
summary(outdoor_fg_model)
#AIC: 2290

#fg_made ~ kick_distance + wind + temp
outdoor_fg_model <- glm(fg_made ~ kick_distance + temp + wind, data = outdoor_fg_data, family = binomial)
summary(outdoor_fg_model)
#AIC 2290

#using model to predict 
distance_seq <- data.frame(kick_distance = seq(19, 75, by = 1))

# Predict probabilities for each distance in distance_seq
distance_seq$prob_made <- predict(outdoor_fg_model, newdata = distance_seq, 
                                  type = "response")

# Predict historical FGs to assess accuracy of prediction
outdoor_fg_data <- outdoor_fg_data |>
  mutate(fg_pred = ifelse(predict(outdoor_fg_model, type = "response") > 0.5, 1,0),
         correct_pred = ifelse(fg_made == fg_pred, 1,0)
  )

#Confusion Matrix
confusionMatrix(as.factor(outdoor_fg_data$fg_pred), 
                as.factor(outdoor_fg_data$fg_made))
