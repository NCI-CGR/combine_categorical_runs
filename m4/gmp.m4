# ===========================================================================
# Derived from: http://www.gnu.org/software/autoconf-archive/ax_check_zlib.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_CHECK_GMP([action-if-found], [action-if-not-found])
#
# DESCRIPTION
#
#   This macro searches for an installed gmp library. If nothing was
#   specified when calling configure, it searches first in /usr/local and
#   then in /usr, /opt/local and /sw. If the --with-gmp=DIR is specified,
#   it will try to find it in DIR/include/gmp.h and DIR/lib/libgmp.a. If
#   --without-gmp is specified, the library is not searched at all.
#
#   If either the header file (gmp.h) or the library (libgmp) is not found,
#   shell commands 'action-if-not-found' is run. If 'action-if-not-found' is
#   not specified, the configuration exits on error, asking for a valid gmp
#   installation directory or --without-gmp.
#
#   If both header file and library are found, shell commands
#   'action-if-found' is run. If 'action-if-found' is not specified, the
#   default action appends '-I${GMP_HOME}/include' to CPPFLAGS, appends
#   '-L${GMP_HOME}/lib' to LDFLAGS, prepends '-lgmp' to LIBS, and calls
#   AC_DEFINE(HAVE_LIBGMP). You should use autoheader to include a definition
#   for this symbol in a config.h file. Sample usage in a C/C++ source is as
#   follows:
#
#     #ifdef HAVE_LIBGMP
#     #include <gmp.h>
#     #endif /* HAVE_LIBGMP */
#
# LICENSE
#
#   Copyright (c) 2008 Loic Dachary <loic@senga.org>
#   Copyright (c) 2010 Bastien Chevreux <bach@chevreux.org>
#   Copyright (c) 2021 Cameron Palmer <palmerd@nih.gov>
#
#   This program is free software; you can redistribute it and/or modify it
#   under the terms of the GNU General Public License as published by the
#   Free Software Foundation; either version 2 of the License, or (at your
#   option) any later version.
#
#   This program is distributed in the hope that it will be useful, but
#   WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
#   Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program. If not, see <http://www.gnu.org/licenses/>.
#
#   As a special exception, the respective Autoconf Macro's copyright owner
#   gives unlimited permission to copy, distribute and modify the configure
#   scripts that are the output of Autoconf when processing the Macro. You
#   need not follow the terms of the GNU General Public License when using
#   or distributing such scripts, even though portions of the text of the
#   Macro appear in them. The GNU General Public License (GPL) does govern
#   all other use of the material that constitutes the Autoconf Macro.
#
#   This special exception to the GPL applies to versions of the Autoconf
#   Macro released by the Autoconf Archive. When you make and distribute a
#   modified version of the Autoconf Macro, you may extend this special
#   exception to the GPL to apply to your modified version as well.

#serial 14

AU_ALIAS([CHECK_GMP], [AX_CHECK_GMP])
AC_DEFUN([AX_CHECK_GMP],
#
# Handle user hints
#
[AC_MSG_CHECKING(if gmp is wanted)
gmp_places="/usr/local /usr /opt/local /sw"
AC_ARG_WITH([gmp],
[  --with-gmp=DIR       root directory path of gmp installation @<:@defaults to
                        /usr/local or /usr if not found in /usr/local@:>@
  --without-gmp         to disable gmp usage completely],
[if test "$withval" != no ; then
  AC_MSG_RESULT(yes)
  if test -d "$withval"
  then
    gmp_places="$withval $gmp_places"
  else
    AC_MSG_WARN([Sorry, $withval does not exist, checking usual places])
  fi
else
  gmp_places=
  AC_MSG_RESULT(no)
fi],
[AC_MSG_RESULT(yes)])

#
# Locate gmp, if wanted
#
if test -n "${gmp_places}"
then
	# check the user supplied or any other more or less 'standard' place:
	#   Most UNIX systems      : /usr/local and /usr
	#   MacPorts / Fink on OSX : /opt/local respectively /sw
	for GMP_HOME in ${gmp_places} ; do
	  if test -f "${GMP_HOME}/include/gmp.h"; then break; fi
	    GMP_HOME=""
	    done

  GMP_OLD_LDFLAGS=$LDFLAGS
  GMP_OLD_CPPFLAGS=$CPPFLAGS
  if test -n "${GMP_HOME}"; then
        LDFLAGS="$LDFLAGS -L${GMP_HOME}/lib"
        CPPFLAGS="$CPPFLAGS -I${GMP_HOME}/include"
  fi
  AC_LANG_SAVE
  AC_LANG_C
  AC_CHECK_LIB([gmp], [__gmpz_init], [gmp_cv_gmpz=yes], [gmp_cv_gmpz=no])
  AC_CHECK_HEADER([gmp.h], [gmp_cv_gmp_h=yes], [gmp_cv_gmp_h=no])
  AC_LANG_RESTORE
  if test "$gmp_cv_gmpz" = "yes" && test "$gmp_cv_gmp_h" = "yes"
  then
    #
    # If both library and header were found, action-if-found
    #
    m4_ifblank([$1],[
                CPPFLAGS="$CPPFLAGS -I${GMP_HOME}/include"
                LDFLAGS="$LDFLAGS -L${GMP_HOME}/lib"
                LIBS="-lgmp $LIBS"
                AC_DEFINE([HAVE_LIBGMP], [1],
                          [Define to 1 if you have `gmp' library (-lgmp)])
               ],[
                # Restore variables
                LDFLAGS="$GMP_OLD_LDFLAGS"
                CPPFLAGS="$GMP_OLD_CPPFLAGS"
                $1
               ])
  else
    #
    # If either header or library was not found, action-if-not-found
    #
    m4_default([$2],[
                AC_MSG_ERROR([either specify a valid gmp installation with --with-gmp=DIR or disable gmp usage with --without-gmp])
                ])
  fi
fi
])
