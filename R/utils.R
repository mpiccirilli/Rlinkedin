jobsToDF <- function(x)
{
  jb.nodes <- getNodeSet(x, "//job")
  
  jb.id <- lapply(jb.nodes, xpathSApply, "./id", xmlValue)
  jb.id[sapply(jb.id, is.list)] <- NA
  jb.id <- unlist(jb.id)
  
  cp.id <- lapply(jb.nodes, xpathSApply, "./company/id", xmlValue)
  cp.id[sapply(cp.id, is.list)] <- NA
  cp.id <- unlist(cp.id)
  
  cp.name <- lapply(jb.nodes, xpathSApply, "./company/name", xmlValue)
  cp.name[sapply(cp.name, is.list)] <- NA
  cp.name <- unlist(cp.name)
  
  jp.id <- lapply(jb.nodes, xpathSApply, "./job-poster/id", xmlValue)
  jp.id[sapply(jp.id, is.list)] <- NA
  jp.id <- unlist(jp.id)
  
  
  fname <- lapply(jb.nodes, xpathSApply, "./job-poster/first-name", xmlValue)
  fname[sapply(fname, is.list)] <- NA
  fname <- unlist(fname)
  
  lname <- lapply(jb.nodes, xpathSApply, "./job-poster/last-name", xmlValue)
  lname[sapply(lname, is.list)] <- NA
  lname <- unlist(lname)
  
  headline <- lapply(jb.nodes, xpathSApply, "./job-poster/headline", xmlValue)
  headline[sapply(headline, is.list)] <- NA
  headline <- unlist(headline)
  
  salary <- lapply(jb.nodes, xpathSApply, "./salary", xmlValue)
  salary[sapply(salary, is.list)] <- NA
  salary <- unlist(salary)
  
  jb.desc <- lapply(jb.nodes, xpathSApply, "./description-snippet", xmlValue)
  jb.desc[sapply(jb.desc, is.list)] <- NA
  jb.desc <- unlist(jb.desc)
  
  jb.location <- lapply(jb.nodes, xpathSApply, "./location-description", xmlValue)
  jb.location[sapply(jb.location, is.list)] <- NA
  jb.location <- unlist(jb.location)  
  
  df <- data.frame(job_id=jb.id,
                     company_id=cp.id,
                     company_name=cp.name, 
                     salary=salary,
                     poster_id=jp.id,
                     poster_fname=fname,
                     poster_lname=lname,
                     job_headline=headline,
                     job_desc=jb.desc,
                     location=jb.location
                     )
  return(df)
}

jobBookmarksToDF <- function(x)
{
  jb.nodes <- getNodeSet(x, "//job-bookmark")
  
  app.status <- lapply(jb.nodes, xpathSApply, "./is-applied", xmlValue)
  app.status[sapply(app.status, is.list)] <- NA
  app.status <- unlist(app.status)

  saved.time <- lapply(jb.nodes, xpathSApply, "./saved-timestamp", xmlValue)
  saved.time[sapply(saved.time, is.list)] <- NA
  saved.time <- unlist(saved.time)
  
  jb.id <- lapply(jb.nodes, xpathSApply, "./job/id", xmlValue)
  jb.id[sapply(jb.id, is.list)] <- NA
  jb.id <- unlist(jb.id)
  
  jb.status <- lapply(jb.nodes, xpathSApply, "./job/active", xmlValue)
  jb.status[sapply(jb.status, is.list)] <- NA
  jb.status <- unlist(jb.status)
  
  cp.id <- lapply(jb.nodes, xpathSApply, "./job/company/id", xmlValue)
  cp.id[sapply(cp.id, is.list)] <- NA
  cp.id <- unlist(cp.id)
  
  cp.name <- lapply(jb.nodes, xpathSApply, "./job/company/name", xmlValue)
  cp.name[sapply(cp.name, is.list)] <- NA
  cp.name <- unlist(cp.name)
  
  jb.title <- lapply(jb.nodes, xpathSApply, "./job/position/title", xmlValue)
  jb.title[sapply(jb.title, is.list)] <- NA
  jb.title <- unlist(jb.title)
  
  jb.desc <- lapply(jb.nodes, xpathSApply, "./job/description-snippet", xmlValue)
  jb.desc[sapply(jb.desc, is.list)] <- NA
  jb.desc <- unlist(jb.desc)
  
  post.time <- lapply(jb.nodes, xpathSApply, "./job/posting-timestamp", xmlValue)
  post.time[sapply(post.time, is.list)] <- NA
  post.time <- unlist(post.time)  
  
  df <- data.frame(app_status=app.status,
                   saved_time=saved.time,
                   job_id=jb.id, 
                   job_status=jb.status,
                   company_id=cp.id,
                   company_name=cp.name,
                   job_title=jb.title,
                   job_desc=jb.desc,
                   post_timestamp=post.time
  )
  return(df)
}

groupsToDF <- function(x)
{
  gp.nodes <- getNodeSet(x, "//group-membership")
  
  gp.id <- lapply(gp.nodes, xpathSApply, "./group/id", xmlValue)
  gp.id[sapply(gp.id, is.list)] <- NA
  gp.id <- unlist(gp.id)
  
  gp.name <- lapply(gp.nodes, xpathSApply, "./group/name", xmlValue)
  gp.name[sapply(gp.name, is.list)] <- NA
  gp.name <- unlist(gp.name)
  
  gp.status <- lapply(gp.nodes, xpathSApply, "./membership-state/code", xmlValue)
  gp.status[sapply(gp.status, is.list)] <- NA
  gp.status <- unlist(gp.status)
  
  gp.allow.messages <- lapply(gp.nodes, xpathSApply, "./allow-messages-from-members", xmlValue)
  gp.allow.messages[sapply(gp.allow.messages, is.list)] <- NA
  gp.allow.messages <- unlist(gp.allow.messages)
  
  gp.email.freq <- lapply(gp.nodes, xpathSApply, "./email-digest-frequency/code", xmlValue)
  gp.email.freq[sapply(gp.email.freq, is.list)] <- NA
  gp.email.freq <- unlist(gp.email.freq)

  gp.email.mgr <- lapply(gp.nodes, xpathSApply, "./email-annoucements-from-manages", xmlValue)
  gp.email.mgr[sapply(gp.email.mgr, is.list)] <- NA
  gp.email.mgr <- unlist(gp.email.mgr)
  
  gp.email.new.posts <- lapply(gp.nodes, xpathSApply, "./email-for-every-new-post", xmlValue)
  gp.email.new.posts[sapply(gp.email.new.posts, is.list)] <- NA
  gp.email.new.posts <- unlist(gp.email.new.posts)
  
  q.df <- data.frame(group_id=gp.id,
                     group_name=gp.name,
                     member_status=gp.status,
                     allow_messages_from_members=gp.allow.messages,
                     email_frequency=gp.email.freq,
                     manager_announcements=gp.email.mgr,
                     email_new_posts=gp.email.new.posts)
  return(q.df)
}