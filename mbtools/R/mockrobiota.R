## Copyright 2016 Christian Diener <mail[at]cdiener.com>
##
## Apache license 2.0. See LICENSE for more information.

#' Downloads all files from a given FTP directory
#'
#' This can be used to download all file from a FTP directory.
#'
#' @param url URL to the directory.
#' @param outdir The output directory (will be created).
#' @param quiet Boolean. Whether the download should happen quietly.
#' @return A character vector of the downloaded filenames.
#' @examples
#'  NULL
#'
#' @export
#' @importFrom RCurl getURL
download_ftpdir <- function(url, outdir, quiet=FALSE) {
    files <- strsplit(getURL(url, dirlistonly=TRUE), "\n")[[1]]
    dir.create(outdir)
    sapply(files, function(f)
        download.file(paste0(url, "/", f), paste0(outdir, "/", f), quiet=quiet))
    return(files)
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
    snames <- unique(apply(taxa1[, 1:index], 1, paste, collapse=";"))
    snames <- snames[!is.na(snames) & nchar(snames) > 0]
    snames_ref <- apply(taxa2[, 1:index], 1, paste, collapse=";")
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
    if (colnames(taxa1) != colnames(taxa2))
        stop("Both taxonomy tables need to have the same column names!")

    metrics <- data.frame()
    for (cn in colnames(taxa1)) {
        found <- find_taxa(taxa1, taxa2, level=cn)
        new <- data.frame(level=cn, found=sum(found)/length(found))
        metrics <- rbind(metrics, new)
    }

    return(metrics)
}

#' Compares taxa quantification from a measurement to a reference ground truth.
#'
#' @param taxa1 Measured taxonomy quantities.
#' @param taxa2 Reference taxonomy quantities.
#' @return A scatter plot having the measured quantities on the x-axis and
#'  true quantities on the y-axis.
#' @examples
#'  NULL
#'
#' @export
taxa_quants <- function(taxa1, taxa2) {
    if (colnames(taxa1) != colnames(taxa2))
        stop("Both taxonomy tables need to have the same column names!")

    n <- ncol(taxa1)
    x <- data.frame()
    for (cn in colnames(taxa1)[-n]) {
        found <- find_taxa(taxa1, taxa2, level=cn)
        found <- names(found)[found]
        measured <- taxa1[, n]
        names(measured) <- apply(taxa1[, -n], 1, paste, collapse=";")
        reference <- taxa2[, n]
        names(reference) <- apply(taxa2[, -n], 1, paste, collapse=";")
        new <- data.frame(level=cn, name=found, measured=measured[found],
            reference=reference[found])
        x <- rbind(x, new)
    }

    return(x)
}
