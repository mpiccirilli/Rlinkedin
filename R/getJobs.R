#' LinkedIn Job Recommendations and Job Search
#'
#' @param token Authorization token 
#' @param suggestions LinkedIn job recommendations
#' @return Returns LinkedIn job recommendation or search for jobs via LinkedIn
#' @examples
#' \dontrun{
#' 
#' my.jobs <- getJobs(in.auth, suggestions=TRUE)
#' }
#' @export


getJobs <- function(token, suggestions=TRUE, bookmarks=FALSE)
{ 
  
  if(isTRUE(suggestions) && isTRUE(bookmarks)){
    print("Please select either suggestions or bookmarks")
  }
  
  if(isTRUE(suggestions)){
  url <- "http://api.linkedin.com/v1/people/~/suggestions/job-suggestions"
  query <- GET(url, config(token = token))
  q.content <- content(query)
  q.df <- jobsToDF(q.content)
  return(q.df)
  }
  
  if(isTRUE(bookmarks)){
    url <- "https://api.linkedin.com/v1/people/~/job-bookmarks"
    query <- GET(url, config(token = token))
    q.content <- content(query)
    q.df <- jobBookmarksToDF(q.content)
    return(q.df)
  }
}