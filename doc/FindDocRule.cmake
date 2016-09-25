xtdmake_find_program(Doxygen
  NAMES doxygen
  DOC "Source documentation generation tool"
  URL "http://www.doxygen.org/"
  VERSION_OPT "--version"
  VERSION_POS "0"
  REQUIRED DocRule_FIND_REQUIRED)

xtdmake_find_program(Plantuml
  NAMES plantuml
  DOC "UML diagrams drawing tool"
  URL "http://plantuml.com/"
  VERSION_OPT "-version"
  VERSION_POS "2")

xtdmake_find_program(Dot
  NAMES dot
  DOC "Graph drawing tools"
  URL "http://www.graphviz.org/"
  VERSION_OPT "-V 2>&1"
  VERSION_POS "0")

if (NOT Doxygen_FOUND)
  set(DocRule_FOUND 0)
  message(STATUS "Found module DocRule : FALSE (unmet required dependencies)")
  if (DocRule_FIND_REQUIRED)
    message(FATAL_ERROR "Unable to load required module DocRule")
  endif()
else()
  set(DocRule_FOUND 1)
  message(STATUS "Found module DocRule : TRUE")
endif()

add_custom_target(doc)
add_custom_target(doc-clean)
if (NOT DocRule_FOUND)
  function(add_doc module)
    add_custom_target(doc-${module}
      COMMAND echo "warning: doc rule is disabled due to missing dependencies")
    add_custom_target(doc-${module}-clean
      COMMAND echo "warning: doc rule is disabled due to missing dependencies")
    add_dependencies(doc       doc-${module})
    add_dependencies(doc-clean doc-${module}-clean)
  endfunction()
else()
  function(add_doc module)
    set(multiValueArgs  EXCLUDE FILE_PATTERNS CALL_GRAPHS PREDEFINED EXPAND_AS_DEFINED)
    set(oneValueArgs    EXAMPLE PLANTUML)
    set(options         WERROR)
    cmake_parse_arguments(DocRule
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN})

    set(DocRule_MODULE   "${module}")
    set(DocRule_OUTPUT   "${CMAKE_BINARY_DIR}/reports/${module}/doc")

    if ("${DocRule_FILE_PATTERNS}" STREQUAL "")
      set(DocRule_FILE_PATTERNS "*.cc *.hh *.hpp")
    endif()

    if ("${DocRule_PLANTUML}" STREQUAL "")
      if (Dot_FOUND AND Plantuml_FOUND)
        set(DocRule_PLANTUML "/usr/share/plantuml/plantuml.jar")
      endif()
    elseif("${DocRule_PLANTUML}" STREQUAL "NO")
      set(DocRule_PLANTUML "")
    endif()

    if ("${DocRule_CALL_GRAPHS}" STREQUAL "")
      if (Dot_FOUND)
        set(DocRule_CALL_GRAPHS "YES")
      endif()
    endif()

    if ("${DocRule_WERROR}" STREQUAL "TRUE")
      set(DocRule_WERROR "YES")
    else()
      set(DocRule_WERROR "NO")
    endif()

    if ("${DocRule_EXAMPLE}" STREQUAL "")
      if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/doc/example)
        set(DocRule_EXAMPLE ${CMAKE_CURRENT_SOURCE_DIR}/doc/example)
      endif()
    endif()



    if ("${DocRule_IMAGE}" STREQUAL "")
      if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/doc/image)
        set(DocRule_IMAGE ${CMAKE_CURRENT_SOURCE_DIR}/doc/image)
      endif()
    endif()

    if ("${DocRule_INPUT}" STREQUAL "")
      set(DocRule_INPUT ${CMAKE_CURRENT_SOURCE_DIR}/src)
      if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/doc)
        set(DocRule_INPUT "${DocRule_INPUT} ${CMAKE_CURRENT_SOURCE_DIR}/doc")
      endif()
    endif()

    set(l_excludes "${DocRule_EXCLUDE}")
    set(DocRule_EXCLUDE "")
    foreach(c_file ${l_excludes})
      if (NOT IS_ABSOLUTE ${c_file})
        set(c_file ${CMAKE_CURRENT_SOURCE_DIR}/${c_file})
      endif()
      set(DocRule_EXCLUDE "${DocRule_EXCLUDE} ${c_file}")
    endforeach()

    # compute target dependencies, we apply patterns to each input
    set(DocRule_DEPENDS "")
    string(REPLACE " " ";" l_inputs "${DocRule_INPUT}")
    string(REPLACE " " ";" l_patterns "${DocRule_FILE_PATTERNS}")
    foreach(c_file ${l_inputs})
      if (NOT IS_ABSOLUTE ${c_file})
        set(c_file ${CMAKE_CURRENT_SOURCE_DIR}/${c_file})
      endif()
      if (IS_DIRECTORY ${c_file})
        foreach(c_pattern ${l_patterns})
          file(GLOB_RECURSE l_dep ${c_file}/${c_pattern})
          if (NOT "${l_dep}" STREQUAL "")
            set(DocRule_DEPENDS "${DocRule_DEPENDS};${l_dep}")
          endif()
        endforeach()
      else()
        if (NOT "${c_file}" STREQUAL "")
          set(DocRule_DEPENDS "${DocRule_DEPENDS};${c_file}")
        endif()
      endif()
    endforeach()

    
    string(REPLACE ";" " " ${DocRule_DEPENDS}        "${DocRule_DEPENDS}")
    string(REPLACE ";" " " DocRule_PREDEFINED        "${DocRule_PREDEFINED}")
    string(REPLACE ";" " " DocRule_EXPAND_AS_DEFINED "${DocRule_EXPAND_AS_DEFINED}")

    set(DocRule_CONFIGURE_TEMPLATE ${PROJECT_SOURCE_DIR}/xtdmake/doc/doxygen-1.8.11.in)
    if (Doxygen_VERSION VERSION_LESS "1.8.11")
      set(DocRule_CONFIGURE_TEMPLATE ${PROJECT_SOURCE_DIR}/xtdmake/doc/doxygen.in)
    endif()

    configure_file(${DocRule_CONFIGURE_TEMPLATE} ${CMAKE_CURRENT_BINARY_DIR}/doxygen.cfg @ONLY)

    add_custom_command(
      COMMENT "Generating ${module} API documentation"
      OUTPUT ${DocRule_OUTPUT}/html/index.html ${DocRule_OUTPUT}/xml/index.xml
      DEPENDS ${DocRule_DEPENDS} ${CMAKE_CURRENT_BINARY_DIR}/doxygen.cfg
      COMMAND mkdir -p ${DocRule_OUTPUT}
      COMMAND ${Doxygen_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/doxygen.cfg
      VERBATIM)

    add_custom_target(doc-${module}
      DEPENDS ${DocRule_OUTPUT}/html/index.html)
    set_target_properties(doc-${module}
      PROPERTIES OUTPUT_DIR "${DocRule_OUTPUT}")
    add_custom_target(doc-${module}-clean
      COMMAND rm -rf ${DocRule_OUTPUT})

    add_dependencies(doc       doc-${module})
    add_dependencies(doc-clean doc-${module}-clean)
  endfunction()
endif()
