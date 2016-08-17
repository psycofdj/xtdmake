find_program(Coverxygen_EXECUTABLE
  NAMES coverxygen.py
  DOC "Tool to generate coverage report from Doxygen documentation (https://github.com/psycofdj/coverxygen)"
)

if (Coverxygen_EXECUTABLE)
  set(Coverxygen_FOUND 1)
  message(STATUS "Found Coverxygen : TRUE")
else()
  set(Coverxygen_FOUND 0)
  if (Coverxygen_FIND_REQUIRED)
    message(SEND_ERROR "Cannot find Coverxygen required package, please install goverxygen (https://github.com/psycofdj/coverxygen)")
  else()
    message(STATUS "Found Coverxygen : FALSE")
  endif()
endif()


