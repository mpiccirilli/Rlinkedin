#' Share a Network Update 
#'
#'
#' If one of the content elements is specified you must also include include a url for the post
#'
#' @param token Authorization token 
#' @param comment Headline of the post
#' @param content_title Title of the post
#' @param content_desc Description of the post 
#' @param content_url Url to content
#' @param content_img Url to image
#' @param visibility 'anyone' or 'connections-only'
#' @return Creates a post to the network feed
#' @examples
#' \dontrun{
#' 
#' comment <- "Test connecting to the LinkedIn API via R"
#' title <- "Im creating an R package to connect to the LinkedIn API, this is a test post from R!"
#' url <- "https://github.com/mpiccirilli"
#' desc <- "Dev version of access to LinkedIn API via R. Collaboration is welcomed!"
#' 
#' submitShare(in.auth, comment=comment, content_tile=title, content_url=url, content_desc=desc)
#' }
#' @export


submitShare <- function(token, comment=NULL, content_title=NULL, content_desc=NULL,  content_url=NULL, content_img=NULL, visibility='anyone')
{
  base_url <- "https://api.linkedin.com/v1/people/~/shares"
  
  # if an element in the content list is given, you must also include include a url for
  # for the 'submitted-url' field
  
  share.xml <- newXMLNode("share")
  xml.list <- list(comment=comment, content=list(title=content_title, description=content_desc,
                                        `submitted-url`=content_url, `submitted-image-url`=content_img), visibility=list(code=visibility))
  
  listToXML(share.xml, xml.list)
  share.xml <- as(share.xml, "character")
  
  post.share <- POST(url=base_url, body=share.xml,  config(token=token), verbose())
  # Build in return function
  
}


