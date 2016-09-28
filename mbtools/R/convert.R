# Copyright 2016 Christian Diener <mail[at]cdiener.com>
#
# Apache license 2.0.

ANN_RE <- "\\|NN=(.+)\\|D=(.+);"


hitdb_cleaner <- function(i, df, match, cutoff = 99) {
    xn <- df[i, 1]
    x <- df[i, 2]

    x <- sub("\\|.+;", ";", x)
    if (!is.na(match[i, 1]) && as.numeric(match[i, 3]) > cutoff) {
        x <- sub(xn, match[i, 2], x)
    } else x <- sub(xn, "unclassified", x)
    x
}

#' Converts taxa annotations from mothur format to dada2 format.
#'
#' @param seq_file A fasta file containing the (cluster) sequences.
#' @param taxa_file A tab-separated file with IDs on the first column and
#'  taxonomy in the second column.
#' @param out Filename for the compressed output file.
#' @return Nothing.
#' @examples
#'  NULL
#'
#' @export
mothur_to_dada <- function(seq_file, taxa_file, out = "taxonomy.fa.gz") {
    taxa_df <- read.table(taxa_file, header = FALSE)
    matches <- str_match(taxa_df[, 2], ANN_RE)

    taxa <- vapply(1:nrow(taxa_df), hitdb_cleaner, "", df = taxa_df,
                   match = matches)
    names(taxa) <- taxa_df[, 1]

    seqs <- readFasta(seq_file)
    ids <- as.character(id(seqs))
    seqs <- ShortRead(sread(seqs), BStringSet(taxa[ids]))
    writeFasta(seqs, out, compress = TRUE)
}
