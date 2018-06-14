[![wercker status](https://app.wercker.com/status/ef9cd211a697b9ae558269dab4ee619e/s "wercker status")](https://app.wercker.com/project/bykey/ef9cd211a697b9ae558269dab4ee619e)
[![codecov](https://codecov.io/gh/cdiener/microbiome/branch/master/graph/badge.svg)](https://codecov.io/gh/cdiener/microbiome)
[![Docker Pulls](https://img.shields.io/docker/pulls/cdiener/microbiome.svg?maxAge=2592000)](https://hub.docker.com/r/cdiener/microbiome/)

# Microbiome project pipeline

This repo contains the standardized analysis pipeline for 16S and metagenome data. It serves as a testing ground for what will be required to analyze around 500 samples.

- For suggestions, open questions and bugs please use the [issue tracker](https://github.com/cdiener/microbiome/issues).
- Different pipelines are managed via branches. The master branch points to the default pipeline.
- The project itself is managed in the [Trello Board](https://trello.com/b/rHtrpyiz/microbiome)

For an examples analyzing a mock community see https://resendislab.github.io/microbiome.

## Installation

If you want to perform Human sequence removal you will need [bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml) installed and a human reference. The tools are bundled in the `mbtools` R package which also depends on all additional packages you need to run
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

### FAQ

- How do I change the password?
  Login to the rstudio account with the default credentials (user and password
  are "rstudio"). Click on the "Tools" in the menu bar and choose "Shell".
  Type "passwd" and Enter. You will be promted for the old and new password.
