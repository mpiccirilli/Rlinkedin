submitGroupPost <- function(token, group_id, disc_title=NULL, summary=NULL, content_url=NULL, img_url=NULL, content_title=NULL, content_desc=NULL)
{
  base_url <- "https://api.linkedin.com/v1/groups/"  
  url <- paste0(base_url, group_id, "/posts")
  share.xml <- newXMLNode("post")
  xml.list <- list(title=disc_title, summary=summary, content=list(title=content_title, description=content_desc, `submitted-url`=content_url, `submitted-image-url`=img_url))
  listToXML(share.xml, xml.list)
  share.xml <- as(share.xml, "character")
  post.share <- POST(url=url, body=share.xml,  config(token=token), verbose())
  # Build in return function
}
