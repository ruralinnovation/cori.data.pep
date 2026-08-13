# Get Census Bureau population change components

Returns components of population change — births, deaths, natural
change, and migration — from the U.S. Census Bureau's Population
Estimates Program (PEP). Data cover 2000–present at annual frequency for
county, state, and national geographies.

## Usage

``` r
get_population_change(
  geography = c("county", "state", "nation"),
  years = NULL,
  geoids = NULL,
  variables = NULL,
  vintage = "latest"
)
```

## Arguments

- geography:

  Character. Geographic level to return: `"all"`, `"county"`, `"state"`,
  or `"nation"`. Ignored when `geoids` is provided. Default: `"all"`.

- years:

  Integer vector. Years to return. Default: all available.

- geoids:

  Character vector. FIPS codes to return (5-digit county, 2-digit state,
  or `"00"` for national). When provided, takes precedence over
  `geography`. Default: `NULL` (all geographies).

- variables:

  Character vector. Variables to return. Options: `"births"`,
  `"deaths"`, `"natural_change"`, `"domestic_migration"`,
  `"international_migration"`, `"net_migration"`. Default: all.

- vintage:

  Character. Vintage to read, e.g. `"2023"`. Default: `"latest"`.

## Value

A data frame with columns: `geoid`, `year`, `variable`, `value`,
`agg_var`. `agg_var` is population / 1,000, suitable for
population-weighted averaging.

## See also

[`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md),
[`get_pep_codebook()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_pep_codebook.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# All components, county level
get_population_change(geography = "county", years = 2010:2023)

# Net migration only — Grafton County, NH
get_population_change(geoids = "33009", variables = "net_migration")

# Migration components, state level
get_population_change(
  geography = "state",
  variables = c("domestic_migration", "net_migration"),
  years     = 2015:2023
)
} # }
```
