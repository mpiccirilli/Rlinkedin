#' Extract LinkedIn Profile Information
#'
#' @description
#' \code{getProfile} retrieve's proflie information about to yourself, your connections, or another individual.
#' 
#' @details
#' There are three separate calls in \code{getProfile}.
#' 
#' The first is to return profile information about yourself.  The only input
#' into the function under this scenario is the \code{token}. 
#' 
#' The second is to return profile information about all your 1st degree
#' connections.  You need to supply the \code{token} and set the 
#' \code{connections} = TRUE. 
#' 
#' The third is to return profile information about an individual based on 
#' their id number.  This can be found if you search your connections using
#' the \code{getMyConnections} function. 
#' 
#' @author
#' Michael Piccirilli \email{michael.r.piccirilli@@gmail.com}
#' @seealso \code{\link{searchPeople}}, \code{\link{getMyConnections}}
#'
#' @param token Authorization token.
#' @param connections TRUE or FALSE. If TRUE, will return profile information of your connections. FALSE is default.
#' @param id Numeric ID number of a LinkedIn member.
#' @param partner Indicate whether you belong to the Partnership Program. Values: 0 or 1
#' 
#' @return Returns a list of profile information.
#' 
#' @examples
#' \dontrun{
#' 
#' profiles <- getProfile(in.auth, connections=TRUE)
#' }
#' @export



getProfile <- function(token, connections=FALSE, id=NULL, partner = 0)
{
  
  if( (isTRUE(connections) | !is.null(id)) & partner == 0 ){
    stop("This function is no longer available through LinkedIn's open API.  \n
  If you are a member of the Partnership Program, set the 'partner' input of this function equal to 1 (default: 0).")
  }
  
  
  base_url <- "https://api.linkedin.com/v1/people/"
  profile_fields <- ":(id,first-name,last-name,formatted-name,location:(name),headline,industry,num-connections,summary,specialties,positions,public-profile-url)"
  
  # if connections=FALSE && id=NULL:
  # This will return all basic profile information about yourself
  if( is.null(id) && !isTRUE(connections) ){
    url <- paste0(base_url,"~",profile_fields)
    query <- GET(url, config(token=token))
    q.list <- profileToList(query)
    return(q.list)
  }
  

  # if connections=FALSE && id=#
  # This will return all basic profile information about person
  if( !isTRUE(connections) && length(id)==1 ){
    url <- paste0(base_url, "id=", id, profile_fields)
    query <- GET(url, config(token=token))
    q.content <- content(query)
    xml <- xmlTreeParse(q.content, useInternalNodes=TRUE)
    if(!is.na(xml[["number(//error/status)"]]==404)){
      stop(xml[["string(//error/message)"]])
    }
    q.list <- profileToList(query)
    return(q.list)
  }
  
  # if connections=TRUE && id=NULL
  # This will return profile information of all your connections
  if(isTRUE(connections) && is.null(id) && partner != 0){
  url <- paste0(base_url, "~/connections",profile_fields)
  query <- GET(url, config(token=token))
  q.content <- content(query)
  xml <- xmlTreeParse(q.content, useInternalNodes=TRUE)
  if(!is.na(xml[["number(//error/status)"]]==404)){
    stop(xml[["string(//error/message)"]])
  }
  q.list <- profileToList(query)
  return(q.list)
  
  }
  # if connections=TRUE && id=#
  # give an error, cannot perform such search
  if(!is.null(id) && isTRUE(connections)){
    print("Cannot perform query with connections=TRUE and id #")
  }
}
