# tokenizers.bpe - R package for Byte Pair Encoding

This repository contains an R package which is an Rcpp wrapper around the YouTokenToMe C++ library

- YouTokenToMe is an unsupervised text tokenizer focused on computational efficiency (https://github.com/VKCOM/YouTokenToMe)
- It currently implements fast Byte Pair Encoding (BPE) [[Sennrich et al.](https://www.aclweb.org/anthology/P16-1162)].



## Features

Currently the R package allows you to 

- build a Byte Pair Encoding (BPE) model
- apply the model to encode text
- apply the model to decode ids back to text

## Installation

```
install.packages("udpipe")
remotes::install_github("bnosac/tokenizers.bpe")
```

## Example

- As an example, let's take some training data from the udpipe package


```r
library(tokenizers.bpe)
library(udpipe)
data(brussels_reviews, package = "udpipe")
writeLines(text = brussels_reviews$feedback, con = "traindata.txt")
```

- Train a model on text data and inspect the vocabulary


```r
model <- bpe(file = "traindata.txt", coverage = 0.999, vocab_size = 5000)
model
```

```
Byte Pair Encoding model training with YouTokenToMe
  size of the vocabulary: 5000
  model stored at: C:/Users/Jan/Dropbox/Work/RForgeBNOSAC/jwijffels/tokenizers.bpe/youtokentome.bpe
```

```r
str(model$vocabulary)
```

```
'data.frame':	5000 obs. of  2 variables:
 $ id     : int  0 1 2 3 4 5 6 7 8 9 ...
 $ subword: chr  "<PAD>" "<UNK>" "<BOS>" "<EOS>" ...
```

- Use the model to encode text


```r
text <- c("L'appartement est grand & extremement bien situe en plein centre",
          "I visited Brussels as the Belgium beer is great, particularly Westmalle and Orval")
bpe_encode(model, x = text, type = "subwords")
```

```
[[1]]
 [1] "▁L'appartement" "▁est"           "▁grand"         "▁"              "&"              "▁extreme"       "ment"          
 [8] "▁bien"          "▁situe"         "▁en"            "▁plein"         "▁centre"       

[[2]]
 [1] "▁I"       "▁visite"  "d"        "▁Brussel" "s"        "▁as"      "▁the"     "▁Belg"    "i"        "um"       "▁b"      
[12] "eer"      "▁is"      "▁g"       "re"       "at"       ","        "▁parti"   "cul"      "ar"       "l"        "y"       
[23] "▁W"       "est"      "m"        "al"       "le"       "▁and"     "▁O"       "r"        "val"  
```

```r
bpe_encode(model, x = text, type = "ids")
```

```
[[1]]
 [1]  478  139  735    4    1 4539  100  169  381   93 1291  586

[[2]]
 [1]  317 2221   15  310   11 1126 2029 1621   12 1334   90  268  191  106   89  161   24 1999 1613   74   13   26  283  265   17  117   95 1054  407   10 3448
```

- Use the model to decode byte pair encodings back to text


```r
x <- bpe_encode(model, x = text, type = "ids")
bpe_decode(model, x)
```

```
[[1]]
[1] "L'appartement est grand <UNK> extremement bien situe en plein centre"

[[2]]
[1] "I visited Brussels as the Belgium beer is great, particularly Westmalle and Orval"
```

## Support in text mining

Need support in text mining?
Contact BNOSAC: http://www.bnosac.be

