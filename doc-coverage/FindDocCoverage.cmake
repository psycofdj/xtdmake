if (DocCoverage_FIND_REQUIRED)
  find_package(Genhtml REQUIRED)
  find_package(Coverxygen REQUIRED)
else()
  find_package(Coverxygen)
  find_package(Genhtml)
endif()

set(DocCoverage_FOUND 0)
if (NOT Coverxygen_FOUND OR NOT Genhtml_FOUND)
  if (DocCoverage_FIND_REQUIRED)
    message(SEND_ERROR "Unable to load DocCoverage without Genhtml and Coverxygen packages")
  else()
    message(SEND_STATUS "Unable to load DocCoverage without Genhtml and Coverxygen packages")
  endif()
else()
  set(DocCoverage_FOUND 1)
  message(STATUS "Found DocCoverage package")
endif()


if (DocCoverage_FOUND)
  add_custom_target(doc-coverage)
  add_custom_target(doc-coverage-clean)
  function(add_doc_coverage module)
    if (NOT TARGET doc-${module})
      message(FATAL_ERROR "unable to find target doc-${module}, please call add_doc command for your module")
    endif()

    get_target_property(CMAKE_DOXYGEN_OUTPUT doc-${module} OUTPUT_DIR)
    set(CMAKE_DOCCOVERAGE_OUTPUT "${CMAKE_BINARY_DIR}/reports/${module}/doc-coverage")

    add_custom_command(
      OUTPUT ${CMAKE_DOCCOVERAGE_OUTPUT}/doc-coverage.info
      COMMAND mkdir -p ${CMAKE_DOCCOVERAGE_OUTPUT}
      COMMAND ${Coverxygen_EXECUTABLE} --xml-dir ${CMAKE_DOXYGEN_OUTPUT}/xml/ --output ${CMAKE_DOCCOVERAGE_OUTPUT}/doc-coverage.info --prefix ${CMAKE_CURRENT_SOURCE_DIR}/src
      DEPENDS ${CMAKE_DOXYGEN_OUTPUT}/xml/index.xml
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMENT "Generating ${module} documentation coverage informations" VERBATIM)

    add_custom_command(
      OUTPUT ${CMAKE_DOCCOVERAGE_OUTPUT}/index.html
      COMMAND mkdir -p ${CMAKE_DOCCOVERAGE_OUTPUT}
      COMMAND ${Genhtml_EXECUTABLE} --no-function-coverage --no-branch-coverage ${CMAKE_DOCCOVERAGE_OUTPUT}/doc-coverage.info -o ${CMAKE_DOCCOVERAGE_OUTPUT}/
      DEPENDS ${CMAKE_DOCCOVERAGE_OUTPUT}/doc-coverage.info
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMENT "Generating ${module} documentation coverage result interface" VERBATIM)

    add_custom_target(doc-coverage-${module}
      DEPENDS ${CMAKE_DOCCOVERAGE_OUTPUT}/index.html)
    set_target_properties(doc-coverage-${module}
      PROPERTIES OUTPUT_DIR "${CMAKE_DOCCOVERAGE_OUTPUT}")
    add_custom_target(doc-coverage-${module}-clean
      COMMAND rm -rf ${CMAKE_DOCCOVERAGE_OUTPUT})

    add_dependencies(doc-coverage       doc-coverage-${module})
    add_dependencies(doc-coverage-clean doc-coverage-${module}-clean)
  endfunction()
endif()
