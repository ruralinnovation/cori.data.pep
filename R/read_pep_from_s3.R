#' Read processed PEP data from S3
#'
#' Queries CORI's processed Population Estimates Program parquet files from S3
#' using DuckDB. Returns long-format data — one row per geoid/year/variable.
#'
#' @param vintage Character. Vintage to read, e.g. `"2023"`. Default: `"latest"`,
#'   which reads the `_LATEST` pointer written by [write_pep_processed_to_s3()].
#' @param variables Character vector. Variables to return. Default: all.
#'   See [get_pep_codebook()] for names.
#' @param years Integer vector. Years to return. Default: all.
#' @param geoids Character vector. 5-digit county FIPS codes to return.
#'   Default: all.
#' @param s3_bucket Character. S3 bucket name. Default: `"cori.data.pep"`.
#' @param s3_path_prefix Character. Optional prefix matching the one used in
#'   [write_pep_processed_to_s3()], e.g. `"test/"`. Default: `""`.
#'
#' @return A data frame with columns: `geoid`, `year`, `variable`, `value`,
#'   `agg_var`.
#'
#' @seealso [latest_pep_vintage()], [get_pep_codebook()]
#'
#' @examples
#' \dontrun{
#' # All data, latest vintage
#' df <- read_pep_from_s3()
#'
#' # Total population, specific years
#' df <- read_pep_from_s3(variables = "population", years = 2010:2023)
#'
#' # Migration components for specific counties
#' df <- read_pep_from_s3(
#'   variables = c("domestic_mig", "net_mig"),
#'   geoids    = c("54011", "54025")
#' )
#' }
#'
#' @export
read_pep_from_s3 <- function(
    vintage        = "latest",
    variables      = NULL,
    years          = NULL,
    geoids         = NULL,
    s3_bucket      = "cori.data.pep",
    s3_path_prefix = ""
) {

  vintage_tag <- if (vintage == "latest") {
    latest_pep_vintage(s3_bucket, s3_path_prefix)
  } else {
    if (!startsWith(vintage, "vintage_")) sprintf("vintage_%s", vintage) else vintage
  }

  con <- cori.data.s3::connect_to_s3(s3_bucket)
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)
  DBI::dbExecute(con, sprintf("SET temp_directory = '%s';", tempdir()))

  glob  <- sprintf(
    "s3://%s/%sdata_processed/%s/**/*.parquet",
    s3_bucket, s3_path_prefix, vintage_tag
  )
  query <- sprintf(
    "SELECT geoid, year, variable, value, agg_var FROM read_parquet('%s', hive_partitioning = true)",
    glob
  )

  where <- character(0)
  if (!is.null(geoids)) {
    where <- c(where, sprintf("geoid IN (%s)", paste0("'", geoids, "'", collapse = ", ")))
  }
  if (!is.null(years)) {
    where <- c(where, sprintf("year IN (%s)", paste(years, collapse = ", ")))
  }
  if (!is.null(variables)) {
    where <- c(where, sprintf("variable IN (%s)", paste0("'", variables, "'", collapse = ", ")))
  }
  if (length(where) > 0) {
    query <- paste(query, "WHERE", paste(where, collapse = " AND "))
  }

  DBI::dbGetQuery(con, query) |>
    dplyr::mutate(
      geoid   = as.character(geoid),
      year    = as.integer(year),
      value   = as.numeric(value),
      agg_var = as.numeric(agg_var)
    )
}
