# Build a Custom Sum-Score Composite Index

Lets you combine individual items from the bundled `items` dataset into
your own sum-score composite(s), merged into your data by state and
year. Each composite is the row-wise sum of the items you choose,
computed within a single year (you cannot mix items from different years
into one composite). To merge individual items without combining them,
see
[`item_stigmaR()`](https://stigmaRverse.github.io/stigmaR/reference/item_stigmaR.md).

## Usage

``` r
cust_stigmaR(df, state, year, cust_index, var_name, na_rm = FALSE)
```

## Arguments

- df:

  A data frame containing your data.

- state:

  Character string. Name of the column in `df` containing two-letter
  state abbreviations (e.g., "IL", "CA").

- year:

  Character vector. Years to merge in (e.g., `c("2016", "2017")`). Each
  custom index is computed separately for each requested year and added
  as a column named `YYYY_varname`.

- cust_index:

  A character vector of item names to sum into a single custom index, or
  a list of such character vectors to build multiple custom indices at
  once. Valid item names are determined automatically from the columns
  of the bundled `items` dataset (every `iat_sex_*` mean column,
  excluding the `iat_sex_n_*` respondent-count columns). See
  `names(stigmaR::items)` for the full, current list.

- var_name:

  Character vector of names for the new column(s), one per group in
  `cust_index` (i.e., `length(var_name)` must equal
  `length(cust_index)`, or be `1` if `cust_index` is a single vector).

- na_rm:

  Logical. If `FALSE` (default), a composite is `NA` for a given
  state-year if *any* of its component items are `NA` for that
  state-year. If `TRUE`, the composite is the sum of whatever component
  items are non-missing (and `NA` only if *all* are missing).

## Value

The input data frame with new columns named `YYYY_varname` containing
the summed custom index for each requested year and `var_name`.

## References

Kim, S. & Todd, N. R. (2027). stigmaR: Enhancing Accessibility,
Reproducibility, and Transparency of Structural Stigma Research.

## Examples

``` r
if (FALSE) { # \dontrun{
# One custom index
new_df <- cust_stigmaR(
  df         = my_data,
  state      = "state_abbrev",
  year       = c("2016", "2017"),
  cust_index = c("iat_sex_imp_d", "iat_sex_exp_therm_gm"),
  var_name   = "my_custom_index"
)

# Multiple custom indices at once
new_df <- cust_stigmaR(
  df         = my_data,
  state      = "state_abbrev",
  year       = "2016",
  cust_index = list(
    c("iat_sex_imp_d", "iat_sex_exp_therm_gm"),
    c("iat_sex_exp_pol_marr", "iat_sex_exp_pol_legal", "iat_sex_exp_pol_adopt")
  ),
  var_name   = c("implicit_plus_therm", "policy_sum")
)
} # }
```
