# Calculate State-Level Individual Item Scores

Merges state- and year-level *individual item* scores - the building
blocks behind the composite indices in
[`stigmaR()`](https://stigmaRverse.github.io/stigmaR/reference/stigmaR.md) -
into your dataset. Use this when you want full flexibility to work with
individual items (e.g., to build and compare your own composites). To
create a single summed composite column directly, see
[`cust_stigmaR()`](https://stigmaRverse.github.io/stigmaR/reference/cust_stigmaR.md).

## Usage

``` r
item_stigmaR(df, state, item, year)
```

## Arguments

- df:

  A data frame containing your data.

- state:

  Character string. Name of the column in `df` containing two-letter
  state abbreviations (e.g., "IL", "CA").

- item:

  Character vector. One or more individual items to merge in. The set of
  valid items is determined automatically from the columns of the
  bundled `items` dataset (every `iat_sex_*` mean column, excluding the
  `iat_sex_n_*` respondent-count columns). See `names(stigmaR::items)`
  for the full, current list.

- year:

  Character vector. Years to merge in (e.g., `c("2016", "2017")`). Each
  year x item combination becomes one new column named `YYYY_itemname`
  (as an example).

## Value

The input data frame with new columns named `YYYY_itemname` containing
matched state-level item scores for each requested year and item.

## Details

To keep merges manageable, a single call is limited to 100 new columns
(i.e., `length(item) * length(year)`). If you need more than that, split
the request into multiple calls.

## References

Kim, S. & Todd, N. R. (2027). stigmaR: Enhancing Accessibility,
Reproducibility, and Transparency of Structural Stigma Research.

## Examples

``` r
if (FALSE) { # \dontrun{
new_df <- item_stigmaR(
  df    = my_data,
  state = "state_abbrev",
  item  = c("iat_sex_imp_d", "iat_sex_exp_therm_gm"),
  year  = c("2016", "2017")
)
} # }
```
