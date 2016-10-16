#' Create OAuth token to LinkedIn R session
#'
#' @description
#' \code{inOAuth} creates a long-lived OAuth access token that enables R to make
#' authenticated calls to the LinkedIn API. This function relies on the
#' \code{httr} package to create the OAuth token.
#'
#'
#' @details
#' There are two ways to create an authenticated connection.  One is to use 
#' the default credentials supplied in the package.  The second is to obtain
#' your own credentials and using them as inputs into the function.
#' Examples of both are shown below. 
#' 
#' Create your own application here: \url{https://developer.linkedin.com/}
#'
#'
#' @author
#' Michael Piccirilli \email{michael.r.piccirilli@@gmail.com}
#' @seealso \code{\link{getProfile}}, \code{\link{getMyConnections}}
#'
#'
#' @param application_name Name of your application.
#' @param consumer_key Consumer API Key of your application.
#' @param consumer_secret Consumer Secret Key of your application.
#' @return Authorization token to be used in other functions.
#' @examples
#' \dontrun{
#' 
#' ## Default Consumer and Secret Key for the Rlinkedin package:
#' in.auth <- inOAuth()
#' 
#' ## Use your own Consumer and Secret Key:
#' in.auth <- inOAuth("your_app_name", "your_consumer_key", "your_consumer_secret")
#' }
#' @export


inOAuth <- function(application_name=NULL, consumer_key=NULL, consumer_secret=NULL)
{
  
  full_url <- oauth_callback()
  message <- paste("If you've created you're own application, be sure to copy and paste the following into \n 'OAuth 2.0 Redirect URLs' in the LinkedIn Application Details:", full_url, "\n When done, press any key to continue...")
  invisible(readline(message))
  
  if(is.null(application_name) && is.null(consumer_key) && is.null(consumer_secret)){
    application_name <- "RLnkdInV2"
    consumer_key <- "75yrky9cluyq7b"
    consumer_secret <- "ZRZ9Wm6mgyYvUiXL"
    linkedin <- oauth_endpoint("requestToken", "authorize", "accessToken",
                               base_url = "https://api.linkedin.com/uas/oauth")
    

    myapp <- oauth_app(appname = application_name, consumer_key, consumer_secret)
    token <- oauth1.0_token(linkedin, myapp)
    return(token)
  }
  else {
    linkedin <- oauth_endpoint("requestToken", "authorize", "accessToken",
                             base_url = "https://api.linkedin.com/uas/oauth")
    myapp <- oauth_app(appname = application_name, consumer_key, consumer_secret)
    token <- oauth1.0_token(linkedin, myapp)
    return(token)
  }
}