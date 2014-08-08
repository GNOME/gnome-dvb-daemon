## this one is commonly used with AM_PATH_PYTHONDIR ...
dnl AM_CHECK_PYMOD(MODNAME [,SYMBOL [,ACTION-IF-FOUND [,ACTION-IF-NOT-FOUND]]])
dnl Check if a module containing a given symbol is visible to python.
AC_DEFUN([AM_CHECK_PYMOD],
[AC_REQUIRE([AM_PATH_PYTHON])
py_mod_var=`echo $1['_']$2 | sed 'y%./+-%__p_%'`
AC_MSG_CHECKING(for ifelse([$2],[],,[$2 in ])python module $1)
AC_CACHE_VAL(py_cv_mod_$py_mod_var, [
ifelse([$2],[], [prog="
import sys
try:
        import $1
except ImportError:
        sys.exit(1)
except:
        sys.exit(0)
sys.exit(0)"], [prog="
import $1
$1.$2"])
if $PYTHON -c "$prog" 1>&AC_FD_CC 2>&AC_FD_CC
  then
    eval "py_cv_mod_$py_mod_var=yes"
  else
    eval "py_cv_mod_$py_mod_var=no"
  fi
])
py_val=`eval "echo \`echo '$py_cv_mod_'$py_mod_var\`"`
if test "x$py_val" != xno; then
  AC_MSG_RESULT(yes)
  ifelse([$3], [],, [$3
])dnl
else
  AC_MSG_RESULT(no)
  ifelse([$4], [],, [$4
])dnl
fi
])

dnl a macro to check for ability to create python extensions
dnl  AM_CHECK_PYTHON_HEADERS([ACTION-IF-POSSIBLE], [ACTION-IF-NOT-POSSIBLE])
dnl function also defines PYTHON_INCLUDES
AC_DEFUN([AM_CHECK_PYTHON_HEADERS],
[AC_REQUIRE([AM_PATH_PYTHON])
AC_MSG_CHECKING(for headers required to compile python extensions)
dnl deduce PYTHON_INCLUDES
if test "x$PYTHON_INCLUDES" = x; then
  PYTHON_CONFIG=`which $PYTHON`-config
  if test -x "$PYTHON_CONFIG"; then
    PYTHON_INCLUDES=`$PYTHON_CONFIG --includes 2>/dev/null`
  else
    PYTHON_INCLUDES=`$PYTHON -c "import distutils.sysconfig, sys; sys.stdout.write(distutils.sysconfig.get_python_inc(True))"`
    PYTHON_INCLUDES="-I$PYTHON_INCLUDES"
  fi
fi
AC_SUBST(PYTHON_INCLUDES)
dnl check if the headers exist:
save_CPPFLAGS="$CPPFLAGS"
CPPFLAGS="$CPPFLAGS $PYTHON_INCLUDES"
AC_TRY_CPP([#include <Python.h>],dnl
[AC_MSG_RESULT(found)
$1],dnl
[AC_MSG_RESULT(not found)
$2])
CPPFLAGS="$save_CPPFLAGS"
])

dnl a macro to check for ability to embed python
dnl  AM_CHECK_PYTHON_LIBS([ACTION-IF-POSSIBLE], [ACTION-IF-NOT-POSSIBLE])
dnl function also defines PYTHON_LIBS
AC_DEFUN([AM_CHECK_PYTHON_LIBS],
[AC_REQUIRE([AM_PATH_PYTHON])
AC_MSG_CHECKING(for libraries required to embed python)
dnl deduce PYTHON_LIBS
py_prefix=`$PYTHON -c "import sys; sys.stdout.write(sys.prefix)"`
if test "x$PYTHON_LIBS" = x; then
  PYTHON_CONFIG=`which $PYTHON`-config
  if test -x "$PYTHON_CONFIG"; then
    PYTHON_LIBS=`$PYTHON_CONFIG --ldflags 2>/dev/null`
  else
    PYTHON_LIBS="-L${py_prefix}/lib -lpython${PYTHON_VERSION}"
  fi
fi
if test "x$PYTHON_LIB_LOC" = x; then
	PYTHON_LIB_LOC="${py_prefix}/lib"
fi
AC_SUBST(PYTHON_LIBS)
AC_SUBST(PYTHON_LIB_LOC)
dnl check if the headers exist:
save_LIBS="$LIBS"
LIBS="$LIBS $PYTHON_LIBS"
AC_TRY_LINK_FUNC(Py_Initialize, dnl
         [LIBS="$save_LIBS"; AC_MSG_RESULT(yes); $1], dnl
         [LIBS="$save_LIBS"; AC_MSG_RESULT(no); $2])

])
