# Introduction to cori.data.pep

`cori.data.pep` provides county-level population estimates from the U.S.
Census Bureau’s Population Estimates Program (PEP). Data cover
2000–present at annual frequency.

## Variables

``` r

library(cori.data.pep)

get_pep_codebook() |>
  dplyr::select(variable, label, coverage = notes) |>
  gt::gt() |>
  gt::cols_label(
    variable = "Variable",
    label = "Label",
    coverage = "Coverage"
  )
```

## Reading data

All data are returned in long format: one row per
`geoid / year / variable`.

``` r

# Total population, all counties, all years
pop <- get_population(geography = "county", variables = "population")
dplyr::glimpse(pop)
```

Filter to specific variables, years, or counties:

``` r

# Migration components for West Virginia counties
wv_mig <- get_population_change(
  variables = c("domestic_migration", "international_migration", "net_migration"),
  geoids    = grep("^54", unique(pop$geoid), value = TRUE),
  years     = 2010:2025
)

dplyr::glimpse(wv_mig)
```

## Population trend — Grafton County, NH

Grafton County, NH (GEOID `33009`) illustrates how to build a simple
time-series chart using `cori.charts`.

``` r

library(ggplot2)
library(cori.charts)

load_fonts()

grafton_pop <- get_population(
  variables = "population",
  geoids    = "33009",
  years     = 2000:2025
)

fig_line <- ggplot(grafton_pop, aes(x = year, y = value)) +
  geom_line(color = cori_colors[["Emerald"]], linewidth = 1.2) +
  geom_point(color = cori_colors[["Emerald"]], size = 2) +
  scale_x_continuous(breaks = seq(2000, 2025, by = 5)) +
  scale_y_continuous(labels = scales::label_comma()) +
  theme_cori() +
  labs(
    title    = "Grafton County, NH population, 2000\u20132025",
    subtitle = "Total resident population estimate",
    x        = NULL,
    y        = NULL,
    caption  = "Source: CORI analysis of U.S. Census Bureau Population Estimates Program (PEP)."
  )

fig_line
```
