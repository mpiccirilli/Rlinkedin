#' Retrieve Company Profile Information
#'
#' @description
#' \code{getCompany} retrieves company profiles using a company Id, a universal name, or an email domain.
#' 
#' @details
#' The 'universal name' needs to be the exact name seen at the end of the URL on the company page on linkedin.com.
#' 
#' @author
#' Michael Piccirilli \email{michael.r.piccirilli@@gmail.com}
#' @seealso \code{\link{searchCompanies}}
#'
#' @param token Authorization token.
#' @param universal_name LinkedIn universal company name. This is the exact name seen at the end of the URL on the company page on linkedin.com.
#' @param email_domain The email domain used by the company.
#' @param company_id LinkedIn company ID. 
#'
#' @return Returns company profile data, such as LinkedIn ID, name, universal-name, email-domains, company-type, ticker, website-url, industries, status, twitter handle, employee-count-range, specialties, locations, description, founded-year, and number of followers.
#' 
#' The output when specifying the \code{universal_name} or \code{company_id} will be in a list, whereas the output when specifying the \code{email_domain} will be a dataframe.
#' 
#' @examples
#' \dontrun{
#' 
#' company.name <- getCompany(token=in.auth, universal_name="Facebook")
#' 
#' company.email <- getCompany(token=in.auth, email_domain = "columbia.edu")
#' 
#' # Main Columbia Name:
#' company.id <- getCompany(token=in.auth, company_id = company.email$company_id[14])
#' 
#' }
#' @export

getCompany <- function(token, universal_name=NULL, email_domain=NULL, company_id=NULL)
{ 
  base_url <- "https://api.linkedin.com/v1/companies"
  field_selectors <- ":(id,name,universal-name,email-domains,company-type,ticker,website-url,industries,status,twitter-id,employee-count-range,specialties,locations,description,founded-year,num-followers)"
  
  #Search by Email Domain:
  if(!is.null(email_domain))
  {
    email_addy <- if(!is.null(email_domain)) URLencode(paste0("?email-domain=",email_domain))
    url <- paste0(base_url,email_addy)
    query <- GET(url, config(token=token))
    q.content <- content(query)
    if(!is.na(q.content[["number(//error/status)"]]==404)){
      stop(q.content[["string(//error/message)"]])
    }
    n.companies <- unlistWithNAs(getNodeSet(q.content, "//companies"), "//companies", "Attrs")
    nodes <- getNodeSet(q.content, "//company")  
    email.df <- data.frame(company_id=unlistWithNAs(nodes, "./id"),
                           company_name=unlistWithNAs(nodes, "./name"))
    return(email.df)
  }
  
  # Search by Universal Name:
  if(!is.null(universal_name))
  {
    uni_name <- if(!is.null(universal_name)) URLencode(paste0("/universal-name=", gsub(" ", "-",universal_name)))
    uni_name <- tolower(uni_name)
    url <- paste0(base_url, uni_name, field_selectors)
    query <- GET(url, config(token=token))
    q.content <- content(query)
    if(!is.na(q.content[["number(//error/status)"]]==404)){
      stop(q.content[["string(//error/message)"]])
    }
    q.list <- companyProfileToList(query)
    return(q.list)
  }
  
  # Search by Company ID:
  if(!is.null(company_id))
  {
    url <- paste0(base_url,"/",company_id,field_selectors)
    query <- GET(url, config(token=token))
    q.content <- content(query)
    if(!is.na(q.content[["number(//error/status)"]]==404)){
      stop(q.content[["string(//error/message)"]])
    }
    q.list <- companyProfileToList(query)
    return(q.list)
  }
  # If more than one option is selected:
  if( sum( as.numeric(!is.null(universal_name)) + as.numeric(!is.null(email_domain)) + 
             as.numeric(!is.null(company_id)) ) > 1){
    stop("Please search by only one: universal_name, email_domain, or company_id")
  }    
}
