## Copyright 2016 Christian Diener <mail[at]cdiener.com>
##
## Apache license 2.0. See LICENSE for more information.

# This is an example analyzing a single mock community from
# mockrobiota

devtools::load_all("../mbtools")
library(dada2)
library(ggplot2)

if (!file.exists("mock3.rds")) {
    mock <- mockrobiota("mock-3", "mock3")
    saveRDS(mock, "mock3.rds")
} else mock <- readRDS("mock3.rds")

reads <- c(mock$forward, mock$reverse)
barcodes <- mock$samples$BarcodeSequence
names(barcodes) <- gsub(".+\\.", "", mock$samples[,1])
bcs <- split_barcodes(reads, mock$index, "split", barcodes)
fwd <- list.files("split", pattern="forward", full.names=T)
bwd <- list.files("split", pattern="reverse", full.names=T)

ggsave("fwd_quals.png", plotQualityProfile(reads[1]))
ggsave("bwd_quals.png", plotQualityProfile(reads[2]))

dir.create("filtered")
fwd_filt <- file.path("filtered", basename(fwd))
bwd_filt <- file.path("filtered", basename(bwd))
for (i in seq_along(fwd)) {
    fastqPairedFilter(c(fwd[i], bwd[i]), c(fwd_filt[i], bwd_filt[i]),
        truncLen=c(150, 100), compress=T, verbose=T)
}

derepFs <- derepFastq(fwd_filt, verbose=TRUE)
derepRs <- derepFastq(bwd_filt, verbose=TRUE)
# Name the derep-class objects by the sample names
names(derepFs) <- names(derepRs) <- names(barcodes)

dadaFs <- dada(derepFs, err=NULL, selfConsist = TRUE)
dadaRs <- dada(derepRs, err=NULL, selfConsist = TRUE)

seqtab <- cbind(makeSequenceTable(dadaFs), makeSequenceTable(dadaRs))
seqtab.nochim <- removeBimeraDenovo(seqtab, verbose=TRUE)

taxa <- assignTaxonomy(seqtab.nochim, "gg_13_8_train_set_97.fa.gz")
colnames(taxa) <- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")
