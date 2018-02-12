# Copyright 2017 Christian Diener <mail[at]cdiener.com>
#
# Apache license 2.0. See LICENSE for more information.

#' Plots counts for several taxa across a co-variable
#'
#' @param dds A DESeq2 data set.
#' @param variable The name of the co-variable.
#' @param taxa A character vector denoting the taxa to be plotted.
#' @param normalized Whether to normalize the counts using the DESeq2 size
#'  factors.
#' @param pc The pseudo count to add.
#' @param only_data Only get the raw data for the plot.
#' @return Nothing.
#' @examples
#'  NULL
#'
#' @export
#' @importFrom ggplot2 ggplot geom_boxplot facet_wrap scale_y_log10 xlab
plot_counts <- function(dds, variable, taxa = NULL,
                        normalized = TRUE, pc = 0.5, only_data = FALSE) {
    cn <- counts(dds, normalized = normalized)

    if (is.null(taxa)) {
        taxa <- rownames(cn)
    }

    dts <- lapply(taxa, function(ta) {
        data.table(counts = cn[ta, ], variable = variable,
                   value = dds[[variable]], taxa = ta)
    })
    dts <- rbindlist(dts)
    if (only_data) return(dts)

    pl <- ggplot(dts, aes(x = value, y = counts + pc, group=value)) +
          geom_boxplot() + facet_wrap(~ taxa) + scale_y_log10() +
          xlab(variable)

    return(pl)
}


shorten <- function(texts, n=40) {
    before <- sapply(texts, nchar)
    texts <- substr(texts, 1, n)
    after <- sapply(texts, nchar)
    texts[before > after] <- paste0(texts[before > after], "...")
    return(texts)
}


plot_taxa <- function(ps, level="Phylum", sort=TRUE,
                      max_taxa = 12, only_data = FALSE) {
    counts <- taxa_count(ps, lev=level)[, reads := as.double(reads)]
    counts[, reads := reads / sum(reads), by = "sample"]
    if (is.na(level)) {
        counts[, taxa := paste0(species, ": ", taxa)]
    }
    total_ord <- counts[, sum(reads, na.rm=TRUE), by = "taxa"][order(-V1), taxa]
    if (length(total_ord) > max_taxa) {
        total_ord <- total_ord[1:max_taxa]
        counts <- counts[taxa %in% total_ord]
    }
    sample_ord <- counts[taxa == total_ord[1]][order(-reads), sample]
    counts[, taxa := factor(taxa, levels=rev(total_ord))]
    counts[, sample := factor(sample, levels=sample_ord)]
    counts[, id := as.numeric(sample)]

    if (only_data) return(counts)

    pl <- ggplot(counts, aes(x=id, y=reads, fill=taxa)) +
        geom_bar(stat="identity", col=NA, width=1) +
        scale_x_continuous(expand = c(0, 1)) +
        scale_y_continuous(expand = c(0, 0.01)) +
        scale_fill_brewer(palette="Paired", direction = -1, label=shorten) +
        xlab("sample index") + ylab("% of reads") + labs(fill="") +
        theme_bw()

    return(pl)
}
