submitShare <- function(token, comment=NULL, title=NULL, description=NULL,  desc.url=NULL, img.url=NULL, visibility='anyone')
{
  base_url <- "https://api.linkedin.com/v1/people/~/shares"
  
  # if an element in the content list is given, you must also include include a url for
  # for the 'submitted-url' field
  share.xml <- newXMLNode("share")
  xml.list <- list(comment=comment, content=list(title=title, description=description,
                                        `submitted-url`=desc.url, `submitted-image-url`=img.url),
             visibility=list(code=visibility))
  
  listToXML(share.xml, xml.list)
  share.xml <- as(share.xml, "character")
  
  post.share <- POST(url=base_url, body=share.xml,  config(token=token), verbose())
  # Build in return function
  
}


