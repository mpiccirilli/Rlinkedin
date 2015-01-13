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
#' in.auth <- inOAuth("myappname", "your_consumer_key", "your_consumer_secret")
#' }
#' @export


inOAuth <- function(application_name, consumer_key, consumer_secret)
{
  full_url <- oauth_callback()
  message <- paste("Copy and paste into 'OAuth 2.0 Redirect URLs' on LinkeIn Application Details:", full_url, "\nWhen done, press any key to continue...")
  invisible(readline(message))
  linkedin <- oauth_endpoint("requestToken", "authorize", "accessToken", base_url = "https://api.linkedin.com/uas/oauth/")
  myapp <- oauth_app(appname = application_name, consumer_key, consumer_secret)
  token <- oauth1.0_token(linkedin, myapp)
  return(token)
}