# cori.data.pep

Access and analyze U.S. Census Bureau Population Estimates Program (PEP) data at the county level from 2000 to present.

## What's in the package

Eight variables, county-level, annual:

| Variable | Coverage | Description |
|---|---|---|
| `population` | 2000–present | Total resident population |
| `pop_16plus` | 2007–present | Resident population age 16+ |
| `births` | 2000–present | Annual births |
| `deaths` | 2000–present | Annual deaths |
| `natural_chg` | 2000–present | Natural change (births minus deaths) |
| `domestic_mig` | 2000–present | Net domestic migration |
| `international_mig` | 2000–present | Net international migration |
| `net_mig` | 2000–present | Net migration (domestic + international) |

Data are returned in long format: one row per `geoid / year / variable`.

## Installation

```r
remotes::install_github("ruralinnovation/cori.data.pep")
```

## Usage

```r
library(cori.data.pep)

# All data, latest vintage
df <- read_pep_from_s3()

# Total population and migration, specific years
df <- read_pep_from_s3(
  variables = c("population", "net_mig"),
  years     = 2010:2024
)

# Specific counties
df <- read_pep_from_s3(
  variables = c("domestic_mig", "international_mig"),
  geoids    = c("54011", "54025")
)

# Variable documentation
get_pep_codebook()
```

## Data sources

Three Census PEP vintages are handled internally:

| Vintage | URL |
|---|---|
| 2000–2009 | Intercensal county estimates |
| 2010–2019 | Vintage 2019 county estimates |
| 2020–present | Latest vintage county estimates |

See [RELEASE_CALENDAR.md](RELEASE_CALENDAR.md) for vintage log and update schedule.

