# Copyright 2016 Christian Diener <mail[at]cdiener.com>
#
# Apache license 2.0. See LICENSE for more information.

#' Converts a mbquant object to a matrix.
#'
#' @param long_data A mbquant data table.
#' @return Nothing.
#' @examples
#'  NULL
#'
#' @export
#' @importFrom phyloseq otu_table tax_table
#' @importFrom data.table dcast rbindlist
as.matrix.mbquant <- function(long_data) {
    mat <- dcast(long_data, sample ~ taxa, value.var = "reads")
    samples <- mat[, sample]
    mat <- as.matrix(mat[, !"sample"])
    rownames(mat) <- samples
    return(mat)
}

#' Counts the reads for a specific taxonomy level.
#'
#' @param ps A phyloseq object.
#' @param lev The taxonomy level at which to count.
#' @return A mbquant data table containing the counts in "long" format.
#' @examples
#'  NULL
#'
#' @export
taxa_count <- function(ps, lev = "Genus") {
    otus <- as(otu_table(ps), "matrix")
    if (taxa_are_rows(ps)) {
        otus <- t(otus)
    }
    taxonomy <- as(tax_table(ps), "matrix")
    ilev <- which(colnames(taxonomy) == lev)
    taxa <- factor(apply(taxonomy, 1, "[", ilev))

    counts <- tapply(1:length(taxa), taxa, function(idx) {
        sums <- rowSums(otus[, idx, drop = FALSE])
        data.table(sample = sample_names(ps),
                   taxa = taxa[idx[1]],
                   reads = sums)
    }, simplify = FALSE)
    counts <- rbindlist(counts)
    class(counts) <- c("mbquant", class(counts))

    return(counts)
}
