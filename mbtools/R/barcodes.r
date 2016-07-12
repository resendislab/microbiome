## Copyright 2016 Christian Diener <mail[at]cdiener.com>
##
## Apache license 2.0. See LICENSE for more information.

#' Splits FASTQ files into individual samples.
#'
#' This function will take each of the sequences barcodes and tries to find
#' the corresponding barcode from the reference set. After that it writes new
#' fastq files containing only the reads for a single barcode.
#'
#' @param reads A character vector containing the read files in fastq format.
#' @param index The index file containing the demultiplexed barcodes for each
#'  read file.
#' @param out A folder to which to save the split fastq files.
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
split_barcodes <- function(reads, index, out, ref, snames=NULL, max_ed=1) {
    if (is.null(snames)) snames <- paste0("S", 1:length(ref))
    ref <- DNAStringSet(ref)

    istream <- FastqStreamer(index)
    on.exit(close(istream))

    rstream <- lapply(reads, FastqStreamer)

    if (dir.exists(out)) {
        unlink(file.path(out, "*.fastq.gz"))
    } else dir.create(out)
    res <- c(unique=0, nomatch=0, multiple=0)

    repeat {
        fq <- yield(istream)
        if (length(fq) == 0) break

        ids <- sub("/.+$", "", id(fq))

        hits <- as.data.table(srdistance(fq, ref)) <= max_ed
        inds <- apply(hits, 1, function(x) {
            id <- which(x)
            if (length(id) != 1) return(NA)
            else return(id)
        })


        for (i in 1:length(rstream)) {
            rfq <- yield(rstream[[i]])
            rids <- sub("/.+$", "", id(rfq))
            if (any(rids != ids)) stop("Index file and reads do not match!")
            fn <- basename(reads[i])

            for (sid in 1:length(ref)) {
                writeFastq(rfq[inds == sid], file.path(out, paste0(snames[sid], "_", fn)), "a")
            }
        }

        hits <- rowSums(hits)
        res <- res + c(sum(hits == 1), sum(hits == 0), sum(hits > 1))
    }
    for (s in rstream) { close(s) }

    return(res)
}

#' Assigns sample IDs from barcodes
#'
#' @param index Path to the FASTQ index file.
#' @param A vector of barcodes, one for each sample.
#' @return A vector with an ID for each sample in the index file.
#' @examples
#'  NULL
#'
#' @export
#' @importFrom Biostrings DNAStringSet
assign_barcodes <- function(index, barcodes) {
    istream <- FastqStreamer(index)
    on.exit(close(istream))
    barcodes <- DNAStringSet(barcodes)

    res <- NULL

    repeat {
        fq <- yield(istream)
        if (length(fq) == 0) break

        dists <- as.data.table(srdistance(fq, barcodes))
        ids <- apply(dists, 1, function(x) which(x == 0))
        res <- append(res, ids)
    }

    return(res)
}
