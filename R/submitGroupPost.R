submitGroupPost <- function(token)
{
  # This might wo
  base_url <- "https://api.linkedin.com/v1/groups/77616/posts"
  txt <- '
<post>
<title>Test connecting to the LinkedIn API via R</title>
<summary>Im creating an R package to connect to the LinkedIn API, this is a test post from R!</summary>
<content>
<submitted-url>https://github.com/mpiccirilli/Rlinkedin</submitted-url>
<title>Rlinkedin</title>
<description>Dev version of access to LinkedIn API via R. Collaboration is welcomed!</description>
</content>
</post>'
  pst <- POST(url=base_url, body=txt,  config(token=token), verbose())
  pst
  
  
  
  
  title <- "Test connecting to the LinkedIn API via R"
  url <- paste(base_url, "title:(", title.e, ")", sep="")
  
  
  title.u <- URLencode(title)
  
  title.e <- enc2utf8(title)
  title.e <- gsub(" ", "+",title.e)
  
  test.post <- POST(url, config(token=token))
  
  url <- paste0(base_url, text)
  
  cs <- GET(url, config(token=token))
  cs$cookies$lidc
  pst.data <- POST(url, body=)
  top

}





top <- newXMLNode("post")
newXMLNode("title", "Test Post: Connecting to the LinkedIn API via R", parent = top)
newXMLNode("summary","Im creating an R package to connect to the LinkedIn API, this is a test post from R!", parent=top)
top


cdss.id <- q.df$group_id[5]


POST(b2, body = list(y = upload_file(system.file("CITATION"))))
POST(b2, body = list(x = "A simple text string"), encode = "json")

''

  
post <- "mypost.xml"
saveXML(txt, post)
list(file=upload_file("~/Documents/GitHub/Rlinkedin/myfile.xml"))




pst$request
xmlfile <- xmlParse("myfile.xml")
POST(b2, body = FALSE, verbose())

httpPUT("http://127.0.0.1:5984/temp_db")
httpPUT(base_url, xmlfile)
