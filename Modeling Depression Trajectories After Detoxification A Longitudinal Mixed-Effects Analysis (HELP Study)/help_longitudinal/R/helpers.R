# R/helpers.R
# Helper functions for analysis.Rmd (HELP study CESD trajectory analysis)

# ---------------------------------------------------------------------------
# missingness_by_wave(): per-wave missingness summary for a longitudinal
# outcome. Prints a small tibble with n, n_missing, pct_missing per wave.
# ---------------------------------------------------------------------------
missingness_by_wave <- function(df, time_var, outcome_var) {
  out <- df %>%
    dplyr::group_by(.data[[time_var]]) %>%
    dplyr::summarise(
      n = dplyr::n(),
      n_missing = sum(is.na(.data[[outcome_var]])),
      pct_missing = round(100 * mean(is.na(.data[[outcome_var]])), 1),
      .groups = "drop"
    )
  print(out)
  invisible(out)
}

# ---------------------------------------------------------------------------
# plot_trajectories(): spaghetti plot of individual trajectories over time,
# with the group mean overlaid. Optionally color/summarize by a grouping var.
# ---------------------------------------------------------------------------
plot_trajectories <- function(df, id_var, time_var, outcome_var, group_var = NULL) {
  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(
      x = .data[[time_var]],
      y = .data[[outcome_var]],
      group = .data[[id_var]]
    )
  ) +
    ggplot2::geom_line(alpha = 0.15, linewidth = 0.3, na.rm = TRUE) +
    ggplot2::labs(x = "Months since baseline", y = outcome_var)

  if (is.null(group_var)) {
    p <- p +
      ggplot2::stat_summary(
        ggplot2::aes(group = 1), fun = mean, geom = "line",
        color = "firebrick", linewidth = 1.1, na.rm = TRUE
      ) +
      ggplot2::labs(title = "Individual trajectories with overall mean")
  } else {
    p <- p +
      ggplot2::aes(color = .data[[group_var]]) +
      ggplot2::stat_summary(
        ggplot2::aes(group = .data[[group_var]], color = .data[[group_var]]),
        fun = mean, geom = "line", linewidth = 1.1, na.rm = TRUE
      ) +
      ggplot2::labs(
        title = paste("Individual trajectories by", group_var),
        color = group_var
      )
  }

  print(p)
  invisible(p)
}

# ---------------------------------------------------------------------------
# compare_models(): nested-model comparison (LRT + AIC/BIC) for two lmer
# fits, printed as a tidy summary.
# ---------------------------------------------------------------------------
compare_models <- function(m1, m2) {
  cmp <- anova(m1, m2)
  print(cmp)
  invisible(cmp)
}

# ---------------------------------------------------------------------------
# tidy_effects_table(): fixed-effects table with CIs for an lmer/lme fit,
# via broom.mixed::tidy(). Works for both lmerMod and lme objects.
# ---------------------------------------------------------------------------
tidy_effects_table <- function(model) {
  tab <- broom.mixed::tidy(
    model,
    effects = "fixed",
    conf.int = TRUE
  )
  print(tab)
  invisible(tab)
}
