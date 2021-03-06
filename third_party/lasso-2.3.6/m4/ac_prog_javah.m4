##### http://autoconf-archive.cryp.to/ac_prog_javah.html
#
# SYNOPSIS
#
#   AC_PROG_JAVAH
#
# DESCRIPTION
#
#   AC_PROG_JAVAH tests the availability of the javah header generator
#   and looks for the jni.h header file. If available, JAVAH is set to
#   the full path of javah and CPPFLAGS is updated accordingly.
#
# LAST MODIFICATION
#
#   2002-03-25
#
# COPYLEFT
#
#   Copyright (c) 2002 Luc Maisonobe <luc@spaceroots.org>
#
#   Copying and distribution of this file, with or without
#   modification, are permitted in any medium without royalty provided
#   the copyright notice and this notice are preserved.

AC_DEFUN([AC_PROG_JAVAH],[
AC_REQUIRE([AC_CANONICAL_SYSTEM])dnl
AC_REQUIRE([AC_PROG_CPP])dnl
test "x$JAVAH" = x && AC_CHECK_PROGS(JAVAH,gjavah gcjh javah)
if test "x$JAVAH" != x ; then
  AC_TRY_CPP([#include <jni.h>],,[
    ac_save_CPPFLAGS="$CPPFLAGS"
changequote(, )dnl
    ac_dir=`echo $ac_cv_path_JAVAH | sed 's,\(.*\)/[^/]*/[^/]*$,\1/include,'`
    ac_machdep=`echo $build_os | sed 's,[-0-9].*,,' | sed 's,cygwin,win32,'`
changequote([, ])dnl
    CPPFLAGS="$ac_save_CPPFLAGS -I$ac_dir -I$ac_dir/$ac_machdep"
    AC_TRY_CPP([#include <jni.h>],
               ac_save_CPPFLAGS="$CPPFLAGS",
               AC_MSG_WARN([unable to include <jni.h>]))
    CPPFLAGS="$ac_save_CPPFLAGS"])
else
true
fi])
