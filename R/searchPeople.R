#' People Search API: Search for People on LinkedIn
#'
#' The People Search API returns information about people. It lets you implement most of what shows up when you do a search for "People" in the top right box on LinkedIn.com.
#' 
#' People Search API is a part of LinkedIn's Vetted API Access Program. You must apply and get LinkedIn's approval before using this API.
#' 
#' Up to 100 returns per search, 10 returns per page. Each page is one API call. 
#'
#' @param token Authorization token 
#' @param keywords Keyword people search 
#' @param first_name First Name  
#' @param last_name Last Name
#' @param company_name Company Name 
#' @param current_company TRUE/FALSE
#' @param title Job Title
#' @param current_title TRUE/FALSE
#' @param school_name School Name of a school
#' @param curent_school TRUE/FALSE 
#' @param country_code TRUE/FALSE 
#' @param postal_code Code Must be combined with the country-code parameter.
#' @param distanace Distance Matches members within a distance from a central point. This is measured in miles.
#'
#' @return Returns people search based input parameters
#' @examples
#' \dontrun{
#' 
#' search.results <- searchPeople(token=in.auth, first_name="Michael", last_name="Piccirilli")
#' }
#' @export


searchPeople <- function(token, keywords=NULL, first_name=NULL, last_name=NULL, company_name=NULL, current_company=NULL, title=NULL, current_title=NULL, school_name=NULL, current_school=NULL, country_code=NULL, postal_code=NULL, distance=NULL)
{
  base_url <- "https://api.linkedin.com/v1/people-search:(people:(id,first-name,last-name,formatted-name,location:(name),headline,industry,num-connections,summary,specialties,positions))?"

  # Should build a nicer way of doing this...
  kw <- if(!is.null(keywords)) URLencode(paste0("keywords=",keywords,"&"))
  fname <- if(!is.null(first_name)) URLencode(paste0("first-name=",first_name,"&"))
  lname <- if(!is.null(last_name)) URLencode(paste0("last-name=",last_name,"&"))
  comp <- if(!is.null(company_name)) URLencode(paste0("company-name=",company_name,"&"))
  curr_comp <- if(!is.null(current_company)) URLencode(paste0("current-company=",current_company,"&")) # true/false
  ttl <- if(!is.null(title)) URLencode(paste0("title=",title,"&"))
  curr_ttl <- if(!is.null(current_title)) URLencode(paste0("current-title=",current_title,"&")) # true/false
  sch_name <- if(!is.null(school_name)) URLencode(paste0("school-name=",school_name,"&"))
  curr_sch <- if(!is.null(current_school)) URLencode(paste0("current-school=",current_school,"&")) # true/false
  ctry_code <- if(!is.null(country_code)) URLencode(paste0("country-code=",country_code,"&")) 
  pstl_code <- if(!is.null(postal_code)) URLencode(paste0("postal-code=",postal_code,"&"))
  dist <- if(!is.null(distance)) URLencode(paste0("distance=",distance,"&")) # miles
  ct <- URLencode(paste0("count=",10))
  
  url <- paste0(base_url, kw, fname, lname, comp, curr_comp, ttl, curr_ttl, sch_name,
               curr_sch, ctry_code, pstl_code,dist,ct)
  query <- GET(url, config(token=token))
  q.content <- content(query)
  if(!is.na(q.content[["number(//error/status)"]]==403)){
    print(q.content[["string(//error/message)"]])
  }
  else {
    p1 <- searchPeopleToDF(q.content)
    search.total <- as.numeric(xmlAttrs(q.content[["//people-search/people"]])[[1]])
    search.count <- if(search.total<10) search.total else as.numeric(xmlAttrs(q.content[["//people-search/people"]])[[2]])
    total.pages <- ceiling(search.total/search.count)
    if(total.pages>1){
      q.df <- data.frame()
      for(i in 2:total.pages)
      { 
        if(i==1) start <- 0 else start <- (i-1)*search.count
        full_url <- paste0(base_url, kw, fname, lname, comp, curr_comp, ttl, curr_ttl, sch_name,
                      curr_sch, ctry_code, pstl_code, dist)
        pages_url <- paste0(full_url, "start=",start,"&",ct)
        query <- GET(pages_url, config(token = token))
        q.content <- content(query)
        q.tmp <- searchPeopleToDF(q.content)
        q.df <- rbind(q.df, q.tmp)
      }
    }
    out <- rbind(p1,q.df)
    return(out)
  }
}
