# Builds the course datasets from the original BDSinfo.xlsx
# (Santos & Duarte, 2016, "A public data set of human balance evaluations", PeerJ 4:e2648)
# Run from the project root:  Rscript scripts/prepare_data.R path/to/BDSinfo.xlsx
library(readxl)
args <- commandArgs(trailingOnly = TRUE)
src  <- if (length(args)) args[1] else "~/Downloads/BDSinfo.xlsx"
raw  <- as.data.frame(suppressWarnings(read_excel(src)))

# ---- Trial-level file (one row per balance trial) ----
trials <- raw[, c("Trial", "Subject", "Vision", "Surface", "AgeGroup", "Gender")]
write.csv(trials, "data/bds_trials.csv", row.names = FALSE)

# ---- Participant-level file (one row per participant) ----
p <- raw[!duplicated(raw$Subject), ]
fes <- sub(" Concern", "", p$FES_S)           # "Low" / "Moderate" / "High"
balance <- data.frame(
  subject     = p$Subject,
  age         = round(p$Age, 1),
  age_group   = p$AgeGroup,
  sex         = p$Gender,
  height_cm   = p$Height,
  mass_kg     = p$Weight,
  bmi         = round(p$BMI, 1),
  foot_cm     = p$FootLen,
  nationality = p$Nationality,
  illness     = p$Illness,
  disability  = p$Disability,
  falls_12m   = p$Falls12m,
  fes_total   = p$FES_T,                     # Short FES-I, 7 (no concern) - 28 (high concern)
  fear_falling= fes,
  activity    = p$IPAQ_S,                    # IPAQ category: Low / Moderate / High
  tmt_a_s     = p$TMT_timeA,                 # Trail Making Test part A (s)
  tmt_b_s     = p$TMT_timeB,                 # Trail Making Test part B (s)
  minibest    = p$Best_T                     # Mini-BESTest total, 0 - 28 (higher = better balance)
)
write.csv(balance, "data/balance.csv", row.names = FALSE)
cat("Wrote", nrow(balance), "participants and", nrow(trials), "trials\n")
