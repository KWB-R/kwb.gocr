% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gocrDownload.R
\name{gocrDownload}
\alias{gocrDownload}
\title{Download gocr executable}
\usage{
gocrDownload(
  version_number = "048",
  overwrite = FALSE,
  target_dir = file.path(system.file(package = "kwb.gocr"), "extdata/gocr")
)
}
\arguments{
\item{version_number}{latest version number is "049". However, "048" was used
for the development of this R package and is still available (default: "048")}

\item{overwrite}{if TRUE downloads and overwrites existing gocr executable in
target_directory, otherwise not (default: FALSE)}

\item{target_dir}{target directory (default: file.path(system.file(package = "kwb.gocr"),
"extdata/gocr2")}
}
\value{
downloads gocr executable to target directory and returns path
}
\description{
Download gocr executable
}
\examples{
gocrDownload(version_number = "048")
\dontrun{
gocrDownload(version_number = "049")
}
}
