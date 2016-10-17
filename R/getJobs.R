#' Bookmarked and Recommended Jobs on LinkedIn
#'
#' @description
#' \code{getJobs} can be used to retrieve your bookmarked and 
#' suggested jobs.
#'
#' @details
#' This function can return either jobs you've bookmarked on LinkedIn, 
#' or jobs LinkedIn is recommending for you, but not both at the same time.
#'
#' @author
#' Michael Piccirilli \email{michael.r.piccirilli@@gmail.com}
#' @seealso \code{\link{searchJobs}}
#'
#' @param token Authorization token.
#' @param suggestions TRUE or FALSE. If TRUE, it will return LinkedIn's job recommendations.
#' @param bookmarks TRUE or FALSE. If TRUE, it will return jobs you've bookmarked on LinkedIn.
#' @param partner Indicate whether you belong to the Partnership Program. Values: 0 or 1
#' 
#' @return Returns a dataframe of recommended or bookmarked jobs.
#' 
#' @examples
#' \dontrun{
#' 
#' job.suggestions <- getJobs(in.auth, suggestions=TRUE)
#' job.bookmarks <- getJobs(in.auth, bookmarks=TRUE)
#' 
#' ## Will return NULL
#' job.fail <- getJobs(in.auth) 
#' 
#' }
#' @export


getJobs <- function(token, suggestions=NULL, bookmarks=NULL, partner = 0)
{ 
  
  if(partner == 0){
    stop("This function is no longer available through LinkedIn's open API.  \n
  If you are a member of the Partnership Program, set the 'partner' input of this function equal to 1 (default: 0).")
  }
  
  
  if(!is.null(suggestions) && !is.null(bookmarks) || is.null(suggestions) && is.null(bookmarks)){
    print("Please select either suggestions or bookmarks")
  }
  
  if(isTRUE(suggestions) && is.null(bookmarks)){
  url <- "http://api.linkedin.com/v1/people/~/suggestions/job-suggestions"
  query <- GET(url, config(token = token))
  q.content <- content(query)
  xml <- xmlTreeParse(q.content, useInternalNodes=TRUE)
  if(!is.na(xml[["number(//error/status)"]]==404)){
    stop(xml[["string(//error/message)"]])
  }
  q.df <- jobRecsToDF(q.content)
  return(q.df)
  }
  
  if(isTRUE(bookmarks) && is.null(suggestions)){
    url <- "https://api.linkedin.com/v1/people/~/job-bookmarks"
    query <- GET(url, config(token = token))
    q.content <- content(query)
    xml <- xmlTreeParse(q.content, useInternalNodes=TRUE)
    if(!is.na(xml[["number(//error/status)"]]==404)){
      stop(xml[["string(//error/message)"]])
    }
    q.df <- jobBookmarksToDF(q.content)
    return(q.df)
  }
}