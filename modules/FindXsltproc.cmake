find_program(Xsltproc_EXECUTABLE
  NAMES xsltproc
  DOC "rendering xslt stylehseets"
)

if (Xsltproc_EXECUTABLE)
  set(Xsltproc_FOUND 1)
  message(STATUS "Found Xsltproc : TRUE")
else()
  set(Xsltproc_FOUND 0)
  if (Xsltproc_FIND_REQUIRED)
    message(SEND_ERROR "Cannot find Xsltproc required program, please install (http://xmlsoft.org/)")
  else()
    message(STATUS "Found Xsltproc : FALSE")
  endif()
endif()
