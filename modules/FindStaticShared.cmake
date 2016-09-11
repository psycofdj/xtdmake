set(StaticShared_FOUND 1)
message(STATUS "Found module StaticShared : TRUE")

function(add_shared_static_library name)
  set(multiValueArgs  INSTALL_HEADERS_PATTERNS)
  set(oneValueArgs    INSTALL_HEADERS_DESTINATION INSTALL_LIBS_DESTINATION DIRECTORY)
  set(options         NOINSTALL)

  cmake_parse_arguments(StaticShared
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  add_library(${name}-objs OBJECT ${ARGN})
  add_library(${name}_s STATIC $<TARGET_OBJECTS:${name}-objs>)
  add_library(${name}   SHARED $<TARGET_OBJECTS:${name}-objs>)
  set_property(TARGET ${name}-objs PROPERTY POSITION_INDEPENDENT_CODE 1)


  if (NOT ${StaticShared_NOINSTALL})
    if ("${StaticShared_INSTALL_LIBS_DESTINATION}" STREQUAL "")
      set(StaticShared_INSTALL_LIBS_DESTINATION ${PROJECT_NAME}/lib)
    endif()
    if ("${StaticShared_INSTALL_HEADERS_DESTINATION}" STREQUAL "")
      set(StaticShared_INSTALL_HEADERS_DESTINATION ${PROJECT_NAME}/include/${name})
    endif()
    if ("${StaticShared_DIRECTORY}" STREQUAL "")
      set(StaticShared_DIRECTORY "src/")
    endif()
    if ("${StaticShared_INSTALL_HEADERS_PATTERNS}" STREQUAL "")
      set(StaticShared_INSTALL_HEADERS_PATTERNS "*.h;*.hxx;*.hh;*.hpp")
    endif()
    install(
      TARGETS     ${name}_s ${name}
      DESTINATION ${StaticShared_INSTALL_LIBS_DESTINATION})
    foreach (c_pattern in ${INSTALL_HEADERS_PATTERNS})
      install(
        DIRECTORY   ${StaticShared_DIRECTORY}
        DESTINATION ${StaticShared_INSTALL_HEADERS_DESTINATION}
        FILES_MATCHING
        PATTERN     ${c_pattern})
    endforeach()
  endif()


endfunction(add_shared_static_library)
