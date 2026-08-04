#' Read processed PEP data from S3
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' `read_pep_from_s3()` is deprecated. Use [get_population()] instead.
#'
#' @param vintage Passed to [get_population()].
#' @param variables Passed to [get_population()].
#' @param years Passed to [get_population()].
#' @param geoids Passed to [get_population()].
#' @param s3_bucket Ignored. No longer configurable in the public API.
#' @param s3_path_prefix Ignored. No longer configurable in the public API.
#'
#' @return A data frame. See [get_population()] for details.
#'
#' @seealso [get_population()]
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
  .Deprecated(
    new     = "get_population",
    package = "cori.data.pep",
    msg     = paste0(
      "`read_pep_from_s3()` is deprecated.\n",
      "  Use `get_population()` for population and population_16plus.\n",
      "  Use `get_population_change()` for births, deaths, and migration components.\n",
      "  Note: `s3_bucket` and `s3_path_prefix` are no longer configurable in the public API."
    )
  )
  # Fall back to get_population() for backwards compatibility.
  # Users requesting change variables will need to switch to get_population_change().
  get_population(
    years     = years,
    geoids    = geoids,
    variables = variables,
    vintage   = vintage
  )
}
