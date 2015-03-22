#' Share an update to your network's activity feed
#'
#' @description
#' \code{submitShare} will post a network update to the newsfeed of your connections.  You can select the visibility of your post to be seen either by 'anyone' or 'connections-only'. 
#' 
#' @details
#' If either \code{content_title} or \code{content_desc} is specified, you must also include a \code{content_url} for the post.
#'
#'
#' @author
#' Michael Piccirilli \email{michael.r.piccirilli@@gmail.com}
#' @seealso \code{\link{submitGroupPost}}
#'
#' @param token Authorization token.
#' @param comment Headline of your post.
#' @param content_title Title of your post.
#' @param content_desc Description of your post.
#' @param content_url Url to content you'd like to share. This is required if you specify either \code{content_title} or \code{content_desc}. 
#' @param content_img Url to an image you would like to include in your post, optional.
#' @param visibility Choose the visibility of the post. The choices are 'anyone' or 'connections-only'.
#' 
#' @return Shares an update to your networks's activity feed.
#' 
#' @examples
#' \dontrun{
#' 
#' comment <- "Test connecting to the LinkedIn API via R"
#' title <- "Im creating an R package to connect to the LinkedIn API, this is a test post from R!"
#' url <- "https://github.com/mpiccirilli"
#' desc <- "Dev version of access to LinkedIn API via R. Collaboration is welcomed!"
#' 
#' submitShare(token = in.auth, comment=comment, content_tile=title,
#'             content_url=url, content_desc=desc)
#' }
#' @export


submitShare <- function(token, comment=NULL, content_title=NULL, content_desc=NULL,  content_url=NULL, content_img=NULL, visibility='anyone')
{
  base_url <- "https://api.linkedin.com/v1/people/~/shares"
  share.xml <- newXMLNode("share")
  xml.list <- list(comment=comment, content=list(title=content_title, description=content_desc,
               `submitted-url`=content_url, `submitted-image-url`=content_img),
               visibility=list(code=visibility))
  listToXML(share.xml, xml.list)
  share.xml <- as(share.xml, "character")
  post.share <- POST(url=base_url, body=share.xml,  config(token=token))
  if(post.share$status_code==201){
    print("Post created")
  }
  if(post.share$status_code!=201) {
      print("Bad request. You must include a content url.")
  }
}