cmake_minimum_required(VERSION 2.8.7)
enable_testing()
project(xtdmake NONE)

list(APPEND l_dirs check)
list(APPEND l_dirs cloc)
list(APPEND l_dirs coverage)
list(APPEND l_dirs cppcheck)
list(APPEND l_dirs doc)
list(APPEND l_dirs doc-coverage)
list(APPEND l_dirs documentation)
list(APPEND l_dirs interface)
list(APPEND l_dirs memcheck)
list(APPEND l_dirs tracking)

file(GLOB l_files "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cmake")
install(FILES ${l_files}
  DESTINATION share/xtdmake
  )

foreach (c_dir ${l_dirs})
  install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/${c_dir}
    USE_SOURCE_PERMISSIONS
    COMPONENT   ${c_dir}
    DESTINATION share/xtdmake
    )
endforeach()

subdirs(tests)
