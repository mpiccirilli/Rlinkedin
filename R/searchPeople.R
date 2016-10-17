#' Search for People on LinkedIn
#'
#' @description
#' \code{searchPeople} allows you to search for connections on LinkedIn. It returns most of what shows up when you do a search for people in the box at the top of the page on linkedin.com.
#' 
#' There are a number of parameters that allow you to conduct either a broad or focused search.
#' 
#' In order to use this function, you must create your own appliction and apply for the Vetted API Access here: \url{https://help.linkedin.com/app/ask/path/api-dvr}.
#' 
#' @author
#' Michael Piccirilli \email{michael.r.piccirilli@@gmail.com}
#' @seealso \code{\link{getProfile}}
#'
#' @param token Authorization token.
#' @param keywords A keyword used in a person's profile. Multiple words should be separated by a space.
#' @param first_name Search by a user's first name.
#' @param last_name Search by a user's last name.
#' @param company_name The name of a company where someone has as worked.
#' @param current_company TRUE or FALSE, can only be used in conjunction with \code{company_name}.
#' @param title A job title someone has held
#' @param current_title TRUE or FALSE, can only be used in conjunction with \code{title}.
#' @param school_name The name of a school someone has attended.
#' @param current_school TRUE or FALSE, can only be used in conjuntion with \code{current_school}.
#' @param country_code Specify the country in which to search. This is the ISO3166 country code, and must be in lower case.
#' @param postal_code Must be combined with the \code{country_code} parameter.
#' @param distance Distance matches members within a distance from a central point. This is measured in miles and and is best used in conjunction with both \code{country_code} and \code{postal-code}.
#' @param partner Indicate whether you belong to the Partnership Program. Values: 0 or 1
#'
#' @return Returns a dataframe of people based input parameters
#' @examples
#' \dontrun{
#' 
#' search.results <- searchPeople(token=in.auth, first_name="Michael", last_name="Piccirilli")
#' }
#' @export


searchPeople <- function(token, keywords=NULL, first_name=NULL, last_name=NULL, company_name=NULL, current_company=NULL, title=NULL, current_title=NULL, school_name=NULL, current_school=NULL, country_code=NULL, postal_code=NULL, distance=NULL, partner = 0)
{
  
  if(partner == 0){
    stop("This function is no longer available through LinkedIn's open API.  \n
  If you are a member of the Partnership Program, set the 'partner' input of this function equal to 1 (default: 0).")
  }
  
  base_url <- "https://api.linkedin.com/v1/people-search:(people:(id,first-name,last-name,formatted-name,location:(name),headline,industry,num-connections,summary,specialties,positions))?"

  # Should build a nicer way of doing this, maybe with 'switch'?
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
  xml <- xmlTreeParse(q.content, useInternalNodes=TRUE)
  if(!is.na(xml[["number(//error/status)"]]==403)){
    stop(xml[["string(//error/message)"]])
  }
  if(unlistWithNAs(getNodeSet(q.content, "//people-search"), "./people", "Attrs")==0){
    stop("Sorry, no results containing all your search terms were found")
  }
  else {
    p1 <- profileToList(query)
    xml <- xmlTreeParse(q.content, useInternalNodes=TRUE)
    
    search.total <- as.numeric(xmlAttrs(xml[["//people-search/people"]])[[1]])
    search.count <- if(search.total<10) search.total else as.numeric(xmlAttrs(xml[["//people-search/people"]])[[2]])
    total.pages <- ceiling(search.total/search.count)
    if(total.pages>1 && total.pages >10){
      total.pages <- 10  # To prevent Throttle limits..
      q.list <- list()
      for(i in 2:total.pages)
      { 
        if(i==1) start <- 0 else start <- (i-1)*search.count
        full_url <- paste0(base_url, kw, fname, lname, comp, curr_comp, ttl, curr_ttl, sch_name,
                      curr_sch, ctry_code, pstl_code, dist)
        pages_url <- paste0(full_url, "start=",start,"&",ct)
        query <- GET(pages_url, config(token = token))
        q.tmp <- profileToList(query)
        q.list <- c(q.list, q.tmp)
      }
    }
    out <- c(p1,q.list)
    return(out)
  }
}
