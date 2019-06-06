
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
      - Discuss the issue of the package developer not wanting to
        understand all about how `model.matrix()` works
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
      - Good place for the pictures in the hardhat vignette\!
  - High level interfaces
      - What do I mean by interfaces?
          - Formula, data.frame, matrix, recipes
      - When would I use one over the other?
          - Formula VS XY? (Pull from rstudio conf workshop, drawbacks
            of each)
      - How do I implement one?
          - A crash course on S3
          - `<generic>.<method>()`
  - Low level implementation
      - Accepts only the required inputs, in their raw-est form
      - This is where you as the package developer shines
      - Returns a named list of the objects you want in your model
        object
  - Bridging the gap
      - The high level interface should be agnostic to the low level
        implementation
      - You need something that bridges the gap between them
      - This kind of function should accept the preprocessed data, and
        return a model object using a *constructor*.
      - Along the way it can convert your preprocessed data to a lower
        level format
      - And run the implementation function
  - Model constructors
      - What is a constructor?
          - Mention advanced R section on constructors
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
  - High level `predict()`ion
      - `predict()` generic
      - What should the `type` be?
      - `new_data`
      - Each `type` should have its own implementation
  - Low level predict implementations
      - Classification
          - Might have `"class"` or `"prob"` `type`
          - General advice - separation:
              - `predict_<model_fn>_class()`
              - `predict_<model_fn>_prob()`
  - Bridging the gap 2
      - Like with fitting, it makes sense to separate the high level
        predict interface from the low level implementation functions
      - The bridge function takes the processed `new_data` predictors
        and passes them along to the correct implementation method
      - It also has the *very* important job of enforcing size stability
          - Number of rows in the output should be the same as the input
  - So how does hardhat help?
      - It can set all of this up for you with a call to
        `create_modeling_package()`
  - What else can hardhat help with? (the following sections explain)
      - “A tour of hardhat”
  - Consider: Standardization
      - Different interfaces take data in different ways
      - Your implementation function only cares about the raw predictors
        / outcomes
      - Introducing `mold()`
      - Mold takes data in all of the common interface formats and
        standardizes it
      - As you will also see, it does much more with regards to
        preprocessing
  - Consider: Preprocessing
      - Preprocessing at prediction time on new test data
          - Needs to use the same preprocessing as training data
          - Storing the hardhat blueprint for prediction
      - Introducing `forge()`
          - Using the blueprint that `mold()` returns
          - Handles the standardization of new data to a common format
          - And preprocesses the new data using the same processing done
            on the original data
      - Various preprocessing variations
          - The hardhat `blueprint` object
              - Can tweak defaults
          - Whether or not to automatically include an intercept
              - Case study of earth package
          - Whether or not to automatically expand dummy variables
              - Case study of the ranger package
          - Multivariate outcomes
              - `cbind()` in `lm()`
  - Consider: Validation
      - `forge()` uses the blueprint to do more than just preprocess the
        new data
      - `shrink()`
          - Not enough columns
      - `scream()`
          - Handles all other validation
          - Novel factor levels
          - `vec_cast()` magic
              - New columns
              - Not enough factor levels
              - Lossless conversion, nice automatic character -\> factor
                conversion
  - Consider: Prediction
      - Want to return consistent output
          - A `tibble()` with properly named columns
          - `spruce_*()` functions
      - Want to ensure number of rows of output are the same as input
          - `validate_prediction_size()`

### Deck 3 - Building a modeling package

  - Your new best friends
      - usethis
      - devtools
      - hardhat
  - What are we creating?
      - A logistic regression package
      - Under the hood, we will use `glm()` for the implementation
      - and `predict.glm()` for prediction implementation
  - Getting started
      - Creating a new modeling package requires some boilerplate
      - `hardhat::create_modeling_package()`
      - `devtools::document()`
      - `devtools::load_all()`
  - What did this do?
      - See `?logistic_regression`
      - See the files in `R/`
  - They should “just work” immediately
      - Run the examples in `?logistic_regression`
      - And `?predict.logistic_regression`
  - What now?
      - We are going to fill in each of the sections of the skeleton,
        utilizing these best practices that we have learned.
  - Start with the fit implementation
      - This is where you figure out what your model requires, which
        feeds into the other functions
      - This is where you do the “hard work”
      - Starting here allows you to prototype quickly since you can
        supply the raw inputs and make the function run.
      - Our engine is `glm.fit`
      - What are our inputs

## hardhat specific ideas

  - Preprocessing with recipes
      - Whether or not to use `skip = TRUE`

## Implementing a package that uses hardhat

  - Model constructors
      - Using `new_model()` to build our constructor
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
