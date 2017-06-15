set(XTDMake_MAJOR   1)
set(XTDMake_MINOR   0)
set(XTDMake_PATH    0)
set(XTDMake_VERSION "${XTDMake_PATH}.${XTDMake_MINOR}.${XTDMake_PATCH}")
set(XTDMake_HOME    "${CMAKE_CURRENT_LIST_DIR}")

# add subdirectories to cmake path
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cppcheck")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/doc")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/doc-coverage")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cloc")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/interface")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/tracking")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/check")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/coverage")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/memcheck")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/codedup")

include(CMakeParseArguments)
include(xtdmake_lang)
include(xtdmake_eval)
include(xtdmake_set_default)
include(xtdmake_find_program)
include(xtdmake_find_python_module)

message(STATUS "Found module XTDMake : TRUE")

function(xtdmake_init project dir)
  set(multiValueArgs  )
  set(oneValueArgs    StaticShared DocRule DocCoverageRule CppcheckRule ClocRule Tracking Cppunit CheckRule CovRule MemcheckRule CodeDupRule Reports)
  set(options         )
  cmake_parse_arguments(__x
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})
  foreach(c_module ${oneValueArgs})
    if (__x_${c_module} STREQUAL REQUIRED)
      find_package(${c_module} REQUIRED)
    else()
      find_package(${c_module})
    endif()
  endforeach()
endfunction()
