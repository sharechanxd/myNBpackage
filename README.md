
<!-- README.md is generated from README.Rmd. Please edit that file -->

# BIOS625: Naive bayes classifier with discretization and Gaussian estimation

<!-- badges: start -->

[![Build
Status](https://app.travis-ci.com/sharechanxd/myNBpackage.svg?branch=main)](https://app.travis-ci.com/sharechanxd/myNBpackage)
[![R-CMD-check](https://github.com/sharechanxd/myNBpackage/workflows/R-CMD-check/badge.svg)](https://github.com/sharechanxd/myNBpackage/actions?workflow=R-CMD-check)
[![codecov](https://codecov.io/gh/sharechanxd/myNBpackage/branch/main/graph/badge.svg?token=DPZU2BB7L1)](https://codecov.io/gh/sharechanxd/myNBpackage)
<!-- badges: end -->

The usage of myNBpackage is to allow users to build naive bayes
classifier with discretization and Gaussian estimation and predict the
new data’s labels. To estimate the parameters for a feature’s
distribution, one must assume a distribution or generate nonparametric
models for the features from the training set. If you are dealing with
continuous data, a common assumption is that these continuous values are
Gaussians. It’s also OK to do with Poisson, Multinomial or Bernoulli
distribution. Another commonly used technique for dealing with
continuous numerical problems is by discretizing continuous numerical
values. Generally, when the number of training samples is small or the
exact distribution is known, the method of passing the probability
distribution is a better choice. In the case of a large number of
samples, the discretization method performs better, because a large
number of samples can learn the distribution of the data. In my package,
I build method for data discretization and build naive bayes classifier
with Gaussian estimation for continous variables.

Compared to the well-established “e1071” package, although our package
is not so efficient and memory-saving when running the same huge data
tasks, it could provide users with more flexible operation with
continuous and categorical variables. We provide the tutorial and
description to help users better access and understand the
functionalities of these methods.

## Structure

This package includes 5 functions:

  - **disc\_train\_data**: function of discreting the train data with
    supervised method and return the cut points and discreted train
    dataset
      - Discretization for train dataset
      - disc\_train\_data(x, y, alpha =0.05)
          - **x**: A dataframe of train data with some numeric columns,
            X must have dim larger than 1
          - **y**: A dataframe or vector of categorical labels
          - **alpha**: Significance level value, default is 0.05
  - **disc\_test\_data**: function to discrete the test data with cut
    points from train dataset
      - disc\_test\_data(x, cutp)
          - **x**: A dataframe of test data with some numeric columns
          - **cutp**: cut points from train dataset
  - **myNaiveBayes**: This would give us a ‘NB’ class object for
    predicting and printing
      - Continuous Xi we estimated with Guassian Distribution.For
        categorical and logical Xi, P(Xi|Y) would be calculated with
        laplace smoothing.all needed info to do bayes inference from
        train data will be in the object
      - myNaiveBayes(x,y,laplace = 0,discre = FALSE,alpha=0.05)
          - **x**: A dataframe of train data
          - **y**: A dataframe or vector of categorical labels
          - **alpha**: Significance level value for discretization,
            default is 0.05
          - **laplace**: parametre for laplace smoothing, default is 0
          - **discre**: paramtre to decide discretization, default is
            FALSE
  - **predict\_your\_model**: used to predict new data with previously
    defined model
      - ‘class’(return labels) and ‘raw’(return probabilities)
    
      - predict\_your\_model(NB\_obj,new\_x, pred\_type =
        c(‘class’,‘raw’),threshold = .Machine$double.eps,eps =
        0)
        
          - **NB\_obj**: object for Naive bayes classifier
          - **new\_x**: a dataframe of test dataset without labels
          - **pred\_type**: predicted result type, should be ‘class’ or
            ‘raw’
          - **threshold**: Value replacing cells with probabilities
            within eps, default is .Machine$double.eps
          - **eps**: laplace smoothing parametre, default is 0
  - **print\_my\_naiveBayes**: Print function to see hidden information

## Installation

You can install the development version of myNBpackage like so:

``` r
devtools::install_github('sharechanxd/myNBpackage', build_vignettes = T)
library("myNBpackage")
```

## Example

These are basic example which shows you how to solve a common problem
and illustrate the usage of this function in the package:

``` r
library(myNBpackage)
data("iris")

# Basic example
x=iris[c(1:40,51:90,101:140),-5]
y=iris[c(1:40,51:90,101:140),5]
testx = iris[c(41:50,91:100,141:150),-5]
m2 = myNaiveBayes(x,y)
r1 = predict_your_model(m2,testx,'class')
r2 = predict_your_model(m2,testx,'raw')

# discrete functions
v = disc_train_data(x,y)
x_dis = v$discredata
testx_dis = disc_test_data(testx,v$cutp)

# discrete example
m2_2 = myNaiveBayes(x,y,discre = TRUE)
r2_2 = predict_your_model(m2_2,testx,'class')
```

For more detailed examples or for more information, please use

``` r
browseVignettes(package = 'myNBpackage')
#> No vignettes found by browseVignettes(package = "myNBpackage")
```

and click HTML to see more complex examples and how to use these
functions in a more complete way.
