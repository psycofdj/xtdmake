xtdmake_find_program(Cppcheck
  NAMES cppcheck
  DOC "cppcheck static code anylyser tool"
  URL "http://cppcheck.sourceforge.net/"
  REQUIRED CppcheckRule_FIND_REQUIRED
  VERSION_OPT "--version"
  VERSION_POS 1)

xtdmake_find_program(Xsltproc
  NAMES xsltproc
  DOC "rendering xslt stylehseets"
  URL "http://xmlsoft.org/"
  VERSION_OPT " --version | head -n1 | cut -d' ' -f3 | sed 's/,//g'"
  VERSION_POS "0"
  REQUIRED CppcheckRule_FIND_REQUIRED)

if (NOT Xsltproc_FOUND)
  set(CppcheckRule_FOUND 0)
  message(STATUS "Found module CppcheckRule : FALSE (unmet required dependencies)")
  if (CppcheckRule_FIND_REQUIRED)
    message(FATAL_ERROR "Unable to load required module CppcheckRule")
  endif()
else()
  set(CppcheckRule_FOUND 1)
  message(STATUS "Found module CppcheckRule : TRUE")
endif()


add_custom_target(cppcheck)
add_custom_target(cppcheck-clean)
if(NOT CppcheckRule_FOUND)
  function(add_cppcheck module)
    add_custom_target(cppcheck-${module}
      COMMAND echo "warning: cppcheck rule is disabled due to missing dependencies")
    add_custom_target(cppcheck-${module}-clean
      COMMAND echo "warning: cppcheck rule is disabled due to missing dependencies")
    add_dependencies(cppcheck       cppcheck-${module})
    add_dependencies(cppcheck-clean cppcheck-${module}-clean)
  endfunction()
else()
  function(add_cppcheck module)
    set(CMAKE_CPPCHECK_OUTPUT "${CMAKE_BINARY_DIR}/reports/${module}/cppcheck")
    file(GLOB_RECURSE files_cppcheck
      "${CMAKE_CURRENT_SOURCE_DIR}/doc/*.cc"
      "${CMAKE_CURRENT_SOURCE_DIR}/doc/*.hh"
      "${CMAKE_CURRENT_SOURCE_DIR}/doc/*.hxx")

    add_custom_command(
      OUTPUT ${CMAKE_CPPCHECK_OUTPUT}/cppcheck.xml
      COMMAND mkdir -p ${CMAKE_CPPCHECK_OUTPUT}
      COMMAND ${Cppcheck_EXECUTABLE} -q --xml ${CMAKE_CURRENT_SOURCE_DIR}/src 2> ${CMAKE_CPPCHECK_OUTPUT}/cppcheck.xml
      DEPENDS ${files_cppcheck}
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMENT "Generating ${module} cppcheck xml report" VERBATIM)

    add_custom_command(
      OUTPUT ${CMAKE_CPPCHECK_OUTPUT}/cppcheck.html
      COMMAND xsltproc ${PROJECT_SOURCE_DIR}/xtdmake/cppcheck/stylesheet.xsl ${CMAKE_CPPCHECK_OUTPUT}/cppcheck.xml > ${CMAKE_CPPCHECK_OUTPUT}/cppcheck.html
      DEPENDS ${CMAKE_CPPCHECK_OUTPUT}/cppcheck.xml
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMENT "Transforming ${module} cppcheck xml into html" VERBATIM)

    add_custom_target(cppcheck-${module}
      DEPENDS ${CMAKE_CPPCHECK_OUTPUT}/cppcheck.html)
    add_custom_target(cppcheck-${module}-clean
      COMMAND rm -rf ${CMAKE_CPPCHECK_OUTPUT})
    add_dependencies(cppcheck       cppcheck-${module})
    add_dependencies(cppcheck-clean cppcheck-${module}-clean)
  endfunction()
endif()