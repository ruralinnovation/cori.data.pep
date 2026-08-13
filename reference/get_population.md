# Get Census Bureau population estimates

Returns total population and working-age population (16+) from the U.S.
Census Bureau's Population Estimates Program (PEP). Data cover
2000–present at annual frequency for county, state, and national
geographies.

## Usage

``` r
get_population(
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

  Character vector. Variables to return: `"population"` and/or
  `"population_16plus"`. Default: both.

- vintage:

  Character. Vintage to read, e.g. `"2023"`. Default: `"latest"`.

## Value

A data frame with columns: `geoid`, `year`, `variable`, `value`,
`agg_var`. `agg_var` is population / 1,000, suitable for
population-weighted averaging.

## See also

[`get_population_change()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population_change.md),
[`get_pep_codebook()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_pep_codebook.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# All county-level population
get_population(geography = "county", years = 2010:2023)

# Specific county — Grafton County, NH
get_population(geoids = "33009", years = 2010:2023)

# Working-age population only, state level
get_population(geography = "state", variables = "population_16plus", years = 2015:2023)
} # }
```
