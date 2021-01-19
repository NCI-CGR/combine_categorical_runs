# =============================================================================
#  Derived from https://www.gnu.org/software/autoconf-archive/ax_boost_program_options.html
# =============================================================================
#
# SYNOPSIS
#
#   AX_CHECK_GMP
#
# DESCRIPTION
#
#   Test for gmp (gmp) library. 
#
#   This macro calls:
#
#     AC_SUBST(GMP_LIB)
#
#   And sets:
#
#     HAVE_GMP
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

AC_DEFUN([AX_CHECK_GMP],
[
	AC_ARG_WITH([gmp],
		AS_HELP_STRING([--with-gmp@<:@=special-lib@:>@],
                       [use the gmp library - it is possible to specify a certain library for the linker
                        e.g. --with-gmp=gmp-gcc-mt-1_33_1 ]),
        [
        if test "$withval" = "no"; then
			want_gmp="no"
        elif test "$withval" = "yes"; then
            want_gmp="yes"
            ax_gmp_user_lib=""
        else
		    want_gmp="yes"
		ax_gmp_user_lib="$withval"
		fi
        ],
        [want_boost="yes"]
	)

	if test "x$want_gmp" = "xyes"; then
        AC_REQUIRE([AC_PROG_CC])
	    export want_gmp
		CPPFLAGS_SAVED="$CPPFLAGS"
		CPPFLAGS="$CPPFLAGS -I/usr/include"
		export CPPFLAGS
		LDFLAGS_SAVED="$LDFLAGS"
		LDFLAGS="$LDFLAGS -L/usr/lib"
		export LDFLAGS
		AC_CACHE_CHECK([whether the gmp library is available],
					   ax_cv_gmp,
					   [AC_LANG_PUSH(C++)
				AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[@%:@include <gmp.h>
                                                          ]],
                                  [[mpz_t sum;;
                                   return 0;]])],
                           ax_cv_gmp=yes, ax_cv_gmp=no)
					AC_LANG_POP([C++])
		])
		if test "$ax_cv_gmp" = yes; then
				AC_DEFINE(HAVE_GMP,,[define if the gmp library is available])
                  GMPLIBDIR="/usr/lib"
                if test "x$ax_gmp_user_lib" = "x"; then
                for libextension in `ls $GMPLIBDIR/libgmp*.so* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^lib\(gmp.*\)\.so.*$;\1;'` `ls $GMPLIBDIR/libgmp*.dylib* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^lib\(gmp.*\)\.dylib.*$;\1;'` `ls $GMPLIBDIR/libgmp*.a* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^lib\(gmp.*\)\.a.*$;\1;'` ; do
                     ax_lib=${libextension}
				    AC_CHECK_LIB($ax_lib, exit,
                                 [GMP_LIB="-l$ax_lib"; AC_SUBST(GMP_LIB) link_gmp="yes"; break],
                                 [link_gmp="no"])
				done
                if test "x$link_gmp" != "xyes"; then
                for libextension in `ls $GMPLIBDIR/gmp*.dll* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^\(gmp.*\)\.dll.*$;\1;'` `ls $GMPLIBDIR/gmp*.a* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^\(gmp.*\)\.a.*$;\1;'` ; do
                     ax_lib=${libextension}
				    AC_CHECK_LIB($ax_lib, exit,
                                 [GMP_LIB="-l$ax_lib"; AC_SUBST(GMP_LIB) link_gmp="yes"; break],
                                 [link_gmp="no"])
				done
                fi
                else
                  for ax_lib in $ax_gmp_user_lib gmp-$ax_gmp_user_lib; do
				      AC_CHECK_LIB($ax_lib, main,
                                   [GMP_LIB="-l$ax_lib"; AC_SUBST(GMP_LIB) link_gmp="yes"; break],
                                   [link_gmp="no"])
                  done
                fi
            if test "x$ax_lib" = "x"; then
                AC_MSG_ERROR(Could not find a version of the gmp library!)
            fi
				if test "x$link_gmp" != "xyes"; then
					AC_MSG_ERROR([Could not link against [$ax_lib] !])
				fi
		fi
		CPPFLAGS="$CPPFLAGS_SAVED"
	LDFLAGS="$LDFLAGS_SAVED"
	fi
])
