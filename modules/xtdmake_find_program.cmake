macro(xtdmake_find_program var)
  if (NOT DEFINED ${var}_FOUND)
    set(multiValueArgs  NAMES)
    set(oneValueArgs    DOC URL REQUIRED VERSION_OPT VERSION_POS)
    set(options         NOWARNING)
    cmake_parse_arguments(x
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN})

    find_program(${var}_EXECUTABLE
      NAMES ${x_NAMES}
      DOC   ${x_DOC}
      ${x_UNPARSED_ARGUMENTS})

    if (${var}_EXECUTABLE)
      set(${var}_FOUND 1)

      if (NOT ${x_VERSION_OPT} STREQUAL "")
        execute_process(
          COMMAND bash -c "${${var}_EXECUTABLE} ${x_VERSION_OPT} 2>&1"
          OUTPUT_VARIABLE __x_stdout
          RESULT_VARIABLE __x_status
          ERROR_VARIABLE  __x_stderr
          )

        string(REPLACE "\n" "" l_words "${__x_stdout}")
        string(REPLACE " " ";" l_words "${l_words}")
        list(GET l_words ${x_VERSION_POS} ${var}_VERSION)
      else()
        set(${var}_VERSION "unknown")
      endif()
      message(STATUS "Found program ${var} : ${${var}_EXECUTABLE} (version \"${${var}_VERSION}\")")
    else()
      set(${var}_FOUND 0)
      if (${x_REQUIRED})
        message(SEND_ERROR "Cannot find required program ${var}, ${x_DOC}, please install at (${x_URL})")
      elseif(NOT ${x_NOWARNING} STREQUAL "TRUE")
        message(STATUS "Found program ${var} : FALSE")
      endif()
    endif()
  endif()
endmacro()

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

    set(${var}_FOUND 0)
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

      set(${var}_INTERPRETER ${${c_python}_EXECUTABLE})
      set(${var}_MODULE ${y_NAME})
      set(${var}_FOUND 1)
      set(${var}_VERSION "unknown")

      if (NOT ${__y_stdout} STREQUAL "")
        string(REPLACE "\n" "" l_words "${__y_stdout}")
        string(REPLACE " " ";" l_words "${l_words}")
        list(GET l_words ${y_VERSION_POS} ${var}_VERSION)
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
