library(purrr)
library(lobstr)
library(glue)
library(rlang, warn.conflicts = FALSE)

make_an_lm <- function() {
  x <- rep(1L, times = 10000000)
  cat(glue("x is {object.size(x)}B"))
  lm(1 ~ 1)
}

lm_model <- make_an_lm()

# that's not so bad...
object.size(lm_model)

# wtf?
obj_size(lm_model)

# lm_model is a list...so
str(map(lm_model, obj_size), digits.d = 10)

# terms? model?
str(lm_model$terms)

# attributes?
str(map(attributes(lm_model$terms), obj_size), digits.d = 10)

# environment..........
lm_model_env <- attr(lm_model$terms, ".Environment")
env_names(lm_model_env)

# `x` was carried along!
obj_size(lm_model_env$x)

# saves to 40+Mb, or 20+Mb with compression when it "should" only be 0.01 Mb
# (would be 80Mb, but `x` is only saved once, I think)
# saveRDS(lm_model, "~/Desktop/lm.rds", compress = FALSE)
