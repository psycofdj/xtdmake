set(CMAKE_CXX_FLAGS                 "${CMAKE_CXX_FLAGS} -DHAVE_DEPENDENCY_TRACKING")
set(CMAKE_CXX_ARCHIVE_CREATE        "${XTDMake_HOME}/tracking/ar_wrapper --top-srcdir='${PROJECT_SOURCE_DIR}' --bin='<CMAKE_AR>' --opts=qc --target='<TARGET>' --flags='<LINK_FLAGS>' --objects='<OBJECTS>'")
set(CMAKE_CXX_ARCHIVE_APPEND        "${XTDMake_HOME}/tracking/ar_wrapper --top-srcdir='${PROJECT_SOURCE_DIR}' --bin='<CMAKE_AR>' --opts=q  --target='<TARGET>' --flags='<LINK_FLAGS>' --objects='<OBJECTS>'")
set(CMAKE_CXX_LINK_EXECUTABLE       "${XTDMake_HOME}/tracking/link_wrapper --top-srcdir='${PROJECT_SOURCE_DIR}' --bin='<CMAKE_CXX_COMPILER>' --flags='<FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS>' --objects='<OBJECTS>'  --target='<TARGET>' --libs='<LINK_LIBRARIES>'")
set(CMAKE_CXX_CREATE_SHARED_LIBRARY "${XTDMake_HOME}/tracking/link_wrapper --top-srcdir='${PROJECT_SOURCE_DIR}' --bin='<CMAKE_CXX_COMPILER>' --flags='<CMAKE_SHARED_LIBRARY_CXX_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <SONAME_FLAG><TARGET_SONAME>' --objects='<OBJECTS>'  --target='<TARGET>' --libs='<LINK_LIBRARIES>'")
set(CMAKE_CXX_CREATE_SHARED_MODULE  "${XTDMake_HOME}/tracking/link_wrapper  --top-srcdir='${PROJECT_SOURCE_DIR}' --bin='<CMAKE_CXX_COMPILER>' --flags='<CMAKE_SHARED_LIBRARY_CXX_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <SONAME_FLAG><TARGET_SONAME>' --objects='<OBJECTS>'  --target='<TARGET>' --libs='<LINK_LIBRARIES>'")

set(Tracking_FOUND 1)
message(STATUS "Found module Tracking : TRUE")
