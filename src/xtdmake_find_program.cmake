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
      set(${var}_FOUND 1 CACHE STRING "Program found")

      if (NOT ${x_VERSION_OPT} STREQUAL "")
        execute_process(
          COMMAND bash -c "${${var}_EXECUTABLE} ${x_VERSION_OPT} 2>&1"
          OUTPUT_VARIABLE __x_stdout
          RESULT_VARIABLE __x_status
          ERROR_VARIABLE  __x_stderr
          )
        string(REPLACE "\n" "" l_words "${__x_stdout}")
        string(REPLACE " " ";" l_words "${l_words}")
        list(GET l_words ${x_VERSION_POS} l_version)
        set(${var}_VERSION "${l_version}" CACHE STRING "Program version")
      else()
        set(${var}_VERSION "unknown" CACHE STRING "Program version")
      endif()
      message(STATUS "Found program ${var} : ${${var}_EXECUTABLE} (version \"${${var}_VERSION}\")")
    else()
      set(${var}_FOUND 0 CACHE STRING "Program found")
      if (${x_REQUIRED})
        message(SEND_ERROR "Cannot find required program ${var}, ${x_DOC}, please install at (${x_URL})")
      elseif(NOT ${x_NOWARNING} STREQUAL "TRUE")
        message(STATUS "Found program ${var} : FALSE")
      endif()
    endif()
  endif()
endmacro()
