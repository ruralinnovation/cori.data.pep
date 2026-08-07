## Documentation/comments
### 2000 reflects the earliest release
devtools::load_all(".")

latest_year = 2025

### check vintage
s3_vintageyr <- as.numeric(substr(latest_pep_vintage(), 9, 12))
if(latest_year <= s3_vintageyr){
  message("Latest year does not reflect a new release of data")
} else{
  stopifnot(nrow(pull_population(latest_year))>0)
  ## write new vintage
  write_pep_processed_to_s3(2000:latest_year)
}


