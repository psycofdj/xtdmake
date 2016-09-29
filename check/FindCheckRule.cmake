enable_testing()
add_custom_target(check)
add_custom_target(check-verbose)
add_custom_target(check-clean)


set(CheckRule_FOUND 1)
set(CheckRule_DEFAULT_ARGS     "" CACHE STRING "CheckRule default unit-test binary parameter template")
set(CheckRule_DEFAULT_ENV      "" CACHE STRING "CheckRule default unit-test binary environment template")
set(CheckRule_DEFAULT_INCLUDES "" CACHE STRING "CheckRule default unit-test header includes")
set(CheckRule_DEFAULT_LINKS    "" CACHE STRING "CheckRule default unit-test link libraries")


message(STATUS "Found module CheckRule : TRUE")

define_property(TARGET
  PROPERTY MYDEPENDS
  BRIEF_DOCS "Internal property to communicate check dependencies to other rules"
  FULL_DOCS "Internal property to communicate check dependencies to other rules")

function(add_check module)
  set(multiValueArgs  PATTERNS INCLUDES LINKS ENV ARGS)
  set(oneValueArgs    DIRECTORY PREFIX JOBS)
  set(options         NO_DEFAULT_ENV NO_DEFAULT_ARGS NO_DEFAULT_INCLUDES)
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

  if (NOT CheckRule_NO_DEFAULT_ARGS)
    eval(l_args "${CheckRule_DEFAULT_ARGS}")
    foreach (c_arg ${l_args})
      list(APPEND CheckRule_ARGS ${c_arg})
    endforeach()
  endif()

  if (NOT CheckRule_NO_DEFAULT_ENV)
    eval(l_args "${CheckRule_DEFAULT_ENV}")
    foreach (c_arg ${l_args})
      list(APPEND CheckRule_ENV ${c_arg})
    endforeach()
  endif()

  if (NOT CheckRule_NO_DEFAULT_INCLUDES)
    foreach (c_arg ${CheckRule_DEFAULT_INCLUDES})
      list(APPEND CheckRule_INCLUDES ${c_arg})
    endforeach()
  endif()

  if (NOT CheckRule_NO_DEFAULT_LINKS)
    foreach (c_arg ${CheckRule_DEFAULT_LINKS})
      list(APPEND CheckRule_LINKS ${c_arg})
    endforeach()
  endif()

  string(REPLACE ";" " " "${CheckRule_INCLUDES}" "${CheckRule_INCLUDES}")
  string(REPLACE ";" " " "${CheckRule_LINKS}"    "${CheckRule_LINKS}")
  string(REPLACE ";" " " "${CheckRule_ENV}"      "${CheckRule_ENV}")
  string(REPLACE ";" " " "${CheckRule_ARGS}"     "${CheckRule_ARGS}")

  set(${l_test_list} "")
  set(${l_dir_list}  "")
  foreach(c_pattern ${CheckRule_PATTERNS})
    file(GLOB_RECURSE l_tests ${CheckRule_DIRECTORY}/${CheckRule_PREFIX}*${c_pattern})
    foreach(c_file ${l_tests})
      get_filename_component(c_name ${c_file} NAME_WE)
      get_filename_component(c_dir  ${c_file} DIRECTORY)
      string(REPLACE ${CheckRule_PREFIX} "" c_name_clean ${c_name})
      add_executable(${c_name_clean} ${c_file})
      target_include_directories(${c_name_clean}
        PUBLIC ${CheckRule_INCLUDES} ${Cppunit_INCLUDE_DIR})
      target_link_libraries(${c_name_clean} ${CheckRule_LINKS} ${Cppunit_LIBRARY})
      add_test(NAME ${c_name_clean}
        COMMAND ${c_name_clean} ${CheckRule_ARGS})
      list(APPEND l_test_list ${c_name_clean})
      list(APPEND l_dir_list  ${c_dir})
      add_custom_target(${c_name_clean}-gdb
        COMMAND ${CheckRule_ENV} gdb -ex run --args ${c_name_clean} ${CheckRule_ARGS} -n)
    endforeach()
  endforeach()

  if (l_dir_list)
    list(REMOVE_DUPLICATES l_dir_list)
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${l_dir_list})
  endif()

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
