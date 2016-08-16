find_program(Cloc_EXECUTABLE
  NAMES cloc
  DOC "cloc code line counting tool (http://cloc.sourceforge.net/)"
)

set(Cloc_FOUND 0)
if (NOT Cloc_EXECUTABLE)
  if (Cloc_FIND_REQUIRED)
    message(SEND_ERROR "Unable to find cloc program, please install cloc (http://cloc.sourceforge.net/)")
  else()
    message(STATUS "Could not find Cloc")
  endif()
else()
  set(Cloc_FOUND 1)
  message(STATUS "Found Cloc package")
endif()

if (Cppcheck_FIND_REQUIRED)
  find_package(Xsltproc REQUIRED)
else()
  find_package(Xsltproc)
endif()


if (Cloc_FOUND)
  add_custom_target(cloc)
  add_custom_target(cloc-clean)
  function(add_cloc module)
    set(CMAKE_CLOC_OUTPUT "${CMAKE_BINARY_DIR}/reports/${module}/cloc")
    file(GLOB_RECURSE files_cloc
      "${CMAKE_CURRENT_SOURCE_DIR}/doc/*.cc"
      "${CMAKE_CURRENT_SOURCE_DIR}/doc/*.hh"
      "${CMAKE_CURRENT_SOURCE_DIR}/doc/*.hxx")

    add_custom_command(
      OUTPUT ${CMAKE_CLOC_OUTPUT}/cloc.xml
      COMMAND mkdir -p ${CMAKE_CLOC_OUTPUT}
      COMMAND ${Cloc_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/src --xml --out ${CMAKE_CLOC_OUTPUT}/cloc.xml --by-file-by-lang
      DEPENDS ${files_cloc}
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMENT "Generating ${module} cloc report" VERBATIM)

    add_custom_command(
      OUTPUT ${CMAKE_CLOC_OUTPUT}/cloc.html
      COMMAND mkdir -p ${CMAKE_CLOC_OUTPUT}
      COMMAND xsltproc ${PROJECT_SOURCE_DIR}/xtdmake/cloc/stylesheet.xsl ${CMAKE_CLOC_OUTPUT}/cloc.xml > ${CMAKE_CLOC_OUTPUT}/cloc.html
      DEPENDS ${CMAKE_CLOC_OUTPUT}/cloc.xml
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMENT "Generating ${module} cloc report" VERBATIM)

    add_custom_target(cloc-${module}
      DEPENDS ${CMAKE_CLOC_OUTPUT}/cloc.html)
    add_custom_target(cloc-${module}-clean
      COMMAND rm -rf ${CMAKE_CLOC_OUTPUT})
    add_dependencies(cloc       cloc-${module})
    add_dependencies(cloc-clean cloc-${module}-clean)
  endfunction()
endif()



