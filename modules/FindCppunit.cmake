#
# Find the CppUnit includes and library
#
# This module defines
# Cppunit_INCLUDE_DIR, where to find tiff.h, etc.
# Cppunit_LIBRARIES, the libraries to link against to use CppUnit.
# Cppunit_FOUND, If false, do not try to use CppUnit.

# also defined, but not for general use are
# Cppunit_LIBRARY, where to find the CppUnit library.
# Cppunit_DEBUG_LIBRARY, where to find the CppUnit library in debug mode.

find_path(Cppunit_INCLUDE_DIR cppunit/TestCase.h
  /usr/local/include
  /usr/include
  )

find_library(Cppunit_LIBRARY cppunit
  ${Cppunit_INCLUDE_DIR}/../lib
  /usr/local/lib
  /usr/lib)

find_library(Cppunit_DEBUG_LIBRARY cppunit
  ${Cppunit_INCLUDE_DIR}/../lib
  /usr/local/lib
  /usr/lib)

if(Cppunit_INCLUDE_DIR)
  if(Cppunit_LIBRARY)
    set(Cppunit_FOUND "YES")
    set(Cppunit_LIBRARIES ${Cppunit_LIBRARY} ${CMAKE_DL_LIBS})
    set(Cppunit_DEBUG_LIBRARIES ${Cppunit_DEBUG_LIBRARY}
      ${CMAKE_DL_LIBS})
  endif()
endif()

