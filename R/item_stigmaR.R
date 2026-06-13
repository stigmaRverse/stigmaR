#' Calculate State-Level Individual Item Scores
#'
#' Merges state- and year-level *individual item* scores - the building
#' blocks behind the composite indices in [stigmaR()] - into your dataset.
#' Use this when you want full flexibility to work with individual items
#' (e.g., to build and compare your own composites). To create a single
#' summed composite column directly, see [cust_stigmaR()].
#'
#' @param df A data frame containing your data.
#' @param state Character string. Name of the column in `df` containing
#'   two-letter state abbreviations (e.g., "IL", "CA").
#' @param item Character vector. One or more individual items to merge in.
#'   The set of valid items is determined automatically from the columns of
#'   the bundled `items` dataset (every `iat_sex_*` mean column, excluding
#'   the `iat_sex_n_*` respondent-count columns). See
#'   `names(stigmaR::items)` for the full, current list.
#' @param year Character vector. Years to merge in (e.g., `c("2016", "2017")`).
#'   Each year x item combination becomes one new column named
#'   `YYYY_itemname` (as an example).
#'
#' @return The input data frame with new columns named `YYYY_itemname`
#'   containing matched state-level item scores for each requested year and
#'   item.
#'
#' @details
#' To keep merges manageable, a single call is limited to 100 new columns
#' (i.e., `length(item) * length(year)`). If you need more than that, split
#' the request into multiple calls.
#'
#' @references
#' Kim, S. & Todd, N. R. (2027). stigmaR: Enhancing Accessibility,
#' Reproducibility, and Transparency of Structural Stigma Research.
#'
#' @examples
#' \dontrun{
#' new_df <- item_stigmaR(
#'   df    = my_data,
#'   state = "state_abbrev",
#'   item  = c("iat_sex_imp_d", "iat_sex_exp_therm_gm"),
#'   year  = c("2016", "2017")
#' )
#' }
#'
#' @export
item_stigmaR <- function(df, state, item, year) {
  # ── Valid inputs ─────────────────────────────────────────────────────────────
  valid_states  <- c(
    "AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID","IL","IN",
    "IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
    "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT",
    "VT","VA","WA","WV","WI","WY"
  )
  # Valid items are read directly from `items`, excluding state/year and the
  # iat_sex_n_* respondent-count columns.
  item_cols   <- setdiff(names(items), c("state", "year"))
  valid_items <- item_cols[!startsWith(item_cols, "iat_sex_n_")]
  # ── Input validation ─────────────────────────────────────────────────────────
  if (!is.data.frame(df))
    stop("`df` must be a data frame.")
  if (!is.character(state) || length(state) != 1)
    stop("`state` must be a single character string naming a column in `df`.")
  if (!state %in% names(df))
    stop(paste0("Column '", state, "' not found in `df`."))
  if (!is.character(item) || length(item) == 0)
    stop("`item` must be a non-empty character vector.")
  if (!is.character(year) || length(year) == 0)
    stop("`year` must be a non-empty character vector.")
  bad_item <- setdiff(item, valid_items)
  if (length(bad_item) > 0)
    stop(paste0(
      "Invalid item value(s): ", paste(bad_item, collapse = ", "),
      "\nMust be one of: ", paste(valid_items, collapse = ", ")
    ))
  # ── Reasonable size limit ───────────────────────────────────────────────────
  max_cols <- 100
  n_new_cols <- length(item) * length(year)
  if (n_new_cols > max_cols)
    stop(paste0(
      "This request would create ", n_new_cols, " new column(s) ",
      "(length(item) x length(year)), which exceeds the limit of ", max_cols, ".\n",
      "Reduce the number of items/years, or split the request into multiple calls."
    ))
  # ── Prepare items reference data ─────────────────────────────────────────────
  # as.character() on state strips haven <labelled> class from .sav-sourced data,
  # which would otherwise silently fail to match plain character state codes
  ref <- items |>
    dplyr::mutate(
      state = as.character(unclass(state)),
      year  = as.character(unclass(year))
    )
  available_years <- unique(ref$year)
  # ── Characterize user states ──────────────────────────────────────────────────
  user_states       <- unique(as.character(df[[state]]))
  user_states       <- user_states[!is.na(user_states)]
  invalid_states    <- setdiff(user_states, valid_states)
  valid_user_states <- intersect(user_states, valid_states)
  # ── Header ───────────────────────────────────────────────────────────────────
  cat("\n")
  cat("================================================================\n")
  cat("  item_stigmaR: State-Level Individual Item Scores             \n")
  cat("================================================================\n")
  cat(sprintf("  stigmaR version : %s\n", packageVersion("stigmaR")))
  cat(sprintf("  Items           : %s\n", paste(item, collapse = ", ")))
  cat(sprintf("  Years           : %s\n", paste(year, collapse = ", ")))
  cat("----------------------------------------------------------------\n")
  cat("  PLEASE CITE:\n")
  cat("  Kim, S. & Todd, N. R. (2027). stigmaR: Enhancing\n")
  cat("    Accessibility, Reproducibility, and Transparency of\n")
  cat("    Structural Stigma Research.\n")
  cat("  Greenwald, A. G., Nosek, B. A., & Banaji, M. R. (2003).\n")
  cat("    Understanding and using the Implicit Association Test.\n")
  cat("    J. Personality & Social Psychology, 85(2), 197-216.\n")
  cat("    https://doi.org/10.1037/0022-3514.85.2.197\n")
  cat("----------------------------------------------------------------\n\n")
  # ── Warnings: invalid state codes ─────────────────────────────────────────────
  if (length(invalid_states) > 0) {
    cat("  [!] UNRECOGNIZED STATE CODES (rows will receive NA):\n")
    cat(sprintf("      %s\n", paste(sort(invalid_states), collapse = ", ")))
    cat("      State codes must be 2-letter US abbreviations (e.g. 'IL').\n\n")
  }
  # ── Warnings: unavailable years ───────────────────────────────────────────────
  unavailable_years <- setdiff(year, available_years)
  if (length(unavailable_years) > 0) {
    cat("  [!] REQUESTED YEARS NOT IN DATA (columns will be all NA):\n")
    cat(sprintf("      Requested but unavailable : %s\n",
                paste(sort(unavailable_years), collapse = ", ")))
    cat(sprintf("      Years available in data   : %s\n\n",
                paste(sort(available_years), collapse = ", ")))
  }
  # ── Merge loop ────────────────────────────────────────────────────────────────
  cat("  COLUMNS ADDED:\n")
  cat(sprintf("  %-32s  %-12s  %-10s  %s\n",
              "Column", "Matched", "Unmatched", "Notes"))
  cat(sprintf("  %s\n", strrep("-", 76)))
  for (it in item) {
    for (yr in year) {
      new_col <- paste0(yr, "_", it)
      # Year unavailable — all-NA column
      if (!yr %in% available_years) {
        cat(sprintf("  %-32s  %-12s  %-10s  %s\n",
                    new_col, "--", "--", "Year not in data; all NA"))
        df[[new_col]] <- NA_real_
        next
      }
      # Filter reference to this year
      ref_yr <- ref |>
        dplyr::filter(year == yr) |>
        dplyr::select(state, score = dplyr::all_of(it))
      # Coverage summary
      available_states <- ref_yr$state[!is.na(ref_yr$score)]
      matched          <- intersect(valid_user_states, available_states)
      unmatched        <- setdiff(valid_user_states, available_states)
      notes <- if (length(unmatched) > 0)
        paste0("No data: ", paste(sort(unmatched), collapse = ", "))
      else
        "OK"
      cat(sprintf("  %-32s  %-12s  %-10s  %s\n",
                  new_col,
                  paste0(length(matched), "/", length(valid_user_states)),
                  length(unmatched),
                  notes))
      # Merge by named lookup vector
      lookup        <- setNames(ref_yr$score, ref_yr$state)
      df[[new_col]] <- lookup[as.character(df[[state]])]
    }
  }
  # ── Footer ────────────────────────────────────────────────────────────────────
  cat("\n")
  cat("  Run citation('stigmaR') for full reference details.\n")
  cat("================================================================\n\n")
  return(df)
}
