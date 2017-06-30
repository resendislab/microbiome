# Copyright 2017 Christian Diener <mail[at]cdiener.com>
#
# Apache license 2.0. See LICENSE for more information.


#' List samples and read files in a directory.
#'
#' @param path Where to look for files.
#' @return A data frame with columns "id", "forward" and optionally "reverse".
#' @examples
#'  NULL
#'
#' @export
sra_files <- function(path) {
    files <- list.file(path, pattern=".fastq\\.*gz*", full.names=TRUE)
    fwd <- grepl(files, "_1.fastq")
    rev <- grepl(files, "_2.fastq")
    if (any(fwd) && sum(fwd) != sum(rev)) {
        stop("Some paired files are missing!")
    }

    ids <- str_match(files, "([\\w\\d]+)_*\\d*\\.fastq")[, 2]

    if (any(fwd)) {
        return(data.frame(id=ids, forward=files[fwd], reverse=files[rev]))
    }
    return(data.frame(id=ids, forward=files))
}