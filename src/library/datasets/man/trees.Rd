% File src/library/datasets/man/trees.Rd
% Part of the R package, https://www.R-project.org
% Copyright 1995-2023 R Core Team
% Distributed under GPL 2 or later

\name{trees}
\docType{data}
\alias{trees}
\title{Diameter, Height and Volume for Black Cherry Trees}
\description{
  This data set provides measurements of the diameter, height and volume
  of timber in 31 felled black cherry trees.  Note that the diameter (in inches) is erroneously
  labelled Girth in the data. It is measured at 4 ft 6 in above the ground.
}
\usage{trees}
\format{
  A data frame with 31 observations on 3 variables.
  \tabular{rlll}{
    \code{[,1]} \tab \code{Girth} \tab numeric
    \tab Tree diameter (rather than girth, actually) in inches\cr
    \code{[,2]} \tab \code{Height}\tab numeric
    \tab Height in ft\cr
    \code{[,3]} \tab \code{Volume}\tab numeric
    \tab Volume of timber in cubic ft\cr}
}
\source{
  Meyer, H. A. (1953)
  \emph{Forest Mensuration}.
  Penns Valley Publishers, Inc.

  Ryan, T. A., Joiner, B. L. and Ryan, B. F. (1976)
  \emph{The Minitab Student Handbook}.
  Duxbury Press.
}
\references{
  Atkinson, A. C. (1985)
  \emph{Plots, Transformations and Regression}.
  Oxford University Press.
}
\examples{
require(stats); require(graphics)
pairs(trees, panel = panel.smooth, main = "trees data")
plot(Volume ~ Girth, data = trees, log = "xy")
coplot(log(Volume) ~ log(Girth) | Height, data = trees,
       panel = panel.smooth)
summary(fm1 <- lm(log(Volume) ~ log(Girth), data = trees))
summary(fm2 <- update(fm1, ~ . + log(Height), data = trees))
step(fm2)
## i.e., Volume ~= c * Height * Girth^2  seems reasonable
}
\keyword{datasets}
