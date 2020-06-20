## ---- fit_monthly_mle ----
fit_mle <- function(answers){
  
  estimate <- answers %>%
    mutate(
      method = "monthly-MLE",
      # MLE estimate for the mean and variance of a binomial sample
      p  =  accepted/answered,
      var = p * (1-p) / answered,
      # 80% confidence interval via normal approximation
      lwr_80 = qnorm(0.1, mean = p, sd = sqrt(var)),
      upr_80 = qnorm(0.9, mean = p, sd = sqrt(var))
    ) %>%
   select(method, date, p,lwr_80, upr_80)
  
  return(estimate)
}
