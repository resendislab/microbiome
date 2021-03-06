% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/shotgun.R
\name{run_slimm}
\alias{run_slimm}
\title{Quantifies abundances for the bacteria using SLIMM}
\usage{
run_slimm(alignments, slimm_db, reports = NULL)
}
\arguments{
\item{alignments}{A data frame as output by \code{\link{align_bowtie2}}}

\item{slimm_db}{Path for the SLIMM data base.}

\item{reports}{Path where to save the SLIMM reports. Uses a temporary
directory by default.}
}
\value{
Path to the slimm output.
}
\description{
Quantifies abundances for the bacteria using SLIMM
}
\examples{
 NULL

}
