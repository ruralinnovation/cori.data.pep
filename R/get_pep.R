# Variable name mappings: S3 parquet names → user-facing names
# These translate raw variable names stored in S3 to the friendly names
# returned by get_population() and get_population_change().

.PEP_POP_RENAMES <- c(
  pop_16plus = "population_16plus"
)

.PEP_CHANGE_RENAMES <- c(
  natural_chg       = "natural_change",
  domestic_mig      = "domestic_migration",
  international_mig = "international_migration",
  net_mig           = "net_migration"
)

# Inverse maps: user-facing name → S3 name (for translating the variables param)
.PEP_POP_S3_NAMES <- c(
  population        = "population",
  population_16plus = "pop_16plus"
)

.PEP_CHANGE_S3_NAMES <- c(
  births                  = "births",
  deaths                  = "deaths",
  natural_change          = "natural_chg",
  domestic_migration      = "domestic_mig",
  international_migration = "international_mig",
  net_migration           = "net_mig"
)


#' Get Census Bureau population estimates
#'
#' Returns total population and working-age population (16+) from the U.S.
#' Census Bureau's Population Estimates Program (PEP). Data cover 2000–present
#' at annual frequency for county, state, and national geographies.
#'
#' @param geography Character. Geographic level to return: `"all"`, `"county"`,
#'   `"state"`, or `"nation"`. Ignored when `geoids` is provided. Default: `"all"`.
#' @param years Integer vector. Years to return. Default: all available.
#' @param geoids Character vector. FIPS codes to return (5-digit county,
#'   2-digit state, or `"00"` for national). When provided, takes precedence
#'   over `geography`. Default: `NULL` (all geographies).
#' @param variables Character vector. Variables to return: `"population"` and/or
#'   `"population_16plus"`. Default: both.
#' @param vintage Character. Vintage to read, e.g. `"2023"`. Default: `"latest"`.
#'
#' @return A data frame with columns: `geoid`, `year`, `variable`, `value`.
#'
#' @seealso [get_population_change()], [get_pep_codebook()]
#'
#' @examples
#' \dontrun{
#' # All county-level population
#' get_population(geography = "county", years = 2010:2023)
#'
#' # Specific county — Grafton County, NH
#' get_population(geoids = "33009", years = 2010:2023)
#'
#' # Working-age population only, state level
#' get_population(geography = "state", variables = "population_16plus", years = 2015:2023)
#' }
#'
#' @export
get_population <- function(
    geography = c("all", "county", "state", "nation"),
    years     = NULL,
    geoids    = NULL,
    variables = NULL,
    vintage   = "latest"
) {
  geography <- match.arg(geography)

  # Translate user-facing variable names to S3 names
  s3_variables <- if (!is.null(variables)) {
    unknown <- setdiff(variables, names(.PEP_POP_S3_NAMES))
    if (length(unknown) > 0) {
      stop(sprintf(
        "Unknown variable(s): %s\nValid options: %s",
        paste(unknown, collapse = ", "),
        paste(names(.PEP_POP_S3_NAMES), collapse = ", ")
      ))
    }
    unname(.PEP_POP_S3_NAMES[variables])
  } else {
    unname(.PEP_POP_S3_NAMES)  # all population variables
  }

  df <- .query_pep_s3(vintage, s3_variables, years, geoids)

  # Rename S3 variable names to user-facing names
  df$variable <- dplyr::recode(df$variable, !!!.PEP_POP_RENAMES)

  df <- .apply_geography_filter(df, geography, geoids)

  .pep_message(df, geography, geoids, "population")
  df
}


#' Get Census Bureau population change components
#'
#' Returns components of population change — births, deaths, natural change,
#' and migration — from the U.S. Census Bureau's Population Estimates Program
#' (PEP). Data cover 2000–present at annual frequency for county, state, and
#' national geographies.
#'
#' @param geography Character. Geographic level to return: `"all"`, `"county"`,
#'   `"state"`, or `"nation"`. Ignored when `geoids` is provided. Default: `"all"`.
#' @param years Integer vector. Years to return. Default: all available.
#' @param geoids Character vector. FIPS codes to return (5-digit county,
#'   2-digit state, or `"00"` for national). When provided, takes precedence
#'   over `geography`. Default: `NULL` (all geographies).
#' @param variables Character vector. Variables to return. Options:
#'   `"births"`, `"deaths"`, `"natural_change"`, `"domestic_migration"`,
#'   `"international_migration"`, `"net_migration"`. Default: all.
#' @param vintage Character. Vintage to read, e.g. `"2023"`. Default: `"latest"`.
#'
#' @return A data frame with columns: `geoid`, `year`, `variable`, `value`.
#'
#' @seealso [get_population()], [get_pep_codebook()]
#'
#' @examples
#' \dontrun{
#' # All components, county level
#' get_population_change(geography = "county", years = 2010:2023)
#'
#' # Net migration only — Grafton County, NH
#' get_population_change(geoids = "33009", variables = "net_migration")
#'
#' # Migration components, state level
#' get_population_change(
#'   geography = "state",
#'   variables = c("domestic_migration", "net_migration"),
#'   years     = 2015:2023
#' )
#' }
#'
#' @export
get_population_change <- function(
    geography = c("all", "county", "state", "nation"),
    years     = NULL,
    geoids    = NULL,
    variables = NULL,
    vintage   = "latest"
) {
  geography <- match.arg(geography)

  # Translate user-facing variable names to S3 names
  s3_variables <- if (!is.null(variables)) {
    unknown <- setdiff(variables, names(.PEP_CHANGE_S3_NAMES))
    if (length(unknown) > 0) {
      stop(sprintf(
        "Unknown variable(s): %s\nValid options: %s",
        paste(unknown, collapse = ", "),
        paste(names(.PEP_CHANGE_S3_NAMES), collapse = ", ")
      ))
    }
    unname(.PEP_CHANGE_S3_NAMES[variables])
  } else {
    unname(.PEP_CHANGE_S3_NAMES)  # all change variables
  }

  df <- .query_pep_s3(vintage, s3_variables, years, geoids)

  # Rename S3 variable names to user-facing names
  df$variable <- dplyr::recode(df$variable, !!!.PEP_CHANGE_RENAMES)

  df <- .apply_geography_filter(df, geography, geoids)

  .pep_message(df, geography, geoids, "population change")
  df
}


# Internal: shared S3 query for all get_pep_*() functions.
.query_pep_s3 <- function(vintage, s3_variables, years, geoids,
                           s3_bucket = "cori.data.pep") {
  vintage_tag <- if (vintage == "latest") {
    .latest_pep_vintage(s3_bucket)
  } else {
    if (!startsWith(vintage, "vintage_")) sprintf("vintage_%s", vintage) else vintage
  }

  con <- DBI::dbConnect(duckdb::duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)

  DBI::dbExecute(con, "INSTALL httpfs; LOAD httpfs;")
  DBI::dbExecute(con, "INSTALL aws;   LOAD aws;")
  DBI::dbExecute(con, sprintf("SET temp_directory = '%s';", tempdir()))
  DBI::dbExecute(con, "CREATE OR REPLACE SECRET s3_secret (
    TYPE S3,
    PROVIDER CREDENTIAL_CHAIN,
    CHAIN 'env;config',
    REGION 'us-east-1',
    URL_STYLE 'path'
  );")

  glob  <- sprintf(
    "s3://%s/data_processed/%s/**/*.parquet",
    s3_bucket, vintage_tag
  )
  query <- sprintf(
    "SELECT geoid, year, variable, value FROM read_parquet('%s', hive_partitioning = true)",
    glob
  )

  where <- character(0)
  where <- c(where, sprintf(
    "variable IN (%s)", paste0("'", s3_variables, "'", collapse = ", ")
  ))
  if (!is.null(geoids)) {
    where <- c(where, sprintf("geoid IN (%s)", paste0("'", geoids, "'", collapse = ", ")))
  }
  if (!is.null(years)) {
    where <- c(where, sprintf("year IN (%s)", paste(years, collapse = ", ")))
  }
  query <- paste(query, "WHERE", paste(where, collapse = " AND "))

  DBI::dbGetQuery(con, query) |>
    dplyr::mutate(
      geoid = as.character(geoid),
      year  = as.integer(year),
      value = as.numeric(value)
    )
}


# Internal: apply geography filter. geoids takes precedence over geography.
.apply_geography_filter <- function(df, geography, geoids) {
  if (!is.null(geoids) || geography == "all") return(df)
  switch(geography,
    county = df[nchar(df$geoid) == 5, ],
    state  = df[nchar(df$geoid) == 2, ],
    nation = df[df$geoid == "00", ]
  )
}


# Internal: print a user-facing message describing what was pulled.
.pep_message <- function(df, geography, geoids, label) {
  geo_label <- if (!is.null(geoids)) {
    n <- length(unique(geoids))
    sprintf("%d specific geograph%s", n, ifelse(n == 1, "y", "ies"))
  } else {
    switch(geography,
      all    = "All geographies",
      county = "County-level",
      state  = "State-level",
      nation = "National"
    )
  }

  yr_range <- sprintf(
    "%d\u2013%d",
    min(df$year, na.rm = TRUE),
    max(df$year, na.rm = TRUE)
  )

  message(sprintf(
    "\u2713 %s %s data pulled into your environment\n  Years: %s | Rows: %s | Source: Census PEP",
    geo_label, label, yr_range, format(nrow(df), big.mark = ",")
  ))
}


# Internal: resolve the latest vintage tag from the S3 _LATEST pointer.
.latest_pep_vintage <- function(s3_bucket = "cori.data.pep", s3_path_prefix = "") {
  url <- sprintf(
    "https://s3.us-east-1.amazonaws.com/%s/%sdata_processed/_LATEST",
    s3_bucket, s3_path_prefix
  )
  tryCatch(
    readLines(url, n = 1L, warn = FALSE),
    error = function(e) stop(sprintf(
      "Could not read _LATEST from s3://%s. Has write_pep_processed_to_s3() been run?",
      s3_bucket
    ))
  )
}
