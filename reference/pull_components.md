# Pull components of population change across multiple years

Returns births, deaths, natural change, domestic migration,
international migration, and net migration for all U.S. counties, 2000
to present.

## Usage

``` r
pull_components(years = 2000:as.integer(format(Sys.Date(), "%Y")))
```

## Arguments

- years:

  Integer vector. Years to return. Default: `2000` to current year.
