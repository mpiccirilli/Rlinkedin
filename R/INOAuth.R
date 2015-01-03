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