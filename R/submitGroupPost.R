#' Create a Group Discussion Post
#'
#' @param token Authorization token 
#' @param group_id Numeric Group ID
#' @param disc_title Group Discussion Title
#' @param disc_summary Group Discussion Summary
#' @param content_url Url for content, optinal
#' @param img_url Url for an image, optional
#' @param content_title Title for content, optional
#' @param content_desc Description of content, optional
#' @return Creates a group discussion 
#' @examples
#' \dontrun{
#' 
#' id <- 77616  \# id number for The R Project for Statistical Computing
#' disc.title <- "Test connecting to the LinkedIn API via R"
#' disc.summary <- "Im creating an R package to connect to the LinkedIn API, this is a test post from R!"
#' url <- "https://github.com/mpiccirilli"
#' content.desc <- "Dev version of access to LinkedIn API via R. Collaboration is welcomed!"
#' 
#' submitGroupPost(in.auth, 77616, disc_title=disc.title, disc_summary=disc.summary, content_url=url, content_desc=content.desc)
#' }
#' @export



submitGroupPost <- function(token, group_id, disc_title=NULL, disc_summary=NULL, content_url=NULL, img_url=NULL, content_title=NULL, content_desc=NULL)
{
  base_url <- "https://api.linkedin.com/v1/groups/"  
  url <- paste0(base_url, group_id, "/posts")
  share.xml <- newXMLNode("post")
  xml.list <- list(title=disc_title, disc_summary=summary, content=list(title=content_title, description=content_desc, `submitted-url`=content_url, `submitted-image-url`=img_url))
  listToXML(share.xml, xml.list)
  share.xml <- as(share.xml, "character")
  post.share <- POST(url=url, body=share.xml,  config(token=token), verbose())
  
  # Build in return function to show if it's been '201 Created' or '202 Accepted'
  # 201 Created means you posted to an unmoderated group
  # 202 Accepted means you posted to a moderated group and it's pending approval
}
