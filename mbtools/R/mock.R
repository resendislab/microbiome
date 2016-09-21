# Copyright 2016 Christian Diener <mail[at]cdiener.com>
#
# Apache license 2.0. See LICENSE for more information.

# So check does not complain :()
utils::globalVariables(c("reference", "measured", "level"))

# mockrobiota base address
mb <- "https://raw.githubusercontent.com/caporaso-lab/mockrobiota/master/data/"
dl <- c("raw-data-url-forward-read", "raw-data-url-reverse-read",
        "raw-data-url-index-read")

download_reads <- function(url, folder, quiet) {
    if (is.na(url)) return(NA)
    p <- file.path(folder, basename(url))
    download.file(url, p, quiet = quiet)
    p
}

#' Downloads a complete data set from mockrobiota.
#'
#' @param name Name of the mockrobiota data set.
#' @param folder Where to save the data.
#' @param quiet Whether to show download progress.
#' @return A list with the following components
#' \describe{
#' \item{description}{A description of the data set.}
#' \item{forward}{Filepath to the forward reads.}
#' \item{reverse}{Filepath to the reverse reads.}
#' \item{index}{Filepath to the index file.}
#' \item{citation}{Reference for the data set.}
#' \item{fragment}{Which fragment(s) were sequenced.}
#' \item{equipment}{The used sequencing equipment.}
#' \item{samples}{A data frame mapping samples to barcodes.}
#' \item{tax_gg}{The reference taxonomy for green genes.}
#' \item{tax_silva}{The reference taxonomy for silva.}
#'}
#' @examples
#'  NULL
#'
#' @export
mockrobiota <- function(name, folder, quiet=!interactive()) {
    mock_info <- sprintf("%s/%s/dataset-metadata.tsv", mb, name)
    mock_samples <- sprintf("%s/%s/sample-metadata.tsv", mb, name)
    info <- read.table(mock_info, sep = "\t", header = TRUE)
    ivec <- as.character(info[, 2])
    names(ivec) <- as.character(info[, 1])

    dir.create(folder, showWarnings = FALSE)

    downloaded <- vapply(ivec[dl], download_reads, "", folder = folder,
                         quiet = quiet)
    samples <- read.table(mock_samples, header = TRUE)

    gg <- sprintf("%s/%s/greengenes/13_8/expected-taxonomy.tsv", mb, name)
    gg <- read.table(gg, header = TRUE, sep = "\t")
    silva <- sprintf("%s/%s/silva/119/expected-taxonomy.tsv", mb, name)
    silva <- read.table(silva, header = TRUE, sep = "\t")

    list(
        description = ivec["human-readable-description"],
        forward = downloaded[1],
        reverse = downloaded[2],
        index = downloaded[3],
        citation = ivec["citation"],
        fragment = ivec["target-subfragment"],
        equipment = ivec["sequencing-instrument"],
        samples = samples,
        tax_gg = gg,
        tax_silva = silva
    )
}

taxa_str <- function(taxa, level) {
    index <- which(colnames(taxa) == level)
    bad <- apply(taxa[, 1:index, drop = FALSE], 1, function(x)
        any(is.na(x) | nchar(x) == 0))
    strs <- apply(taxa[, 1:index, drop = FALSE], 1, paste, collapse = ";")
    strs[bad] <- NA
    return(strs)
}

#' Checks whether taxa from one taxonomy table are contained in another table.
#'
#' This function takes two taxonomy tables, than looks for each sample of the first
#' table in the second one.
#'
#' @param taxa1 First taxonomy table.
#' @param taxa2 Second taxonomy table.
#' @param level At which level to compare. Must be column name in both tables.
#' @return A data frame with two columns. Has as many rows as unique values in level.
#' \describe{
#' \item{level}{The unique values found for the specified taxa level.}
#' \item{found}{A boolean indicating whether the taxa were found in the second table.}
#'}
#' @examples
#'  NULL
#'
#' @export
find_taxa <- function(taxa1, taxa2, level="Species") {
    if (!(level %in% colnames(taxa1) && level %in% colnames(taxa2)))
        stop("level must be a valid column name in both tables!")

    index <- which(colnames(taxa1) == level)
    snames <- unique(taxa_str(taxa1, level))
    snames <- snames[!is.na(snames)]
    snames_ref <- taxa_str(taxa2, level)
    found <- snames %in% snames_ref
    names(found) <- snames

    return(found)
}

#' Calculates what percentage of taxa was found in a reference set.
#'
#'
#' @param taxa1 First taxonomy table.
#' @param taxa2 Second taxonomy table.
#' @return A bar plot denoting the percentage of correctly identified taxa.
#' @examples
#'  NULL
#'
#' @export
taxa_metrics <- function(taxa1, taxa2) {
    if (any(colnames(taxa1) != colnames(taxa2)))
        stop("Both taxonomy tables need to have the same column names!")

    metrics <- data.frame()
    for (cn in colnames(taxa1)) {
        found <- find_taxa(taxa1, taxa2, level = cn)
        new <- data.frame(level = cn, found = sum(found) / length(found),
            n = length(found))
        metrics <- rbind(metrics, new)
    }

    return(metrics)
}

#' Compares taxa quantification from a measurement to a reference ground truth.
#'
#' @param taxa1 Measured taxonomy quantities.
#' @param taxa2 Reference taxonomy quantities.
#' @return A data frame with the following columns:
#'  \describe{
#'  \item{level}{The taxonomy level for the entry.}
#'  \item{name}{The taxonomy.}
#'  \item{measured}{The measured quantification.}
#'  \item{measured}{The reference quantification.}
#' }
#' @examples
#'  NULL
#'
#' @export
taxa_quants <- function(taxa1, taxa2, normalize = FALSE) {
    if (any(colnames(taxa1) != colnames(taxa2)))
        stop("Both taxonomy tables need to have the same column names!")

    n <- ncol(taxa1)
    taxa1 <- as.data.frame(taxa1)
    taxa2 <- as.data.frame(taxa2)

    if (normalize) {
        taxa1[, n] <- taxa1[, n] / sum(taxa1[, n])
        taxa2[, n] <- taxa2[, n] / sum(taxa2[, n])
    }

    x <- data.frame()
    for (cn in colnames(taxa1)[-n]) {
        index <- which(colnames(taxa1) == cn)
        found <- find_taxa(taxa1, taxa2, level = cn)
        found <- names(found)[found]
        measured <- taxa1[, n]
        tax_m <- taxa_str(taxa1, cn)
        measured <- tapply(measured, tax_m, sum, na.rm = TRUE)
        reference <- taxa2[, n]
        tax_r <- taxa_str(taxa2, cn)
        reference <- tapply(reference, tax_r, sum, na.rm = TRUE)
        new <- data.frame(level = cn, name = found, measured = measured[found],
            reference = reference[found])
        x <- rbind(x, new)
    }

    return(x)
}

#' Creates a plot of measured taxa quantifications vs. reference quantification.
#'
#' @param taxa1 Measured taxonomy quantities.
#' @param taxa2 Reference taxonomy quantities.
#' @return A ggplot2 plot.
#' @examples
#'  NULL
#'
#' @export
mock_plot <- function(taxa1, taxa2) {
    quants <- taxa_quants(taxa1, taxa2, normalize = TRUE)
    ggplot(quants, aes(x = reference, y = measured)) +
        geom_abline(alpha = 0.5) + geom_point(aes(col = level)) +
        facet_wrap(~ level, scales = "free") + theme_bw() +
        theme(legend.position = "none")
}
