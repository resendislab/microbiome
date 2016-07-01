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
