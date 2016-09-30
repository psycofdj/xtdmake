# Evaluate expression
# Suggestion from the Wiki: http://cmake.org/Wiki/CMake/Language_Syntax
# Unfortunately, no built-in stuff for this: http://public.kitware.com/Bug/view.php?id=4034
macro(eval var expr)
  temp_name(_fname)
  file(WRITE ${_fname} "set(${var} ${expr})")
  include(${_fname})
  file(REMOVE ${_fname})
endmacro(eval)
