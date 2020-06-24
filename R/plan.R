# This is where you write your drake plan.
# Details: https://books.ropensci.org/drake/plans.html

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

plan <- drake_plan(
  
  # ---- data -----------------------------------------------------------------
  
  answers_tagged = get_se_answers(
      user_id = 712603, "stackoverflow.com",
      pagesize = 100, num_pages = 20
    ) %>%
    tag_se_answers(site = "stackoverflow.com", sleep = 0.5),
  
  answers_daily  = summarise_se_answers(answers_tagged,
      date = as.Date(trunc(creation_date, unit = "day"))
    ),
  
  answers_monthly = summarise_se_answers(answers_tagged,
      date = as.Date(trunc(creation_date, unit = "month"))
    ),

  # ---- models ---------------------------------------------------------------
  
  monthly_mle = fit_mle(answers_monthly),
  
  logistic_regression_1 = fit_logistic_regression(answers_daily, deg = 1) %>%
    mutate(method = "logistic-regression-1"),
  
  logistic_regression_2 = fit_logistic_regression(answers_daily, deg = 2) %>%
    mutate(method = "logistic-regression-2"),
  
  prior_propogation = fit_prior_propogation(answers_daily),
  
  bayes_hier_glm = fit_bayes_hier_glm(answers_monthly),
  
  bayes_random_walk = fit_stan_models(answers_monthly,
    here::here("./R/stan/rw-logistic-glm.stan"),
    model_name = "bayes-random-walk",
     chains = 4, iter = 2000, control = list(adapt_delta = 0.95)
    ),
  
  bayes_gp_quad_exp = fit_stan_models(answers_monthly,
    here::here("./R/stan/gp-logistic-glm-ceq.stan"),
    model_name = "bayes-gp-ceq",
    chains = 4, iter = 2000, control = list(adapt_delta = 0.95)
    ),
  
  # currently crashes at 2000 iterations and adapt_delta = 0.95
  bayes_gp_quad_exp_lin = fit_stan_models(answers_monthly,
    here::here("./R/stan/gp-logistic-glm-ceq-lin.stan"),
    model_name = "bayes-gp-ceq-lin",
    chains = 4, iter = 1000, control = list(adapt_delta = 0.9)
  ),

  ## ---- outputs -------------------------------------------------------------
  
  # plots
  model_plots = bind_rows(
    monthly_mle,
    logistic_regression_1,
    logistic_regression_2,
    prior_propogation,
    bayes_hier_glm,
    bayes_random_walk,
    bayes_gp_quad_exp,
    bayes_gp_quad_exp_lin
    ) %>%
    group_nest(method) %>%
    mutate(
      plot = map(data, ~plot_acceptance_rate(.))
    ) %>% select(-data),
  
  narrative = render(knitr_in("index.Rmd"), output_file = "index.html")

)
