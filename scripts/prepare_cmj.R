# Builds data/cmj.csv from three countermovement-jump (CMJ) recordings on a dual force platform (500 Hz).
# ForceA = left plate, ForceB = right plate (N). The athlete is anonymised as "Athlete K".
# Usage (from project root): Rscript scripts/prepare_cmj.R "<folder with the three *_cmj1/2/3_*.txt files>"
args <- commandArgs(trailingOnly = TRUE)
src  <- args[1]
files <- sort(list.files(src, pattern = "_cmj[123]_.*\\.txt$", full.names = TRUE))
stopifnot(length(files) == 3)
cmj <- do.call(rbind, lapply(seq_along(files), function(i) {
  d <- read.delim(files[i], skip = 1)[, c("Time", "ForceA", "ForceB")]
  data.frame(trial = paste0("CMJ ", i),
             time_s = d$Time / 1000,
             force_left = d$ForceA,
             force_right = d$ForceB,
             force_total = round(d$ForceA + d$ForceB, 1))
}))
write.csv(cmj, "data/cmj.csv", row.names = FALSE)
cat("Wrote", nrow(cmj), "rows\n")
