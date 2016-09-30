xtdmake_find_program(Genhtml
  NAMES genhtml
  DOC "Html report generation tool"
  URL "http://ltp.sourceforge.net/coverage/lcov.php"
  REQUIRED DocCoverageRule_FIND_REQUIRED
  VERSION_OPT "--version"
  VERSION_POS 3)

xtdmake_find_program(Coverxygen
  NAMES coverxygen.py
  DOC "Tool to generate coverage report from Doxygen documentation"
  URL "https://github.com/psycofdj/coverxygen"
  REQUIRED DocCoverageRule_FIND_REQUIRED
  VERSION_OPT "--version"
  VERSION_POS 0)

set(DocCoverageRule_FOUND 0)
if (NOT Coverxygen_FOUND OR NOT Genhtml_FOUND OR NOT DocRule_FOUND)
  message(STATUS "Found module DocCoverageRule : FALSE (unmet required dependencies)")
  if (DocCoverageRule_FIND_REQUIRED)
    message(FATAL_ERROR "Unable to load required module DocCoverageRule")
  endif()
else()
  set(DocCoverageRule_FOUND 1)
  message(STATUS "Found module DocCoverageRule : TRUE")
endif()


add_custom_target(doc-coverage)
add_custom_target(doc-coverage-clean)
if (NOT DocCoverageRule_FOUND)
  function(add_doc_coverage module)
    add_custom_target(doc-coverage-${module}
      COMMAND echo "warning: doc-coverage rule is disabled due to missing dependencies")
    add_custom_target(doc-coverage-${module}-clean
      COMMAND echo "warning: doc coverage is disabled due to missing dependencies")
    add_dependencies(doc-coverage       doc-coverage-${module})
    add_dependencies(doc-coverage-clean doc-coverage-${module}-clean)
  endfunction()
else()
  function(add_doc_coverage module)
    if (NOT TARGET doc-${module})
      message(FATAL_ERROR "unable to find target doc-${module}, please call add_doc command for your module")
    endif()

    set(multiValueArgs  SCOPE KIND)
    set(oneValueArgs    )
    set(options         )
    cmake_parse_arguments(DocCoverageRule
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN})


    if (NOT DocCoverageRule_KIND)
      set(DocCoverageRule_KIND "enum;typedef;variable;function;class;struct;define")
    endif()

    if (NOT DocCoverageRule_SCOPE)
      set(DocCoverageRule_SCOPE "public;protected")
    endif()

    string(REPLACE ";" "," DocCoverageRule_KIND  "${DocCoverageRule_KIND}")
    string(REPLACE ";" "," DocCoverageRule_SCOPE "${DocCoverageRule_SCOPE}")
    get_target_property(DocCoverageRule_DOXYGEN_OUTPUT doc-${module} OUTPUT_DIR)
    set(DocCoverageRule_OUTPUT "${CMAKE_BINARY_DIR}/reports/${module}/doc-coverage")

    add_custom_command(
      COMMENT "Generating ${module} documentation coverage informations"
      OUTPUT ${DocCoverageRule_OUTPUT}/doc-coverage.info ${DocCoverageRule_OUTPUT}/data.json
      DEPENDS doc-${module} ${DocCoverageRule_DOXYGEN_OUTPUT}/xml/index.xml
      COMMAND mkdir -p ${DocCoverageRule_OUTPUT}
      COMMAND ${Coverxygen_EXECUTABLE} --xml-dir ${DocCoverageRule_DOXYGEN_OUTPUT}/xml/ --output ${DocCoverageRule_OUTPUT}/doc-coverage.info --prefix ${CMAKE_CURRENT_SOURCE_DIR}/src --scope ${DocCoverageRule_SCOPE} --kind ${DocCoverageRule_KIND}
      COMMAND ${Coverxygen_EXECUTABLE} --xml-dir ${DocCoverageRule_DOXYGEN_OUTPUT}/xml/ --output ${DocCoverageRule_OUTPUT}/data.json --json  --prefix ${CMAKE_CURRENT_SOURCE_DIR}/src --scope ${DocCoverageRule_SCOPE} --kind ${DocCoverageRule_KIND}
      COMMAND ${PROJECT_SOURCE_DIR}/xtdmake/coverage/lcov_cobertura.py ${DocCoverageRule_OUTPUT}/doc-coverage.info -d -o ${DocCoverageRule_OUTPUT}/doc-coverage.xml
      VERBATIM)

    add_custom_command(
      COMMENT "Generating ${module} documentation coverage HTML report"
      OUTPUT ${DocCoverageRule_OUTPUT}/index.html
      DEPENDS ${DocCoverageRule_OUTPUT}/doc-coverage.info
      COMMAND mkdir -p ${DocCoverageRule_OUTPUT}
      COMMAND ${Genhtml_EXECUTABLE} -q --no-function-coverage --no-branch-coverage ${DocCoverageRule_OUTPUT}/doc-coverage.info -o ${DocCoverageRule_OUTPUT}/ -t "${module} documentation coverage" > /dev/null 2>&1
      VERBATIM)

    add_custom_target(doc-coverage-${module}
      DEPENDS ${DocCoverageRule_OUTPUT}/index.html ${DocCoverageRule_OUTPUT}/data.json)
    set_target_properties(doc-coverage-${module}
      PROPERTIES OUTPUT_DIR "${DocCoverageRule_OUTPUT}")
    add_custom_target(doc-coverage-${module}-clean
      COMMAND rm -rf ${DocCoverageRule_OUTPUT})

    add_dependencies(doc-coverage       doc-coverage-${module})
    add_dependencies(doc-coverage-clean doc-coverage-${module}-clean)
  endfunction()
endif()
