include_directories(
  ${Boost_INCLUDE_DIRS}
  ${m1_INCLUDE_DIRS}
  )

add_shared_static_library(m1
  src/code.cc
  )


add_executable(bin_m1
  src/main.cc
  )

target_link_libraries(bin_m1 m1_s)

install(TARGETS bin_m1
  RUNTIME
  DESTINATION bin)

add_doc(m1)
add_doc_coverage(m1)
add_cloc(m1)
add_cppcheck(m1)
add_check(m1 INCLUDES ${m1_INCLUDE_DIRS} LINKS m1_s)
add_cov(m1)
add_memcheck(m1)

