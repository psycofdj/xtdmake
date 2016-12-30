Introduction
============

XTDMake is a set of CMake packages that provides easy-to-use targets that generate
code quality measurements reports :
- Doxygen-based documentation
- Coverage of documentation
- Count lines of code
- Cppcheck static analysis
- Unit tests
- Coverage of unit tests
- Memory leak of unit tests


Each target generates both a locally readable and machine processable reports.
Local report targets the developer while the machine-processable reports can be
used in your Continuous Integration (CI) process.


Note about CI :

Key Points Indicators (KPIs) measurement tools are often built in the CI
work flow and therefore cannot be run on the developer's local environment.
This usually lead to discovering regressions (failed tests, a lower coverage
or what-so-ever) only after pushing code to distant repository.
Developer's being responsible for the KPIs, they should be able to
run the measurement tools before pushing new code.

Because code of industrial applications is usually segmented in different modules,
each with a different purpose and levels of criticity, XTDMake's KPIs reports are
generated per module, allowing a finer interpretation of the indicators.

C++ compilation is already slow enough. XTDMake's targets are designed to be fully
incremental with a fine dependency tracking.
