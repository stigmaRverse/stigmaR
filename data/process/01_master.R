# 01_master.R
# Purpose: Join all cleaned source datasets → produce package datasets
# Outputs:
#   data/final/items.rda      → used by cust_stigmaR() (individual items)
#   data/final/composite.rda  → used by stigmaR()      (composite indices)
#   Also baked into package via usethis::use_data()

pacman::p_load(tidyverse, here)

# ── Load cleaned source datasets ─────────────────────────────────────────────
iat_sex_items   <- readRDS(here("data/clean/iat_sexuality_items.Rds"))
iat_sex_indices <- readRDS(here("data/clean/iat_sexuality_indices.Rds"))
# iat_black_items   <- readRDS(here("data/clean/iat_race_items.Rds"))
# iat_black_indices <- readRDS(here("data/clean/iat_race_indices.Rds"))
# map_items         <- readRDS(here("data/clean/map_items.Rds"))
# map_indices       <- readRDS(here("data/clean/map_indices.Rds"))

# ── Merge all item-level sources ──────────────────────────────────────────────
# full_join preserves all state-years even when a source lacks coverage
items <- iat_sex_items
# |> full_join(iat_black_items, by = c("state", "year"))
# |> full_join(map_items,       by = c("state", "year"))

# ── Merge all composite-level sources ────────────────────────────────────────
composite <- iat_sex_indices
# |> full_join(iat_black_indices, by = c("state", "year"))
# |> full_join(map_indices,       by = c("state", "year"))

# ── Validate ──────────────────────────────────────────────────────────────────
stopifnot(
  "state must be two-letter code" =
    all(nchar(items$state) == 2, na.rm = TRUE),
  "items and composite must have same state-year rows" =
    nrow(items) == nrow(composite)
)

# ── Save final .rda files ─────────────────────────────────────────────────────
save(items,     file = here("data/final/items.rda"))
save(composite, file = here("data/final/composite.rda"))

# ── Bake into stigmaR package ─────────────────────────────────────────────────
# stigmaR()      → composite
# cust_stigmaR() → items
usethis::use_data(composite, items,
                  overwrite = TRUE, compress = "xz")

message("01_master.R complete.",
        "\n  composite: ", nrow(composite), " rows, ", ncol(composite), " cols",
        "\n  items:     ", nrow(items),     " rows, ", ncol(items),     " cols")
