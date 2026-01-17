# R/stigmaR.R

#' Calculate State-Level Stigma Scores
#'
#' Merges state-level structural stigma indicators into your dataset based on
#' Movement Advancement Project (MAP) policy data.
#'
#' @param df A data frame containing your data
#' @param state_name Character string specifying the column name in `df` that
#'   contains state abbreviations (e.g., "IL", "CA")
#' @param indicator Character string specifying which stigma indicator to use.
#'   Options are:
#'   \itemize{
#'     \item `"map_total"`: Total stigma score across all policies
#'     \item `"map_sex"`: Sexual orientation-specific policies only
#'     \item `"map_gender"`: Gender identity-specific policies only
#'   }
#' @param new_var Character string specifying the name of the new variable to
#'   create in `df` containing the stigma scores
#'
#' @return The input data frame `df` with an additional column containing
#'   state-level stigma scores. Unmatched states will have NA values.
#'
#' @details
#' This function matches state abbreviations in your data to pre-calculated
#' stigma scores based on MAP policy data. States not found in the reference
#' data will be assigned NA and a warning will be displayed showing which
#' states were not matched.
#'
#' @examples
#' \dontrun{
#' # Add total stigma scores
#' my_data <- stigmaR(
#'   df = my_data,
#'   state_name = "state",
#'   indicator = "map_total",
#'   new_var = "stigma_score"
#' )
#'
#' # Add sexual orientation-specific scores
#' my_data <- stigmaR(
#'   df = my_data,
#'   state_name = "state_abbrev",
#'   indicator = "map_sex",
#'   new_var = "so_stigma"
#' )
#' }
#'
#' @export
stigmaR <- function(df, state_name, indicator, new_var) {

  # Avoid R CMD check notes for dplyr variables
  state <- raw_score <- orientation <- NULL

  # Input validation
  if (!is.data.frame(df)) {
    stop("`df` must be a data frame")
  }

  if (!is.character(state_name) || length(state_name) != 1) {
    stop("`state_name` must be a single character string")
  }

  if (!is.character(indicator) || length(indicator) != 1) {
    stop("`indicator` must be a single character string")
  }

  if (!is.character(new_var) || length(new_var) != 1) {
    stop("`new_var` must be a single character string")
  }

  if (!state_name %in% names(df)) {
    stop(paste0("Column '", state_name, "' not found in data frame"))
  }

  # Load internal stigma data (map_data stored in R/sysdata.rda)
  # Calculate state totals based on indicator
  if (indicator == "map_total") {
    state_totals <- map_data |>
      dplyr::group_by(state) |>
      dplyr::summarise(total_score = sum(raw_score, na.rm = TRUE), .groups = "drop")

  } else if (indicator == "map_sex") {
    state_totals <- map_data |>
      dplyr::group_by(state) |>
      dplyr::filter(orientation == "sexual_orientation") |>
      dplyr::summarise(total_score = sum(raw_score, na.rm = TRUE), .groups = "drop")

  } else if (indicator == "map_gender") {
    state_totals <- map_data |>
      dplyr::group_by(state) |>
      dplyr::filter(orientation == "gender_identity") |>
      dplyr::summarise(total_score = sum(raw_score, na.rm = TRUE), .groups = "drop")

  } else {
    stop("`indicator` must be one of: 'map_total', 'map_sex', or 'map_gender'")
  }

  # Get unique states from user's data
  user_states <- unique(df[[state_name]])
  user_states <- user_states[!is.na(user_states)]  # Remove NAs

  # Get available states in reference data
  available_states <- state_totals$state

  # Find matched and unmatched states
  matched_states <- intersect(user_states, available_states)
  unmatched_states <- setdiff(user_states, available_states)

  # Display matching information
  cat("\n")
  cat("================\n")
  cat(sprintf("INDICATOR       = %s\n", indicator))
  cat(sprintf("STATES USED     = %d/%d\n", length(matched_states), length(available_states)))

  if (length(unmatched_states) > 0) {
    cat(sprintf("ERRORS          = Unmatched states: %s\n", paste(unmatched_states, collapse = ", ")))
  } else {
    cat("ERRORS          = NONE\n")
  }

  cat(sprintf("stigmaR         = %s\n", packageVersion("stigmaR")))
  cat("================\n")
  cat("\n")

  # Create a named vector for matching
  state_lookup <- setNames(state_totals$total_score, state_totals$state)

  # Match and create new variable
  df[[new_var]] <- state_lookup[df[[state_name]]]

  return(df)
}
