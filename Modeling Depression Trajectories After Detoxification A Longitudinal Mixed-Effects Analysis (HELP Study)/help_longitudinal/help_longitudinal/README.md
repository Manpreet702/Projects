# Modeling Depression Trajectories After Detoxification

A longitudinal mixed-effects analysis of depressive symptom (CESD) trajectories over 24 months following detoxification, using the HELP (Health Evaluation and Linkage to Primary care) study.

## Research question

How does depressive symptom severity (CESD) change over 24 months following detoxification, and are individual trajectories associated with baseline substance type, housing status, and treatment assignment?

## Project structure

```
.
├── analysis.Rmd                              # Main analysis: data cleaning, EDA, modeling, diagnostics
├── analysis.html                             # Knitted output of analysis.Rmd
├── R/
│   └── helpers.R                             # Helper functions sourced by analysis.Rmd
│                                              #   (missingness_by_wave, plot_trajectories,
│                                              #    compare_models, tidy_effects_table)
├── data/
│   └── HELPfull.csv                          # Source dataset (mosaicData::HELPfull)
├── figs/                                     # Figures generated on knit (fig.path in analysis.Rmd)
├── output/
│   └── analysis.html                         # Earlier/alternate knit output
└── Depression_Trajectories_HELP_Study.docx   # Standalone written report (first-person, with figures)
```

## How to run

1. Open `analysis.Rmd` in RStudio (Run All, or Knit).
2. The setup chunk installs any missing packages automatically:
   `mosaicData`, `tidyverse`, `naniar`, `lme4`, `lmerTest`, `nlme`, `broom.mixed`,
   `performance`, `DHARMa`, `mice`, `ggeffects`, `influence.ME`, `see`.
3. `R/helpers.R` must sit alongside `analysis.Rmd` in an `R/` subfolder — it's sourced automatically in the setup chunk and supplies the plotting/summary helper functions the document calls.
4. Optional: set `HELP_RUN_INFLUENCE=true` as an environment variable before knitting to also run the (slower) leave-one-subject-out influence diagnostics in Section 8.

Both knitting and running chunks interactively (Ctrl+Enter / Run All) are supported.

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

## Key results

| Effect | Estimate | Notes |
| --- | --- | --- |
| ICC | 0.424 | ~42% of variance is between-subject |
| Time (per month) | −0.47 to −0.48 CESD points | ~11–12 point decline over 24 months; p < .001 |
| Homeless | +4.53 CESD points | p < .001 |
| Cocaine vs. alcohol (baseline) | −3.51 CESD points | p = .013 |
| Treatment arm | Not significant | p = .57 |
| Age | Not significant | p = .78 |

Full write-up, figures, and discussion: see `Depression_Trajectories_HELP_Study.docx` or the knitted `analysis.html`.

## Known issues

- `vis_miss()`'s rotated column labels in the missingness plot (Section 3 of `analysis.Rmd`) are slightly clipped by the plot's own panel/clip region — cosmetic only; the exact percentages are given in the table immediately below it.
