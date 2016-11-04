macro(get_directory out in)
  if (${CMAKE_MAJOR_VERSION} STREQUAL "3")
    get_filename_component(${out} ${in} DIRECTORY)
  else()
    get_filename_component(${out} ${in} PATH)
  endif()
endmacro()

macro(temp_name fname)
  if(${ARGC} GREATER 1) # Have to escape ARGC to correctly compare
    set(_base ${ARGV1})
  else(${ARGC} GREATER 1)
    set(_base ".cmake-tmp")
  endif(${ARGC} GREATER 1)
  set(_counter 0)
  while(EXISTS "${_base}${_counter}")
    math(EXPR _counter "${_counter} + 1")
  endwhile(EXISTS "${_base}${_counter}")
  set(${fname} "${_base}${_counter}")
endmacro(temp_name)

macro(debug var)
  message("${var} : ${${var}}")
endmacro()

macro(stringify var)
  string(REPLACE ";" " " ${var} "${${var}}")
endmacro()
