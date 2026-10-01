# R/helpers.R
# Derivation and analysis helper functions for the NHANES hypertension
# risk-factor analysis. Every derivation below encodes a specific
# methodological choice -- each function's header explains what the choice
# is and why, so the reasoning is auditable rather than buried in a mutate().

# ---------------------------------------------------------------------------
# classify_smoking(): NHANES asks smoking status in two steps -- SMQ020
# ("smoked at least 100 cigarettes in life") and, only for those who say
# yes, SMQ040 ("do you now smoke"). CDC's own analytic guidance says these
# two questions must be combined to get current/former/never status; there
# is no single pre-built variable for this in the raw file.
# ---------------------------------------------------------------------------
classify_smoking <- function(smq020, smq040) {
  dplyr::case_when(
    smq020 == 2 ~ "Never",
    smq020 == 1 & smq040 %in% c(1, 2) ~ "Current",
    smq020 == 1 & smq040 == 3 ~ "Former",
    TRUE ~ NA_character_
  ) |> factor(levels = c("Never", "Former", "Current"))
}

# ---------------------------------------------------------------------------
# classify_alcohol(): ALQ121 gives drinking FREQUENCY as a coded category
# (e.g. "3-4 times a week"), not a days/week count, and ALQ130 gives the
# average number of drinks PER drinking day. To classify drinkers against
# the standard NIAAA moderate-drinking thresholds (up to 1 drink/day for
# women, up to 2/day for men) we need an approximate weekly drink total, so
# we map each ALQ121 category to its midpoint in days/week and multiply by
# ALQ130. This midpoint mapping is a standard, documented approximation
# used in the NHANES analytic literature -- not an exact count -- and that
# limitation is called out explicitly in the write-up rather than glossed
# over.
# ---------------------------------------------------------------------------
alq121_days_per_week <- c(
  `0` = 0,        # never in the last year
  `1` = 7,        # every day
  `2` = 6,        # nearly every day
  `3` = 3.5,      # 3-4 times a week
  `4` = 2,        # 2 times a week
  `5` = 1,        # once a week
  `6` = 2.5 / 4.33,  # 2-3 times a month
  `7` = 1 / 4.33,    # once a month
  `8` = 9 / 52,      # 7-11 times in the last year
  `9` = 4.5 / 52,    # 3-6 times in the last year
  `10` = 1.5 / 52    # 1-2 times in the last year
)

classify_alcohol <- function(alq121, alq130, sex) {
  days_per_week <- unname(alq121_days_per_week[as.character(alq121)])
  drinks_per_week <- days_per_week * alq130

  dplyr::case_when(
    alq121 == 0 ~ "None (past year)",
    is.na(drinks_per_week) ~ NA_character_,
    sex == "Male"   & drinks_per_week <= 14 ~ "Moderate",
    sex == "Female" & drinks_per_week <= 7  ~ "Moderate",
    !is.na(drinks_per_week) ~ "Heavy",
    TRUE ~ NA_character_
  ) |> factor(levels = c("None (past year)", "Moderate", "Heavy"))
}

# ---------------------------------------------------------------------------
# compute_pa_met_minutes(): derives weekly moderate-equivalent activity
# minutes from NHANES's GPAQ-style physical activity questionnaire, since
# NHANES provides no pre-built "meets guidelines" variable. Follows the
# WHO Global Physical Activity Questionnaire (GPAQ) analysis-guide scoring
# convention: vigorous activity = 8 METs, moderate activity (including
# active transport) = 4 METs. "Moderate-equivalent minutes" doubles
# vigorous minutes, matching how the US 2018 Physical Activity Guidelines
# define equivalence between vigorous and moderate activity for the
# 150-min/week threshold.
#
# NHANES codes "yes/no" (PAQ605 etc.) as 1 = Yes, 2 = No, 7 = Refused,
# 9 = Don't know; days/minutes fields are only asked (and only valid)
# when the corresponding yes/no question is 1.
# ---------------------------------------------------------------------------
compute_pa_met_minutes <- function(paq_row) {
  with(paq_row, {
    vig_work <- ifelse(!is.na(PAQ605) & PAQ605 == 1 & !is.na(PAQ610) & !is.na(PAD615),
                        PAQ610 * PAD615, 0)
    mod_work <- ifelse(!is.na(PAQ620) & PAQ620 == 1 & !is.na(PAQ625) & !is.na(PAD630),
                        PAQ625 * PAD630, 0)
    walk_bike <- ifelse(!is.na(PAQ635) & PAQ635 == 1 & !is.na(PAQ640) & !is.na(PAD645),
                         PAQ640 * PAD645, 0)
    vig_rec <- ifelse(!is.na(PAQ650) & PAQ650 == 1 & !is.na(PAQ655) & !is.na(PAD660),
                       PAQ655 * PAD660, 0)
    mod_rec <- ifelse(!is.na(PAQ665) & PAQ665 == 1 & !is.na(PAQ670) & !is.na(PAD675),
                       PAQ670 * PAD675, 0)

    moderate_equiv_min <- (2 * (vig_work + vig_rec)) + mod_work + walk_bike + mod_rec
    moderate_equiv_min
  })
}

#' meets_pa_guidelines(): >=150 moderate-equivalent minutes/week, per the US
#' 2018 Physical Activity Guidelines threshold. Returns NA (not FALSE) when
#' the underlying questionnaire responses were missing/refused for every
#' domain, so non-response isn't silently coded as "inactive".
meets_pa_guidelines <- function(moderate_equiv_min, any_domain_answered) {
  dplyr::if_else(any_domain_answered, moderate_equiv_min >= 150, NA)
}

# ---------------------------------------------------------------------------
# classify_bmi(): standard WHO/CDC adult BMI categories.
# ---------------------------------------------------------------------------
classify_bmi <- function(bmxbmi) {
  dplyr::case_when(
    is.na(bmxbmi) ~ NA_character_,
    bmxbmi < 18.5 ~ "Underweight",
    bmxbmi < 25 ~ "Normal",
    bmxbmi < 30 ~ "Overweight",
    TRUE ~ "Obese"
  ) |> factor(levels = c("Normal", "Underweight", "Overweight", "Obese"))
}

# ---------------------------------------------------------------------------
# mean_oscillometric_bp(): NHANES's own analytic guidance for oscillometric
# BP (introduced in this cycle) is to treat the first reading as a
# reactive/settling-in measurement and average the LATER readings instead.
# We average readings 2 and 3, falling back to reading 1 alone for the small
# number of participants missing both 2 and 3 -- documented explicitly here
# and in the write-up rather than left as an unstated default.
# ---------------------------------------------------------------------------
mean_oscillometric_bp <- function(r1, r2, r3) {
  later <- cbind(r2, r3)
  n_later <- rowSums(!is.na(later))
  mean_later <- rowMeans(later, na.rm = TRUE)
  dplyr::if_else(n_later > 0, mean_later, r1)
}

# ---------------------------------------------------------------------------
# define_hypertension(): two definitions are built side by side so the
# primary analysis and the sensitivity analysis are never out of sync.
#   - "aha2017": mean SBP >=130 OR mean DBP >=80 OR currently on
#     antihypertensive medication (current ACC/AHA 2017 clinical threshold)
#   - "jnc7": mean SBP >=140 OR mean DBP >=90 OR on medication (the older,
#     more conservative threshold many earlier NHANES-based papers used --
#     comparing against it is the sensitivity check for whether conclusions
#     depend on which guideline's threshold is used)
# Both require a valid mean BP OR documented medication use; a participant
# with no BP reading and no medication data is left NA, not coded normotensive.
#
# on_bp_meds itself comes from BPQ050A, which NHANES only ASKS respondents
# who first said yes to BPQ020 ("ever told you had high blood pressure") --
# so a missing BPQ050A almost always means the question legitimately didn't
# apply (never diagnosed), not genuine nonresponse. Treating missing
# on_bp_meds as FALSE ("not on medication") is therefore the methodologically
# correct read of NHANES's skip-pattern design, not a convenient default.
# ---------------------------------------------------------------------------
define_hypertension <- function(mean_sbp, mean_dbp, on_bp_meds) {
  on_meds <- ifelse(is.na(on_bp_meds), FALSE, on_bp_meds)
  aha2017 <- dplyr::case_when(
    is.na(mean_sbp) & is.na(mean_dbp) & !on_meds ~ NA,
    on_meds ~ TRUE,
    TRUE ~ (mean_sbp >= 130 | mean_dbp >= 80)
  )
  jnc7 <- dplyr::case_when(
    is.na(mean_sbp) & is.na(mean_dbp) & !on_meds ~ NA,
    on_meds ~ TRUE,
    TRUE ~ (mean_sbp >= 140 | mean_dbp >= 90)
  )
  list(aha2017 = aha2017, jnc7 = jnc7)
}

# ---------------------------------------------------------------------------
# svyglm_or_table(): tidy a svyglm(family = quasibinomial) fit into a table
# of odds ratios with 95% CI and p-values, on the response (not log-odds)
# scale, ready for a forest plot or a results table.
# ---------------------------------------------------------------------------
svyglm_or_table <- function(model) {
  co <- summary(model)$coefficients
  ci <- stats::confint(model)
  tibble::tibble(
    term = rownames(co),
    estimate_log_odds = co[, "Estimate"],
    std_error = co[, "Std. Error"],
    p_value = co[, ncol(co)],
    or = exp(co[, "Estimate"]),
    or_low = exp(ci[, 1]),
    or_high = exp(ci[, 2])
  )
}

# ---------------------------------------------------------------------------
# weighted_calibration_table(): a survey-weighted analogue of a
# Hosmer-Lemeshow calibration table -- splits observations into deciles of
# PREDICTED risk, then compares the weighted mean predicted probability to
# the weighted observed proportion of the outcome within each decile. This
# is the standard practical stand-in for the Archer-Lemeshow test (the
# formal complex-survey goodness-of-fit test) when a dedicated package
# implementation of that test isn't available -- it answers the same
# question (does predicted risk track observed risk across the risk
# spectrum?) via straightforward weighted summaries rather than a specific
# test statistic, and that trade-off is intentional and stated in the report.
# ---------------------------------------------------------------------------
weighted_calibration_table <- function(design, predicted, observed, n_bins = 10) {
  design$variables$.predicted <- predicted
  design$variables$.observed <- observed

  # quantile() breakpoints can collide when predicted risk clusters heavily
  # (common with a mostly-categorical predictor set) -- cut() errors on
  # duplicate breaks, so we de-duplicate and fall back to fewer, wider bins
  # rather than crashing this diagnostic outright.
  breaks <- unique(stats::quantile(predicted, probs = seq(0, 1, length.out = n_bins + 1), na.rm = TRUE))
  if (length(breaks) < 3) {
    stop("Predicted probabilities are too concentrated to form risk bins -- ",
         "inspect range(predicted) directly instead of via this calibration table.")
  }
  design$variables$.risk_decile <- cut(predicted, breaks = breaks, include.lowest = TRUE, labels = FALSE)
  survey::svyby(~.observed, ~.risk_decile, design, survey::svymean, na.rm = TRUE) |>
    dplyr::rename(observed_rate = .observed) |>
    dplyr::left_join(
      survey::svyby(~.predicted, ~.risk_decile, design, survey::svymean, na.rm = TRUE) |>
        dplyr::rename(predicted_rate = .predicted),
      by = ".risk_decile"
    )
}
