% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/permQValue.R
\name{permQValue}
\alias{permQValue}
\title{Calculate q-values from DGCA class objects based on permutation-based empirical null statistics.}
\usage{
permQValue(dcObject, permObject, secondMat, testSlot, verbose = FALSE,
  plotFdr = FALSE, empOnly = FALSE)
}
\arguments{
\item{dcObject}{The original S4 class object containing the test statistics to be extracted.}

\item{permObject}{The array of matrices containing the null test statistics.}

\item{secondMat}{Logical, indicating whether a second matrix was used in the construction of this dcObject and permObject. If FALSE, the upper.tri of both are extracted to avoid double counting test statistics.}

\item{testSlot}{The slot of the dcObject to be removed for use as the actual test statistic.}

\item{verbose}{Whether summaries of the q-value operations should be reported.}

\item{plotFdr}{Allows for plotting of fdrtool p-value adjustment result OR empirical FDR q-value adjustment technique, if either of these are chosen. Requires fdrtool package OR qvalue package. Default = FALSE.}

\item{empOnly}{Whether or not we don't want to calculate qvalues for the empirical pvalues. Default = FALSE.}
}
\value{
A list containing a vectof of empirical p-values and a vector of q-values, both of the same length as the original actual test statistics.
}
\description{
First, estimate empirical p-values based on a comparison of the actual and permuted test statistics. Next, estimate the proportion of true null hypotheses using the qvalue package as well as qvalues from the empirical p-values, using this value. If the estimated pi0 <= 0, then sequentially recalculates using increasingly conservative set of lambda values, until lambda = 0.5.
}
