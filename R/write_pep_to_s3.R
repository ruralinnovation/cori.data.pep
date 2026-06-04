#' Return the current latest PEP vintage from S3
#'
#' Reads the `_LATEST` pointer written by [write_pep_processed_to_s3()] and
#' returns the vintage string (e.g., `"vintage_2023"`).
#'
#' @param s3_bucket Character. S3 bucket name. Default: `"cori.data.pep"`.
#' @param s3_path_prefix Character. Optional prefix matching the one used in
#'   [write_pep_processed_to_s3()], e.g. `"test/"`. Default: `""`.
#'
#' @return Character. Current vintage tag (e.g., `"vintage_2023"`).
#'
#' @export
latest_pep_vintage <- function(s3_bucket = "cori.data.pep", s3_path_prefix = "") {
  url <- sprintf(
    "https://s3.us-east-1.amazonaws.com/%s/%sdata_processed/_LATEST",
    s3_bucket, s3_path_prefix
  )
  tryCatch(
    readLines(url, n = 1L, warn = FALSE),
    error = function(e) stop(sprintf(
      "Could not read _LATEST from s3://%s/%sdata_processed/_LATEST. Has write_pep_processed_to_s3() been run?",
      s3_bucket, s3_path_prefix
    ))
  )
}


#' Write processed PEP data to S3 as a versioned vintage
#'
#' Runs all `pull_*` functions, combines the results, and writes year-partitioned
#' parquet files to S3. A `_LATEST` pointer file is updated so
#' [read_pep_from_s3()] can find the current vintage automatically.
#'
#' @param years Integer vector. Years to include.
#'   Default: `2000` to current year.
#' @param s3_bucket Character. S3 bucket name. Default: `"cori.data.pep"`.
#' @param s3_path_prefix Character. Optional prefix for all S3 keys, e.g.
#'   `"test/"` during development. Default: `""` (no prefix).
#' @param overwrite Logical. If `TRUE`, delete the existing S3 vintage prefix
#'   before uploading. Default: `FALSE`.
#' @param sync_to_s3 Logical. Upload to S3 after writing locally.
#'   Default: `TRUE`.
#'
#' @return Invisibly, a named list: `$vintage` and `$n_rows`.
#'
#' @seealso [read_pep_from_s3()], [get_pep_codebook()]
#'
#' @keywords internal
#' @export
write_pep_processed_to_s3 <- function(
    years          = 2000:as.integer(format(Sys.Date(), "%Y")),
    s3_bucket      = "cori.data.pep",
    s3_path_prefix = "",
    overwrite      = FALSE,
    sync_to_s3     = TRUE
) {

  message("Pulling population...")
  pop <- pull_population(years)

  message("Pulling population 16+...")
  pop16 <- pull_pop_16plus(years[years >= 2007])

  message("Pulling components of change...")
  comp <- pull_components(years)

  county_data <- dplyr::bind_rows(pop, pop16, comp)

  message("Aggregating to state and national level...")
  agg_data <- .aggregate_to_state_national(county_data)

  processed   <- dplyr::bind_rows(county_data, agg_data)
  vintage     <- as.character(max(processed$year, na.rm = TRUE))
  vintage_tag <- sprintf("vintage_%s", vintage)

  message(sprintf("Vintage: %s | Rows: %s", vintage,
                  format(nrow(processed), big.mark = ",")))

  # Write parquet locally, partitioned by year
  out_dir <- file.path(tempdir(), "pep_s3", vintage_tag)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  con <- DBI::dbConnect(duckdb::duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)

  DBI::dbWriteTable(con, "processed", processed, overwrite = TRUE)
  DBI::dbExecute(con, sprintf(
    "COPY processed TO '%s' (FORMAT 'parquet', PARTITION_BY (year), OVERWRITE_OR_IGNORE)",
    out_dir
  ))

  # Write _LATEST pointer
  latest_dir  <- file.path(tempdir(), "pep_s3")
  latest_file <- file.path(latest_dir, "_LATEST")
  writeLines(vintage_tag, latest_file)

  message(sprintf("Parquet written to: %s", out_dir))

  if (sync_to_s3) {
    s3_vintage_prefix <- sprintf("%sdata_processed/%s/", s3_path_prefix, vintage_tag)

    if (overwrite) {
      s3_uri <- sprintf("s3://%s/%s", s3_bucket, s3_vintage_prefix)
      message(sprintf("Deleting existing S3 prefix: %s", s3_uri))
      system2("aws", args = c("s3", "rm", s3_uri, "--recursive"))
    }

    .pep_upload_to_s3(s3_bucket, s3_vintage_prefix, out_dir)
    .pep_upload_to_s3(
      s3_bucket,
      sprintf("%sdata_processed/_LATEST", s3_path_prefix),
      latest_file
    )
    message(sprintf("_LATEST updated to: %s", vintage_tag))
  }

  invisible(list(vintage = vintage, n_rows = nrow(processed)))
}


# Internal: upload a directory or single file to S3 via AWS CLI.
#' @keywords internal
.pep_upload_to_s3 <- function(s3_bucket, s3_prefix, local_path) {
  s3_uri <- sprintf("s3://%s/%s", s3_bucket, s3_prefix)
  message(sprintf("Uploading to %s...", s3_uri))

  if (file.info(local_path)$isdir) {
    exit_code <- base::system2("aws", args = c("s3", "sync", local_path, s3_uri))
  } else {
    exit_code <- base::system2("aws", args = c("s3", "cp", local_path, s3_uri))
  }

  if (exit_code != 0) stop(sprintf("AWS CLI upload failed: %s -> %s", local_path, s3_uri))
}
