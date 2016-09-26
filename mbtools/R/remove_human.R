# Copyright 2016 Christian Diener <mail[at]cdiener.com>
#
# Apache license 2.0. See LICENSE for more information.

HS_GENOME <- paste0("ftp://ftp.ensembl.org/pub/current_fasta/homo_sapiens/",
                    "dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz")

#' Builds index files for human sequence identification
#'
#' This function has to be run only once to enable analysis.
#'
#' @param where Where to save index files
#' @param genome_file The human genome to be used. NA means download a recent version.
#' @return Nothing.
#' @examples
#'  NULL
#'
#' @export
build_index <- function(where="./bmtagger", genome_file=NA) {
    dir.create(where, showWarnings = FALSE)

    if (is.na(genome_file)) {
        loc <- file.path(where, "hg38.fa.gz")
        cat("No genome file given, downloading hg38...\n")
        download.file(HS_GENOME, loc)
        cat("Extracting hg38...\n")
        genome_file <- gunzip(loc)
    }

    cat("Building reference bitmask...\n")
    system2("bmtool", c("-d", genome_file, "-o",
                        file.path(where, "ref.bitmask"), "-w", "18"))

    cat("Building srprism index...\n")
    system2("srprism", c("mkindex", "-i", genome_file, "-o",
                         file.path(where, "ref.srprism"), "-M", "7168"))

    cat("Building blast database...\n")
    system2("makeblastdb", c("-in", genome_file, "-dbtype", "nucl"))

}

#' Removes human sequences from a set of reads.
#'
#' This function uses bmtagger to identify and remove humans sequences. It requires
#' prior construction of the indices via \link{build_index}.
#'
#' @param reads A character vector containing the read files in fastq format.
#' @param out A folder to which to save the filtered fastq files.
#' @param index Additional barcode file that should be filtered as well.
#' @param where Where to find the previously generated index files.
#' @return A numeric vector with two entries. The number of sequences after
#'  filtering (non-human), and the number of removed sequences (human).
#' @examples
#'  NULL
#'
#' @export
remove_human <- function(reads, index=NA, out, where="./bmtagger") {
    paired <- length(reads) == 2 & !any(is.na(reads))

    if (paired) {
        reads <- vapply(reads, gunzip, "", remove = FALSE, skip = TRUE)
    } else reads <- gunzip(reads[1], remove = FALSE, skip = TRUE)

    if (!is.na(index)) index <- gunzip(index, remove = FALSE, skip = TRUE)

    cat("Finding human sequences...")
    if (!paired) {
        system2("bmtagger.sh", c("-b", file.path(where, "ref.bitmask"), "-x",
                                 file.path(where, "ref.srprism"), "-T",
                                 file.path(where), "-q", "1", "-1", "-o",
                                 file.path(where, "human.txt")))
    } else {
        system2("bmtagger.sh", c("-b", file.path(where, "ref.bitmask"), "-x",
                                 file.path(where, "ref.srprism"), "-T",
                                 file.path(where), "-q", "1", "-1",
                                 reads[1], "-2", reads[2], "-o",
                                 file.path(where, "human.txt")))
    }


    human_ids <- read.table(file.path(where, "human.txt"))[, 1]
    human_ids <- as.character(human_ids)
    new_files <- file.path(out, paste0(basename(reads), ".gz"))
    dir.create(out, showWarnings = FALSE)

    streams <- list(f = FastqStreamer(reads[1]))
    if (!is.na(index)) {
        streams$i <- FastqStreamer(index)
        new_files[3] <- file.path(out, paste0(basename(index), ".gz"))
    }
    if (paired) {
        streams$r <- FastqStreamer(reads[2])
    }

    counts <- vapply(1:length(streams), function(i) {
        n <- 0
        repeat {
            reads <- yield(streams[[i]])
            if (length(reads) == 0) break
            ids <- sub("/\\d+$", "", as.character(id(reads)))
            rem <- !(ids %in% human_ids)
            writeFastq(reads[rem], new_files[i])
            n <- n + length(reads[rem])
        }
        n
    },
    0)
    lapply(streams, close)

    return(c(reads = counts[1], removed = length(human_ids)))
}
