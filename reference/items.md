# Individual Item Structural Stigma Scores

State- and year-level individual item means and respondent counts
underlying the composite indices in
[composite](https://follhim.github.io/stigmaR/reference/composite.md).
Used internally by
[`item_stigmaR()`](https://follhim.github.io/stigmaR/reference/item_stigmaR.md)
and
[`cust_stigmaR()`](https://follhim.github.io/stigmaR/reference/cust_stigmaR.md).

## Usage

``` r
items
```

## Format

A data frame with 510 rows (51 states + DC x 10 years) and 20 columns:
`state`, `year`, 9 item-mean columns (`iat_sex_*`), and 9 matching
respondent-count columns (`iat_sex_n_*`):

- state:

  Two-letter US state code (50 states + DC only).

- year:

  4-digit integer year.

- iat_sex_imp_d:

  IAT D-score (`d_biep.straight_good_all`).

- iat_sex_exp_att:

  Explicit attitude item (`att_7`).

- iat_sex_exp_therm_gm:

  Gay men thermometer (reversed).

- iat_sex_exp_therm_gw:

  Lesbian women thermometer (reversed).

- iat_sex_exp_pol_marr:

  Marriage rights opposition.

- iat_sex_exp_pol_legal:

  Relations legality opposition.

- iat_sex_exp_pol_adopt:

  Adoption opposition.

- iat_sex_exp_pol_serv:

  Service refusal support.

- iat_sex_exp_pol_trans:

  Transgender bathroom opposition.

- iat_sex_n_imp_d:

  Respondent count for `iat_sex_imp_d`.

- iat_sex_n_exp_att:

  Respondent count for `iat_sex_exp_att`.

- iat_sex_n_exp_therm_gm:

  Respondent count for `iat_sex_exp_therm_gm`.

- iat_sex_n_exp_therm_gw:

  Respondent count for `iat_sex_exp_therm_gw`.

- iat_sex_n_exp_pol_marr:

  Respondent count for `iat_sex_exp_pol_marr`.

- iat_sex_n_exp_pol_legal:

  Respondent count for `iat_sex_exp_pol_legal`.

- iat_sex_n_exp_pol_adopt:

  Respondent count for `iat_sex_exp_pol_adopt`.

- iat_sex_n_exp_pol_serv:

  Respondent count for `iat_sex_exp_pol_serv`.

- iat_sex_n_exp_pol_trans:

  Respondent count for `iat_sex_exp_pol_trans`.

## Source

<https://github.com/stigmaRverse/stigmaRdata>
