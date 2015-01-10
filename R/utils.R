unlistWithNAs <- function(node_set, node_path)
{
  x.list <- lapply(node_set, xpathSApply, node_path, xmlValue)
  x.list[sapply(x.list, is.list)] <- NA
  x.list <- unlist(x.list)
}

nullObjTest <- function(x) is.null(x) | all(sapply(x, is.null))  

rmNullElements <- function(x)
{
  x <- Filter(Negate(nullObjTest),x)
  lapply(x, function(x) if (is.list(x)) rmNullElements(x) else x)
}


listToXML <- function(node, sublist)
{
  sublist <- rmNullElements(sublist)
  for(i in 1:length(sublist)){
    child <- newXMLNode(names(sublist)[i], parent=node)  
    if (typeof(sublist[[i]]) == "list"){
      listToXML(child, sublist[[i]])
    }
    else{
      xmlValue(child) <- sublist[[i]]
    }
  } 
}


jobsToDF <- function(x)
{
  nodes <- getNodeSet(x, "//job")
  
  q.df <- data.frame(job_id=unlistWithNAs(nodes, "./id"),
                     company_id=unlistWithNAs(nodes, "./company/id"),
                     company_name=unlistWithNAs(nodes, "./company/name"),
                     poster_id=unlistWithNAs(nodes, "./job-poster/id"),
                     poster_fname=unlistWithNAs(nodes, "./job-poster/first-name"),
                     poster_lname=unlistWithNAs(nodes, "./job-poster/last-name"),
                     job_headline=unlistWithNAs(nodes, "./job-poster/headline"),
                     salary=unlistWithNAs(nodes, "./salary"),
                     job_desc=unlistWithNAs(nodes, "./description-snippet"),
                     location=unlistWithNAs(nodes, "./location-description")
                     )
  return(q.df)
}



jobBookmarksToDF <- function(x)
{
  nodes <- getNodeSet(x, "//job-bookmark")
  
  q.df <- data.frame(app_status=unlistWithNAs(nodes, "./is-applied"),
                   saved_time=unlistWithNAs(nodes, "./saved-timestamp"),
                   job_id=unlistWithNAs(nodes, "./job/id"), 
                   job_status=unlistWithNAs(nodes, "./job/active"),
                   company_id=unlistWithNAs(nodes, "./job/company/id"),
                   company_name=unlistWithNAs(nodes, "./job/company/name"),
                   job_title=unlistWithNAs(nodes, "./job/position/title"),
                   job_desc=unlistWithNAs(nodes, "./job/description-snippet"),
                   post_timestamp=unlistWithNAs(nodes, "./job/posting-timestamp")
                   )
  return(q.df)
}


groupsToDF <- function(x)
{
  
  nodes <- getNodeSet(x, "//group-membership") 
  q.df <- data.frame(group_id=unlistWithNAs(nodes, "./group/id"),
                     group_name=unlistWithNAs(nodes, "./group/name"),
                     member_status=unlistWithNAs(nodes, "./membership-state/code"),
                     allow_messages_from_members=unlistWithNAs(nodes, "./allow-messages-from-members"),
                     email_frequency=unlistWithNAs(nodes, "./email-digest-frequency/code"),
                     manager_announcements=unlistWithNAs(nodes, "./email-annoucements-from-managers"),
                     email_new_posts=unlistWithNAs(nodes, "./email-for-every-new-post")
                     )
  return(q.df)
}

groupPostToDF <- function(x)
{ 
  if(as.numeric(xmlAttrs(x[["//posts[@total]"]])[[1]])==0){
    return(NULL)
  }
  nodes <- getNodeSet(x, "//post")
  n.likes <- as.vector(unlist(xpathApply(x, "//likes", function(x){xmlAttrs(x)[1]})))
  n.comments <- as.vector(unlist(xpathApply(x, "//comments", function(x){xmlAttrs(x)[1]})))
  q.df <- data.frame(post_id=unlistWithNAs(nodes, "./id"),
                     creator_fname=unlistWithNAs(nodes, "./creator/first-name"),
                     creator_lname=unlistWithNAs(nodes, "./creator/last-name"),
                     creator_headline=unlistWithNAs(nodes, "./creator/headline"),
                     post_title=unlistWithNAs(nodes, "./title"),
                     post_summary=unlistWithNAs(nodes, "./summary"),
                     num_likes=n.likes,
                     num_comments=n.comments
  )
  return(q.df)
}


connectionsToDF <- function(x)
{ 
  nodes <- getNodeSet(x, "//person")
  q.df <- data.frame(id=unlistWithNAs(nodes, "./id"),
                     fname=unlistWithNAs(nodes, "./first-name"),
                     lname=unlistWithNAs(nodes, "./last-name"),
                     headline=unlistWithNAs(nodes, "./headline"),
                     industry=unlistWithNAs(nodes, "./industry"),
                     area=unlistWithNAs(nodes, "./location/name"),
                     country=unlistWithNAs(nodes, "./location/country/code"),
                     api_url=unlistWithNAs(nodes, "./api-standard-profile-request/url"),
                     site_url=unlistWithNAs(nodes, "./site-standard-profile-request/url")
  )
  return(q.df)
}


profileToList <- function(x)
{
  nodes <- getNodeSet(x, "//person")
  
  q.list <- list(id=unlistWithNAs(nodes, "./id"),
                 fname=unlistWithNAs(nodes, "./first-name"),
                 lname=unlistWithNAs(nodes, "./last-name"),
                 formatted_name=unlistWithNAs(nodes, "./formatted-name"),
                 headline=unlistWithNAs(nodes, "./headline"),
                 industry=unlistWithNAs(nodes, "./industry"),
                 connections=unlistWithNAs(nodes, "./num-connections"),
                 profile_summary=unlistWithNAs(nodes, "./summary"),
                 profile_url=unlistWithNAs(nodes, "./public-profile-url"),
                 positions=positionsToList(x))
  return(q.list)
}

positionsToList <- function(x)
{
  nodes <- getNodeSet(x, "//position")
  q.list <- list(position_id=unlistWithNAs(nodes, "./id"),
                     position_title=unlistWithNAs(nodes, "./title"),
                     position_summary=unlistWithNAs(nodes, "./summary"),
                     start_year=unlistWithNAs(nodes, "./start-date/year"),
                     end_year=unlistWithNAs(nodes, "./end-date/year"),
                     is_current=unlistWithNAs(nodes, "./is-current"),
                     company_id=unlistWithNAs(nodes, "./company/id"),
                     company_name=unlistWithNAs(nodes, "./company/name")
  )
  return(q.list)
}

