# Rural Population Trends

``` r

library(cori.data.pep)
library(ggplot2)
library(cori.charts)
library(dplyr)

load_fonts()
```

## Components of population change — Grafton County, NH

Population change is driven by two forces: natural change (births minus
deaths) and migration (domestic and international). This chart shows how
each component has contributed to Grafton County’s population trajectory
from 2000 to 2025.

``` r

grafton <- get_population_change(
  variables = c("natural_change", "domestic_migration", "international_migration"),
  geoids    = "33009",
  years     = 2000:2025
)

component_labels <- c(
  natural_change          = "Natural change",
  domestic_migration      = "Domestic migration",
  international_migration = "International migration"
)

component_colors <- c(
  "Natural change"          = cori_colors[["Dark Green"]],
  "Domestic migration"      = cori_colors[["Mid Teal"]],
  "International migration" = cori_colors[["Squash"]]
)

grafton_plot <- grafton |>
  mutate(component = recode(variable, !!!component_labels))

ggplot(grafton_plot, aes(x = year, y = value, fill = component)) +
  geom_col(position = "stack", width = 0.7) +
  geom_hline(yintercept = 0, color = "grey40", linewidth = 0.4) +
  scale_fill_manual(values = component_colors) +
  scale_x_continuous(breaks = seq(2000, 2025, by = 5)) +
  scale_y_continuous(labels = scales::label_comma()) +
  theme_cori() +
  theme(legend.position = "bottom") +
  labs(
    title    = "Migration patterns shape population change in Grafton County, NH",
    subtitle = "Annual components of population change, 2000 - 2025",
    x        = NULL,
    y        = NULL,
    fill     = NULL,
    caption  = paste0(
      "Source: CORI analysis of U.S. Census Bureau Population Estimates Program (PEP).\n",
      "Natural change = births minus deaths."
    )
  )
```

## Rural vs. non-rural net migration

Using the `ruraldefinitions` package to classify counties, we can
compare how net migration has differed between rural and non-rural
communities since 2000.

``` r

library(ruraldefinitions)

rural_xwalk <- ruraldefinitions::cbsa_2023 |>
  select(geoid, is_rural)

pop <- get_population(
  variables = "population",
  years     = 2000:2025
) |>
  left_join(rural_xwalk, by = "geoid") |>
  filter(!is.na(is_rural)) |>
  group_by(year, is_rural) |>
  summarise(value = sum(value, na.rm = TRUE), .groups = "drop") |>
  group_by(is_rural) |>
  mutate(index = value / value[year == 2000] * 100) |>
  ungroup()

ggplot(pop, aes(x = year, y = index, color = is_rural)) +
  geom_line(linewidth = 1.2) +
  geom_hline(yintercept = 100, color = "grey40", linewidth = 0.4, linetype = "dashed") +
  scale_color_manual(values = c(
                                "Rural"    = "#00825B",
                                "Nonrural" = "#211448")) +
  scale_x_continuous(breaks = seq(2000, 2025, by = 5)) +
  scale_y_continuous(labels = scales::label_number(suffix = "")) +
  theme_cori() +
  labs(
    title    = "Rural population growth levels off post Great Recession",
    subtitle = "Relative changes in population levels since 2000",
    x        = NULL,
    y        = NULL,
    # color    = NULL,
    caption  = paste0(
      "Source: CORI analysis of U.S. Census Bureau Population Estimates Program (PEP).\n",
      "Rural classification: CORI CBSA 2023 definition."
    )
  )
```

## Natural change vs. migration — rural counties

For rural counties, understanding whether population change is driven by
natural change or migration reveals fundamentally different policy
levers. Below we show both components aggregated across all rural
counties.

``` r

rural_comp <- get_population_change(
  variables = c("natural_change", "net_migration"),
  years     = 2000:2025
) |>
  left_join(rural_xwalk, by = "geoid") |>
  filter(is_rural == "Rural") |>
  group_by(year, variable) |>
  summarise(value = sum(value, na.rm = TRUE), .groups = "drop") |>
  mutate(component = recode(variable,
    natural_change = "Natural change",
    net_migration  = "Net migration"
  ))

ggplot(rural_comp, aes(x = year, y = value, fill = component)) +
  geom_col(position = "stack", width = 0.7) +
  geom_hline(yintercept = 0, color = "grey40", linewidth = 0.4) +
  scale_fill_manual(
    values = c(
      "Natural change" = cori_colors[["Dark Green"]],
      "Net migration"  = cori_colors[["Mid Teal"]]
    )
  ) +
  scale_x_continuous(breaks = seq(2000, 2025, by = 5)) +
  scale_y_continuous(labels = scales::label_comma()) +
  theme_cori() +
  theme(legend.position = "bottom") +
  labs(
    title    = "Rural population change: natural change vs. migration",
    subtitle = "Aggregated across all rural counties, 2000 - 2025",
    x        = NULL,
    y        = NULL,
    fill     = NULL,
    caption  = paste0(
      "Source: CORI analysis of U.S. Census Bureau Population Estimates Program (PEP).\n",
      "Rural classification: CORI CBSA 2023 definition."
    )
  )
```
