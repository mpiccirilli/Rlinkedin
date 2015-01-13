#' Bookmarked and Recommended Jobs on LinkedIn
#'
#' @param token Authorization token 
#' @param suggestions Suggestions LinkedIn job recommendations
#' @param bookmarks Bookmarks LinkedIn jobs you've bookmarked
#' @return Returns LinkedIn recommended or bookmarked jobs
#' @examples
#' \dontrun{
#' 
#' job.suggestions <- getJobs(in.auth, suggestions=TRUE)
#' job.bookmarks <- getJobs(in.auth, bookmarks=TRUE)
#' 
#' job.fail <- getJobs(in.auth) \# Will return null
#' 
#' }
#' @export


getJobs <- function(token, suggestions=NULL, bookmarks=NULL)
{ 
  
  if(!is.null(suggestions) && !is.null(bookmarks) || is.null(suggestions) && is.null(bookmarks)){
    print("Please select either suggestions or bookmarks")
  }
  
  if(isTRUE(suggestions) && is.null(bookmarks)){
  url <- "http://api.linkedin.com/v1/people/~/suggestions/job-suggestions"
  query <- GET(url, config(token = token))
  q.content <- content(query)
  q.df <- jobRecsToDF(q.content)
  return(q.df)
  }
  
  if(isTRUE(bookmarks) && is.null(suggestions)){
    url <- "https://api.linkedin.com/v1/people/~/job-bookmarks"
    query <- GET(url, config(token = token))
    q.content <- content(query)
    q.df <- jobBookmarksToDF(q.content)
    return(q.df)
  }
}