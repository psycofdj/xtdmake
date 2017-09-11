add_custom_target(iwyu)
add_custom_target(iwyu-clean)

xtdmake_find_program(Iwyu
  NAMES include-what-you-use
  DOC "Include-what-you-use header analyzer"
  URL "https://include-what-you-use.org/"
  REQUIRED ${IwyuRule_FIND_REQUIRED}
  VERSION_OPT "--version | cut -d' ' -f2"
  VERSION_POS 0)

xtdmake_find_python_module(Mako
  NAME mako
  INTERPRETERS python3 python
  DOC "Library to generate template in python"
  URL "http://www.makotemplates.org/"
  REQUIRED ${IwyuRule_FIND_REQUIRED}
  VERSION_MEMBER "__version__"
  VERSION_POS 0)


set(IwyuRule_FOUND 0)
if (NOT CMAKE_EXPORT_COMPILE_COMMANDS)
  message(STATUS "Found module IwyuRule_FOUND : FALSE (CMAKE_EXPORT_COMPILE_COMMANDS is mandatory)")
  if (IwyuRule_FIND_REQUIRED)
    message(FATAL_ERROR "Unable to find compile commands")
  endif()
endif()
set(IwyuRule_FOUND 1)

set(IwyuRule_DEFAULT_EXCLUDE_PATTERN "\${CMAKE_CURRENT_SOURCE_DIR}/unit/*"   CACHE STRING "IwyuRule default pattern to exclude source from analysis")
set(IwyuRule_DEFAULT_JOBS            "4"                                     CACHE STRING "IwyuRule default number of concurrent jobs")
set(IwyuRule_DEFAULT_MAPPING         "\${XTDMake_HOME}/iwyu/mapping.imp"     CACHE STRING "IwyuRule default mapping file")
set(IwyuRule_DEFAULT_VERBOSE         "FALSE"                                 CACHE STRING   "IwyuRule default verbose status")

if (NOT IwyuRule_FOUND)
  function(add_iwyu module)
    add_custom_target(${module}-iwyu
      COMMAND echo "warning: iwyu rule is disabled due to missing dependencies")
    add_custom_target(${module}-iwyu-clean
      COMMAND echo "warning: iwyu rule is disabled due to missing dependencies")
    add_dependencies(iwyu       ${module}-iwyu)
    add_dependencies(iwyu-clean ${module}-iwyu-clean)
  endfunction()
else()
  function(add_iwyu module)
    set(multiValueArgs  DEPENDS)
    set(oneValueArgs    EXCLUDE_PATTERN JOBS MAPPING)
    set(options         VERBOSE)
    cmake_parse_arguments(IwyuRule
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN})

    xtdmake_set_default(IwyuRule EXCLUDE_PATTERN)
    xtdmake_set_default(IwyuRule JOBS)
    xtdmake_set_default(IwyuRule VERBOSE)
    xtdmake_set_default(IwyuRule MAPPING)

    set(IwyuRule_OUTPUT "${PROJECT_BINARY_DIR}/reports/iwyu/${module}")
    set(IwyuRule_DEPENDS ${IwyuRule_DEPENDS})
    set(l_args "")

    if ("${IwyuRule_VERBOSE}" STREQUAL "TRUE" OR "${IwyuRule_DEFAULT_VERBOSE}" STREQUAL "TRUE")
      list(APPEND l_args "--verbose")
    endif()


    list(APPEND l_args "-Xiwyu")
    list(APPEND l_args "--max_line_length=300")

    if (NOT "${IwyuRule_MAPPING}" STREQUAL "")
      list(APPEND l_args "-Xiwyu")
      list(APPEND l_args "--mapping_file=${IwyuRule_MAPPING}")
      list(APPEND IwyuRule_DEPENDS "${IwyuRule_MAPPING}")
    endif()

    add_custom_command(
      COMMENT "Generating ${module} iwyu JSON reports"
      OUTPUT
      ${IwyuRule_OUTPUT}/iwyu.json
      DEPENDS
      ${IwyuRule_DEPENDS}
      ${XTDMake_HOME}/iwyu/analyze.py
      ${XTDMake_HOME}/iwyu/FindIwyuRule.cmake

      COMMAND mkdir -p ${IwyuRule_OUTPUT}
      COMMAND ${XTDMake_HOME}/iwyu/analyze.py
               --build-dir "${CMAKE_CURRENT_BINARY_DIR}"
               --commands "${CMAKE_BINARY_DIR}/compile_commands.json"
               --iwyu-bin "${Iwyu_EXECUTABLE}"
               --exclude "${IwyuRule_EXCLUDE_PATTERN}"
               --jobs "${IwyuRule_JOBS}"
               --output-file "${IwyuRule_OUTPUT}/iwyu.json"
               ${l_args}
      VERBATIM)

    add_custom_command(
      COMMENT "Generating ${module} iwyu HTML reports"
      OUTPUT
      ${IwyuRule_OUTPUT}/index.html
      ${IwyuRule_OUTPUT}/status.json
      DEPENDS
      ${IwyuRule_OUTPUT}/iwyu.json
      ${XTDMake_HOME}/iwyu/FindIwyuRule.cmake
      ${XTDMake_HOME}/iwyu/status.py
      ${XTDMake_HOME}/iwyu/index.tpl
      COMMAND ${Mako_INTERPRETER} ${XTDMake_HOME}/iwyu/status.py
               --module "${module}"
               --input-file    "${IwyuRule_OUTPUT}/iwyu.json"
               --output-status "${IwyuRule_OUTPUT}/status.json"
               --output-html   "${IwyuRule_OUTPUT}/index.html"
      VERBATIM)

    add_custom_target(${module}-iwyu
      DEPENDS
      ${IwyuRule_OUTPUT}/index.html
      ${IwyuRule_OUTPUT}/iwyu.json
      ${IwyuRule_OUTPUT}/status.json)

    add_custom_target(${module}-iwyu-clean
      COMMAND rm -rf ${IwyuRule_OUTPUT})

    add_dependencies(iwyu       ${module}-iwyu)
    add_dependencies(iwyu-clean ${module}-iwyu-clean)
  endfunction()
endif()
