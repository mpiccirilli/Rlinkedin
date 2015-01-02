getMyConenctions <- function(token)
{ 
  # returns default fields
  base_url <- "http://api.linkedin.com/v1/people/~/connections"
  query <- GET(base_url, config(token = token))
  q.content <- content(query) 
  q.df <- xmlToDataFrame(q.content)
  return(q.df)
}
my_connections <- getMyConenctions(in_oauth)
