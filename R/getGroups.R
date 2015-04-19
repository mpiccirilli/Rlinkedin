#' Retrieve LinkedIn Group Information
#'
#' @description
#' \code{getGroups} retrieves information and settings about the LinkedIn groups you belong to. 
#' 
#' @details
#' This function returns information about what groups you belong to, either with or without group details. Group details can be called by setting the option \code{details} = TRUE.
#' 
#' @author
#' Michael Piccirilli \email{michael.r.piccirilli@@gmail.com}
#' @seealso \code{\link{getGroupPosts}} \code{\link{submitGroupPost}}
#'
#' @param token Authorization token.
#' @param details TRUE or FALSE. If TRUE, it will return group details. FALSE is default.
#' 
#' @return Returns a dataframe including group profile information.
#' 
#' When \code{details} = FALSE (default), the function will return information about each group's settings such as whether it allows messages from members, email frequency, and manager announcements.
#' 
#' When \code{details} = TRUE, the function will return both a short and long
#' description of the group.
#' 
#' @examples
#' \dontrun{
#' 
#' my.groups <- getGroups(token = in.auth, details=TRUE)
#' }
#' @export


getGroups <- function(token, details=FALSE)
{
  # This function will get all the groups a user (including self) is a member of
  membership_url <- "https://api.linkedin.com/v1/people/"
  membership_fields <- "/group-memberships:(group:(id,name),membership-state,show-group-logo-in-profile,allow-messages-from-members,email-digest-frequency,email-announcements-from-managers,email-for-every-new-post)"
  
  # group details:
  groups_url <- "https://api.linkedin.com/v1/groups/"
  details_fields <- ":(id,name,short-description,description,relation-to-viewer:(membership-state,available-actions),posts,counts-by-category,is-open-to-non-members,category,website-url,locale,location:(country,postal-code),allow-member-invites,site-group-url,small-logo-url,large-logo-url)"
  
  
  # if details=FALSE
  # This will return a list of groups you're in 
  if(!isTRUE(details)){
    url <- paste0(membership_url,"~",membership_fields)
    query <- GET(url, config(token=token))
    q.content <- content(query)
    r <- xmlRoot(q.content)
    if(xmlAttrs(r)[[1]]==0){
      print("You are not currently a member of any groups.")
    }
    else {
      q.df <- groupsToDF(q.content)
      return(q.df)
    }
  }
    
  # if details=TRUE
  # This will return group details of groups you're in
  if(isTRUE(details)){
    url <- paste0(membership_url,"~",membership_fields)
    query <- GET(url, config(token=token))
    q.content <- content(query)
    r <- xmlRoot(q.content)
    if(xmlAttrs(r)[[1]]==0){
      print("You are not currently a member of any groups.")
    }
    else {
      gp.ids <- groupsToDF(q.content)$group_id
      q.df <- data.frame()
      for(i in 1:length(gp.ids))
      {
        url <- paste0(groups_url, gp.ids[i], details_fields)  
        query <- GET(url, config(token=token))
        q.content <- content(query)
        temp.df <- data.frame(group_id=q.content["number(//group/id/text())"],
                              group_name=q.content["string(//group/name/text())"],
                              group_desc_short=q.content["string(//group/short-description/text())"],
                              group_desc_long=q.content["string(//group/description/text())"]
                              )
        q.df <- rbind(q.df, temp.df)
      }
      return(q.df)
    }
  }
}

