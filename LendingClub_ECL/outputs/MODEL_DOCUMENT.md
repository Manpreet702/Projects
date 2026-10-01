# Model Document: Simplified IFRS 9 PD / LGD / EAD / ECL (LendingClub)

## 1. Purpose
Illustrate how a PD model feeds an IFRS 9-style Expected Credit Loss estimate for an unsecured consumer
loan portfolio. Educational scope only; not for provisioning or decision-making.

## 2. Data
* LendingClub accepted loans. Modelling sample = closed loans (Fully Paid vs Charged Off/Default); in-progress loans excluded.
* Train: issued up to 2014-12-31 (453,809 loans, default rate 17.03%).
  Out-of-time test: 2015-01-01 to 2016-12-31 (668,651 loans, default rate 21.54%).
* Features: application-time only (loan terms, income, DTI, FICO, credit history, utilisation, etc.).
  LendingClub grade / interest rate are excluded from the PD model (they are the lender's own model output) and used only for reporting.

## 3. Methodology
* **PD**: WoE-binned logistic regression scorecard (8 features, IV 0.02-0.6, |corr| < 0.8).
  Challenger: histogram gradient boosting on all features. Scorecard scaling: 600 points at 50:1 odds, PDO 20.
* **Variable checks**: removed after the coefficient-sign / score-spread checks: loan_amnt (wrong-sign coefficient), revol_util (score spread only 0.5 points) (rules: negative coefficient on WoE; at least 1.0 points of score spread).
* **Recalibration**: scorecard intercept shifted by +0.328 to match the OOT default rate (flag `RECALIBRATE_TO_TEST`).
* **LGD**: 1 - net recoveries / EAD at default, exposure-weighted by grade (overall 91.0%).
* **EAD**: outstanding principal (`out_prncp`) on the live book; at default approximated as funded amount - principal repaid.
* **ECL**: PD x LGD x EAD, mid-horizon discounted at the loan interest rate.
  Stage 1 = 12-month PD; Stage 2 (grace / 16-30 days late) = lifetime PD; Stage 3 (31-120 days late) = PD 100%.
  Term structure via constant hazard: PD_h = 1 - (1 - PD_life)^(h/term).
* **Scenarios**: adverse = PD odds x1.5, LGD x1.15.

## 4. Validation results (out-of-time)
                        AUC   Gini     KS  Brier
Scorecard (train)    0.6818 0.3636 0.2637 0.1325
Scorecard (OOT test) 0.6912 0.3824 0.2720 0.1579
GBM (train)          0.7215 0.4431 0.3222 0.1279
GBM (OOT test)       0.7141 0.4282 0.3073 0.1541

Calibration:
           calibration_slope  calibration_intercept (CITL)  mean_pred_PD  observed_DR
Scorecard             1.1068                        0.3278        0.1681       0.2154
GBM                   1.0613                        0.3131        0.1711       0.2154

Stability: score PSI = 0.002
(Stable).

## 5. Model choice
Scorecard (GBM as challenger). GBM is 2.3 AUC points better; consider it as a challenger or add monotonic constraints and SHAP-based explanations before replacing the scorecard. The scorecard stays primary for transparency.

## 6. Results
Portfolio base ECL 748,839,792 / EAD 9,510,001,923 = 7.87%. Adverse ECL 1,037,844,807.
Details by grade and stage in `outputs/ecl_summary.xlsx`.

## 7. Limitations
* Right-censoring: recent vintages show lower default rates because bad loans have not matured yet.
* Population drift: LendingClub underwriting changed over time; PDs are recalibrated on one window only.
* Stage allocation uses delinquency status only; no PD-based SICR test, no forward-looking macro scenarios or probability-weighting.
* Constant-hazard term structure; no prepayment modelling; discounting uses the contract rate as a proxy for EIR.
* LGD is a grade-level average of cash recoveries without discounting or recovery-timing curves.
* EAD ignores undrawn commitments (term loans only).
* Only one test window; no stress test beyond a simple multiplier. Fairness / bias review not performed.
