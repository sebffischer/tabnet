test_that("explain provides correct result with data.frame", {

  set.seed(2022)
  torch::torch_manual_seed(2022)

  n <- 2000
  x <- data.frame(
    x = rnorm(n),
    y = rnorm(n),
    z = rnorm(n)
  )

  y <- x$x

  fit <- tabnet_fit(x, y, epochs = 15,
                    num_steps = 1,
                    batch_size = 512,
                    attention_width = 1,
                    num_shared = 1,
                    num_independent = 1)

  expect_equal(which.max(fit$fit$importances$importance), 1)
  expect_equal(fit$fit$importances$variables, colnames(x))

  ex <- tabnet_explain(fit, x)

  expect_length(ex, 2)
  expect_length(ex[[2]], 1)
  expect_equal(nrow(ex[[1]]), nrow(x))
  expect_equal(nrow(ex[[2]][[1]]), nrow(x))

})

test_that("explain works for dataframe, formula and recipe", {

  # data.frame, regression
  expect_error(
    tabnet_explain(ames_pretrain_vsplit, new_data=small_ames),
    regexp = NA
  )

  expect_error(
    tabnet_explain(ames_fit_vsplit, new_data=small_ames),
    regexp = NA
  )

  # data.frame, classification
  expect_error(
    tabnet_explain(attr_pretrained_vsplit, attrix),
    regexp = NA
  )
  expect_error(
    tabnet_explain(attr_fitted_vsplit, attrix),
    regexp = NA
  )


  # formula
  tabnet_pretrain <- tabnet_pretrain(Sale_Price ~., data=small_ames, epochs = 3, valid_split=.2,
                                     num_steps = 1, attention_width = 1, num_shared = 1, num_independent = 1)
  expect_error(
    tabnet_explain(tabnet_pretrain, new_data=small_ames),
    regexp = NA
  )

  tabnet_fit <- tabnet_fit(Sale_Price ~., data=small_ames, tabnet_model=tabnet_pretrain, epochs = 3,
                           num_steps = 1, attention_width = 1, num_shared = 1, num_independent = 1)
  expect_error(
    tabnet_explain(tabnet_fit, new_data=small_ames),
    regexp = NA
  )

  # recipe
  rec <- recipe(Sale_Price ~., data = small_ames) %>%
    step_zv(all_predictors()) %>%
    step_normalize(all_numeric_predictors())

  tabnet_pretrain <- tabnet_pretrain(rec, data=small_ames, epochs = 3, valid_split=.2,
                                     num_steps = 1, attention_width = 1, num_shared = 1, num_independent = 1)
  expect_error(
    tabnet_explain(tabnet_pretrain, new_data=small_ames),
    regexp = NA
  )

  tabnet_fit <- tabnet_fit(rec, data=small_ames, tabnet_model=tabnet_pretrain, epochs = 3,
                           num_steps = 1, attention_width = 1, num_shared = 1, num_independent = 1)
  expect_error(
    tabnet_explain(tabnet_fit, new_data=small_ames),
    regexp = NA
  )
})

test_that("support for vip on tabnet_fit and tabnet_pretrain", {

  skip_if_not_installed("vip")

  n <- 1000
  x <- data.frame(
    x = runif(n),
    y = runif(n),
    z = runif(n)
  )

  y <- x$x

  pretrain <- tabnet_pretrain(x, y, epochs = 1,
                    num_steps = 1,
                    batch_size = 512,
                    attention_width = 1,
                    num_shared = 1,
                    num_independent = 1)

  fit <- tabnet_fit(x, y, epochs = 1,
                    num_steps = 1,
                    batch_size = 512,
                    attention_width = 1,
                    num_shared = 1,
                    num_independent = 1)

  expect_error(vip::vip(pretrain), regexp = NA)
  expect_error(vip::vip(fit), regexp = NA)

})


test_that("Importance is skipped if skip_importance flag is used", {

  set.seed(2022)
  torch::torch_manual_seed(2022)

  n <- 1000
  x <- data.frame(
    x = rnorm(n),
    y = rnorm(n),
    z = rnorm(n)
  )

  y <- x$x

  fit <- tabnet_fit(x, y, epochs = 15,
                    num_steps = 1,
                    batch_size = 512,
                    attention_width = 1,
                    num_shared = 1,
                    num_independent = 1,
                    skip_importance = TRUE)

  expect_equal(fit$fit$importances, NULL)

  fit <- tabnet_fit(x, y, epochs = 15,
                    num_steps = 1,
                    batch_size = 512,
                    attention_width = 1,
                    num_shared = 1,
                    num_independent = 1,
                    skip_importance = FALSE)


  expect_equal(which.max(fit$fit$importances$importance), 1)
  expect_equal(fit$fit$importances$variables, colnames(x))

})
