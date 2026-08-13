# Write processed PEP data to S3 as a versioned vintage

Runs all `pull_*` functions, combines the results, and writes
year-partitioned parquet files to S3. A `_LATEST` pointer file is
updated so
[`read_pep_from_s3()`](https://ruralinnovation.github.io/cori.data.pep/reference/read_pep_from_s3.md)
can find the current vintage automatically.

## Usage

``` r
write_pep_processed_to_s3(
  years = 2000:as.integer(format(Sys.Date(), "%Y")),
  s3_bucket = "cori.data.pep",
  s3_path_prefix = "",
  overwrite = FALSE,
  sync_to_s3 = TRUE
)
```

## Arguments

- years:

  Integer vector. Years to include. Default: `2000` to current year.

- s3_bucket:

  Character. S3 bucket name. Default: `"cori.data.pep"`.

- s3_path_prefix:

  Character. Optional prefix for all S3 keys, e.g. `"test/"` during
  development. Default: `""` (no prefix).

- overwrite:

  Logical. If `TRUE`, delete the existing S3 vintage prefix before
  uploading. Default: `FALSE`.

- sync_to_s3:

  Logical. Upload to S3 after writing locally. Default: `TRUE`.

## Value

Invisibly, a named list: `$vintage` and `$n_rows`.

## See also

[`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md),
[`get_pep_codebook()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_pep_codebook.md)
