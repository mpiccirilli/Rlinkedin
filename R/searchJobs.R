#' Search for Jobs on LinkedIn
#'
#' @description
#' \code{searchJobs} searches across LinkedIn's job postings.
#' 
#' There are several parameters that allow you to conduct either a broad or focused search.
#' 
#' In order to use this function, you must create your own appliction and apply for the Vetted API Access here: \url{https://help.linkedin.com/app/ask/path/api-dvr}.  You cannot use the default credentials supplied in the Rlinkedin package. 
#' 
#' 
#' @details
#' There are many different search parameters that allow you to make a focused search of a particular job within a certain company some area of the country. Or you can search for all jobs posted based on general keywords. 
#' 
#' @author
#' Michael Piccirilli \email{michael.r.piccirilli@@gmail.com}
#' @seealso \code{\link{getJobs}} \code{\link{searchCompanies}}
#'
#' @param token Authorization token.
#' @param keywords A keyword used in the job title or description. Multiple words should be separated by a space.
#' @param company_name Company posting the job.
#' @param job_title Title of the job.
#' @param country_code  Specify the country in which to search. This is the ISO3166 country code, and must be in lower case.
#' @param postal_code Must be combined with the \code{country_code} parameter.
#' @param distance Distance matches jobs within a distance from a central point. This is measured in miles and is best used in conjunction with both \code{country_code} and \code{postal-code}.
#' 
#' @return Returns a dataframe of jobs based input parameters
#' 
#' @examples
#' \dontrun{
#' 
#' search.results <- searchJobs(token = in.auth, keywords = "data scientist")
#' }
#' @export
#' 

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
    stop(q.content[["string(//error/message)"]])
  }
  else {
    p1 <- jobsToDF(q.content)
    search.total <- as.numeric(xmlAttrs(q.content[["//job-search/jobs"]])[[1]])
    search.count <- if(search.total<10) search.total else as.numeric(xmlAttrs(q.content[["//job-search/jobs"]])[[2]])
    total.pages <- ceiling(search.total/search.count)
    q.df <- data.frame()
    if(total.pages>1 && total.pages >10){
      total.pages <- 10  # To prevent Thr
      for(i in 2:total.pages)
      {
        if(i==1) start <- 0 else start <- (i-1)*search.count
        full_url <- paste0(base_url,kw, comp_name, jb_ttl, ctry_code, pstl_code, dist)
        pages_url <- paste0(full_url, "start=",start,"&",ct)
        query <- GET(pages_url, config(token = token))
        q.content <- content(query)
        q.tmp <- jobsToDF(q.content)
        q.df <- rbind(q.df, q.tmp)
      }
    }
    out <- rbind(p1,q.df)
    return(out)
  }
}
