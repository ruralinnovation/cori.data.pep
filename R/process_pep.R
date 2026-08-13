# Processing functions for Census Bureau Population Estimates Program (PEP).
# All functions return a data frame with columns: geoid, year, variable, value, agg_var
#
# Coverage: 2000-present, county level.
# Three Census vintages handled internally: 2000-2009, 2010-2019, 2020-present.
#
# Variables:
#   population     — total resident population
#   pop_16plus     — resident population age 16 and over
#   births         — births
#   deaths         — deaths
#   natural_chg    — natural change (births minus deaths)
#   domestic_mig   — net domestic migration
#   international_mig — net international migration
#   net_mig        — net migration (domestic + international)


# Census vintage URLs ----------------------------------------------------------

.PEP_URLS <- list(
  population = list(
    v2000_2009 = "https://www2.census.gov/programs-surveys/popest/datasets/2000-2010/intercensal/county/co-est00int-tot.csv",
    v2010_2019 = "https://www2.census.gov/programs-surveys/popest/tables/2010-2019/counties/totals/co-est2019-annres.xlsx",
    v2020_on   = "https://www2.census.gov/programs-surveys/popest/tables/2020-%d/counties/totals/co-est%d-pop.xlsx"
  ),
  components = list(
    v2000_2009 = "https://www2.census.gov/programs-surveys/popest/datasets/2000-2009/counties/totals/co-est2009-alldata.csv",
    v2010_2019 = "https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/totals/co-est2019-alldata.csv",
    v2020_on   = "https://www2.census.gov/programs-surveys/popest/datasets/2020-%d/counties/totals/co-est%d-alldata.csv"
  )
)

.COMPONENT_VARS <- c("births", "deaths", "naturalchg", "domesticmig", "internationalmig", "netmig")


#' Pull total county population across multiple years
#'
#' Returns annual resident population for all U.S. counties, 2000 to present.
#' Handles three Census vintages internally (2000-2009, 2010-2019, 2020-present).
#'
#' @param years Integer vector. Years to return. Default: \code{2000} to current year.
#'
#' @keywords internal
pull_population <- function(years = 2000:as.integer(format(Sys.Date(), "%Y"))) {

  results <- list()

  # -- 2000-2009: intercensal CSV -----------------------------------------------
  yrs_00s <- years[years >= 2000 & years <= 2009]
  if (length(yrs_00s) > 0) {
    message("Pulling population 2000-2009...")
    dta <- readr::read_csv(.PEP_URLS$population$v2000_2009, show_col_types = FALSE) |>
      dplyr::filter(SUMLEV == "50") |>
      dplyr::mutate(
        geoid = paste0(stringr::str_pad(STATE, 2, pad = "0"),
                       stringr::str_pad(COUNTY, 3, pad = "0"))
      ) |>
      dplyr::select(geoid, dplyr::starts_with("POPESTIMATE")) |>
      tidyr::pivot_longer(
        cols      = dplyr::starts_with("POPESTIMATE"),
        names_to  = "year",
        values_to = "value"
      ) |>
      dplyr::mutate(
        year     = as.integer(stringr::str_extract(year, "\\d{4}")),
        variable = "population",
        agg_var  = NA_real_
      ) |>
      dplyr::filter(year %in% yrs_00s) |>
      dplyr::select(geoid, year, variable, value, agg_var)

    results[["v2000_2009"]] <- dta
  }

  # -- 2010-2019: Excel file ----------------------------------------------------
  yrs_10s <- years[years >= 2010 & years <= 2019]
  if (length(yrs_10s) > 0) {
    message("Pulling population 2010-2019...")
    fp <- file.path(tempdir(), "co-est2019-annres.xlsx")
    utils::download.file(.PEP_URLS$population$v2010_2019, fp, mode = "wb", quiet = TRUE)

    counties <- .pep_county_xwalk()

    dta <- readxl::read_xlsx(fp, skip = 3) |>
      dplyr::rename(name_co = 1) |>
      dplyr::filter(!is.na(name_co), name_co != "United States") |>
      dplyr::mutate(name_co = stringr::str_remove(name_co, "^\\.")) |>
      tidyr::pivot_longer(cols = -name_co, names_to = "year", values_to = "value") |>
      dplyr::mutate(year = as.integer(year)) |>
      dplyr::filter(!is.na(year), !is.na(value), year %in% yrs_10s) |>
      dplyr::left_join(counties, by = "name_co") |>
      dplyr::filter(!is.na(geoid)) |>
      dplyr::mutate(variable = "population", agg_var = NA_real_) |>
      dplyr::select(geoid, year, variable, value, agg_var)

    results[["v2010_2019"]] <- dta
  }

  # -- 2020-present: Excel file -------------------------------------------------
  yrs_20s <- years[years >= 2020]
  if (length(yrs_20s) > 0) {
    latest_yr <- .pep_latest_vintage_year(.PEP_URLS$population$v2020_on)
    message(sprintf("Pulling population 2020-%d...", latest_yr))
    url <- sprintf(.PEP_URLS$population$v2020_on, latest_yr, latest_yr)
    fp  <- file.path(tempdir(), sprintf("co-est%d-pop.xlsx", latest_yr))
    utils::download.file(url, fp, mode = "wb", quiet = TRUE)

    counties <- .pep_county_xwalk()

    dta <- readxl::read_xlsx(fp, skip = 3) |>
      dplyr::rename(name_co = 1) |>
      dplyr::filter(!is.na(name_co), name_co != "United States") |>
      dplyr::mutate(name_co = stringr::str_remove(name_co, "^\\.")) |>
      tidyr::pivot_longer(cols = -name_co, names_to = "year", values_to = "value") |>
      dplyr::mutate(year = as.integer(year)) |>
      dplyr::filter(!is.na(year), !is.na(value), year %in% yrs_20s) |>
      dplyr::left_join(counties, by = "name_co") |>
      dplyr::filter(!is.na(geoid)) |>
      dplyr::mutate(variable = "population", agg_var = NA_real_) |>
      dplyr::select(geoid, year, variable, value, agg_var)

    results[["v2020_on"]] <- dta
  }

  dplyr::bind_rows(results)
}


#' Pull population age 16 and over across multiple years
#'
#' Returns resident population age 16+ for all U.S. counties, 2007 to present.
#' Note: this is resident population (includes institutionalized populations).
#' It differs from BLS civilian noninstitutional population used in national ratios.
#'
#' For 2007-2009, uses intercensal age groups to approximate 15+ population
#' (AGE16PLUS not directly available in those vintages).
#'
#' @param years Integer vector. Years to return. Must be 2007 or later.
#'
#' @keywords internal
pull_pop_16plus <- function(years = 2007:as.integer(format(Sys.Date(), "%Y"))) {

  if (min(years) < 2007) stop("Age 16+ data only available from 2007 onward.")

  results  <- list()
  st_fips  <- sprintf("%02d", c(1:2, 4:6, 8:13, 15:42, 44:51, 53:56))

  # -- 2007-2009: intercensal age groups (15+ approximation) -------------------
  yrs_00s <- years[years >= 2007 & years <= 2009]
  if (length(yrs_00s) > 0) {
    message("Pulling pop 16+ 2007-2009 (15+ approximation)...")
    url <- "https://www2.census.gov/programs-surveys/popest/datasets/2000-2010/intercensal/county/co-est00int-agesex-5yr.csv"

    dta <- readr::read_csv(url, show_col_types = FALSE) |>
      dplyr::filter(SUMLEV == "050", SEX == 0) |>
      dplyr::mutate(
        geoid = paste0(stringr::str_pad(STATE, 2, pad = "0"),
                       stringr::str_pad(COUNTY, 3, pad = "0"))
      ) |>
      dplyr::select(geoid, AGEGRP, dplyr::starts_with("POPESTIMATE")) |>
      tidyr::pivot_longer(
        cols      = dplyr::starts_with("POPESTIMATE"),
        names_to  = "year",
        values_to = "value"
      ) |>
      dplyr::mutate(year = as.integer(stringr::str_extract(year, "\\d{4}"))) |>
      dplyr::filter(year %in% yrs_00s, AGEGRP %in% c(0, 1, 2, 3)) |>
      tidyr::pivot_wider(names_from = AGEGRP, values_from = value, names_prefix = "age_") |>
      dplyr::mutate(
        value    = age_0 - age_1 - age_2 - age_3,
        variable = "pop_16plus",
        agg_var  = NA_real_
      ) |>
      dplyr::select(geoid, year, variable, value, agg_var)

    results[["v2007_2009"]] <- dta
  }

  # -- 2010-2019: state-by-state CSVs ------------------------------------------
  yrs_10s <- years[years >= 2010 & years <= 2019]
  if (length(yrs_10s) > 0) {
    message("Pulling pop 16+ 2010-2019...")
    dta <- lapply(st_fips, function(fips) {
      url <- sprintf(
        "https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/asrh/cc-est2019-agesex-%s.csv",
        fips
      )
      tryCatch({
        readr::read_csv(url, show_col_types = FALSE) |>
          dplyr::filter(SUMLEV == "050") |>
          dplyr::mutate(
            geoid = paste0(stringr::str_pad(STATE, 2, pad = "0"),
                           stringr::str_pad(COUNTY, 3, pad = "0")),
            year  = 2009L + as.integer(YEAR)
          ) |>
          dplyr::filter(year %in% yrs_10s) |>
          dplyr::select(geoid, year, value = AGE16PLUS_TOT)
      }, error = function(e) NULL)
    }) |>
      dplyr::bind_rows() |>
      dplyr::mutate(variable = "pop_16plus", agg_var = NA_real_) |>
      dplyr::select(geoid, year, variable, value, agg_var)

    results[["v2010_2019"]] <- dta
  }

  # -- 2020-present: state-by-state CSVs ----------------------------------------
  yrs_20s <- years[years >= 2020]
  if (length(yrs_20s) > 0) {
    latest_yr <- .pep_latest_vintage_year(
      "https://www2.census.gov/programs-surveys/popest/datasets/2020-%d/counties/asrh/cc-est%d-agesex-01.csv"
    )
    message(sprintf("Pulling pop 16+ 2020-%d...", latest_yr))
    dta <- lapply(st_fips, function(fips) {
      url <- sprintf(
        "https://www2.census.gov/programs-surveys/popest/datasets/2020-%d/counties/asrh/cc-est%d-agesex-%s.csv",
        latest_yr, latest_yr, fips
      )
      tryCatch({
        readr::read_csv(url, show_col_types = FALSE) |>
          dplyr::filter(SUMLEV == "050") |>
          dplyr::mutate(
            geoid = paste0(stringr::str_pad(STATE, 2, pad = "0"),
                           stringr::str_pad(COUNTY, 3, pad = "0")),
            year  = 2019L + as.integer(YEAR)
          ) |>
          dplyr::filter(year %in% yrs_20s) |>
          dplyr::select(geoid, year, value = AGE16PLUS_TOT)
      }, error = function(e) NULL)
    }) |>
      dplyr::bind_rows() |>
      dplyr::mutate(variable = "pop_16plus", agg_var = NA_real_) |>
      dplyr::select(geoid, year, variable, value, agg_var)

    results[["v2020_on"]] <- dta
  }

  dplyr::bind_rows(results)
}


#' Pull components of population change across multiple years
#'
#' Returns births, deaths, natural change, domestic migration, international
#' migration, and net migration for all U.S. counties, 2000 to present.
#'
#' @param years Integer vector. Years to return. Default: \code{2000} to current year.
#'
#' @keywords internal
pull_components <- function(years = 2000:as.integer(format(Sys.Date(), "%Y"))) {

  results <- list()

  # -- 2000-2009 ----------------------------------------------------------------
  yrs_00s <- years[years >= 2000 & years <= 2009]
  if (length(yrs_00s) > 0) {
    message("Pulling components 2000-2009...")
    results[["v2000_2009"]] <- .read_components_csv(
      .PEP_URLS$components$v2000_2009, yrs_00s
    )
  }

  # -- 2010-2019 ----------------------------------------------------------------
  yrs_10s <- years[years >= 2010 & years <= 2019]
  if (length(yrs_10s) > 0) {
    message("Pulling components 2010-2019...")
    results[["v2010_2019"]] <- .read_components_csv(
      .PEP_URLS$components$v2010_2019, yrs_10s
    )
  }

  # -- 2020-present -------------------------------------------------------------
  yrs_20s <- years[years >= 2020]
  if (length(yrs_20s) > 0) {
    latest_yr <- .pep_latest_vintage_year(.PEP_URLS$components$v2020_on)
    message(sprintf("Pulling components 2020-%d...", latest_yr))
    url <- sprintf(.PEP_URLS$components$v2020_on, latest_yr, latest_yr)
    results[["v2020_on"]] <- .read_components_csv(url, yrs_20s)
  }

  dplyr::bind_rows(results)
}


# -- Internal helpers ----------------------------------------------------------

# Read and tidy a PEP all-data CSV into long format with standard variable names.
#' @keywords internal
.read_components_csv <- function(url, years) {
  readr::read_csv(url, show_col_types = FALSE) |>
    janitor::clean_names() |>
    dplyr::filter(as.integer(sumlev) == 50) |>
    dplyr::mutate(
      geoid = paste0(stringr::str_pad(state, 2, pad = "0"),
                     stringr::str_pad(county, 3, pad = "0"))
    ) |>
    dplyr::select(geoid, dplyr::any_of(c(
      "geoid",
      paste0("births",           2000:2030),
      paste0("deaths",           2000:2030),
      paste0("naturalchg",       2000:2030),
      paste0("naturalinc",       2000:2030),
      paste0("domesticmig",      2000:2030),
      paste0("internationalmig", 2000:2030),
      paste0("netmig",           2000:2030)
    ))) |>
    tidyr::pivot_longer(
      cols      = -geoid,
      names_to  = "raw_var",
      values_to = "value"
    ) |>
    dplyr::mutate(
      year     = as.integer(stringr::str_extract(raw_var, "\\d{4}")),
      variable = dplyr::case_when(
        stringr::str_detect(raw_var, "^births")           ~ "births",
        stringr::str_detect(raw_var, "^deaths")           ~ "deaths",
        stringr::str_detect(raw_var, "^naturalchg")       ~ "natural_chg",
        stringr::str_detect(raw_var, "^naturalinc")       ~ "natural_chg",
        stringr::str_detect(raw_var, "^domesticmig")      ~ "domestic_mig",
        stringr::str_detect(raw_var, "^internationalmig") ~ "international_mig",
        stringr::str_detect(raw_var, "^netmig")           ~ "net_mig"
      ),
      agg_var  = NA_real_
    ) |>
    dplyr::filter(!is.na(year), year %in% years, !is.na(variable)) |>
    dplyr::select(geoid, year, variable, value, agg_var)
}


# Find the latest available Census vintage year for 2020+ files.
# Each Census file type (alldata, agesex, pop) has independent release timing.
# Tries from current_year-1 downward until finding an accessible URL.
#
# @param url_template A sprintf template with two %d placeholders (both = year).
#' @keywords internal
.pep_latest_vintage_year <- function(url_template) {
  current_yr <- as.integer(format(Sys.Date(), "%Y"))
  for (yr in (current_yr - 1):(2020)) {
    url <- sprintf(url_template, yr, yr)
    accessible <- tryCatch({
      con <- url(url, open = "r")
      close(con)
      TRUE
    }, error = function(e) FALSE)
    if (accessible) return(yr)
  }
  stop(sprintf("Could not find an accessible Census PEP file matching: %s",
               sprintf(url_template, 9999, 9999)))
}


# Aggregate county-level PEP data to state and national level by summing counties.
# Returns state rows (2-digit geoid) and national row (geoid = "00").
# Only includes the 50 states + DC (state FIPS < 60); excludes territories.
# All PEP variables use NA for agg_var, so a simple sum is appropriate.
#' @keywords internal
.aggregate_to_state_national <- function(county_data) {
  county_50states <- county_data |>
    dplyr::filter(
      nchar(geoid) == 5,
      as.integer(substr(geoid, 1, 2)) < 60
    )

  state_data <- county_50states |>
    dplyr::mutate(geoid = substr(geoid, 1, 2)) |>
    dplyr::group_by(geoid, year, variable) |>
    dplyr::summarise(value = sum(value, na.rm = TRUE), agg_var = NA_real_, .groups = "drop")

  national_data <- state_data |>
    dplyr::mutate(geoid = "00") |>
    dplyr::group_by(geoid, year, variable) |>
    dplyr::summarise(value = sum(value, na.rm = TRUE), agg_var = NA_real_, .groups = "drop")

  dplyr::bind_rows(state_data, national_data)
}


# Build a county name -> geoid crosswalk using tigris (needed for Excel files
# that identify counties by name rather than FIPS).
#' @keywords internal
.pep_county_xwalk <- function() {
  dplyr::bind_rows(
    tigris::counties(year = 2019) |> sf::st_drop_geometry(),
    tigris::counties(year = 2023) |> sf::st_drop_geometry()
  ) |>
    dplyr::left_join(
      tigris::states(year = 2024) |> dplyr::select(NAME, STATEFP),
      by = "STATEFP"
    ) |>
    dplyr::mutate(name_co = paste0(NAMELSAD, ", ", NAME)) |>
    dplyr::select(geoid = GEOID, name_co) |>
    dplyr::distinct()
}
