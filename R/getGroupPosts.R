#' Get Posts from your LinkedIn Groups
#'
#' @param token Authorization token 
#' @return Returns posts from groups you belong to
#' @examples
#' \dontrun{
#' 
#' my.groups <- getGroupPosts(in.auth)
#' }
#' @export


getGroupPosts <- function(token)
{
  membership_url <- "https://api.linkedin.com/v1/people/"
  membership_fields <- "/group-memberships:(group:(id,name),membership-state,show-group-logo-in-profile,allow-messages-from-members,email-digest-frequency,email-announcements-from-managers,email-for-every-new-post)"
  
  # group details:
  details_url <- "https://api.linkedin.com/v1/groups/"
  details_fields <- ":(id,name,short-description,description,relation-to-viewer:(membership-state,available-actions),posts,counts-by-category,is-open-to-non-members,category,website-url,locale,location:(country,postal-code),allow-member-invites,site-group-url,small-logo-url,large-logo-url)"
  
  # if memberships=TRUE, details=TRUE, posts=TRUE
  # This will return the posts of groups you're in
  
  url <- paste0(membership_url,"~",membership_fields)
  query <- GET(url, config(token=token))
  q.content <- content(query)
  group.ids <- unlist(xpathApply(q.content, "//group/id", xmlValue))
  q.df <- data.frame()
  for(i in 1:length(group.ids))
  {
    url <- paste0(details_url, group.ids[i], details_fields)  
    query <- GET(url, config(token=token))
    q.content <- content(query)
    
    gp.id <- q.content["number(//group/id/text())"]
    gp.name <- q.content["string(//group/name/text())"]
    
    post.nodes <- getNodeSet(q.content, "//post")
    er <- tryCatch(
      {
      post.id <- lapply(post.nodes, xpathSApply, "./id", xmlValue)
      post.id[sapply(post.id, is.list)] <- NA
      post.id <- unlist(post.id)
      
      poster.fname <- lapply(post.nodes, xpathSApply, "./creator/first-name", xmlValue)
      poster.fname[sapply(poster.fname, is.list)] <- NA
      poster.fname <- unlist(poster.fname)
      
      poster.lname <- lapply(post.nodes, xpathSApply, "./creator/last-name", xmlValue)
      poster.lname[sapply(poster.lname, is.list)] <- NA
      poster.lname <- unlist(poster.lname)
      
      post.headline <- lapply(post.nodes, xpathSApply, "./creator/headline", xmlValue)
      post.headline[sapply(post.headline, is.list)] <- NA
      post.headline <- unlist(post.headline)
      
      post.title <- lapply(post.nodes, xpathSApply, "./title", xmlValue)
      post.title[sapply(post.title, is.list)] <- NA
      post.title <- unlist(post.title)
      
    }, 
    error=function(e)
      {
      NULL
      })
    if(is.null(er))
    {
      post.id <- NA
      poster.fname <- NA
      poster.lname <- NA
      post.headline <- NA
      post.title <- NA
    }
    
    temp.df <- data.frame(group_id=gp.id, group_name=gp.name, post_id=post.id,
                          poster_fname=poster.fname, poster_lname=poster.lname,
                          post_headline=post.headline, post_title=post.title)
    q.df <- rbind(q.df, temp.df)
    }
  return(q.df)
}

