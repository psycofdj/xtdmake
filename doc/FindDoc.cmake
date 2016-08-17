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
    message(STATUS "Found Doc : FALSE, cannot use Doxygen package")
  endif()
else()
  set(Doc_FOUND 1)
  message(STATUS "Found Doc : TRUE")
  add_custom_target(doc)
  add_custom_target(doc-clean)
  function(add_doc module)
    set(multiValueArgs  EXCLUDE FILE_PATTERNS CALL_GRAPHS)
    set(oneValueArgs    EXAMPLE)
    set(options         WERROR)

    cmake_parse_arguments(Doc
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN})

    set(Doc_MODULE   "${module}")
    set(Doc_OUTPUT   "${CMAKE_BINARY_DIR}/reports/${module}/doc")

    if ("${Doc_FILE_PATTERNS}" STREQUAL "")
      set(Doc_FILE_PATTERNS "*.cc *.hh *.hpp")
    endif()

    if ("${Doc_CALL_GRAPHS}" STREQUAL "")
      set(Doc_CALL_GRAPHS "YES")
    endif()

    if ("${Doc_WERROR}" STREQUAL "TRUE")
      set(Doc_WERROR "YES")
    else()
      set(Doc_WERROR "NO")
    endif()

    if ("${Doc_EXAMPLE}" STREQUAL "")
      if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/doc/example)
        set(Doc_EXAMPLE ${CMAKE_CURRENT_SOURCE_DIR}/doc/example)
      endif()
    endif()

    if ("${Doc_IMAGE}" STREQUAL "")
      if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/doc/image)
        set(Doc_IMAGE ${CMAKE_CURRENT_SOURCE_DIR}/doc/image)
      endif()
    endif()

    if ("${Doc_INPUT}" STREQUAL "")
      set(Doc_INPUT ${CMAKE_CURRENT_SOURCE_DIR}/src)
      if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/doc)
        set(Doc_INPUT "${Doc_INPUT} ${CMAKE_CURRENT_SOURCE_DIR}/doc")
      endif()
    endif()

    if (NOT "${Doc_EXCLUDE}" STREQUAL "")
      string(REPLACE ";" " " Doc_EXCLUDE "${Doc_EXCLUDE}")
    endif()

    # compute target dependencies, we apply patterns to each input
    set(Doc_DEPENDS "")
    string(REPLACE " " ";" l_inputs "${Doc_INPUT}")
    string(REPLACE " " ";" l_patterns "${Doc_FILE_PATTERNS}")
    foreach(c_file ${l_inputs})
      if (NOT IS_ABSOLUTE ${c_file})
        set(c_file ${CMAKE_CURRENT_SOURCE_DIR}/${c_file})
      endif()
      if (IS_DIRECTORY ${c_file})
        foreach(c_pattern ${l_patterns})
          file(GLOB_RECURSE l_dep ${c_file}/${c_pattern})
          if (NOT "${l_dep}" STREQUAL "")
            set(Doc_DEPENDS "${Doc_DEPENDS};${l_dep}")
          endif()
        endforeach()
      else()
        if (NOT "${c_file}" STREQUAL "")
          set(Doc_DEPENDS "${Doc_DEPENDS};${c_file}")
        endif()
      endif()
    endforeach()
    string(REPLACE ";" " " ${Doc_DEPENDS} "${Doc_DEPENDS}")

    set(Doc_CONFIGURE_TEMPLATE ${PROJECT_SOURCE_DIR}/xtdmake/doc/doxygen-1.8.11.in)
    if (DOXYGEN_VERSION VERSION_LESS "1.8.11")
      set(Doc_CONFIGURE_TEMPLATE ${PROJECT_SOURCE_DIR}/xtdmake/doc/doxygen.in)
    endif()

    configure_file(${Doc_CONFIGURE_TEMPLATE} ${CMAKE_CURRENT_BINARY_DIR}/doxygen.cfg @ONLY)

    add_custom_command(
      OUTPUT ${Doc_OUTPUT}/html/index.html ${Doc_OUTPUT}/xml/index.xml
      COMMAND mkdir -p ${Doc_OUTPUT}
      COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/doxygen.cfg
      DEPENDS ${Doc_DEPENDS}
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMENT "Generating ${module} API documentation with doxygen" VERBATIM)

    add_custom_target(doc-${module}
      DEPENDS ${Doc_OUTPUT}/html/index.html)
    set_target_properties(doc-${module}
      PROPERTIES OUTPUT_DIR "${Doc_OUTPUT}")
    add_custom_target(doc-${module}-clean
      COMMAND rm -rf ${Doc_OUTPUT})

    add_dependencies(doc       doc-${module})
    add_dependencies(doc-clean doc-${module}-clean)
  endfunction()
endif()
