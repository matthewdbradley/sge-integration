library(Seurat)
library(dplyr)
library(tidyverse)
library(BayesSpace)
library(purrr)
library(janitor)
library(magrittr)
library(purrr)
library(patchwork)
library(stringr)

#--------Setup-------

# Set this to your sge-integration folder
setwd("/home/bradlem4/sge-integration/")

# Save the Seurat object for use with other integration methods.
scRNA <- readRDS(scRNA, file = "data/scRNA/ureter-scRNA.Rds")

# Source the functions file to make them available to our active session of R
source("scripts/functions.R")


## ----- Load Visium samples ------
# This block of code will do a few things, but in short it will prepare the individual Visium samples for integration.
# If your single-cell data is normalized using SCTransform then you need to normalize your Visium data using SCTransform. In short, they just have to match. In order to SCT normalize your data, put "SCT" instead of "LogNormalize" below. 

U1.Seurat <- preProcessSeuratVisium("data/U1", normalization = "LogNormalize")
U2.Seurat <- preProcessSeuratVisium("data/U2", normalization = "LogNormalize")

#----- Perform anchor mapping----

# This function will find "anchor" genes that are represented prominently in both the scRNA and SGE data. It will then use these to help approximate the distribution of single-cell identities in the spatial data.
U1.Seurat <- anchorMapping(scRNA, U1.Seurat, feats = genes, query.dims=30, anchor.labels = levels(as.factor(scRNA$subclass)))
U2.Seurat <- anchorMapping(scRNA, U2.Seurat, feats = genes, query.dims=30, anchor.labels=levels(as.factor(scRNA$subclass)))

# Plot the predictions made by the single-cell data
scplots <- purrr::map(levels(as.factor(scRNA$subclass)), function(x) SpatialFeaturePlot(U1.Seurat, x))
patchwork::wrap_plots(scplots, ncol=4) %T>% ggsave(filename = "figures/Seurat/Figure_1a.pdf", width = 25, height = 25, units = "in", dpi = 300)

scplots <- purrr::map(levels(as.factor(scRNA$subclass)), function(x) SpatialFeaturePlot(U2.Seurat, x))
patchwork::wrap_plots(scplots, ncol=4) %T>% ggsave(filename = "figures/Seurat/Figure_1b.pdf", width =25, height = 25, units = "in", dpi = 300)

