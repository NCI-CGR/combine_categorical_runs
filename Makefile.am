bin_PROGRAMS = combine_categorical_runs.out

AM_CXXFLAGS = $(BOOST_CPPFLAGS) -ggdb -Wall -std=c++17

combine_categorical_runs_out_SOURCES = combine_categorical_runs/cargs.cc combine_categorical_runs/cargs.h combine_categorical_runs/main.cc
combine_categorical_runs_out_LDADD = $(BOOST_LDFLAGS) -lmpfr -lgmp -lfinter -lz -lbz2 $(BOOST_PROGRAM_OPTIONS_LIB) $(BOOST_SYSTEM_LIB) $(BOOST_FILESYSTEM_LIB) $(BOOST_IOSTREAMS_LIB)
dist_doc_DATA = README
ACLOCAL_AMFLAGS = -I m4
## TAP support
TEST_LOG_DRIVER = env AM_TAP_AWK='$(AWK)' $(SHELL) \
                  $(top_srcdir)/tap-driver.sh
TESTS = tests/placeholder.test
EXTRA_DIST = $(TESTS)
