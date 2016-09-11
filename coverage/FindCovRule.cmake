add_custom_target(cov)
add_custom_target(cov-clean)

xtdmake_find_program(Lcov
  NAMES lcov
  DOC "code coverage generation tool"
  URL "http://ltp.sourceforge.net/coverage/lcov.php"
  REQUIRED CovRule_FIND_REQUIRED
  VERSION_OPT "--version"
  VERSION_POS 3)

xtdmake_find_program(Genhtml
  NAMES genhtml
  DOC "Html report generation tool"
  URL "http://ltp.sourceforge.net/coverage/lcov.php"
  REQUIRED CovRule_FIND_REQUIRED
  VERSION_OPT "--version"
  VERSION_POS 3)


set(CovRule_FOUND 0)
if (NOT Lcov_FOUND OR NOT Genhtml_FOUND OR NOT CheckRule_FOUND)
  message(STATUS "Found module CovRule : FALSE (unmet required dependencies)")
  if (CovRule_FIND_REQUIRED)
    message(FATAL_ERROR "Unable to load required module CovRule")
  endif()
else()
  set(CovRule_FOUND 1)
  message(STATUS "Found module CovRule : TRUE")
endif()

if (NOT CovRule_FOUND)
  function(add_cov module)
    add_custom_target(cov-${module}
      COMMAND echo "warning: cov rule is disabled due to missing dependencies")
    add_custom_target(cov-${module}-clean
      COMMAND echo "warning: cov rule is disabled due to missing dependencies")
    add_dependencies(cov       cov-${module})
    add_dependencies(cov-clean cov-${module}-clean)
  endfunction()
else()
  function(add_cov module)
    set(multiValueArgs  EXCLUDE_PATTERNS DEFAULT_EXCLUDE_PATTERNS)
    set(oneValueArgs    )
    set(options         )
    cmake_parse_arguments(CovRule
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN})

    set(CovRule_OUTPUT   "${CMAKE_BINARY_DIR}/reports/${module}/coverage")
    file(GLOB l_depends "${CMAKE_CURRENT_BINARY_DIR}/*.gcno")


    if ("${CovRule_DEFAULT_EXCLUDE_PATTERNS}" STREQUAL "")
      set(CovRule_DEFAULT_EXCLUDE_PATTERNS "*Test*.*")
    endif()

    string(REPLACE ";" " " "${CovRule_EXCLUDE_PATTERNS}"         "${CovRule_EXCLUDE_PATTERNS}")
    string(REPLACE ";" " " "${CovRule_DEFAULT_EXCLUDE_PATTERNS}" "${CovRule_DEFAULT_EXCLUDE_PATTERNS}")
    get_target_property(l_check_dependencies check-${module}-build MYDEPENDS)

    add_custom_command(
      COMMENT "Generating ${module} coverage informations"
      OUTPUT  ${CMAKE_CURRENT_BINARY_DIR}/coverage.info
      DEPENDS check-${module}-build ${l_check_dependencies}
      COMMAND ${Lcov_EXECUTABLE} -q -c -i -d ${CMAKE_CURRENT_BINARY_DIR} -o ${CMAKE_CURRENT_BINARY_DIR}/coverage-initial.info
      COMMAND bash -c "while [ -d ${CMAKE_CURRENT_BINARY_DIR}/testing ]; do sleep 1; done"
      COMMAND find . -name '*.gcda' | xargs rm -f
      COMMAND $(MAKE) check-${module}-forced-run  > /dev/null 2>&1
      COMMAND ${Lcov_EXECUTABLE} -q --rc lcov_branch_coverage=1 -c -d ${CMAKE_CURRENT_BINARY_DIR} -o ${CMAKE_CURRENT_BINARY_DIR}/coverage-run.info
      COMMAND ${Lcov_EXECUTABLE} -q --rc lcov_branch_coverage=1 --no-recursion -a ${CMAKE_CURRENT_BINARY_DIR}/coverage-initial.info -a ${CMAKE_CURRENT_BINARY_DIR}/coverage-run.info -o ${CMAKE_CURRENT_BINARY_DIR}/coverage.info
      COMMAND ${Lcov_EXECUTABLE} -q --rc lcov_branch_coverage=1 -e ${CMAKE_CURRENT_BINARY_DIR}/coverage.info "${CMAKE_CURRENT_SOURCE_DIR}/*" -o ${CMAKE_CURRENT_BINARY_DIR}/coverage.info
      COMMAND ${Lcov_EXECUTABLE} -q --rc lcov_branch_coverage=1 -r ${CMAKE_CURRENT_BINARY_DIR}/coverage.info ${CovRule_DEFAULT_EXCLUDE_PATTERNS} -o ${CMAKE_CURRENT_BINARY_DIR}/coverage.info
      VERBATIM)

    add_custom_command(
      COMMENT "Generating ${module} coverage HTML and XML reports"
      OUTPUT ${CovRule_OUTPUT}/index.html ${CovRule_OUTPUT}/coverage.xml
      DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/coverage.info
      COMMAND ${Genhtml_EXECUTABLE} -q -o ${CovRule_OUTPUT}/ -p ${CMAKE_CURRENT_SOURCE_DIR}/ --function-coverage --branch-coverage -t "${module} unit test coverage" --demangle-cpp ${CMAKE_CURRENT_BINARY_DIR}/coverage.info --legend -s
      COMMAND ${PROJECT_SOURCE_DIR}/xtdmake/coverage/lcov_cobertura.py ${CMAKE_CURRENT_BINARY_DIR}/coverage.info -d -o ${CovRule_OUTPUT}/coverage.xml
      )

    add_custom_target(cov-${module}
      DEPENDS ${CovRule_OUTPUT}/index.html)
    add_custom_target(cov-${module}-clean
      COMMAND rm -rf ${CovRule_OUTPUT} ${CMAKE_CURRENT_BINARY_DIR}/coverage.info)
    add_dependencies(cov       cov-${module})
    add_dependencies(cov-clean cov-${module}-clean)
  endfunction()
endif()
