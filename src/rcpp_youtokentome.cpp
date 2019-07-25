#include <Rcpp.h>
#include <memory>
#include "bpe.h"
#include "utils.h"

// [[Rcpp::export]]
std::string youtokentome_train(const std::string& input_path,
                               const std::string& model_path,
                               double coverage,
                               int threads = -1,
                               int vocab_size = 30000,
                               int pad_id = 0,
                               int unk_id = 1,
                               int bos_id = 2,
                               int eos_id = 3) {
  vkcom::SpecialTokens special = vkcom::SpecialTokens(pad_id, unk_id, bos_id, eos_id);
  vkcom::BpeConfig config      = vkcom::BpeConfig(coverage, threads, special);
  vkcom::train_bpe(input_path, model_path, vocab_size, config);
  return model_path;
}


// [[Rcpp::export]]
Rcpp::List youtokentome_load_model(const std::string& model_path, int threads = -1) {

  // Create the Byte-Pair-Encoder
  Rcpp::XPtr<vkcom::BaseEncoder> bytepair_encoder(new vkcom::BaseEncoder(model_path, threads), true);

  // Extract the vocabulary
  int n = bytepair_encoder->vocab_size();
  std::vector<std::string> subwords;
  std::vector<int32_t> subwords_id;
  for (int i = 0; i < n; i++) {
    subwords.push_back(bytepair_encoder->id_to_subword(i));
    subwords_id.push_back(i);
  }

  // Return vocabulary and a pointer to model
  Rcpp::List output = Rcpp::List::create(
    Rcpp::Named("model") = bytepair_encoder,
    Rcpp::Named("model_path") = model_path,
    Rcpp::Named("threads") = threads,
    Rcpp::Named("vocab_size") = n,
    Rcpp::Named("vocabulary") = Rcpp::DataFrame::create(
      Rcpp::Named("id") = subwords_id,
      Rcpp::Named("subword") = subwords,
      Rcpp::Named("stringsAsFactors") = false));
  output.attr("class") = "youtokentome";
  return output;
}


// [[Rcpp::export]]
std::vector<std::vector<int>> youtokentome_encode_as_ids(SEXP model, const std::vector<std::string>& x,
                                                         bool bos = false, bool eos = false, bool reverse = false) {
  Rcpp::XPtr<vkcom::BaseEncoder> bytepair_encoder(model);
  std::vector<std::vector<int>> x_encoded;
  x_encoded = bytepair_encoder->encode_as_ids(x, bos, eos, reverse);
  return x_encoded;
}

// [[Rcpp::export]]
std::vector<std::vector<std::string>> youtokentome_encode_as_subwords(SEXP model, const std::vector<std::string>& x,
                                                                      bool bos = false, bool eos = false, bool reverse = false) {
  Rcpp::XPtr<vkcom::BaseEncoder> bytepair_encoder(model);
  std::vector<std::vector<std::string>> x_encoded;
  x_encoded = bytepair_encoder->encode_as_subwords(x, bos, eos, reverse);
  return x_encoded;
}

// [[Rcpp::export]]
std::string youtokentome_decode(SEXP model, const std::vector<int>& x) {
  Rcpp::XPtr<vkcom::BaseEncoder> bytepair_encoder(model);
  return bytepair_encoder->decode(x);
}



// [[Rcpp::export]]
std::vector<std::string> youtokentome_recode_id_to_subword(SEXP model, Rcpp::IntegerVector x) {
  Rcpp::XPtr<vkcom::BaseEncoder> bytepair_encoder(model);
  std::vector<std::string> result(x.size());
  for (int i = 0; i < x.size(); i++){
    result[i] = bytepair_encoder->id_to_subword(x[i]);
  }
  return result;
}


// [[Rcpp::export]]
std::vector<int> youtokentome_recode_subword_to_id(SEXP model, Rcpp::StringVector x) {
  Rcpp::XPtr<vkcom::BaseEncoder> bytepair_encoder(model);
  std::vector<int> result(x.size());
  std::string subword;
  for (int i = 0; i < x.size(); i++){
    subword = Rcpp::as<std::string>(x[i]);
    result[i] = bytepair_encoder->subword_to_id(subword);
  }
  return result;
}

