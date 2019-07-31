
#' @title Construct a Byte Pair Encoding model
#' @description Construct a Byte Pair Encoding model on text
#' @param x path to the text file containing training data or a character vector of text with training data
#' @param coverage fraction of characters covered by the model. Must be in the range [0, 1]. A good value to use is about 0.9999
#' @param vocab_size integer indicating the number of tokens in the final vocabulary
#' @param threads integer with number of CPU threads to use for model processing. If equal to -1 then minimum of the number of available threads and 8 will be used
#' @param pad_id integer, reserved id for padding
#' @param unk_id integer, reserved id for unknown symbols
#' @param bos_id integer, reserved id for begin of sentence token
#' @param eos_id integer, reserved id for end of sentence token
#' @param model_path path to the file on disk where the model will be stored. Defaults to 'youtokentome.bpe' in the current working directory
#' @return an object of class \code{youtokentome} which is defined at \code{\link{bpe_load_model}}
#' @seealso \code{\link{bpe_load_model}}
#' @export
#' @examples
#' data(belgium_parliament, package = "tokenizers.bpe")
#' x <- subset(belgium_parliament, language == "french")
#' model <- bpe(x$text, coverage = 0.999, vocab_size = 5000, threads = 1)
#' model
#' str(model$vocabulary)
#'
#' text <- c("L'appartement est grand & vraiment bien situe en plein centre",
#'           "Proportion de femmes dans les situations de famille monoparentale.")
#' bpe_encode(model, x = text, type = "subwords")
#' bpe_encode(model, x = text, type = "ids")
#'
#' encoded <- bpe_encode(model, x = text, type = "ids")
#' decoded <- bpe_decode(model, encoded)
#' decoded
#'
#' ## Remove the model file (Clean up for CRAN)
#' file.remove(model$model_path)
bpe <- function(x,
                coverage = 0.9999, vocab_size = 5000,
                threads = -1L, pad_id = 0L, unk_id = 1L, bos_id = 2L, eos_id = 3L,
                model_path = file.path(getwd(), "youtokentome.bpe")){
  stopifnot(length(x) > 0)
  if(length(x) > 1){
    txtfile <- tempfile(pattern = "traindata", fileext = ".txt")
    on.exit(file.remove(txtfile))
    fcon <- file(txtfile, open = "wt", encoding = "UTF-8")
    cat(x, file = fcon, sep = "\n")
    close(fcon)
  }else{
    txtfile <- path.expand(x)
  }
  stopifnot(file.exists(txtfile))
  threads <- as.integer(threads)
  stopifnot(threads >= -1)
  model_path <- youtokentome_train(txtfile, model_path,
                     coverage, threads, vocab_size, pad_id, unk_id, bos_id, eos_id)
  bpe_load_model(model_path, threads)
}



#' @title Load a Byte Pair Encoding model
#' @description Load a Byte Pair Encoding model trained with \code{\link{bpe}}
#' @param file path to the model
#' @param threads integer with number of CPU threads to use for model processing. If equal to -1 then minimum of the number of available threads and 8 will be used
#' @return an object of class \code{youtokentome} which is a list with elements
#' \enumerate{
#' \item{model: an Rcpp pointer to the model}
#' \item{model_path: the path to the model}
#' \item{threads: the threads argument}
#' \item{vocab_size: the size of the BPE vocabulary}
#' \item{vocabulary: the BPE vocabulary with is a data.frame with columns id and subword}
#' }
#' @export
#' @examples
#' ## Reload a model
#' path  <- system.file(package = "tokenizers.bpe", "extdata", "youtokentome.bpe")
#' model <- bpe_load_model(path)
#'
#' ## Build a model and load it again
#'
#' data(belgium_parliament, package = "tokenizers.bpe")
#' x <- subset(belgium_parliament, language == "french")
#' model <- bpe(x$text, coverage = 0.999, vocab_size = 5000, threads = 1)
#' model <- bpe_load_model(model$model_path, threads = 1)
#'
#' ## Remove the model file (Clean up for CRAN)
#' file.remove(model$model_path)
bpe_load_model <- function(file, threads = -1L){
  stopifnot(file.exists(file))
  threads <- as.integer(threads)
  stopifnot(threads >= -1)
  model <- youtokentome_load_model(file, threads)
  Encoding(model$vocabulary$subword) <- "UTF-8"
  model
}

#' @export
print.youtokentome <- function(x, ...){
  cat("Byte Pair Encoding model trained with YouTokenToMe", sep = "\n")
  cat(sprintf("  size of the vocabulary: %s", x$vocab_size), sep = "\n")
  cat(sprintf("  model stored at: %s", x$model_path), sep = "\n")
}


#' @title Tokenise text alongside a Byte Pair Encoding model
#' @description Tokenise text alongside a Byte Pair Encoding model
#' @param model an object of class \code{youtokentome} as returned by \code{\link{bpe_load_model}}
#' @param x a character vector of text to tokenise
#' @param type a character vector of text to tokenise
#' @param bos logical if set to TRUE then token 'beginning of sentence' will be added
#' @param eos logical if set to TRUE then token 'end of sentence' will be added
#' @param reverse logical if set to TRUE the output sequence of tokens will be reversed
#' @export
#' @examples
#' data(belgium_parliament, package = "tokenizers.bpe")
#' x <- subset(belgium_parliament, language == "french")
#' model <- bpe(x$text, coverage = 0.999, vocab_size = 5000, threads = 1)
#' model
#' str(model$vocabulary)
#'
#' text <- c("L'appartement est grand & vraiment bien situe en plein centre",
#'           "Proportion de femmes dans les situations de famille monoparentale.")
#' bpe_encode(model, x = text, type = "subwords")
#' bpe_encode(model, x = text, type = "ids")
#'
#' encoded <- bpe_encode(model, x = text, type = "ids")
#' decoded <- bpe_decode(model, encoded)
#' decoded
#'
#' ## Remove the model file (Clean up for CRAN)
#' file.remove(model$model_path)
bpe_encode <- function(model, x, type = c("subwords", "ids"), bos = FALSE, eos = FALSE, reverse = FALSE){
  stopifnot(inherits(model, "youtokentome"))
  type <- match.arg(type)
  if(type == "ids"){
    x_encoded <- youtokentome_encode_as_ids(model$model, x, bos, eos, reverse)
  }else if(type == "subwords"){
    x_encoded <- youtokentome_encode_as_subwords(model$model, x, bos, eos, reverse)
    x_encoded <- lapply(x_encoded, FUN=function(x){
      Encoding(x) <- "UTF-8"
      x
    })
  }
  x_encoded
}


#' @title Decode Byte Pair Encoding sequences to text
#' @description Decode a sequence of Byte Pair Encoding ids into text again
#' @param model an object of class \code{youtokentome} as returned by \code{\link{bpe_load_model}}
#' @param x an integer vector of BPE id's
#' @param ... further arguments passed on to youtokentome_encode_as_ids
#' @export
#' @examples
#' data(belgium_parliament, package = "tokenizers.bpe")
#' x <- subset(belgium_parliament, language == "french")
#' model <- bpe(x$text, coverage = 0.999, vocab_size = 5000, threads = 1)
#' model
#' str(model$vocabulary)
#'
#' text <- c("L'appartement est grand & vraiment bien situe en plein centre",
#'           "Proportion de femmes dans les situations de famille monoparentale.")
#' bpe_encode(model, x = text, type = "subwords")
#' bpe_encode(model, x = text, type = "ids")
#'
#' encoded <- bpe_encode(model, x = text, type = "ids")
#' decoded <- bpe_decode(model, encoded)
#' decoded
#'
#' ## Remove the model file (Clean up for CRAN)
#' file.remove(model$model_path)
bpe_decode <- function(model, x, ...){
  stopifnot(inherits(model, "youtokentome"))
  if(is.list(x)){
    return(lapply(x, FUN=function(y, ...) bpe_decode(model, y, ...), ...))
  }
  stopifnot(inherits(x, "integer") | inherits(x, "character"))
  if(inherits(x, "character")){
    x <- youtokentome_encode_as_ids(model$model, x, ...)
  }
  x_decoded <- youtokentome_decode(model$model, x)
  Encoding(x_decoded) <- "UTF-8"
  x_decoded
}
