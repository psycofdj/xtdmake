# ----------
# cmake init
# ----------

cmake_minimum_required (VERSION 2.6)
project(p1)
enable_testing()
set(PROJECT_VERSION_MAJOR 0)
set(PROJECT_VERSION_MINOR 1)
set(PROJECT_VERSION_PATCH 1)

# ---------
# libraries
# ---------

find_package(Boost REQUIRED thread)
find_package(Threads REQUIRED)
add_definitions(-DBOOST_MAJOR_VERSION=${Boost_MAJOR_VERSION})
add_definitions(-DBOOST_MINOR_VERSION=${Boost_MINOR_VERSION})

set(REQUIRED "REQUIRED")

if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING
    "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel."
    FORCE)
endif()

if (EXISTS "${PROJECT_SOURCE_DIR}/xtdmake/src")
  find_package(XTDMake REQUIRED HINTS "${PROJECT_SOURCE_DIR}/xtdmake/src")
else()
  find_package(XTDMake REQUIRED CONFIG)
endif()

list(APPEND CheckRule_DEFAULT_INCLUDES "${Boost_INCLUDE_DIRS}")
list(APPEND CheckRule_DEFAULT_LINKS    "${Boost_LIBRARIES}")

xtdmake_init(
  StaticShared    REQUIRED
  DocRule         ${REQUIRED}
  DocCoverageRule ${REQUIRED}
  CppcheckRule    ${REQUIRED}
  CheckRule       ${REQUIRED}
  ClocRule        ${REQUIRED}
  Tracking        ${REQUIRED}
  Cppunit         ${REQUIRED}
  CovRule         ${REQUIRED}
  MemcheckRule    ${REQUIRED}
  Reports         ${REQUIRED})

enable_tracking()

# --------------------
# compiler options
# --------------------

set(CMAKE_CXX_COMPILER         "g++")
set(CMAKE_CXX_FLAGS            "${CMAKE_CXX_FLAGS} -W -Wall -Wextra")
set(CMAKE_CXX_FLAGS_DEBUG      "${CMAKE_CXX_FLAGS_DEBUG} -O0 -fprofile-arcs -ftest-coverage")
set(CMAKE_CXX_FLAGS_RELEASE    "${CMAKE_CXX_FLAGS_RELEASE} -Werror")

# ------------
# local config
# ------------

set(m1_INCLUDE_DIRS ${PROJECT_SOURCE_DIR}/m1/src)

subdirs(m1)
