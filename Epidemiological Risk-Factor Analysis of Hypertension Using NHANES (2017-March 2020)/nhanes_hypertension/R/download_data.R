# R/download_data.R
# Downloads and caches the NHANES 2017-March 2020 pre-pandemic data files
# needed for this analysis, using the nhanesA package.
#
# WHY THIS CYCLE: CDC's regular 2019-2020 NHANES cycle was interrupted by
# COVID-19 and its data cannot be reported as a standalone nationally
# representative cycle. CDC instead released a special "2017-March 2020
# pre-pandemic" file, combining 2017-2018 and the partial 2019-2020
# collection, with its OWN purpose-built sample weights (WTMECPRP,
# WTINTPRP, WTDRD1PP) and its OWN masked variance PSU/strata variables
# (SDMVPSU, SDMVSTRA). These are NOT the same weights as a standard 2-year
# cycle and must not be halved or combined with another cycle's weights --
# CDC did that work already. Table names in this cycle carry a "P_" PREFIX
# (e.g. P_DEMO), not the single-letter SUFFIX used for regular cycles
# (e.g. DEMO_J for 2017-2018). All of this was verified directly against
# CDC's own data file documentation before writing this script.
#
# Source: https://wwwn.cdc.gov/nchs/nhanes/continuousnhanes/default.aspx?Cycle=2017-2020

required_pkgs <- c("nhanesA", "dplyr")
new_pkgs <- required_pkgs[!(required_pkgs %in% installed.packages()[, "Package"])]
if (length(new_pkgs)) install.packages(new_pkgs, repos = "https://cloud.r-project.org")

library(nhanesA)
library(dplyr)

# Tables pulled, and why each is needed:
#   P_DEMO   - demographics + INDFMPIR (income-to-poverty ratio) + the sample
#              weights and design variables (WTMECPRP, WTINTPRP, SDMVPSU, SDMVSTRA)
#   P_BPXO   - oscillometric blood pressure exam (this cycle switched from the
#              older mercury-sphygmomanometer BPX component to an automated
#              oscillometric device -- BPXOSY1-3 / BPXODI1-3, only 3 readings,
#              not the 4-reading BPXSY1-4 used in earlier cycles)
#   P_BPQ    - self-reported hypertension diagnosis (BPQ020) and antihypertensive
#              medication use (BPQ050A) -- needed to build the outcome definition
#   P_BMX    - body measures (BMXBMI)
#   P_PAQ    - physical activity questionnaire (work/recreation/transport minutes)
#   P_SMQ    - smoking history
#   P_ALQ    - alcohol consumption frequency/quantity
#   P_DIQ    - self-reported diabetes diagnosis
#   P_TCHOL  - lab-measured total cholesterol (LBXTC)
#   P_DR1TOT - Day-1 24-hour dietary recall totals (DR1TSODI sodium, DR1TKCAL
#              energy) -- used only in the secondary/sensitivity diet model,
#              since it needs its OWN weight (WTDRD1PP), not WTMECPRP
tables_needed <- c(
  "P_DEMO", "P_BPXO", "P_BPQ", "P_BMX", "P_PAQ",
  "P_SMQ", "P_ALQ", "P_DIQ", "P_TCHOL", "P_DR1TOT"
)

raw_dir <- "data/raw"
if (!dir.exists(raw_dir)) dir.create(raw_dir, recursive = TRUE)

#' Download one NHANES table via nhanesA and cache it as an .rds file.
#' Re-running the script (or knitting analysis.Rmd) will reuse the cache
#' instead of re-downloading, unless force_refresh = TRUE.
#'
#' translated = FALSE is deliberate, not an oversight: nhanesA::nhanes()
#' defaults to translated = TRUE, which silently converts every coded
#' categorical variable (RIDSTATR, PAQ605, SMQ020, ALQ121, DIQ010, BPQ050A,
#' DR1DRSTZ, ...) from its documented numeric code into a labeled factor
#' (e.g. 2 -> "Both interviewed and MEC examined"). Every derivation in
#' this project (R/helpers.R and the mutate() in analysis.Rmd) is written
#' against the numeric codebook values as CDC documents them, so leaving
#' translation on breaks comparisons like `== 1` or `%in% c(1, 2)`
#' everywhere, silently (they return FALSE/NA rather than erroring) --
#' exactly what happened here. Forcing translated = FALSE keeps every
#' variable as the raw numeric code CDC's documentation describes, so the
#' derivation logic means what it says.
download_nhanes_table <- function(table_name, raw_dir = "data/raw", force_refresh = FALSE) {
  cache_path <- file.path(raw_dir, paste0(table_name, ".rds"))
  if (file.exists(cache_path) && !force_refresh) {
    message(table_name, ": using cached copy at ", cache_path)
    return(invisible(readRDS(cache_path)))
  }
  message(table_name, ": downloading from CDC...")
  dat <- nhanesA::nhanes(table_name, translated = FALSE)
  if (is.null(dat) || nrow(dat) == 0) {
    stop(table_name, ": download returned no rows -- check the table name is ",
         "still current at https://wwwn.cdc.gov/nchs/nhanes/search/datapage.aspx",
         "?Cycle=2017-2020, and that this machine can reach wwwn.cdc.gov.")
  }
  saveRDS(dat, cache_path)
  message(table_name, ": saved ", nrow(dat), " rows to ", cache_path)
  invisible(dat)
}

#' Download (or load from cache) every table this analysis needs and return
#' them as a named list, keyed by table name.
load_all_nhanes_tables <- function(raw_dir = "data/raw", force_refresh = FALSE) {
  tabs <- lapply(tables_needed, download_nhanes_table, raw_dir = raw_dir,
                  force_refresh = force_refresh)
  names(tabs) <- tables_needed
  tabs
}

if (sys.nframe() == 0) {
  # Only runs when this script is Source()'d directly (Rscript
  # R/download_data.R), not when it's sourced from inside analysis.Rmd's
  # setup chunk -- there we just want the functions defined, not an
  # immediate download.
  invisible(load_all_nhanes_tables())
}
