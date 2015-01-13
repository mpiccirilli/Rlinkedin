#' Job Search API: Search for Jobs on LinkedIn
#'
#' The Job Search API enables search across LinkedIn's job postings.
#' 
#' Job Search API is a part of our Vetted API Access Program. You must apply and get LinkedIn's approval before using this API.
#' 
#' Throttle limits: Up to 100 returns per search, 10 returns per page. Each page is one API call. 
#'
#'
#' @param token Authorization token 
#' @param keyword Keyword search jobs by keyword
#' @param company_name Company search by company name
#' @param job_title Title search by job title
#' @param country_code  ISO3166 country code, must be in lower case
#' @param postal_code Postal Code must combined with country-code
#' @param distance Distance matches members within a distance from a central point. This is measured in miles. This is best used in combination with both country-code and postal-code.
#' @return Returns jobs based input parameters
#' @examples
#' \dontrun{
#' 
#' search.results <- searchJobs(in.auth, keywords = "data scientist")
#' }
#' @export




searchJobs <- function(token, keywords=NULL, company_name=NULL, job_title=NULL, country_code=NULL, postal_code=NULL, distance=NULL)
{
  base_url <- "https://api.linkedin.com/v1/job-search:(jobs:(id,customer-job-code,active,posting-date,expiration-date,posting-timestamp,expiration-timestamp,company:(id,name),position:(title,location,job-functions,industries,job-type,experience-level),skills-and-experience,description-snippet,description,salary,job-poster:(id,first-name,last-name,headline),referral-bonus,site-job-url,location-description))?"
  
  kw <- if(!is.null(keywords)) URLencode(paste0("keywords=",keywords,"&"))
  comp_name <- if(!is.null(company_name)) URLencode(paste0("company-name=",company_name,"&"))
  jb_ttl <- if(!is.null(job_title)) URLencode(paste0("job-title=",job_title,"&"))
  ctry_code <- if(!is.null(country_code)) URLencode(paste0("country-code=",country_code,"&")) 
  pstl_code <- if(!is.null(postal_code)) URLencode(paste0("postal-code=",postal_code,"&"))
  dist <- if(!is.null(distance)) URLencode(paste0("distance=",distance,"&")) # miles
  ct <- URLencode(paste0("count=",10))
  url <- paste0(base_url, kw, comp_name, jb_ttl, ctry_code, pstl_code, dist, ct)
  query <- GET(url, config(token=token))
  q.content <- content(query)
  if(!is.na(q.content[["number(//error/status)"]]==403)){
    print(q.content[["string(//error/message)"]])
  }
  else {
    p1 <- jobsToDF(q.content)
    search.total <- as.numeric(xmlAttrs(q.content[["//job-search/jobs"]])[[1]])
    search.count <- if(search.total<10) search.total else as.numeric(xmlAttrs(q.content[["//job-search/jobs"]])[[2]])
    total.pages <- ceiling(search.total/search.count)
    q.df <- data.frame()
    for(i in 2:total.pages)
    {
      if(i==1) start <- 0 else start <- (i-1)*search.count
      full_url <- paste0(base_url,kw, comp_name, jb_ttl, curr_sch, ctry_code, pstl_code, dist)
      pages_url <- paste0(full_url, "start=",start,"&",ct)
      query <- GET(pages_url, config(token = token))
      q.content <- content(query)
      q.tmp <- jobsToDF(q.content)
      q.df <- rbind(q.df, q.tmp)
    }
    out <- rbind(p1,q.df)
    return(out)
  }
}
