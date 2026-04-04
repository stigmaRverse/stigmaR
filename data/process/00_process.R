# 00_process.R
# Master run script — execute this to fully rebuild all package datasets.
# Run from the package root directory (where stigmaR.Rproj lives).
#
# Order matters:
#   1. Source-specific scripts (02_, 03_, ...) clean raw data → .Rds in data/clean/
#   2. 01_master.R joins all sources → bakes composite + items into the package
#   3. devtools::load_all() reloads the package with fresh data
#
# Future sources: add their script below before 01_master.R, following the
# same pattern as 02_iat_sexuality.R.

pacman::p_load(here, devtools)

# ── Step 1: Source-specific cleaning scripts ──────────────────────────────────
source(here("data/process/02_iat_sexuality.R"))   # ~2-3 min
# source(here("data/process/03_iat_race.R"))      # placeholder
# source(here("data/process/04_map.R"))           # placeholder

# ── Step 2: Join all sources and bake into package ────────────────────────────
source(here("data/process/01_master.R"))

# ── Step 3: Reload package with fresh data ────────────────────────────────────
devtools::load_all()

message("Full pipeline complete. Package reloaded with updated datasets.")
