unlistWithNAs <- function(node_set, node_path, type="Values")
{  
  if(type=="Attrs"){
    x.list <- lapply(node_set, xpathSApply, node_path, function(x){xmlAttrs(x)[[1]]})
    x.list[sapply(x.list, is.list)] <- 0
    x.list <- as.numeric(unlist(x.list))
    return(x.list)
  }
  if(type=="Values"){
    x.list <- lapply(node_set, xpathSApply, node_path, xmlValue)
    x.list[sapply(x.list, is.list)] <- NA
    x.list <- unlist(x.list)
    return(x.list)
  }
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
  xyr <- unlistWithNAs(nodes, "./expiration-date/year")
  xm <- unlistWithNAs(nodes, "./expiration-date/month")
  xd <- unlistWithNAs(nodes, "./expiration-date/day")
  xdate <- as.POSIXct(paste(xyr,xm,xd,sep="-"))
  t <- as.POSIXct(as.numeric(unlistWithNAs(nodes, "./posting-timestamp"))/1000,
                  origin="1970-01-01 00:00:00")
  q.df <- data.frame(job_id=unlistWithNAs(nodes, "./id"),
                     post_timestamp=t,
                     exp_date=xdate,
                     company_id=unlistWithNAs(nodes, "./company/id"),
                     company_name=unlistWithNAs(nodes, "./company/name"),
                     position_title=unlistWithNAs(nodes, "./position/title"),
                     job_type=unlistWithNAs(nodes, "./job-type/name"),
                     location=unlistWithNAs(nodes, "./location/name"),
                     poster_id=unlistWithNAs(nodes, "./job-poster/id"),
                     poster_fname=unlistWithNAs(nodes, "./job-poster/first-name"),
                     poster_lname=unlistWithNAs(nodes, "./job-poster/last-name"),
                     poster_headline=unlistWithNAs(nodes, "./job-poster/headline"),
                     job_desc=unlistWithNAs(nodes, "./description"),
                     salary=unlistWithNAs(nodes, "./salary")
  )
  return(q.df)
}

jobRecsToDF <- function(x)
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
  # Need to build in positions
  xml <- xmlTreeParse(x, useInternalNodes=TRUE)
  persons <- xpathApply(xml, "//person", xmlChildren)
  n.positions <- unlistWithNAs(getNodeSet(xml, "//person"), "./positions", "Attrs")
  n.persons <- length(persons)
  q.list <- list()
  position.list <- list()
  for(i in 1:n.persons)
  {
    if(xmlValue(persons[[i]]$id)=="private" || xmlAttrs(persons[[i]]$positions)[[1]]==0 ){
      position.list <- list(positions=NA)
    }
    else {
      p.nodes <- xmlChildren(persons[[i]]$positions)
      for(j in 1:n.positions[i])
      {
        if(j==1){ p.list <- list(); position.list <- list()}
        id.n <- paste0("position",j,"_id"); comp.n <- paste0("position",j,"_company"); 
        ttl.n <- paste0("position",j,"_title"); year.n <- paste0("position",j,"_start_year"); 
        month.n <- paste0("position",j,"_start_month"); curr.n <- paste0("position",j,"_is_current"); 
        sum.n <- paste0("position",j,"_summary");  
        p.list <- list(id=unlistWithNAs(p.nodes[j], "./id")[[1]],
                              company=unlistWithNAs(p.nodes[j], "./company/name")[[1]],
                              title=unlistWithNAs(p.nodes[j], "./title")[[1]],
                              start_year=unlistWithNAs(p.nodes[j], "./start-date/year")[[1]],
                              start_month=unlistWithNAs(p.nodes[j], "./start-date/month")[[1]],
                              is_current=unlistWithNAs(p.nodes[j], "./is-current")[[1]],
                              summary=unlistWithNAs(p.nodes[j], "./summary")[[1]]
        )
        names(p.list) <- c(id.n, comp.n, ttl.n, year.n, month.n, curr.n, sum.n)
        position.list <- c(position.list, p.list)
      }
    } 
    profile.list <- list(connection_id=xmlValue(persons[[i]]$id),
                         fname=xmlValue(persons[[i]]$`first-name`),
                         lname=xmlValue(persons[[i]]$`last-name`),
                         formatted_name=xmlValue(persons[[i]]$`formatted-name`),
                         location=xmlValue(persons[[i]]$location),
                         headline=xmlValue(persons[[i]]$headline),
                         industry=xmlValue(persons[[i]]$industry),
                         num_connections=xmlValue(persons[[i]]$`num-connections`),
                         profile_url=xmlValue(persons[[i]]$`public-profile-url`),
                         num_positions=n.positions[i]
                         )
    q.list[[i]] <- c(profile.list, position.list)
  }
  return(q.list)
}

companyProfileToList <- function(x)
{
  xml <- xmlTreeParse(x, useInternalNodes=TRUE)
  company <- xpathApply(xml, "//company", xmlChildren)
  
  nemails <- unlistWithNAs(getNodeSet(xml, "//company"), "./email-domains", "Attrs")
  e.list <- list()
  for(i in 1:nemails)
  {
    email.number <- paste0("email_domain",i)
    email.list <- list(email=xmlValue(company[[1]]$`email-domains`[[i]]))
    names(email.list) <- email.number
    e.list <- c(e.list, email.list)
  }
  
  nspecs <- unlistWithNAs(getNodeSet(xml, "//company"), "./specialties", "Attrs")
  if(nspecs==0){
    spec.list <- list(specialty="NA")
  }
  else {
    spec.list <- list()
    for(i in 1:nspecs)
    {
      spec.num <- paste0("specialty",i)
      s.list <- list(spec=xmlValue(company[[1]]$specialties[[i]]))
      names(s.list) <- spec.num
      spec.list <- c(spec.list, s.list)
    }
  }
    
  nodes <- getNodeSet(xml, "//company")
  q.list <- list(company_id=unlistWithNAs(nodes, "./id"),
                 company_name=unlistWithNAs(nodes, "./name"),
                 company_type=unlistWithNAs(nodes, "./company-type/name"),
                 ticker=unlistWithNAs(nodes, "./ticker"),
                 website=unlistWithNAs(nodes, "./website-url"),
                 industry=unlistWithNAs(nodes, "./industries/industry/name"),
                 company_status=unlistWithNAs(nodes, "./status/name"),
                 twitter_handle=unlistWithNAs(nodes, "./twitter-id"),
                 employee_count=unlistWithNAs(nodes, "./employee-count-range/name"),
                 founded=unlistWithNAs(nodes, "./founded-year"),
                 num_followers=unlistWithNAs(nodes, "./num-followers"),
                 description=unlistWithNAs(nodes, "./description")
  )
  q.list <- c(q.list, spec.list, e.list)
  return(q.list)
}

companySearchToList <- function(x)
{
  xml <- xmlTreeParse(x, useInternalNodes=TRUE)
  company <- xpathApply(xml, "//company", xmlChildren)
  n.companies <- length(company)
  q.list <- list()
  for(i in 1:n.companies)
  {
    q.list[[i]] <- list(company_id=xmlValue(company[[i]]$id),
                   company_name=xmlValue(company[[i]]$name),
                   universal_name=xmlValue(company[[i]]$`universal-name`),
                   website=xmlValue(company[[i]]$`website-url`),
                   twitter_handle=xmlValue(company[[i]]$`twitter-id`),
                   employee_count=xmlValue(company[[i]]$`employee-count-range`[[2]]),
                   company_status=xmlValue(company[[i]]$status[[2]]),
                   founded=xmlValue(company[[i]]$`founded-year`),
                   num_followers=xmlValue(company[[i]]$`num-followers`),
                   description=xmlValue(company[[i]]$description)
                   )
    
    
    
    # Specialties:
    nspecs <- tryCatch({
      out <- xmlAttrs(company[[i]]$specialties)[[1]]
    },
    error=function(cond){
      out <- 0
      return(out)
    })
    spec.list <- list()
    if(nspecs==0){
      spec.list <- list(specialty="NA")
    }
    else {
      for (j in 1:nspecs)
      {
        spec.num <- paste0("specialty",j)
        s.list <- list(spec=xmlValue(company[[i]]$specialties[[j]]))
        names(s.list) <- spec.num
        spec.list <- c(spec.list, s.list)
      }
    }
    
    # Industries
    ninds <- tryCatch({
      out <- xmlAttrs(company[[i]]$industries)[[1]]
    },
    error=function(cond){
      out <- 0
      return(out)
    })
    ind.list <- list()
    if(ninds==0){
      ind.list <- list(industry="NA")
    }
    else {
      for (j in 1:ninds)
      {
        ind.num <- paste0("industry",j)
        i.list <- list(ind=xmlValue(company[[i]]$industries[[j]]))
        names(i.list) <- ind.num
        ind.list <- c(ind.list, i.list)
      }
    }
  }
  q.list[[i]] <- c(q.list[[i]], spec.list, ind.list)
  return(q.list)                 
}


connectionUpdatesToDF <- function(x)
{ 
  nodes <- getNodeSet(x, "//update[./update-type='CONN']")
  q.df <- data.frame(timestamp=as.POSIXct(as.numeric(unlistWithNAs(nodes, "./timestamp"))/1000,
                                          origin="1970-01-01 00:00:00"),
                     update_type=unlistWithNAs(nodes, "./update-type"),
                     connection_id=unlistWithNAs(nodes, "./update-content/person/id"),
                     connection_fname=unlistWithNAs(nodes, "./update-content/person/first-name"),
                     connection_lname=unlistWithNAs(nodes, "./update-content/person/last-name"),
                     connection_headline=unlistWithNAs(nodes, "./update-content/person/headline"),
                     connection_profile=unlistWithNAs(nodes, "./update-content/person/site-standard-profile-request/url"),
                     new_connection_id=unlistWithNAs(nodes, "./update-content/person/connections/person/id"),
                     new_connection_fname=unlistWithNAs(nodes, "./update-content/person/connections/person/first-name"),
                     new_connection_lname=unlistWithNAs(nodes, "./update-content/person/connections/person/last-name"),
                     new_connection_headline=unlistWithNAs(nodes, "./update-content/person/connections/person/headline"),
                     new_connection_profile=unlistWithNAs(nodes, "./update-content/person/connections/person/site-standard-profile-request/url")) 
  return(q.df)
}

shareUpdatesToDF <- function(x)
{
  nodes <- getNodeSet(x, "//update[./update-type='SHAR']")
  q.df <- data.frame(timestamp=as.POSIXlt(as.numeric(unlistWithNAs(nodes, "./timestamp"))/1000,
                                          origin="1970-01-01 00:00:00"),
                     update_type=unlistWithNAs(nodes, "./update-type"),
                     connection_id=unlistWithNAs(nodes, "./update-content/person/id"),
                     connection_fname=unlistWithNAs(nodes, "./update-content/person/first-name"),
                     connection_lname=unlistWithNAs(nodes, "./update-content/person/last-name"),
                     connection_headline=unlistWithNAs(nodes, "./update-content/person/headline"),
                     connection_profile=unlistWithNAs(nodes, "./update-content/person/site-standard-profile-request/url"),
                     share_id=unlistWithNAs(nodes, "./update-content/person/current-share/id"),
                     share_visibility=unlistWithNAs(nodes, "./update-content/person/current-share/visibility/code"),
                     share_comment=unlistWithNAs(nodes, "./update-content/person/current-share/comment"),
                     share_link=unlistWithNAs(nodes, "./update-content/person/current-share/content/submitted-url"),
                     share_title=unlistWithNAs(nodes, "./update-content/person/current-share/content/title"),
                     share_description=unlistWithNAs(nodes, "./update-content/person/current-share/content/description"),
                     num_likes=unlistWithNAs(nodes, "./num-likes"),
                     num_comments=unlistWithNAs(nodes, "./num-likes", "Attrs")
                     )
  return(q.df)
}

viralUpdatesToDF <- function(x)
{
  nodes <- getNodeSet(x, "//update[./update-type='VIRL']")
  q.df <- data.frame(timestamp=as.POSIXlt(as.numeric(unlistWithNAs(nodes, "./timestamp"))/1000,
                                          origin="1970-01-01 00:00:00"),
                     update_type=unlistWithNAs(nodes, "./update-type"),
                     connection_id=unlistWithNAs(nodes, "./update-content/person/id"),
                     connection_fname=unlistWithNAs(nodes, "./update-content/person/first-name"),
                     connection_lname=unlistWithNAs(nodes, "./update-content/person/last-name"),
                     connection_headline=unlistWithNAs(nodes, "./update-content/person/headline"),
                     connection_profile=unlistWithNAs(nodes, "./update-content/person/site-standard-profile-request/url"),
                     connection_update=unlistWithNAs(nodes, "./update-content/update-action/action/code"),
                     original_update_time=as.POSIXlt(as.numeric(unlistWithNAs(nodes, "./update-content/update-action/original-update/timestamp"))/1000,origin="1970-01-01 00:00:00"),
                     original_update_type=unlistWithNAs(nodes, "./update-content/update-action/original-update/update-type"))
  return(q.df)
}

pplFollowUpdatesToDF <- function(x)
{
  nodes <- getNodeSet(x, "//update[./update-type='PFOL']")
  q.df <- data.frame(timestamp=as.POSIXlt(as.numeric(unlistWithNAs(nodes, "./timestamp"))/1000,
                                          origin="1970-01-01 00:00:00"),
                     update_type=unlistWithNAs(nodes, "./update-type"),
                     connection_id=unlistWithNAs(nodes, "./update-content/person/id"),
                     connection_fname=unlistWithNAs(nodes, "./update-content/person/first-name"),
                     connection_lname=unlistWithNAs(nodes, "./update-content/person/last-name"),
                     connection_headline=unlistWithNAs(nodes, "./update-content/person/headline"),
                     connection_profile=unlistWithNAs(nodes, "./update-content/person/site-standard-profile-request/url"),
                     num_following=unlistWithNAs(nodes, "./update-content/person/following/people", "Attrs"))
  return(q.df)
}

groupUpdatesToDF <- function(x)
{
  nodes <- getNodeSet(x, "//update[./update-type='JGRP']")
  q.df <- data.frame(timestamp=as.POSIXlt(as.numeric(unlistWithNAs(nodes, "./timestamp"))/1000,
                                          origin="1970-01-01 00:00:00"),
                     update_type=unlistWithNAs(nodes, "./update-type"),
                     connection_id=unlistWithNAs(nodes, "./update-content/person/id"),
                     connection_fname=unlistWithNAs(nodes, "./update-content/person/first-name"),
                     connection_lname=unlistWithNAs(nodes, "./update-content/person/last-name"),
                     connection_headline=unlistWithNAs(nodes, "./update-content/person/headline"),
                     connection_profile=unlistWithNAs(nodes, "./update-content/person/site-standard-profile-request/url"),
                     group_id=unlistWithNAs(nodes, "./update-content/person/member-groups/member-group/id"),
                     group_name=unlistWithNAs(nodes, "./update-content/person/member-groups/member-group/name"),
                     group_url=unlistWithNAs(nodes, "./update-content/person/member-groups/member-group/site-group-request/url")
  )
  return(q.df)
}

profileUpdatesToDF <- function(x)
{
  nodes <- getNodeSet(x, "//update[./update-type='PROF']")
  q.df <- data.frame(timestamp=as.POSIXlt(as.numeric(unlistWithNAs(nodes, "./timestamp"))/1000,
                                          origin="1970-01-01 00:00:00"),
                     update_type=unlistWithNAs(nodes, "./update-type"),
                     connection_id=unlistWithNAs(nodes, "./update-content/person/id"),
                     connection_fname=unlistWithNAs(nodes, "./update-content/person/first-name"),
                     connection_lname=unlistWithNAs(nodes, "./update-content/person/last-name"),
                     connection_headline=unlistWithNAs(nodes, "./update-content/person/headline"),
                     connection_profile=unlistWithNAs(nodes, "./update-content/person/site-standard-profile-request/url"))
  return(q.df)
}

# This is very limited. I need to update for different
# types of company update
companyUpdatesToDF <- function(x)
{
  nodes <- getNodeSet(x, "//update[./update-type='CMPY']")  
  q.df <- data.frame(timestamp=as.POSIXlt(as.numeric(unlistWithNAs(nodes, "./timestamp"))/1000,
                                          origin="1970-01-01 00:00:00"),
                     update_type=unlistWithNAs(nodes, "./update-type"),
                     company_id=unlistWithNAs(nodes, "./update-content/company/id"),
                     company_name=unlistWithNAs(nodes, "./update-content/company/name"),
                     num_likes=unlistWithNAs(nodes, "./num-likes"),
                     num_comments=unlistWithNAs(nodes, "./update-comments", "Attrs"))
  return(q.df)
}
