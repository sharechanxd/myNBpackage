if (!require("discretization",character.only = T)) {
  install.packages("discretization",quiet=TRUE)
}
if (!require("e1071",character.only = T)) {
  install.packages("e1071",quiet=TRUE)
}
library(discretization, quietly = TRUE) ## help with discretization
library(e1071, quietly = TRUE)
## To estimate the parameters for a feature's distribution, one must assume a distribution or generate nonparametric models for the features from the training set.
## If you are dealing with continuous data, a common assumption is that these continuous values are Gaussian.
## Another commonly used technique for dealing with continuous numerical problems is by discretizing continuous numerical values.
## Generally, when the number of training samples is small or the exact distribution is known, the method of passing the probability distribution is a better choice.
## In the case of a large number of samples, the discretization method performs better, because a large number of samples can learn the distribution of the data.

## Below two functions are suitable for discretization method.

#' function of discreting the train data with supervised method and return the cut points.
#' @title Discretization for train dataset
#' @name disc_train_data
#' @usage disc_train_data(x, y, alpha =0.05)
#' @param x A dataframe of train data with some numeric columns
#' @param y A dataframe or vector of categorical labels
#' @param alpha Significance level value, default is 0.05
#'
#' @return A list with cut points and new x dataframe
#' @export
#' @importFrom discretization value
#' @examples
#' x=iris[c(1:40,51:90,101:140),-5]
#' y=iris[c(1:40,51:90,101:140),5]
#' testx = iris[c(41:50,91:100,141:150),-5]
#' v = disc_train_data(x,y)
#' v$discredata
#' v$cutp
#'
disc_train_data = function(x,y,alpha=0.05){
  p = dim(x)[2]
  if(is.null(p)){stop('X must have dim larger than 1')}
  discredata = x
  cutp <- list()
  for(i in 1:p){
    if(is.numeric(x[,i])){
      val <- value(i,cbind(x,y),alpha)
      cutp[[i]] <- val$cuts
      discredata[,i] <- factor(val$disc[,i])
    }else{
      cutp[[i]] = 'shit'
    }

  }
  return(list(cutp=cutp,discredata=discredata))
}

#' function to discrete the test data with train data cut points.
#' @title Discretization for test dataset
#' @name disc_test_data
#' @usage disc_test_data(x, cutp)
#' @param x A dataframe of test data with some numeric columns
#' @param cutp cut points from train dataset
#'
#' @return new test data with discretization
#' @export
#'
#' @examples
#' x=iris[c(1:40,51:90,101:140),-5]
#' y=iris[c(1:40,51:90,101:140),5]
#' testx = iris[c(41:50,91:100,141:150),-5]
#' v = disc_train_data(x,y)
#' testx_dis = disc_test_data(testx,v$cutp)
#'
#'
#'
disc_test_data = function(x,cutp){
  p = dim(x)[2]
  discredata = x
  for(i in 1:p){
    if(all(cutp[[i]] != 'shit')){
      discredata[,i] = factor(cut(x[,i],c(-Inf,cutp[[i]],Inf),labels = c(1:(length(cutp[[i]])+1))))
    }
  }
  return(discredata)
}


#' @title Naive bayes classifier with discretization and Gaussian estimation
#' @name myNaiveBayes
#' @usage myNaiveBayes(x,y,laplace = 0,discre = FALSE,alpha=0.05)
#' @param x A dataframe of train data
#' @param y A dataframe or vector of categorical labels
#' @param laplace parametre for laplace smoothing, default is 0
#' @param discre paramtre to decide discretization, default is FALSE
#' @param alpha Significance level value for discretization, default is 0.05
#'
#' @return object for Naive bayes classifier
#' @export
#'
#' @examples
#' x=iris[c(1:40,51:90,101:140),-5]
#' y=iris[c(1:40,51:90,101:140),5]
#' testx = iris[c(41:50,91:100,141:150),-5]
#' m2 = myNaiveBayes(x,y)
#' r2 = predict_your_model(m2,testx,'class')
#'
myNaiveBayes = function(x,y,laplace = 0,discre = FALSE,alpha=0.05){
  if(any(rowsum(rep(1,length(y)), y)<2)){
    stop('Should be at least 2 rows or more for each class')
  }
  x = as.data.frame(x)

  if (is.logical(y)){
    # only for TRUE/FALSE or T/F
    y <- factor(y, levels = c(TRUE, FALSE))
  }
  ## This is the prior distribution coming from labels.
  prior_dist = table(y)

  cutp=list()

  ## Do discretization if discre = False.
  if(discre){
    nn = disc_train_data(x,y,alpha)
    cutp = nn$cutp
    x=nn$discredata
  }
  type_of_x = vapply(x, is.numeric, NA)

  ## We assume that the data follows Gaussian Distribution with small sample size.
  ## But actually discrete the continuous variable would be better especially large dataset.
  gaussian_estimation = function(Xi,target){
    if(is.numeric(Xi)){
      # Continuous Xi we estimated with Guassian Distribution
      mean_groupby_y = tapply(Xi, target, mean, na.rm = TRUE)
      sd_groupby_y = tapply(Xi, target, sd, na.rm = TRUE)
      return(cbind(mean_groupby_y,sd_groupby_y))
    }else if(is.logical(Xi)){
      Xi = factor(Xi,levels = c(TRUE, FALSE))
      y_xi_table = table(target,Xi)
      return((y_xi_table + laplace) / (rowSums(y_xi_table) + laplace * nlevels(Xi)))
    }else{
      y_xi_table = table(target,Xi)
      return((y_xi_table + laplace) / (rowSums(y_xi_table) + laplace * nlevels(Xi)))
    }
  }
  ## For categorical and logical Xi, P(Xi|Y) would be calculated with laplace smoothing

  ## all needed info to do bayes inference from X in this list.
  prob_prep_table = lapply(x,gaussian_estimation,target=y)

  return(structure(
    list(prior_dist=prior_dist,
         prob_prep_table=prob_prep_table,
         cutp=cutp,
         type_of_x=type_of_x),class='NB'))
}



#' @title Naive bayes predictor
#' @name predict_your_model
#' @usage predict_your_model(NB_obj,new_x, pred_type = c('class','raw'),threshold = .Machine$double.eps,eps = 0)
#' @param NB_obj object for Naive bayes classifier
#' @param new_x a dataframe of test dataset without labels
#' @param pred_type predict result, should be 'class' or 'raw'
#' @param threshold laplace smoothing parametre, default is .Machine$double.eps
#' @param eps laplace smoothing parametre, default is 0
#'
#' @return predicted result depending on pred_type
#' @export
#'
#' @examples
#' x=iris[c(1:40,51:90,101:140),-5]
#' y=iris[c(1:40,51:90,101:140),5]
#' testx = iris[c(41:50,91:100,141:150),-5]
#' m2 = myNaiveBayes(x,y)
#' r2 = predict_your_model(m2,testx,'class')
#'
predict_your_model = function(NB_obj,new_x, pred_type = c('class','raw'),threshold = .Machine$double.eps,eps = 0){
  pred_type = match.arg(pred_type)
  new_x = as.data.frame(new_x)
  y_levels = names(NB_obj$prior_dist)

  ## Decide whether to discrete new x with cut points from train dataset.
  if(length(NB_obj$cutp)!=0){
    new_x = disc_test_data(new_x,NB_obj$cutp)
  }

  ## Fix factor levels with train dataset.
  for(i in names(NB_obj$prob_prep_table)){
    if(is.logical(new_x[[i]])){
      new_x[[i]] = factor(new_x[[i]],levels = c(TRUE, FALSE))}
    else if(!is.null(new_x[[i]]) && !is.numeric(new_x[[i]])){
      new_x[[i]] <- factor(new_x[[i]], levels = colnames(NB_obj$prob_prep_table[[i]]))
    }
  }

  isnumeric <- vapply(new_x, is.numeric, NA)
  islogical <- vapply(new_x, is.logical, NA)
  # print(y_levels)

  # prevent 0 probability and avoid floating precision with log and plus
  calc_prob = function(i){
    sample_i = new_x[i,]
    probs = list()
    for(v in 1:length(sample_i)){
      cc = sample_i[1,v]
      if(is.na(cc)|is.null(cc)){
        cc_prob = rep.int(1,length(y_levels))
      }
      else{
        if(isnumeric[v]){
          mean_sd = NB_obj$prob_prep_table[[v]]
          mean_sd[,2][mean_sd[,2]<=eps] = threshold
          ## With mean and sd value, we could calculate the Gaussian estimation as P(Xi|Y)
          cc_prob = dnorm(cc,mean_sd[,1],mean_sd[,2])
        }else{
          cc_prob = NB_obj$prob_prep_table[[v]][,cc]
        }
        cc_prob[cc_prob<=eps] = threshold
      }
      probs[[v]] = cc_prob
    }
    probs = t(sapply(probs,c))

    ## The evidence factor, which is the denominator in Naive Bayes (usually a constant), is used to normalize the sum of all kinds of posterior probabilities.
    ## And we could ignore this evidence in our calculation for the posterior probabilities for Y
    i_prob = apply(log(probs),2,sum) + log(NB_obj$prior_dist/sum(NB_obj$prior_dist))
    return(i_prob)

  }

  pred_prob = vapply(c(1:nrow(new_x)),calc_prob,double(length(y_levels)))

  if(pred_type == 'class'){
      return(factor(y_levels[apply(pred_prob, 2, which.max)], levels = y_levels))
  }else{
    ## Translate the value back to probabilities for different class of Y
    pred_prob = t(pred_prob)
    pred_prob = exp(pred_prob)
    pred_prob = pred_prob/rowSums(pred_prob)
    return(pred_prob)
  }
}

#' @title Print function to see hidden information
#' @name print_my_naiveBayes
#' @usage print_my_naiveBayes(model)
#' @param model object for Naive bayes classifier
#'
#' @return 1 as flag
#' @export
#'
#' @examples
#' x=iris[c(1:40,51:90,101:140),-5]
#' y=iris[c(1:40,51:90,101:140),5]
#' testx = iris[c(41:50,91:100,141:150),-5]
#' m2 = myNaiveBayes(x,y)
#' print_my_naiveBayes(m2)
print_my_naiveBayes <- function(model) {
  cat("\nNaive Bayes Classifier wt/wo discretization \n\n")
  cat("\nPrior probabilities from labels:\n")
  print(model$prior_dist/sum(model$prior_dist))

  cat("\nConditional probabilities for all predictors:\n")
  for(i in model$prob_prep_table){
    print(i)
    cat("\n")
  }
  return(1)
}
