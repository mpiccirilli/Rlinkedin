#' Extract Posts from your LinkedIn Groups
#'
#' @description
#' \code{getGroupPosts} will retrieve posts from each LinkedIn group you belong to. 
#'
#' @author
#' Michael Piccirilli \email{michael.r.piccirilli@@gmail.com}
#' @seealso \code{\link{getGroups}} \code{\link{submitGroupPost}}
#'
#' @param token Authorization token.
#' @param partner Indicate whether you belong to the Partnership Program. Values: 0 or 1
#' 
#' @return Returns a dataframe with the 10 most recent posts from each
#' group you belong to.
#' 
#' @examples
#' \dontrun{
#' 
#' my.groups <- getGroupPosts(in.auth)
#' }
#' @export


getGroupPosts <- function(token, partner = 0)
{
  
  if(partner == 0){
    stop("This function is no longer available through LinkedIn's open API.  \n
  If you are a member of the Partnership Program, set the 'partner' input of this function equal to 1 (default: 0).")
  }
  
  
  membership_url <- "https://api.linkedin.com/v1/people/"
  membership_fields <- "/group-memberships:(group:(id,name),membership-state,show-group-logo-in-profile,allow-messages-from-members,email-digest-frequency,email-announcements-from-managers,email-for-every-new-post)"
  
  # group details:
  groups_url <- "https://api.linkedin.com/v1/groups/"
  post_fields <- "/posts:(creator:(first-name,last-name,headline),comments,id,title,summary,likes)"
  
  # This will return the posts of groups you're in
  url <- paste0(membership_url,"~",membership_fields)
  query <- GET(url, config(token=token))
  q.content <- content(query)
  xml <- xmlTreeParse(q.content, useInternalNodes=TRUE)
  if(!is.na(xml[["number(//error/status)"]]==404)){
    stop(xml[["string(//error/message)"]])
  }
  
  if(as.numeric(xmlAttrs(xml[["//group-memberships[@total]"]])[[1]])==0){
    print("You are not currently a member of any groups.")
  }
  else {
  gp.ids <- groupsToDF(q.content)$group_id
  gp.names <- groupsToDF(q.content)$group_name
  
  # This currently only retrieves the past 10 posts in each group
  # Would need to nest another loop to get more
  q.df <- data.frame()
  for(i in 1:length(gp.ids))
  {
    url <- paste0(groups_url, gp.ids[i], post_fields)  
    query <- GET(url, config(token=token))
    q.content <- content(query)
    temp.df <- groupPostToDF(q.content)
    q.df <- rbind(q.df, temp.df)
    }
  return(q.df)
  }
  # It's possible to extract info of poeple who commented and liked the posts
  # Perhaps build in additional featur
}