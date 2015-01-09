#' Get LinkedIn Connections
#'
#' @param token Authorization token 
#' @return Returns a dataframe of LinkedIn connections
#' @examples
#' \dontrun{
#' 
#' my.connections <- getMyConnections(in.auth)
#' }
#' @export


getMyConenctions <- function(token)
{ 
  # returns default fields
  base_url <- "http://api.linkedin.com/v1/people/~/connections"
  query <- GET(base_url, config(token = token))
  q.content <- content(query) 
  q.df <- connectionsToDF(q.content)
  return(q.df)
}
