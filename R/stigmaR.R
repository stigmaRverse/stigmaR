#' Calculate State-Level Stigma Scores from IAT Data
#'
#' Merges state- and year-level stigma indices derived from Project Implicit
#' IAT data into your dataset. New columns are added in the format
#' `YYYY_iat_sex_index`.
#'
#' @param df A data frame containing your data.
#' @param state Character string. Name of the column in `df` containing
#'   two-letter state abbreviations (e.g., "IL", "CA").
#' @param index Character vector. One or more composite indices to merge in.
#'   Options are:
#'   \itemize{
#'     \item `"iat_sex_implicit"`: IAT D-score (implicit pro-straight bias;
#'       higher = more stigma)
#'     \item `"iat_sex_explicit_therm"`: Average of gay men + lesbian women
#'       feeling thermometers (reversed so higher = more stigma)
#'     \item `"iat_sex_explicit_pol"`: Average of policy opposition items
#'       (marriage rights, relations legality, adoption, service refusal,
#'       transgender bathroom)
#'     \item `"iat_sex_explicit"`: Omnibus average across all explicit items
#'       (therm + pol)
#'   }
#' @param year Character vector. Years to merge in (e.g., `c("2016", "2017")`).
#'   Each year x index combination becomes one new column named
#'   `YYYY_iat_sex_index`. Data are available from 2016 onward.
#'
#' @return The input data frame with new columns named `YYYY_iat_sex_index`
#'   containing matched state-level stigma scores for each requested year
#'   and index.
#'
#' @references
#' Kim, S. & Todd, N. R. (2027). stigmaR: Enhancing Accessibility,
#' Reproducibility, and Transparency of Structural Stigma Research.
#'
#' Greenwald, A. G., Nosek, B. A., & Banaji, M. R. (2003). Understanding
#' and using the Implicit Association Test: I. An improved scoring algorithm.
#' \emph{Journal of Personality and Social Psychology}, 85(2), 197–216.
#' https://doi.org/10.1037/0022-3514.85.2.197
#'
#' @examples
#' \dontrun{
#' new_df <- stigmaR(
#'   df    = my_data,
#'   state = "state_abbrev",
#'   index = c("iat_sex_implicit", "iat_sex_explicit_pol"),
#'   year  = c("2016", "2017")
#' )
#' # Adds columns: 2016_iat_sex_implicit, 2017_iat_sex_implicit,
#' #               2016_iat_sex_explicit_pol, 2017_iat_sex_explicit_pol
#' }
#'
#' @export
stigmaR <- function(df, state, index, year) {

  # ── Valid inputs ─────────────────────────────────────────────────────────────
  valid_states  <- c(
    "AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID","IL","IN",
    "IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
    "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT",
    "VT","VA","WA","WV","WI","WY"
  )

  valid_indices <- c(
    "iat_sex_implicit",
    "iat_sex_explicit_therm",
    "iat_sex_explicit_pol",
    "iat_sex_explicit"
  )

  # ── Input validation ─────────────────────────────────────────────────────────
  if (!is.data.frame(df))
    stop("`df` must be a data frame.")
  if (!is.character(state) || length(state) != 1)
    stop("`state` must be a single character string naming a column in `df`.")
  if (!state %in% names(df))
    stop(paste0("Column '", state, "' not found in `df`."))
  if (!is.character(index) || length(index) == 0)
    stop("`index` must be a non-empty character vector.")
  if (!is.character(year) || length(year) == 0)
    stop("`year` must be a non-empty character vector.")

  bad_index <- setdiff(index, valid_indices)
  if (length(bad_index) > 0)
    stop(paste0(
      "Invalid index value(s): ", paste(bad_index, collapse = ", "),
      "\nMust be one of: ", paste(valid_indices, collapse = ", ")
    ))

  # ── Prepare composite reference data ─────────────────────────────────────────
  # as.character() on state strips haven <labelled> class from .sav-sourced data,
  # which would otherwise silently fail to match plain character state codes
  ref <- composite |>
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
  cat("  stigmaR: State-Level Structural Stigma Scores                \n")
  cat("================================================================\n")
  cat(sprintf("  stigmaR version : %s\n", packageVersion("stigmaR")))
  cat(sprintf("  Indices         : %s\n", paste(index, collapse = ", ")))
  cat(sprintf("  Years           : %s\n", paste(year,  collapse = ", ")))
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

  for (idx in index) {

    score_col <- idx               # composite column name in `composite`

    for (yr in year) {

      new_col <- paste0(yr, "_", idx)

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
        dplyr::select(state, score = dplyr::all_of(score_col))

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
