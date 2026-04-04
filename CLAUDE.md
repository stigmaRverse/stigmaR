# CLAUDE.md — stigmaR Project Context

This file provides context for AI-assisted development sessions so you don't need to re-explain the project from scratch.

---

## What is stigmaR?

`stigmaR` is an R package that gives researchers pre-computed, state-level structural stigma scores derived from Project Implicit IAT data. Users merge these scores into their own dataframes using simple function calls. The package ships two internal datasets (`composite` and `items`) baked in via `usethis::use_data()`.

- **`stigmaR()`** — merges composite indices (pre-averaged scores) into a user dataframe
- **`cust_stigmaR()`** — NOT YET BUILT; will let users build their own indices from raw items using a sum of their choosing

---

## Repository Structure

```
stigmaR/
├── R/
│   ├── stigmaR.R           # stigmaR() function (built)
│   └── stigmaR-package.R   # package-level docs
├── data/
│   ├── composite.rda       # baked-in composite indices (used by stigmaR)
│   └── items.rda           # baked-in individual items (for future cust_stigmaR)
├── data/process/           # data pipeline scripts (NOT part of package)
│   ├── 02_iat_sexuality.R  # raw IAT files → clean items + indices → .Rds
│   └── 01_master.R         # joins all sources → saves composite + items → use_data()
└── data/clean/             # intermediate .Rds files (git-ignored)
    ├── iat_sexuality_items.Rds
    └── iat_sexuality_indices.Rds
```

Raw data lives at `data/raw/iat/sexuality/` (git-ignored). It contains yearly `.csv` and `.sav` files from Project Implicit's sexuality IAT public dataset.

---

## Data Pipeline

Always run in this exact order when raw data changes:

```r
source(here("data/process/02_iat_sexuality.R"))  # ~2-3 min, reads all raw files
source(here("data/process/01_master.R"))          # bakes composite + items into package
devtools::load_all()                              # reloads package with fresh data
```

`02_iat_sexuality.R` outputs two `.Rds` files: one with individual item means per state-year (`iat_sexuality_items`) and one with composite indices per state-year (`iat_sexuality_indices`). `01_master.R` joins all sources (currently only IAT sexuality) and calls `usethis::use_data(composite, items, overwrite = TRUE)`.

---

## composite dataset

Shape: one row per (state × year), 12 columns.

| Column | Description |
|---|---|
| `state` | Two-letter US state code (50 states + DC only) |
| `year` | 4-digit integer year |
| `implicit` | IAT D-score (implicit pro-straight bias; higher = more stigma) |
| `n_implicit` | Respondent count for implicit |
| `explicit_therm` | Mean of gay men + gay women thermometers (reversed: higher = more stigma) |
| `n_explicit_therm` | Min respondent count across constituent items |
| `explicit_pol` | Mean of 5 policy opposition items |
| `n_explicit_pol` | Min respondent count across constituent items |
| `explicit_bel` | Belief that sexuality is environmental (higher = more stigma) |
| `n_explicit_bel` | Respondent count for belief item |
| `explicit` | Omnibus mean across all explicit items |
| `n_explicit` | Min respondent count across all explicit items |

`n_` columns use `pmin()` across constituent item counts — conservative for `min_n` filtering.

---

## items dataset

Shape: one row per (state × year), 22 columns. Contains all individual `piat_*` item means plus their `n_` counts. This is what `cust_stigmaR()` will draw from.

Individual items:
- `piat_imp_straight_good` — IAT D-score
- `piat_exp_att_straight_pref` — explicit attitude (att_7)
- `piat_exp_therm_gaymen` — gay men thermometer (reversed)
- `piat_exp_therm_gaywomen` — gay women thermometer (reversed)
- `piat_exp_pol_marriagerights` — marriage rights opposition
- `piat_exp_pol_relationslegal` — relations legality opposition
- `piat_exp_pol_adoptchild` — adoption opposition
- `piat_exp_pol_serverights` — service refusal support
- `piat_exp_pol_transgender` — transgender bathroom opposition
- `piat_exp_bel_sexorigin` — belief sexuality is environmental

---

## stigmaR() — Built

Merges composite indices into a user dataframe. Adds columns named `YYYY_indexname`.

```r
new_df <- stigmaR(
  df    = DATAFRAME,
  state = "col_name",          # column in df with two-letter state codes
  index = c("implicit",        # one or more composite indices (see valid list below)
             "explicit_pol"),
  year  = c("2015", "2016"),   # one or more years as character strings
  min_n = 30                   # optional; cells with fewer respondents → NA
)
# Adds: 2015_implicit, 2016_implicit, 2015_explicit_pol, 2016_explicit_pol
```

Valid `index` values: `"implicit"`, `"explicit_therm"`, `"explicit_pol"`, `"explicit_bel"`, `"explicit"`

The function validates state codes, warns on unrecognized codes or unavailable years, prints a coverage table, and returns the original df with new columns appended.

---

## cust_stigmaR() — NOT YET BUILT

Planned function for users to build custom indices from individual items in the `items` dataset using a sum (not mean) of their chosen items.

```r
new_df <- cust_stigmaR(
  df         = DATAFRAME,
  state      = "col_name",              # two-letter state code column in df
  year       = "2015",                  # one year at a time
  cust_index = c("piat_imp_straight_good",   # individual items to sum
                 "piat_exp_therm_gaymen"),
  var_name   = "my_custom_index"        # name for the new column
  # number of var_names must equal number of cust_index groupings
)
```

Uses `items.rda` internally. Users define which individual items to combine and what to call the result.

---

## Key Technical Notes

**Column name casing:** Raw Project Implicit `.sav` and `.csv` files have inconsistent casing across years (e.g., `STATE` vs `state`, `D_biep.Straight_Good_all` vs `d_biep.straight_good_all`). `clean_one_year()` applies `names(df) <- tolower(names(df))` as its first line to normalize everything.

**`across()` order in `summarise()`:** Counts (`n_` columns) MUST be computed before means within the same `summarise()` call. dplyr evaluates expressions sequentially — if means are computed first using `.names = "{.col}"` (overwriting original column names), the subsequent count `across()` operates on scalar means instead of group data, returning `n = 1` for all non-NaN values. The fix: always put the counts `across()` first.

**`haven_labelled` class:** `.sav` files from SPSS carry metadata labels on columns. Use `as.character(unclass(col))` or `haven::zap_labels(col)` before string matching. The `composite$state` column retains this class after `use_data()` — `stigmaR()` strips it with `as.character(unclass(state))` when preparing the reference lookup.

**`min_n` filtering:** `stigmaR()` sets scores to `NA` for state-year cells where the respondent count falls below `min_n` (default 30). If scores are all NA, check that the `n_` columns in `composite` have real counts (hundreds+), not 1s — which would indicate the pipeline's `across()` order bug has reappeared.

**Territory exclusion:** `clean_one_year()` filters to 50 US states + DC using the `us_states_dc` vector defined at the top of `02_iat_sexuality.R`. Territories (GU, PR, VI, AS) and military codes (AA, AE, AP) are dropped.

---

## Development Workflow

```r
# Load package for development (no full install needed)
devtools::load_all()

# After editing R/ files, reload:
devtools::load_all()

# After changing data pipeline, always run all three:
source(here("data/process/02_iat_sexuality.R"))
source(here("data/process/01_master.R"))
devtools::load_all()

# Rebuild docs
devtools::document()
```

---

## Future Data Sources (planned, not yet built)

Additional stigma indices from other sources will follow the same pattern: each source gets its own `0X_sourcename.R` script that outputs `sourcename_items.Rds` and `sourcename_indices.Rds` to `data/clean/`. `01_master.R` then `full_join`s all sources by `(state, year)` before calling `use_data()`.

Planned sources:
- IAT race (parallel structure to sexuality)
- MAP (Movement Advancement Project) — policy climate scores
