get_se_answers <- function(user_id, site, ...){
  require(stackr)
  answers <- stack_users(id =  user_id, "answers", site = site, ...)
}

tag_se_answers <- function(answers, question_id = question_id, site, sleep = 0){
  require(stackr) 

  # A separate API call is required for each question, making a high volume of
  # calls may require app registration
  answers <- answers %>%
    mutate(tag = map({{question_id}},.f= function(x){Sys.sleep(sleep); stack_questions(x, site = site)$tags})) 
  # tags <- map(answers$question_id, .f= function(x){Sys.sleep(sleep); stack_questions(x, site = site)$tags})
  return(answers)
}

summarise_se_answers <- function(answers, ...){
  # if no arguments are passed simply return the answers data.
  if(missing(...) == TRUE){
    message("No grouping variables provided.")
    return(answers)
  }
  
  answers <- answers %>%
    group_by(...) %>%
    summarise(
      answered = n(),
      accepted = sum(is_accepted)
    ) %>%
    ungroup()
  
  return(answers)  
}

expand_se_answer_tags <- function(answers){
  answers <- answers %>%
    mutate(tags = str_split(tags, ","), temp = 1) %>%
    unnest(tags) %>%
    pivot_wider(
      names_from = tags,
      values_from = temp,
      values_fill = list(temp = 0),
      names_prefix = "tag_"
    )
  
  return(answers)
}

