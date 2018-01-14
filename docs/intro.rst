Introduction
============

XTDMake is a set of CMake_ packages that provides easy-to-use targets that generate
code quality measurements reports.

* Documentation (using Doxygen_)
* Documentation coverage (using Doxygen_ and Lcov_)
* Count lines of code (using Cloc_)
* C++ static code analysis (using CppCheck_)
* Unit tests (using CMake_'s test facility)
* Code coverage (using Lcov_)
* Memory leak of unit tests (using Valgrind_)
* Code duplication analysis (using Pmd_)
* C++ include sanitizing (using Iwyu_)

.. _Doxygen: http://www.doxygen.org/
.. _Lcov: http://ltp.sourceforge.net/coverage/lcov.php
.. _Cloc: http://cloc.sourceforge.net/
.. _CppCheck: http://cppcheck.sourceforge.net/
.. _Valgrind: http://valgrind.org/
.. _Pmd: http://pmd.sourceforge.net
.. _Iwyu: https://include-what-you-use.org/
.. _CMake: https://cmake.org/


Each target generates both a locally readable and machine processable reports.
Local report targets the developer while the machine-processable reports can be
used in your Continuous Integration (CI) process.


Locally runnable
----------------

Key Point Indicators (KPIs) measurement tools are often built in the CI
work flow and therefore cannot be run on the developer's local environment.
This usually lead to discovering regressions (failed tests, a lower coverage
or what-so-ever) only after pushing code to distant repository.
Developer's being responsible for the KPIs, they should be able to
run the measurement tools before pushing new code.

Per module
----------

Because code of industrial applications is usually divided in different modules,
each with a different purpose and levels of criticity, XTDMake's KPIs reports are
generated per module, allowing a finer interpretation of the indicators.

Incremental execution
---------------------

C++ compilation is already slow enough. XTDMake's targets are designed to be fully
incremental with a fine dependency tracking.


..
   Local Variables:
   ispell-local-dictionary: "en"
   End:
