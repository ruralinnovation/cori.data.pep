# Read processed PEP data from S3

**\[deprecated\]**

`read_pep_from_s3()` is deprecated. Use
[`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md)
instead.

## Usage

``` r
read_pep_from_s3(
  vintage = "latest",
  variables = NULL,
  years = NULL,
  geoids = NULL,
  s3_bucket = "cori.data.pep",
  s3_path_prefix = ""
)
```

## Arguments

- vintage:

  Passed to
  [`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md).

- variables:

  Passed to
  [`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md).

- years:

  Passed to
  [`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md).

- geoids:

  Passed to
  [`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md).

- s3_bucket:

  Ignored. No longer configurable in the public API.

- s3_path_prefix:

  Ignored. No longer configurable in the public API.

## Value

A data frame. See
[`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md)
for details.

## See also

[`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md)
