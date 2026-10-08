# Builds the Module 3/4 datasets from the GRF classification project (athlete names removed).
# Usage (from project root):
#   Rscript scripts/prepare_squad.R <grf_classification_data1.csv> <perlimb_trials.csv>
args <- commandArgs(trailingOnly = TRUE)

# ---- 1. One row per athlete: CMJ force-plate variables (jump_squad.csv) ----
d <- read.csv(args[1], check.names = FALSE)
d$id <- ave(d$Sport, d$Sport, FUN = function(s) sprintf("%s%02d", substr(s[1], 1, 1), seq_along(s)))
squad <- data.frame(
  id                  = d$id,
  sport               = d$Sport,
  body_mass_kg        = round(d$Bodymass, 1),
  height_m            = d$Height,
  jump_height_m       = round(d$Jheight, 3),
  con_time_s          = d$ConcentricT,             # propulsion (concentric) phase duration
  ecc_time_s          = d$EccentricT,              # unweighting + braking phase duration
  contraction_time_s  = d[["ContractionT(Ecc+Con)"]],
  time_to_peak_s      = d$Tfmax,                   # time from movement onset to peak force
  con_force_rel       = round(d$rel_meanConForce, 2), # mean propulsive force (N/kg)
  peak_force_rel      = round(d$rel_Fmax, 2),      # peak force (N/kg)
  con_impulse_rel     = round(d$rel_ConImp, 3),    # propulsive impulse incl. body weight (N·s/kg)
  ecc_impulse_rel     = round(d$rel_EccImp, 3),    # eccentric impulse (N·s/kg)
  peak_power_rel      = round(d$rel_PPower, 1),    # peak power (W/kg)
  mean_power_rel      = round(d$rel_avgPower, 1),  # mean propulsive power (W/kg)
  peak_velocity       = round(d$Peak_vel, 3),      # peak centre-of-mass velocity (m/s)
  cmj_depth_m         = round(d$min_Disp, 3),      # lowest centre-of-mass position (negative, m)
  ecc_rfd_max         = round(d$maxEccRFD),        # peak eccentric rate of force development (N/s)
  ecc_rfd_mean        = round(d$meanEccRFD),       # mean eccentric RFD (N/s)
  rsi_mod             = round(d$RSImod, 3),        # jump height / contraction time (m/s)
  k_vert              = round(d$Kvert, 2)          # vertical stiffness (N/kg/m)
)
write.csv(squad, "data/jump_squad.csv", row.names = FALSE)
cat("jump_squad.csv:", nrow(squad), "athletes\n")

# ---- 2. Trial-level CMJ data for reliability: athletes with exactly 3 CMJs in a session ----
p <- read.csv(args[2])
p <- subset(p, cond == "CMJ" & group %in% c("Basketball", "Soccer"))
n <- table(p$sess)
p <- subset(p, sess %in% names(n)[n == 3])
p <- p[!duplicated(p$ath) | p$sess %in% p$sess[!duplicated(p$ath)], ]
first_sess <- tapply(p$sess, p$ath, function(s) sort(s)[1])
p <- subset(p, sess %in% first_sess)
p <- p[order(p$sess, p$file), ]
ids <- sprintf("A%02d", match(p$ath, unique(p$ath)))
trials <- data.frame(
  athlete        = ids,
  sport          = p$group,
  trial          = ave(seq_len(nrow(p)), p$sess, FUN = seq_along),
  body_mass_kg   = round(p$mass, 1),   # estimated from the force plate in each trial
  jump_height_cm = round(100 * p$Jheight, 1)
)
write.csv(trials, "data/cmj_trials.csv", row.names = FALSE)
cat("cmj_trials.csv:", length(unique(trials$athlete)), "athletes,", nrow(trials), "trials\n")
