unlistWithNAs <- function(node_set, node_path)
{
  x.list <- lapply(node_set, xpathSApply, node_path, xmlValue)
  x.list[sapply(x.list, is.list)] <- NA
  x.list <- unlist(x.list)
}


jobsToDF <- function(x)
{
  jb.nodes <- getNodeSet(x, "//job")
  
  q.df <- data.frame(job_id=unlistWithNAs(jb.nodes, "./id"),
                     company_id=unlistWithNAs(jb.nodes, "./company/id"),
                     company_name=unlistWithNAs(jb.nodes, "./company/name"),
                     poster_id=unlistWithNAs(jb.nodes, "./job-poster/id"),
                     poster_fname=unlistWithNAs(jb.nodes, "./job-poster/first-name"),
                     poster_lname=unlistWithNAs(jb.nodes, "./job-poster/last-name"),
                     job_headline=unlistWithNAs(jb.nodes, "./job-poster/headline"),
                     salary=unlistWithNAs(jb.nodes, "./salary"),
                     job_desc=unlistWithNAs(jb.nodes, "./description-snippet"),
                     location=unlistWithNAs(jb.nodes, "./location-description")
                     )
  return(df)
}



jobBookmarksToDF <- function(x)
{
  jb.nodes <- getNodeSet(x, "//job-bookmark")
  
  q.df <- data.frame(app_status=unlistWithNAs(jb.nodes, "./is-applied"),
                   saved_time=unlistWithNAs(jb.nodes, "./saved-timestamp"),
                   job_id=unlistWithNAs(jb.nodes, "./job/id"), 
                   job_status=unlistWithNAs(jb.nodes, "./job/active"),
                   company_id=unlistWithNAs(jb.nodes, "./job/company/id"),
                   company_name=unlistWithNAs(jb.nodes, "./job/company/name"),
                   job_title=unlistWithNAs(jb.nodes, "./job/position/title"),
                   job_desc=unlistWithNAs(jb.nodes, "./job/description-snippet"),
                   post_timestamp=unlistWithNAs(jb.nodes, "./job/posting-timestamp")
                   )
  return(df)
}



groupsToDF <- function(x)
{
  gp.nodes <- getNodeSet(x, "//group-membership")
  
  q.df <- data.frame(group_id=unlistWithNAs(gp.nodes, "./group/id"),
                     group_name=unlistWithNAs(gp.nodes, "./group/name"),
                     member_status=unlistWithNAs(gp.nodes, "./membership-state/code"),
                     allow_messages_from_members=unlistWithNAs(gp.nodes, "./allow-messages-from-members"),
                     email_frequency=unlistWithNAs(gp.nodes, "./email-digest-frequency/code"),
                     manager_announcements=unlistWithNAs(gp.nodes, "./email-annoucements-from-managers"),
                     email_new_posts=unlistWithNAs(gp.nodes, "./email-for-every-new-post")
                     )
  return(q.df)
}
