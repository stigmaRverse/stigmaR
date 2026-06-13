# Composite Structural Stigma Indices

State- and year-level composite (pre-averaged) structural stigma indices
derived from Project Implicit IAT data, covering the 50 US states and DC
from 2016 onward. Used internally by
[`stigmaR()`](https://follhim.github.io/stigmaR/reference/stigmaR.md).

## Usage

``` r
composite
```

## Format

A data frame with 510 rows (51 states + DC x 10 years) and 6 columns:

- state:

  Two-letter US state code (50 states + DC only).

- year:

  4-digit integer year.

- iat_sex_implicit:

  IAT D-score (implicit pro-straight bias; higher = more stigma).

- iat_sex_explicit_therm:

  Mean of gay men + lesbian women thermometers (reversed: higher = more
  stigma).

- iat_sex_explicit_pol:

  Mean of 5 policy opposition items.

- iat_sex_explicit:

  Omnibus mean across all explicit items (thermometer + policy).

## Source

<https://github.com/stigmaRverse/stigmaRdata>
