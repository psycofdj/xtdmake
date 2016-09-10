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
  message(STATUS "Found module DocCoverage : FALSE (unmet required dependencies)")
  if (DocCoverageRule_FIND_REQUIRED)
    message(FATAL_ERROR "Unable to load required module DocCoverageRule")
  endif()
else()
  set(DocCoverageRule_FOUND 1)
  message(STATUS "Found module DocCoverage : TRUE")
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

    get_target_property(DocCoverageRule_DOXYGEN_OUTPUT doc-${module} OUTPUT_DIR)
    set(DocCoverageRule_OUTPUT "${CMAKE_BINARY_DIR}/reports/${module}/doc-coverage")

    add_custom_command(
      OUTPUT ${DocCoverageRule_OUTPUT}/doc-coverage.info ${DocCoverageRule_OUTPUT}/data.json
      COMMAND mkdir -p ${DocCoverageRule_OUTPUT}
      COMMAND ${Coverxygen_EXECUTABLE} --xml-dir ${DocCoverageRule_DOXYGEN_OUTPUT}/xml/ --output ${DocCoverageRule_OUTPUT}/doc-coverage.info --prefix ${CMAKE_CURRENT_SOURCE_DIR}/src
      COMMAND ${Coverxygen_EXECUTABLE} --xml-dir ${DocCoverageRule_DOXYGEN_OUTPUT}/xml/ --output ${DocCoverageRule_OUTPUT}/data.json --json --prefix ${CMAKE_CURRENT_SOURCE_DIR}/src
      DEPENDS ${DocCoverageRule_DOXYGEN_OUTPUT}/xml/index.xml
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMENT "Generating ${module} documentation coverage informations" VERBATIM)

    add_custom_command(
      OUTPUT ${DocCoverageRule_OUTPUT}/index.html
      COMMAND mkdir -p ${DocCoverageRule_OUTPUT}
      COMMAND ${Genhtml_EXECUTABLE} --no-function-coverage --no-branch-coverage ${DocCoverageRule_OUTPUT}/doc-coverage.info -o ${DocCoverageRule_OUTPUT}/
      DEPENDS ${DocCoverageRule_OUTPUT}/doc-coverage.info
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMENT "Generating ${module} documentation coverage result interface" VERBATIM)

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
