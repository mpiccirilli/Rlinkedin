searchJobs <- function(token, keywords, count=20)
{
  # In order to utilize this function you need to apply for Vetted API Access
  # Throttle limits: Up to 100 returns per search, 10 returns per page. Each page is one API call. 
  
  keywords <- "Data Scientist"
  kw.search <- URLencode(keywords)
  count <- 20
  
  
  
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
  total.pages
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
