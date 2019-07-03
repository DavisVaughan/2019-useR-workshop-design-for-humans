source("reprex/reprex-in-env.R")

library(parsnip)
train <- mtcars[1:20,]
test <- mtcars[21:32,]

linear_reg(penalty = .01) %>%
  set_engine("glmnet") %>%
  fit(mpg ~ cyl + disp, train) %>%
  predict(test)

rand_forest(mode = "regression") %>%
  set_engine("ranger") %>%
  fit(mpg ~ cyl + disp, train) %>%
  predict(test)
