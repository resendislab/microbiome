## Copyright 2016 Christian Diener <mail[at]cdiener.com>
##
## Apache license 2.0. See LICENSE for more information.

# This is an example analyzing a single mock community from
# mockrobiota

devtools::load_all("../mbtools")
library(dada2)
library(ggplot2)

desc_url <- "https://github.com/caporaso-lab/mockrobiota/raw/master/data/mock-3/dataset-metadata.tsv"
sample_url <- "https://github.com/caporaso-lab/mockrobiota/raw/master/data/mock-3/sample-metadata.tsv"

desc <- read.table(desc_url, sep="\t", header=T)
samples <- read.table(sample_url, sep="\t", header=T, comment.char="")
snames <- gsub(".+\\.", "", samples[,1])
data_url <- desc[3, 2]

if (!dir.exists("mock3")) download_ftpdir(data_url, "mock3")

reads <- list.files("mock3", pattern="\\.R\\d\\.", full.names=T)
index <- "mock3/A0A3V.I1.fastq.gz"
bcs <- split_barcodes(reads, index, "split", samples$BarcodeSequence)
fwd <- list.files("split", pattern="\\.R1\\.", full.names=T)
bwd <- list.files("split", pattern="\\.R2\\.", full.names=T)

ggsave("fwd_quals.png", plotQualityProfile(fwd[[1]]))
ggsave("bwd_quals.png", plotQualityProfile(bwd[[1]]))

dir.create("filtered")
fwd_filt <- file.path("filtered", basename(fwd))
bwd_filt <- file.path("filtered", basename(bwd))
for (i in seq_along(fwd)) {
    fastqPairedFilter(c(fwd[i], bwd[i]), c(fwd_filt[i], bwd_filt[i]),
        truncLen=c(150, 100), maxEE=2, compress=T, verbose=T)
}

derepFs <- derepFastq(fwd_filt, verbose=TRUE)
derepRs <- derepFastq(fwd_filt, verbose=TRUE)
# Name the derep-class objects by the sample names
names(derepFs) <- names(derepRs) <- snames

dadaFs <- dada(derepFs, err=NULL, selfConsist = TRUE)
dadaRs <- dada(derepRs, err=NULL, selfConsist = TRUE)

seqtab <- cbind(makeSequenceTable(dadaFs), makeSequenceTable(dadaRs))
seqtab.nochim <- removeBimeraDenovo(seqtab, verbose=TRUE)

taxa <- assignTaxonomy(seqtab.nochim, "gg_13_8_train_set_97.fa.gz")
colnames(taxa) <- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")
taxa <- gsub(".\\__", "", taxa)
