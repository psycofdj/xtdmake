add_custom_target(cov)
add_custom_target(cov-clean)

xtdmake_find_program(Lcov
  NAMES lcov
  DOC "code coverage generation tool"
  URL "http://ltp.sourceforge.net/coverage/lcov.php"
  REQUIRED ${CovRule_FIND_REQUIRED}
  VERSION_OPT "--version"
  VERSION_POS 3)

xtdmake_find_program(Genhtml
  NAMES genhtml
  DOC "Html report generation tool"
  URL "http://ltp.sourceforge.net/coverage/lcov.php"
  REQUIRED ${CovRule_FIND_REQUIRED}
  VERSION_OPT "--version"
  VERSION_POS 3)


set(CovRule_DEFAULT_EXCLUDE_PATTERNS "Test*.*" CACHE STRING "CovRule default file exclude wildcards")
set(CovRule_DEFAULT_MIN_PERCENT      "30"      CACHE STRING "CovRule default mimunim coverage percentage to consider task successful")
set(CovRule_FOUND 0)

execute_process(
  COMMAND bash ${XTDMake_HOME}/coverage/clean-gcno.sh ${PROJECT_BINARY_DIR}
  )


if (NOT Lcov_FOUND OR NOT Genhtml_FOUND OR NOT CheckRule_FOUND)
  message(STATUS "Found module CovRule : FALSE (unmet required dependencies)")
  if (CovRule_FIND_REQUIRED)
    message(FATAL_ERROR "Unable to load required module CovRule")
  endif()
else()
  set(CovRule_FOUND 1)
  message(STATUS "Found module CovRule : TRUE")
endif()

if (NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
  function(add_cov module)
    add_custom_target(${module}-cov
      COMMAND echo "warning: cov rule is disabled due release build")
    add_custom_target(${module}-cov-clean
      COMMAND echo "warning: cov rule is disabled due release build")
    add_dependencies(cov       ${module}-cov)
    add_dependencies(cov-clean ${module}-cov-clean)
  endfunction()
else()
  if (NOT CovRule_FOUND)
    function(add_cov module)
      add_custom_target(${module}-cov
        COMMAND echo "warning: cov rule is disabled due to missing dependencies")
      add_custom_target(${module}-cov-clean
        COMMAND echo "warning: cov rule is disabled due to missing dependencies")
      add_dependencies(cov       ${module}-cov)
      add_dependencies(cov-clean ${module}-cov-clean)
    endfunction()
  else()
    function(add_cov module)
      set(multiValueArgs  EXCLUDE_PATTERNS)
      set(oneValueArgs    MIN_PERCENT)
      set(options         )
      cmake_parse_arguments(CovRule
        "${options}"
        "${oneValueArgs}"
        "${multiValueArgs}"
        ${ARGN})

      set(CovRule_OUTPUT   "${PROJECT_BINARY_DIR}/reports/coverage/${module}")
      xtdmake_set_default(CovRule EXCLUDE_PATTERNS)
      xtdmake_set_default(CovRule MIN_PERCENT)

      get_target_property(l_test_list ${module}-check TESTLIST)
      if ("${l_test_list}" STREQUAL "NOTFOUND")
        message(FATAL_ERROR "Unable to find defined tests, memchecks depends on check rule")
      endif()

      add_custom_command(
        COMMENT "Generating ${module} coverage informations"
        OUTPUT  ${CMAKE_CURRENT_BINARY_DIR}/coverage.info
        DEPENDS
        ${l_test_list}
        ${XTDMake_HOME}/coverage/coverage.sh
        COMMAND
        ${XTDMake_HOME}/coverage/coverage.sh
          --module "${module}"
          --exclude "${CovRule_EXCLUDE_PATTERNS}"
          --top-bindir "${PROJECT_BINARY_DIR}"
          --bindir "${CMAKE_CURRENT_BINARY_DIR}"
          --srcdir "${CMAKE_CURRENT_SOURCE_DIR}"
          --make-bin "${CMAKE_MAKE_PROGRAM}"
          --lcov-bin "${Lcov_EXECUTABLE}"
        )

      add_custom_command(
        COMMENT "Generating ${module} coverage HTML and XML reports"
        OUTPUT
        ${CovRule_OUTPUT}/index.html
        ${CovRule_OUTPUT}/coverage.xml
        ${CovRule_OUTPUT}/status.json
        DEPENDS
        ${CMAKE_CURRENT_BINARY_DIR}/coverage.info
        ${XTDMake_HOME}/coverage/status.py
        COMMAND mkdir -p ${CovRule_OUTPUT}/
        COMMAND ${Genhtml_EXECUTABLE} -q -o ${CovRule_OUTPUT}/ --function-coverage -t "${module} unit test coverage" --demangle-cpp ${CMAKE_CURRENT_BINARY_DIR}/coverage.info --legend -s
        COMMAND ${XTDMake_HOME}/coverage/lcov_cobertura.py ${CMAKE_CURRENT_BINARY_DIR}/coverage.info -d -o ${CovRule_OUTPUT}/coverage.xml
        COMMAND ${XTDMake_HOME}/coverage/status.py --module ${module}  --input-file=${CovRule_OUTPUT}/coverage.xml --output-file=${CovRule_OUTPUT}/status.json --min-percent=${CovRule_MIN_PERCENT}
        )

      add_custom_target(${module}-cov
        DEPENDS
        ${CovRule_OUTPUT}/index.html
        ${CovRule_OUTPUT}/coverage.xml
        ${CovRule_OUTPUT}/status.json)
      add_custom_target(${module}-cov-clean
        COMMAND rm -rf ${CovRule_OUTPUT} ${CMAKE_CURRENT_BINARY_DIR}/coverage.info)
      add_dependencies(cov       ${module}-cov)
      add_dependencies(cov-clean ${module}-cov-clean)
    endfunction()
  endif()
endif()
