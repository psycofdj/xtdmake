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

if (Doc_FOUND)
  add_custom_command(TARGET doc
    POST_BUILD
    COMMAND ${PROJECT_SOURCE_DIR}/xtdmake/interface/gendata.py --report-dir ${CMAKE_REPORT_OUTPUT}/ --output-file ${CMAKE_REPORT_OUTPUT}/data.js
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Updating reports data for target doc" VERBATIM)
endif()

if (DocCoverage_FOUND)
  add_custom_command(TARGET doc-coverage
    POST_BUILD
    COMMAND ${PROJECT_SOURCE_DIR}/xtdmake/interface/gendata.py --report-dir ${CMAKE_REPORT_OUTPUT}/ --output-file ${CMAKE_REPORT_OUTPUT}/data.js
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Updating reports data for target doc-coverage" VERBATIM)
endif()

if (Cloc_FOUND)
  add_custom_command(TARGET cloc
    POST_BUILD
    COMMAND ${PROJECT_SOURCE_DIR}/xtdmake/interface/gendata.py --report-dir ${CMAKE_REPORT_OUTPUT}/ --output-file ${CMAKE_REPORT_OUTPUT}/data.js
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Updating reports data for target cloc" VERBATIM)
endif()

if (Cppcheck_FOUND)
  add_custom_command(TARGET cppcheck
    POST_BUILD
    COMMAND ${PROJECT_SOURCE_DIR}/xtdmake/interface/gendata.py --report-dir ${CMAKE_REPORT_OUTPUT}/ --output-file ${CMAKE_REPORT_OUTPUT}/data.js
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Updating reports data for target cppcheck" VERBATIM)
endif()


add_custom_target(reports
  DEPENDS doc doc-coverage cloc cppcheck
)

add_custom_target(reports-show
  COMMAND sensible-browser ${CMAKE_REPORT_OUTPUT}/index.html &
  DEPENDS ${CMAKE_REPORT_OUTPUT}/index.html ${CMAKE_REPORT_OUTPUT}/data.js
)

add_custom_target(reports-clean
  COMMAND rm -rf ${CMAKE_REPORT_OUTPUT})
