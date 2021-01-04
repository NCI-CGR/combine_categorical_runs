/*!
  \file cargs.cc
  \brief method implementation for command line argument parser class
  \copyright Released under the MIT License.
  Copyright 2021 Cameron Palmer
*/

#include "combine_categorical_runs/cargs.h"

void combine_categorical_runs::cargs::initialize_options() {
  _desc.add_options()("help,h", "emit this help message")(
      "output-prefix,o",
      boost::program_options::value<std::string>()->default_value("out"),
      "prefix of all output files written by software");
}
