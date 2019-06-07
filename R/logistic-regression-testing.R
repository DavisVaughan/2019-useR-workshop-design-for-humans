library(readr)
library(rsample)
library(dplyr)
library(hardhat)
library(recipes)

library(yardstick)
options(yardstick.event_first = FALSE)

set.seed(1234)

admittance_raw <- read_csv("https://stats.idre.ucla.edu/stat/data/binary.csv")

# ------------------------------------------------------------------------------

# Admittance into graduate school:
# - admit - Binary 0 = no, 1 = yes
# - gre - Graduate Record Exam score (max of 800)
# - gpa - Grade point averate (max of 4.00)
# - rank - Prestige of undergrad university (1 is highest prestige)

admittance <- admittance_raw

# A few changes:
# - `rank` is really a factor
# - 0 = "no", 1 - "yes"
# - first level is "failure" for glm (and logistic_regression)
admittance <- admittance %>%
  mutate(
    rank = factor(rank, levels = c("1", "2", "3", "4")),
    admit = factor(if_else(admit == 1L, "yes", "no"), levels = c("no", "yes"))
  )

# ------------------------------------------------------------------------------

# Split into train/test
split <- initial_split(admittance)
train <- training(split)
test <- testing(split)

# ------------------------------------------------------------------------------

mod_glm <- glm(admit ~ ., train, family = binomial())
mod_logreg <- logistic_regression(admit ~ ., train)

# ------------------------------------------------------------------------------

# looking good!
predict(mod_glm, test, type = "response")
predict(mod_logreg, test, type = "prob")

# ------------------------------------------------------------------------------
# Why is the data frame form nice?
test_with_predictions <- mod_logreg %>%
  predict(test, type = "prob") %>%
  bind_cols(test)

test_with_predictions %>%
  roc_auc(admit, .pred_no)

# ------------------------------------------------------------------------------
# What else?

# Class predictions
test_with_hard_predictions <- mod_logreg %>%
  predict(test, type = "class") %>%
  bind_cols(test)

test_with_hard_predictions %>%
  accuracy(admit, .pred_class)

# ------------------------------------------------------------------------------
# XY Interface
outcome <- select(train, admit)

train_no_outcome <- select(train, -admit)

frame_lst <- model_frame(~ ., train_no_outcome)
frame_lst$data
frame_lst$terms

predictors <- model_matrix(frame_lst$terms, frame_lst$data)

mod_xy <- logistic_regression(predictors, outcome, intercept = FALSE)

# ------------------------------------------------------------------------------
# Recipes interface

train_rec <- recipe(admit ~ ., train) %>%
  step_log(gre) %>%
  step_dummy(rank)

mod_recipe <- logistic_regression(train_rec, train)
mod_recipe

mod_recipe$blueprint$recipe

# All of the recipe steps are performed on `test` automatically
predict(mod_recipe, test)

# Proof? Use forge()
forge(test, mod_recipe$blueprint)

# ------------------------------------------------------------------------------
# NA values

test_with_na <- test
test_with_na$gre[c(1, 3, 5)] <- NA

predict(mod_recipe, test_with_na)

predict(mod_recipe, test_with_na, type = "class")

# ------------------------------------------------------------------------------
# Validation

# What if `rank` was a character vector?
# Result: Silently restores levels!
test_with_chr_rank <- mutate(test, rank = as.character(rank))
forge(test_with_chr_rank, mod_logreg$blueprint)
predict(mod_logreg, test_with_chr_rank)

predict(mod_glm, test_with_chr_rank, type = "response")

# What if `rank` was missing a level?
# Result: Silently restores it
test_with_missing_lvl <- mutate(test, rank = factor(ifelse(rank == 4, 3, rank), levels = c("1", "2", "3")))
forge(test_with_missing_lvl, mod_logreg$blueprint)
predict(mod_logreg, test_with_missing_lvl)

predict(mod_glm, test_with_missing_lvl, type = "response")

# What if `rank` has too many levels?
# Result: Warning about extra level being dropped
test_with_too_many_lvls <- mutate(test, rank = factor(rank, levels = c(levels(rank), "5")))
test_with_too_many_lvls$rank[1] <- 5
forge(test_with_too_many_lvls, mod_logreg$blueprint)
predict(mod_logreg, test_with_too_many_lvls)

# Often requested that this is a warning
# https://stackoverflow.com/questions/4285214/predict-lm-with-an-unknown-factor-level-in-test-data/44316204
# - lme4:::predict.merMod(allow.new.levels = TRUE)
# - mlr::makeLearner(fix.factors.prediction = TRUE)
predict(mod_glm, test_with_too_many_lvls, type = "response")

# What if `gre` is a character?
# Result: Silently converted to dbl
# How? _Lossless_ conversion is possible
test_with_chr_gre <- mutate(test, gre = as.character(gre))
forge(test_with_chr_gre, mod_logreg$blueprint)
predict(mod_logreg, test_with_chr_gre)

predict(mod_glm, test_with_chr_gre, type = "response")

# What if `gre` is a factor?
# Result: Error! can't meaningfully convert to a double from factor
test_with_fct_gre <- mutate(test, gre = as.factor(gre))
forge(test_with_fct_gre, mod_logreg$blueprint)

predict(mod_glm, test_with_fct_gre, type = "response")

# What if we are missing columns?
# Result: Error!
test_with_missing_columns <- select(test, -gre, -gpa)
forge(test_with_missing_columns, mod_logreg$blueprint)

predict(mod_glm, test_with_missing_columns, type = "response")
