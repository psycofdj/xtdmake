find_program(Genhtml_EXECUTABLE
  NAMES genhtml
  DOC "Html report generation tool (http://ltp.sourceforge.net/coverage/lcov.php)"
)

if (Genhtml_EXECUTABLE)
  set(Genhtml_FOUND 1)
else()
  set(Genhtml_FOUND 0)
  if (Genhtml_FIND_REQUIRED)
    message(SEND_ERROR "Unable to find genhtml program, please install (http://ltp.sourceforge.net/coverage/lcov.php)")
  else()
    message(STATUS "Could not find genhtml (lcov)")
  endif()
endif()


