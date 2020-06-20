# This is where you write your drake plan.
# Details: https://books.ropensci.org/drake/plans.html

plan <- drake_plan(
  # most models will be fit against data for daily answers.
  answers_daily = get_se_answers(user_id = 7224, date = as.Date(trunc(creation_date, unit = "day"))),
  answers_monthly = get_se_answers(user_id = 7224, date = as.Date(trunc(creation_date, unit = "month"))),
  
  # models
  monthly_mle = fit_mle(answers_monthly),
  prior_propogation = fit_prior_propogation(answers_daily),
  bayes_hier_glm = fit_bayes_hier_glm(answers_monthly),
  
  # plots
  model_plots = bind_rows(monthly_mle, prior_propogation, bayes_hier_glm) %>%
    group_nest(method) %>%
    mutate(
      plot = map(data, ~plot_acceptance_rate(.))
    ) %>% select(-data)
  
  narrative = render(knitr_in("index.Rmd"), output_file = "index.html")

)
