
# Workshop outline

## Technical bits

  - Need 1 TA

  - 3 hours

  - Plus a 30 minute break

  - 26 people

  - Gitter live chat

  - RStudio Pro instances (30?)

  - Shortlink for materials

  - Slides made in keynote

## General structure

  - Introduction to modeling principles
  - Go over hardhat, with hands on sections
  - Build a modeling R package that implements these “best practices”
      - A mix of slides and hands on work to actually get a working R
        package
      - usethis will come in handy

## Outline

### Introduction deck

Needs RStudio logo

  - Title slide
  - Shortlink to materials
  - Introduce self + Kelly
  - Outline the 3 hours + break (just the time)
  - Outline what we hope to accomplish in the 3 hours
  - Shortlink again
  - Gitter
  - Explain that everything is available
  - 5 minutes to meet each other

### Deck 1 - The big picture

  - Title slide

  - The R modeling ecosystem
    
      - The wild west
      - Lack of standards
          - 2003 BDR -
            <https://developer.r-project.org/model-fitting-functions.html>

  - What makes the R modeling ecosystem painful?
    
      - Show the `predict()` table with all of the different packages /
        ways to get class probs
      - Predictions with a different number of rows as the input
      - “glmnet doesn’t work for me, I work for glmnet”
      - TODO more?

  - What makes a good modeling R package?
    
      - Familiar interfaces
      - Good defaults
      - TODO more?

  - Details laid out in modeling principles guide
    
      - Link to the guide

  - If these principles are good, why isn’t everyone doing it?
    
      - Consider the typical R modeling developer
          - Statistical researcher
          - Not a software engineer
          - Might have an A+ rock solid implementation
          - But UI is $hit
      - Key point: A lack of knowledge and tooling to make good UI
      - Can we:
          - Provide the tooling
          - Lower the amount of knowledge required

  - hardhat - A toolkit for the construction of modeling packages
    
      - Provide opionated rules around creating modeling packages
      - Do the “hard work” around preprocessing user input
          - This otherwise requires special knowledge on the developer’s
            part
              - `model.matrix()`? recipe? formula method? Just make it
                work…
      - Add structure and consistency around the `predict()` method
      - Provide additional tooling for input validation, with expressive
        error messages

  - Who wins? Everyone.
    
      - Developers can focus on their implementations
      - Users can reap the benefits of a good UI

### Deck 2 - hardhat

  - What are the steps in building a modeling package?
      - A low level model fitting function
      - A high level model fitting user interface
      - A model object that you return to the user
      - A `predict()` function
      - Various methods you might implement `coef()`, `summary()`…
      - hardhat has something to offer for all of these
  - Model constructors
      - What is a constructor?
          - Advanced R section on constructors
      - Why are they useful (aka why do I care)?
      - What does my model object need?
          - Consider the generics you want methods for
              - `coef()`?
              - `residuals()`?
              - Your own custom ones?
          - Retain the minimally sufficient set
      - Do *not* store the call.
          - Example with `x <- do.call(lm, list(formula = mpg ~ cyl,
            data = mtcars))`
          - This isn’t a new
                idea\!
              - <https://github.com/topepo/caret/issues/76#issuecomment-63856383>
          - `call-hell.R`
      - Try not to store the `terms` object or the model frame
          - `lm-hell.R`
  - Modeling interfaces and preprocessing
      - What do i mean by interfaces?
          - formula, data frame, matrix, recipes, …

### Deck 3 - Building a modeling package

  - Your new best friends
      - usethis
      - devtools
      - hardhat

## hardhat specific ideas

  - Discuss the issue of the package developer not wanting to understand
    all about how `model.matrix()` works

  - Preprocessing at prediction time on new test data
    
      - Storing the hardhat blueprint for prediction

  - Validation
    
      - New columns
      - Not enough columns
      - Novel factor levels
      - Not enough factor levels
      - Lossless conversion, nice automatic character -\> factor
        conversion

  - Standardizing prediction output

  - Various preprocessing tricks
    
      - Whether or not to automatically include an intercept
          - Case study of earth package
      - Whether or not to automatically expand dummy variables
          - Case study of the ranger package
      - Multivariate outcomes
          - `cbind()` in `lm()`

  - Preprocessing with recipes
    
      - Whether or not to use `skip = TRUE`

## Implementing a package that uses hardhat

  - Model constructors
      - Using `new_model()` to build our constructor
  - Bare bones of S3
      - Why is it useful?
      - How does it work `<generic>.<method>()`
      - A simple non-modeling example
  - User facing function with interfaces for:
      - data frame
      - matrix
      - formula
          - Historical fun fact - hardcoded allowance for `formula` to
            be the dispatch arg
      - recipe
  - Separation of the interface from the implementation
      - `linear_regression()` vs `linear_regression_impl()`
  - Modeling bridge function
      - Receives processed `mold()` data
      - Calls the implementation function
      - Returns a new instance of our model class
  - Prediction
      - Always returns the same class of output (tibble)
      - Standardize on `type`
      - Standardized column names
      - Always return the same number of rows as the input (NA value
        issues)
          - Case study of situations where this doesn’t happen
  - Prediction bridge function
      - Convert `forge()`d predictors to implementation ready type
        (matrix)
      - Switch on the `type` and dispatch to the prediction
        implementation function
          - Ensure the implementation function called `spruce_()`
      - Call `validate_prediction_size()` at some point
