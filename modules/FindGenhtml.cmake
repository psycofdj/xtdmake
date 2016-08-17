find_program(Genhtml_EXECUTABLE
  NAMES genhtml
  DOC "Html report generation tool (http://ltp.sourceforge.net/coverage/lcov.php)"
)

if (Genhtml_EXECUTABLE)
  set(Genhtml_FOUND 1)
    message(STATUS "Found Genhtml : TRUE")
else()
  set(Genhtml_FOUND 0)
  if (Genhtml_FIND_REQUIRED)
    message(SEND_ERROR "Cannot find Genhtml required program, please install lcov (http://ltp.sourceforge.net/coverage/lcov.php)")
  else()
    message(STATUS "Found Genhtml : FALSE")
  endif()
endif()
