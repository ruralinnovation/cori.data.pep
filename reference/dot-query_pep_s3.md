# Query PEP data from S3 via DuckDB

Shared query engine for
[`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md)
and
[`get_population_change()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population_change.md).
Connects to S3 using
[`cori.data.s3::connect_to_s3()`](https://ruralinnovation.github.io/cori.data.s3/reference/connect_to_s3.html),
builds a DuckDB query against hive-partitioned parquet files, and
returns long-format results.

## Usage

``` r
.query_pep_s3(
  vintage,
  s3_variables,
  years,
  geoids,
  s3_bucket = "cori.data.pep",
  s3_path_prefix = ""
)
```

## Arguments

- vintage:

  Character. Vintage tag (e.g. `"2023"`) or `"latest"`.

- s3_variables:

  Character vector. Variable names as stored in S3 parquet files (before
  user-facing renaming).

- years:

  Integer vector or `NULL`. Years to filter; `NULL` returns all.

- geoids:

  Character vector or `NULL`. FIPS codes to filter; `NULL` returns all.

- s3_bucket:

  Character. S3 bucket name. Default: `"cori.data.pep"`.

- s3_path_prefix:

  Character. Optional path prefix within bucket. Default: `""`.

## Value

A data frame with columns: `geoid`, `year`, `variable`, `value`,
`agg_var`.
