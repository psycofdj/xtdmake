find_program(Xsltproc_EXECUTABLE
  NAMES xsltproc
  DOC "rendering xslt stylehseets"
)

if (Xsltproc_EXECUTABLE)
  set(Xsltproc_FOUND 1)
else()
  set(Xsltproc_FOUND 0)
  if (Xsltproc_FIND_REQUIRED)
    message(SEND_ERROR "Unable to find xsltproc program, please install xsltproc (apt-get install xsltproc)")
  else()
    message(STATUS "Could not find xsltproc")
  endif()
endif()
