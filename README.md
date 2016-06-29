# Microbiome project pipeline

This repo contains the standardized analysis pipeline for 16S and metagenome data. It serves as a testing ground for what will be required to analyze around 500 samples. 

- For suggestions, open questions and bugs please use the [issue tracker](https://github.com/cdiener/microbiome/issues). 
- Different pipelines are managed via branches. The master branch points to the default pipeline.
- The project itself is managed in the [Trello Board](https://trello.com/b/rHtrpyiz/microbiome)

## Installation

If you want to perform Human sequence removal you will need [bmtagger](ftp://ftp.ncbi.nlm.nih.gov/pub/agarwala/bmtagger/) installed. The tools are bundled in the `mbtools` R package which also depends on all additional packages you need to run 
the analyses. You will need to [install bioconductor first](https://www.bioconductor.org/install/) followed by running 

```R
install.packages('devtools')
devtools::install_github('cdiener/microbiome/mbtools')
```

in R.

Alternatively you can use the Docker image which is built and kept up to date automatically by watching this repo. For this
you will require a [local installation](https://www.docker.com/products/docker-toolbox) with Docker or a cloud instance which can run docker (for instance CoreOS VMs on AWS or Google Cloud).

## Using the docker image

First get the image with

```bash
docker pull cdiener/microbiome
```

You can now start a Rstudio instance at port 8000 using

```
docker run -d -p 8000:8787 cdiener/microbiome
```

Now navigate your browser to <your-ip>:8000 (for instance localhost:8000 if you run docker on your machine) and you will be prompted for user credentials (use "rstudio" for user and password). All packages and dependencies are already installed here.
