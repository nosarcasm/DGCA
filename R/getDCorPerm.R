#' @title Get permuted groupwise correlations and pairwise differential correlations. 
#' @description Takes input and methods and randomly permutes the data to do getCor as well as group-specific pairwiseDCor.
#' @param inputMat The matrix (or data.frame) of values (e.g., gene expression values from an RNA-seq or microarray study) that you are interested in analyzing. The rownames of this matrix should correspond to the identifiers whose correlations and differential correlations you are interested in analyzing, while the columns should correspond to the rows of the design matrix and should be separable into your groups.
#' @param inputMatB Optional, secondary input matrix that allows you to calculate correlation and differential correlation for the rows between inputMat and imputMatB.
#' @param compare Vector of two character strings, each corresponding to one name in the list of correlation matrices that should be compared.
#' @param impute A binary variable specifying whether values should be imputed if there are missing values. Note that the imputation is performed in the full input matrix (i.e., prior to subsetting) and uses k-nearest neighbors.
#' @param corrType The correlation type of the analysis, limited to "pearson" or "spearman".
#' @param design A standard model.matrix created design matrix. Rows correspond to samples and colnames refer to the names of the conditions that you are interested in analyzing. Only 0's or 1's are allowed in the design matrix. Please see vignettes for more information.
#' @param nPerms Number of permutations to generate.
#' @param corr_cutoff Cutoff specifying correlation values beyond which will be truncated to this value, to reduce the effect of outlier correlation values when using small sample sizes. Default = 0.99
#' @param signType Coerce all correlation coefficients to be either positive (via "positive"), negative (via "negative"), or none (via "none"). This could be used if you think that going from a positive to a negative correlation is unlikely to occur biologically and is more likely to be due to noise, and you want to ignore these effects. Note that this does NOT affect the reported underlying correlation values, but does affect the z-score difference of correlation calculation. Default = "none", for no coercing.
#' @param cl A parallel cluster object created by parallel::makeCluster(). If FALSE, defaults to single-core implementation.
#' @param k When running in MI mode, the number of intervals to discretize the data into before calculating mutual information. Default = 5.
#' @param k_iter_max When running in MI mode, the number of iterations to determine the k-clusters for discretization before calculating mutual information. Default = 10. 
#' @return An array of permuted differences in z-scores calculated between conditions, with the third dimension corresponding to the number of permutations performed.
#' @export
getDCorPerm <- function(inputMat, design, compare, inputMatB = NULL, impute = FALSE,
	nPerms = 10, corrType = "pearson", corr_cutoff = 0.99, signType = "none",cl=NULL, k=5,k_iter_max=10,lib.loc=NULL){

	secondMat = FALSE
	if(!is.null(inputMatB)){
		corPermMat1 = array(dim = c(nrow(inputMat), nrow(inputMatB), nPerms))
		corPermMat2 = array(dim = c(nrow(inputMat), nrow(inputMatB), nPerms))
		zPermMat = array(dim = c(nrow(inputMat), nrow(inputMatB), nPerms))
		secondMat = TRUE
	} else {
		corPermMat1 = array(dim = c(nrow(inputMat), nrow(inputMat), nPerms))
		corPermMat2 = array(dim = c(nrow(inputMat), nrow(inputMat), nPerms))
		zPermMat = array(dim = c(nrow(inputMat), nrow(inputMat), nPerms))
	}

	calcZscores <- function(iter,inputMat, design, compare, inputMatB = NULL, impute = FALSE,
	 corrType = "pearson", corr_cutoff = 0.99, signType = "none",clus=NULL,secondMat=FALSE, k=5,k_iter_max=10,lib.loc=NULL){
		message("Calculating permutation number ", iter, ".")
		inputMat_perm = inputMat[ , sample(ncol(inputMat)), drop = FALSE]
		if(secondMat){
			inputMatB_perm = inputMatB[ , sample(ncol(inputMatB)), drop = FALSE]
			corMats_res = getCors(inputMat_perm, design = design,
				inputMatB = inputMatB_perm, corrType = corrType, impute = impute,cl=clus, k=k,k_iter_max=k_iter_max,lib.loc=lib.loc)
		} else {
			corMats_res = getCors(inputMat_perm, design = design,
				corrType = corrType, impute = impute,cl=clus, k=k,k_iter_max=k_iter_max,lib.loc=lib.loc)
		}
		dcPairs_res = pairwiseDCor(corMats_res, compare, corr_cutoff = corr_cutoff,
			secondMat = secondMat, signType = signType, corrType = corrType)
		zscores = slot(dcPairs_res, "ZDiff")
		return(list("zscores"=zscores,"corrs"=corMats_res))
	}

	if(!identical(cl,FALSE)){
		parallel::clusterExport(cl=cl,c("getCors","pairwiseDCor","getGroupsFromDesign",
		                      "dCorMats","dCorrs"))
		res = parallel::parLapplyLB(cl,1:nPerms,calcZscores,
		                         inputMat=inputMat,design=design,compare=compare,
		                         inputMatB=inputMatB,impute=impute,corrType=corrType,
		                         corr_cutoff=corr_cutoff,signType=signType,clus=FALSE,
		                         secondMat=secondMat, k=k,k_iter_max=k_iter_max,lib.loc=lib.loc)
		for (i in 1:nPerms){
			zPermMat[ , , i] = res[[i]]$zscores #zPermMatList
			corPermMat1[ , , i] = res[[i]]$corrs@corMatList[[1]]$corrs #corPermMatList
			corPermMat2[ , , i] = res[[i]]$corrs@corMatList[[2]]$corrs #corPermMatList
		}
	}else{
		for(i in 1:nPerms){
			message("Calculating permutation number ", i, ".")
			inputMat_perm = inputMat[ , sample(ncol(inputMat)), drop = FALSE]
			if(secondMat){
				inputMatB_perm = inputMatB[ , sample(ncol(inputMatB)), drop = FALSE]
				corMats_res = getCors(inputMat_perm, design = design,
					inputMatB = inputMatB_perm, corrType = corrType, impute = impute,cl=FALSE, k=k,k_iter_max=k_iter_max,lib.loc=lib.loc)
			} else {
				corMats_res = getCors(inputMat_perm, design = design,
					corrType = corrType, impute = impute,cl=FALSE, k=k,k_iter_max=k_iter_max,lib.loc=lib.loc)
			}
			dcPairs_res = pairwiseDCor(corMats_res, compare, corr_cutoff = corr_cutoff,
				secondMat = secondMat, signType = signType, corrType = corrType)
			zscores = slot(dcPairs_res, "ZDiff")
			zPermMat[ , , i] = zscores
			corPermMat1[ , , i] = corMats_res@corMatList[[1]]$corrs
			corPermMat2[ , , i] = corMats_res@corMatList[[2]]$corrs
		}
	}
	#save(corPermMat1, corPermMat2, file="corPermMats.Rsave")
	#save(zPermMat, file="zPermMat.Rsave")
	return(list("zPermMat"=zPermMat,"corPermMat1"=corPermMat1,"corPermMat2"=corPermMat2))
}
