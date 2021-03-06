# DGCA (2.0 version)

The goal of DGCA is to calculate differential correlations across conditions.

It simplifies the process of seeing whether two correlations are different without having to rely solely on parametric assumptions by leveraging non-parametric permutation tests and adjusting the resulting empirical p-values for multiple corrections using the qvalue R package.

It also has several other options including calculating the average differential correlation between groups of genes, gene ontology enrichment analyses of the results, and differential correlation network identification via integration with MEGENA. 

Changes from CRAN version (1.0.2):

* Can handle a very large number of features (20k -> 1 million or more) by splitting up correlation matrix into sections and submitting them to separate nodes as batch jobs or sequentially on a low-memory machine
  * Collects results automatically and writes them out in batches
* Parallel correlation matrix and permutation matrix generation on each node (handles many permutations)
* Speed improvements, even in single core mode
* Fastest update yet – completed Lei’s F.AD vs M.AD RNA+CNV dataset in 2.5 hours (whereas previously would have taken ~35.7 days in single-threaded mode)
* Bugfix in correlation cutoff function: did not properly calculate p-values when R2 is < -0.99 (drops significant correlations or raises errors)
  * Necessary for discrete data like CNVs, genetics, clinical features
* Bugfix in gene filtering: possible divide by zero for discrete features if the mean of all observations is exactly zero
* Bugfix in qvalue function: automatically picks the best lambda sequence for the input data (previous versions would not report lambda if there were errors)
* Bugfix where DGCA would crash during the empirical p-value calculation step if there were too many elements
* Can adjust non-empirical p-values by q-value in adjustPVals (Storey et al., 2002)
* Fuzzy permutation adjustment of p-values, especially useful for discrete data like CNVs (Yang et al., Nat Sci Rep 2016)


## Installation

You can install the development version of DGCA from github with:

```R
install.packages("devtools","withr","memoise","httr","R6","curl")
source("https://bioconductor.org/biocLite.R")
biocLite()
withr::with_libpaths("~/.RlibDGCA",devtools::install_github("nosarcasm/DGCA",repos=biocinstallRepos()))
```
i
## Basic Example

```R
library(DGCA)
data(darmanis); data(design_mat)
ddcor_res = ddcorAll(inputMat = darmanis, design = design_mat, compare = c("oligodendrocyte", "neuron"))
head(ddcor_res, 3)
#   Gene1  Gene2 oligodendrocyte_cor oligodendrocyte_pVal neuron_cor neuron_pVal
# 1 CACYBP   NACA        -0.070261455           0.67509118  0.9567267           0
# 2 CACYBP    SSB        -0.055290516           0.74162636  0.9578999           0
# 3 NDUFB9    SSB        -0.009668455           0.95405875  0.9491904           0
#   zScoreDiff     pValDiff     empPVals pValDiff_adj Classes
# 1  10.256977 1.100991e-24 1.040991e-05    0.6404514     0/+
# 2  10.251847 1.161031e-24 1.040991e-05    0.6404514     0/+
# 3   9.515191 1.813802e-21 2.265685e-05    0.6404514     0/+
```

## Vignettes

There are three vignettes available in order to help you learn how to use the package:

- [DGCA Basic](http://htmlpreview.github.io/?https://github.com/andymckenzie/DGCA/blob/master/vignettes/DGCA_basic.html): This will get you going quickly.
- [DGCA](http://htmlpreview.github.io/?https://github.com/andymckenzie/DGCA/blob/master/inst/doc/DGCA.html): This is a more extended version that explains a bit about how the package works and shows several of the options available in the package.
- [DGCA Modules](https://github.com/andymckenzie/DGCA/blob/master/inst/doc/DGCA_modules.pdf): This will show you how to use the package to perform module-based and network-based analyses.

The second two vignettes can be found in inst/doc.

## Applications

You can view the manuscript describing DGCA in detail as well as several applications here:

- http://bmcsystbiol.biomedcentral.com/articles/10.1186/s12918-016-0349-1

Material for associated simulations and networks created from MEGENA can be found here:

- https://github.com/andymckenzie/dgca_manuscript
