# For CORI data engineers

To refresh the S3 data after Census releases new estimates run `refresh_pep.R` with the latest available years starting in 2000.

See `?write_pep_processed_to_s3` for options including `overwrite` and `s3_path_prefix` for testing.
