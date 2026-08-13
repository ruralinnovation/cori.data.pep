# Pull population age 16 and over across multiple years

Returns resident population age 16+ for all U.S. counties, 2007 to
present. Note: this is resident population (includes institutionalized
populations). It differs from BLS civilian noninstitutional population
used in national ratios.

## Usage

``` r
pull_pop_16plus(years = 2007:as.integer(format(Sys.Date(), "%Y")))
```

## Arguments

- years:

  Integer vector. Years to return. Must be 2007 or later.

## Details

For 2007-2009, uses intercensal age groups to approximate 15+ population
(AGE16PLUS not directly available in those vintages).
