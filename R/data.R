#' Composite Structural Stigma Indices
#'
#' State- and year-level composite (pre-averaged) structural stigma indices
#' derived from Project Implicit IAT data, covering the 50 US states and DC
#' from 2016 onward. Used internally by [stigmaR()].
#'
#' @format A data frame with 510 rows (51 states + DC x 10 years) and 6
#'   columns:
#' \describe{
#'   \item{state}{Two-letter US state code (50 states + DC only).}
#'   \item{year}{4-digit integer year.}
#'   \item{iat_sex_implicit}{IAT D-score (implicit pro-straight bias;
#'     higher = more stigma).}
#'   \item{iat_sex_explicit_therm}{Mean of gay men + lesbian women
#'     thermometers (reversed: higher = more stigma).}
#'   \item{iat_sex_explicit_pol}{Mean of 5 policy opposition items.}
#'   \item{iat_sex_explicit}{Omnibus mean across all explicit items
#'     (thermometer + policy).}
#' }
#'
#' @source \url{https://github.com/stigmaRverse/stigmaRdata}
"composite"

#' Individual Item Structural Stigma Scores
#'
#' State- and year-level individual item means and respondent counts
#' underlying the composite indices in [composite]. Used internally by
#' [item_stigmaR()] and [cust_stigmaR()].
#'
#' @format A data frame with 510 rows (51 states + DC x 10 years) and 20
#'   columns: `state`, `year`, 9 item-mean columns (`iat_sex_*`), and 9
#'   matching respondent-count columns (`iat_sex_n_*`):
#' \describe{
#'   \item{state}{Two-letter US state code (50 states + DC only).}
#'   \item{year}{4-digit integer year.}
#'   \item{iat_sex_imp_d}{IAT D-score (\code{d_biep.straight_good_all}).}
#'   \item{iat_sex_exp_att}{Explicit attitude item (\code{att_7}).}
#'   \item{iat_sex_exp_therm_gm}{Gay men thermometer (reversed).}
#'   \item{iat_sex_exp_therm_gw}{Lesbian women thermometer (reversed).}
#'   \item{iat_sex_exp_pol_marr}{Marriage rights opposition.}
#'   \item{iat_sex_exp_pol_legal}{Relations legality opposition.}
#'   \item{iat_sex_exp_pol_adopt}{Adoption opposition.}
#'   \item{iat_sex_exp_pol_serv}{Service refusal support.}
#'   \item{iat_sex_exp_pol_trans}{Transgender bathroom opposition.}
#'   \item{iat_sex_n_imp_d}{Respondent count for `iat_sex_imp_d`.}
#'   \item{iat_sex_n_exp_att}{Respondent count for `iat_sex_exp_att`.}
#'   \item{iat_sex_n_exp_therm_gm}{Respondent count for
#'     `iat_sex_exp_therm_gm`.}
#'   \item{iat_sex_n_exp_therm_gw}{Respondent count for
#'     `iat_sex_exp_therm_gw`.}
#'   \item{iat_sex_n_exp_pol_marr}{Respondent count for
#'     `iat_sex_exp_pol_marr`.}
#'   \item{iat_sex_n_exp_pol_legal}{Respondent count for
#'     `iat_sex_exp_pol_legal`.}
#'   \item{iat_sex_n_exp_pol_adopt}{Respondent count for
#'     `iat_sex_exp_pol_adopt`.}
#'   \item{iat_sex_n_exp_pol_serv}{Respondent count for
#'     `iat_sex_exp_pol_serv`.}
#'   \item{iat_sex_n_exp_pol_trans}{Respondent count for
#'     `iat_sex_exp_pol_trans`.}
#' }
#'
#' @source \url{https://github.com/stigmaRverse/stigmaRdata}
"items"
