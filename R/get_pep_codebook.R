#' Get the cori.data.pep variable codebook
#'
#' Returns documentation for all variables available via [get_population()] and
#' [get_population_change()]. All variables are available at three geographic
#' levels: county (5-digit FIPS), state (2-digit FIPS), and national (`"00"`).
#' State and national values are derived by summing the 50 states + DC;
#' territories (Puerto Rico, etc.) are excluded.
#'
#' @return A data frame with columns: `variable`, `raw_variable`, `label`,
#'   `unit`, `nominal`, `notes`.
#'   `raw_variable` is the original name stored in S3 parquet files.
#'
#' @seealso [get_population()], [get_population_change()]
#'
#' @examples
#' get_pep_codebook()
#'
#' @export
get_pep_codebook <- function() {
  data.frame(
    stringsAsFactors = FALSE,

    variable = c(
      "population",
      "population_16plus",
      "births",
      "deaths",
      "natural_change",
      "domestic_migration",
      "international_migration",
      "net_migration"
    ),

    raw_variable = c(
      "population",
      "pop_16plus",
      "births",
      "deaths",
      "natural_chg",
      "domestic_mig",
      "international_mig",
      "net_mig"
    ),

    label = c(
      "Total resident population",
      "Resident population age 16+",
      "Births",
      "Deaths",
      "Natural change",
      "Net domestic migration",
      "Net international migration",
      "Net migration"
    ),

    unit = rep("persons", 8),

    nominal = rep(FALSE, 8),

    notes = c(
      "Annual resident population estimate. Coverage: 2000-present.",
      paste0(
        "Resident population age 16 and over. Includes institutionalized populations ",
        "(prisons, nursing homes, military on base) \u2014 differs from BLS civilian ",
        "noninstitutional population. For 2007-2009, approximated as 15+ from ",
        "intercensal age groups. Coverage: 2007-present."
      ),
      "Annual births. Source: PEP components of change file. Coverage: 2000-present.",
      "Annual deaths. Source: PEP components of change file. Coverage: 2000-present.",
      "Natural change = births minus deaths. Coverage: 2000-present.",
      "Net domestic migration (in-migrants minus out-migrants within U.S.). Coverage: 2000-present.",
      "Net international migration (immigration minus emigration). Coverage: 2000-present.",
      "Net migration = domestic migration plus international migration. Coverage: 2000-present."
    )
  )
}
