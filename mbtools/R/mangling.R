# Copyright 2016 Christian Diener <mail[at]cdiener.com>
#
# Apache license 2.0. See LICENSE for more information.

#' @importFrom phyloseq otu_table tax_table
#' @importFrom data.table dcast rbindlist
as.matrix.mbquant <- function(long_data) {
    mat <- dcast(long_data, sample ~ taxa, value.var = "reads")
    samples <- mat[, sample]
    mat <- as.matrix(mat[, !"sample"])
    rownames(mat) <- samples
    return(mat)
}

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
