reprex_render_in_env <- function (input, std_out_err = NULL, env) {
  withr::with_options(list(keep.source = TRUE), {
    rmarkdown::render(input, quiet = TRUE, envir = env)
  })
}

reprex_in_env <- function (x = NULL, input = NULL, outfile = NULL, venue = c("gh", "so", "ds", "r", "rtf"), render = TRUE, advertise = NULL, 
          si = reprex:::opt(FALSE), style = reprex:::opt(FALSE), show = reprex:::opt(TRUE), comment = reprex:::opt("#>"), 
          tidyverse_quiet = reprex:::opt(TRUE), std_out_err = reprex:::opt(FALSE), env = globalenv()) {
  
  library(rlang)
  venue <- tolower(venue)
  venue <- match.arg(venue)
  venue <- reprex:::ds_is_gh(venue)
  venue <- reprex:::rtf_requires_highlight(venue)
  advertise <- advertise %||% getOption("reprex.advertise") %||% 
    (venue %in% c("gh", "so"))
  si <- reprex:::arg_option(si)
  style <- reprex:::arg_option(style)
  show <- reprex:::arg_option(show)
  comment <- reprex:::arg_option(comment)
  tidyverse_quiet <- reprex:::arg_option(tidyverse_quiet)
  std_out_err <- reprex:::arg_option(std_out_err)
  if (!is.null(input)) 
    stopifnot(is.character(input))
  if (!is.null(outfile)) 
    stopifnot(is.character(outfile) || is.na(outfile))
  stopifnot(reprex:::is_toggle(advertise), reprex:::is_toggle(si), reprex:::is_toggle(style))
  stopifnot(reprex:::is_toggle(show), reprex:::is_toggle(render))
  stopifnot(is.character(comment))
  stopifnot(reprex:::is_toggle(tidyverse_quiet), reprex:::is_toggle(std_out_err))
  x_expr <- rlang::enexpr(x)
  where <- if (is.null(x_expr)) 
    reprex:::locate_input(input)
  else "expr"
  src <- switch(where, expr = reprex:::stringify_expression(x_expr), 
                clipboard = reprex:::ingest_clipboard(), path = reprex:::read_lines(input), 
                input = reprex:::escape_newlines(sub("\n$", "", input)), NULL)
  src <- reprex:::ensure_not_empty(src)
  src <- reprex:::ensure_not_dogfood(src)
  src <- reprex:::ensure_no_prompts(src)
  if (style) {
    src <- reprex:::ensure_stylish(src)
  }
  outfile_given <- !is.null(outfile)
  infile <- if (where == "path") 
    input
  else NULL
  files <- reprex:::make_filenames(reprex:::make_filebase(outfile, infile))
  r_file <- files[["r_file"]]
  if (reprex:::would_clobber(r_file)) {
    return(invisible())
  }
  std_file <- if (std_out_err) 
    files[["std_file"]]
  else NULL
  data <- list(venue = venue, advertise = advertise, si = si, 
               comment = comment, tidyverse_quiet = tidyverse_quiet, 
               std_file = std_file)
  src <- reprex:::apply_template(src, data)
  writeLines(src, r_file)
  if (outfile_given) {
    message("Preparing reprex as .R file:\n  * ", r_file)
  }
  if (!render) {
    return(invisible(readLines(r_file, encoding = "UTF-8")))
  }
  message("Rendering reprex...")
  reprex_render_in_env(r_file, std_file, env)
  reprex_file <- md_file <- files[["md_file"]]
  if (std_out_err) {
    reprex:::inject_file(md_file, std_file, tag = "standard output and standard error")
  }
  if (outfile_given) {
    message("Writing reprex markdown:\n  * ", md_file)
  }
  if (venue %in% c("r", "rtf")) {
    rout_file <- files[["rout_file"]]
    output_lines <- readLines(md_file, encoding = "UTF-8")
    output_lines <- reprex:::convert_md_to_r(output_lines, comment = comment, 
                                    flavor = "fenced")
    writeLines(output_lines, rout_file)
    if (outfile_given) {
      message("Writing reprex as commented R script:\n  * ", 
              rout_file)
    }
    reprex_file <- rout_file
  }
  if (venue == "rtf") {
    rtf_file <- files[["rtf_file"]]
    reprex:::reprex_highlight(reprex_file, rtf_file)
    if (outfile_given) {
      message("Writing reprex as highlighted RTF:\n  * ", 
              reprex_file)
    }
    reprex_file <- rtf_file
  }
  if (show) {
    html_file <- files[["html_file"]]
    rmarkdown::render(md_file, output_file = html_file, clean = FALSE, 
                      quiet = TRUE, encoding = "UTF-8", output_options = if (reprex:::pandoc2.0()) 
                        list(pandoc_args = "--quiet"))
    html_file <- reprex:::force_tempdir(html_file)
    viewer <- getOption("viewer") %||% utils::browseURL
    viewer(html_file)
  }
  out_lines <- readLines(reprex_file, encoding = "UTF-8")
  if (reprex:::clipboard_available()) {
    clipr::write_clip(out_lines)
    message("Rendered reprex is on the clipboard.")
  }
  else if (interactive()) {
    clipr::dr_clipr()
    message("Unable to put result on the clipboard. How to get it:\n", 
            "  * Capture what `reprex()` returns.\n", "  * Consult the output file. Control via `outfile` argument.\n", 
            "Path to `outfile`:\n", "  * ", reprex_file)
    if (reprex:::yep("Open the output file for manual copy?")) {
      withr::defer(utils::file.edit(reprex_file))
    }
  }
  invisible(out_lines)
}

