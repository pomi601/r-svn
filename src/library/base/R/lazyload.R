#  File src/library/base/R/lazyload.R
#  Part of the R package, https://www.R-project.org
#
#  Copyright (C) 1995-2020 The R Core Team
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

## This code should be kept in step with code in ../baseloader.R
##
## This code has been factored in a somewhat peculiar way to allow the
## lazy load data base mechanism to be used for storing processed .Rd
## files. This isn't quite right as the .Rd use only uses the data
## base, not the lazy load part, but for now it will do. LT

lazyLoadDBexec <- function(filebase, fun, filter)
{
    ##
    ## bootstrapping definitions so we can load base
    ## - not that this version is actually used to load base (but the ../baseloader.R  one is!)
    ##
    glue <- function (..., sep = " ", collapse = NULL)
##      .Internal(paste(list(...), sep, collapse, TRUE))# recycle0=TRUE
        .Internal(paste(list(...), sep, collapse, FALSE))
    readRDS <- function (file) {
        halt <- function (message) .Internal(stop(TRUE, message))
        gzfile <- function (description, open)
            .Internal(gzfile(description, open, "", 6))
        close <- function (con) .Internal(close(con, "rw"))
        if (! is.character(file)) halt("bad file name")
        con <- gzfile(file, "rb")
        on.exit(close(con))
        .Internal(unserializeFromConn(con, baseenv()))
    }
    `parent.env<-` <-
        function (env, value) .Internal(`parent.env<-`(env, value))
    existsInFrame <- function (x, env) .Internal(exists(x, env, "any", FALSE))
    list2env <- function (x, envir) .Internal(list2env(x, envir))
    environment <- function () .Internal(environment(NULL))
    mkenv <- function() .Internal(new.env(TRUE, baseenv(), 29L))

    ##
    ## main body
    ##
    mapfile  <- glue(filebase, "rdx", sep = ".")
    datafile <- glue(filebase, "rdb", sep = ".")
    env <- mkenv()
    map <- readRDS(mapfile)
    vars <- names(map$variables)
    compressed <- map$compressed
    list2env(map$references, env)
    envenv <- mkenv()
    envhook <- function(n) {
        if (existsInFrame(n, envenv))
            envenv[[n]]
        else {
            e <- mkenv()
            envenv[[n]] <- e           # MUST do this immediately
            key <- env[[n]]
            ekey <- if (is.list(key)) key$eagerKey else key
            data <- lazyLoadDBfetch(ekey, datafile, compressed, envhook)
            ## comment from r41494
            ## modified the loading of old environments, so that those
            ## serialized with parent.env NULL are loaded with the
            ## parent.env=emptyenv(); and yes an alternative would have been
            ## baseenv(), but that was seldom the intention of folks that
            ## set the environment to NULL.
            parent.env(e) <- data$enclos %||% emptyenv()
            list2env(data$bindings, e)
            if (! is.null(data$attributes))
                attributes(e) <- data$attributes
            if (! is.null(data$isS4) && data$isS4)
                .Internal(setS4Object(e, TRUE, TRUE))

            ## lazily loaded bindings (used e.g. for parseData and lines from
            ## source references)
            if (is.list(key)) {
                expr <- quote(lazyLoadDBfetch(KEY, datafile, compressed, envhook))
                .Internal(makeLazy(names(key$lazyKeys), key$lazyKeys, expr,
                    parent.env(environment()), e))
            }
            if (! is.null(data$locked) && data$locked)
                .Internal(lockEnvironment(e, FALSE))
            e
        }
    }
    if (!missing(filter)) {
        use <- filter(vars)
        vars <- vars[use]
        vals <- map$variables[use]
        use <- NULL
    } else
        vals <-  map$variables

    ## This may use vals.
    res <- fun(environment())

    ## reduce memory use
    map <- NULL
    vars <- NULL
    vals <- NULL
    rvars <- NULL
    mapfile <- NULL
    readRDS <- NULL

    res
}

lazyLoad <- function(filebase, envir = parent.frame(), filter)
{
    fun <- function(db) {
        vals <- db$vals
        vars <- db$vars
        expr <- quote(lazyLoadDBfetch(key, datafile, compressed, envhook))
        .Internal(makeLazy(vars, vals, expr, db, envir))
    }
    lazyLoadDBexec(filebase, fun, filter)
}
