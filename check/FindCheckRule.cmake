enable_testing()
add_custom_target(check)
add_custom_target(check-clean)

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
        COMMAND ${CheckRule_ENV} gdb ${c_name_clean})
    endforeach()
  endforeach()

  string(REPLACE ";" "\\|" l_test_names   "${l_test_list}")
  string(REPLACE ";" ";"   l_test_depends "${l_test_list}")
  add_custom_command(
    OUTPUT ${CheckRule_OUTPUT}/tests.xml
    DEPENDS ${l_test_depends}
    COMMAND mkdir -p ${CheckRule_OUTPUT}
    COMMAND rm -rf Testing/
    COMMAND touch DartConfiguration.tcl
    COMMAND ${CheckRule_ENV} ctest --output-on-failure -j ${CheckRule_JOBS} -T Test -R "\\(${l_test_names}\\)" || true
    COMMAND cp Testing/*/*.xml ${CheckRule_OUTPUT}/tests.xml
    )

  add_custom_command(
    OUTPUT ${CheckRule_OUTPUT}/index.html
    DEPENDS ${CheckRule_OUTPUT}/tests.xml ${PROJECT_SOURCE_DIR}/xtdmake/check/stylesheet.xsl
    COMMAND xsltproc ${PROJECT_SOURCE_DIR}/xtdmake/check/stylesheet.xsl ${CheckRule_OUTPUT}/tests.xml > ${CheckRule_OUTPUT}/index.html
    )

  add_custom_target(check-${module}
    DEPENDS ${CheckRule_OUTPUT}/index.html)
  add_custom_target(check-${module}-clean
    COMMAND rm -rf ${CheckRule_OUTPUT} Testing DartConfiguration.tcl)
  add_dependencies(check       check-${module})
  add_dependencies(check-clean check-${module}-clean)
endfunction()
