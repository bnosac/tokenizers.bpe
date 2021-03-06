% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/youtokentome.R
\name{bpe_decode}
\alias{bpe_decode}
\title{Decode Byte Pair Encoding sequences to text}
\usage{
bpe_decode(model, x, ...)
}
\arguments{
\item{model}{an object of class \code{youtokentome} as returned by \code{\link{bpe_load_model}}}

\item{x}{an integer vector of BPE id's}

\item{...}{further arguments passed on to youtokentome_encode_as_ids}
}
\description{
Decode a sequence of Byte Pair Encoding ids into text again
}
\examples{
data(belgium_parliament, package = "tokenizers.bpe")
x <- subset(belgium_parliament, language == "french")
model <- bpe(x$text, coverage = 0.999, vocab_size = 5000, threads = 1)
model
str(model$vocabulary)

text <- c("L'appartement est grand & vraiment bien situe en plein centre",
          "Proportion de femmes dans les situations de famille monoparentale.")
bpe_encode(model, x = text, type = "subwords")
bpe_encode(model, x = text, type = "ids")

encoded <- bpe_encode(model, x = text, type = "ids")
decoded <- bpe_decode(model, encoded)
decoded

## Remove the model file (Clean up for CRAN)
file.remove(model$model_path)
}
