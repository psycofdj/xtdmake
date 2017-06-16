add_custom_target(codedup)
add_custom_target(codedup-clean)

set(CodeDupRule_DEFAULT_PMD_VERSION      "5.7.0"                                          CACHE STRING "CodeDupRule PDM installed version")
set(CodeDupRule_DEFAULT_PMD_HOME         "/usr/share/pmd-bin-\${CodeDupRule_PMD_VERSION}" CACHE STRING "CodeDupRule location of PDM installation")
set(CodeDupRule_DEFAULT_INPUT            "\${CMAKE_CURRENT_SOURCE_DIR}/src"               CACHE STRING "CodeDupRule default list of source directories relative to CMAKE_CURRENT_SOURCE_DIR")
set(CodeDupRule_DEFAULT_FILE_PATTERNS    "*.cc;*.hh;*.hxx"                                CACHE STRING "CodeDupRule default list of wildcard patterns to search in INPUT directories")
set(CodeDupRule_DEFAULT_EXCLUDE_PATTERNS "\${CMAKE_CURRENT_SOURCE_DIR}/unit/*"            CACHE STRING "CodeDupRule default list of patterns to exclude from analysis")
set(CodeDupRule_DEFAULT_MIN_TOKENS       "100"                                            CACHE STRING "CodeDupRule default minimum token length which should be reported as a duplicate")
set(CodeDupRule_DEFAULT_ARGS             "--skip-lexical-errors"                          CACHE STRING "CodeDupRule default additional arguments to give to pmd")

xtdmake_eval(CodeDupRule_PMD_VERSION2 "${CodeDupRule_DEFAULT_PMD_VERSION}")
set(CodeDupRule_PMD_VERSION "${CodeDupRule_PMD_VERSION2}" CACHE STRING "")
xtdmake_eval(CodeDupRule_PMD_HOME2    "${CodeDupRule_DEFAULT_PMD_HOME}")
set(CodeDupRule_PMD_HOME    "${CodeDupRule_PMD_HOME2}"  CACHE STRING "")

xtdmake_find_program(Xsltproc
  NAMES xsltproc
  DOC "rendering xslt stylehseets"
  URL "http://xmlsoft.org/"
  VERSION_OPT " --version | head -n1 | cut -d' ' -f3 | sed 's/,//g'"
  VERSION_POS "0"
  REQUIRED ${CppcheckRule_FIND_REQUIRED})

xtdmake_find_program(Java
  NAMES java
  DOC "Java runtime environment"
  URL "http://openjdk.java.net/"
  REQUIRED ${CodeDupRule_FIND_REQUIRED}
  VERSION_OPT "-version 2>&1 | head -n1 | cut -d' ' -f3 | sed 's/\"//g' | cut -d_ -f1"
  VERSION_POS 0
  MIN_VERSION 1.8.0)


if (NOT EXISTS "${CodeDupRule_PMD_HOME}/lib/pmd-core-${CodeDupRule_PMD_VERSION}.jar")
  set(Pmd_FOUND 0)
  message(STATUS "Found Pmd jar : FALSE")
  message(STATUS "  Cannot find required Pmd jar, please install at (http://pmd.sourceforge.net)")
  message(STATUS "  - looking for file : ${CodeDupRule_PMD_HOME}/lib/pmd-core-${CodeDupRule_PMD_VERSION}.jar")
  message(STATUS "  - CodeDupRule_PMD_VERSION : ${CodeDupRule_PMD_VERSION}")
  message(STATUS "  - CodeDupRule_PMD_HOME : ${CodeDupRule_PMD_HOME}")
else()
  set(Pmd_FOUND 1)
  message(STATUS "Found Pmd jar : TRUE")
endif()

if (NOT Xsltproc_FOUND OR NOT Java_FOUND OR NOT Pmd_FOUND)
  set(CodeDupRule_FOUND 0)
  message(STATUS "Found module CodeDupRule : FALSE (unmet required dependencies)")
  if (CodeDupRule_FIND_REQUIRED)
    message(FATAL_ERROR "Unable to load required module CodeDupRule")
  endif()
else()
  set(CodeDupRule_FOUND 1)
  message(STATUS "Found module CodeDupRule : TRUE")
endif()

if(NOT CodeDupRule_FOUND)
  function(add_codedup module)
    add_custom_target(${module}-codedup
      COMMAND echo "warning: codedup rule is disabled due to missing dependencies")
    add_custom_target(${module}-codedup-clean
      COMMAND echo "warning: codedup rule is disabled due to missing dependencies")
    add_dependencies(codedup       ${module}-codedup)
    add_dependencies(codedup-clean ${module}-codedup-clean)
  endfunction()
else()
  function(add_codedup module)
    set(multiValueArgs  INPUT FILE_PATTERNS EXCLUDE_PATTERNS)
    set(oneValueArgs    MIN_TOKENS ARGS)
    set(options         )
    cmake_parse_arguments(CodeDupRule
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN})

    xtdmake_set_default(CodeDupRule FILE_PATTERNS)
    xtdmake_set_default(CodeDupRule MIN_TOKENS)
    xtdmake_set_default(CodeDupRule ARGS)
    xtdmake_set_default(CodeDupRule EXCLUDE_PATTERNS)
    xtdmake_set_default_if_exists(CodeDupRule INPUT)

    file(GLOB_RECURSE CodeDupRule_PMD_CLASSPATH "${CodeDupRule_PMD_HOME}/lib/*.jar")
    string(REPLACE ";" ":" CodeDupRule_PMD_CLASSPATH "${CodeDupRule_PMD_CLASSPATH}")
    set(CodeDupRule_OUTPUT "${PROJECT_BINARY_DIR}/reports/codedup/${module}")
    set(CodeDupRule_DEPENDS "")

    # compute input file list
    set(l_args "")
    foreach(c_dir ${CodeDupRule_INPUT})
      foreach(c_pattern ${CodeDupRule_FILE_PATTERNS})
        file(GLOB_RECURSE l_files ${c_dir}/${c_pattern})
        foreach(c_res ${l_files})
          foreach(c_exclude_pattern ${CodeDupRule_EXCLUDE_PATTERNS})
            if (NOT ${c_res} MATCHES ${c_exclude_pattern})

              get_filename_component(l_abspath ${c_res} REALPATH)
              list(APPEND l_args --files ${l_abspath})
            endif()
          endforeach()
          list(APPEND CodeDupRule_DEPENDS ${c_res})
        endforeach()
      endforeach()
    endforeach()

    # extract directory from all dependencies
    set(l_dir_list "")
    foreach(c_file ${CodeDupRule_DEPENDS})
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
      COMMENT "Generating ${module} codedup HTML and XML reports"
      OUTPUT
      ${CodeDupRule_OUTPUT}/codedup.xml
      ${CodeDupRule_OUTPUT}/index.html
      ${CodeDupRule_OUTPUT}/status.json
      DEPENDS
      ${CodeDupRule_DEPENDS}
      ${XTDMake_HOME}/codedup/stylesheet.xsl
      ${XTDMake_HOME}/codedup/status.py
      ${XTDMake_HOME}/codedup/FindCodeDupRule.cmake
      COMMAND mkdir -p ${CodeDupRule_OUTPUT}
      COMMAND ${Java_EXECUTABLE} -cp ${CodeDupRule_PMD_CLASSPATH} net.sourceforge.pmd.cpd.CPD --minimum-tokens ${CodeDupRule_MIN_TOKENS} --format xml  --language cpp ${l_args} ${CodeDupRule_ARGS} > ${CodeDupRule_OUTPUT}/codedup.xml || true
      COMMAND ${Xsltproc_EXECUTABLE} ${XTDMake_HOME}/codedup/stylesheet.xsl ${CodeDupRule_OUTPUT}/codedup.xml > ${CodeDupRule_OUTPUT}/index.html
      COMMAND ${XTDMake_HOME}/codedup/status.py --module ${module} --input-file=${CodeDupRule_OUTPUT}/codedup.xml --output-file=${CodeDupRule_OUTPUT}/status.json
      VERBATIM)

    add_custom_target(${module}-codedup
      DEPENDS
      ${CodeDupRule_OUTPUT}/index.html
      ${CodeDupRule_OUTPUT}/codedup.xml
      ${CodeDupRule_OUTPUT}/status.json)

    add_custom_target(${module}-codedup-clean
      COMMAND rm -rf ${CodeDupRule_OUTPUT})
    add_dependencies(codedup       ${module}-codedup)
    add_dependencies(codedup-clean ${module}-codedup-clean)
  endfunction()
endif()
