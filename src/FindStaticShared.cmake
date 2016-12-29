set(StaticShared_FOUND 1)
message(STATUS "Found module StaticShared : TRUE")

set(StaticShared_DEFAULT_INSTALL_LIBS_DESTINATION    "lib"                               CACHE STRING "StaticShared default library install dir")
set(StaticShared_DEFAULT_INSTALL_HEADERS_DESTINATION "include/\${PROJECT_NAME}/\${name}" CACHE STRING "StaticShared default headers destination")
set(StaticShared_DEFAULT_INSTALL_HEADERS_PATTERNS    "*.h;*.hxx;*.hh;*.hpp"              CACHE STRING "StaticShared default headers pattern list")
set(StaticShared_DEFAULT_INSTALL_HEADERS_DIRECTORY   "src/"                              CACHE STRING "StaticShared default headers source directory")
set(StaticShared_DEFAULT_VERSION
  "\${PROJECT_VERSION_MAJOR}.\${PROJECT_VERSION_MINOR}.\${PROJECT_VERSION_PATCH}"
  CACHE STRING "StaticShared default shared library version")
set(StaticShared_DEFAULT_SOVERSION
  "\${PROJECT_VERSION_MAJOR}"
  CACHE STRING "StaticShared default shared library soversion")

function(add_shared_static_library name)
  set(multiValueArgs  INSTALL_HEADERS_PATTERNS)
  set(oneValueArgs    INSTALL_HEADERS_DESTINATION INSTALL_LIBS_DESTINATION INSTALL_HEADERS_DIRECTORY VERSION SOVERSION)
  set(options         NOINSTALL)

  cmake_parse_arguments(StaticShared
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  xtdmake_set_default(StaticShared INSTALL_LIBS_DESTINATION)
  xtdmake_set_default(StaticShared INSTALL_HEADERS_DESTINATION)
  xtdmake_set_default(StaticShared INSTALL_HEADERS_PATTERNS)
  xtdmake_set_default(StaticShared INSTALL_HEADERS_DIRECTORY)
  xtdmake_set_default(StaticShared VERSION)
  xtdmake_set_default(StaticShared SOVERSION)

  if (${CMAKE_VERSION}} VERSION_LESS 2.8.8)
    message(WARNING "add_shared_static_library requires cmake >= 2.8.8, building seperate objects")
    add_library(${name}_s STATIC ${ARGN})
    add_library(${name}   SHARED ${ARGN})
    set_target_properties(${name} PROPERTIES
      LIBRARY_OUTPUT_NAME ${PROJECT_NAME}${name}
      VERSION     ${StaticShared_VERSION}
      SOVERSION   ${StaticShared_SOVERSION})
    set_target_properties(${name}_s PROPERTIES
      ARCHIVE_OUTPUT_NAME ${PROJECT_NAME}${name})
    if (NOT ${StaticShared_NOINSTALL})
      install(
        TARGETS     ${name}_s ${name}
        DESTINATION ${StaticShared_INSTALL_LIBS_DESTINATION})
      foreach (c_pattern in ${StaticShared_INSTALL_HEADERS_PATTERNS})
        install(
          DIRECTORY   ${StaticShared_INSTALL_HEADERS_DIRECTORY}
          DESTINATION ${StaticShared_INSTALL_HEADERS_DESTINATION}
          FILES_MATCHING
          PATTERN     ${c_pattern})
      endforeach()
  endif()
  else()
    add_library(${PROJECT_NAME}${name}-objs OBJECT ${ARGN})
    add_library(${PROJECT_NAME}${name}_s STATIC $<TARGET_OBJECTS:${PROJECT_NAME}${name}-objs>)
    add_library(${PROJECT_NAME}${name}   SHARED $<TARGET_OBJECTS:${PROJECT_NAME}${name}-objs>)
    set_property(TARGET ${PROJECT_NAME}${name}-objs PROPERTY POSITION_INDEPENDENT_CODE 1)
    set_target_properties(${PROJECT_NAME}${name} PROPERTIES
      VERSION     ${StaticShared_VERSION}
      SOVERSION   ${StaticShared_SOVERSION})
    add_library(${name}_s ALIAS ${PROJECT_NAME}${name}_s)
    add_library(${name}   ALIAS ${PROJECT_NAME}${name})


    if (NOT ${StaticShared_NOINSTALL})
      install(
        TARGETS     ${PROJECT_NAME}${name}_s ${PROJECT_NAME}${name}
        DESTINATION ${StaticShared_INSTALL_LIBS_DESTINATION})
      foreach (c_pattern in ${StaticShared_INSTALL_HEADERS_PATTERNS})
        install(
          DIRECTORY   ${StaticShared_INSTALL_HEADERS_DIRECTORY}
          DESTINATION ${StaticShared_INSTALL_HEADERS_DESTINATION}
          FILES_MATCHING
          PATTERN     ${c_pattern})
      endforeach()
    endif()
  endif()

endfunction(add_shared_static_library)
