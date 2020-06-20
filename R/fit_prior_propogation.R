fit_prior_propogation <- function(answers){
  
  estimate <- answers %>%
    mutate(
      method = "prior-propogation",
      # propogate forward the conjugate prior (beta); factors of 1/2
      # are added to alpha/beta to reflect a starting Jeffrey's prior.
      alpha = cumsum(accepted) +1/2,
      beta  = cumsum(answered) - cumsum(accepted) + 1/2,
      p = alpha/(alpha + beta),
      lwr_80 = qbeta(0.1, alpha, beta),
      upr_80 = qbeta(0.9, alpha, beta)
    ) %>%
    select(method, date, p,lwr_80, upr_80)
  
  return(estimate)
}