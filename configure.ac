#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT(combine_categorical_runs, 1.1.0, palmercd@nih.gov)
AC_CONFIG_AUX_DIR([.])
AM_INIT_AUTOMAKE([-Wall -Werror subdir-objects])
AM_SILENT_RULES([yes])
AM_PROG_AR
LT_INIT
AC_CONFIG_SRCDIR([combine_categorical_runs/main.cc])
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_HEADERS([temp_config.h])
AX_PREFIX_CONFIG_H([combine_categorical_runs/config.h])

# Checks for programs.
AC_LANG([C++])
AC_PROG_CXX
AC_PROG_INSTALL
AC_PROG_MAKE_SET
AC_CHECK_PROGS([INSTALL_INFO], [install-info])
AC_CHECK_PROGS([MAKEINFO], [makeinfo])
AC_CHECK_PROGS([TEXI2PDF], [texi2pdf])
AC_CHECK_PROGS([TEXI2DVI], [texi2dvi])
AC_PROG_CXX_C_O

#AC_ARG_ENABLE([threads], [AS_HELP_STRING([--disable-threads],
#		       [disable hyperthreading support (default=no)])],
#		       [],
#		       [AX_PTHREAD])
#AS_IF([test "x$ac_disable_threads" != xyes],
#	    [AX_PTHREAD]) #([CFLAGS=$CFLAGS $PTHREAD_CFLAGS])
#fi

#AX_CXX_COMPILE_STDCXX_11([ext], [optional])

# Checks for libraries.
AX_BOOST_BASE([1.63.0])
AX_BOOST_FILESYSTEM
AX_BOOST_PROGRAM_OPTIONS
AX_BOOST_IOSTREAMS
AX_CHECK_ZLIB
AX_CHECK_BZIP2

AC_CHECK_LIB([m],[cos])
# having issues in build, so using hacked AX test functions
AX_CHECK_GMP
AX_CHECK_MPFR

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([
 Makefile
 combine_categorical_runs-1.1.0.pc
])
AC_OUTPUT
