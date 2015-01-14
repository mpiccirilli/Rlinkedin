Rlinkedin
=========

This is a development version of an R package to access the LinkedIn API via R

Collaboration is welcomed! 


Installation and Authentication
-------

Since this package is still in development, it can only be installed or downloaded via GitHub.

You can establish an authenticated connection to the LinkedIn API in one of two ways:<br>
1) Use the default API and Secret Key information.<br>
2) Create your own [LinkedIn Developer application](https://developer.linkedin.com/).<p>

The default information is not approved to use the People Search API (searchPeople) or the Job Search API (searchJobs).  If you would like to utilize these functions you must create your own application and [apply here](https://help.linkedin.com/app/ask/path/api-dvr) for the "Vetted API Access". 

If you use your own application name, API Key, and Secret Key, you must paste `http://localhost:1410/` into the *'OAuth 2.0 Redirect URLs'* input box and select all of the *'Scope'* parameters, both of which are in the **'OAuth User Agreement'** section. Otherwise, you will not be able to create an authorized connection and these functions will not work properly. 

```{r}
require(devtools)
install_github("mpiccirilli/Rlinkedin")
require(Rlinkedin)

# To use the default API and Secret Key for the Rlinkedin package:
in.auth <- inOAuth()

# To use your own application's API and Secret Key:
in.auth <- inOAuth("your_app_name", "your_consumer_key", "your_consumer_secret")
```


Connections API
-----
The [Connections API](https://developer.linkedin.com/documents/connections-api) returns a list of 1st degree connections for a user who has granted access to his/her account.

You cannot "browse connections." That is, you can only get the connections of the user who granted your application access. You cannot get connections of that user's connections (2nd degree connections).

Per LinkedIn: You may never store data returned from the Connections API.
```{r}
my.connections <- getMyConenctions(in.auth)

colnames(my.connections)
##  [1] "id"  "fname"  "lname"   "headline"   "industry"   "area"  "country"  "api_url" 
##  [9] "site_url"

require(plyr)
conn.freq <- count(my.connections, c("industry", "area"))
head(conn.freq[order(-conn.freq$freq),])

##             industry                         area   freq
##   Financial Services   Greater New York City Area     43
##             Research   Greater New York City Area     18
##     Higher Education   Greater New York City Area     13
##           Accounting   Greater New York City Area     10
##                 <NA>   Greater New York City Area     10
##    Computer Software   Greater New York City Area      9

```


Profile API
------
The [Profile API](https://developer.linkedin.com/documents/profile-api) returns a member's LinkedIn profile. This function can retrieve proflie information about to yourself, your connections, or an individual.

To Do: Include positions in results

```{r}
my.profile <- getProfile(in.auth)
connections.profiles <- getProfile(in.auth, connections = TRUE)
individual.profile <- getProfile(in.auth, id = my.connections$id[1])

class(my.profile)
##  [1] "list"


my.profile
##  [[1]]
##  [[1]]$connection_id
##  [1] "RIWnbCCRy2"

##  [[1]]$fname
##  [1] "Michael"

##  [[1]]$lname
##  [1] "Piccirilli"

##  [[1]]$formatted_name
##  [1] "Michael Piccirilli"

##  [[1]]$location
##  [1] "Greater New York City Area"

##  [[1]]$headline
##  [1] "Graduate Student in Statistics at Columbia University"

##  [[1]]$industry
##  [1] "Higher Education"

##  [[1]]$num_connections
##  [1] "282"

##  [[1]]$profile_url
##  [1] "https://www.linkedin.com/in/mikepiccirilli"

##  [[1]]$num_positions
##  [1] 3
```


People Search API
-------
The [People Search API](https://developer.linkedin.com/documents/people-search-api) returns information about people. It lets you implement most of what shows up when you do a search for "People" in the top right box on LinkedIn.com.

People Search API is a part of their Vetted API Access Program. You must [apply here](https://help.linkedin.com/app/ask/path/api-dvr) and get LinkedIn's approval before using this API.  The default token in the package is not approved for this use. 

Throttle limits: Up to 100 returns per search, 10 returns per page. Each page is one API call.

The arguments available to be used in a search: <br>
- keywords <br>
- first name <br>
- last name <br>
- company name <br>
- current company (T/F) <br>
- title <br>
- current title <br>
- school name <br>
- current school (T/F) <br>
- country code <br>
- postal code <br>
- distance 

To Do: Include positions in results
```{r}
search.ppl <- searchPeople(token=in.auth, first_name="Michael", last_name="Piccirilli")

colnames(search.ppl)
##  [1] "id"              "fname"           "lname"           "formatted_name"  "location"       
##  [6] "headline"        "industry"        "connections"     "profile_summary" "num_positions" 

search.ppl[,c(4,5,7,8)]
##                   formatted_name                      location                            industry connections
##               Michael Piccirilli    Greater New York City Area                    Higher Education         282
##                  Mike Piccirilli      Baltimore, Maryland Area                      Graphic Design           1
##               Michael Piccirilli Providence, Rhode Island Area Information Technology and Services          30
##               michael piccirilli           Greater Boston Area                             Banking           0
##               Michael Piccirilli           Greater Boston Area          Logistics and Supply Chain         398
##               Michael Piccirilli      Greater Los Angeles Area                       Entertainment         141
##               Michael Piccirilli           Greater Boston Area International Trade and Development         156
##                  MIke Piccirilli      Baltimore, Maryland Area                      Graphic Design          22
##                  Mike Piccirilli          Greater Atlanta Area           Government Administration           4
##  Sean Michael (Barry) Piccirilli         Portland, Oregon Area              Environmental Services           6
##                  mike piccirilli     Sharon, Pennsylvania Area        Health, Wellness and Fitness           0
> 

```



Job Bookmarks & Suggestions
--------
The API can be used to retrieve the current members [bookmarked and suggested jobs](https://developer.linkedin.com/documents/job-bookmarks-and-suggestions).

```{r}
job.recs <- getJobs(token = in.auth, suggestions = TRUE)
job.bookmarks <- getJobs(token = in.auth, bookmarks = TRUE)

colnames(job.recs)
##  [1] "job_id"       "company_id"   "company_name" "poster_id"    "poster_fname" "poster_lname"
##  [7] "job_headline" "salary"       "job_desc"     "location" 

```


Job Search API
--------
The [Job Search API](https://developer.linkedin.com/documents/job-search-api#) enables search across LinkedIn's job postings.

Job Search API is a part of their Vetted API Access Program. You must [apply here](https://help.linkedin.com/app/ask/path/api-dvr) and get LinkedIn's approval before using this API. The default token in the package is not approved for this use. 

Throttle limits: Up to 100 returns per search, 10 returns per page. Each page is one API call.

The arguments available to be used in a search: <br>
- keywords <br>
- company name <br>
- job_title <br>
- country code  <br>
- postal_code <br>
- distance <br>


```{r}
search.jobs <- searchJobs(token = in.auth, keywords = "data scientist")
colnames(search.jobs)
##  [1] "job_id"          "post_timestamp"  "exp_date"        "company_id"      "company_name"   
##  [6] "position_title"  "job_type"        "location"        "poster_id"       "poster_fname"   
##  [11] "poster_lname"    "poster_headline" "job_desc"        "salary"    


head(search.jobs[,c(5,6,8)], 3)
##   company_name                                               position_title             location
##   Bloomberg LP          Employee Services & Support Advisor at Bloomberg LP    New York, NY, USA
##           FILD                           Manager, People Operations at FILD      Upper West Side
##        KPMG US      Associate Director, Marketing Experienced Hires at KPMG         New York, NY

```


Groups API
---------
The [Groups API](https://developer.linkedin.com/documents/groups-api) enables members to view and interact with groups off of LinkedIn.com with the same rules that apply on the LinkedIn site. Data available includes group profile information, discussion posts, comments on posts, and likes.

#### Group Information
```{r}
my.groups <- getGroups(in.auth)
colnames(my.groups)
##  [1] "group_id"                    "group_name"                  "member_status"              
##  [4] "allow_messages_from_members" "email_frequency"             "manager_announcements"      
##  [7] "email_new_posts"     


my.group.details <- getGroups(in.auth, details=TRUE)
colnames(my.group.details)
##  [1] "group_id"  "group_name"  "group_desc_short"  "group_desc_long" 
```

#### Group Posts
To Do:<br>
1) Include functionality to retrieve information of people who have liked and commented on posts.<br>
2) Currently this only returns the past 10 posts from each group. Build in functionality to retrieve more posts in each group.
```{r}
my.group.posts <- getGroupPosts(token = in.auth)
colnames(my.group.posts)
##  [1] "post_id"          "creator_fname"    "creator_lname"    "creator_headline" "post_title"      
##  [6] "post_summary"     "num_likes"        "num_comments"   
```

#### Create a group discussion 
There are two possible actions here: <br>
1) Your post has been created and is visibile immediately. Most likely you posted to an unmoderated group.<br>
2) Your post has been accepted by the API but is pending approval by the group moderator.<br>

```{r}
id <- my.groups$group_id[1]
disc.title <- "Test connecting to the LinkedIn API via R"
disc.summary <- "Im creating an R package to connect to the LinkedIn API, this is a test post from R!"
url <- "https://github.com/mpiccirilli"
content.desc <- "Dev version of access to LinkedIn API via R. Collaboration is welcomed!"

submitGroupPost(in.auth, group_id=id, disc_title=disc.title, disc_summary=disc.summary, content_url=url, content_desc=content.desc)
```
![submitGroupPost](https://github.com/mpiccirilli/Rlinkedin/blob/master/images/submitGroupPost.png)



Share API
--------
You can share network updates through the [Share API](https://developer.linkedin.com/documents/share-api).

Note: If one of the content elements is specified you must also include include a url for the post
```{r}
comment <- "Test connecting to the LinkedIn API via R"
title <- "Im creating an R package to connect to the LinkedIn API, this is a test post from R!"
url <- "https://github.com/mpiccirilli"
desc <- "Dev version of access to LinkedIn API via R. Collaboration is welcomed!"
submitShare(token = in.auth, comment=comment, content_title=title, content_url=url, content_desc=desc)
```
![submitShare](https://github.com/mpiccirilli/Rlinkedin/blob/master/images/submitShare.png)





To Do:
--------
- Get Network Updates and Statistics API: The Get Network Updates API returns the users network updates, which is the LinkedIn term for the user's feed. This call returns most of what shows up in the middle column of the LinkedIn.com home page, either for the member or the member's connections.
- Company Lookup API: Retrieves and displays one or more company profiles based on the company ID or universal name. Returns basic company profile data, such as name, website, and industry. Returns handles to additional company content, such as RSS stream and Twitter feed.
- Company Search API: The Company Search API enables search across company pages.


