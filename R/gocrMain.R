# gocrRun ----------------------------------------------------------------------

#' Run gocr on an Image File
#' 
#' @param config gocr configuration as returned by \code{\link{gocrConfig}}
#' @param useBatch if TRUE (default), a batch file is written so that the user
#'   can reproduce the call by double-clicking the batch file in the file
#'   explorer (opens when \emph{opendir} is TRUE)
#' @param waitForBatch passed to \code{kwb.gocr:::writeAndRunBatchFile}
#' @param opendir if TRUE (default), and if \emph{useBatch} is TRUE, the
#'   directory in which the batch file is written, is opened in the Windows
#'   Explorer
#' @param dbg if \code{TRUE} debug messages are shown
#' 
#' @return (only if \emph{waitForBatch} = TRUE): result of OCR as a vector of 
#'   character representing the recognised lines. The result vector has the 
#'   attribute \emph{config} containing the configuration used (original config,
#'   with default values set where needed)
#' 
#' @export
#'  
gocrRun <- function(
  config, useBatch = TRUE, waitForBatch = TRUE, opendir = TRUE, dbg = TRUE
) 
{
  cmd <- paste(kwb.utils::cmdLinePath(gocrExePath()), gocrOptionString(config))
  
  gocrDir <- kwb.utils::createDirectory(file.path(tempdir(), "gocr"), dbg = dbg)
  
  # Get the basename of the input file to be used as part of result and error
  # file
  inputBasename <- gsub("\\.pgm$", "", basename(config$inputfile))
  
  # Set a value for settings that are emtpy ("")
  config <- setDefaultsInSetting(config, inputBasename, gocrDir, dbg)
  
  # If the database is to be extended we need to run gocr in a separate
  # cmd window. Therefore, create and run a batch file containing the gocr-call  
  errCode <- if (useBatch) {
    
    writeAndRunBatchFile(
      config, inputBasename, gocrDir, opendir, waitForBatch, dbg
    )
    
  } else {
    
    # Run gocr. Therefore, append the command string to the cmd command
    # (I do not know why but otherwise it won't work)
    kwb.utils::hsShell(commandLine = paste(
      "cmd /C ", kwb.utils::cmdLinePath(cmd)
    ))
  }

  if (waitForBatch) {
    
    stopOnErrorAndDeleteErrorFile(errCode, config$errorfile)
    
    if (config$outputfile != "" && file.exists(config$outputfile)) {
      
      result <- readLines(config$outputfile, warn = FALSE)      
    }
    
    structure(result, config = config)
  }
}

# gocrConfig -------------------------------------------------------------------

#' Create a gocr Configuration
#' 
#' @param inputfile -i file: read input from file (or stdin if file is a single
#'   dash)
#' @param showhelp -h: show usage information
#' @param outputfile -o file: send output to file instead of stdout. If ""
#'   (default), a file "gocrOut_<\emph{basename(outputfile)}>" in
#'   \code{tempdir()} is used as the output file.
#' @param errorfile -e file: send errors to file instead of stderr or to stdout
#'   if file is a dash
#' @param progressfile -x file: progress output to file (file can be a file
#'   name, a fifo name or a file descriptor 1...255), this is useful for  GUI 
#'   developpers to  show the OCR progress, the file descriptor argument is only
#'   available, if compiled with __USE_POSIX defined
#' @param databasepath -p path: database path, that will be populated with
#'   images of learned characters. If "" (default), and a database is needed, a
#'   directory within the folder of the installed package is used
#' @param outputformat -f format: output  format  of  the  recognized text
#'   (ISO8859_1 TeX HTML XML UTF8 ASCII), XML will also output position and
#'   probability data
#' @param greylevel -l level set grey level to level (0<160<=255, default: 0 for
#'   autodetect), darker  pixels  belong to characters, brighter pixels are
#'   inter- preted as background of the input image
#' @param dustsize -d size: set dust size in pixels (clusters smaller than this
#'   are removed), 0 means no clusters are removed, the default is -1 for auto
#'   detection
#' @param spacewidth -s num: set spacewidth between words in units of dots
#'   (default: 0 for autodetect), wider widths are interpreted as  word  spaces,
#'   smaller as character spaces
#' @param verbosity -v verbosity: be verbose to stderr; verbosity is a bitfield.
#'   Use \code{\link{optionValueVerbosity}} to get a proper value
#' @param limitVerbosityToChars -c string: only verbose output of characters
#'   from string to stderr, more output  is  generated  for all characters
#'   within the string, the
#' @param limitRecognitionToChars -C string: only recognise characters from
#'   string, this is a filter function in cases where the interest is only to a
#'   part of  the  character alphabet
#' @param certainty -a certainty: set  value  for  certainty of recognition
#'   (0..100; default: 95), characters with a higher certainty are accepted,
#'   characters with a lower certainty are treated as unknown (not recognized);
#'   set higher values, if you want to have only more certain recognized
#'   characters
#' @param mode -m mode: set oprational mode; mode is a bitfield (default: 0).
#'   Use \code{\link{optionValueMode}} to get a proper value
#' @param onlyRecogniseNumbers -n bool: if  bool  is non-zero, only recognise
#'   numbers (this is now obsolete, use -C "0123456789")
#' 
#' @export
#' 
gocrConfig <- function(
  inputfile, showhelp = FALSE, outputfile = "", errorfile = "", 
  progressfile = "", databasepath = "", outputformat = "", greylevel = 0,
  dustsize = -1, spacewidth = 0, verbosity = 0, limitVerbosityToChars = "",
  limitRecognitionToChars = "", certainty = 95, mode = 0, 
  onlyRecogniseNumbers = FALSE
)
{
  list(
    inputfile = inputfile,  
    showhelp = showhelp,
    outputfile = outputfile,
    errorfile = errorfile,
    progressfile = progressfile,
    databasepath = databasepath,
    outputformat = outputformat,
    greylevel = greylevel,
    dustsize = dustsize,
    spacewidth = spacewidth,
    verbosity = verbosity,
    limitVerbosityToChars = limitVerbosityToChars,
    limitRecognitionToChars = limitRecognitionToChars,
    certainty = certainty,
    mode = mode,
    onlyRecogniseNumbers = onlyRecogniseNumbers
  )
}

# setDefaultsInSetting ---------------------------------------------------------
setDefaultsInSetting <- function(config, inputBasename, gocrDir, dbg = TRUE)
{
  # We will always use an output file
  if (config$outputfile == "") {
    
    outFilename <- sprintf("gocrOut_%s.txt", inputBasename)
    
    config$outputfile <- file.path(gocrDir, outFilename)
  }
  
  # If the database is to be used but no database path is given we use the
  # database in this package
  optionName <- c("useDatabase", "extendDatabase")
  
  dbNeeded <- any(modeOptionIsSet(optionName, modeValue = config$mode))
  
  if (config$databasepath == "" && dbNeeded) {
    
    config$databasepath <- system.file(
      "extdata", "gocr", "db", package = "kwb.gocr"
    )
    
    kwb.utils::catIf(
      dbg, "*** Using default database:", config$databasepath, "\n"
    )
  }
  
  # Redirect error output into file (only if database is not to be extended
  # since otherwise user cannot interact)
  if (config$errorfile == "" && 
      ! modeOptionIsSet("extendDatabase", config$mode)) {
    
    errFilename <- sprintf("gocrErr_%s.txt", inputBasename)
    
    config$errorfile <- file.path(gocrDir, errFilename)
  }
  
  config
}

# writeAndRunBatchFile ---------------------------------------------------------
writeAndRunBatchFile <- function(
  config, inputBasename, gocrDir, opendir, waitForBatch, dbg
)
{
  # Write the batch file
  batfile <- writeBatchFile(config, inputBasename, gocrDir, dbg)
  
  # Open directory in file explorer if desired
  if (opendir) {
    
    shell.exec(dirname(batfile))
  }
  
  # Run the batch file
  runBatchFile(batfile, waitForBatch = waitForBatch, dbg = dbg)
  
  return (0)
}

# writeBatchFile ---------------------------------------------------------------
writeBatchFile <- function(config, inputBasename, gocrDir, dbg = TRUE)
{
  batfilename <- sprintf("run_gocr_%s.bat", inputBasename)
  
  batfile <- file.path(gocrDir, batfilename)
  
  kwb.utils::catIf(dbg, "Writing batch file:", batfile, "...")
  
  writeLines(gocrBatchFileContent(config), batfile)
  
  kwb.utils::catIf(dbg, "ok.\n")
  
  batfile
}

# runBatchFile -----------------------------------------------------------------
runBatchFile <- function(
  batfile, runDir = tempdir(), waitForBatch = TRUE, dbg = TRUE
)
{  
  kwb.utils::catIf(dbg, "Running batch file in", runDir, "...")
  
  if (waitForBatch) {
    
    kwb.utils::runBatchfileInDirectory(batfile, runDir)
    
  } else {
    
    shell(batfile, minimized = TRUE)
  }
  
  if (waitForBatch) {
    
    readline(prompt = "Press Return if the batch file has finished...")
  }  
}

# gocrExePath ------------------------------------------------------------------

#' Path to gocr Executable File
#' 
gocrExePath <- function()
{
  system.file("extdata", "gocr", "gocr048.exe", package = "kwb.gocr")
}

# gocrBatchFileContent ---------------------------------------------------------

gocrBatchFileContent <- function(config, insertPause = FALSE)
{
  c(
    "@ECHO OFF",
    "REM batch file generated by kwb.gocr::gocrBatchFileContent()\n",    
    paste("ECHO Running gocr on %s ...", config$inputfile),
    paste(kwb.utils::cmdLinePath(gocrExePath()), gocrOptionString(config)),
    if (insertPause) "pause"
  )
}

# gocrOptionString -------------------------------------------------------------

#' Option String for gocr Call
#' 
#' @param config gocr configuration as returned by \code{\link{gocrConfig}}
#' 
gocrOptionString <- function(config)
{
  opt <- paste("-i", kwb.utils::cmdLinePath(config$inputfile))
  
  opt <- appendPathIfNotEqual(opt, "-o", config$outputfile, "")
  opt <- appendPathIfNotEqual(opt, "-e", config$errorfile, "")
  opt <- appendPathIfNotEqual(opt, "-x", config$progressfile, "")
  
  # it seems that -m needs to come before -p
  opt <- appendIfNotEqual(opt, "-m", config$mode, 0)  

  opt <- appendIfNotEqual(opt, "-h", config$showhelp, FALSE, switchOnly = TRUE)
  opt <- appendIfNotEqual(opt, "-f", config$outputformat, "")
  opt <- appendIfNotEqual(opt, "-l", config$greylevel, 0)
  opt <- appendIfNotEqual(opt, "-d", config$dustsize, -1)
  opt <- appendIfNotEqual(opt, "-s", config$spacewidth, 0)
  opt <- appendIfNotEqual(opt, "-v", config$verbosity, 0)
  opt <- appendIfNotEqual(opt, "-c", config$limitVerbosityToChars, "")
  
  opt <- appendIfNotEqual(opt, "-C", config$limitRecognitionToChars, "")  
  # opt <- paste(opt, "-C", hsQuoteChr(charsToRecognise, qchar='"'))
  
  opt <- appendIfNotEqual(opt, "-a", config$certainty, 95)
  
  only_numbers <- as.integer(config$onlyRecogniseNumbers)
  
  opt <- appendIfNotEqual(opt, "-n", only_numbers, 0)

  # it seems that the path to the database must not be included in quotes! 
  # -> it must not contain spaces!
  dbpath <- paste0(config$databasepath, "/") # final slash needed!
  
  if (grepl("\\s", dbpath)) {
    
    cat(sprintf(
      "\n***\n*** The path to the database \"%s\" contains spaces! %s",
      dbpath, "I do not know how to pass to gocr!\n***\n"
    ))
  }
  
  #opt <- appendPathIfNotEqual(opt, "-p", dbpath, "")
  opt <- appendIfNotEqual(opt, "-p", dbpath, "")
  
  opt
}

# appendIfNotEqual -------------------------------------------------------------
appendIfNotEqual <- function(
  optionString, optionSwitch, optionValue, compareWith, switchOnly = FALSE
)
{
  if (optionValue != compareWith) {
    
    optionString <- paste(optionString, optionSwitch)
    
    if (! switchOnly) {
      
      optionString <- paste(optionString, optionValue)
    }
  }  
  
  optionString
}

# appendPathIfNotEqual ---------------------------------------------------------
appendPathIfNotEqual <- function(
  optionString, optionSwitch, optionValue, compareWith
)
{
  if (optionValue != compareWith) {
    
    optionString <- paste(optionString, optionSwitch, kwb.utils::cmdLinePath(optionValue))
  } 
  
  optionString
}

# stopOnErrorAndDeleteErrorFile ------------------------------------------------

stopOnErrorAndDeleteErrorFile <- function(errCode, errorFile, mydebug = FALSE)
{
  errorMessages <- NULL
  
  errorLines <- NULL
  
  # read and delete error file if it exists
  if (file.exists(errorFile)) {
    
    errorLines <- readLines(errorFile, warn = FALSE)
    unlink(errorFile)
  }   
  
  kwb.utils::catIf(mydebug, "Error code of gocr:", errCode, "\n")

  if (errCode != 0) {
    
    errorMessages <- paste("gocr returned a non-zero error code:", errCode)
  }
  
  if (! kwb.utils::isNullOrEmpty(errorLines) && 
      any(grepl("ERROR", errorLines))) {
    
    errorMessages <- c(errorMessages, "Content of error file: ", errorLines)
  }
  
  if (! kwb.utils::isNullOrEmpty(errorMessages)) {
    
    stop(kwb.utils::collapsed(errorMessages, "\n"))
  }
}

# optionValueVerbosity ---------------------------------------------------------

#' Value for Option Verbosity
#' 
#' @param printMore (1) print more info
#' @param listShapes (2) list shapes of boxes (see -c) to stderr
#' @param listPattern (4) list pattern of boxes (see -c) to stderr
#' @param printPattern (8) print pattern after recognition for debugging
#' @param printDebug (16) print debug information about recognition of lines to
#'   stderr
#' @param createOutPng (32) create outXX.png with boxes and lines marked on each
#'   general OCR-step
#'   
#' @export
#'  
optionValueVerbosity <- function( 
  printMore = 1, listShapes = 1, listPattern = 1, printPattern = 1, 
  printDebug = 1, createOutPng = 0
)
{
  printMore * 1 + listShapes * 2 + listPattern * 4 + printPattern * 8 + 
    printDebug * 16 + createOutPng * 32    
}

# modeOptionIsSet --------------------------------------------------------------

modeOptionIsSet <- function(optionName, modeValue)
{
  bitValue <- getModeValues()[optionName]
  
  bitops::bitAnd(modeValue, bitValue) == bitValue
}

# optionValueMode --------------------------------------------------------------

#' Value for Mode Option
#' 
#' @param useDatabase (2) use database to recognize characters which are not
#'   recognized by other algorithms, (early development)
#' @param layoutAnalysis (4) switching on layout analysis or zoning
#'   (development)
#' @param doNotCompare (8) don't compare unrecognized characters to recognized
#'   one
#' @param doNotDivide (16) don't try to divide overlapping characters to two or
#'   three single characters
#' @param doNotCorrect (32) don't do context correction
#' @param characterPacking (64) character packing, before recognition starts,
#'   similar characters are searched and only one of this characters will be
#'   send to the recognition engine (development)
#' @param extendDatabase (128) extend database, prompts user for unidentified
#'   characters and extends the database with users answer (128+2, early
#'   development)
#' @param switchOffEngine (256) switch off the recognition engine (makes sense
#'   together with -m 2)
#' 
#' @export
#' 
#' @references \url{http://manpages.ubuntu.com/manpages/gutsy/man1/gocr.1.html}
#' 
optionValueMode <- function
(
  useDatabase = FALSE,
  layoutAnalysis = FALSE,
  doNotCompare = FALSE,
  doNotDivide = FALSE,
  doNotCorrect = FALSE,
  characterPacking = FALSE,
  extendDatabase = FALSE,
  switchOffEngine = FALSE
)
{
  if (extendDatabase && !useDatabase) {
    
    useDatabase <- TRUE
    
    warning("useDatabase has been set to TRUE since extendDatabase is TRUE!")
  }

  modeValues <- getModeValues()
  
  sum(c(
    useDatabase * modeValues["useDatabase"],
    layoutAnalysis * modeValues["layoutAnalysis"],
    doNotCompare * modeValues["doNotCompare"],
    doNotDivide * modeValues["doNotDivide"],
    doNotCorrect * modeValues["doNotCorrect"],
    characterPacking * modeValues["characterPacking"],
    extendDatabase * modeValues["extendDatabase"],
    switchOffEngine * modeValues["switchOffEngine"]
  ))
}

# getModeValues ----------------------------------------------------------------

getModeValues <- function()
{
  modeValueNames <- c(
    "useDatabase", "layoutAnalysis", "doNotCompare", "doNotDivide",
    "doNotCorrect", "characterPacking", "extendDatabase", "switchOffEngine"
  )
  
  stats::setNames(2^(seq_along(modeValueNames)), nm = modeValueNames)
}
