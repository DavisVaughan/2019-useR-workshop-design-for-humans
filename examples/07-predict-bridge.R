library(yardstick)
library(dplyr)
library(rsample)
library(tibble)
library(dplyr)
library(hardhat)

set.seed(123)

split <- initial_split(admittance)
train <- training(split)
test <- testing(split)

model <- logistic_regression(admit ~ gre + gpa, train)

predict(model, test)

predict(model, test, type = "class")

# rlang::arg_match()
predict(model, test, type = "cla")

# ------------------------------------------------------------------------------
# Why is the data frame form nice?

test_with_predictions <- model %>%
  predict(test, type = "prob") %>%
  bind_cols(test)

test_with_predictions

test_with_predictions %>%
  pr_auc(admit, .pred_0)

# ------------------------------------------------------------------------------
# Class predictions

# Class predictions
test_with_hard_predictions <- model %>%
  predict(test, type = "class") %>%
  bind_cols(test)

test_with_hard_predictions

test_with_hard_predictions %>%
  accuracy(admit, .pred_class)
