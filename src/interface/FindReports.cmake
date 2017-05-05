add_custom_target(reports-update)
add_custom_target(reports-show)
add_custom_target(reports-graph)
add_custom_target(reports
  DEPENDS doc doc-coverage cloc cppcheck check cov memcheck)
add_custom_target(reports-clean
  DEPENDS doc-clean doc-coverage-clean cloc-clean cppcheck-clean check-clean cov-clean memcheck-clean)

function(xtdmake_init_project name directory)
  add_custom_command(
    COMMENT "Installing report interface for ${name}"
    OUTPUT
    ${directory}/reports/menu.html
    ${directory}/reports/index.html
    ${directory}/reports/view.html
    ${directory}/reports/contribs/
    DEPENDS
    ${XTDMake_HOME}/interface/menu.html
    ${XTDMake_HOME}/interface/index.html
    ${XTDMake_HOME}/interface/view.html
    ${XTDMake_HOME}/interface/contribs/
    COMMAND mkdir -p ${directory}/reports
    COMMAND cp    ${XTDMake_HOME}/interface/menu.html   ${directory}/reports/
    COMMAND cp    ${XTDMake_HOME}/interface/index.html  ${directory}/reports/
    COMMAND cp    ${XTDMake_HOME}/interface/view.html   ${directory}/reports/
    COMMAND cp -r ${XTDMake_HOME}/interface/contribs/ ${directory}/reports/
    VERBATIM)

  add_custom_command(
    COMMENT "Generating graph data for ${name}"
    OUTPUT
    ${directory}/reports/graph.js
    DEPENDS
    ${XTDMake_HOME}/interface/graph
    COMMAND mkdir -p ${directory}/reports
    COMMAND ${XTDMake_HOME}/interface/graph
      --report-dir ${directory}/reports/
      --history-dir ${directory}/reports/
      --output-dir ${directory}/reports/
      --build-label XTDMake
      --max-items 100
    VERBATIM
    )

  add_custom_target(reports-${name}-update
    COMMENT "Updating reports data for ${name}"
    DEPENDS
    ${directory}/reports/menu.html
    ${directory}/reports/index.html
    ${directory}/reports/view.html
    ${XTDMake_HOME}/interface/gendata
    COMMAND mkdir -p ${directory}/reports
    COMMAND ${XTDMake_HOME}/interface/gendata --report-dir ${directory}/reports/ --output-file ${directory}/reports/data.js
    VERBATIM
    )

  add_custom_target(reports-${name}-show
    DEPENDS reports-${name}-update ${directory}/reports/index.html
    COMMAND sensible-browser ${directory}/reports/index.html &
    )

  add_custom_target(reports-${name}-graph
    DEPENDS ${directory}/reports/graph.js
    )

  add_custom_target(reports-${name}
    DEPENDS ${directory}/reports/index.html
    )

  add_dependencies(reports-update reports-${name}-update)
  add_dependencies(reports-show reports-${name}-show)
  add_dependencies(reports reports-${name})
  add_dependencies(reports-graph reports-${name}-graph)
endfunction()



if (DocRule_FOUND)
  add_custom_command(TARGET doc
    POST_BUILD
    COMMAND $(MAKE) reports-update
    VERBATIM)
  add_custom_command(TARGET doc-clean
    POST_BUILD
    COMMAND $(MAKE) reports-update
    VERBATIM)
endif()


if (DocCoverageRule_FOUND)
  add_custom_command(TARGET doc-coverage
    POST_BUILD
    COMMAND $(MAKE) reports-update
    VERBATIM)
  add_custom_command(TARGET doc-coverage-clean
    POST_BUILD
    COMMAND $(MAKE) reports-update
    VERBATIM)
endif()


if (ClocRule_FOUND)
  add_custom_command(TARGET cloc
    POST_BUILD
    COMMAND $(MAKE) reports-update
    VERBATIM)
  add_custom_command(TARGET cloc-clean
    POST_BUILD
    COMMAND $(MAKE) reports-update
    VERBATIM)
endif()


if (CppcheckRule_FOUND)
  add_custom_command(TARGET cppcheck
    POST_BUILD
    COMMAND $(MAKE) reports-update
    VERBATIM)
  add_custom_command(TARGET cppcheck-clean
    POST_BUILD
    COMMAND $(MAKE) reports-update
    VERBATIM)
endif()


if (CheckRule_FOUND)
  add_custom_command(TARGET check
    POST_BUILD
    COMMAND $(MAKE) reports-update
    VERBATIM)
  add_custom_command(TARGET check-clean
    POST_BUILD
    COMMAND $(MAKE) reports-update
    VERBATIM)
endif()

if (CovRule_FOUND)
  add_custom_command(TARGET cov
    POST_BUILD
    COMMAND $(MAKE) reports-update
    VERBATIM)
  add_custom_command(TARGET cov-clean
    POST_BUILD
    COMMAND $(MAKE) reports-update
    VERBATIM)
endif()

if (MemcheckRule_FOUND)
  add_custom_command(TARGET memcheck
    POST_BUILD
    COMMAND $(MAKE) reports-update
    VERBATIM)
  add_custom_command(TARGET memcheck-clean
    POST_BUILD
    COMMAND $(MAKE) reports-update
    VERBATIM)
endif()
