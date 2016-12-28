macro(xtdmake_find_python_module var)
  if (NOT DEFINED ${var}_FOUND)
    set(multiValueArgs  INTERPRETERS)
    set(oneValueArgs    NAME DOC URL REQUIRED VERSION_MEMBER VERSION_POS)
    set(options         NOWARNING)
    cmake_parse_arguments(y
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN})

    set(${var}_FOUND 0                 CACHE STRING "Module found")
    set(${var}_VERSION     "unknown"   CACHE STRING "Python module version")
    set(${var}_INTERPRETER ""          CACHE STRING "Python module interpreter")
    set(${var}_MODULE      "${y_NAME}" CACHE STRING "Python module name")

    foreach(c_python ${y_INTERPRETERS})
      if (NOT ${c_python}_EXECUTABLE)
        xtdmake_find_program(${c_python}
          NAMES ${c_python}
          DOC   "Python interpreter"
          URL   "https://www.python.org/"
          REQUIRED ${y_REQUIRED}
          VERSION_OPT "--version"
          VERSION_POS 1)
      endif()
      if (NOT ${c_python}_EXECUTABLE)
        continue()
      endif()

      execute_process(
        COMMAND bash -c "${${c_python}_EXECUTABLE} -c 'import ${y_NAME}; print(${y_NAME}.${y_VERSION_MEMBER})'"
        OUTPUT_VARIABLE __y_stdout
        ERROR_VARIABLE  __y_stderr
        RESULT_VARIABLE __y_status)
      if (NOT __y_status EQUAL 0)
        continue()
      endif()

      set(${var}_INTERPRETER "${${c_python}_EXECUTABLE}" CACHE STRING "Python module interpreter" FORCE)
      set(${var}_FOUND 1                                 CACHE STRING "Module found" FORCE)
      if (NOT ${__y_stdout} STREQUAL "")
        string(REPLACE "\n" "" l_words "${__y_stdout}")
        string(REPLACE " " ";" l_words "${l_words}")
        list(GET l_words ${y_VERSION_POS} l_ver)
        set(${var}_VERSION ${l_ver} CACHE STRING "Python module version" FORCE)
      endif()
      message(STATUS "Found python module ${y_NAME} : ${${var}_INTERPRETER} -m ${y_NAME} (version \"${${var}_VERSION}\")")
      break()
    endforeach()

    if (${var}_FOUND EQUAL 0)
      if (${y_REQUIRED})
        message(SEND_ERROR "Cannot find required module ${y_NAME}, ${y_DOC}, please install at (${y_URL})")
      elseif(NOT ${y_NOWARNING} STREQUAL "TRUE")
        message(STATUS "Found python module ${y_NAME} : FALSE")
      endif()
    endif()
  endif()
endmacro()
