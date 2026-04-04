# 02_iat_sexuality.R
# Purpose: Raw IAT sexuality files → item means → composite indices
# Outputs:
#   data/clean/iat_sexuality_items.Rds    (state × year, all piat_ items + n_)
#   data/clean/iat_sexuality_indices.Rds  (state × year, composite scores + n_)

pacman::p_load(tidyverse, here, readr, haven)

folder_path <- here("data/raw/iat/sexuality")

# ── Valid US states + DC only ─────────────────────────────────────────────────
us_states_dc <- c(
  "AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID","IL","IN",
  "IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
  "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT",
  "VT","VA","WA","WV","WI","WY"
)

# ── Read all raw files ────────────────────────────────────────────────────────
csv_files <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE, recursive = TRUE)
sav_files <- list.files(folder_path, pattern = "\\.sav$", full.names = TRUE, recursive = TRUE)

all_files <- c(
  set_names(map(csv_files, read_csv), tools::file_path_sans_ext(basename(csv_files))),
  set_names(map(sav_files, read_sav), tools::file_path_sans_ext(basename(sav_files)))
)

# ── Helper: safely grab a column or return NAs ───────────────────────────────
grab <- function(df, col) {
  if (col %in% names(df)) df[[col]] else rep(NA_real_, nrow(df))
}

# ── Clean one year-file to state-year item means ─────────────────────────────
clean_one_year <- function(df) {
  # Normalize all column names to lowercase to handle casing differences
  # across years (.csv vs .sav) and Project Implicit naming conventions
  names(df) <- tolower(names(df))

  df |>
    filter(!is.na(state)) |>
    mutate(
      # Implicit ---------------------------------------------------------------
      piat_imp_straight_good     = grab(pick(everything()), "d_biep.straight_good_all"),

      # Explicit: Attitude -----------------------------------------------------
      piat_exp_att_straight_pref = grab(pick(everything()), "att_7"),

      # Explicit: Thermometer (reversed: higher = more stigma) ----------------
      piat_exp_therm_gaymen   = 10 - grab(pick(everything()), "tgaymen"),
      piat_exp_therm_gaywomen = 10 - coalesce(
        grab(pick(everything()), "tgayleswomen"),
        grab(pick(everything()), "tgaywomen")
      ),

      # Explicit: Policy (0 = low stigma, 1 = high stigma, NA = no opinion) ---
      piat_exp_pol_marriagerights = coalesce(
        case_when(
          grab(pick(everything()), "marriagerights_3num") == 1 ~ 0,
          grab(pick(everything()), "marriagerights_3num") == 2 ~ 1,
          grab(pick(everything()), "marriagerights_3num") == 3 ~ NA_real_
        ),
        case_when(
          grab(pick(everything()), "marriagerights_3") == 0 ~ 1,
          grab(pick(everything()), "marriagerights_3") == 1 ~ 0,
          grab(pick(everything()), "marriagerights_3") == 2 ~ NA_real_
        )
      ),

      piat_exp_pol_relationslegal = coalesce(
        case_when(
          grab(pick(everything()), "relationslegal_3num") == 1 ~ 0,
          grab(pick(everything()), "relationslegal_3num") == 2 ~ 1,
          grab(pick(everything()), "relationslegal_3num") == 3 ~ NA_real_
        ),
        case_when(
          grab(pick(everything()), "relationslegal_3") == 0 ~ 1,
          grab(pick(everything()), "relationslegal_3") == 1 ~ 0,
          grab(pick(everything()), "relationslegal_3") == 2 ~ NA_real_
        )
      ),

      piat_exp_pol_adoptchild = case_when(
        grab(pick(everything()), "adoptchild") == 1 ~ 0,
        grab(pick(everything()), "adoptchild") == 2 ~ 1,
        grab(pick(everything()), "adoptchild") == 3 ~ NA_real_
      ),

      piat_exp_pol_serverights = case_when(
        grab(pick(everything()), "serverights") == 1 ~ 1,
        grab(pick(everything()), "serverights") == 2 ~ 0,
        grab(pick(everything()), "serverights") == 3 ~ NA_real_
      ),

      piat_exp_pol_transgender = case_when(
        grab(pick(everything()), "transgender") == 1 ~ 1,
        grab(pick(everything()), "transgender") == 2 ~ 0
      ),

      # Explicit: Belief -------------------------------------------------------
      piat_exp_bel_sexorigin = grab(pick(everything()), "sexualityorigin")
    ) |>
    group_by(year, state) |>
    summarise(
      # Counts FIRST — outputs to n_{.col} so original column names are preserved
      across(
        c(piat_imp_straight_good,
          piat_exp_att_straight_pref,
          piat_exp_therm_gaymen, piat_exp_therm_gaywomen,
          piat_exp_pol_marriagerights, piat_exp_pol_relationslegal,
          piat_exp_pol_adoptchild, piat_exp_pol_serverights,
          piat_exp_pol_transgender,
          piat_exp_bel_sexorigin),
        ~ sum(!is.na(.x)),
        .names = "n_{.col}"
      ),
      # Means SECOND — now safe to overwrite column names with {.col}
      across(
        c(piat_imp_straight_good,
          piat_exp_att_straight_pref,
          piat_exp_therm_gaymen, piat_exp_therm_gaywomen,
          piat_exp_pol_marriagerights, piat_exp_pol_relationslegal,
          piat_exp_pol_adoptchild, piat_exp_pol_serverights,
          piat_exp_pol_transgender,
          piat_exp_bel_sexorigin),
        ~ mean(.x, na.rm = TRUE),
        .names = "{.col}"
      ),
      .groups = "drop"
    ) |>
    # Strip <labelled> class from .sav imports, normalize, keep 50 states + DC
    mutate(state = toupper(trimws(as.character(haven::zap_labels(state))))) |>
    filter(state %in% us_states_dc)
}

# ── Build item-level dataset ──────────────────────────────────────────────────
iat_sexuality_items <- all_files |>
  map_dfr(clean_one_year)

# ── Build composite-level dataset ─────────────────────────────────────────────
# n_ columns: carry forward the smallest constituent n per composite
# so that stigmaR()'s min_n filter has a conservative count to work with
iat_sexuality_indices <- iat_sexuality_items |>
  mutate(
    # Implicit -----------------------------------------------------------------
    implicit = piat_imp_straight_good,
    n_implicit = n_piat_imp_straight_good,

    # Explicit: Thermometer ----------------------------------------------------
    explicit_therm = rowMeans(
      pick(piat_exp_therm_gaymen, piat_exp_therm_gaywomen),
      na.rm = TRUE
    ),
    n_explicit_therm = pmin(n_piat_exp_therm_gaymen, n_piat_exp_therm_gaywomen, na.rm = TRUE),

    # Explicit: Policy ---------------------------------------------------------
    explicit_pol = rowMeans(
      pick(piat_exp_pol_marriagerights, piat_exp_pol_relationslegal,
           piat_exp_pol_adoptchild,    piat_exp_pol_serverights,
           piat_exp_pol_transgender),
      na.rm = TRUE
    ),
    n_explicit_pol = pmin(
      n_piat_exp_pol_marriagerights, n_piat_exp_pol_relationslegal,
      n_piat_exp_pol_adoptchild,    n_piat_exp_pol_serverights,
      n_piat_exp_pol_transgender,
      na.rm = TRUE
    ),

    # Explicit: Belief ---------------------------------------------------------
    explicit_bel = piat_exp_bel_sexorigin,
    n_explicit_bel = n_piat_exp_bel_sexorigin,

    # Explicit: Omnibus --------------------------------------------------------
    explicit = rowMeans(
      pick(piat_exp_therm_gaymen,      piat_exp_therm_gaywomen,
           piat_exp_pol_marriagerights, piat_exp_pol_relationslegal,
           piat_exp_pol_adoptchild,    piat_exp_pol_serverights,
           piat_exp_pol_transgender,   piat_exp_bel_sexorigin),
      na.rm = TRUE
    ),
    n_explicit = pmin(
      n_piat_exp_therm_gaymen,      n_piat_exp_therm_gaywomen,
      n_piat_exp_pol_marriagerights, n_piat_exp_pol_relationslegal,
      n_piat_exp_pol_adoptchild,    n_piat_exp_pol_serverights,
      n_piat_exp_pol_transgender,   n_piat_exp_bel_sexorigin,
      na.rm = TRUE
    )
  ) |>
  select(
    state, year,
    implicit,       n_implicit,
    explicit_therm, n_explicit_therm,
    explicit_pol,   n_explicit_pol,
    explicit_bel,   n_explicit_bel,
    explicit,       n_explicit
  )

# ── Save ──────────────────────────────────────────────────────────────────────
saveRDS(iat_sexuality_items,   here("data/clean/iat_sexuality_items.Rds"))
saveRDS(iat_sexuality_indices, here("data/clean/iat_sexuality_indices.Rds"))

message("02_iat_sexuality.R complete: ",
        nrow(iat_sexuality_items), " state-year rows written.")
