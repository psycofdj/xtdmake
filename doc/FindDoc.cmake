if (Doc_FIND_REQUIRED)
  find_package(Doxygen REQUIRED)
else()
  find_package(Doxygen)
endif()

set(Doc_FOUND 0)
if (NOT DOXYGEN_FOUND)
  if (Doc_FIND_REQUIRED)
    message(SEND_ERROR "Cannot use Doc without Doxygen package")
  else()
    message(STATUS "Cannot use Doc without Doxygen package")
  endif()
else()
  set(Doc_FOUND 1)
  message(STATUS "Found Doc package")
  add_custom_target(doc)
  add_custom_target(doc-clean)
  function(add_doc module)
    set(multiValueArgs  EXCLUDE FILE_PATTERNS CALL_GRAPHS)
    set(oneValueArgs    EXAMPLE)
    set(options         WERROR)
    cmake_parse_arguments(CMAKE_DOXYGEN "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(CMAKE_DOXYGEN_SRC_ROOT ${CMAKE_CURRENT_SOURCE_DIR})
    set(CMAKE_DOXYGEN_INPUT    ${CMAKE_CURRENT_SOURCE_DIR}/src)
    set(CMAKE_DOXYGEN_MODULE   "${module}")
    set(CMAKE_DOXYGEN_OUTPUT   "${CMAKE_BINARY_DIR}/reports/${module}/doc")

    string(REPLACE  ";"    " "                                CMAKE_DOXYGEN_EXCLUDE "${CMAKE_DOXYGEN_EXCLUDE}")
    string(REPLACE  "src/" "${CMAKE_CURRENT_SOURCE_DIR}/src/" CMAKE_DOXYGEN_EXCLUDE "${CMAKE_DOXYGEN_EXCLUDE}")

    if ("${CMAKE_DOXYGEN_FILE_PATTERNS}" STREQUAL "")
      set(CMAKE_DOXYGEN_FILE_PATTERNS "*.cc *.hh *.hpp")
    endif()

    if ("${CMAKE_DOXYGEN_CALL_GRAPHS}" STREQUAL "")
      set(CMAKE_DOXYGEN_CALL_GRAPHS "YES")
    endif()

    if ("${CMAKE_DOXYGEN_WERROR}" STREQUAL "TRUE")
      set(CMAKE_DOXYGEN_WERROR "YES")
    else()
      set(CMAKE_DOXYGEN_WERROR "NO")
    endif()

    if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/doc)
      set(CMAKE_DOXYGEN_INPUT "${CMAKE_DOXYGEN_INPUT} ${CMAKE_CURRENT_SOURCE_DIR}/doc")
      file(GLOB_RECURSE files_doc
        "${CMAKE_CURRENT_SOURCE_DIR}/doc/*.cc"
        "${CMAKE_CURRENT_SOURCE_DIR}/doc/*.hh"
        "${CMAKE_CURRENT_SOURCE_DIR}/doc/*.hxx")

    endif()

    if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/doc/example)
      set(CMAKE_DOXYGEN_EXAMPLE ${CMAKE_CURRENT_SOURCE_DIR}/doc/example)
    endif()

    if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/doc/image)
      set(CMAKE_DOXYGEN_IMAGE ${CMAKE_CURRENT_SOURCE_DIR}/doc/image)
    endif()

    file(GLOB_RECURSE files
      "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cc"
      "${CMAKE_CURRENT_SOURCE_DIR}/src/*.hh"
      "${CMAKE_CURRENT_SOURCE_DIR}/src/*.hxx")

    configure_file(${PROJECT_SOURCE_DIR}/xtdmake/doc/doxygen.in ${CMAKE_CURRENT_BINARY_DIR}/doxygen.cfg @ONLY)

    add_custom_command(
      OUTPUT ${CMAKE_DOXYGEN_OUTPUT}/html/index.html ${CMAKE_DOXYGEN_OUTPUT}/xml/index.xml
      COMMAND mkdir -p ${CMAKE_DOXYGEN_OUTPUT}
      COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/doxygen.cfg
      DEPENDS ${files} ${files_doc}
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMENT "Generating ${module} API documentation with doxygen" VERBATIM)

    add_custom_target(doc-${module}
      DEPENDS ${CMAKE_DOXYGEN_OUTPUT}/html/index.html)
    set_target_properties(doc-${module}
      PROPERTIES OUTPUT_DIR "${CMAKE_DOXYGEN_OUTPUT}")
    add_custom_target(doc-${module}-clean
      COMMAND rm -rf ${CMAKE_DOXYGEN_OUTPUT})

    add_dependencies(doc       doc-${module})
    add_dependencies(doc-clean doc-${module}-clean)
  endfunction()
endif()
