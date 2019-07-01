library(rsample)
library(tibble)
library(dplyr)
library(hardhat)

set.seed(123)

split <- initial_split(admittance)
train <- training(split)
test <- testing(split)

model <- logistic_regression(admit ~ gre + gpa, train)

model

# outcome levels info
model$blueprint$ptypes$predictors
model$blueprint$ptypes$outcomes

levels(model$blueprint$ptypes$outcomes[[1]])

# convert to low level matrix
test_matrix <- test %>%
  select(gre, gpa) %>%
  # hardhat::add_intercept_column()
  add_intercept_column() %>%
  as.matrix()

head(test_matrix)

# class prob
predict_logistic_regression_prob(model, test_matrix)

# hard class prediction
predict_logistic_regression_class(model, test_matrix)
