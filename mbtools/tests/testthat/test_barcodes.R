context("barcodes")

mb <- "https://github.com/caporaso-lab/mockrobiota/raw/master/data/"
mock_info <- paste0(mb, "mock-3/dataset-metadata.tsv")
mock_samples <- paste0(mb, "mock-3/sample-metadata.tsv")

test_that("barcode splitting/checking work", {
    # download an example data set
    info <- read.table(mock_info, sep = "\t", header = TRUE)
    ivec <- as.character(info[, 2])
    names(ivec) <- as.character(info[, 1])
    dir <- tempdir()
    download.file(ivec["raw-data-url-forward-read"],
        file.path(dir, "f.fastq.gz"), quiet = TRUE)
    download.file(ivec["raw-data-url-reverse-read"],
        file.path(dir, "r.fastq.gz"), quiet = TRUE)
    download.file(ivec["raw-data-url-index-read"],
        file.path(dir, "i.fastq.gz"), quiet = TRUE)
    samples <- read.table(mock_samples, header = TRUE)
    reads <- c(file.path(dir, c("f.fastq.gz", "r.fastq.gz")))
    index <- file.path(dir, "i.fastq.gz")
    bc <- split_barcodes(reads, index, file.path(dir, "filtered"),
        as.character(samples$BarcodeSequence))
    expect_true(55979 == bc[1])
    expect_true(0 == bc[2])
    expect_true(0 == bc[3])
    expect_error(split_barcodes(reads, index, file.path(dir, "filtered"),
        "ACGAT"))
})
