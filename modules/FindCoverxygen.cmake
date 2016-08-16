find_program(Coverxygen_EXECUTABLE
  NAMES coverxygen.py
  DOC "Tool to generate coverage report from Doxygen documentation (https://github.com/psycofdj/coverxygen)"
)

if (Coverxygen_EXECUTABLE)
  set(Coverxygen_FOUND 1)
else()
  set(Coverxygen_FOUND 0)
  if (Coverxygen_FIND_REQUIRED)
    message(SEND_ERROR "Unable to find coverxygen.py program, please install goverxygen (https://github.com/psycofdj/coverxygen)")
  else()
    message(STATUS "Could not find coverxygen")
  endif()
endif()


