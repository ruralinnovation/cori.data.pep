# Suppress R CMD check NOTEs for column names used in dplyr NSE pipelines.

utils::globalVariables(c(
  # Identifiers
  "geoid", "year",

  # Pre-janitor::clean_names() column names (raw Census names)
  "SUMLEV", "STATE", "COUNTY", "SEX", "AGEGRP", "YEAR",
  "AGE16PLUS_TOT", "STATEFP", "NAMELSAD", "GEOID", "NAME",

  # Post-clean_names() column names
  "sumlev", "state", "county",

  # Pivot / reshape intermediates
  "name_co", "raw_var", "age_0", "age_1", "age_2", "age_3",

  # Processed output columns
  "variable", "value", "agg_var"
))
