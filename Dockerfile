FROM rocker/rstudio
MAINTAINER "Christian Diener <mail[at]cdiener.com>"

# Setup bmtools
RUN cd /tmp && \
    wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/LATEST/ncbi-blast-2.6.0+-x64-linux.tar.gz && \
    tar xzf ncbi-blast-2.6.0+-x64-linux.tar.gz && \
    wget ftp://ftp.ncbi.nlm.nih.gov/pub/agarwala/bmtagger/bm* &&\
    wget ftp://ftp.ncbi.nlm.nih.gov/pub/agarwala/bmtagger/extract_fullseq && \
    wget  ftp://ftp.ncbi.nlm.nih.gov/pub/agarwala/bmtagger/srprism && \
    cp bm* extract_fullseq srprism ncbi-blast-2.6.0+/bin/blastn \
    ncbi-blast-2.6.0+/bin/makeblastdb /usr/bin && \
    cd /usr/bin && chmod +x bm* extract_fullseq srprism

# Setup dependencies
RUN Rscript -e "source('http://bioconductor.org/biocLite.R'); \
    biocLite('BiocInstaller'); setRepositories(ind=1:2); \
    install.packages('devtools'); \
    devtools::install_github('cdiener/microbiome/mbtools')" \
    && rm -rf /tmp/*

RUN mkdir /data
COPY docs/mock_example.rmd /data
RUN chown -R rstudio:rstudio /data
