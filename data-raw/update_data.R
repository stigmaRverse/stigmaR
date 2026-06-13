# data-raw/update_data.R
# Purpose: Download composite.rda and items.rda from the stigmaRdata GitHub
#          repo (data/release_data/) and bake them into the stigmaR package.
#
# Run this script manually whenever stigmaRdata has been updated:
#
#   source("data-raw/update_data.R")
#
# Then rebuild the package (devtools::document(), devtools::build()) and push
# to GitHub.
#
# To pin to a specific tag or commit instead of the latest main branch,
# change REF below (e.g., REF <- "v1.0.0" or a commit SHA). Pinning is
# recommended for reproducibility.

pacman::p_load(usethis)

# ── Config ───────────────────────────────────────────────────────────────────
REPO <- "stigmaRverse/stigmaRdata"
REF  <- "main"   # branch, tag, or commit SHA
BASE <- paste0("https://raw.githubusercontent.com/", REPO, "/", REF, "/data/release_data")

# ── Download ─────────────────────────────────────────────────────────────────
tmp_composite <- tempfile(fileext = ".rda")
tmp_items     <- tempfile(fileext = ".rda")

message("Downloading composite.rda from ", REPO, " (", REF, ")...")
download.file(paste0(BASE, "/composite.rda"), destfile = tmp_composite, mode = "wb")

message("Downloading items.rda from ", REPO, " (", REF, ")...")
download.file(paste0(BASE, "/items.rda"), destfile = tmp_items, mode = "wb")

# ── Load into environment ───────────────────────────────────────────────────
load(tmp_composite)   # loads `composite`
load(tmp_items)       # loads `items`

message("composite : ", nrow(composite), " rows, ", ncol(composite), " cols")
message("items     : ", nrow(items),     " rows, ", ncol(items),     " cols")

# ── Bake into package ─────────────────────────────────────────────────────────
usethis::use_data(composite, items,
                  overwrite = TRUE, compress = "xz")

message("\nDone. Run devtools::document() then devtools::build() to finalize.")
