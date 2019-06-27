source("reprex/reprex-in-env.R")

library(hardhat)
library(dplyr)

processed <- mold(Sepal.Width ~ Sepal.Length, iris)

processed$predictors

bp <- default_formula_blueprint(intercept = TRUE)
processed <- mold(Sepal.Width ~ Sepal.Length, iris, blueprint = bp)

processed$predictors

bp <- default_formula_blueprint(intercept = TRUE)
processed <- mold(Sepal.Width ~ Species, iris, blueprint = bp)

processed$predictors

bp <- default_formula_blueprint(intercept = TRUE, indicators = FALSE)
processed <- mold(Sepal.Width ~ Species, iris, blueprint = bp)

processed$predictors
