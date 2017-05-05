add_custom_target(memcheck)
add_custom_target(memcheck-clean)

xtdmake_find_program(Valgrind
  NAMES valgrind
  DOC "Dynamic analysis tool"
  URL "http://valgrind.org/"
  REQUIRED MemcheckRule_FIND_REQUIRED
  VERSION_OPT "--version | tr -- '-' ' '"
  VERSION_POS 1)

xtdmake_find_program(Xsltproc
  NAMES xsltproc
  DOC "rendering xslt stylehseets"
  URL "http://xmlsoft.org/"
  VERSION_OPT " --version | head -n1 | cut -d' ' -f3 | sed 's/,//g'"
  VERSION_POS "0"
  REQUIRED CppcheckRule_FIND_REQUIRED)

set(MemcheckRule_FOUND 0)
if (NOT Valgrind_FOUND OR NOT Xsltproc_FOUND)
  message(STATUS "Found module MemcheckRule : FALSE (unmet required dependencies)")
  if (MemcheckRule_FIND_REQUIRED)
    message(FATAL_ERROR "Unable to load required module MemcheckRule")
  endif()
else()
  set(MemcheckRule_FOUND 1)
  message(STATUS "Found module MemcheckRule : TRUE")
endif()

if (NOT MemcheckRule_FOUND)
  function(add_memcheck module)
    add_custom_target(${module}-memcheck
      COMMAND echo "warning: memcheck rule is disabled due to missing dependencies")
    add_custom_target(${module}-memcheck-clean
      COMMAND echo "warning: memcheck rule is disabled due to missing dependencies")
    add_dependencies(memcheck       ${module}-memcheck)
    add_dependencies(memcheck-clean ${module}-memcheck-clean)
  endfunction()
else()
  function(add_memcheck module)
    set(multiValueArgs  SUPPRESSIONS)
    set(oneValueArgs    )
    set(options         )
    cmake_parse_arguments(MemcheckRule
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN})

    set(l_supprs "")
    foreach(c_suppr ${MemcheckRule_SUPPRESSIONS})
      set(l_supprs "--suppressions=${c_suppr}")
    endforeach()

    set(MemcheckRule_OUTPUT   "${PROJECT_BINARY_DIR}/reports/memcheck/${module}")

    get_target_property(l_test_list ${module}-check TESTLIST)
    if ("${l_test_list}" STREQUAL "NOTFOUND")
      message(FATAL_ERROR "Unable to find defined tests, memchecks depends on check rule")
    endif()

    set(l_depends "")
    foreach(c_test ${l_test_list})
      get_property(c_test_args TEST ${c_test} PROPERTY ARGS)

      if (Valgrind_VERSION VERSION_LESS 3.9.0)
        add_custom_command(
          COMMENT "Performing memory analysis for ${module} : ${c_test}"
          OUTPUT  ${CMAKE_CURRENT_BINARY_DIR}/${c_test}.memcheck.xml
          DEPENDS ${c_test} ${MemcheckRule_SUPPRESSIONS}
          COMMAND valgrind
          --tool=memcheck
          --leak-check=full
          --num-callers=50
          --show-reachable=no
          --xml=yes --xml-file=${CMAKE_CURRENT_BINARY_DIR}/${c_test}.memcheck.xml
          ${l_supprs}
          --
          ./${c_test} ${c_test_args} > /dev/null 2>&1 || true
          VERBATIM)
      else()
        add_custom_command(
          COMMENT "Performing memory analysis for ${module} : ${c_test}"
          OUTPUT  ${CMAKE_CURRENT_BINARY_DIR}/${c_test}.memcheck.xml
          DEPENDS ${c_test} ${MemcheckRule_SUPPRESSIONS}
          COMMAND valgrind
          --tool=memcheck
          --leak-check=full
          --show-leak-kinds=all
          --num-callers=500
          --show-reachable=no
          --xml=yes --xml-file=${CMAKE_CURRENT_BINARY_DIR}/${c_test}.memcheck.xml
          ${l_supprs}
          --
          ./${c_test} ${c_test_args} > /dev/null 2>&1 || true
          VERBATIM)
      endif()

      list(APPEND l_depends ${CMAKE_CURRENT_BINARY_DIR}/${c_test}.memcheck.xml)
    endforeach()

    add_custom_command(
      COMMENT "Generating ${module} memcheck XML and HTML reports"
      OUTPUT
      ${MemcheckRule_OUTPUT}/memcheck.js
      ${MemcheckRule_OUTPUT}/memcheck.json
      ${MemcheckRule_OUTPUT}/index.html
      ${MemcheckRule_OUTPUT}/status.json
      DEPENDS
      ${l_depends}
      ${XTDMake_HOME}/memcheck/readfiles.py
      ${XTDMake_HOME}/memcheck/stylesheet.xsl
      ${XTDMake_HOME}/memcheck/index.html
      ${XTDMake_HOME}/memcheck/status.py
      COMMAND mkdir -p ${MemcheckRule_OUTPUT}
      COMMAND ${XTDMake_HOME}/memcheck/readfiles.py ${l_depends} > ${MemcheckRule_OUTPUT}/memcheck.json
      COMMAND echo -n "var g_data = " > ${MemcheckRule_OUTPUT}/memcheck.js
      COMMAND cat ${MemcheckRule_OUTPUT}/memcheck.json >> ${MemcheckRule_OUTPUT}/memcheck.js
      COMMAND echo -n ";" >> ${MemcheckRule_OUTPUT}/memcheck.js
      COMMAND cp ${XTDMake_HOME}/memcheck/index.html ${MemcheckRule_OUTPUT}/index.html
      COMMAND ${XTDMake_HOME}/memcheck/status.py --module ${module} --input-file=${MemcheckRule_OUTPUT}/memcheck.json --output-file=${MemcheckRule_OUTPUT}/status.json
      VERBATIM)

    add_custom_target(${module}-memcheck
      DEPENDS
      ${MemcheckRule_OUTPUT}/memcheck.json
      ${MemcheckRule_OUTPUT}/index.html
      ${MemcheckRule_OUTPUT}/memcheck.js
      ${MemcheckRule_OUTPUT}/status.json)

    add_custom_target(${module}-memcheck-clean
      COMMAND rm -rf  ${MemcheckRule_OUTPUT} ${l_depends})
    add_dependencies(memcheck       ${module}-memcheck)
    add_dependencies(memcheck-clean ${module}-memcheck-clean)
  endfunction()
endif()
