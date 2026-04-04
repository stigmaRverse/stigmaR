# Calculate State-Level Stigma Scores from IAT Data

Merges state- and year-level stigma indices derived from Project
Implicit IAT data into your dataset. New columns are added in the format
`YYYY_index`.

## Usage

``` r
stigmaR(df, state, index, year, min_n = 30)
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

  - `"implicit"`: IAT D-score (implicit pro-straight bias)

  - `"explicit_therm"`: Average of gay men + gay women feeling
    thermometers (reversed so higher = more stigma)

  - `"explicit_pol"`: Average of policy opposition items (marriage
    rights, relations legality, adoption, service refusal, transgender
    bathroom)

  - `"explicit_bel"`: Belief that sexuality is environmental rather than
    innate

  - `"explicit"`: Average across all explicit indices (therm + pol +
    bel)

- year:

  Character vector. Years to merge in (e.g., `c("2015", "2016")`). Each
  year x index combination becomes one new column named `YYYY_index`.

- min_n:

  Integer. Minimum IAT respondents required per state-year cell. Cells
  below this threshold are set to NA. Default is 30.

## Value

The input data frame with new columns named `YYYY_index` containing
matched state-level stigma scores for each requested year and index.

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
  index = c("implicit", "explicit_pol"),
  year  = c("2015", "2016")
)
# Adds columns: 2015_implicit, 2016_implicit, 2015_explicit_pol, 2016_explicit_pol
} # }
```
