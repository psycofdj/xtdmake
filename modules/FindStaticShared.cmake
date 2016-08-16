set(StaticShared_FOUND 1)
message(STATUS "Found StaticShared package")

function(add_shared_static_library name)
  add_library(${name}-objs OBJECT ${ARGN})
  add_library(${name}_s STATIC $<TARGET_OBJECTS:${name}-objs>)
  add_library(${name}   SHARED $<TARGET_OBJECTS:${name}-objs>)

  set_property(TARGET ${name}-objs PROPERTY POSITION_INDEPENDENT_CODE 1)

  install(
    TARGETS     ${name}_s ${name}
    DESTINATION xtdcpp/lib)

  install(
  DIRECTORY   src/
  DESTINATION xtdcpp/include/${name}
  FILES_MATCHING
  PATTERN     "*.hh"
  PATTERN     "*.hxx"
  )
endfunction(add_shared_static_library)
