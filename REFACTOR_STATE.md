# cori.data.pep — Refactor: Current State & Proposed State

**Package:** cori.data.pep **Purpose:** Access U.S. Census Bureau
Population Estimates Program (PEP) data — population totals, population
age 16+, and components of change (births, deaths, migration) — at
county, state, and national level from 2000 to present.

------------------------------------------------------------------------

## Current State

### What the package exposes today

Every function in the package is currently exported — meaning it’s
visible and callable by any user who installs the package. That includes
internal processing functions that were never intended for general use.

**Exported functions (what users see today):**

| Function | What it does | Should it be public? |
|----|----|----|
| [`read_pep_from_s3()`](https://ruralinnovation.github.io/cori.data.pep/reference/read_pep_from_s3.md) | Queries S3 via DuckDB, returns population data | Yes, but rename |
| [`get_pep_codebook()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_pep_codebook.md) | Returns variable documentation table | Yes |
| [`latest_pep_vintage()`](https://ruralinnovation.github.io/cori.data.pep/reference/latest_pep_vintage.md) | Returns the current S3 vintage tag | No — internal detail |
| [`pull_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/pull_population.md) | Pulls raw Census population files | No — internal |
| [`pull_pop_16plus()`](https://ruralinnovation.github.io/cori.data.pep/reference/pull_pop_16plus.md) | Pulls raw Census age 16+ files | No — internal |
| [`pull_components()`](https://ruralinnovation.github.io/cori.data.pep/reference/pull_components.md) | Pulls births/deaths/migration files | No — internal |
| [`write_pep_processed_to_s3()`](https://ruralinnovation.github.io/cori.data.pep/reference/write_pep_processed_to_s3.md) | Writes processed data to S3 | No — maintainer only |

**How users access data today:**

``` r

library(cori.data.pep)

# Must know the internal variable name "population"
# Must filter geography themselves after loading
df <- read_pep_from_s3(variables = "population", years = 2010:2023)
df_county <- df |> dplyr::filter(nchar(geoid) == 5)

# Returns 5 columns including agg_var — but PEP is count data,
# agg_var is meaningless here (population IS the weight, not a variable needing one)
# geoid  year  variable    value    agg_var
# 01001  2010  population  54571    NA
```

**Problems with the current state:**

1.  [`read_pep_from_s3()`](https://ruralinnovation.github.io/cori.data.pep/reference/read_pep_from_s3.md)
    — name exposes S3 as an implementation detail. Users shouldn’t need
    to know where the data lives.
2.  No geography filter — users get everything and must filter
    themselves.
3.  No feedback — nothing tells the user what they pulled or how much
    data was returned.
4.  `agg_var` is always returned even though it’s meaningless for count
    data like population.
5.  Seven functions are exported when only two need to be
    ([`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md)
    and
    [`get_pep_codebook()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_pep_codebook.md)).
6.  Internal processing functions
    ([`pull_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/pull_population.md),
    [`pull_pop_16plus()`](https://ruralinnovation.github.io/cori.data.pep/reference/pull_pop_16plus.md),
    [`pull_components()`](https://ruralinnovation.github.io/cori.data.pep/reference/pull_components.md))
    are visible to users — confusing and clutters tab-completion.

------------------------------------------------------------------------

## Proposed State

### What the package exposes after the refactor

**Exported functions (what users see after):**

| Function | What it does | Change |
|----|----|----|
| [`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md) | Get population data — with geography filter and messaging | **New** |
| [`get_pep_codebook()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_pep_codebook.md) | Returns variable documentation table | No change |
| [`read_pep_from_s3()`](https://ruralinnovation.github.io/cori.data.pep/reference/read_pep_from_s3.md) | Deprecated wrapper → calls [`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md) with a warning | Deprecated |

Everything else (`write_pep_processed_to_s3`, `latest_pep_vintage`,
`pull_*`) moves to internal — invisible to users, still usable by
maintainers.

------------------------------------------------------------------------

### New function: `get_population()`

``` r

get_population(
  geography = c("all", "county", "state", "nation"),
  years     = NULL,
  geoids    = NULL,
  variables = NULL,
  vintage   = "latest"
)
```

**Parameters:**

| Parameter   | Type             | Description                 | Default       |
|-------------|------------------|-----------------------------|---------------|
| `geography` | character        | Geographic level to return  | `"all"`       |
| `years`     | integer vector   | Years to return             | all available |
| `geoids`    | character vector | Specific FIPS codes         | `NULL` (all)  |
| `variables` | character vector | Variables to return         | `NULL` (all)  |
| `vintage`   | character        | Data vintage, e.g. `"2023"` | `"latest"`    |

**`geography` values:**

| Value      | Returns                   |
|------------|---------------------------|
| `"all"`    | County + state + national |
| `"county"` | 5-digit FIPS only         |
| `"state"`  | 2-digit FIPS only         |
| `"nation"` | `"00"` only               |

**`geoids` vs `geography`:** When `geoids` is provided, it takes
precedence — you get exactly the geographies you asked for. `geography`
is for bulk level filtering; `geoids` is for specific places.

**Return value:** 4 columns — `geoid`, `year`, `variable`, `value`.
`agg_var` is dropped entirely (population is a count; weighted averaging
against population uses PEP data as the weight, not as the variable
being weighted).

------------------------------------------------------------------------

### How users access data after:

``` r

library(cori.data.pep)

# All county-level population — no filtering required
get_population(geography = "county", years = 2010:2023)
#> ✓ County-level population data pulled into your environment
#>   Years: 2010–2023 | Rows: 40,846 | Source: Census PEP (vintage_2023)

# Specific county
get_population(geoids = "33009", years = 2010:2023)
#> ✓ Population data pulled for 1 specific geography
#>   Years: 2010–2023 | Rows: 104 | Source: Census PEP (vintage_2023)

# Migration components, state level
get_population(
  geography = "state",
  variables = c("domestic_mig", "net_mig"),
  years     = 2015:2023
)
#> ✓ State-level population data pulled into your environment
#>   Years: 2015–2023 | Rows: 918 | Source: Census PEP (vintage_2023)

# Returns 4 columns — clean and simple
# geoid  year  variable    value
# 33009  2010  population  89118
# 33009  2011  population  90331
```

------------------------------------------------------------------------

### What happens to `read_pep_from_s3()`?

It stays in the package temporarily as a **deprecated wrapper**. Any
code calling it today continues to work — it just gets a warning:

``` r

read_pep_from_s3(variables = "population", years = 2010:2023)
#> Warning: `read_pep_from_s3()` is deprecated. Use `get_population()` instead.
#> (returns data as before)
```

It will be removed in the next major version (~6 months), after existing
pipelines have had time to migrate.

------------------------------------------------------------------------

## File Changes Summary

| File | Current | After |
|----|----|----|
| `R/get_pep.R` | Does not exist | **New** — [`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md) |
| `R/read_pep_from_s3.R` | Primary read function, exported | Deprecated wrapper only |
| `R/write_pep_to_s3.R` | [`latest_pep_vintage()`](https://ruralinnovation.github.io/cori.data.pep/reference/latest_pep_vintage.md) + [`write_pep_processed_to_s3()`](https://ruralinnovation.github.io/cori.data.pep/reference/write_pep_processed_to_s3.md) both exported | Both marked internal |
| `R/process_pep.R` | `pull_*` functions exported | Marked internal (no functional change) |
| `R/get_pep_codebook.R` | References [`read_pep_from_s3()`](https://ruralinnovation.github.io/cori.data.pep/reference/read_pep_from_s3.md) in docs | Updated to reference [`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md) |
| `NAMESPACE` | 7 exports | 3 exports: `get_population`, `get_pep_codebook`, `read_pep_from_s3` (deprecated) |

**No changes to:** - Processing logic (`process_pep.R`) — the underlying
data pipeline is untouched - S3 layout or data files — same parquet
files, same vintage structure - `globals.R` — no changes needed -
Vignettes — updated to use
[`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md)
(content stays the same)

------------------------------------------------------------------------

## What This Is Not

- Not a data change — same variables, same geographies, same vintages on
  S3
- Not a breaking change —
  [`read_pep_from_s3()`](https://ruralinnovation.github.io/cori.data.pep/reference/read_pep_from_s3.md)
  keeps working (with a warning)
- Not a rewrite — processing functions are untouched, just hidden from
  users

------------------------------------------------------------------------

## Open Questions for the Team

1.  **`variables` parameter in
    [`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md):**
    PEP has 8 variables. Should users be able to filter to specific ones
    (e.g., just `"population"`), or do we always return all 8 and let
    them filter themselves? Keeping the parameter is more flexible;
    dropping it is simpler.

2.  **`agg_var` removal:** Dropping it from the return value is a
    **breaking change** for any downstream code that references
    `df$agg_var` from PEP data. Is there any active pipeline that uses
    `agg_var` from PEP specifically? If not, safe to drop.

3.  **Vignette scope:** Two vignettes exist (`introduction.Rmd` and
    `rural-population-trends.Rmd`). The refactor standard calls for one
    vignette with rural vs. non-rural + county spotlight. Do we
    consolidate, or keep both and update both?
