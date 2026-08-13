# Get the cori.data.pep variable codebook

Returns documentation for all variables available via
[`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md)
and
[`get_population_change()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population_change.md).
All variables are available at three geographic levels: county (5-digit
FIPS), state (2-digit FIPS), and national (`"00"`). State and national
values are derived by summing the 50 states + DC; territories (Puerto
Rico, etc.) are excluded.

## Usage

``` r
get_pep_codebook()
```

## Value

A data frame with columns: `variable`, `raw_variable`, `label`, `unit`,
`nominal`, `notes`. `raw_variable` is the original name stored in S3
parquet files.

## See also

[`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md),
[`get_population_change()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population_change.md)

## Examples

``` r
get_pep_codebook()
#>                  variable      raw_variable                       label    unit
#> 1              population        population   Total resident population persons
#> 2       population_16plus        pop_16plus Resident population age 16+ persons
#> 3                  births            births                      Births persons
#> 4                  deaths            deaths                      Deaths persons
#> 5          natural_change       natural_chg              Natural change persons
#> 6      domestic_migration      domestic_mig      Net domestic migration persons
#> 7 international_migration international_mig Net international migration persons
#> 8           net_migration           net_mig               Net migration persons
#>   nominal
#> 1   FALSE
#> 2   FALSE
#> 3   FALSE
#> 4   FALSE
#> 5   FALSE
#> 6   FALSE
#> 7   FALSE
#> 8   FALSE
#>                                                                                                                                                                                                                                                                     notes
#> 1                                                                                                                                                                                                            Annual resident population estimate. Coverage: 2000-present.
#> 2 Resident population age 16 and over. Includes institutionalized populations (prisons, nursing homes, military on base) — differs from BLS civilian noninstitutional population. For 2007-2009, approximated as 15+ from intercensal age groups. Coverage: 2007-present.
#> 3                                                                                                                                                                                           Annual births. Source: PEP components of change file. Coverage: 2000-present.
#> 4                                                                                                                                                                                           Annual deaths. Source: PEP components of change file. Coverage: 2000-present.
#> 5                                                                                                                                                                                                           Natural change = births minus deaths. Coverage: 2000-present.
#> 6                                                                                                                                                                            Net domestic migration (in-migrants minus out-migrants within U.S.). Coverage: 2000-present.
#> 7                                                                                                                                                                                     Net international migration (immigration minus emigration). Coverage: 2000-present.
#> 8                                                                                                                                                                                Net migration = domestic migration plus international migration. Coverage: 2000-present.
```
