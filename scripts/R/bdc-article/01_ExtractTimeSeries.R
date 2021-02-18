set.seed(777)
library(sits)

#
# BDC Access definition
#
Sys.setenv(
  BDC_ACCESS_KEY = "My-Token"
)

#
# Auxiliary function
#
extract_ts_by_sample_location <- function(collection, start_date, end_date, bands, sample_file) {
  cube <- sits_cube(
    type        = "BDC",
    name        = "cube_to_extract_sample",
    url         = "https://brazildatacube.dpi.inpe.br/stac/",
    collection  = collection,
    start_date  = start_date,
    end_date    = end_date,
    bands       = bands
  )
  
  samples <- sits_get_data(cube = cube, file = sample_file)
  samples
}

#
# General definitions
#
start_date  <- "2018-09-01"
end_date    <- "2019-08-31"
sample_file <- "https://brazildatacube.dpi.inpe.br/geo-knowledge-hub/bdc-article/training-samples/training-samples.csv"

#
# Output directory
#
output_dir <- paste0(path.expand('~/work'), "/bdc-article", "/training-samples")
dir.create(
    path         = output_dir, 
    showWarnings = FALSE, 
    recursive    = TRUE
)

#
# Sentinel-2/MSI (16 days 'stack')
#
cb4_samples_with_ts <- extract_ts_by_sample_location(
  collection  = "S2_10_16D_STK-1",
  start_date  = start_date,
  end_date    = end_date, 
  bands       = c("band4", "band3", "band2", "band8", "NDVI", "EVI"),
  sample_file = sample_file
)
saveRDS(cb4_samples_with_ts, paste0(output_dir, "/CB4_64_16D_STK_1.rds"))

#
# Landsat-8/OLI (16 days 'stack')
#
l8_samples_with_ts <- extract_ts_by_sample_location(
  collection  = "LC8_30_16D_STK-1",
  start_date  = start_date,
  end_date    = end_date, 
  bands       = c("band4", "band3", "band2", "band5", "NDVI", "EVI"),
  sample_file = sample_file
)
saveRDS(l8_samples_with_ts, paste0(output_dir, "/LC8_30_16D_STK_1.rds"))

#
# CBERS-4/AWFI (16 days 'stack')
#
s2_samples_with_ts <- extract_ts_by_sample_location(
  collection  = "CB4_64_16D_STK-1",
  start_date  = start_date,
  end_date    = end_date, 
  bands       = c("BAND15", "BAND14", "BAND13", "BAND16", "NDVI", "EVI"),
  sample_file = sample_file
)
saveRDS(s2_samples_with_ts, paste0(output_dir, "/S2_10_16D_STK_1.rds"))
