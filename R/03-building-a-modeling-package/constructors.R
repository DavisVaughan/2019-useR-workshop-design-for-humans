source("reprex/reprex-in-env.R")

new_secret <- function(x = double()) {
  stopifnot(is.double(x))
  
  structure(
    x,
    class = c(class, "secret")
  )
}
