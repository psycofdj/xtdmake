xtdmake_find_program(Cloc
  NAMES cloc
  DOC "cloc code line counting tool"
  URL "http://cloc.sourceforge.net/"
  VERSION_OPT "--version"
  VERSION_POS "0"
  REQUIRED ClocRule_FIND_REQUIRED)

xtdmake_find_program(Xsltproc
  NAMES xsltproc
  DOC "rendering xslt stylehseets"
  URL "http://xmlsoft.org/"
  VERSION_OPT " --version | head -n1 | cut -d' ' -f3 | sed 's/,//g'"
  VERSION_POS "0"
  REQUIRED ClocRule_FIND_REQUIRED)

if (NOT Cloc_FOUND OR NOT Xsltproc_FOUND)
  set(ClocRule_FOUND 0)
  message(STATUS "Found module ClocRule : FALSE (unmet required dependencies)")
  if (ClocRule_FIND_REQUIRED)
    message(FATAL_ERROR "Unable to load required module ClocRule")
  endif()
else()
  set(ClocRule_FOUND 1)
  message(STATUS "Found module ClocRule : TRUE")
endif()

set(ClocRule_DEFAULT_INPUT         "\${CMAKE_CURRENT_SOURCE_DIR}/src" CACHE STRING "ClocRule default list of source directories")
set(ClocRule_DEFAULT_FILE_PATTERNS "*.cc;*.hh;*.hxx"                  CACHE STRING "ClocRule default list of wildcard patterns to search in INPUT directories")
set(ClocRule_DEFAULT_MIN_PERCENT   "30"                               CACHE STRING "ClocRule default mimunim comment percentage to consider task successful")

add_custom_target(cloc)
add_custom_target(cloc-clean)

if (NOT ClocRule_FOUND)
  function(add_cloc module)
    add_custom_target(${module}-cloc
      COMMAND echo "warning: cloc rule disabled due to missing dependencies")
    add_custom_target(${module}-cloc-clean
      COMMAND echo "warning: cloc rule disabled due to missing dependencies")
    add_dependencies(cloc       ${module}-cloc)
    add_dependencies(cloc-clean ${module}-cloc-clean)
  endfunction()
else()
  function(add_cloc module)
    set(multiValueArgs  INPUT FILE_PATTERNS)
    set(oneValueArgs    )
    set(options         )
    cmake_parse_arguments(ClocRule
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN})

    set_default(ClocRule FILE_PATTERNS)
    set_default(ClocRule MIN_PERCENT)
    set_default_if_exists(ClocRule INPUT)

    set(ClocRule_OUTPUT "${CMAKE_BINARY_DIR}/reports/${module}/cloc")
    set(ClocRule_DEPENDS "")
    foreach(c_dir ${ClocRule_INPUT})
      foreach(c_pattern ${ClocRule_FILE_PATTERNS})
        file(GLOB_RECURSE l_files ${c_dir}/${c_pattern})
        foreach(c_res ${l_files})
          list(APPEND ClocRule_DEPENDS ${c_res})
        endforeach()
      endforeach()
    endforeach()

    # extract directory from all dependencies
    set(l_dir_list "")
    foreach(c_file ${ClocRule_DEPENDS})
      if (${CMAKE_MAJOR_VERSION} STREQUAL "3")
        get_filename_component(c_dir ${c_file} DIRECTORY)
      else()
        get_filename_component(c_dir ${c_file} PATH)
      endif()
      list(APPEND l_dir_list ${c_dir})
    endforeach()

    # sets as configure dependencies
    if (l_dir_list)
      list(REMOVE_DUPLICATES l_dir_list)
      set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${l_dir_list})
    endif()

    add_custom_command(
      COMMENT "Generating ${module} cloc HTML and XML reports"
      OUTPUT ${ClocRule_OUTPUT}/cloc.xml ${ClocRule_OUTPUT}/cloc.html ${ClocRule_OUTPUT}/status.json
      DEPENDS ${ClocRule_DEPENDS} ${PROJECT_SOURCE_DIR}/xtdmake/cloc/stylesheet.xsl ${PROJECT_SOURCE_DIR}/xtdmake/cloc/status.py
      COMMAND mkdir -p ${ClocRule_OUTPUT}
      COMMAND ${Cloc_EXECUTABLE} ${ClocRule_DEPENDS} --xml --out ${ClocRule_OUTPUT}/cloc.xml --by-file-by-lang
      COMMAND ${Xsltproc_EXECUTABLE} ${PROJECT_SOURCE_DIR}/xtdmake/cloc/stylesheet.xsl ${ClocRule_OUTPUT}/cloc.xml > ${ClocRule_OUTPUT}/cloc.html
      COMMAND ${PROJECT_SOURCE_DIR}/xtdmake/cloc/status.py --input-file=${ClocRule_OUTPUT}/cloc.xml --output-file=${ClocRule_OUTPUT}/status.json --min-percent=${ClocRule_MIN_PERCENT}
      VERBATIM)

    add_custom_target(${module}-cloc
      DEPENDS ${ClocRule_OUTPUT}/cloc.html ${ClocRule_OUTPUT}/status.json ${ClocRule_OUTPUT}/cloc.xml)
    add_custom_target(${module}-cloc-clean
      COMMAND rm -rf ${ClocRule_OUTPUT})
    add_dependencies(cloc       ${module}-cloc)
    add_dependencies(cloc-clean ${module}-cloc-clean)
  endfunction()
endif()
