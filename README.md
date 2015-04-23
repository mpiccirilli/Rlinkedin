Rlinkedin
=========

[![Build Status](https://travis-ci.org/mpiccirilli/Rlinkedin.svg?branch=master)](https://travis-ci.org/mpiccirilli/Rlinkedin)

This is a development version of an R package to access the LinkedIn API.  I was motivated to create this after using and contributing to Pablo Barberá's awesome [Rfacebook](https://github.com/pablobarbera/Rfacebook) package. 

Contributions are welcomed, and if you come across any errors please don't hesitate to open a new issue.  At the bottom of this readme is a list of the functions I would still like to add to the package. 

If you'd like to contribute or simply learn more about accessing the API, get started by visiting the [LinkedIn Developer](https://developer.linkedin.com/) page.




Installation and Authentication
-------

Since this package is still in development, it can only be installed or downloaded via GitHub.

You can establish an authenticated connection to the LinkedIn API in one of two ways:<br>
1) Use the default API and Secret Key information.<br>
2) Create your own [LinkedIn Developer application](https://developer.linkedin.com/).<p>

The default information is not approved to use the People Search API (searchPeople) or the Job Search API (searchJobs).  If you would like to utilize these functions you must create your own application and [apply here](https://help.linkedin.com/app/ask/path/api-dvr) for the "Vetted API Access". 

If you use your own application name, API Key, and Secret Key, you must paste `http://localhost:1410/` into the *'OAuth 2.0 Redirect URLs'* input box and select all of the *'Scope'* parameters, both of which are in the **'OAuth User Agreement'** section. Otherwise, you will not be able to create an authorized connection and these functions will not work properly. 

For a step-by-step tutorial, check this [fantastic blog post](http://thinktostart.com/analyze-linkedin-with-r/) by [JulianHi](https://twitter.com/JulianHi).

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
The [Connections API](https://developer-programs.linkedin.com/documents/connections-api) returns a list of 1st degree connections for a user who has granted access to his/her account.

You cannot "browse connections." That is, you cannot get connections of your connections (2nd degree connections).

Per LinkedIn: You may never store data returned from the Connections API.
```{r}
my.connections <- getMyConnections(in.auth)

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
The [Profile API](https://developer-programs.linkedin.com/documents/profile-api) returns a member's LinkedIn profile. This function can retrieve proflie information about to yourself, your connections, or an individual.

To Do: <br>
1/14: Include positions in results <br>
1/22: Added positions into results, need to update example in readme (below).  <br>
3/19: Updated ReadMe, gave example to turn list into df

```{r}
my.profile <- getProfile(in.auth)
connections.profiles <- getProfile(in.auth, connections = TRUE)
individual.profile <- getProfile(in.auth, id = my.connections$id[1])

# The output of this function is naturually in a list.
# However you can convert it into a dataframe quite easily. 
# I will use 'my.profile' as an example, but the same can be applied to all three above.

# Data as a list:

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
##  [1] "San Francisco Bay Area"
....


# Now as a dataframe:

data.frame(t(sapply(my.profile, function(x){ 
  x[c("fname", "lname", "location")]})))

##      fname      lname               location
##  1 Michael Piccirilli San Francisco Bay Area


# To see all the elements in the list, simply run:
sapply(my.profile, function(x) names(x))

```


People Search API
-------
The [People Search API](https://developer-programs.linkedin.com/documents/people-search-api) returns information about people. It lets you implement most of what shows up when you do a search for "People" in the top right box on LinkedIn.com.

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

To Do: <br>
1/14: Include positions in results<br>
1/22: Added positions into results, need to update example in readme (below).  Results are now a list, not a df.<br>
3/19: Updated ReadMe, gave example to turn list into df
```{r}
search.ppl <- searchPeople(token=in.auth, first_name="Michael", last_name="Piccirilli")
class(search.ppl)
##  [1] "list"

length(search.ppl)
##  [1] 12

# Again, you can use this function to check out the all the elements within each list item (aka, each person)
sapply(search.ppl, function(x) names(x))
##  [[1]]
##  [1] "connection_id"         "fname"                 "lname"                
##  [4] "formatted_name"        "location"              "headline"             
##  [7] "industry"              "num_connections"       "profile_url"  
....

# Now let's turn that into a dataframe: 
data.frame(t(sapply(search.ppl, function(x){
  x[c("formatted_name", "location", "industry", "num_connections")]
  })))

##                      formatted_name                      location                            industry num_connections
##  1               Michael Piccirilli        San Francisco Bay Area                    Higher Education             306
##  2                  Mike Piccirilli      Baltimore, Maryland Area                      Graphic Design               1
##  3               Michael Piccirilli Providence, Rhode Island Area Information Technology and Services              31
##  4               michael piccirilli           Greater Boston Area                             Banking               0
##  5               Michael Piccirilli           Greater Boston Area          Logistics and Supply Chain             414
##  6               Michael Piccirilli      Greater Los Angeles Area                       Entertainment             143
##  7               Michael Piccirilli           Greater Boston Area International Trade and Development             157
##  8                  MIke Piccirilli      Baltimore, Maryland Area                      Graphic Design              22
##  9                  Mike Piccirilli          Greater Atlanta Area           Government Administration               4
##  10 Sean Michael (Barry) Piccirilli         Portland, Oregon Area              Environmental Services               6
##  11                 mike piccirilli     Sharon, Pennsylvania Area        Health, Wellness and Fitness               0
##  12              MICHAEL PICCIRILLI          Naples, Florida Area                             Banking               2

```



Job Bookmarks & Suggestions
--------
The API can be used to retrieve the current members [bookmarked and suggested jobs](https://developer-programs.linkedin.com/documents/job-bookmarks-and-suggestions).

```{r}
job.recs <- getJobs(token = in.auth, suggestions = TRUE)
job.bookmarks <- getJobs(token = in.auth, bookmarks = TRUE)

colnames(job.recs)
##  [1] "job_id"       "company_id"   "company_name" "poster_id"    "poster_fname" "poster_lname"
##  [7] "job_headline" "salary"       "job_desc"     "location" 

```


Job Search API
--------
The [Job Search API](https://developer-programs.linkedin.com/documents/job-search-api#) enables search across LinkedIn's job postings.

Job Search API is a part of their Vetted API Access Program. You must [apply here](https://help.linkedin.com/app/ask/path/api-dvr) and get LinkedIn's approval before using this API. The default token in the package is not approved for this use. 

Throttle limits: Up to 100 returns per search, 10 returns per page. Each page is one API call.

The arguments available to be used in a search: <br>
- keywords <br>
- company name <br>
- job title <br>
- country code  <br>
- postal code <br>
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


Company APIs
--------
#### Company Profile API
Use the [Company Profile API](https://developer-programs.linkedin.com/documents/company-lookup-api-and-fields) to find companies using a company ID, a universal name, or an email domain.

The universal name needs to be the exact name seen at the end of the URL on the company page on LinkedIn. In most cases this is simply the name of the company, but not always.  For example, let's consider Coca-Cola.  The company's LinkedIn page is:
- https://www.linkedin.com/company/the-coca-cola-company

Therefore, you would search "the coca cola company" or "the-coca-cola-company".  The same principles apply to other companies. See example below. 


```{r}

#### Search by Company Name ####
company.name <- getCompany(token=in.auth, universal_name="the coca cola company")
head(copmany.name)

##  $company_id
##  [1] "1694"

##  $company_name
##  [1] "The Coca-Cola Company"

##  $company_type
##  [1] "Public Company"

##  $ticker
##  [1] "KO"

##  $website
##  [1] "http://www.coca-colacompany.com"

##  $industry
##  [1] "Food & Beverages"
 
 
#### Search by Email Domain ####
company.email <- getCompany(token=in.auth, email_domain = "columbia.edu")
head(company.email)

##    company_id                                                 company_name
##        263698     Columbia-Harlem Small Business Development Center (SBDC)
##        269863          Columbia Center for New Media Teaching and Learning
##        239158   Center for Technology, Innovation and Community Engagement
##       2600576           Columbia University School of Continuing Education
##       3328717                   Columbia University Information Technology
##        444161                                  ICAP at Columbia University
 


#### Search by Company ID ####
# Select: Columbia University in the City of New York
company.id <- getCompany(token=in.auth, company_id = company.email$company_id[14])

class(company.id)
##  [1] "list"

length(company.id)
##  [1] 279
# This is so long because there are 261 email domain names associated 'columbia.edu'
```

#### Company Search API
Use the [Company Search API](https://developer-programs.linkedin.com/documents/company-search) to find companies using keywords, industry, location, or some other criteria. It returns a collection of matching companies. Each entry can contain much of the information available on the company page.

1/22:  Added searchCompanies() to repo.  Will add/update readme w/ example soon... <br>
3/19:  I will add this function to the ReadMe this weekend.
``` {r}
search.comp <- searchCompanies(in.auth, keywords = "LinkedIn")

# Find list elements of interest:
sapply(search.comp, function(x) names(x))[[1]]

##  [1] "company_id"     "company_name"   "universal_name" "website"        "twitter_handle"
##  [6] "employee_count" "company_status" "founded"        "num_followers"  "description"   

data.frame(t(sapply(search.comp, function(x){
  x[c("company_id", "company_name", "universal_name", "website", "num_followers")]
})))

```



Groups API
---------
The [Groups API](https://developer-programs.linkedin.com/documents/groups-api) enables members to view and interact with groups off of LinkedIn.com with the same rules that apply on the LinkedIn site. Data available includes group profile information, discussion posts, comments on posts, and likes.

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
You can share network updates through the [Share API](https://developer-programs.linkedin.com/documents/share-api).

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



