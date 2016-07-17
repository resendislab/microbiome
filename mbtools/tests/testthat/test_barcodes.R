context("barcodes")

mock_info <- "https://github.com/caporaso-lab/mockrobiota/raw/master/data/mock-3/dataset-metadata.tsv"
mock_samples <- "https://github.com/caporaso-lab/mockrobiota/raw/master/data/mock-3/sample-metadata.tsv"

test_that("barcode splitting/checking work", {
    # download an example data set
    url <- read.table(mock_info, sep="\t", header=TRUE)[3,2]
    dir <- tempdir()
    download_ftpdir(url, dir, quiet=TRUE)
    samples <- read.table(mock_samples, header=FALSE)
    reads <- list.files(dir, pattern="\\.R\\d", full.names=TRUE)
    index <- list.files(dir, pattern="\\.I1", full.names=TRUE)
    bc <- split_barcodes(reads, index, file.path(dir, "filtered"),
        as.character(samples[,2]))
    expect_true(55979 == bc[1])
    expect_true(0 == bc[2])
    expect_true(0 == bc[3])
    expect_error(split_barcodes(reads, index, file.path(dir, "filtered"),
        "ACGAT"))
})
