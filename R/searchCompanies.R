#' Company Search API: Search for Companies on LinkedIn
#'
#'
#' The Company Search API enables search across company pages.
#' 
#'
#' @param token Authorization token 
#' @param keywords Keyword people search 
#' @return Returns a search of companies based on keywords, industries, or location
#' @examples
#' \dontrun{
#' 
#' search.comp <- searchCompanies(in.auth, "LinkedIn")
#' 
#' }
#' @export


searchCompanies <- function(token, keywords)
{
  
  base_url <- "https://api.linkedin.com/v1/company-search:(companies:(id,name,universal-name,website-url,industries,status,logo-url,blog-rss-url,twitter-id,employee-count-range,specialties,locations,description,stock-exchange,founded-year,end-year,num-followers))?"
  
  
  # Add in search by industry and location? as well
  kw <- if(!is.null(keywords)) URLencode(paste0("keywords=",keywords,"&"))
  ct <- URLencode(paste0("count=",10))
  
  url <- paste0(base_url, kw, ct)
  query <- GET(url, config(token=token))
  q.content <- content(query)
  if(!is.na(q.content[["number(//error/status)"]]==403)){
    stop(q.content[["string(//error/message)"]])
  }
  else {
    p1 <- companySearchToList(query)
    search.total <- as.numeric(xmlAttrs(q.content[["//company-search/companies"]])[[1]])
    search.count <- if(search.total<10) search.total else as.numeric(xmlAttrs(q.content[["//company-search/companies"]])[[2]])
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


