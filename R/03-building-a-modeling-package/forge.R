source("reprex/reprex-in-env.R")

library(hardhat)
library(dplyr)

iris <- as_tibble(iris)

train <- iris[1:100,]
test <- iris[101:150,]

processed <- mold(Sepal.Length ~ Species + log(Sepal.Width), train)

forged <- forge(test, processed$blueprint)
forged$predictors



test_lvls <- test
test_lvls <- mutate(test_lvls, Species = as.character(Species))
test_lvls$Species[1] <- "extra"
test_lvls <- mutate(test_lvls, Species = as.factor(Species))

levels(test_lvls$Species)

forged <- forge(test_lvls, processed$blueprint)

forged$predictors


# fitting
frame <- model.frame(Sepal.Length ~ Species + log(Sepal.Width), train)
terms <- delete.response(terms(frame))
orig_lvls <- .getXlevels(terms, frame)
model_obj <- list(stuff = 1, terms = terms, orig_lvls = orig_lvls)

# prediction
test_frame <- model.frame(model_obj$terms, test_lvls)
head(model.matrix(model_obj$terms, test_frame))

# using xlev
model.frame(model_obj$terms, test_lvls, xlev = model_obj$orig_lvls)

test_missing_lvl <- test
test_missing_lvl$Species <- as.factor(as.character(test_missing_lvl$Species))

test_frame <- model.frame(model_obj$terms, test_missing_lvl)
head(model.matrix(model_obj$terms, test_frame))

model.frame(model_obj$terms, test_missing_lvl, xlev = model_obj$orig_lvls)



# Entirely new types
train <- data.frame(date = Sys.Date() + 1:100, y = 1:100)
test <- data.frame(date = 1:5)

processed <- mold(y ~ date, train)
forge(test, processed$blueprint)

terms <- delete.response(terms(model.frame(y ~ date, train)))
model.matrix(terms, model.frame(terms, test))

attr(terms, "dataClasses")




