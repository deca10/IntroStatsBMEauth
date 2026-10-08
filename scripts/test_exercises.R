# Runs every webR code block, every exercise solution and its grader in local R.
# Usage (from project root): Rscript scripts/test_exercises.R
suppressPackageStartupMessages({ library(ggplot2); library(ggdist); library(ggrepel); library(patchwork) })

parse_blocks <- function(file) {
  lines <- readLines(file, warn = FALSE)
  blocks <- list(); i <- 1
  while (i <= length(lines)) {
    if (grepl("^```\\{webr\\}", lines[i])) {
      j <- i + 1
      while (!grepl("^```\\s*$", lines[j])) j <- j + 1
      body <- lines[(i + 1):(j - 1)]
      opt_lines <- grep("^#\\|", body, value = TRUE)
      opts <- list()
      for (o in opt_lines) {
        kv <- sub("^#\\|\\s*", "", o); k <- sub(":.*", "", kv); v <- trimws(sub("^[^:]*:", "", kv))
        opts[[k]] <- v
      }
      blocks[[length(blocks) + 1]] <- list(opts = opts, code = paste(body[!grepl("^#\\|", body)], collapse = "\n"))
      i <- j
    }
    i <- i + 1
  }
  blocks
}

helpers <- parse_blocks("_common.qmd")[[1]]$code
pages <- c("how-to-use.qmd", sort(Sys.glob("m[0-9]-[0-9]*.qmd")))
fails <- 0
for (pg in pages) {
  cat("\n=====", pg, "=====\n")
  rm(list = setdiff(ls(globalenv(), all.names = TRUE), c("helpers","pages","fails","pg","parse_blocks")), envir = globalenv())
  eval(parse(text = helpers), envir = globalenv())
  blocks <- parse_blocks(pg)
  # global hidden setup
  for (b in blocks) if (identical(b$opts$include, "false")) eval(parse(text = b$code), envir = globalenv())
  # free-standing demo blocks (shared global env, like the browser)
  for (b in blocks) {
    if (is.null(b$opts$exercise) && !identical(b$opts$include, "false")) {
      r <- tryCatch({ v <- withVisible(eval(parse(text = b$code), envir = globalenv())); if (inherits(v$value, "ggplot")) ggplot_build(v$value); "ok" },
                    error = function(e) conditionMessage(e))
      if (r != "ok") cat("  [demo error]", substr(b$code, 1, 50), "->", r, "\n")
    }
  }
  ex <- unique(unlist(lapply(blocks, function(b) b$opts$exercise)))
  for (e in ex) {
    sol <- Filter(function(b) identical(b$opts$exercise, e) && identical(b$opts$solution, "true"), blocks)[[1]]$code
    chk <- Filter(function(b) identical(b$opts$exercise, e) && identical(b$opts$check, "true"), blocks)[[1]]$code
    sol_env <- new.env(parent = globalenv()); res_env <- new.env(parent = globalenv())
    sol_val <- suppressMessages(withVisible(eval(parse(text = sol), envir = sol_env)))$value
    res_val <- suppressMessages(withVisible(eval(parse(text = sol), envir = res_env)))$value
    if (inherits(res_val, "ggplot")) suppressMessages(ggplot_build(res_val))
    chk_env <- new.env(parent = globalenv())
    assign(".result", res_val, chk_env); assign(".envir_result", res_env, chk_env)
    assign(".user_code", sol, chk_env)
    assign(".checker_args", list(envir_solution = sol_env, solution = sol_val), chk_env)
    out <- tryCatch(eval(parse(text = chk), envir = chk_env), error = function(err) list(correct = FALSE, message = paste("CHECK ERROR:", conditionMessage(err))))
    status <- if (isTRUE(out$correct)) "PASS" else { fails <- fails + 1; "FAIL" }
    cat(sprintf("  %-4s %-10s %s\n", status, e, substr(as.character(out$message), 1, 110)))
  }
}
cat("\nTotal failures:", fails, "\n")
