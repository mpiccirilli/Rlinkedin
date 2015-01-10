#' Create a Group Discussion Post
#'
#'
#' Must include a minimum of a discussion title, discussion summary, and content title"
#'
#' @param token Authorization token 
#' @param group_id Numeric Group ID
#' @param disc_title Group Discussion Title, required
#' @param disc_summary Group Discussion Summary, required
#' @param content_url Url for content, optinal
#' @param content_img Url for an image, optional
#' @param content_title Title for content, required
#' @param content_desc Description of content, optional
#' @return Creates a group discussion 
#' @examples
#' \dontrun{
#' 
#' my.groups <- getGroups(in.auth)
#' 
#' id <- my.groups$group_id[1]
#' disc.title <- "Test connecting to the LinkedIn API via R"
#' disc.summary <- "Im creating an R package to connect to the LinkedIn API, this is a test post from R!"
#' url <- "https://github.com/mpiccirilli"
#' content.desc <- "Dev version of access to LinkedIn API via R. Collaboration is welcomed!"
#' 
#' submitGroupPost(in.auth, group_id=id, disc_title=disc.title, disc_summary=disc.summary, content_url=url, content_desc=content.desc)
#' }
#' @export


submitGroupPost <- function(token, group_id, disc_title=NULL, disc_summary=NULL, content_url=NULL, content_img=NULL, content_title=NULL, content_desc=NULL)
{
  base_url <- "https://api.linkedin.com/v1/groups/"  
  url <- paste0(base_url, group_id, "/posts")
  share.xml <- newXMLNode("post")
  xml.list <- list(title=disc_title, summary=disc_summary, content=list(title=content_title, description=content_desc, `submitted-url`=content_url, `submitted-image-url`=content_img))
  listToXML(share.xml, xml.list)
  share.xml <- as(share.xml, "character")
  post.share <- POST(url=url, body=share.xml,  config(token=token))
  if(post.share$status_code==202){
    print("Post created, pending moderator approval")
  }
  if(post.share$status_code==201){
    print("Post created")
  }
  if(post.share$status_code!=201 && post.share$status_code!=202) {
    print("Bad request. Please include a minimum of a discussion title, discussion summary, and content title")
  }
}
