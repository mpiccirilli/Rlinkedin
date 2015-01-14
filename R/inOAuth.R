#' LinkedIn Job Recommendations and Job Search
#'
#' Establishes a connection to the LinkedIn API. 
#'
#'
#' @param application_name Name of your application
#' @param consumer_key Consumer API Key of your application
#' @param consumer_secret Consumer Secret Key of your application
#' @return Authorization token to be used in other functions
#' @examples
#' \dontrun{
#' 
#' \# To use the default API and Secret Key for the Rlinkedin package:
#' in.auth <- inOAuth()
#' 
#' \# To use your own application's API and Secret Key:
#' in.auth <- inOAuth("your_app_name", "your_consumer_key", "your_consumer_secret")
#' }
#' @export


inOAuth <- function(application_name=NULL, consumer_key=NULL, consumer_secret=NULL)
{
  # This seems repetitive...
  if(is.null(application_name) && is.null(consumer_key) && is.null(consumer_secret)){
    application_name <- "Rlinkedin"
    consumer_key <- "77w6b6fmmu2967"
    consumer_secret <- "JcHFtrazNQAgBVMx"
    linkedin <- oauth_endpoint("requestToken", "authorize", "accessToken",
                               base_url = "https://api.linkedin.com/uas/oauth/")
    myapp <- oauth_app(appname = application_name, consumer_key, consumer_secret)
    token <- oauth1.0_token(linkedin, myapp)
  }
  if(list.files(getwd(), all.files=TRUE, pattern=".httr-oauth")==".httr-oauth"){
    linkedin <- oauth_endpoint("requestToken", "authorize", "accessToken",
                               base_url = "https://api.linkedin.com/uas/oauth/")
    myapp <- oauth_app(appname = application_name, consumer_key, consumer_secret)
    token <- oauth1.0_token(linkedin, myapp)
  }
  else {
    full_url <- oauth_callback()
    message <- paste("If you've created you're own application, be sure to copy and paste the following into \n 'OAuth 2.0 Redirect URLs' in the LinkedIn Application Details:", full_url, "\n When done, press any key to continue...")
    
    invisible(readline(message))
    linkedin <- oauth_endpoint("requestToken", "authorize", "accessToken",
                               base_url = "https://api.linkedin.com/uas/oauth/")
    myapp <- oauth_app(appname = application_name, consumer_key, consumer_secret)
    token <- oauth1.0_token(linkedin, myapp)
  }
  return(token)
}