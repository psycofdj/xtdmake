enable_testing()
add_custom_target(check)
add_custom_target(check-verbose)
add_custom_target(check-clean)


set(CheckRule_FOUND 1)
message(STATUS "Found module CheckRule : TRUE")

define_property(TARGET
  PROPERTY MYDEPENDS
  BRIEF_DOCS "Internal property to communicate check dependencies to other rules"
  FULL_DOCS "Internal property to communicate check dependencies to other rules")

function(add_check module)
  set(multiValueArgs  PATTERNS INCLUDES LINKS ENV ARGS)
  set(oneValueArgs    DIRECTORY PREFIX JOBS)
  set(options         NO_DEFAULT_ENV)
  cmake_parse_arguments(CheckRule
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  set(CheckRule_OUTPUT   "${CMAKE_BINARY_DIR}/reports/${module}/check")

  if (NOT CheckRule_PREFIX)
    set(CheckRule_PREFIX "Test")
  endif()

  if (NOT CheckRule_JOBS)
    set(CheckRule_JOBS "1")
  endif()

  if (NOT CheckRule_PATTERNS)
    set(CheckRule_PATTERNS ".c;.cc;.cpp")
  endif()

  if (NOT CheckRule_DIRECTORY)
    set(CheckRule_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/unit/)
  endif()

  if (NOT CheckRule_NO_DEFAULT_ENV)
    list(APPEND CheckRule_ENV "CURRENT_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}")
    list(APPEND CheckRule_ENV "PROJECT_SOURCE_DIR=${PROJECT_SRCDIR}")
    list(APPEND CheckRule_ENV "PROJECT_BINARY_DIR=${PROJECT_BINARY_DIR}")
    list(APPEND CheckRule_ENV "TEST_SOURCE_DIR=${CheckRule_DIRECTORY}")
  endif()

  string(REPLACE ";" " " ${CheckRule_ENV}      "${CheckRule_ENV}")
  string(REPLACE ";" " " ${CheckRule_INCLUDES} "${CheckRule_INCLUDES}")
  string(REPLACE ";" " " ${CheckRule_LINKS}    "${CheckRule_LINKS}")
  string(REPLACE ";" " " ${CheckRule_ARGS}    "${CheckRule_ARGS}")

  set(${l_test_list} "")
  foreach(c_pattern ${CheckRule_PATTERNS})
    file(GLOB_RECURSE l_tests ${CheckRule_DIRECTORY}/${CheckRule_PREFIX}*${c_pattern})
    foreach(c_file ${l_tests})
      get_filename_component(c_name ${c_file} NAME_WE)
      string(REPLACE ${CheckRule_PREFIX} "" c_name_clean ${c_name})
      add_executable(${c_name_clean} ${c_file})
      target_include_directories(${c_name_clean}
        PUBLIC ${CheckRule_INCLUDES} ${Cppunit_INCLUDE_DIR})
      target_link_libraries(${c_name_clean} ${CheckRule_LINKS} ${Cppunit_LIBRARY})
      add_test(NAME ${c_name_clean}
        COMMAND ${c_name_clean} ${CheckRule_ARGS})
      list(APPEND l_test_list ${c_name_clean})
      add_custom_target(${c_name_clean}-gdb
        COMMAND ${CheckRule_ENV} gdb -ex run --args ${c_name_clean} ${CheckRule_ARGS} -n)
    endforeach()
  endforeach()

  string(REPLACE ";" "\\|" l_test_names   "${l_test_list}")
  string(REPLACE ";" ";"   l_test_depends "${l_test_list}")


  add_custom_target(check-${module}-build
    DEPENDS ${l_test_depends})

  set_target_properties(check-${module}-build
    PROPERTIES MYDEPENDS "${l_test_depends}")

  add_custom_target(check-${module}-forced-run
    COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/testing
    COMMAND ${CheckRule_ENV} ctest  -j ${CheckRule_JOBS} -T Test -R "\\(${l_test_names}\\)" || true
    COMMAND rm -rf ${CMAKE_CURRENT_BINARY_DIR}/testing)

  add_custom_target(check-${module}-verbose
    COMMAND $(MAKE) check-${module}-build
    COMMAND ${CheckRule_ENV} ctest --output-on-failure -j ${CheckRule_JOBS} -T Test -R "\\(${l_test_names}\\)" || true)

  add_custom_target(check-${module}-run
    DEPENDS check-${module}-build
    COMMAND $(MAKE) check-${module}-forced-run)

  add_custom_command(
    COMMENT "Generating ${module} tests HTML and XML reports"
    OUTPUT ${CheckRule_OUTPUT}/tests.xml ${CheckRule_OUTPUT}/index.html
    DEPENDS ${l_test_depends} check-${module}-build ${PROJECT_SOURCE_DIR}/xtdmake/check/stylesheet.xsl
    COMMAND mkdir -p ${CheckRule_OUTPUT}
    COMMAND rm -rf Testing/
    COMMAND touch DartConfiguration.tcl
    COMMAND $(MAKE) check-${module}-forced-run
    COMMAND cp Testing/*/*.xml ${CheckRule_OUTPUT}/tests.xml
    COMMAND ${Xsltproc_EXECUTABLE} ${PROJECT_SOURCE_DIR}/xtdmake/check/stylesheet.xsl ${CheckRule_OUTPUT}/tests.xml > ${CheckRule_OUTPUT}/index.html
    )

  add_custom_target(check-${module}
    DEPENDS ${CheckRule_OUTPUT}/tests.xml ${CheckRule_OUTPUT}/index.html)
  add_custom_target(check-${module}-clean
    COMMAND rm -rf ${CheckRule_OUTPUT} Testing DartConfiguration.tcl)
  add_dependencies(check         check-${module})
  add_dependencies(check-verbose check-${module}-verbose)
  add_dependencies(check-clean    check-${module}-clean)
endfunction()
