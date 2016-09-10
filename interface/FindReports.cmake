set(CMAKE_REPORT_OUTPUT "${CMAKE_BINARY_DIR}/reports")

add_custom_command(
  OUTPUT
  ${CMAKE_REPORT_OUTPUT}/data.js
  COMMAND mkdir -p ${CMAKE_REPORT_OUTPUT}
  COMMAND ${PROJECT_SOURCE_DIR}/xtdmake/interface/gendata.py --report-dir ${CMAKE_REPORT_OUTPUT}/ --output-file ${CMAKE_REPORT_OUTPUT}/data.js
  DEPENDS
  ${PROJECT_SOURCE_DIR}/xtdmake/interface/gendata.py
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  COMMENT "Updating reports data" VERBATIM)

add_custom_command(
  OUTPUT
  ${CMAKE_REPORT_OUTPUT}/menu.html
  ${CMAKE_REPORT_OUTPUT}/index.html
  ${CMAKE_REPORT_OUTPUT}/bower_components/
  COMMAND mkdir -p ${CMAKE_REPORT_OUTPUT}
  COMMAND cp ${PROJECT_SOURCE_DIR}/xtdmake/interface/menu.html            ${CMAKE_REPORT_OUTPUT}/
  COMMAND cp ${PROJECT_SOURCE_DIR}/xtdmake/interface/index.html           ${CMAKE_REPORT_OUTPUT}/
  COMMAND cp -r ${PROJECT_SOURCE_DIR}/xtdmake/interface/bower_components/ ${CMAKE_REPORT_OUTPUT}/
  DEPENDS
  ${PROJECT_SOURCE_DIR}/xtdmake/interface/menu.html
  ${PROJECT_SOURCE_DIR}/xtdmake/interface/index.html
  ${PROJECT_SOURCE_DIR}/xtdmake/interface/bower_components/
  ${PROJECT_SOURCE_DIR}/xtdmake/interface/gendata.py
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  COMMENT "Installing report interface" VERBATIM)

if (DocRule_FOUND)
  add_custom_command(TARGET doc
    POST_BUILD
    COMMAND ${PROJECT_SOURCE_DIR}/xtdmake/interface/gendata.py --report-dir ${CMAKE_REPORT_OUTPUT}/ --output-file ${CMAKE_REPORT_OUTPUT}/data.js
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Updating reports data for target doc" VERBATIM)
  add_custom_command(TARGET doc-clean
    POST_BUILD
    COMMAND ${PROJECT_SOURCE_DIR}/xtdmake/interface/gendata.py --report-dir ${CMAKE_REPORT_OUTPUT}/ --output-file ${CMAKE_REPORT_OUTPUT}/data.js
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Updating reports data for target doc-clean" VERBATIM)
endif()

if (DocCoverageRule_FOUND)
  add_custom_command(TARGET doc-coverage
    POST_BUILD
    COMMAND ${PROJECT_SOURCE_DIR}/xtdmake/interface/gendata.py --report-dir ${CMAKE_REPORT_OUTPUT}/ --output-file ${CMAKE_REPORT_OUTPUT}/data.js
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Updating reports data for target doc-coverage" VERBATIM)
  add_custom_command(TARGET doc-coverage-clean
    POST_BUILD
    COMMAND ${PROJECT_SOURCE_DIR}/xtdmake/interface/gendata.py --report-dir ${CMAKE_REPORT_OUTPUT}/ --output-file ${CMAKE_REPORT_OUTPUT}/data.js
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Updating reports data for target doc-coverage-clean" VERBATIM)
endif()

if (ClocRule_FOUND)
  add_custom_command(TARGET cloc
    POST_BUILD
    COMMAND ${PROJECT_SOURCE_DIR}/xtdmake/interface/gendata.py --report-dir ${CMAKE_REPORT_OUTPUT}/ --output-file ${CMAKE_REPORT_OUTPUT}/data.js
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Updating reports data for target cloc" VERBATIM)
  add_custom_command(TARGET cloc-clean
    POST_BUILD
    COMMAND ${PROJECT_SOURCE_DIR}/xtdmake/interface/gendata.py --report-dir ${CMAKE_REPORT_OUTPUT}/ --output-file ${CMAKE_REPORT_OUTPUT}/data.js
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Updating reports data for target cloc-clean" VERBATIM)
endif()

if (CppcheckRule_FOUND)
  add_custom_command(TARGET cppcheck
    POST_BUILD
    COMMAND ${PROJECT_SOURCE_DIR}/xtdmake/interface/gendata.py --report-dir ${CMAKE_REPORT_OUTPUT}/ --output-file ${CMAKE_REPORT_OUTPUT}/data.js
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Updating reports data for target cppcheck" VERBATIM)
  add_custom_command(TARGET cppcheck-clean
    POST_BUILD
    COMMAND ${PROJECT_SOURCE_DIR}/xtdmake/interface/gendata.py --report-dir ${CMAKE_REPORT_OUTPUT}/ --output-file ${CMAKE_REPORT_OUTPUT}/data.js
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Updating reports data for target cppcheck-clean" VERBATIM)
endif()


add_custom_target(reports
  DEPENDS
  doc
  doc-coverage
  cloc
  cppcheck
  ${CMAKE_REPORT_OUTPUT}/menu.html
  ${CMAKE_REPORT_OUTPUT}/index.html
)

add_custom_target(reports-clean
  DEPENDS doc-clean doc-coverage-clean cloc-clean cppcheck-clean
)

add_custom_target(reports-show
  COMMAND sensible-browser ${CMAKE_REPORT_OUTPUT}/index.html &
  DEPENDS ${CMAKE_REPORT_OUTPUT}/index.html ${CMAKE_REPORT_OUTPUT}/data.js
)
