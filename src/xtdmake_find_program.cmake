macro(xtdmake_find_program var)
  if (NOT DEFINED ${var}_FOUND)
    set(multiValueArgs  NAMES)
    set(oneValueArgs    DOC URL REQUIRED VERSION_OPT VERSION_POS MIN_VERSION TOTO)
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


    set(l_found 0)
    set(l_error "")
    set(l_cause "")

    if (NOT ${var}_EXECUTABLE)
      set(l_error "Cannot find required program ${var}, ${x_DOC}, please install at (${x_URL})")
      set(l_cause "${x_DOC}, please install at (${x_URL})")
    else()
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

      if (x_MIN_VERSION)
        if ("${l_version}" VERSION_LESS "${x_MIN_VERSION}")
          set(l_error "Found ${var} but detected version ${l_version} is lower to ${x_MIN_VERSION}, please install at ${x_URL}")
          set(l_cause "(found ${l_version} but need ${x_VERSION}), please install at (${x_URL})")
        else()
          set(l_found 1)
          set(l_cause "${${var}_EXECUTABLE} (version \"${${var}_VERSION}\")")
        endif()
      else()
        set(l_found 1)
        set(l_cause "${${var}_EXECUTABLE} (version \"${${var}_VERSION}\")")
      endif()

    endif()

    if (l_found)
      set(${var}_FOUND 1 CACHE STRING "Program found")
      message(STATUS "Found program ${var} : ${l_cause}")
    else()
      set(${var}_FOUND 0 CACHE STRING "Program found")
      if (${x_REQUIRED})
        message(SEND_ERROR "${l_error}")
      elseif(NOT ${x_NOWARNING} STREQUAL "TRUE")
        message(STATUS "Found program ${var} : FALSE, ${l_cause}")
      endif()
    endif()

  endif()
endmacro()
