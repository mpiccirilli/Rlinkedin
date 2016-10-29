#' Access to LinkedIn API via R
#' 
#' This is an R package that provides a series of functions that allow users
#' to access the LinkedIn API to get information about connections, search for people,
#' search for jobs, share updates with your network, and create group discussions.
#'
#' @seealso \code{\link{inOAuth}}, \code{\link{getProfile}}, 
#' \code{\link{getMyConnections}}, \code{\link{getGroupPosts}},
#' \code{\link{getGroups}}, \code{\link{getJobs}}, 
#' \code{\link{searchJobs}}, \code{\link{searchPeople}},
#' \code{\link{submitGroupPost}}, \code{\link{submitShare}},
#' \code{\link{getCompany}}, \code{\link{searchCompanies}}
#' @name Rlinkedin-package
#' @aliases Rlinkedin
#' @docType package
#' @author Michael Piccirilli \email{michael.r.piccirilli@gmail.com}
#' @import httr XML httpuv
#' @importFrom utils URLencode
#' @importFrom methods as
NULL