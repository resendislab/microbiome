## Copyright 2016 Christian Diener <mail[at]cdiener.com>
##
## Apache license 2.0. See LICENSE for more information.

#' Validates sequences barcodes versus a reference.
#'
#' This function will take each of the sequences barcodes and tries to find
#' the corresponding barcode from the reference set. After that it writes new
#' fastq files containing only the reads for which a barcode could be uniquely
#' identified.
#'
#' @param reads A character vector containing the read files in fastq format.
#' @param index The index file containing the demultiplexed barcodes for each
#'  read file.
#' @param out A folder to which to save the filtered fastq files.
#' @param ref A character vector or DNAStringSet containing the reference
#'  barcodes.
#' @param max_ed Maximum allowed edit distance between the sequenced and
#'  reference barcode.
#' @return A numeric vector containing three entries, where the first defines the
#'  reads that are kept.
#'  \itemize{
#'  \item{The number of reads that could be mapped uniquely.}
#'  \item{The number of reads for which no match was found.}
#'  \item{The number of reads for which more than one reference match was found.}
#'  }
#' @examples
#'  NULL
#'
#' @export
validate_barcodes <- function(reads, index, out, ref, max_ed=1) {
    stream <- open(FastqStreamer(index))
    on.exit(close(stream))

    dir.create(out)
    res <- c(unique=0, nomatch=0, multiple=0)

    repeat {
        fq <- yield(stream)
        if (length(fq) == 0) break

        hits <- rowSums(as.data.table(srdistance(fq, ref)) <= max_ed)
        writeFastq(fq[hits == 1], paste0(out, "/", index), "a")
        res <- res + c(sum(hits == 1), sum(hits == 0), sum(hits > 1))
    }

    return(res)
}
