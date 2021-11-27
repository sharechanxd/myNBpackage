
library(discretization, quietly = TRUE)
library(e1071, quietly = TRUE)

data_new = data.frame(
  size=c("Big","Small","Big","Big","Small","Small"),
  weight=c("light","heavy","light","light","heavy","light"),
  color=c("Red","Red","Red","Green","Red","Green"),
  expensive = c(FALSE,FALSE,TRUE,TRUE,FALSE,FALSE),
  taste=c(TRUE,TRUE,FALSE,FALSE,FALSE,TRUE)
)
x=data_new[,-5]
y=data_new[,5]
testx = data.frame(
  size=c("Big","Small"),
  weight=c("heavy","light"),
  color=c("Green","Red"),
  expensive = c(FALSE,TRUE)
)

test_that("basic function works", {
  m1 = naiveBayes(x,y)
  r1 = predict(m1,testx)
  m2 = myNaiveBayes(x,y)
  r2 = predict_your_model(m2,testx,'class')
  expect_equal(all(r1==r2), TRUE)
})
