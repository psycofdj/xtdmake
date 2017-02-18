set(CMAKE_REPORT_OUTPUT "${CMAKE_BINARY_DIR}/reports")

add_custom_target(reports-update
  COMMENT "Updating reports data"
  DEPENDS
  ${CMAKE_REPORT_OUTPUT}/menu.html
  ${CMAKE_REPORT_OUTPUT}/index.html
  ${CMAKE_REPORT_OUTPUT}/view.html
  ${XTDMake_HOME}/interface/gendata
  COMMAND mkdir -p ${CMAKE_REPORT_OUTPUT}
  COMMAND ${XTDMake_HOME}/interface/gendata --report-dir ${CMAKE_REPORT_OUTPUT}/ --output-file ${CMAKE_REPORT_OUTPUT}/data.js
  VERBATIM)


add_custom_command(
  COMMENT "Installing report interface"
  OUTPUT
  ${CMAKE_REPORT_OUTPUT}/menu.html
  ${CMAKE_REPORT_OUTPUT}/index.html
  ${CMAKE_REPORT_OUTPUT}/view.html
  ${CMAKE_REPORT_OUTPUT}/contribs/
  DEPENDS
  ${XTDMake_HOME}/interface/menu.html
  ${XTDMake_HOME}/interface/index.html
  ${XTDMake_HOME}/interface/view.html
  ${XTDMake_HOME}/interface/contribs/
  COMMAND mkdir -p ${CMAKE_REPORT_OUTPUT}
  COMMAND cp ${XTDMake_HOME}/interface/menu.html   ${CMAKE_REPORT_OUTPUT}/
  COMMAND cp ${XTDMake_HOME}/interface/index.html  ${CMAKE_REPORT_OUTPUT}/
  COMMAND cp ${XTDMake_HOME}/interface/view.html   ${CMAKE_REPORT_OUTPUT}/
  COMMAND cp -r ${XTDMake_HOME}/interface/contribs/ ${CMAKE_REPORT_OUTPUT}/
  VERBATIM)

add_custom_command(
  COMMENT "Generating graph data"
  OUTPUT
  ${CMAKE_REPORT_OUTPUT}/graph.js
  DEPENDS
  ${XTDMake_HOME}/interface/graph
  COMMAND mkdir -p ${CMAKE_REPORT_OUTPUT}
  COMMAND ${XTDMake_HOME}/interface/graph
    --report-dir ${CMAKE_REPORT_OUTPUT}/
    --history-dir ${CMAKE_REPORT_OUTPUT}/
    --output-dir ${CMAKE_REPORT_OUTPUT}/
    --build-label XTDMake
    --max-items 100
  VERBATIM)


if (DocRule_FOUND)
  add_custom_command(TARGET doc
    POST_BUILD
    COMMENT "Updating reports data for target doc"
    COMMAND $(MAKE) reports-update
    VERBATIM)
  add_custom_command(TARGET doc-clean
    COMMENT "Updating reports data for target doc-clean"
    POST_BUILD
    COMMAND $(MAKE) reports-update
    VERBATIM)
endif()


if (DocCoverageRule_FOUND)
  add_custom_command(TARGET doc-coverage
    POST_BUILD
    COMMENT "Updating reports data for target doc-coverage"
    COMMAND $(MAKE) reports-update
    VERBATIM)
  add_custom_command(TARGET doc-coverage-clean
    POST_BUILD
    COMMENT "Updating reports data for target doc-coverage-clean"
    COMMAND $(MAKE) reports-update
    VERBATIM)
endif()


if (ClocRule_FOUND)
  add_custom_command(TARGET cloc
    POST_BUILD
    COMMENT "Updating reports data for target cloc"
    COMMAND $(MAKE) reports-update
    VERBATIM)
  add_custom_command(TARGET cloc-clean
    POST_BUILD
    COMMENT "Updating reports data for target cloc-clean"
    COMMAND $(MAKE) reports-update
    VERBATIM)
endif()


if (CppcheckRule_FOUND)
  add_custom_command(TARGET cppcheck
    POST_BUILD
    COMMENT "Updating reports data for target cppcheck"
    COMMAND $(MAKE) reports-update
    VERBATIM)
  add_custom_command(TARGET cppcheck-clean
    POST_BUILD
    COMMENT "Updating reports data for target cppcheck-clean"
    COMMAND $(MAKE) reports-update
    VERBATIM)
endif()


if (CheckRule_FOUND)
  add_custom_command(TARGET check
    POST_BUILD
    COMMENT "Updating reports data for target check"
    COMMAND $(MAKE) reports-update
    VERBATIM)
  add_custom_command(TARGET check-clean
    POST_BUILD
    COMMENT "Updating reports data for target check-clean"
    COMMAND $(MAKE) reports-update
    VERBATIM)
endif()


if (CovRule_FOUND)
  add_custom_command(TARGET cov
    POST_BUILD
    COMMENT "Updating reports data for target cov"
    COMMAND $(MAKE) reports-update
    VERBATIM)
  add_custom_command(TARGET cov-clean
    POST_BUILD
    COMMENT "Updating reports data for target cov-clean"
    COMMAND $(MAKE) reports-update
    VERBATIM)
endif()



if (MemcheckRule_FOUND)
  add_custom_command(TARGET memcheck
    POST_BUILD
    COMMENT "Updating reports data for target memcheck"
    COMMAND $(MAKE) reports-update
    VERBATIM)
  add_custom_command(TARGET memcheck-clean
    POST_BUILD
    COMMENT "Updating reports data for target memcheck-clean"
    COMMAND $(MAKE) reports-update
    VERBATIM)
endif()


add_custom_target(reports
  DEPENDS doc doc-coverage cloc cppcheck check cov memcheck
  ${CMAKE_REPORT_OUTPUT}/index.html
)

add_custom_target(reports-clean
  DEPENDS doc-clean doc-coverage-clean cloc-clean cppcheck-clean check-clean cov-clean memcheck-clean
)

add_custom_target(reports-graph
  DEPENDS ${CMAKE_REPORT_OUTPUT}/graph.js
)

add_custom_target(reports-show
  DEPENDS reports-update ${CMAKE_REPORT_OUTPUT}/index.html
  COMMAND sensible-browser ${CMAKE_REPORT_OUTPUT}/index.html &
)
