getProfile <- function(token, connections=FALSE, id=NULL)
{
 
  base_url <- "https://api.linkedin.com/v1/people/"
  basicprofile_fields <- ":(id,first-name,last-name,maiden-name,formatted-name,headline,industry,num-connections,summary,specialties,positions,picture-url,public-profile-url)"
  
  # if connections=FALSE && id=NULL:
  # This will return all basic profile information about yourself
  if(is.null(id) && !isTRUE(connections)){
    url <- paste0(base_url,"~",basicprofile_fields)
    query <- GET(url, config(token=token))
    q.content <- content(query)
    q.list <- xmlToList(q.content)
    q.df <- do.call(data.frame, unlist(q.list, recursive=FALSE))
    return(q.df)
  }
  
  
  # if connections=FALSE && id=#
  # This will return all basic profile information about person
  if(!isTRUE(connections) && length(id)==1){
    url <- paste0(base_url, "id=", id, basicprofile_fields)
    query <- GET(url, config(token=token))
    q.content <- content(query)
    q.list <- xmlToList(q.content)
    q.df <- do.call(data.frame, unlist(q.list, recursive=FALSE))
    return(q.df)
  }
  
  # if connections=TRUE && id=NULL
  # This will return profile information of all your connections
  if(isTRUE(connections) && is.null(id)){
  url <- paste0(base_url, "~/connections",basicprofile_fields)
  query <- GET(url, config(token=token))
  q.content <- content(query)
  q.df <- ldply(xmlToList(q.content), data.frame)
  return(q.df)
  }
  
  # if connections=TRUE && id=#
  # give an error, cannot perform such search
  if(!is.null(id) && isTRUE(connections)){
    print("Cannot perform query with connections=TRUE and id #")
  }
}
