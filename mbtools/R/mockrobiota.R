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

    levels <- unique(taxa1[, level])
    found <- levels %in% unique(taxa2[, level])

    return(data.frame(level=levels, found=found))
}
