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
#' @importFrom stringr str_match
#' @importFrom data.table data.table
sra_files <- function(path) {
    files <- list.files(path, pattern=".fastq\\.*gz*", full.names=TRUE)
    fwd <- grepl("_1.fastq", files)
    rev <- grepl("_2.fastq", files)
    if (any(fwd) && sum(fwd) != sum(rev)) {
        stop("Some paired files are missing!")
    }

    ids <- str_match(files, "([a-zA-Z\\d]+)_*\\d*\\.fastq")[, 2]

    if (any(fwd)) {
        return(data.table(id=ids[fwd], forward=files[fwd], reverse=files[rev]))
    }
    return(data.table(id=ids, forward=files))
}