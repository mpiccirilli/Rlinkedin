Rlinkedin
=========

This is a development version of an R package to access the LinkedIn API via R

Collaboration is welcomed! 


Installation and Authentication
-------

Installing and establishing a connection to the LinkedIn API. 

```{r}
require(devtools)
install_github("mpiccirilli/Rlinkedin")
require(Rlinkedin)

app.name <- "mikesapp"
api.key <- ""  # aka 'consumer key', provided in Application Details
secret.key <- "" # aka 'consumer key', provided in Application Details

in.auth <- inOAuth(app.name, api.key, secret.key)

```


getMyConnections
-----
Get your connections and basic/default information about them.
```{r}
my.connections <- getMyConenctions(in.auth)

colnames(my.connections)
## [1] "id"       "fname"    "lname"    "headline" "industry" "area"     "country"  "api_url"  "site_url"

require(plyr)
conn.freq <- count(my.connections, c("industry", "area"))
head(conn.freq[order(-conn.freq$freq),])

##           industry                       area   freq
## Financial Services   Greater New York City Area   43
##           Research   Greater New York City Area   18
##   Higher Education   Greater New York City Area   13
##         Accounting   Greater New York City Area   10
##               <NA>   Greater New York City Area   10
##  Computer Software   Greater New York City Area    9

```


getProfile
------
Get profile information of yourself, your connections, or an individual.
```{r}
my.profile <- getProfile(in.auth)
connections.profiles <- getProfile(in.auth, connections = TRUE)
individual.profile <- getProfile(in.auth, id = my.connections$id[1])

class(my.profile)
## [1] "list"

names(my.profile)
## [1] "id"              "fname"           "lname"           "formatted_name"  "headline"       
## [6] "industry"        "connections"     "profile_summary" "profile_url"     "positions"    

head(my.profile, 5)

##  $id
##  [1] "RIWnbCCRy2"
##  $fname
##  [1] "Michael"
##  $lname
##  [1] "Piccirilli"
##  $formatted_name
##  [1] "Michael Piccirilli"
##  $headline
##  [1] "Graduate Student in Statistics at Columbia University"
```


getJobs
--------
Returns LinkedIn job recommendations or bookmarks.
```{r}
job.recs <- getJobs(token = in.auth, suggestions = TRUE)
job.bookmarks <- getJobs(token = in.auth, bookmarks = TRUE)

colnames(job.recs)
## [1] "job_id"       "company_id"   "company_name" "poster_id"    "poster_fname" "poster_lname" "job_headline"
## [8] "salary"       "job_desc"     "location"    
```

searchJobs
--------
Job Search API is a part of their Vetted API Access Program. You must apply and get LinkedIn's approval before using this API.

I have currently only included a search based on keywords. I will include more soon...

```{r}
search.jobs <- searchJobs(token = in.auth, keywords = "data scientist")
colnames(search.jobs)
## [1] "job_id"       "company_id"   "company_name" "poster_id"    "poster_fname" "poster_lname" "job_headline"
## [8] "salary"       "job_desc"     "location"    

head(search.jobs[,c(3,7, 10)], 3)
##   company_name                                                 job_headline             location
##   Bloomberg LP          Employee Services & Support Advisor at Bloomberg LP    New York, NY, USA
##           FILD                           Manager, People Operations at FILD      Upper West Side
##        KPMG US      Associate Director, Marketing Experienced Hires at KPMG         New York, NY

```


getGroups
---------
Returns information about what groups you belong to, either with or without detailed information
```{r}
my.groups <- getGroups(in.auth)
colnames(my.groups)
## [1] "group_id"                    "group_name"                  "member_status"              
## [4] "allow_messages_from_members" "email_frequency"             "manager_announcements"      
## [7] "email_new_posts"   

my.group.details <- getGroups(in.auth, details=TRUE)
colnames(my.group.details)
## [1] "group_id"         "group_name"       "group_desc_short" "group_desc_long" 
```


getGroupPosts
--------
Returns posts from groups you belong to
```{r}
# This is broken right now
my.group.posts <- getGroupPosts(in.auth)
```


submitShare
--------
Share an update to your networks feed. 

Note: If one of the content elements is specified you must also include include a url for the post
```{r}
comment <- "Test connecting to the LinkedIn API via R"
title <- "Im creating an R package to connect to the LinkedIn API, this is a test post from R!"
url <- "https://github.com/mpiccirilli"
desc <- "Dev version of access to LinkedIn API via R. Collaboration is welcomed!"

submitShare(in.auth, comment=comment, content_tile=title, content_url=url, content_desc=desc, visibility = "anyone")

```


submitGroupPost
--------
Create a group discussion 

There are two response types here: <br>
201 Created: Your discussion has been created, most likely you posted to an unmoderated group<br>
202 Accepted: Your discussion is pending approval, most likely you posted to a moderated group<br>

```{r}
id <- my.groups$group_id[1]
disc.title <- "Test connecting to the LinkedIn API via R"
disc.summary <- "Im creating an R package to connect to the LinkedIn API, this is a test post from R!"
url <- "https://github.com/mpiccirilli"
content.desc <- "Dev version of access to LinkedIn API via R. Collaboration is welcomed!"

submitGroupPost(in.auth, group_id=id, disc_title=disc.title, disc_summary=disc.summary, content_url=url, content_desc=content.desc)

```

