# ===========================================================================
# Derived from: http://www.gnu.org/software/autoconf-archive/ax_check_zlib.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_CHECK_MPFR([action-if-found], [action-if-not-found])
#
# DESCRIPTION
#
#   This macro searches for an installed mpfr library. If nothing was
#   specified when calling configure, it searches first in /usr/local and
#   then in /usr, /opt/local and /sw. If the --with-mpfr=DIR is specified,
#   it will try to find it in DIR/include/mpfr.h and DIR/lib/libmpfr.a. If
#   --without-mpfr is specified, the library is not searched at all.
#
#   If either the header file (mpfr.h) or the library (libmpfr) is not found,
#   shell commands 'action-if-not-found' is run. If 'action-if-not-found' is
#   not specified, the configuration exits on error, asking for a valid mpfr
#   installation directory or --without-mpfr.
#
#   If both header file and library are found, shell commands
#   'action-if-found' is run. If 'action-if-found' is not specified, the
#   default action appends '-I${MPFR_HOME}/include' to CPPFLAGS, appends
#   '-L${MPFR_HOME}/lib' to LDFLAGS, prepends '-lmpfr' to LIBS, and calls
#   AC_DEFINE(HAVE_LIBMPFR). You should use autoheader to include a definition
#   for this symbol in a config.h file. Sample usage in a C/C++ source is as
#   follows:
#
#     #ifdef HAVE_LIBMPFR
#     #include <mpfr.h>
#     #endif /* HAVE_LIBMPFR */
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

AU_ALIAS([CHECK_MPFR], [AX_CHECK_MPFR])
AC_DEFUN([AX_CHECK_MPFR],
#
# Handle user hints
#
[AC_MSG_CHECKING(if mpfr is wanted)
mpfr_places="/usr/local /usr /opt/local /sw"
AC_ARG_WITH([mpfr],
[  --with-mpfr=DIR       root directory path of mpfr installation @<:@defaults to
                         /usr/local or /usr if not found in /usr/local@:>@
  --without-mpfr         to disable mpfr usage completely],
[if test "$withval" != no ; then
  AC_MSG_RESULT(yes)
  if test -d "$withval"
  then
    mpfr_places="$withval $mpfr_places"
  else
    AC_MSG_WARN([Sorry, $withval does not exist, checking usual places])
  fi
else
  mpfr_places=
  AC_MSG_RESULT(no)
fi],
[AC_MSG_RESULT(yes)])

#
# Locate mpfr, if wanted
#
if test -n "${mpfr_places}"
then
	# check the user supplied or any other more or less 'standard' place:
	#   Most UNIX systems      : /usr/local and /usr
	#   MacPorts / Fink on OSX : /opt/local respectively /sw
	for MPFR_HOME in ${mpfr_places} ; do
	  if test -f "${MPFR_HOME}/include/mpfr.h"; then break; fi
	    MPFR_HOME=""
	    done

  MPFR_OLD_LDFLAGS=$LDFLAGS
  MPFR_OLD_CPPFLAGS=$CPPFLAGS
  if test -n "${MPFR_HOME}"; then
        LDFLAGS="$LDFLAGS -L${MPFR_HOME}/lib"
        CPPFLAGS="$CPPFLAGS -I${MPFR_HOME}/include"
  fi
  AC_LANG_SAVE
  AC_LANG_C
  AC_CHECK_LIB([mpfr], [mpfr_init2], [mpfr_cv_mpfrinit=yes], [mpfr_cv_mpfrinit=no])
  AC_CHECK_HEADER([mpfr.h], [mpfr_cv_mpfr_h=yes], [mpfr_cv_mpfr_h=no])
  AC_LANG_RESTORE
  if test "$mpfr_cv_mpfrinit" = "yes" && test "$mpfr_cv_mpfr_h" = "yes"
  then
    #
    # If both library and header were found, action-if-found
    #
    m4_ifblank([$1],[
                CPPFLAGS="$CPPFLAGS -I${MPFR_HOME}/include"
                LDFLAGS="$LDFLAGS -L${MPFR_HOME}/lib"
                LIBS="-lmpfr $LIBS"
                AC_DEFINE([HAVE_LIBMPFR], [1],
                          [Define to 1 if you have `mpfr' library (-lmpfr)])
               ],[
                # Restore variables
                LDFLAGS="$MPFR_OLD_LDFLAGS"
                CPPFLAGS="$MPFR_OLD_CPPFLAGS"
                $1
               ])
  else
    #
    # If either header or library was not found, action-if-not-found
    #
    m4_default([$2],[
                AC_MSG_ERROR([either specify a valid mpfr installation with --with-mpfr=DIR or disable mpfr usage with --without-mpfr])
                ])
  fi
fi
])
