# Calculate State-Level Stigma Scores

Merges state-level structural stigma indicators into your dataset based
on Movement Advancement Project (MAP) policy data.

## Usage

``` r
stigmaR(df, state_name, indicator, new_var)
```

## Arguments

- df:

  A data frame containing your data

- state_name:

  Character string specifying the column name in `df` that contains
  state abbreviations (e.g., "IL", "CA")

- indicator:

  Character string specifying which stigma indicator to use. Options
  are:

  - `"map_total"`: Total stigma score across all policies

  - `"map_sex"`: Sexual orientation-specific policies only

  - `"map_gender"`: Gender identity-specific policies only

- new_var:

  Character string specifying the name of the new variable to create in
  `df` containing the stigma scores

## Value

The input data frame `df` with an additional column containing
state-level stigma scores. Unmatched states will have NA values.

## Details

This function matches state abbreviations in your data to pre-calculated
stigma scores based on MAP policy data. States not found in the
reference data will be assigned NA and a warning will be displayed
showing which states were not matched.

## Examples

``` r
if (FALSE) { # \dontrun{
# Add total stigma scores
my_data <- stigmaR(
  df = my_data,
  state_name = "state",
  indicator = "map_total",
  new_var = "stigma_score"
)

# Add sexual orientation-specific scores
my_data <- stigmaR(
  df = my_data,
  state_name = "state_abbrev",
  indicator = "map_sex",
  new_var = "so_stigma"
)
} # }
```
