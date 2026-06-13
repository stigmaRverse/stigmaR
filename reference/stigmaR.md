# Calculate Structural Stigma Scores

Merges state- and year-level structural indices derived from publicly
available data into your dataset. You can find all available indices in
[stigmaRdata](https://stigmaRverse.github.io/stigmaR/reference/stigmaRverse.github.io/stigmaRdata).

## Usage

``` r
stigmaR(df, state, index, year)
```

## Arguments

- df:

  A data frame containing your data.

- state:

  Character string. Name of the column in `df` containing two-letter
  state abbreviations (e.g., "IL", "CA").

- index:

  Character vector. One or more composite indices to merge in. The set
  of valid indices is determined automatically from the columns of the
  bundled `composite` dataset (every column except `state` and `year`).
  Examples include:

  - `"iat_sex_implicit"`: IAT D-score (implicit pro-straight bias;
    higher = more stigma)

  - `"iat_sex_explicit_pol"`: Average of policy opposition items
    (marriage rights, relations legality, adoption, service refusal,
    transgender bathroom)

  See `names(stigmaR::composite)` for the full, current list.

- year:

  Character vector. Years to merge in (e.g., `c("2016", "2017")`). Each
  year x index combination becomes one new column named
  `YYYY_iat_sex_implicit` (as an exeample).

## Value

The input data frame with new columns named `YYYY_iat_sex_implicit`
containing matched state-level stigma scores for each requested year and
index.

## References

Kim, S. & Todd, N. R. (2027). stigmaR: Enhancing Accessibility,
Reproducibility, and Transparency of Structural Stigma Research.

## Examples

``` r
if (FALSE) { # \dontrun{
new_df <- stigmaR(
  df    = my_data,
  state = "state_abbrev",
  index = c("iat_sex_implicit", "iat_sex_explicit_pol"),
  year  = c("2016", "2017")
)
} # }
```
