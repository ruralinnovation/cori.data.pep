# Package index

## Population Estimates

- [`get_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population.md)
  : Get Census Bureau population estimates
- [`get_population_change()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_population_change.md)
  : Get Census Bureau population change components

## Utilities

- [`get_pep_codebook()`](https://ruralinnovation.github.io/cori.data.pep/reference/get_pep_codebook.md)
  : Get the cori.data.pep variable codebook
- [`read_pep_from_s3()`](https://ruralinnovation.github.io/cori.data.pep/reference/read_pep_from_s3.md)
  **\[deprecated\]** : Read processed PEP data from S3
- [`latest_pep_vintage()`](https://ruralinnovation.github.io/cori.data.pep/reference/latest_pep_vintage.md)
  : Return the current latest PEP vintage from S3

## Internal

Functions for data processing and maintenance

- [`pull_components()`](https://ruralinnovation.github.io/cori.data.pep/reference/pull_components.md)
  : Pull components of population change across multiple years
- [`pull_pop_16plus()`](https://ruralinnovation.github.io/cori.data.pep/reference/pull_pop_16plus.md)
  : Pull population age 16 and over across multiple years
- [`pull_population()`](https://ruralinnovation.github.io/cori.data.pep/reference/pull_population.md)
  : Pull total county population across multiple years
- [`write_pep_processed_to_s3()`](https://ruralinnovation.github.io/cori.data.pep/reference/write_pep_processed_to_s3.md)
  : Write processed PEP data to S3 as a versioned vintage
