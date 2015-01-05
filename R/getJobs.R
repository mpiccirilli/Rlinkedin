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


getJobs <- function(token, suggestions=TRUE)
{
  
  if(isTRUE(suggestions)){
  url <- "http://api.linkedin.com/v1/people/~/suggestions/job-suggestions"
  query <- GET(url, config(token = token))
  q.content <- content(query)
  

  jp.nodes <- getNodeSet(q.content, "//job-poster")
  
  p.id <- lapply(jp.nodes, xpathSApply, ".//id", xmlValue)
  p.id[sapply(p.id, is.list)] <- NA
  p.id <- unlist(p.id)
  
  fname <- lapply(jp.nodes, xpathSApply, ".//first-name", xmlValue)
  fname[sapply(fname, is.list)] <- NA
  fname <- unlist(fname)
  
  lname <- lapply(jp.nodes, xpathSApply, ".//last-name", xmlValue)
  lname[sapply(lname, is.list)] <- NA
  lname <- unlist(lname)
  
  headline <- lapply(jp.nodes, xpathSApply, ".//headline", xmlValue)
  headline[sapply(headline, is.list)] <- NA
  headline <- unlist(headline)
  
  salary.node <- getNodeSet(q.content, "//salary")
  salary.node.list <- lapply(salary.node, xpathSApply, ".", xmlValue)
  salary.list.names <- seq(1, length(jp.nodes),1)
  salary.list <- sapply(salary.list.names, function(x) NULL)
  for (i in 1:length(salary.node.list))
  {
    salary.list[[i]] <- salary.node.list[[i]]
  }
  salary.list[sapply(salary.list, is.null)] <- NA
  salary <- unlist(salary.list)

  
  
  sugg.df <- data.frame(job_id=unlist(xpathApply(q.content, "//job/id", xmlValue)),
                        company_id=unlist(xpathApply(q.content, "//job/company/id", xmlValue)),
                        company_name=unlist(xpathApply(q.content, "//job/company/name", xmlValue)), 
                        salary=salary,
                        poster_id=p.id,
                        poster_fname=fname,
                        poster_lname=lname,
                        job_headline=headline,
                        job_desc=unlist(xpathApply(q.content, "//description-snippet", xmlValue))
                        )
  return(sugg.df)
  }
  
  # I've applied for Vetted API Access; cannot currently conduct a search: access denied
}