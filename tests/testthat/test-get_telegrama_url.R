test_that("get_telegrama_url works", {
  expect_equal(get_telegrama_url("0100100001X"),
               'https://www.resultados2019.gob.ar/opt/jboss/rct/tally/pages/0100100001X/1.png')
})
