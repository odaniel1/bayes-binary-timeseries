fit_bayes_hier_glm <- function(answers){
  require(rstanarm)
  require(tidybayes)
  
  stan_fit <- stan_glmer(
      formula = cbind(accepted, answered-accepted) ~ 1 + (1|date),
      data = answers,
      family = binomial(link = "logit"),
      cores = 4
    )
  
  estimate <- stan_fit %>%
    spread_draws(`(Intercept)`, b[,date]) %>%
    mode_qi(mode = `(Intercept)` + b, .width = 0.8) %>%
    transmute(
      method = "bayes-hierarchical-glm",
      date = str_remove(date, "date:") %>% as.Date(),
      p = plogis(mode),
      lwr_80 = plogis(.lower),
      upr_80 = plogis(.upper)
    )
  
  return(estimate)
}