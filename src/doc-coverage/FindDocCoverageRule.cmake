add_custom_target(doc-coverage)
add_custom_target(doc-coverage-clean)

xtdmake_find_program(Genhtml
  NAMES genhtml
  DOC "Html report generation tool"
  URL "http://ltp.sourceforge.net/coverage/lcov.php"
  REQUIRED DocCoverageRule_FIND_REQUIRED
  VERSION_OPT "--version"
  VERSION_POS 3)

xtdmake_find_python_module(Coverxygen
  NAME coverxygen
  INTERPRETERS python3 python
  DOC "Tool to generate coverage report from Doxygen documentation"
  URL "https://github.com/psycofdj/coverxygen"
  REQUIRED DocCoverageRule_FIND_REQUIRED
  VERSION_MEMBER "__version__"
  VERSION_POS 0)

set(DocCoverageRule_FOUND 0)
if (NOT Coverxygen_FOUND OR NOT Genhtml_FOUND OR NOT DocRule_FOUND OR Coverxygen_VERSION VERSION_LESS 1.2.0)
  message(STATUS "Found module DocCoverageRule : FALSE (unmet required dependencies)")
  if (DocCoverageRule_FIND_REQUIRED)
    message(FATAL_ERROR "Unable to load required module DocCoverageRule")
  endif()
else()
  set(DocCoverageRule_FOUND 1)
  message(STATUS "Found module DocCoverageRule : TRUE")
endif()

set(DocCoverageRule_DEFAULT_KIND        "enum;typedef;variable;function;class;struct;define"  CACHE STRING "DocCoverageRule default list of symbol kinds")
set(DocCoverageRule_DEFAULT_SCOPE       "public;protected"                                    CACHE STRING "DocCoverageRule default list of symbol scope")
set(DocCoverageRule_DEFAULT_PREFIX      "\${CMAKE_CURRENT_SOURCE_DIR}/src"                    CACHE STRING "DocCoverageRule default file prefix filter")
set(DocCoverageRule_DEFAULT_MIN_PERCENT "30"                                                  CACHE STRING "DocCoverageRule default mimunim coverage percentage to consider task successful")


if (NOT DocCoverageRule_FOUND)
  function(add_doc_coverage module)
    add_custom_target(${module}-doc-coverage
      COMMAND echo "warning: doc-coverage rule is disabled due to missing dependencies")
    add_custom_target(${module}-doc-coverage-clean
      COMMAND echo "warning: doc coverage is disabled due to missing dependencies")
    add_dependencies(doc-coverage       ${module}-doc-coverage)
    add_dependencies(doc-coverage-clean ${module}-doc-coverage-clean)
  endfunction()
else()
  function(add_doc_coverage module)
    if (NOT TARGET ${module}-doc)
      message(FATAL_ERROR "unable to find target doc-${module}, please call add_doc command for your module")
    endif()

    set(multiValueArgs  SCOPE KIND)
    set(oneValueArgs    MIN_PERCENT PREFIX)
    set(options         )
    cmake_parse_arguments(DocCoverageRule
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN})

    xtdmake_set_default(DocCoverageRule KIND)
    xtdmake_set_default(DocCoverageRule SCOPE)
    xtdmake_set_default(DocCoverageRule PREFIX)
    xtdmake_set_default(DocCoverageRule MIN_PERCENT)

    string(REPLACE ";" "," DocCoverageRule_KIND  "${DocCoverageRule_KIND}")
    string(REPLACE ";" "," DocCoverageRule_SCOPE "${DocCoverageRule_SCOPE}")

    get_target_property(DocCoverageRule_DOXYGEN_OUTPUT ${module}-doc OUTPUT_DIR)
    set(DocCoverageRule_OUTPUT "${PROJECT_BINARY_DIR}/reports/doc-coverage/${module}")

    add_custom_command(
      COMMENT "Generating ${module} documentation coverage informations"
      OUTPUT
      ${DocCoverageRule_OUTPUT}/doc-coverage.info
      ${DocCoverageRule_OUTPUT}/data.json
      ${DocCoverageRule_OUTPUT}/status.json
      DEPENDS
      ${DocCoverageRule_DOXYGEN_OUTPUT}/xml/index.xml
      ${XTDMake_HOME}/doc-coverage/status.py
      COMMAND mkdir -p ${DocCoverageRule_OUTPUT}
      COMMAND ${Coverxygen_INTERPRETER}
      -m ${Coverxygen_MODULE}
      --xml-dir ${DocCoverageRule_DOXYGEN_OUTPUT}/xml/
      --src-dir ${CMAKE_CURRENT_SOURCE_DIR}
      --output ${DocCoverageRule_OUTPUT}/doc-coverage.info
      --prefix ${DocCoverageRule_PREFIX}
      --scope ${DocCoverageRule_SCOPE}
      --kind ${DocCoverageRule_KIND}

      COMMAND ${Coverxygen_INTERPRETER}
      -m ${Coverxygen_MODULE}
      --xml-dir ${DocCoverageRule_DOXYGEN_OUTPUT}/xml/
      --src-dir ${CMAKE_CURRENT_SOURCE_DIR}
      --output ${DocCoverageRule_OUTPUT}/data.json
      --prefix ${DocCoverageRule_PREFIX}
      --scope ${DocCoverageRule_SCOPE}
      --kind ${DocCoverageRule_KIND}
      --json

      COMMAND ${XTDMake_HOME}/coverage/lcov_cobertura.py ${DocCoverageRule_OUTPUT}/doc-coverage.info -d -o ${DocCoverageRule_OUTPUT}/doc-coverage.xml
      COMMAND ${XTDMake_HOME}/doc-coverage/status.py --module ${module} --input-file=${DocCoverageRule_OUTPUT}/data.json --output-file=${DocCoverageRule_OUTPUT}/status.json --min-percent=${DocCoverageRule_MIN_PERCENT}
      VERBATIM)

    add_custom_command(
      COMMENT "Generating ${module} documentation coverage HTML report"
      OUTPUT ${DocCoverageRule_OUTPUT}/index.html
      DEPENDS ${DocCoverageRule_OUTPUT}/doc-coverage.info
      COMMAND mkdir -p ${DocCoverageRule_OUTPUT}
      COMMAND ${Genhtml_EXECUTABLE} -q --no-function-coverage --no-branch-coverage ${DocCoverageRule_OUTPUT}/doc-coverage.info -o ${DocCoverageRule_OUTPUT}/ -t "${module} documentation coverage" 2> /dev/null
      VERBATIM)

    add_custom_target(${module}-doc-coverage
      DEPENDS
      ${DocCoverageRule_OUTPUT}/index.html
      ${DocCoverageRule_OUTPUT}/data.json
      ${DocCoverageRule_OUTPUT}/status.json)
    set_target_properties(${module}-doc-coverage
      PROPERTIES OUTPUT_DIR "${DocCoverageRule_OUTPUT}")
    add_custom_target(${module}-doc-coverage-clean
      COMMAND rm -rf ${DocCoverageRule_OUTPUT})

    add_dependencies(doc-coverage       ${module}-doc-coverage)
    add_dependencies(doc-coverage-clean ${module}-doc-coverage-clean)
  endfunction()
endif()
