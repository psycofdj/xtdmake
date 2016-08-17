find_program(Cppcheck_EXECUTABLE
  NAMES cppcheck
  DOC "cppcheck static code anylyser tool (http://cppcheck.sourceforge.net/)"
)

if (Cppcheck_FIND_REQUIRED)
  find_package(Xsltproc REQUIRED)
else()
  find_package(Xsltproc)
endif()

set(Cppcheck_FOUND 0)
if (NOT Cppcheck_EXECUTABLE)
  if (Cppcheck_FIND_REQUIRED)
    message(SEND_ERROR "Cannot find cppcheck required program, please install (http://cppcheck.sourceforge.net/)")
  else()
    message(STATUS "Found Cppcheck : FALSE")
  endif()
else()
  if (NOT Xsltproc_FOUND)
    if (Cppcheck_FIND_REQUIRED)
      message(SEND_ERROR "Cannot use Cppcheck without xsltproc package")
    else()
      message(STATUS "Found Cppcheck : FALSE, cannot use without xsltproc package")
    endif()
  else()
    set(Cppcheck_FOUND 1)
    message(STATUS "Found Cppcheck : TRUE")
  endif()
endif()


if(Cppcheck_FOUND)
  add_custom_target(cppcheck)
  add_custom_target(cppcheck-clean)

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
