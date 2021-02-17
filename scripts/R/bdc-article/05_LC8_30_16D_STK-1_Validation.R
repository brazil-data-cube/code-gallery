library(sf)
library(sits)
library(raster)

#
# Load classification results
#
# Load classification results
output_dir <- paste0(path.expand('~/work'), "/bdc-article", "/results", "/LC8_30_16D_STK_1")

classification_results <- raster::stack(c(
    paste0(output_dir, "/cube_to_classify_044048_probs_class_2018_8_2019_7_v1.tif"),
    paste0(output_dir, "/cube_to_classify_044049_probs_class_2018_8_2019_7_v1.tif")
))

# Load classification reference
validation_samples <- readRDS(url("https://brazildatacube.dpi.inpe.br/geo-knowledge-hub/bdc-article/validation-samples/validation-samples.rds"))

#
# Extract predicted values from raster (Using validation samples locations)
#
predicted_values <- raster::extract(
  x = classification_results, 
  y = validation_samples$geom
)

#
# Transform values to PRODES Anthropic and Natural vegetation
#

# Pasture and Agriculture to PRODES Anthropic class
predicted_values[predicted_values == 98]  <- 2
predicted_values[predicted_values == 130] <- 2

# Natural Vegetation
predicted_values[predicted_values != 2] <- 1

#
# Generate confusion matrix and user/producer accuracy
#
sits_conf_matrix(list(
  predicted = predicted_values,
  reference = validation_samples$reference
))
