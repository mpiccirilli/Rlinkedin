#' Job Search API: Search for Jobs on LinkedIn
#'
#' Job Search API is a part of our Vetted API Access Program. You must apply and get LinkedIn's approval before using this API.
#'
#'
#' @param token Authorization token 
#' @param keyword Keyword job search 
#' @param count Authorization token 
#' @return Returns jobs based input parameters
#' @examples
#' \dontrun{
#' 
#' search.results <- searchJobs(in.auth, "data scientist")
#' }
#' @export


searchJobs <- function(token, keywords, count=20)
{
  # Need to include more parameters
  
  # In order to utilize this function you need to apply for Vetted API Access
  # Right now I only have a search based on keywords. 
  
  # Count can range from 1 to 20
  # Throttle limits: Up to 100 returns per search, 10 returns per page. Each page is one API call. 

  kw.search <- URLencode(keywords)
  start <- 0
  base_url <- paste0("https://api.linkedin.com/v1/job-search?start=",start,"&count=",count,"&")
  kw.url <- paste0("keywords=",kw.search)
  
  url <- paste0(base_url, kw.url)
  query <- GET(url, config(token = token))
  q.content <- content(query)
  search.total <- as.numeric(xmlAttrs(q.content[["//job-search/jobs[@total]"]])[[1]])
  #The number of jobs to return. Values can range between 0 and 20. The default value is 10. The total results available to any user depends on their account level.
  search.count <- as.numeric(xmlAttrs(q.content[["//job-search/jobs[@total]"]])[[2]])
  total.pages <- ceiling(search.total/search.count)
  q.df <- data.frame()
  for(i in 1:total.pages)
  {
    if(i==1) start <- 0 else start <- (i-1)*search.count
    base_url <- paste0("https://api.linkedin.com/v1/job-search?start=",start,"&count=",count,"&")
    url <- paste0(base_url, kw.url)
    query <- GET(url, config(token = token))
    q.content <- content(query)
    q.tmp <- jobsToDF(q.content)
    q.df <- rbind(q.df, q.tmp)
  }
  return(q.df)
}
