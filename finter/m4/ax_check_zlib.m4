# =============================================================================
#  Derived from https://www.gnu.org/software/autoconf-archive/ax_boost_program_options.html
# =============================================================================
#
# SYNOPSIS
#
#   AX_CHECK_ZLIB
#
# DESCRIPTION
#
#   Test for zlib (z) library. 
#
#   This macro calls:
#
#     AC_SUBST(ZLIB_LIB)
#
#   And sets:
#
#     HAVE_ZLIB
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

AC_DEFUN([AX_CHECK_ZLIB],
[
	AC_ARG_WITH([zlib],
		AS_HELP_STRING([--with-zlib@<:@=special-lib@:>@],
                       [use the zlib library - it is possible to specify a certain library for the linker
                        e.g. --with-zlib=zlib-gcc-mt-1_33_1 ]),
        [
        if test "$withval" = "no"; then
			want_zlib="no"
        elif test "$withval" = "yes"; then
            want_zlib="yes"
            ax_zlib_user_lib=""
        else
		    want_zlib="yes"
		ax_zlib_user_lib="$withval"
		fi
        ],
        [want_boost="yes"]
	)

	if test "x$want_zlib" = "xyes"; then
        AC_REQUIRE([AC_PROG_CC])
	    export want_zlib
		CPPFLAGS_SAVED="$CPPFLAGS"
		CPPFLAGS="$CPPFLAGS $BOOST_CPPFLAGS"
		export CPPFLAGS
		LDFLAGS_SAVED="$LDFLAGS"
		LDFLAGS="$LDFLAGS $BOOST_LDFLAGS"
		export LDFLAGS
		AC_CACHE_CHECK([whether the zlib library is available],
					   ax_cv_zlib,
					   [AC_LANG_PUSH(C++)
				AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[@%:@include <zlib.h>
                                                          ]],
                                  [[gzFile _gz_input = 0;
                                   return 0;]])],
                           ax_cv_zlib=yes, ax_cv_zlib=no)
					AC_LANG_POP([C++])
		])
		if test "$ax_cv_zlib" = yes; then
				AC_DEFINE(HAVE_ZLIB,,[define if the zlib library is available])
                  ZLIBLIBDIR=`echo $BOOST_LDFLAGS | sed -e 's/@<:@^\/@:>@*//'`
                if test "x$ax_zlib_user_lib" = "x"; then
                for libextension in `ls $ZLIBLIBDIR/libz*.so* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^lib\(z.*\)\.so.*$;\1;'` `ls $ZLIBLIBDIR/libz*.dylib* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^lib\(z.*\)\.dylib.*$;\1;'` `ls $ZLIBLIBDIR/libz*.a* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^lib\(z.*\)\.a.*$;\1;'` ; do
                     ax_lib=${libextension}
				    AC_CHECK_LIB($ax_lib, exit,
                                 [ZLIB_LIB="-l$ax_lib"; AC_SUBST(ZLIB_LIB) link_zlib="yes"; break],
                                 [link_zlib="no"])
				done
                if test "x$link_zlib" != "xyes"; then
                for libextension in `ls $ZLIBLIBDIR/zlib*.dll* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^\(zlib.*\)\.dll.*$;\1;'` `ls $ZLIBLIBDIR/zlib*.a* 2>/dev/null | sed 's,.*/,,' | sed -e 's;^\(zlib.*\)\.a.*$;\1;'` ; do
                     ax_lib=${libextension}
				    AC_CHECK_LIB($ax_lib, exit,
                                 [ZLIB_LIB="-l$ax_lib"; AC_SUBST(ZLIB_LIB) link_zlib="yes"; break],
                                 [link_zlib="no"])
				done
                fi
                else
                  for ax_lib in $ax_zlib_user_lib zlib-$ax_zlib_user_lib; do
				      AC_CHECK_LIB($ax_lib, main,
                                   [ZLIB_LIB="-l$ax_lib"; AC_SUBST(ZLIB_LIB) link_zlib="yes"; break],
                                   [link_zlib="no"])
                  done
                fi
            if test "x$ax_lib" = "x"; then
                AC_MSG_ERROR(Could not find a version of the zlib library!)
            fi
				if test "x$link_zlib" != "xyes"; then
					AC_MSG_ERROR([Could not link against [$ax_lib] !])
				fi
		fi
		CPPFLAGS="$CPPFLAGS_SAVED"
	LDFLAGS="$LDFLAGS_SAVED"
	fi
])
