% Please edit documentation in R/output.R
\name{knit}
\alias{knit}
\alias{purl}
\title{Knit a document}
\usage{
knit(input, output = NULL, tangle = FALSE, text = NULL, quiet = FALSE, 
    envir = parent.frame(), encoding = getOption("encoding"))

purl(..., documentation = 1L)
}
\arguments{
\item{input}{path of the input file}

\item{output}{path of the output file for \code{knit()}; if \code{NULL}, this
function will try to guess and it will be under the current working
directory}

\item{tangle}{whether to tangle the R code from the input file (like
\code{\link[utils]{Stangle}})}

\item{text}{a character vector as an alternative way to provide the input
file}

\item{quiet}{whether to suppress the progress bar and messages}

\item{envir}{the environment in which the code chunks are to be evaluated
(for example, \code{\link{parent.frame}()}, \code{\link{new.env}()}, or
\code{\link{globalenv}()})}

\item{encoding}{the encoding of the input file; see \code{\link{file}}}

\item{...}{arguments passed to \code{\link{knit}()} from \code{purl()}}

\item{documentation}{an integer specifying the level of documentation to go
the tangled script: \code{0} means pure code (discard all text chunks);
\code{1} (default) means add the chunk headers to code; \code{2} means add
all text chunks to code as roxygen comments}
}
\value{
The compiled document is written into the output file, and the path
  of the output file is returned. If the \code{text} argument is not
  \code{NULL}, the compiled output is returned as a character vector. In
  other words, if you provide a file input, you get an output filename; if
  you provide a character vector input, you get a character vector output.
}
\description{
This function takes an input file, extracts the R code in it according to a
list of patterns, evaluates the code and writes the output in another file.
It can also tangle R source code from the input document (\code{purl()} is a
wrapper to \code{knit(..., tangle = TRUE)}). The \code{knitr.purl.inline}
option can be used to also tangle the code of inline expressions (disabled
by default).
}
\details{
For most of the time, it is not necessary to set any options outside the
input document; in other words, a single call like
\code{knit('my_input.Rnw')} is usually enough. This function will try to
determine many internal settings automatically. For the sake of
reproducibility, it is better practice to include the options inside the
input document (to be self-contained), instead of setting them before
knitting the document.

First the filename of the output document is determined in this way:
\file{foo.Rnw} generates \file{foo.tex}, and other filename extensions like
\file{.Rtex}, \file{.Rhtml} (\file{.Rhtm}) and \file{.Rmd}
(\file{.Rmarkdown}) will generate \file{.tex}, \file{.html} and \file{.md}
respectively. For other types of files, if the filename contains
\samp{_knit_}, this part will be removed in the output file, e.g.,
\file{foo_knit_.html} creates the output \file{foo.html}; if \samp{_knit_} is
not found in the filename, \file{foo.ext} will produce \file{foo.txt} if
\code{ext} is not \code{txt}, otherwise the output is \file{foo-out.txt}. If
\code{tangle = TRUE}, \file{foo.ext} generates an R script \file{foo.R}.

We need a set of syntax to identify special markups for R code chunks and R
options, etc. The syntax is defined in a pattern list. All built-in pattern
lists can be found in \code{all_patterns} (call it \code{apat}). First
\pkg{knitr} will try to decide the pattern list based on the filename
extension of the input document, e.g. \samp{Rnw} files use the list
\code{apat$rnw}, \samp{tex} uses the list \code{apat$tex}, \samp{brew} uses
\code{apat$brew} and HTML files use \code{apat$html}; for unkown extensions,
the content of the input document is matched against all pattern lists to
automatically determine which pattern list is being used. You can also manually
set the pattern list using the \code{\link{knit_patterns}} object or the
\code{\link{pat_rnw}} series functions in advance and \pkg{knitr} will
respect the setting.

According to the output format (\code{opts_knit$get('out.format')}), a set of
output hooks will be set to mark up results from R (see
\code{\link{render_latex}}). The output format can be LaTeX, Sweave and HTML,
etc. The output hooks decide how to mark up the results (you can customize
the hooks).

The name \code{knit} comes from its counterpart \samp{weave} (as in Sweave),
and the name \code{purl} (as \samp{tangle} in Stangle) comes from a knitting
method `knit one, purl one'.

If the input document has child documents, they will also be compiled
recursively. See \code{\link{knit_child}}.

See the package website and manuals in the references to know more about
\pkg{knitr}, including the full documentation of chunk options and demos,
etc.
}
\note{
The working directory when evaluating R code chunks is the directory of
  the input document by default, so if the R code involves external files
  (like \code{read.table()}), it is better to put these files under the same
  directory of the input document so that we can use relative paths. However,
  it is possible to change this directory with the package option
  \code{\link{opts_knit}$set(root.dir = ...)} so all paths in code chunks are
  relative to this \code{root.dir}. It is not recommended to change the
  working directory via \code{\link{setwd}()} in a code chunk, because it may
  lead to terrible consequences (e.g. figure and cache files may be written to
  wrong places). If you do use \code{setwd()}, please note that \pkg{knitr}
  will always restore the working directory to the original one. Whenever you
  feel confused, print \code{getwd()} in a code chunk to see what the working
  directory really is.

  The arguments \code{input} and \code{output} do not have to be restricted
  to files; they can be \code{stdin()}/\code{stdout()} or other types of
  connections, but the pattern list to read the input has to be set in
  advance (see \code{\link{pat_rnw}}), and the output hooks should also be
  set (see \code{\link{render_latex}}), otherwise \pkg{knitr} will try to
  guess the patterns and output format.

  If the \code{output} argument is a file path, it is strongly recommended to
  be in the current working directory (e.g. \file{foo.tex} instead of
  \file{somewhere/foo.tex}), especially when the output has external
  dependencies such as figure files. If you want to write the output to a
  different directory, it is recommended to set the working directory to
  that directory before you knit a document. For example, if the source
  document is \file{foo.Rmd} and the expected output is \file{out/foo.md},
  you can write \code{setwd('out/'); knit('../foo.Rmd')} instead of
  \code{knit('foo.Rmd', 'out/foo.md')}.

  N.B. There is no guarantee that the R script generated by \code{purl()} can
  reproduce the computation done in \code{knit()}. The \code{knit()} process
  can be fairly complicated (special values for chunk options, custom chunk
  hooks, computing engines besides R, and the \code{envir} argument, etc). If
  you want to reproduce the computation in a report generated by
  \code{knit()}, be sure to use \code{knit()}, instead of merely executing
  the R script generated by \code{purl()}. This seems to be obvious, but some
  people \href{http://bit.ly/SnLi6h}{just do not get it}.
}
\examples{
library(knitr)
(f = system.file("examples", "knitr-minimal.Rnw", package = "knitr"))
knit(f)  # compile to tex

purl(f)  # tangle R code
purl(f, documentation = 0)  # extract R code only
purl(f, documentation = 2)  # also include documentation
}
\references{
Package homepage: \url{http://yihui.name/knitr/}. The \pkg{knitr}
  \href{http://yihui.name/knitr/demo/manual/}{main manual}: and
  \href{http://yihui.name/knitr/demo/graphics}{graphics manual}.

  See \code{citation('knitr')} for the citation information.
}
