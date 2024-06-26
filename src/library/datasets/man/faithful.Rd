% File src/library/datasets/man/faithful.Rd
% Part of the R package, https://www.R-project.org
% Copyright 1995-2018 R Core Team
% Distributed under GPL 2 or later

\name{faithful}
\docType{data}
\alias{faithful}
\encoding{UTF-8}
\title{Old Faithful Geyser Data}
\description{
  Waiting time between eruptions and the duration of the eruption for
  the Old Faithful geyser in Yellowstone National Park, Wyoming, USA.
}
\usage{faithful}
\format{A data frame with 272 observations on 2 variables.
  \tabular{rlll}{
    [,1]  \tab \code{eruptions}  \tab numeric  \tab Eruption time in \abbr{min}s \cr
    [,2]  \tab \code{waiting}    \tab numeric  \tab Waiting time to next
    eruption (in \abbr{min}s)\cr
  }
}
\source{W. Härdle.}
\references{
  \enc{Härdle}{Haerdle}, W. (1991).
  \emph{Smoothing Techniques with Implementation in S}.
  New York: Springer.

  Azzalini, A. and Bowman, A. W. (1990).
  A look at some data on the Old Faithful geyser.
  \emph{Applied Statistics}, \bold{39}, 357--365.
  \doi{10.2307/2347385}.
}
\details{
  A closer look at \code{faithful$eruptions} reveals that these are
  heavily rounded times originally in seconds, where multiples of 5 are
  more frequent than expected under non-human measurement.  For a
  better version of the eruption times, see the example below.

  There are many versions of this dataset around:
  \bibcite{Azzalini and Bowman (1990)} use a more complete version.
}
\seealso{
  \code{geyser} in package \CRANpkg{MASS} for the \I{Azzalini}--\I{Bowman} version.
}
\examples{
require(stats); require(graphics)
f.tit <-  "faithful data: Eruptions of Old Faithful"

ne60 <- round(e60 <- 60 * faithful$eruptions)
all.equal(e60, ne60)             # relative diff. ~ 1/10000
table(zapsmall(abs(e60 - ne60))) # 0, 0.02 or 0.04
faithful$better.eruptions <- ne60 / 60
te <- table(ne60)
te[te >= 4]                      # (too) many multiples of 5 !
plot(names(te), te, type = "h", main = f.tit, xlab = "Eruption time (sec)")

plot(faithful[, -3], main = f.tit,
     xlab = "Eruption time (min)",
     ylab = "Waiting time to next eruption (min)")
lines(lowess(faithful$eruptions, faithful$waiting, f = 2/3, iter = 3),
      col = "red")
}
\keyword{datasets}
