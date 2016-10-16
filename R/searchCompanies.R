#' Search for Companies on LinkedIn
#'
#' @description
#' \code{searchCompanies} searches across LinkedIn's companies pages based on keywords, location, and industry. 
#' 
#' @details
#' In order to narrow the search down by location or industry, you must look up the proper input codes on the linkedin website.  The geography codes can be found here: \url{https://developer.linkedin.com/docs/reference/geography-codes}, and the industry codes can be found here: \url{https://developer.linkedin.com/docs/reference/industry-codes}.
#' 
#' @author
#' Michael Piccirilli \email{michael.r.piccirilli@@gmail.com}
#' @seealso \code{\link{getCompany}} \code{\link{searchJobs}}
#'
#' @param token Authorization token. 
#' @param keywords A keyword used anywhere in a company's listing. Multiple words should be separated by a space.
#' @param location LinkedIn geography code, found here: \url{https://developer.linkedin.com/docs/reference/geography-codes}.
#' @param industry LinkedIn industry code, found here: \url{https://developer.linkedin.com/docs/reference/industry-codes}.
#' 
#' @return Returns a list, information includes company id, company name, universal name, website, twitter handle, employee count, founded date, number of followers, and company description.
#' @examples
#' \dontrun{
#' 
#' search.comp <- searchCompanies(in.auth, keywords = "LinkedIn")
#' 
#' }
#' @export


searchCompanies <- function(token, keywords, location=NULL, industry=NULL)
{

  base_url <- "https://api.linkedin.com/v1/company-search:(companies:(id,name,universal-name,website-url,industries,status,logo-url,blog-rss-url,twitter-id,employee-count-range,specialties,locations,description,stock-exchange,founded-year,end-year,num-followers))?"
  
  kw <- if(!is.null(keywords)) URLencode(paste0("keywords=",keywords,"&"))
  loc <- if(!is.null(location)) URLencode(paste0("facet=location,",location,"&"))
  ind <- if(!is.null(industry)) URLencode(paste0("facet=industry,", industry,"&"))
  ct <- URLencode(paste0("count=",10))
  
  if(!is.null(location) | !is.null(industry)){
    facet_url <- paste0(base_url, "facets=location,industry&")
    url <- paste0(facet_url, kw, loc, ind, ct)
  }
  else{
    url <- paste0(base_url, kw, ct)
  }
  query <- GET(url, config(token=token))
  q.content <- content(query)
  xml <- xmlTreeParse(q.content, useInternalNodes=TRUE)
  
  if(!is.na(xml[["number(//error/status)"]]==403)){
    stop(xml[["string(//error/message)"]])
  }
  else {
    p1 <- companySearchToList(query)
    xml <- xmlTreeParse(q.content, useInternalNodes=TRUE)
    search.total <- as.numeric(xmlAttrs(xml[["//company-search/companies"]]))[[1]]
    search.count <- if(search.total<10) search.total else as.numeric(xmlAttrs(xml[["//company-search/companies"]])[[2]])
    
    total.pages <- ceiling(search.total/search.count)
    if(total.pages>1 && total.pages >10){
      total.pages <- 10  # To prevent Throttle limits..
      q.list <- list()
      for(i in 2:total.pages)
      { 
        if(i==1) start <- 0 else start <- (i-1)*search.count
        full_url <- paste0(base_url, kw)
        pages_url <- paste0(full_url, "start=",start,"&",ct)
        query <- GET(pages_url, config(token = token))
        q.tmp <- companySearchToList(query)
        q.list <- c(q.list, q.tmp)
      }
    }
    out <- c(p1,q.list)
    return(out)
  }
}

