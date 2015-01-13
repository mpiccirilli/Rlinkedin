#' LinkedIn Bookmarked and Recommended Jobs
#'
#' @param token Authorization token 
#' @param suggestions LinkedIn job recommendations
#' @param bookmarks Jobs you've bookmarked
#' @return Returns LinkedIn recommended or bookmarked jobs
#' @examples
#' \dontrun{
#' 
#' job.suggestions <- getJobs(in.auth, suggestions=TRUE)
#' job.bookmarks <- getJobs(in.auth, bookmarks=TRUE)
#' 
#' }
#' @export


getJobs <- function(token, suggestions=TRUE, bookmarks=FALSE)
{ 
  
  
  if(isTRUE(suggestions)){
  url <- "http://api.linkedin.com/v1/people/~/suggestions/job-suggestions"
  query <- GET(url, config(token = token))
  q.content <- content(query)
  q.df <- jobRecsToDF(q.content)
  return(q.df)
  }
  
  if(isTRUE(bookmarks)){
    url <- "https://api.linkedin.com/v1/people/~/job-bookmarks"
    query <- GET(url, config(token = token))
    q.content <- content(query)
    q.df <- jobBookmarksToDF(q.content)
    return(q.df)
  }
  
  if(isTRUE(suggestions) && isTRUE(bookmarks)){
    print("Please select either suggestions or bookmarks")
  }
}