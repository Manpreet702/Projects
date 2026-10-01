# Demographic, Lifestyle, and Clinical Correlates of Hypertension

A survey-weighted cross-sectional analysis of NHANES 2017-March 2020
(CDC's pre-pandemic combined cycle), asking what demographic, lifestyle,
and clinical factors are associated with hypertension among U.S. adults --
and whether dietary sodium intake adds explanatory value beyond that.

## Research question

How does hypertension relate to demographic (age, sex, race/ethnicity,
education, income), lifestyle (BMI, physical activity, smoking, alcohol),
and clinical (diabetes, total cholesterol) factors among U.S. adults, and
does dietary sodium intake add independent explanatory value once those
core risk factors are accounted for?

## Why this is a survey analysis, not an ML pipeline

NHANES is not a simple random sample -- it's a multi-stage, stratified,
clustered probability sample with oversampling of some subgroups. Treating
its rows as i.i.d. observations (the implicit assumption behind a plain
`glm()`, let alone a `train_test_split` + classifier pipeline) produces
biased point estimates and badly wrong standard errors. This project uses
the `survey` package throughout: every prevalence estimate, model
coefficient, and confidence interval is computed from a `svydesign` object
that incorporates the sample weights (`WTMECPRP` / `WTDRD1PP`) and the
masked variance PSU/strata variables (`SDMVPSU`, `SDMVSTRA`) CDC provides
specifically for this purpose. Section 10.3 of the analysis fits the exact
same model two ways -- correctly (survey-weighted) and naively
(unweighted, i.i.d.) -- side by side, to make concrete exactly what
ignoring the survey design costs, rather than just asserting that it
matters.

The goal throughout is inference (which factors are associated with
hypertension, how strongly, with defensible uncertainty) rather than
prediction/classification accuracy -- there is no train/test split and no
"accuracy" metric anywhere in this project, deliberately.

## Project structure

```
.
├── analysis.Rmd          # Main analysis: acquisition, cleaning, survey design,
│                          #   modeling, diagnostics, sensitivity analyses
├── R/
│   ├── download_data.R   # Downloads + caches NHANES tables via nhanesA
│   └── helpers.R         # Derivation functions (outcome definition, smoking/
│                          #   alcohol/BMI/activity categorization, OR tables,
│                          #   calibration table) -- each documents WHY, not
│                          #   just what, since every one encodes a real
│                          #   methodological decision
├── data/
│   └── raw/               # Cached NHANES tables (.rds), created on first run
├── figs/                  # Figures generated on knit
└── output/
    └── analysis.html      # Rendered report (the knit target -- see below)
```

## How to run

1. Open `analysis.Rmd` in RStudio and Knit (Ctrl+Shift+K). The `.Rmd`'s
   YAML `knit:` field routes the rendered HTML to `output/analysis.html`
   automatically.
2. **First run needs internet access** to `wwwn.cdc.gov` -- the setup
   pulls ten NHANES tables (a few MB total) and caches them to
   `data/raw/*.rds`. Every re-knit after that reuses the cache; delete a
   specific `.rds` file (or pass `force_refresh = TRUE` to
   `download_nhanes_table()`) to pull a fresh copy.
3. Required packages (`nhanesA`, `tidyverse`, `survey`, `gtsummary`,
   `broom`, `car`, `naniar`, `scales`) install automatically if missing.
4. Expect the first knit to take a few minutes (download + several
   `svyglm` fits on a sample of several thousand adults).

## Data

**Source:** NHANES 2017-March 2020 pre-pandemic file. CDC built this
special combined cycle specifically to replace the COVID-interrupted
2019-2020 collection, with its own purpose-built weights (`WTMECPRP`
for exam-based analyses, `WTDRD1PP` for analyses using the Day-1 dietary
recall) and its own masked-variance PSU/strata variables -- these are
**not** interchangeable with a standard 2-year cycle's weights, and the
download script's comments explain why each choice was made. Every table
name, variable name, and value coding used in this project was verified
directly against CDC's own data file documentation (not recalled from
memory) before being written into code -- e.g. this cycle switched from
the older 4-reading mercury-sphygmomanometer BP exam (`BPXSY1-4`) to a
3-reading automated oscillometric device (`BPXOSY1-3`), a change easy to
get wrong if you assume the variable names from an earlier cycle still
apply.

**Tables used:** `P_DEMO` (demographics + weights), `P_BPXO` (blood
pressure exam), `P_BPQ` (hypertension diagnosis/medication), `P_BMX`
(body measures), `P_PAQ` (physical activity), `P_SMQ` (smoking), `P_ALQ`
(alcohol), `P_DIQ` (diabetes), `P_TCHOL` (lab total cholesterol),
`P_DR1TOT` (Day-1 dietary recall, sodium/energy).

**Outcome:** hypertension, defined two ways for a built-in sensitivity
check -- ACC/AHA 2017 (mean SBP >=130 or mean DBP >=80, or on
antihypertensive medication; the primary definition) and JNC7 (>=140/90
or on medication; the more conservative, older threshold). Mean BP
averages the 2nd and 3rd oscillometric readings per NHANES analytic
convention (the 1st reading is treated as a reactive/settling-in
measurement).

## Method summary

1. Merge ten NHANES modules on `SEQN`; derive the outcome and every
   lifestyle/clinical predictor with fully documented derivation logic
   (`R/helpers.R`).
2. Build the survey design on the **full** sample first, then `subset()`
   down to the analytic domain (adults, MEC-examined, valid outcome) --
   preserving correct variance estimation, unlike filtering the raw
   data.frame before designing.
3. Weighted Table 1, weighted prevalence estimates, weighted EDA.
4. Crude (unadjusted) and adjusted multivariable `svyglm` (quasibinomial)
   models; odds ratios with 95% CI; forest plot.
5. Diagnostics: multicollinearity (`car::vif`), linearity of continuous
   predictors (spline term + survey-adjusted Wald test via
   `regTermTest`, since `anova()`-style LRTs aren't design-consistent for
   `svyglm`), and a weighted decile calibration table (the practical
   stand-in for a formal Archer-Lemeshow test).
6. Sensitivity analyses: alternate hypertension definition (JNC7),
   excluding already-treated participants, survey-weighted vs. naive
   unweighted model (to make the cost of ignoring survey design
   concrete), and a diet-augmented model on the dietary-recall subsample
   using its own weight.

## Known limitations (by design, stated up front)

- Cross-sectional data -- every association is exactly that, an
  association; no causal or temporal claims are made anywhere in the
  interpretation.
- Complete-case analysis for missingness (Section 3); multiple imputation
  combined with `survey`'s replicate-weight machinery is noted as the
  natural next step, not silently skipped.
- Self-reported smoking, alcohol, and diabetes status carry the usual
  social-desirability/recall biases inherent to questionnaire data.
- A single day's dietary recall is a noisy proxy for usual sodium intake
  -- the diet sub-analysis is explicitly framed as exploratory for this
  reason, not as strong as the core survey-weighted BP-exam analysis.

## Results

Weighted, the analytic domain (8,293 sampled adults) represents an
estimated 231.8 million U.S. adults. Overall weighted hypertension
prevalence (ACC/AHA 2017 definition) is **48.7%** (SE 1.2 pp) -- 51.7%
among men vs. 46.0% among women, and highest among Non-Hispanic Black
adults (58.6%) vs. Non-Hispanic White (48.9%) and Mexican American
(37.4%) adults.

After survey-weighted adjustment for demographics, lifestyle, and
clinical covariates, the strongest independent predictors of
hypertension are **obesity** (OR 3.25, 95% CI 2.29-4.62), **diabetes**
(OR 2.46, 95% CI 1.46-4.15), **heavy alcohol use** (OR 2.14, 95% CI
1.15-3.99), and **age** (OR 1.06 per year, 95% CI 1.05-1.07); meeting
physical activity guidelines is independently protective (OR 0.74, 95%
CI 0.55-0.99). These associations are directionally consistent under
the JNC7 definition, persist when restricting to untreated adults only,
and hold whether or not dietary sodium is added to the model -- sodium
itself showed no significant independent association (p = 0.78) once
core risk factors were accounted for, though a single day's dietary
recall is a genuinely noisy measure of usual intake.

The side-by-side weighted-vs-naive comparison (Section 10.3) makes the
survey-design point concrete rather than asserted: point estimates are
similar between the two approaches, but the naive (unweighted, i.i.d.)
model's confidence intervals are consistently narrower -- e.g., for age,
p = 8.3e-146 naively vs. p = 5.8e-4 with the design correctly accounted
for -- exactly the overconfident precision that ignoring NHANES's
clustering and weighting would otherwise produce.

One notable limitation surfaced by the analysis itself: this
pre-pandemic combined cycle leaves very few design degrees of freedom
once `hyp_design` is subset to the adult/valid-outcome domain (e.g., the
age-linearity spline test has only 1 denominator df), which widens
several adjusted confidence intervals relative to what a naive model
would report. See `analysis.Rmd` Section 11 for the full interpretation,
caveats, and suggested next steps (multiple imputation, replicate
weights, effect-modification checks).
