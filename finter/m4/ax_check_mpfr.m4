# =============================================================================
#  Derived from https://www.gnu.org/software/autoconf-archive/ax_boost_program_options.html
# =============================================================================
#
# SYNOPSIS
#
#   AX_CHECK_MPFR
#
# DESCRIPTION
#
#   Test for mpfr (mpfr) library. 
#
#   This macro calls:
#
#     AC_SUBST(MPFR_LIB)
#
#   And sets:
#
#     HAVE_MPFR
#
# LICENSE
#
#   Copyright (c) 2021 Cameron Palmer <palmercd@nih.gov>
#   Copyright (c) 2009 Thomas Porschberg <thomas@randspringer.de>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 26

AC_DEFUN([AX_CHECK_MPFR],
[
	AC_ARG_WITH([mpfr],
		AS_HELP_STRING([--with-mpfr@<:@=special-lib@:>@],
                       [use the mpfr library - it is possible to specify a certain library for the linker
                        e.g. --with-mpfr=mpfr-gcc-mt-1_33_1 ]),
        [
        if test "$withval" = "no"; then
			want_mpfr="no"
        elif test "$withval" = "yes"; then
            want_mpfr="yes"
            ax_mpfr_user_lib=""
        else
		    want_mpfr="yes"
		ax_mpfr_user_lib="$withval"
		fi
        ],
        [want_boost="yes"]
	)

	if test "x$want_mpfr" = "xyes"; then
        AC_REQUIRE([AC_PROG_CC])
	    export want_mpfr
		CPPFLAGS_SAVED="$CPPFLAGS"
		CPPFLAGS="$CPPFLAGS -I/usr/include"
		export CPPFLAGS
		LDFLAGS_SAVED="$LDFLAGS"
		LDFLAGS="$LDFLAGS -L/usr/lib"
		export LDFLAGS
		AC_CACHE_CHECK([whether the mpfr library is available],
					   ax_cv_mpfr,
					   [AC_LANG_PUSH(C++)
				AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[@%:@include <mpfr.h>
                                                          ]],
                                  [[BZFILE *_bz_input = 0;
                                   return 0;]])],
                           ax_cv_mpfr=yes, ax_cv_mpfr=no)
					AC_LANG_POP([C++])
		])
		if test "$ax_cv_mpfr" = yes; then
				AC_DEFINE(HAVE_MPFR,,[define if the mpfr library is available])
                  MPFRLIBDIR="/usr/lib"
                if test "x$ax_mpfr_user_lib" = "x"; then
                for libextension in `ls $MPFRLIBDIR/libmpfr*.so* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^lib\(mpfr.*\)\.so.*$;\1;'` `ls $MPFRLIBDIR/libmpfr*.dylib* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^lib\(mpfr.*\)\.dylib.*$;\1;'` `ls $MPFRLIBDIR/libmpfr*.a* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^lib\(mpfr.*\)\.a.*$;\1;'` ; do
                     ax_lib=${libextension}
				    AC_CHECK_LIB($ax_lib, exit,
                                 [MPFR_LIB="-l$ax_lib"; AC_SUBST(MPFR_LIB) link_mpfr="yes"; break],
                                 [link_mpfr="no"])
				done
                if test "x$link_mpfr" != "xyes"; then
                for libextension in `ls $MPFRLIBDIR/mpfr*.dll* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^\(mpfr.*\)\.dll.*$;\1;'` `ls $MPFRLIBDIR/mpfr*.a* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^\(mpfr.*\)\.a.*$;\1;'` ; do
                     ax_lib=${libextension}
				    AC_CHECK_LIB($ax_lib, exit,
                                 [MPFR_LIB="-l$ax_lib"; AC_SUBST(MPFR_LIB) link_mpfr="yes"; break],
                                 [link_mpfr="no"])
				done
                fi
                else
                  for ax_lib in $ax_mpfr_user_lib mpfr-$ax_mpfr_user_lib; do
				      AC_CHECK_LIB($ax_lib, main,
                                   [MPFR_LIB="-l$ax_lib"; AC_SUBST(MPFR_LIB) link_mpfr="yes"; break],
                                   [link_mpfr="no"])
                  done
                fi
            if test "x$ax_lib" = "x"; then
                AC_MSG_ERROR(Could not find a version of the mpfr library!)
            fi
				if test "x$link_mpfr" != "xyes"; then
					AC_MSG_ERROR([Could not link against [$ax_lib] !])
				fi
		fi
		CPPFLAGS="$CPPFLAGS_SAVED"
	LDFLAGS="$LDFLAGS_SAVED"
	fi
])
