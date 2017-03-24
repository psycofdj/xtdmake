xtdmake_find_program(Xsltproc
  NAMES xsltproc
  DOC "rendering xslt stylehseets"
  URL "http://xmlsoft.org/"
  VERSION_OPT " --version | head -n1 | cut -d' ' -f3 | sed 's/,//g'"
  VERSION_POS "0"
  REQUIRED CheckRule_FIND_REQUIRED)

if (NOT Xsltproc_FOUND)
  set(CheckRule_FOUND 0)
  message(STATUS "Found module CheckRule : FALSE (unmet required dependencies)")
  if (CheckRule_FIND_REQUIRED)
    message(FATAL_ERROR "Unable to load required module CheckRule")
  endif()
else()
  set(CheckRule_FOUND 1)
  message(STATUS "Found module CheckRule : TRUE")
endif()


add_custom_target(check)
add_custom_target(check-verbose)
add_custom_target(check-clean)

set(CheckRule_FOUND 1)
set(CheckRule_DEFAULT_ARGS           ""                                         CACHE STRING "CheckRule default unit-test binary parameter template")
set(CheckRule_DEFAULT_ENV            ""                                         CACHE STRING "CheckRule default unit-test binary environment template")
set(CheckRule_DEFAULT_INCLUDES       ""                                         CACHE STRING "CheckRule default unit-test header includes")
set(CheckRule_DEFAULT_LINKS          ""                                         CACHE STRING "CheckRule default unit-test link libraries")
set(CheckRule_DEFAULT_DIRECTORY      "\${CMAKE_CURRENT_SOURCE_DIR}/unit"        CACHE STRING "CheckRule default unit-test source directory")
set(CheckRule_DEFAULT_PATTERNS       ".c;.cc;.cpp"                              CACHE STRING "CheckRule default wildcard to find unit-test source files in directory")
set(CheckRule_DEFAULT_JOBS           "1"                                        CACHE STRING "CheckRule default parallel jobs to run unit-test")
set(CheckRule_DEFAULT_PREFIX         "Test"                                     CACHE STRING "CheckRule default unit-test source file prefix")
set(CheckRule_DEFAULT_CMAKEVARS_NAME "\${CMAKE_CURRENT_BINARY_DIR}/cmakevars.h" CACHE STRING "CheckRule default filename for cmakevars include")

message(STATUS "Found module CheckRule : TRUE")

define_property(TARGET
  PROPERTY TESTLIST
  BRIEF_DOCS "Internal property to communicate test list to other rules"
  FULL_DOCS  "Internal property to communicate test list to other rules")

define_property(TARGET
  PROPERTY ARGS
  BRIEF_DOCS "Internal property to communicate test arguments other rules"
  FULL_DOCS  "Internal property to communicate test arguments to other rules")

define_property(TARGET
  PROPERTY ENV
  BRIEF_DOCS "Internal property to communicate test envs other rules"
  FULL_DOCS  "Internal property to communicate test envs to other rules")

define_property(TARGET
  PROPERTY MANUAL_TESTS
  BRIEF_DOCS "Internal property to communicate test envs other rules"
  FULL_DOCS  "Internal property to communicate test envs to other rules")

define_property(TEST
  PROPERTY BIN
  BRIEF_DOCS "Internal property to communicate test envs other rules"
  FULL_DOCS  "Internal property to communicate test envs to other rules")

define_property(TEST
  PROPERTY ARGS
  BRIEF_DOCS "Internal property to communicate test envs other rules"
  FULL_DOCS  "Internal property to communicate test envs to other rules")


function(add_check_test module name)
  set(multiValueArgs  ENVIRONMENT COMMAND)
  set(oneValueArgs    )
  set(options         )
  cmake_parse_arguments(__x
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  set(CheckRule_OUTPUT "${CMAKE_BINARY_DIR}/reports/check/${module}")

  list(GET __x_COMMAND 0 l_bin)
  list(REMOVE_AT __x_COMMAND 0)

  add_test(NAME t${name}
    COMMAND  ${l_bin} ${__x_COMMAND}
  )

  set_tests_properties(t${name} PROPERTIES
    BIN         "${l_bin}"
    ARGS        "${__x_COMMAND}"
    ENVIRONMENT "${__x_ENVIRONMENT}")

  if (NOT TARGET ${module}-check)
    add_custom_target(${module}-check
      DEPENDS
      ${CheckRule_OUTPUT}/tests.xml
      ${CheckRule_OUTPUT}/index.html
      ${CheckRule_OUTPUT}/status.json)
    set_property(TARGET ${module}-check PROPERTY MANUAL_TESTS "")
  endif()

  set_property(TARGET ${module}-check APPEND PROPERTY MANUAL_TESTS "t${name}")
endfunction()


function(add_check module)
  set(multiValueArgs  PATTERNS INCLUDES LINKS ENV ARGS)
  set(oneValueArgs    DIRECTORY PREFIX JOBS CMAKEVARS_NAME)
  set(options         NO_DEFAULT_ENV NO_DEFAULT_ARGS NO_DEFAULT_INCLUDES NO_DEFAULT_LINKS)
  cmake_parse_arguments(CheckRule
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  xtdmake_set_default(CheckRule PATTERNS)
  xtdmake_set_default(CheckRule DIRECTORY)
  xtdmake_set_default(CheckRule PREFIX)
  xtdmake_set_default(CheckRule JOBS)
  xtdmake_set_default(CheckRule CMAKEVARS_NAME)

  configure_file(${XTDMake_HOME}/check/cmakevars.h.in ${CheckRule_CMAKEVARS_NAME})

  set(CheckRule_OUTPUT "${CMAKE_BINARY_DIR}/reports/check/${module}")

  if (NOT CheckRule_NO_DEFAULT_ARGS)
    xtdmake_eval(l_args "${CheckRule_DEFAULT_ARGS}")
    foreach (c_arg ${l_args})
      list(APPEND CheckRule_ARGS ${c_arg})
    endforeach()
  endif()

  if (NOT CheckRule_NO_DEFAULT_ENV)
    xtdmake_eval(l_args "${CheckRule_DEFAULT_ENV}")
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

  xtdmake_stringify(CheckRule_ENV)
  set(l_test_list    "")
  set(l_target_list  "")
  set(l_dir_list     "")

  if (EXISTS ${CheckRule_DIRECTORY})
    list(APPEND l_dir_list  ${CheckRule_DIRECTORY})
  endif()

  foreach(c_pattern ${CheckRule_PATTERNS})
    file(GLOB_RECURSE l_tests ${CheckRule_DIRECTORY}/${CheckRule_PREFIX}*${c_pattern})
    foreach(c_file ${l_tests})
      get_filename_component(c_name ${c_file} NAME_WE)
      xtdmake_get_directory(c_dir ${c_file})
      string(REPLACE ${CheckRule_PREFIX} "t" c_name_clean ${c_name})
      add_executable(${c_name_clean} ${c_file})
      if (CMAKE_VERSION VERSION_LESS 2.8.12)
        include_directories(BEFORE ${CheckRule_INCLUDES} ${Cppunit_INCLUDE_DIR})
      else()
        target_include_directories(${c_name_clean} BEFORE 
          PUBLIC ${CheckRule_INCLUDES} ${Cppunit_INCLUDE_DIR})
      endif()
      target_link_libraries(${c_name_clean} ${CheckRule_LINKS} ${Cppunit_LIBRARY})
      add_test(NAME ${c_name_clean}
        COMMAND ${c_name_clean} ${CheckRule_ARGS})
      set_property(TEST ${c_name_clean} PROPERTY ARGS "${CheckRule_ARGS}")
      set_property(TEST ${c_name_clean} PROPERTY ENVS "${CheckRule_ENV}")
      list(APPEND l_test_list ${c_name_clean})
      list(APPEND l_target_list ${c_name_clean})
      list(APPEND l_dir_list  ${c_dir})
      add_custom_target(${module}-check-ut-${c_name_clean}
        COMMAND ${CheckRule_ENV} ./${c_name_clean} ${CheckRule_ARGS}
        DEPENDS ${c_name_clean})
      add_custom_target(${module}-check-ut-${c_name_clean}-gdb
        COMMAND ${CheckRule_ENV} gdb -ex run --args ${c_name_clean} ${CheckRule_ARGS}
        DEPENDS ${c_name_clean})
      add_custom_target(${module}-check-ut-${c_name_clean}-cmd
        COMMAND echo ${CheckRule_ENV} ${CMAKE_CURRENT_BINARY_DIR}/${c_name_clean} ${CheckRule_ARGS})
    endforeach()
  endforeach()

  if (NOT TARGET ${module}-check)
    add_custom_target(${module}-check
      DEPENDS
      ${CheckRule_OUTPUT}/tests.xml
      ${CheckRule_OUTPUT}/index.html
      ${CheckRule_OUTPUT}/status.json)
    set_property(TARGET ${module}-check PROPERTY MANUAL_TESTS "")
  endif()

  get_target_property(l_manual_tests ${module}-check MANUAL_TESTS)
  foreach (c_test ${l_manual_tests})
    list(APPEND l_test_list ${c_test})
    get_property(l_env  TEST ${c_test} PROPERTY ENVIRONMENT)
    get_property(l_bin  TEST ${c_test} PROPERTY BIN)
    get_property(l_args TEST ${c_test} PROPERTY ARGS)
    add_custom_target(${module}-check-ut-${c_test}
      COMMAND ${l_bin} ${l_args})
    add_custom_target(${module}-check-ut-${c_test}-cmd
      COMMAND echo ${l_env} ${l_bin} ${l_args})
  endforeach()

  if (l_dir_list)
    list(REMOVE_DUPLICATES l_dir_list)
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${l_dir_list})
  endif()

  string(REPLACE ";" "\\|" l_test_regex "${l_test_list}")
  add_custom_target(${module}-check-build
    DEPENDS ${l_target_list})

  add_custom_target(${module}-check-run-forced
    COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/testing
    COMMAND ${CheckRule_ENV} ctest  -j ${CheckRule_JOBS} -T Test -R "\\(${l_test_regex}\\)" || true
    COMMAND rm -rf ${CMAKE_CURRENT_BINARY_DIR}/testing)

  add_custom_target(${module}-check-run-verbose
    COMMAND $(MAKE) ${module}-check-build
    COMMAND ${CheckRule_ENV} ctest --output-on-failure -j ${CheckRule_JOBS} -T Test -R "\\(${l_test_regex}\\)" || true)

  add_custom_target(${module}-check-run
    DEPENDS ${module}-check-build
    COMMAND $(MAKE) ${module}-check-run-forced)

  add_custom_command(
    COMMENT "Generating ${module} tests HTML and XML reports"
    OUTPUT
    ${CheckRule_OUTPUT}/tests.xml
    ${CheckRule_OUTPUT}/index.html
    ${CheckRule_OUTPUT}/status.json
    DEPENDS
    ${l_target_list}
    ${XTDMake_HOME}/check/stylesheet.xsl
    ${XTDMake_HOME}/check/status.py
    COMMAND mkdir -p ${CheckRule_OUTPUT}
    COMMAND rm -rf Testing/
    COMMAND touch DartConfiguration.tcl
    COMMAND $(MAKE) ${module}-check-run-forced
    COMMAND cp Testing/*/*.xml ${CheckRule_OUTPUT}/tests.xml
    COMMAND ${Xsltproc_EXECUTABLE} ${XTDMake_HOME}/check/stylesheet.xsl ${CheckRule_OUTPUT}/tests.xml > ${CheckRule_OUTPUT}/index.html
    COMMAND ${XTDMake_HOME}/check/status.py --module ${module} --input-file ${CheckRule_OUTPUT}/tests.xml --output-file ${CheckRule_OUTPUT}/status.json
    )

  set_target_properties(${module}-check             PROPERTIES TESTLIST "${l_target_list}")
  set_target_properties(${module}-check-run         PROPERTIES TESTLIST "${l_target_list}")
  set_target_properties(${module}-check-run-forced  PROPERTIES TESTLIST "${l_target_list}")
  set_target_properties(${module}-check-run-verbose PROPERTIES TESTLIST "${l_target_list}")

  add_custom_target(${module}-check-clean
    COMMAND rm -rf ${CheckRule_OUTPUT} Testing DartConfiguration.tcl)
  add_dependencies(check          ${module}-check)
  add_dependencies(check-verbose  ${module}-check-run-verbose)
  add_dependencies(check-clean    ${module}-check-clean)
endfunction()
