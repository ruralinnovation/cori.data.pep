# Pull total county population across multiple years

Returns annual resident population for all U.S. counties, 2000 to
present. Handles three Census vintages internally (2000-2009, 2010-2019,
2020-present).

## Usage

``` r
pull_population(years = 2000:as.integer(format(Sys.Date(), "%Y")))
```

## Arguments

- years:

  Integer vector. Years to return. Default: `2000` to current year.
