# Longitudinal Depression Trajectories After Detox: A Mixed-Effects Analysis of the HELP Study

## Research question
How does depressive symptom severity (CESD) change over 24 months following
detoxification, and are individual trajectories associated with baseline
substance type, housing status, and treatment assignment?

## Data
- Dataset: `HELPfull` (Health Evaluation and Linkage to Primary Care)
- Source: `mosaicData` R package — https://nhorton.people.amherst.edu/help/
- Design: ~453 adult inpatients recruited from a detox unit, interviewed at
  baseline and every 6 months for 2 years (5 waves total).
- No download needed — loaded directly via `library(mosaicData); data(HELPfull)`

## Project structure
```
help_longitudinal/
├── README.md              <- you are here
├── analysis.Rmd           <- full analysis, stubbed section by section
├── data/                  <- (empty; data loads from package, not stored here)
├── R/
│   └── helpers.R          <- reusable functions (trajectory plots, model tables)
├── figs/                  <- exported figures land here
└── output/                <- rendered report (.html/.pdf) lands here
```

## How to run
1. Open `analysis.Rmd` in RStudio (or run via `rmarkdown::render()`).
2. Run the setup chunk to install/load packages.
3. Work through the numbered sections in order — each is a stub with
   guidance comments (`# TODO:`) and a starter code skeleton.
4. Knit to HTML/PDF when done: `rmarkdown::render("analysis.Rmd")`.

## Packages used
mosaicData, tidyverse, naniar, lme4, lmerTest, nlme, broom.mixed,
performance, DHARMa, mice, ggeffects
