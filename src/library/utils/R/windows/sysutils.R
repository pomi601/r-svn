#  File src/library/utils/R/windows/sysutils.R
#  Part of the R package, https://www.R-project.org
#
#  Copyright (C) 1995-2023 The R Core Team
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  A copy of the GNU General Public License is available at
#  https://www.R-project.org/Licenses/

memory.size <- function(max = FALSE)
{
    warning("'memory.size()' is no longer supported", call.=FALSE)
    Inf
}

memory.limit <- function(size = NA)
{
    warning("'memory.limit()' is no longer supported", call.=FALSE)
    Inf
}

DLL.version <- function(path) .Call(C_dllversion, path)

getClipboardFormats <- function(numeric = FALSE)
{
    known <- c("text", "bitmap", "metafile PICT", "SYLK", "DIF",
    "TIFF", "OEM text", "DIB", "palette", "pendata", "RIFF", "audio",
    "Unicode text", "enhanced metafile", "drag-and-drop", "locale", "shell")
    ans <- sort(.Call(C_getClipboardFormats))
    if(numeric) ans else {
        res <- known[ans]
        res[is.na(res)] <- ans[is.na(res)]
        res
    }
}

readClipboard <- function(format = 13L, raw = FALSE)
    .Call(C_readClipboard, format, raw)

writeClipboard <- function(str, format = 13L)
    invisible(.Call(C_writeClipboard, str, format))

getIdentification <- function() .Call(C_getIdentification)

setWindowTitle <- function(suffix, title = paste(getIdentification(), suffix))
    invisible(.Call(C_setWindowTitle,  title))

getWindowTitle <- function() .Call(C_getWindowTitle)

setStatusBar <- function(text) .Call(C_setStatusBar, text)

getWindowsHandle <- function(which = "Console") {
    if (is.numeric(which)) {
	which <- as.integer(which)
        if(!exists(".Devices")) .Devices <- list("null device")
        if(which > 0 && which <= length(.Devices) && .Devices[[which]] != "windows")
            return(NULL)
    }
    .Call(C_getWindowsHandle, which)
}

getWindowsHandles <- function(which = "R", pattern = "", minimized = FALSE)
{
    which <- match.arg(which, c("R", "all"), several.ok = TRUE)
    len <- max(length(which), length(pattern), length(minimized))
    which     <- rep_len(which,     len)
    pattern   <- rep_len(pattern,   len)
    minimized <- rep_len(minimized, len)
    result <- list()
    for (i in seq_len(len)) {
	res <- .Call(C_getWindowsHandles, which[i], minimized)
	if (nzchar(pattern[i])) res <- res[grep(pattern[i], names(res))]
    	result <- c(result, res) # does *not* grow if res is of length 0
    }
    dup <- duplicated(lapply(result, deparse))
    result[!dup]
}

arrangeWindows <-
    function(action = c("vertical", "horizontal","cascade", "minimize", "restore"),
             windows, preserve = TRUE, outer = FALSE)
{
    action <- match.arg(action)
    action <- which(action == c("cascade", "horizontal", "vertical", "minimize", "restore"))
    stopifnot(length(action) == 1 && !is.na(action))

    if (missing(windows)) {
    	args <- get0(".arrangeWindowsDefaults", globalenv()) %||% list()
        if (action == 5) # restore
            args$minimized <- TRUE
    	windows <- do.call(getWindowsHandles, args)
    }
   .External2(C_arrangeWindows, windows, action, preserve, outer)
}

menuShowCRAN <- function()
{
    CRAN <- getOption("repos")[["CRAN"]] # drop name for identical()
    if(is.na(CRAN) || identical(CRAN, "@CRAN@"))
        CRAN <- "https://cran.r-project.org"
    shell.exec(CRAN)
}

shortPathName <- function(path) .Call(C_shortpath, path)

readRegistry <-
    function(key, hive=c("HLM", "HCR", "HCU", "HU", "HCC", "HPD"),
             maxdepth = 1, view = c("default", "32-bit", "64-bit"))
{
    view <- match(match.arg(view), c("default", "32-bit", "64-bit"))
    .External2(C_readRegistry, key, match.arg(hive), maxdepth, view)
}

setInternet2 <- function(use = TRUE) .Defunct()


win.version <- function() .Call(C_winver)
