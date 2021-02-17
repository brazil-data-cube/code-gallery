set.seed(777)
library(sits)

#
# BDC Access definition
#
Sys.setenv(
  BDC_ACCESS_KEY = "My-Token"
)

#
# General definitions
#
classification_memsize    <- 20 # in GB
classification_multicores <- 20

start_date  <- "2018-09-01"
end_date    <- "2019-08-31"
collection  <- "S2_10_16D_STK-1"

# fixed parameters
collection  <- "S2_10_16D_STK-1"

# define the roi and load samples file
roi     <- readRDS(url("https://brazildatacube.dpi.inpe.br/geo-knowledge-hub/bdc-article/roi/roi.rds"))
samples <- readRDS(url("https://brazildatacube.dpi.inpe.br/geo-knowledge-hub/bdc-article/training-samples/rds/S2_10_16D_STK_1.rds"))

#
# Output directory
#
output_dir <- paste0(path.expand('~/work'), "/bdc-article", "/results", "/S2_10_16D_STK_1")

dir.create(
    path         = output_dir,
    showWarnings = FALSE,
    recursive    = TRUE
)

#
# Load data cube from BDC-STAC
#
cube <- sits_cube(
  type        = "BDC",
  name        = "cube_to_classify",
  url         = "https://brazildatacube.dpi.inpe.br/stac/",
  collection  = collection,
  start_date  = start_date,
  end_date    = end_date,
  tiles       = c("089098")
)

#
# Defining MLP Model
#
mlp_model <- sits_deeplearning(layers        = c(512, 512, 512, 512, 512),
                               activation    = "relu",
                               optimizer     = keras::optimizer_adam(lr = 0.001),
                               epochs        = 200)

#
# Training model
#
dl_model <- sits_train(samples, mlp_model)

#
# Classify using the data cubes
#
probs <- sits_classify(data       = cube,
                       ml_model   = dl_model,
                       memsize    = classification_memsize,
                       multicores = classification_multicores,
                       roi        = roi$classification_roi,
                       output_dir = output_dir)

#
# Post-processing
#
probs_smoothed <- sits_smooth(probs, type = "bayes", output_dir = output_dir)
labels         <- sits_label_classification(probs_smoothed, output_dir = output_dir)

#
# Saving results 
#

# labels
saveRDS(
    labels, file = paste0(output_dir, "/labels.rds")
)

# probs
saveRDS(
    probs, file = paste0(output_dir, "/probs_cube.rds")
)

# smoothed probs
saveRDS(
    probs_smoothed, file = paste0(output_dir, "/probs_smoothed_cube.rds")
)
