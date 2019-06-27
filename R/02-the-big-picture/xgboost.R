source("reprex/reprex-in-env.R")

library(xgboost)
library(dplyr)

outcome <- pull(iris, Species)
predictors <- select(iris, -Species)

head(outcome)

head(predictors)

model <- xgboost(
  data      = predictors, 
  label     = outcome,
  objective = "multi:softprob"
)

model <- xgboost(
  data      = as.matrix(predictors), 
  label     = outcome,
  objective = "multi:softprob"
)

model <- xgboost(
  data      = as.matrix(predictors), 
  label     = outcome,
  objective = "multi:softprob",
  num_class = 3
)

model <- xgboost(
  data      = as.matrix(predictors), 
  label     = outcome,
  objective = "multi:softprob",
  num_class = 3,
  nrounds   = 10
)

model <- xgboost(
  data      = as.matrix(predictors), 
  label     = as.numeric(outcome) - 1L,
  objective = "multi:softprob",
  num_class = 3,
  nrounds   = 10
)

# Questions:
# why can't it be a data frame?
# why do I have to specify the number of classes?
# why can't outcome be a factor?
# why does it have to be 0 based?

predict(model, as.matrix(predictors))

pred <- predict(model, as.matrix(predictors))
matrix(pred, ncol = 3)

predict(model, as.matrix(predictors), reshape = TRUE)

# interesting behavior in that it can predict NA rows
predictors2 <- predictors
predictors2$Petal.Width[1] <- NA
predict(model, as.matrix(predictors2), reshape = TRUE)
