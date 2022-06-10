#' Download gocr executable
#'
#' @param version_number latest version number is "049". However, "048" was used
#' for the development of this R package and is still available (default: "048")
#' @param target_dir target directory (default: file.path(system.file(package = "kwb.gocr"),
#' "extdata/gocr2")
#' @param overwrite if TRUE downloads and overwrites existing gocr executable in
#' target_directory, otherwise not (default: FALSE)
#' @return downloads gocr executable to target directory and returns path
#' @export
#' @importFrom kwb.utils catAndRun resolve
#' @importFrom utils download.file
#' @examples
#' gocrDownload(version_number = "048")
#' \dontrun{
#' gocrDownload(version_number = "049")
#' }
gocrDownload <- function(version_number = "048",
                          overwrite = FALSE,
                          target_dir = file.path(system.file(package = "kwb.gocr"),
                                                 "extdata/gocr")) {
  paths_list <-
    list(
      base_url = "https://www-e.uni-magdeburg.de/jschulen/ocr",
      tdir = target_dir,
      version = version_number,
      exe_name = "gocr<version>.exe",
      exe_source = "<base_url>/<exe_name>",
      exe_target = "<tdir>/<exe_name>"
    )

  paths <- kwb.utils::resolve(paths_list)
    
  if (!file.exists(paths$exe_target) || overwrite) {

    if (!dir.exists(paths$tdir)) {
      dir.create(paths$tdir, recursive = TRUE)
    }
    
    msg <- sprintf(
      "Downloading '%s' executable from '%s' to '%s'",
      paths$exe_name,
      paths$exe_source,
      paths$exe_target
    )
    
    kwb.utils::catAndRun(messageText = msg,
                         expr = {
                           download.file(url = paths$exe_source,
                                         destfile = paths$exe_target,
                                         mode = "wb")
                         })
    if (!file.exists(paths$exe_target)) {
      stop(
        sprintf(
          "%s could not be downloaded from %s to %s",
          paths$exe_name,
          paths$exe_source,
          paths$exe_target
        )
      )
    }
  } else {
    message("Skip downloading of gocr as already available in target directory!")
  }
  paths$exe_target
}
