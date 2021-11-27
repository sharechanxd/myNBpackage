
x=iris[c(1:40,51:90,101:140),-5]
y=iris[c(1:40,51:90,101:140),5]
testx = iris[c(41:50,91:100,141:150),-5]
m2 = myNaiveBayes(x,y)
test_that("multiplication works", {
  expect_equal(print_my_naiveBayes(m2), 1)
})
