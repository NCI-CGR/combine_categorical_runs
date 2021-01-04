
SUBDIRS = finter

bin_PROGRAMS = combine_categorical_runs.out

AM_CXXFLAGS = -I$(srcdir)/finter -I$(srcdir)/finter/include $(BOOST_CPPFLAGS) -ggdb -Wall -std=c++17

combine_categorical_runs_out_SOURCES = combine_categorical_runs/cargs.cc combine_categorical_runs/cargs.h combine_categorical_runs/main.cc
combine_categorical_runs_out_LDADD = $(BOOST_LDFLAGS) finter/lib/libfinter.la -lboost_program_options -lboost_system -lboost_filesystem -lboost_iostreams
dist_doc_DATA = README
ACLOCAL_AMFLAGS = -I m4
## TAP support
TEST_LOG_DRIVER = env AM_TAP_AWK='$(AWK)' $(SHELL) \
                  $(top_srcdir)/tap-driver.sh
TESTS = tests/placeholder.test
EXTRA_DIST = $(TESTS)
