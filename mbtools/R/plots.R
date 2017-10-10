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

    pl <- ggplot(dts, aes(x = value, y = counts + pc, fill = value)) +
          geom_boxplot() + facet_wrap(~ taxa) + scale_y_log10() +
          xlab(variable)

    return(pl)
}
