# Consumer Credit Risk: PD, LGD and Simplified IFRS 9 ECL (LendingClub)

> **Simplified IFRS 9 illustration, not a production model.**

## Overview
End-to-end credit risk project: out-of-time PD model (WoE scorecard vs gradient boosting), validation
(discrimination, calibration, stability), LGD and EAD from defaulted loans, and a Stage 1/2/3 ECL summary by grade
with a base vs adverse sensitivity.

## Key results
| Metric | Scorecard (OOT) | GBM (OOT) |
|---|---|---|
| AUC | 0.691 | 0.714 |
| Gini | 0.382 | 0.428 |
| KS | 0.272 | 0.307 |

* Chosen primary model: **Scorecard (GBM as challenger)**. GBM is 2.3 AUC points better; consider it as a challenger or add monotonic constraints and SHAP-based explanations before replacing the scorecard. The scorecard stays primary for transparency.
* Portfolio ECL (base): 748,839,792 on EAD 9,510,001,923 (coverage 7.87%); adverse: 1,037,844,807 (+38.6%).
* Exposure-weighted LGD: 91.0%.

## Repo structure
```
data/            # raw Kaggle file (not committed)
notebooks/       # lendingclub_ecl.ipynb
outputs/         # ecl_summary.xlsx, figures/
docs/            # MODEL_DOCUMENT.md
README.md
```

## How to run
1. Download the LendingClub CSV from Kaggle and set `DATA_PATH` in the config cell.
2. `pip install pandas numpy scikit-learn scipy matplotlib openpyxl`
3. Run the notebook top to bottom. Outputs are written to `outputs/`.

## Limitations
See `docs/MODEL_DOCUMENT.md`.
