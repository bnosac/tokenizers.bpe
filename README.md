# tokenizers.bpe - R package for Byte Pair Encoding

This repository contains an R package which is an Rcpp wrapper around the YouTokenToMe C++ library

- YouTokenToMe is an unsupervised text tokenizer focused on computational efficiency
- It currently implements fast Byte Pair Encoding (BPE) [[Sennrich et al.](https://www.aclweb.org/anthology/P16-1162)]
- YouTokenToMe is available at https://github.com/VKCOM/YouTokenToMe

## Features

The R package allows you to 

- build a Byte Pair Encoding (BPE) model
- apply the model to encode text
- apply the model to decode ids back to text

Note that YouTokenToMe only works on 64 bit.

## Installation

<!--
- For regular users, install the package from your local CRAN mirror `install.packages("tokenizers.bpe")`
-->
- For installing the development version of this package: `remotes::install_github("bnosac/tokenizers.bpe", INSTALL_opts = "--no-multiarch")`

Look to the vignette and the documentation of the functions

```
help(package = "tokenizers.bpe")
```

## Example

- As an example, let's take some training data containing questions asked in Belgian Parliament in 2017 and focus on French text only.


```{r}
library(tokenizers.bpe)
data(belgium_parliament, package = "tokenizers.bpe")
x <- subset(belgium_parliament, language == "french")
writeLines(text = x$text, con = "traindata.txt")
```

- Train a model on text data and inspect the vocabulary


```{r}
model <- bpe("traindata.txt", coverage = 0.999, vocab_size = 5000)
model
```

```
Byte Pair Encoding model trained with YouTokenToMe
  size of the vocabulary: 5000
  model stored at: C:/Users/Jan/Dropbox/Work/RForgeBNOSAC/BNOSAC/tokenizers.bpe/youtokentome.bpe
```

```{r}
str(model$vocabulary)
```

```
'data.frame':	5000 obs. of  2 variables:
 $ id     : int  0 1 2 3 4 5 6 7 8 9 ...
 $ subword: chr  "<PAD>" "<UNK>" "<BOS>" "<EOS>" ...
```

- Use the model to encode text


```{r}
text <- c("L'appartement est grand & vraiment bien situe en plein centre",
          "Proportion de femmes dans les situations de famille monoparentale.")
bpe_encode(model, x = text, type = "subwords")
```

```
[[1]]
 [1] "▁L'"     "app"     "ar"      "tement"  "▁est"    "▁grand"  "▁"       "&"       "▁vra"    "iment"   "▁bien"   "▁situe"  "▁en"     "▁plein"  "▁centre"

[[2]]
 [1] "▁Pr"         "op"          "or"          "tion"        "▁de"         "▁femmes"     "▁dans"       "▁les"        "▁situations" "▁de"         "▁famille"   
[12] "▁mon"        "op"          "ar"          "ent"         "ale."
```

```{r}
bpe_encode(model, x = text, type = "ids")
```

```
[[1]]
 [1]  443 1832   98  897  171 1225    4    1 4186 3199  747 4548  114 3558 2196

[[2]]
 [1] 2290  199  111   89   78 1711  162  107 2968   78 1877  989  199   98   85 2090
```

- Use the model to decode byte pair encodings back to text


```{r}
x <- bpe_encode(model, x = text, type = "ids")
bpe_decode(model, x)
```

```
[[1]]
[1] "L'appartement est grand <UNK> vraiment bien situe en plein centre"

[[2]]
[1] "Proportion de femmes dans les situations de famille monoparentale."
```

## Support in text mining

Need support in text mining?
Contact BNOSAC: http://www.bnosac.be

