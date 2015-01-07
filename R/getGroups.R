#' Get info from your LinkedIn Groups
#'
#' @param token Authorization token 
#' @param details 
#' @return Returns information about what groups you belong to, either with or without detailed information
#' @examples
#' \dontrun{
#' 
#' my.groups <- getGroups(in.auth, details=TRUE)
#' }
#' @export


getGroups <- function(token, details=FALSE)
{
  # This function will get all the groups a user (including self) is a member of
  membership_url <- "https://api.linkedin.com/v1/people/"
  membership_fields <- "/group-memberships:(group:(id,name),membership-state,show-group-logo-in-profile,allow-messages-from-members,email-digest-frequency,email-announcements-from-managers,email-for-every-new-post)"
  
  # group details:
  details_url <- "https://api.linkedin.com/v1/groups/"
  details_fields <- ":(id,name,short-description,description,relation-to-viewer:(membership-state,available-actions),posts,counts-by-category,is-open-to-non-members,category,website-url,locale,location:(country,postal-code),allow-member-invites,site-group-url,small-logo-url,large-logo-url)"
  
  
  # if details=FALSE
  # This will return a list of groups you're in 
  if(!isTRUE(details)){
    url <- paste0(membership_url,"~",membership_fields)
    query <- GET(url, config(token=token))
    q.content <- content(query)
    q.df <- groupsToDF(q.content)
    return(q.df)
  }
    
  # if details=TRUE
  # This will return group details of groups you're in
  if(isTRUE(details)){
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
      gp.s.desc <- q.content["string(//group/short-description/text())"]
      gp.l.desc <- q.content["string(//group/description/text())"]
      temp.df <- data.frame(group_id=gp.id, group_name=gp.name,
                            group_desc_short=gp.s.desc, group_desc_long=gp.l.desc)
      q.df <- rbind(q.df, temp.df)
    }
    return(q.df)
  }
}

