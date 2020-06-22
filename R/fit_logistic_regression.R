
fit_logistic_regression <- function(answers, deg = 1){
  require(broom)
  
  answers <- answers %>%
    mutate(time = difftime(date, min(date), unit = "days") %>% as.numeric())
  
  glm_fit <- glm(cbind(accepted, answered-accepted) ~ poly(time, deg),
                 data = answers,
                 family = binomial(link = "logit")
            )
  
  par_estimates <- predict(glm_fit, newdata = answers, type = "link", se.fit = TRUE)
  
  estimate <- answers %>% mutate(method = "logistic-regression")
  estimate$p <- plogis(par_estimates$fit)
  estimate$lwr_80 = plogis(par_estimates$fit + qnorm(0.1) * par_estimates$se.fit)
  estimate$upr_80 = plogis(par_estimates$fit + qnorm(0.9) * par_estimates$se.fit)
  
  estimate <- estimate %>% select(method, date, p,lwr_80, upr_80)
  
  return(estimate)
}

