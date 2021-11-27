if (!require("e1071",character.only = T)) {
  install.packages("e1071",quiet=TRUE)
}
if (!require("discretization",character.only = T)) {
  install.packages("discretization",quiet=TRUE)
}
library(discretization, quietly = TRUE)
library(e1071, quietly = TRUE)

x=iris[c(1:40,51:90,101:140),-5]
y=iris[c(1:40,51:90,101:140),5]
testx = iris[c(41:50,91:100,141:150),-5]


test_that("basic function works", {
  m1 = naiveBayes(x,y)
  r1 = predict(m1,testx)
  m2 = myNaiveBayes(x,y)
  r2 = predict_your_model(m2,testx,'class')
  expect_equal(all(r1==r2), TRUE)
})

test_that("discrete function works", {
  v = disc_train_data(x,y)
  x_dis = v$discredata
  testx_dis = disc_test_data(testx,v$cutp)
  m1_2 = naiveBayes(x_dis,y)
  r1_2 = predict(m1_2,testx_dis)
  m2_2 = myNaiveBayes(x,y,discre = TRUE)
  r2_2 = predict_your_model(m2_2,testx,'class')
  expect_equal(all(r1_2==r2_2), TRUE)
})

test_that("pred type raw works", {
  m1 = naiveBayes(x,y)
  r1 = predict(m1,testx,'raw')
  m2 = myNaiveBayes(x,y)
  r2 = predict_your_model(m2,testx,'raw')
  expect_equal(all(round(r1,2)==round(r2,2)), TRUE)
})

test_that("disc train data error works", {
  expect_error(disc_train_data(x[,1],y), 'X must have dim larger than 1')
})

test_that("build model error works", {
  expect_error(myNaiveBayes(x[1:41,],y[1:41]), 'Should be at least 2 rows or more for each class')
})


test_that("test data missing character filling works", {
  i = iris[1:2,]
  i[2,2]=NA
  test_miss = i[,-5]
  m1 = naiveBayes(x,y)
  r1 = predict(m1,test_miss)
  m2 = myNaiveBayes(x,y)
  r2 = predict_your_model(m2,test_miss)
  expect_equal(all(r1==r2), TRUE)
})

