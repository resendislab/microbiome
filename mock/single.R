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
tax_url <- "https://github.com/caporaso-lab/mockrobiota/raw/master/mock-3/source/taxonomy.tsv"

#download.file(desc_url, "dataset-metadata.tsv")
#download.file(sample_url, "sample-metadata.tsv")
#download.file(tax_url, "taxonomy.tsv")

desc <- read.table(desc_url, sep="\t", header=T)
samples <- read.table(sample_url, sep="\t", header=T, comment.char="")
data_url <- desc[3, 2]

if (!dir.exists("mock3")) download_ftpdir(data_url, "mock3")

reads <- list.files("mock3", pattern="\\.R\\d\\.", full.names=T)
index <- list.files("mock3", pattern="\\.I1\\.", full.names=T)
barcodes <- samples$BarcodeSequence
names(barcodes) <- gsub(".+\\.", "", samples[,1])
bcs <- split_barcodes(reads, index, "split", barcodes)
fwd <- list.files("split", pattern="\\.R1\\.", full.names=T)
bwd <- list.files("split", pattern="\\.R2\\.", full.names=T)

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
