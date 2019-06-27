source("reprex/reprex-in-env.R")

library(hardhat)
library(dplyr)

predictors <- select(iris, -Species)
outcomes <- pull(iris, Species)

processed <- mold(predictors, outcomes)

processed$predictors

processed$outcomes

processed$blueprint

processed <- mold(Species ~ Sepal.Width, iris)

processed$predictors

processed$outcomes
