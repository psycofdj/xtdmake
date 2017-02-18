xtdmake_find_program(Cppcheck
  NAMES cppcheck
  DOC "cppcheck static code anylyser tool"
  URL "http://cppcheck.sourceforge.net/"
  REQUIRED CppcheckRule_FIND_REQUIRED
  VERSION_OPT "--version"
  VERSION_POS 1)

xtdmake_find_program(Xsltproc
  NAMES xsltproc
  DOC "rendering xslt stylehseets"
  URL "http://xmlsoft.org/"
  VERSION_OPT " --version | head -n1 | cut -d' ' -f3 | sed 's/,//g'"
  VERSION_POS "0"
  REQUIRED CppcheckRule_FIND_REQUIRED)

if (NOT Xsltproc_FOUND)
  set(CppcheckRule_FOUND 0)
  message(STATUS "Found module CppcheckRule : FALSE (unmet required dependencies)")
  if (CppcheckRule_FIND_REQUIRED)
    message(FATAL_ERROR "Unable to load required module CppcheckRule")
  endif()
else()
  set(CppcheckRule_FOUND 1)
  message(STATUS "Found module CppcheckRule : TRUE")
endif()


set(CppcheckRule_DEFAULT_INPUT         "\${CMAKE_CURRENT_SOURCE_DIR}/src" CACHE STRING "CppcheckRule default list of source directories relative to CMAKE_CURRENT_SOURCE_DIR")
set(CppcheckRule_DEFAULT_FILE_PATTERNS "*.cc;*.hh;*.hxx"                  CACHE STRING "CppcheckRule default list of wildcard patterns to search in INPUT directories")

add_custom_target(cppcheck)
add_custom_target(cppcheck-clean)
if(NOT CppcheckRule_FOUND)
  function(add_cppcheck module)
    add_custom_target(${module}-cppcheck
      COMMAND echo "warning: cppcheck rule is disabled due to missing dependencies")
    add_custom_target(${module}-cppcheck-clean
      COMMAND echo "warning: cppcheck rule is disabled due to missing dependencies")
    add_dependencies(cppcheck       ${module}-cppcheck)
    add_dependencies(cppcheck-clean ${module}-cppcheck-clean)
  endfunction()
else()
  function(add_cppcheck module)
    set(multiValueArgs  INPUT FILE_PATTERNS)
    set(oneValueArgs    )
    set(options         )
    cmake_parse_arguments(Cppcheck
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN})

    xtdmake_set_default(CppcheckRule FILE_PATTERNS)
    xtdmake_set_default_if_exists(CppcheckRule INPUT)

    set(CppcheckRule_OUTPUT "${CMAKE_BINARY_DIR}/reports/cppcheck/${module}")
    set(CppcheckRule_DEPENDS "")
    foreach(c_dir ${CppcheckRule_INPUT})
      foreach(c_pattern ${CppcheckRule_FILE_PATTERNS})
        file(GLOB_RECURSE l_files ${c_dir}/${c_pattern})
        foreach(c_res ${l_files})
          list(APPEND CppcheckRule_DEPENDS ${c_res})
        endforeach()
      endforeach()
    endforeach()

    # extract directory from all dependencies
    set(l_dir_list "")
    foreach(c_file ${CppcheckRule_DEPENDS})
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
      COMMENT "Generating ${module} cppcheck HTML and XML reports"
      OUTPUT
      ${CppcheckRule_OUTPUT}/cppcheck.xml
      ${CppcheckRule_OUTPUT}/index.html
      ${CppcheckRule_OUTPUT}/status.json
      DEPENDS
      ${CppcheckRule_DEPENDS}
      ${XTDMake_HOME}/cppcheck/stylesheet.xsl
      ${XTDMake_HOME}/cppcheck/status.py
      COMMAND mkdir -p ${CppcheckRule_OUTPUT}
      COMMAND ${Cppcheck_EXECUTABLE} -q --xml ${CppcheckRule_DEPENDS} 2> ${CppcheckRule_OUTPUT}/cppcheck.xml
      COMMAND ${Xsltproc_EXECUTABLE} ${XTDMake_HOME}/cppcheck/stylesheet.xsl ${CppcheckRule_OUTPUT}/cppcheck.xml > ${CppcheckRule_OUTPUT}/index.html
      COMMAND ${XTDMake_HOME}/cppcheck/status.py --module ${module} --input-file=${CppcheckRule_OUTPUT}/cppcheck.xml --output-file=${CppcheckRule_OUTPUT}/status.json
      VERBATIM)
    add_custom_target(${module}-cppcheck
      DEPENDS
      ${CppcheckRule_OUTPUT}/index.html
      ${CppcheckRule_OUTPUT}/cppcheck.xml
      ${CppcheckRule_OUTPUT}/status.json)
    add_custom_target(${module}-cppcheck-clean
      COMMAND rm -rf ${CppcheckRule_OUTPUT})
    add_dependencies(cppcheck       ${module}-cppcheck)
    add_dependencies(cppcheck-clean ${module}-cppcheck-clean)
  endfunction()
endif()
