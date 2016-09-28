#!/usr/bin/env Rscript

# Copyright 2016 Christian Diener <mail[at]cdiener.com>
#
# Apache license 2.0.

library(mbtools)

VERSION <- "v1.00"
REPO <- sprintf("https://github.com/microbiome/HITdb/raw/master/HITdb_%s/",
                VERSION)

d <- tempdir()
inst <- file.path("..", "mbtools", "inst", "extdata")
download.file(paste0(REPO, "HITdb_sequences.fna"), file.path(d, "hitdb.fa"),
    quiet = TRUE)
download.file(paste0(REPO, "HITdb_taxonomy_mothur.txt"),
    file.path(d, "taxa.tsv"), quiet = TRUE)

target <- file.path(inst, sprintf("hitdb_%s.fa.gz", VERSION))
if (file.exists(target)) file.remove(target)
mothur_to_dada(file.path(d, "hitdb.fa"), file.path(d, "taxa.tsv"),
    target)

cat(sprintf("Converted HITdb saved to %s.\n", target))
