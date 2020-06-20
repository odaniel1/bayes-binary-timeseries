get_se_answers <- function(user_id, ...){
  require(stackr)
  
  dat <- stack_users(id =  user_id, "answers",
                     site = "stats.stackexchange.com",
                     pagesize = 100, num_pages = 20) %>%
    
    # summarise; summary level determined by arguments in ...
    # mutate(date = trunc(creation_date, unit = "day") %>% as.Date()) %>%
    group_by(...) %>%
    summarise(
      answered = n(),
      accepted = sum(is_accepted)
    ) %>%
    ungroup()
  
  return(dat)
}
