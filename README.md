cori.data.pep
=============

Access and analyze U.S. Census Bureau Population Estimates Program (PEP) data at the county level from 2000 to present.

## What's in the package

| Variable            | Coverage     | Description                              |
|------------------|------------------|------------------------------------|
| `population`        | 2000–present | Total resident population                |
| `pop_16plus`        | 2007–present | Resident population age 16+              |
| `births`            | 2000–present | Annual births                            |
| `deaths`            | 2000–present | Annual deaths                            |
| `natural_chg`       | 2000–present | Natural change (births minus deaths)     |
| `domestic_mig`      | 2000–present | Net domestic migration                   |
| `international_mig` | 2000–present | Net international migration              |
| `net_mig`           | 2000–present | Net migration (domestic + international) |

Data are returned in long format: one row per `geoid / year / variable`.

## Installation

``` r
remotes::install_github("ruralinnovation/cori.data.pep")
```

## Usage

``` r
library(cori.data.pep)

# Population, latest vintage
df <- get_population()

# Net migration and births, specific years
df <- get_population_change(
  variables = c("births", "net_migration"),
  years     = 2010:2024
)

# Specific counties
df <- get_population_change(
  variables = c("domestic_migration", "international_migration"),
  geoids    = c("54011", "54025")
)

# Variable documentation
get_pep_codebook()
```

See [RELEASE_CALENDAR.md](RELEASE_CALENDAR.md) for vintage log and update schedule.
