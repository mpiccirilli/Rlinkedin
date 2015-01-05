Rlinkedin
=========

This is a development version of an R package to access the LinkedIn API via R


Installation and Authentication
-------

Installing ane establishing a connection to the LinkedIn API. 

```{r}
require(devtools)
install_github("mpiccirilli/Rlinkedin")
require(Rlinkedin)

app.name <- "mikesapp"
api.key <- ""  # provided in Application Details
secret.key <- "" # provided in Application Details

in.auth <- inOAuth(app.name, api.key, secret.key)

```


getMyConnections
-----
Get your connections and basic/default information about them.
```{r}
my.connections <- getMyConenctions(in.auth)
```


getProfile
------
Get profile information of yourself, your connections, or an individual.
```{r}
my.profile <- getProfile(in.auth)

connections.profiles <- getProfile(in.auth, connections = TRUE)

individual.profile <- getProfile(in.auth, id = my.connections$id[1])
```


getJobs
--------
Returns LinkedIn job recommendations or search for jobs via LinkedIn. 
Currently I have only included the job recommendations.  I will update with the job search function soon.
```{r}
my.jobs <- getJobs(in.auth, suggestions = TRUE)
```


getGroups
---------
Returns information about what groups you belong to, either with or without detailed information
```{r}
my.groups <- getGroups(in.auth, details=TRUE)
```


getGroupPosts
--------
Returns posts from groups you belong to
```{r}
my.group.posts <- getGroupPosts(in.auth)
```
