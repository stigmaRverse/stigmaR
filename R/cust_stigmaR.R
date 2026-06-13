#' Build a Custom Sum-Score Composite Index
#'
#' Lets you combine individual items from the bundled `items` dataset into
#' your own sum-score composite(s), merged into your data by state and year.
#' Each composite is the row-wise sum of the items you choose, computed
#' within a single year (you cannot mix items from different years into one
#' composite). To merge individual items without combining them, see
#' [item_stigmaR()].
#'
#' @param df A data frame containing your data.
#' @param state Character string. Name of the column in `df` containing
#'   two-letter state abbreviations (e.g., "IL", "CA").
#' @param year Character vector. Years to merge in (e.g., `c("2016", "2017")`).
#'   Each custom index is computed separately for each requested year and
#'   added as a column named `YYYY_varname`.
#' @param cust_index A character vector of item names to sum into a single
#'   custom index, or a list of such character vectors to build multiple
#'   custom indices at once. Valid item names are determined automatically
#'   from the columns of the bundled `items` dataset (every `iat_sex_*` mean
#'   column, excluding the `iat_sex_n_*` respondent-count columns). See
#'   `names(stigmaR::items)` for the full, current list.
#' @param var_name Character vector of names for the new column(s), one per
#'   group in `cust_index` (i.e., `length(var_name)` must equal
#'   `length(cust_index)`, or be `1` if `cust_index` is a single vector).
#' @param na_rm Logical. If `FALSE` (default), a composite is `NA` for a
#'   given state-year if *any* of its component items are `NA` for that
#'   state-year. If `TRUE`, the composite is the sum of whatever component
#'   items are non-missing (and `NA` only if *all* are missing).
#'
#' @return The input data frame with new columns named `YYYY_varname`
#'   containing the summed custom index for each requested year and
#'   `var_name`.
#'
#' @references
#' Kim, S. & Todd, N. R. (2027). stigmaR: Enhancing Accessibility,
#' Reproducibility, and Transparency of Structural Stigma Research.
#'
#' @examples
#' \dontrun{
#' # One custom index
#' new_df <- cust_stigmaR(
#'   df         = my_data,
#'   state      = "state_abbrev",
#'   year       = c("2016", "2017"),
#'   cust_index = c("iat_sex_imp_d", "iat_sex_exp_therm_gm"),
#'   var_name   = "my_custom_index"
#' )
#'
#' # Multiple custom indices at once
#' new_df <- cust_stigmaR(
#'   df         = my_data,
#'   state      = "state_abbrev",
#'   year       = "2016",
#'   cust_index = list(
#'     c("iat_sex_imp_d", "iat_sex_exp_therm_gm"),
#'     c("iat_sex_exp_pol_marr", "iat_sex_exp_pol_legal", "iat_sex_exp_pol_adopt")
#'   ),
#'   var_name   = c("implicit_plus_therm", "policy_sum")
#' )
#' }
#'
#' @export
cust_stigmaR <- function(df, state, year, cust_index, var_name, na_rm = FALSE) {
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
  # ── Normalize cust_index / var_name ─────────────────────────────────────────
  if (!is.list(cust_index)) cust_index <- list(cust_index)
  if (!is.character(var_name))
    stop("`var_name` must be a character vector.")
  if (length(var_name) != length(cust_index))
    stop(paste0(
      "`var_name` must have one name per group in `cust_index` ",
      "(got ", length(var_name), " name(s) for ", length(cust_index), " group(s))."
    ))
  if (anyDuplicated(var_name) > 0)
    stop("`var_name` values must be unique.")
  # ── Input validation ─────────────────────────────────────────────────────────
  if (!is.data.frame(df))
    stop("`df` must be a data frame.")
  if (!is.character(state) || length(state) != 1)
    stop("`state` must be a single character string naming a column in `df`.")
  if (!state %in% names(df))
    stop(paste0("Column '", state, "' not found in `df`."))
  if (!is.character(year) || length(year) == 0)
    stop("`year` must be a non-empty character vector.")
  if (!is.logical(na_rm) || length(na_rm) != 1 || is.na(na_rm))
    stop("`na_rm` must be TRUE or FALSE.")
  for (i in seq_along(cust_index)) {
    grp <- cust_index[[i]]
    if (!is.character(grp) || length(grp) == 0)
      stop(paste0("`cust_index[[", i, "]]` must be a non-empty character vector of item names."))
    bad_item <- setdiff(grp, valid_items)
    if (length(bad_item) > 0)
      stop(paste0(
        "Invalid item value(s) in cust_index[[", i, "]]: ",
        paste(bad_item, collapse = ", "),
        "\nMust be one of: ", paste(valid_items, collapse = ", ")
      ))
    if (anyDuplicated(grp) > 0)
      stop(paste0("`cust_index[[", i, "]]` contains duplicate item names."))
  }
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
  cat("  cust_stigmaR: Custom Sum-Score Composite Indices              \n")
  cat("================================================================\n")
  cat(sprintf("  stigmaR version : %s\n", packageVersion("stigmaR")))
  for (i in seq_along(cust_index)) {
    cat(sprintf("  %-15s : %s = sum(%s)\n",
                if (i == 1) "Custom index(es)" else "",
                var_name[i], paste(cust_index[[i]], collapse = " + ")))
  }
  cat(sprintf("  Years           : %s\n", paste(year, collapse = ", ")))
  cat(sprintf("  na_rm           : %s\n", na_rm))
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
  for (yr in year) {
    for (i in seq_along(cust_index)) {
      grp     <- cust_index[[i]]
      new_col <- paste0(yr, "_", var_name[i])
      # Year unavailable — all-NA column
      if (!yr %in% available_years) {
        cat(sprintf("  %-32s  %-12s  %-10s  %s\n",
                    new_col, "--", "--", "Year not in data; all NA"))
        df[[new_col]] <- NA_real_
        next
      }
      # Filter reference to this year and sum the chosen items row-wise
      ref_yr <- ref |>
        dplyr::filter(year == yr) |>
        dplyr::select(state, dplyr::all_of(grp))
      item_mat   <- as.matrix(dplyr::select(ref_yr, dplyr::all_of(grp)))
      all_na     <- rowSums(!is.na(item_mat)) == 0
      ref_yr$score <- rowSums(item_mat, na.rm = na_rm)
      ref_yr$score[all_na] <- NA_real_
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
