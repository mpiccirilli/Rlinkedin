getMyConenctions <- function(token)
{ 
  # returns default fields
  base_url <- "http://api.linkedin.com/v1/people/~/connections"
  query <- GET(base_url, config(token = token))
  q.content <- content(query) 
  q.df <- ldply(xmlToList(q.content), data.frame)
  return(q.df)
}


