% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ddcorAllParallelWorker.R
\name{ddcorAllParallelWorker}
\alias{ddcorAllParallelWorker}
\title{Worker thread for ddcorAllParallel (internal function).}
\usage{
ddcorAllParallelWorker(job, data, instance)
}
\arguments{
\item{job}{A batchtools job instance.}

\item{data}{A named list containing the program kwargs.}

\item{instance}{Required by batchtools, but not used currently.}
}
\value{
Typically, the returned object is a data frame of the table of differential correlations between conditions. In the case that dCorAvg is calculated, the returned object is instead a list containing that table as well as the object summarizing the difference in average correlation for the specified portion of the data set.
}
\description{
Runs the discovery of differential correlation (ddcor) section for comparing pairwise correlations across conditions in the Differential Gene Correlation Analysis (DGCA) package on a worker thread for two blocks of data (A and B).
}
