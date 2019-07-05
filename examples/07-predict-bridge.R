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

# ------------------------------------------------------------------------------
# Sensitivity / Specificity

# out of all of the true rejections, how many did i get right?
test_with_hard_predictions %>%
  sens(admit, .pred_class)

# confirm
test_with_hard_predictions %>% 
  summarise(
    n_true_rejects = sum(admit == 0),
    n_correctly_pred_reject = sum(admit == 0 & .pred_class == 0),
    n_correctly_pred_reject / n_true_rejects
  )

# out of all of the true admittances, how many did i get right?
test_with_hard_predictions %>%
  spec(admit, .pred_class)

# confirm
test_with_hard_predictions %>% 
  summarise(
    n_true_admit = sum(admit == 1),
    n_correctly_pred_admit = sum(admit == 1 & .pred_class == 1),
    n_correctly_pred_admit / n_true_admit
  )
