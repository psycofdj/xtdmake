add_custom_target(memcheck)
add_custom_target(memcheck-clean)

xtdmake_find_program(Valgrind
  NAMES valgrind
  DOC "Dynamic analisys tool"
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
    set(multiValueArgs  )
    set(oneValueArgs    )
    set(options         )
    cmake_parse_arguments(MemcheckRule
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
      ${ARGN})


    set(MemcheckRule_OUTPUT   "${CMAKE_BINARY_DIR}/reports/${module}/memcheck")


    get_target_property(l_test_list ${module}-check TESTLIST)
    if ("${l_test_list}" STREQUAL "NOTFOUND")
      message(FATAL_ERROR "Unable to find defined tests, memchecks depends on check rule")
    endif()

    set(l_depends "")
    foreach(c_test ${l_test_list})
      get_target_property(c_test_args ${c_test} ARGS)
      add_custom_command(
        COMMENT "Performing memory analisys for ${module} : ${c_test}"
        OUTPUT  ${CMAKE_CURRENT_BINARY_DIR}/${c_test}.memcheck.xml
        DEPENDS ${c_test}
        COMMAND valgrind
        --tool=memcheck
        --leak-check=full
        --show-leak-kinds=all
        --num-callers=500
        --xml=yes --xml-file=${CMAKE_CURRENT_BINARY_DIR}/${c_test}.memcheck.xml
        --
        ./${c_test} ${c_test_args}
        VERBATIM)
      list(APPEND l_depends ${CMAKE_CURRENT_BINARY_DIR}/${c_test}.memcheck.xml)
    endforeach()


    add_custom_command(
      COMMENT "Generating ${module} memcheck XML and HTML reports"
      OUTPUT
      ${MemcheckRule_OUTPUT}/memcheck.xml
      ${MemcheckRule_OUTPUT}/memcheck.html
      DEPENDS
      ${l_depends}
      ${PROJECT_SOURCE_DIR}/xtdmake/memcheck/readfiles.py
      ${PROJECT_SOURCE_DIR}/xtdmake/memcheck/stylesheet.xsl
      COMMAND
      mkdir -p ${MemcheckRule_OUTPUT}
      COMMAND
      ${PROJECT_SOURCE_DIR}/xtdmake/memcheck/readfiles.py ${l_depends} > ${MemcheckRule_OUTPUT}/memcheck.xml
      COMMAND
      ${Xsltproc_EXECUTABLE}
      ${PROJECT_SOURCE_DIR}/xtdmake/memcheck/stylesheet.xsl
      ${MemcheckRule_OUTPUT}/memcheck.xml > ${MemcheckRule_OUTPUT}/memcheck.html
      VERBATIM)

    add_custom_target(${module}-memcheck
      DEPENDS ${MemcheckRule_OUTPUT}/memcheck.xml ${MemcheckRule_OUTPUT}/memcheck.html)

    stringify(l_depends)
    add_custom_target(${module}-memcheck-clean
      COMMAND rm -rf "${l_depends}")
    add_dependencies(memcheck       ${module}-memcheck)
    add_dependencies(memcheck-clean ${module}-memcheck-clean)
  endfunction()
endif()
