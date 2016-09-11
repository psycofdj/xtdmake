xtdmake_find_program(Cloc
  NAMES cloc
  DOC "cloc code line counting tool"
  URL "http://cloc.sourceforge.net/"
  VERSION_OPT "--version"
  VERSION_POS "0"
  REQUIRED ClocRule_FIND_REQUIRED)

xtdmake_find_program(Xsltproc
  NAMES xsltproc
  DOC "rendering xslt stylehseets"
  URL "http://xmlsoft.org/"
  VERSION_OPT " --version | head -n1 | cut -d' ' -f3 | sed 's/,//g'"
  VERSION_POS "0"
  REQUIRED ClocRule_FIND_REQUIRED)

if (NOT Cloc_FOUND OR NOT Xsltproc_FOUND)
  set(ClocRule_FOUND 0)
  message(STATUS "Found module ClocRule : FALSE (unmet required dependencies)")
  if (ClocRule_FIND_REQUIRED)
    message(FATAL_ERROR "Unable to load required module ClocRule")
  endif()
else()
  set(ClocRule_FOUND 1)
  message(STATUS "Found module ClocRule : TRUE")
endif()

add_custom_target(cloc)
add_custom_target(cloc-clean)
if (NOT ClocRule_FOUND)
  function(add_cloc module)
    add_custom_target(cloc-${module}
      COMMAND echo "warning: cloc rule disabled due to missing dependencies")
    add_custom_target(cloc-${module}-clean
      COMMAND echo "warning: cloc rule disabled due to missing dependencies")
    add_dependencies(cloc       cloc-${module})
    add_dependencies(cloc-clean cloc-${module}-clean)
  endfunction()
else()
  function(add_cloc module)
    set(CMAKE_CLOC_OUTPUT "${CMAKE_BINARY_DIR}/reports/${module}/cloc")
    file(GLOB_RECURSE files_cloc
      "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cc"
      "${CMAKE_CURRENT_SOURCE_DIR}/src/*.c"
      "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
      "${CMAKE_CURRENT_SOURCE_DIR}/src/*.h"
      "${CMAKE_CURRENT_SOURCE_DIR}/src/*.hh"
      "${CMAKE_CURRENT_SOURCE_DIR}/src/*.hxx"
      "${CMAKE_CURRENT_SOURCE_DIR}/src/*.hpp")

    add_custom_command(
      COMMENT "Generating ${module} cloc HTML and XML reports"
      OUTPUT ${CMAKE_CLOC_OUTPUT}/cloc.xml ${CMAKE_CLOC_OUTPUT}/cloc.html
      COMMAND mkdir -p ${CMAKE_CLOC_OUTPUT}
      COMMAND ${Cloc_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/src --xml --out ${CMAKE_CLOC_OUTPUT}/cloc.xml --by-file-by-lang
      COMMAND ${Xsltproc_EXECUTABLE} ${PROJECT_SOURCE_DIR}/xtdmake/cloc/stylesheet.xsl ${CMAKE_CLOC_OUTPUT}/cloc.xml > ${CMAKE_CLOC_OUTPUT}/cloc.html
      DEPENDS ${files_cloc}
      VERBATIM)

    add_custom_target(cloc-${module}
      DEPENDS ${CMAKE_CLOC_OUTPUT}/cloc.html)
    add_custom_target(cloc-${module}-clean
      COMMAND rm -rf ${CMAKE_CLOC_OUTPUT})
    add_dependencies(cloc       cloc-${module})
    add_dependencies(cloc-clean cloc-${module}-clean)
  endfunction()
endif()
