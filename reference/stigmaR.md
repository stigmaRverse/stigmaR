# Calculate State-Level Stigma Scores from IAT Data

Merges state- and year-level stigma indices derived from Project
Implicit IAT data into your dataset. New columns are added in the format
`YYYY_iat_sex_index`.

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

  Character vector. One or more composite indices to merge in. Options
  are:

  - `"iat_sex_implicit"`: IAT D-score (implicit pro-straight bias;
    higher = more stigma)

  - `"iat_sex_explicit_therm"`: Average of gay men + lesbian women
    feeling thermometers (reversed so higher = more stigma)

  - `"iat_sex_explicit_pol"`: Average of policy opposition items
    (marriage rights, relations legality, adoption, service refusal,
    transgender bathroom)

  - `"iat_sex_explicit"`: Omnibus average across all explicit items
    (therm + pol)

- year:

  Character vector. Years to merge in (e.g., `c("2016", "2017")`). Each
  year x index combination becomes one new column named
  `YYYY_iat_sex_index`. Data are available from 2016 onward.

## Value

The input data frame with new columns named `YYYY_iat_sex_index`
containing matched state-level stigma scores for each requested year and
index.

## References

Kim, S. & Todd, N. R. (2027). stigmaR: Enhancing Accessibility,
Reproducibility, and Transparency of Structural Stigma Research.

Greenwald, A. G., Nosek, B. A., & Banaji, M. R. (2003). Understanding
and using the Implicit Association Test: I. An improved scoring
algorithm. *Journal of Personality and Social Psychology*, 85(2),
197–216. https://doi.org/10.1037/0022-3514.85.2.197

## Examples

``` r
if (FALSE) { # \dontrun{
new_df <- stigmaR(
  df    = my_data,
  state = "state_abbrev",
  index = c("iat_sex_implicit", "iat_sex_explicit_pol"),
  year  = c("2016", "2017")
)
# Adds columns: 2016_iat_sex_implicit, 2017_iat_sex_implicit,
#               2016_iat_sex_explicit_pol, 2017_iat_sex_explicit_pol
} # }
```
