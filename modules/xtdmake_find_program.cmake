macro(xtdmake_find_program var)
  set(multiValueArgs  NAMES)
  set(oneValueArgs    DOC URL REQUIERED VERSION_OPT VERSION_POS)
  set(options         WARNING)
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
        COMMAND ${${var}_EXECUTABLE} ${x_VERSION_OPT}
        OUTPUT_VARIABLE ${var}_VERSION_RAW)
      string(REPLACE "\n" "" l_words "${${var}_VERSION_RAW}")
      string(REPLACE " " ";" l_words "${l_words}")
      list(GET l_words ${x_VERSION_POS} ${var}_VERSION)
    else()
      set(${var}_VERSION "UNKNOWN")
    endif()
    message(STATUS "Found ${var} : ${${var}_EXECUTABLE} (found version \"${${var}_VERSION}\")")
  else()
    set(${var}_FOUND 0)
    if (${x_REQUIERED})
      message(SEND_ERROR "Cannot find requiered program, please install ${var} (${x_URL})")
    elseif(${x_WARNING} STREQUAL "TRUE")
      message(STATUS "Found ${var} : FALSE")
    endif()
  endif()
endmacro()
