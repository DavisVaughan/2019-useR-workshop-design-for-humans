source("reprex/reprex-in-env.R")

prex <- function() {
  withr::with_options(
    new = c(
      reprex.highlight.hl_style  = "edit-eclipse",
      reprex.highlight.font      = "Fira Code Regular",
      reprex.highlight.font_size = 20
    ),
    reprex_in_env(venue = "rtf")
  )
}

# --------------------

