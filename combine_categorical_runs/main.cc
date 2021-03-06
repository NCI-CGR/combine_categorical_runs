/*!
  \file main.cc
  \brief pseudo-metaanalysis categorical subanalyses
  into a single consensus p-value
  \copyright Released under the MIT License.
  Copyright 2020 Cameron Palmer.
 */

// required definition for mpfr in C++
#define MPFR_USE_INTMAX_T 1

#include <algorithm>
#include <cinttypes>
#include <cmath>
#include <cstdarg>
#include <fstream>
#include <iostream>
#include <map>
#include <sstream>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

// this inclusion must come after inttypes and stdarg
#include <mpfr.h>  // NOLINT

#include "finter/finter.h"

template <class value_type>
value_type from_string(const std::string &str) {
  std::istringstream strm1(str);
  value_type res;
  if (!(strm1 >> res))
    throw std::domain_error("cannot convert string to object: \"" + str + "\"");
  return res;
}

template <class value_type>
std::string to_string(const value_type &obj) {
  std::ostringstream o;
  if (!(o << obj)) throw std::domain_error("cannot convert object to string");
  return o.str();
}

unsigned get_comparison_number(const std::string &filename) {
  if (filename.find("comparison") == std::string::npos)
    throw std::domain_error("comparison directory format not recognized: \"" +
                            filename + "\"");
  std::string truncated = filename.substr(filename.rfind("comparison") + 10);
  unsigned res =
      from_string<unsigned>(truncated.substr(0, truncated.find("/")));
  return res;
}

void process_data(
    const std::vector<std::string> &input_filenames,
    const std::string &output_filename,
    const std::map<std::string, unsigned> &consensus_variants,
    const std::vector<
        std::map<std::pair<unsigned, unsigned>,
                 std::map<std::string, std::pair<unsigned, unsigned> > > >
        &combinatorial_file_counts) {
  if (input_filenames.size() < 2)
    throw std::domain_error("process_data: expected at least two input files");
  std::vector<finter::finter_reader *> inputs;
  std::vector<std::string> input_lines, input_ids;
  std::string line = "", catcher = "", target_id = "", a1 = "", a2 = "";
  std::vector<double> input_pvalues, input_betas;
  std::vector<unsigned> comparison_numbers;
  std::vector<std::pair<unsigned, unsigned> > input_n;
  std::map<std::string, unsigned>::const_iterator finder;
  double min_p = 1.0, consensus_p = 0.0;
  unsigned n_valid = 0;
  std::string annotation_source = "";
  inputs.resize(input_filenames.size(), 0);
  input_lines.resize(input_filenames.size(), "");
  input_ids.resize(input_filenames.size(), "");
  input_betas.resize(input_filenames.size(), 0.0);
  input_pvalues.resize(input_filenames.size(), 0.0);
  input_n.resize(input_filenames.size(), std::pair<unsigned, unsigned>(0, 0));
  comparison_numbers.resize(input_filenames.size(), 0);
  finter::finter_writer *output = 0;
  try {
    for (unsigned i = 0; i < input_filenames.size(); ++i) {
      comparison_numbers.at(i) = get_comparison_number(input_filenames.at(i));
    }
    for (unsigned i = 0; i < input_filenames.size(); ++i) {
      inputs.at(i) =
          finter::reconcile_reader(input_filenames.at(i));
    }
    output = finter::reconcile_writer(output_filename);
    for (unsigned i = 0; i < input_filenames.size(); ++i) {
      inputs.at(i)->getline(&line);
    }
    std::ostringstream o_header;
    o_header << "CHR\tPOS\tSNP\tTested_Allele\tOther_Allele\tFreq_Tested_"
                "Allele_in_TOPMed";
    for (unsigned i = 0; i < input_filenames.size(); ++i) {
      o_header << "\tBETA_COMP" << (i + 1);
    }
    for (unsigned i = 0; i < input_filenames.size(); ++i) {
      o_header << "\tP_COMP" << (i + 1);
    }
    o_header << "\tP_CONSENSUS\tN";
    output->writeline(o_header.str());
    while (true) {
      bool updated = false;
      // find out if there's any input data left to process
      for (unsigned i = 0; i < input_lines.size(); ++i) {
        if (input_lines.at(i).empty()) {
          bool local_updated = false;
          while (inputs.at(i)->getline(&input_lines.at(i))) {
            std::istringstream strm1(input_lines.at(i));
            if (!(strm1 >> catcher >> catcher >> input_ids.at(i) >> a1 >> a2))
              throw std::domain_error("insufficient entries for file \"" +
                                      input_filenames.at(i) + "\" line \"" +
                                      input_lines.at(i) + "\"");
            input_ids.at(i) = input_ids.at(i) + ":" + (a1 < a2 ? a1 : a2) +
                              ":" + (a1 < a2 ? a2 : a1);
            if ((finder = consensus_variants.find(input_ids.at(i))) ==
                    consensus_variants.end() ||
                finder->second != inputs.size()) {
              input_lines.at(i) = input_ids.at(i) = "";
              continue;
            }
            local_updated = true;
            if (!(strm1 >> catcher >> input_betas.at(i)))
              throw std::domain_error("insufficient entries for file \"" +
                                      input_filenames.at(i) + "\" line \"" +
                                      input_lines.at(i) + "\"");
            for (unsigned j = 7; j < 8; ++j) strm1 >> catcher;
            if (!(strm1 >> input_pvalues.at(i) >> catcher >> catcher >>
                  input_n.at(i).first >> input_n.at(i).second))
              throw std::domain_error("insufficient entries for file \"" +
                                      input_filenames.at(i) + "\" line \"" +
                                      input_lines.at(i) + "\"");
            break;
          }
          if (!local_updated) continue;
        }
        if (!input_lines.at(i).empty()) {
          updated = true;
          target_id = input_ids.at(i);
        }
      }
      // if nothing is left, the run is complete
      if (!updated) break;
      // for the next id target, combine and report results
      min_p = 1.0;
      n_valid = 0;
      for (unsigned i = 0; i < input_lines.size(); ++i) {
        if (!input_ids.at(i).compare(target_id)) {
          if (input_pvalues.at(i) < min_p) min_p = input_pvalues.at(i);
          ++n_valid;
          if (annotation_source.empty()) annotation_source = input_lines.at(i);
          input_lines.at(i) = "";
        }
      }
      // for the time being, for strange meta-analysis consistency reasons,
      // enforce presence in all input files
      if (n_valid == input_filenames.size()) {
        // output p-value is, evidently, 1 - prod(1 - min(p))
        // just a simple Bonferroni correction

        // precision error! if p is low enough,
        // this math fails with double precision
        if (min_p < 5e-8) {
          // treat individual variants with GWS values carefully.
          // this is way too large by the way! double precision works
          // ok for these. but it eventually breaks down, and GWS
          // as a threshold for different treatment is a thing that
          // is accepted in GWAS

          // use mpfr!
          mpfr_t x, y;
          try {
            mpfr_inits2(256, x, y, (mpfr_ptr)0);
            mpfr_set_d(x, min_p, MPFR_RNDD);
            mpfr_ui_sub(y, 1, x, MPFR_RNDD);
            mpfr_pow_ui(x, y, n_valid, MPFR_RNDD);
            mpfr_ui_sub(y, 1, x, MPFR_RNDD);
            consensus_p = mpfr_get_d(y, MPFR_RNDD);
            mpfr_clears(x, y, (mpfr_ptr)0);
          } catch (...) {
            mpfr_clears(x, y, (mpfr_ptr)0);
            throw;
          }
        } else {
          consensus_p = 1 - pow(1.0 - min_p, n_valid);
        }
        // otherwise report annotation data from first comparison?
        std::istringstream strm2(annotation_source);
        std::ostringstream o;
        for (unsigned i = 0; i < 6; ++i) {
          strm2 >> catcher;
          o << (i ? "\t" : "") << catcher;
        }
        for (unsigned i = 0; i < input_betas.size(); ++i) {
          o << '\t' << input_betas.at(i);
        }
        for (unsigned i = 0; i < input_pvalues.size(); ++i) {
          o << '\t' << input_pvalues.at(i);
        }
        o << '\t' << consensus_p;
        // now, determine the actual sample size
        unsigned unique_sample_size = 0;
        // need to track which datasets have already had data included for any
        // prior comparison
        std::map<std::string, bool> tracked_datasets;
        for (unsigned i = 0; i < input_n.size(); ++i) {
          // get the comparison number from the filename
          unsigned comparison_number =
              get_comparison_number(input_filenames.at(i));
          // find the sample size for this comparison number
          std::map<std::pair<unsigned, unsigned>,
                   std::map<std::string, std::pair<unsigned, unsigned> > >::
              const_iterator comparison_finder =
                  combinatorial_file_counts.at(comparison_number)
                      .find(input_n.at(i));
          if (comparison_finder ==
              combinatorial_file_counts.at(comparison_number).end()) {
            std::ostringstream o_exception;
            o_exception
                << "combinatorial sample size lookup failed: comparison "
                << comparison_number << "; expected " << input_n.at(i).first
                << "/" << input_n.at(i).second << std::endl;
            o_exception << "available:";
            for (std::map<
                     std::pair<unsigned, unsigned>,
                     std::map<std::string, std::pair<unsigned, unsigned> > >::
                     const_iterator except_iter =
                         combinatorial_file_counts.at(comparison_number)
                             .begin();
                 except_iter !=
                 combinatorial_file_counts.at(comparison_number).end();
                 ++except_iter) {
              o_exception << ' ' << except_iter->first.first << '/'
                          << except_iter->first.second;
            }
            throw std::runtime_error(o_exception.str());
          }
          // look at each constituent dataset. if it's not already present, add
          // the whole number; otherwise only add the nonreference subjects
          for (std::map<std::string,
                        std::pair<unsigned, unsigned> >::const_iterator
                   subset_iter = comparison_finder->second.begin();
               subset_iter != comparison_finder->second.end(); ++subset_iter) {
            if (tracked_datasets.find(subset_iter->first) !=
                tracked_datasets.end()) {
              unique_sample_size += subset_iter->second.second;
            } else {
              tracked_datasets[subset_iter->first] = true;
              unique_sample_size += subset_iter->second.first;
            }
          }
        }
        o << '\t' << unique_sample_size;
        output->writeline(o.str());
      }
      annotation_source = "";
      target_id = "";
    }
    for (unsigned i = 0; i < inputs.size(); ++i) {
      inputs.at(i)->close();
      delete inputs.at(i);
      inputs.at(i) = 0;
    }
    output->close();
    delete output;
    output = 0;
  } catch (...) {
    for (std::vector<finter::finter_reader *>::iterator iter =
             inputs.begin();
         iter != inputs.end(); ++iter) {
      if (*iter) delete *iter;
    }
    if (output) delete output;
    throw;
  }
}

void find_consensus_variants(const std::string &filename,
                             std::map<std::string, unsigned> *target) {
  if (!target) throw std::domain_error("find_consensus_variants: null pointer");
  finter::finter_reader *input = 0;
  std::map<std::string, unsigned>::iterator finder;
  std::string line = "", id = "", catcher = "", a1 = "", a2 = "";
  try {
    input = finter::reconcile_reader(filename);
    input->getline(&line);
    while (input->getline(&line)) {
      std::istringstream strm1(line);
      if (!(strm1 >> catcher >> catcher >> id >> a1 >> a2))
        throw std::domain_error("cannot parse file \"" + filename +
                                "\" line \"" + line + "\"");
      id = id + ":" + (a1 < a2 ? a1 : a2) + ":" + (a1 < a2 ? a2 : a1);
      if ((finder = target->find(id)) == target->end()) {
        finder = target->insert(std::make_pair(id, 0)).first;
      }
      ++finder->second;
    }
    input->close();
    delete input;
    input = 0;
  } catch (...) {
    if (input) delete input;
    throw;
  }
}

void compute_combinatorial_uniques(
    const std::vector<std::string> &model_matrix_filenames,
    std::vector<
        std::map<std::pair<unsigned, unsigned>,
                 std::map<std::string, std::pair<unsigned, unsigned> > > >
        &res) {
  std::string line = "", fid = "", iid = "";
  unsigned pheno = 0;
  // for each filename, determine what comparison is being considered
  std::vector<unsigned> comparisons_by_filename(model_matrix_filenames.size(),
                                                0);
  unsigned max_comparison = 0;
  for (unsigned i = 0; i < model_matrix_filenames.size(); ++i) {
    comparisons_by_filename.at(i) =
        get_comparison_number(model_matrix_filenames.at(i));
    if (max_comparison < comparisons_by_filename.at(i))
      max_comparison = comparisons_by_filename.at(i);
  }
  // for each filename within each comparison, count up the total number of
  // subjects and the total number of alternate condition subjects
  std::vector<std::map<std::string, std::pair<unsigned, unsigned> > >
      subjects_by_file;
  subjects_by_file.resize(max_comparison + 1);
  res.clear();
  res.resize(max_comparison + 1);
  for (unsigned i = 0; i < model_matrix_filenames.size(); ++i) {
    finter::finter_reader *input = 0;
    try {
      input = finter::reconcile_reader(
          model_matrix_filenames.at(i));
      input->getline(&line);
      unsigned n_total = 0, n_alternate = 0;
      while (input->getline(&line)) {
        std::istringstream strm1(line);
        if (!(strm1 >> fid >> iid >> pheno))
          throw std::domain_error("cannot parse file \"" +
                                  model_matrix_filenames.at(i) + "\" line \"" +
                                  line + "\"");
        if (pheno == 1) {
          ++n_alternate;
        }
        ++n_total;
      }
      input->close();
      delete input;
      input = 0;
      subjects_by_file.at(
          comparisons_by_filename.at(i))[model_matrix_filenames.at(i)] =
          std::make_pair(n_total, n_alternate);
    } catch (...) {
      if (input) delete input;
      throw;
    }
  }
  // for each comparison group
  for (unsigned comp = 1; comp < subjects_by_file.size(); ++comp) {
    // for each non-empty combination of files within that comparison group
    for (unsigned i = 1;
         i <
         static_cast<unsigned>(pow(2, subjects_by_file.at(comp).size()) + 0.5);
         ++i) {
      std::map<std::string, std::pair<unsigned, unsigned> > alternate_lookup;
      unsigned map_count = 0, running_total_cases = 0,
               running_total_controls = 0;
      for (std::map<std::string, std::pair<unsigned, unsigned> >::const_iterator
               iter = subjects_by_file.at(comp).begin();
           iter != subjects_by_file.at(comp).end(); ++iter, ++map_count) {
        // add this file's totals to the running totals if required for this
        // combination
        if (i & (1 << map_count)) {
          running_total_cases += iter->second.second;
          running_total_controls += iter->second.first - iter->second.second;
          alternate_lookup[iter->first.substr(iter->first.rfind("/") + 1)] =
              iter->second;
        }
      }
      // this solution regrettably assumes there will not be random collisions
      // in total subject counts between different combinations at least the
      // assumption is detectable when wrong
      if (res.at(comp).find(
              std::make_pair(running_total_cases, running_total_controls)) !=
          res.at(comp).end()) {
        std::ostringstream o_exception;
        o_exception << "hackjob sample size resolution failed due to "
                       "coincidental collision of total sample sizes: size is "
                    << running_total_cases << " cases and "
                    << running_total_controls << " controls" << std::endl;
        o_exception << "previously stored values are:";
        for (std::map<std::pair<unsigned, unsigned>,
                      std::map<std::string, std::pair<unsigned, unsigned> > >::
                 const_iterator except_iter = res.at(comp).begin();
             except_iter != res.at(comp).end(); ++except_iter) {
          o_exception << ' ' << except_iter->first.first << '/'
                      << except_iter->first.second;
        }
        throw std::runtime_error(o_exception.str());
      }
      res.at(
          comp)[std::make_pair(running_total_cases, running_total_controls)] =
          alternate_lookup;
    }
  }
}

bool comparison_name_sort(const std::string &filename1,
                          const std::string &filename2) {
  unsigned comp1 = get_comparison_number(filename1);
  unsigned comp2 = get_comparison_number(filename2);
  return comp1 < comp2;
}

int main(int argc, char **argv) {
  if (argc < 4)
    throw std::domain_error("usage: \"" + std::string(argv[0]) +
                            " [multiple input files] [corresponding model "
                            "matrix files] output_filename\"");
  if (argc == 4)
    throw std::domain_error(
        "this was supposed to only be used with more than one input file, "
        "there's likely a Make logic error");
  if (argc % 2 == 1) {
    throw std::domain_error(
        "there probably shouldn't be an odd number of command line arguments "
        "to this software, check that?");
  }
  std::vector<std::string> input_filenames, model_matrix_filenames;
  for (int i = 1; i < argc - 1; ++i) {
    std::string input_filename = std::string(argv[i]);
    if (input_filename.rfind("model_matrix") == input_filename.size() - 12) {
      model_matrix_filenames.push_back(input_filename);
    } else {
      input_filenames.push_back(input_filename);
    }
  }
  // sort the input files to get the comparisons in the right order in the end
  std::sort(input_filenames.begin(), input_filenames.end(),
            comparison_name_sort);
  std::vector<std::map<std::pair<unsigned, unsigned>,
                       std::map<std::string, std::pair<unsigned, unsigned> > > >
      combinatorial_file_counts;
  std::cout << "computing combinatorial unique sample counts for sample size "
               "reporting"
            << std::endl;
  compute_combinatorial_uniques(model_matrix_filenames,
                                combinatorial_file_counts);
  std::string output_filename = std::string(argv[argc - 1]);
  // do a first pass to find consensus set of variants present in all conditions
  std::cout << "beginning preprocessing for consensus variant list"
            << std::endl;
  std::map<std::string, unsigned> consensus_variants;
  for (unsigned i = 0; i < input_filenames.size(); ++i) {
    find_consensus_variants(input_filenames.at(i), &consensus_variants);
  }
  unsigned complete_count = 0;
  for (std::map<std::string, unsigned>::const_iterator iter =
           consensus_variants.begin();
       iter != consensus_variants.end(); ++iter) {
    if (iter->second == input_filenames.size()) ++complete_count;
  }
  std::cout << "\tfound " << complete_count << " variants present in all files"
            << std::endl;
  std::cout << "beginning streamed processing of data" << std::endl;
  process_data(input_filenames, output_filename, consensus_variants,
               combinatorial_file_counts);
  std::cout << "all done: " << output_filename << std::endl;
  return 0;
}
