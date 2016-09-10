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
          COMMAND bash -c "${${var}_EXECUTABLE} ${x_VERSION_OPT}"
          OUTPUT_VARIABLE ${var}_VERSION_RAW)
        string(REPLACE "\n" "" l_words "${${var}_VERSION_RAW}")
        string(REPLACE " " ";" l_words "${l_words}")
        list(GET l_words ${x_VERSION_POS} ${var}_VERSION)
      else()
        set(${var}_VERSION "unknown")
      endif()
      message(STATUS "Found program ${x_NAMES} : ${${var}_EXECUTABLE} (version \"${${var}_VERSION}\")")
    else()
      set(${var}_FOUND 0)
      if (${x_REQUIRED})
        message(SEND_ERROR "Cannot find required program ${x_NAMES}, ${x_DOC}, please install at (${x_URL})")
      elseif(NOT ${x_NOWARNING} STREQUAL "TRUE")
        message(STATUS "Found program ${x_NAMES} : FALSE")
      endif()
    endif()
  endif()
endmacro()
