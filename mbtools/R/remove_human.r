# Copyright 2016 Christian Diener <mail[at]cdiener.com>
#
# Apache license 2.0. See LICENSE for more information.

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

}

#' Removes human sequences from a set of reads.
#'
#' This function uses bmtagger to identify and remove humans sequences. It requires
#' prior construction of the indices via \link{build_index}.
#'
#' @param reads A character vector containing the read files in fastq format.
#' @param out A folder to which to save the filtered fastq files.
#' @param barcode_files Additional barcode file that should be filtered as well.
#' @param index Where to find the previously generated index files.
#' @return A numeric vector with two entries. The number of sequences after
#'  filtering (non-human), and the number of removed sequnces (human).
#' @examples
#'  NULL
#'
#' @export
remove_human <- function(reads, out, barcode_files=NA, index="./bmtagger") {

}
