# Modeling Depression Trajectories After Detoxification

A longitudinal mixed-effects analysis of depressive symptom (CESD) trajectories over 24 months following detoxification, using the HELP (Health Evaluation and Linkage to Primary care) study.

## Research question

How does depressive symptom severity (CESD) change over 24 months following detoxification, and are individual trajectories associated with baseline substance type, housing status, and treatment assignment?

## Project structure

```
.
├── analysis.Rmd                              # Main analysis: data cleaning, EDA, modeling, diagnostics
├── R/
│   └── helpers.R                             # Helper functions sourced by analysis.Rmd
│                                              #   (missingness_by_wave, plot_trajectories,
│                                              #    compare_models, tidy_effects_table)
├── data/
│   └── HELPfull.csv                          # Source dataset (mosaicData::HELPfull)
├── figs/                                     # Figures generated on knit (fig.path in analysis.Rmd)
├── output/
│   └── analysis.html                         # THE knitted output -- canonical, always regenerated on Knit
└── Depression_Trajectories_HELP_Study.docx   # Standalone written report (first-person, with figures)
```

## How to run

1. Open `analysis.Rmd` in RStudio and Knit (Ctrl+Shift+K), or Run All chunks.
2. The `.Rmd`'s YAML `knit:` field points the "Knit" button at
   `rmarkdown::render(..., output_dir = "output")`, so the rendered HTML
   always lands at `output/analysis.html` rather than next to the `.Rmd` --
   there is now a single canonical rendered copy instead of two that can
   drift out of sync. If you render from the console instead (e.g.
   `rmarkdown::render("analysis.Rmd")` with no `output_dir` argument), that
   call bypasses the YAML `knit:` field and writes `analysis.html` back into
   the project root, so prefer the Knit button or pass
   `output_dir = "output"` explicitly.
3. The setup chunk installs any missing packages automatically:
   `mosaicData`, `tidyverse`, `naniar`, `lme4`, `lmerTest`, `nlme`, `broom.mixed`,
   `performance`, `DHARMa`, `mice`, `ggeffects`, `influence.ME`, `see`,
   `RLRsim`, `gtsummary`, `boot`.
4. `R/helpers.R` must sit alongside `analysis.Rmd` in an `R/` subfolder — it's sourced automatically in the setup chunk and supplies the plotting/summary helper functions the document calls.
5. Optional (slow diagnostics, off by default): set `HELP_RUN_INFLUENCE=true`
   before knitting to run the leave-one-subject-out influence diagnostics in
   Section 8, and/or `HELP_RUN_BOOT=true` to run the 200-refit parametric
   bootstrap CIs in Section 11.6.

Both knitting and running chunks interactively (Ctrl+Enter / Run All) are supported. Figures still land in the top-level `figs/` folder regardless of where the HTML is rendered — that's fine, since the HTML embeds them (`self_contained` is `html_document`'s default), so `output/analysis.html` has no external dependency on `figs/`.

## Data

`HELPfull` — ~470 subjects, interviewed at baseline and every 6 months through 24 months (5 waves: 0/6/12/18/24), long format, ~1,470 rows.

- **Outcome:** `cesd` — Center for Epidemiologic Studies Depression scale (0–60, higher = more symptoms).
- **Predictors:** `time_months`, `substance` (alcohol / cocaine / heroin), `homeless`, `treat`, `age`.
- **Note:** `substance` and `age` are recorded only at baseline in the raw data; `analysis.Rmd` carries these forward within subject so they're available at every wave (see Section 1 of the analysis for the full rationale).

## Method summary

1. Unconditional means model → ICC = 0.424 (repeated-measures structure confirmed).
2. Random-intercept model (`m1`), adjusting for time, substance, age, homeless, treat.
3. Random-slope model (`m2`) — the primary model — allowing each subject's own rate of change, supported by a likelihood-ratio test against `m1` and the individual trajectory plots.
4. Diagnostics (`performance::check_model`, DHARMa) and three sensitivity checks: completers-only, multiple imputation, and an `nlme` cross-check with compound-symmetry correlation.
5. Extended analyses (Section 11): marginal/conditional R², a full
   AIC/BIC model comparison table, a time×homeless interaction (does
   housing status change the *rate* of improvement, not just the level?),
   standardized effect sizes, an exact `RLRsim` test for the random slope,
   parametric bootstrap CIs, observed-vs-predicted plots for a sample of
   subjects, an AR(1) correlation-structure cross-check, a baseline
   "Table 1" by treatment arm, and a quadratic-time robustness check on
   the linearity assumption.

## Key results

| Effect | Estimate | Notes |
| --- | --- | --- |
| ICC | 0.424 | ~42% of variance is between-subject |
| Time (per month) | −0.47 to −0.48 CESD points | ~11–12 point decline over 24 months; p < .001 |
| Homeless | +4.53 CESD points | p < .001 |
| Cocaine vs. alcohol (baseline) | −3.51 CESD points | p = .013 |
| Treatment arm | Not significant | p = .57 |
| Age | Not significant | p = .78 |

Full write-up, figures, and discussion: see `Depression_Trajectories_HELP_Study.docx` or the knitted `output/analysis.html`.

## Known issues

- `vis_miss()`'s rotated column labels in the missingness plot (Section 3 of `analysis.Rmd`) are slightly clipped by the plot's own panel/clip region — cosmetic only; the exact percentages are given in the table immediately below it.
- A stale `analysis.html` may still exist in the project root from before the
  `knit:` YAML field was added (it used to be written there by default). It's
  no longer regenerated and safe to delete — `output/analysis.html` is now
  the one canonical rendered copy.
