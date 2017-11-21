# Copyright 2016 Christian Diener <mail[at]cdiener.com>
#
# Apache license 2.0. See LICENSE for more information.

#' Convert a mbquant data table to a matrix.
#'
#' @param x the mbquant data table.
#' @param ... additional arguments.
#' @return A matrix with samples on the rows and taxa on the columns.
#' @examples
#'  NULL
#'
#' @export
#' @importFrom phyloseq otu_table tax_table
#' @importFrom data.table dcast rbindlist as.data.table melt
as.matrix.mbquant <- function(x, ...) {
    mat <- dcast(x, sample ~ taxa, value.var = "reads")
    samples <- mat[, sample]
    mat <- as.matrix(mat[, !"sample"])
    rownames(mat) <- samples
    return(mat)
}

#' Counts the reads for a specific taxonomy level.
#'
#' @param ps A phyloseq object.
#' @param lev The taxonomy level at which to count. If NA uses the finest level
#'  available (individual sequences).
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

    if (is.na(lev)) {
        counts <- as.data.table(otus, keep.rownames = TRUE)
        counts <- melt(counts, id.vars = "rn")
        names(counts) <- c("sample", "taxa", "reads")
    } else {
        ilev <- which(colnames(taxonomy) == lev)
        taxa <- factor(apply(taxonomy, 1, "[", ilev))

        counts <- tapply(1:length(taxa), taxa, function(idx) {
            sums <- rowSums(otus[, idx, drop = FALSE])
            data.table(sample = sample_names(ps),
                    taxa = taxa[idx[1]],
                    reads = sums)
        }, simplify = FALSE)
        counts <- rbindlist(counts)
    }
    class(counts) <- c("mbquant", class(counts))

    return(counts)
}


#' Applies the specified types to a data frame-like object.
#'
#' @param df A data frame, data table or tibble.
#' @param types A data frame with two columns: name and type.
#' @return The same frame with updated column types.
#' @examples
#'  NULL
#'
#' @export
types <- function(df, types) {
    for (i in 1:nrow(types)) {
        name <- types$name[i]
        type <- types$type[i]
        df[[name]] <- do.call(paste0("as.", type), list(df[[name]]))
    }

    return(df)
}


#' Discretize all continuous variables in a data frame.
#'
#' This function will attempt to balance the groups so they contain similar
#' numbers of elements.
#'
#' @param df A data frame-like object.
#' @param groups The number of groups into which to separate the data.
#' @return The same data fram with updated columns.
#' @examples
#'  NULL
#'
#' @export
#' @importFrom Hmisc cut2
discretize <- function(df, groups = 3) {
    for (col in names(df)) {
        if (is.numeric(df[[col]])) {
            df[[col]] <- cut2(df[[col]], g = groups)
        }
    }

    return(df)
}


#' Standardize all continuous columns of a data frame.
#'
#' @param df A data frame-like object.
#' @return The same data frame with standardized columns.
#' @examples
#'  NULL
#'
#' @export
#' @importFrom stats sd
standardize <- function(df) {
    for (col in names(df)) {
        if (is.numeric(df[[col]])) {
            df[[col]] <- (df[[col]] - mean(df[[col]], na.rm = TRUE))
            df[[col]] <- df[[col]] / sd(df[[col]], na.rm = TRUE)
        }
    }

    return(df)
}
