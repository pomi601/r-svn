% File src/library/utils/man/Rscript.Rd
% Part of the R package, https://www.R-project.org
% Copyright 1995-2022 R Core Team
% Distributed under GPL 2 or later

\name{Rscript}
\alias{Rscript}
\title{Scripting Front-End for R}
\description{
  This is an alternative front end for use in \samp{#!} scripts and
  other scripting applications.
}
\usage{
\special{Rscript [options] file [args]}
\special{Rscript [options] -e expr [-e expr2 ...] [args]}
}
\arguments{
  \item{options}{a list of options, all beginning with \samp{--}.  These
    can be any of the options of the standard \R front-end, and also those
    described in the details.}
  \item{expr, expr2}{\R expression(s), properly quoted.}
  \item{file}{the name of a file containing \R commands.  \samp{-}
    indicates \file{stdin}.}
  \item{args}{arguments to be passed to the script in \code{file} or
    expressions supplied via \option{-e}.}
}
\details{
  \command{Rscript --help} gives details of usage, and
  \command{Rscript --version} gives the version of \command{Rscript}.

  Other invocations invoke the \R front-end with selected options.  This
  front-end is convenient for writing \samp{#!} scripts since it is an
  executable and takes \code{file} directly as an argument.  Options
  \option{--no-echo --no-restore} are always supplied: these imply
  \option{--no-save}. Arguments that contain spaces cannot be specified
  directly on the \samp{#!} line, because spaces and tabs are interpreted as
  delimiters and there is no way to protect them from this interpretation on
  the \samp{#!} line. (The standard Windows command line has no concept
  of \samp{#!} scripts, but \I{Cygwin} shells do.)

  \emph{Either} one or more \option{-e} options or \code{file} should
  be supplied.  When using \option{-e} options be aware of the quoting
  rules in the shell used: see the examples.

  The prescribed order of arguments is important: e.g.  \option{--verbose}
  specified after \option{-e} will be part of \code{args} and passed to the
  expression; the same will happen to \option{-e} specified after
  \code{file}.
  
  Additional options accepted as part of \code{options} (before \code{file}
  or \option{-e}) are
  \describe{
    \item{\option{--verbose}}{gives details of what \command{Rscript} is
      doing.}
    \item{\option{--default-packages=list}}{where \code{list} is a
      comma-separated list of package names or \code{NULL}.  Sets the
      environment variable \env{R_DEFAULT_PACKAGES} which determines the
      packages loaded on startup.
    }
  }

  Spaces are allowed in \code{expr} and \code{file} (but will need
  to be protected from the shell in use, if any, for example by
  enclosing the argument in quotes).

  If \option{--default-packages} is not used, then \command{Rscript}
  checks the environment variable \env{R_SCRIPT_DEFAULT_PACKAGES}. If
  this is set, then it takes precedence over \env{R_DEFAULT_PACKAGES}.

#ifdef unix
  Normally the version of \R is determined at installation, but this can
  be overridden by setting the environment variable \env{RHOME}.
#endif
#ifdef windows
  The \R files are found from the location of the \file{Rscript.exe}
  executable.   If this is copied elsewhere, the environment variable
  \env{RHOME} should be set to the top directory of the \R installation.

  Unlike Unix-alikes, this links directly to \file{R.dll} rather than
  running a separate process.
#endif

  \code{\link{stdin}()} refers to the input file, and
  \code{\link{file}("stdin")} to the \code{stdin} file stream of the
  process.
}
#ifdef unix
\note{
  \command{Rscript} is only supported on systems with the \code{execv}
  system call.
}
#endif
\examples{\dontrun{
#ifdef unix
Rscript -e 'date()' -e 'format(Sys.time(), "\%a \%b \%d \%X \%Y")'
#endif
#ifdef windows
# Note that Rscript is not by default in the PATH on Windows, so
# either put it there or use an explicit path to Rscript.

# at the standard Windows command line
Rscript -e "date()" -e "format(Sys.time(), \\"\%a \%b \%d \%X \%Y\\")"
# in other shells, e.g. bash or tcsh, prefer
Rscript -e 'date()' -e 'format(Sys.time(), "\%a \%b \%d \%X \%Y")'
#endif

# Get the same initial packages in the same order as default R:
Rscript --default-packages=methods,datasets,utils,grDevices,graphics,stats -e 'sessionInfo()'

## example #! script for a Unix-alike
## (arguments given on the #! line end up as [options] to Rscript, while
## arguments passed to the #! script end up as [args], so available to
## commandArgs())
#! /path/to/Rscript --vanilla --default-packages=utils
args <- commandArgs(TRUE)
res <- try(install.packages(args))
if(inherits(res, "try-error")) q(status=1) else q()

}}
\keyword{utilities}
