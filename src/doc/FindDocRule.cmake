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


set(DocRule_DEFAULT_EXCLUDE           ""                                                                  CACHE STRING "DocRule default list of excluded files")
set(DocRule_DEFAULT_EXCLUDE_PATTERNS  ""                                                                  CACHE STRING "DocRule default list of patterns to exclude files")
set(DocRule_DEFAULT_FILE_PATTERNS     "*.cc;*.hh;*.hpp"                                                   CACHE STRING "DocRule default list of wildcard patterns")
set(DocRule_DEFAULT_PREDEFINED        ""                                                                  CACHE STRING "DocRule default list predefined macros")
set(DocRule_DEFAULT_EXPAND_AS_DEFINED ""                                                                  CACHE STRING "DocRule default list of macro to expand as defined")
set(DocRule_DEFAULT_EXAMPLE           "\${CMAKE_CURRENT_SOURCE_DIR}/doc/example"                          CACHE STRING "DocRule default example directory")
set(DocRule_DEFAULT_IMAGE             "\${CMAKE_CURRENT_SOURCE_DIR}/doc/image"                            CACHE STRING "DocRule default example directory")
set(DocRule_DEFAULT_PLANTUML          "/usr/share/plantuml/plantuml.jar"                                  CACHE STRING "DocRule default platuml jar path")
set(DocRule_DEFAULT_INPUT             "\${CMAKE_CURRENT_SOURCE_DIR}/src;\${CMAKE_CURRENT_SOURCE_DIR}/doc" CACHE STRING "DocRule default list of input directory to find file")
set(DocRule_DEFAULT_WERROR            "YES"                                                               CACHE STRING "DocRule default value of WERROR option")
set(DocRule_DEFAULT_CALL_GRAPHS       "YES"                                                               CACHE STRING "DocRule default value of CALL_GRAPHS option")
set(DocRule_DEFAULT_CONFIGURE_TEMPLATE ""                                                                 CACHE STRING "DocRule default value of CONFIGURE_TEMPLATE option")


add_custom_target(doc)
add_custom_target(doc-clean)
if (NOT DocRule_FOUND)
  function(add_doc module)
    add_custom_target(${module}-doc
      COMMAND echo "warning: doc rule is disabled due to missing dependencies")
    add_custom_target(${module}-doc-clean
      COMMAND echo "warning: doc rule is disabled due to missing dependencies")
    add_dependencies(doc       ${module}-doc)
    add_dependencies(doc-clean ${module}-doc-clean)
  endfunction()
else()
  function(add_doc module)
    set(multiValueArgs  INPUT FILE_PATTERNS EXCLUDE EXCLUDE_PATTERNS PREDEFINED EXPAND_AS_DEFINED)
    set(oneValueArgs    EXAMPLE IMAGE PLANTUML WERROR CALL_GRAPHS CONFIGURE_TEMPLATE)
    set(options         )
    cmake_parse_arguments(DocRule
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN})

    set(DocRule_MODULE   "${module}")
    set(DocRule_OUTPUT   "${CMAKE_BINARY_DIR}/reports/doc/${module}")

    # use default value argument if needed
    xtdmake_set_default(DocRule FILE_PATTERNS)
    xtdmake_set_default(DocRule CALL_GRAPHS)
    xtdmake_set_default(DocRule WERROR)
    xtdmake_set_default(DocRule PREDEFINED)
    xtdmake_set_default(DocRule CONFIGURE_TEMPLATE)
    xtdmake_set_default(DocRule EXCLUDE_PATTERNS)
    xtdmake_set_default_if_exists(DocRule PLANTUML)
    xtdmake_set_default_if_exists(DocRule EXAMPLE)
    xtdmake_set_default_if_exists(DocRule IMAGE)
    xtdmake_set_default_if_exists(DocRule INPUT)
    xtdmake_set_default_if_exists(DocRule EXCLUDE)

    # disable graphs if dot not available
    if (NOT Dot_FOUND)
      set(DocRule_CALL_GRAPHS "NO")
    endif()

    # disable plantuml if dor or plantuml not found
    if (NOT Dot_FOUND OR NOT Plantuml_FOUND)
      set(DocRule_PLANTUML "")
    endif()

    # make exclude absolute paths
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
    foreach(c_file ${DocRule_INPUT})
      if (NOT IS_ABSOLUTE "${c_file}")
        set(c_file ${CMAKE_CURRENT_SOURCE_DIR}/${c_file})
      endif()
      if (IS_DIRECTORY "${c_file}")
        foreach(c_pattern ${DocRule_FILE_PATTERNS})
          file(GLOB_RECURSE l_deps ${c_file}/${c_pattern})
          if (l_deps)
            foreach(c_dep ${l_deps})
              list(APPEND DocRule_DEPENDS ${c_dep})
            endforeach()
          endif()
        endforeach()
      else()
        if (c_file)
          list(APPEND DocRule_DEPENDS ${c_file})
        endif()
      endif()
    endforeach()

    # extract directory from all dependencies
    set(l_dir_list "")
    foreach(c_file ${DocRule_DEPENDS})
      xtdmake_get_directory(c_dir ${c_file})
      list(APPEND l_dir_list ${c_dir})
    endforeach()

    # sets as configure dependencies
    if (l_dir_list)
      list(REMOVE_DUPLICATES l_dir_list)
      set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${l_dir_list})
    endif()

    xtdmake_stringify(DocRule_PREDEFINED)
    xtdmake_stringify(DocRule_EXPAND_AS_DEFINED)
    xtdmake_stringify(DocRule_FILE_PATTERNS)
    xtdmake_stringify(DocRule_INPUT)
    xtdmake_stringify(DocRule_EXCLUDE)
    xtdmake_stringify(DocRule_EXCLUDE_PATTERNS)
    set(l_tpl ${DocRule_CONFIGURE_TEMPLATE})
    if ("${l_tpl}" STREQUAL "")
      set(l_tpl "${XTDMake_HOME}/doc/doxygen-1.8.11.in")
      if (Doxygen_VERSION VERSION_LESS "1.8.11")
        set(l_tpl "${XTDMake_HOME}/doc/doxygen.in")
      endif()
    endif()

    configure_file(${l_tpl} ${CMAKE_CURRENT_BINARY_DIR}/doxygen.cfg @ONLY)

    add_custom_command(
      COMMENT "Generating ${module} API documentation"
      OUTPUT
      ${DocRule_OUTPUT}/html/index.html
      ${DocRule_OUTPUT}/xml/index.xml
      DEPENDS
      ${CMAKE_CURRENT_BINARY_DIR}/doxygen.cfg
      ${XTDMake_HOME}/doc/status.py
      COMMAND mkdir -p ${DocRule_OUTPUT}/html ${DocRule_OUTPUT}/xml
      COMMAND ${Doxygen_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/doxygen.cfg
      COMMAND ${XTDMake_HOME}/doc/status.py --module ${module} --output-file=${DocRule_OUTPUT}/status.json
      )

    foreach (c_dep ${DocRule_DEPENDS})
      add_custom_command(
        OUTPUT ${DocRule_OUTPUT}/html/index.html ${DocRule_OUTPUT}/xml/index.xml
        DEPENDS ${c_dep}
        APPEND)
    endforeach()

    add_custom_target(${module}-doc
      DEPENDS ${DocRule_OUTPUT}/html/index.html)
    set_target_properties(${module}-doc
      PROPERTIES OUTPUT_DIR "${DocRule_OUTPUT}")
    add_custom_target(${module}-doc-clean
      COMMAND rm -rf ${DocRule_OUTPUT})
    add_dependencies(doc       ${module}-doc)
    add_dependencies(doc-clean ${module}-doc-clean)
  endfunction()
endif()
