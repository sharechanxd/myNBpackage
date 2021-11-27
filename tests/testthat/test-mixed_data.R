
library(discretization, quietly = TRUE)
library(e1071, quietly = TRUE)

g=disc_train_data(iris[,3:4],iris[,5])
new_data = cbind(iris[,1:2],g$discredata)
new_data = cbind(new_data,iris[,5])

x=new_data[c(1:40,51:90,101:140),-5]
y=new_data[c(1:40,51:90,101:140),5]
testx = new_data[c(41:50,91:100,141:150),-5]

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
