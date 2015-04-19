#' Retrieve 1st Degree LinkedIn Connections
#'
#' @description
#' \code{getMyConnections} returns information about your 1st degree 
#' connections who do not have their profile set to private.
#' 
#' You cannot "browse connections." That is, you cannot get connections 
#' of your connections (2nd degree connections).
#'
#' @author
#' Michael Piccirilli \email{michael.r.piccirilli@@gmail.com}
#' @seealso \code{\link{getProfile}}, \code{\link{searchPeople}}
#'
#' @param token Authorization token.
#' 
#' @return Returns a dataframe of your 1st degree LinkedIn connections.
#' 
#' @examples
#' \dontrun{
#' 
#' my.connections <- getMyConnections(in.auth)
#' }
#' @export


getMyConnections <- function(token)
{ 
  # returns default fields
  base_url <- "http://api.linkedin.com/v1/people/~/connections"
  query <- GET(base_url, config(token = token))
  q.content <- content(query) 
  q.df <- connectionsToDF(q.content)
  return(q.df)
}
