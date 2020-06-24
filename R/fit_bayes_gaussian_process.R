fit_bayes_gaussian_process <- function(answers){
  
  require(rstan)
  require(tidybayes)
  
  answers <- readd(answers_monthly)
  
  stan_data <- answers %>%
    mutate(
      time = difftime(date, min(date), unit = "days") %>% as.numeric(),
      time = scale(time) %>% as.numeric()
    ) %>%
    select(time, count = answered, succ = accepted) %>%
    compose_data(.n_name = n_prefix("N"))
  
  stan_fit <- stan(
    here::here("./R/stan/gp-logistic-glm-ceq-lin.stan"),
    data = stan_data,
    control = list(adapt_delta = 0.9),
    iter = 2000,
    chains = 4
    # pars = c("p")
  )
  
  pst_samples <- stan_fit %>%
    spread_draws(p[1]) %>%
    mutate(
      p = map(p, ~tibble(date = answers$date, p = unlist(.)))
    ) %>%
    unnest(cols=c(p)) %>%
    group_by(date) %>%
    mode_qi(mode = p, .width = 0.8) %>%
    mutate(
      method = "bayes-random-walk",
      p = mode,
      lwr_80 = .lower,
      upr_80 = .upper
    ) %>%
    select(method, date, p, lwr_80, upr_80)
  
  return(pst_samples)
}