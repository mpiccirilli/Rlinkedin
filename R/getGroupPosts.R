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
  
  
  # This will return the posts of groups you're in
  url <- paste0(membership_url,"~",membership_fields)
  query <- GET(url, config(token=token))
  q.content <- content(query)
  gp.ids <- groupsToDF(q.content)$group_id
  gp.names <- groupsToDF(q.content)$group_name
  
  q.df <- data.frame()
  # This currently only retrieves the past 10 posts in each group
  # Need to nest another loop to get more
  for(i in 1:length(gp.ids))
  {
    url <- paste0(details_url, gp.ids[i], details_fields)  
    query <- GET(url, config(token=token))
    q.content <- content(query)
    temp.df <- groupPostToDF(q.content)
    q.df <- rbind(q.df, temp.df)
    }
  return(q.df)
}

