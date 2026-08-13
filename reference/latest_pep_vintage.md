# Return the current latest PEP vintage from S3

Reads the `_LATEST` pointer written by
[`write_pep_processed_to_s3()`](https://ruralinnovation.github.io/cori.data.pep/reference/write_pep_processed_to_s3.md)
and returns the vintage string (e.g., `"vintage_2023"`).

## Usage

``` r
latest_pep_vintage(s3_bucket = "cori.data.pep", s3_path_prefix = "")
```

## Arguments

- s3_bucket:

  Character. S3 bucket name. Default: `"cori.data.pep"`.

- s3_path_prefix:

  Character. Optional prefix matching the one used in
  [`write_pep_processed_to_s3()`](https://ruralinnovation.github.io/cori.data.pep/reference/write_pep_processed_to_s3.md),
  e.g. `"test/"`. Default: `""`.

## Value

Character. Current vintage tag (e.g., `"vintage_2023"`).
