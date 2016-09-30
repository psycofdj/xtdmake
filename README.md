<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-generate-toc again -->
**Table of Contents**

- [What is it ?](#what-is-it-)
- [Install](#install)
- [Binary identity tracking](#binary-identity-tracking)
- [Building both shared and static library](#building-both-shared-and-static-library)
- [Code quality reports](#code-quality-reports)
    - [Documentation](#documentation)
    - [Documentation Coverage](#documentation-coverage)
    - [Count lines of code](#count-lines-of-code)
    - [Cppcheck static analysis](#cppcheck-static-analysis)
    - [Unit tests](#unit-tests)
        - [Global design](#global-design)
        - [Finding the test sources](#finding-the-test-sources)
        - [Binary targets](#binary-targets)
        - [Test targets](#test-targets)
    - [Code coverage](#code-coverage)
    - [Report Interface](#report-interface)

<!-- markdown-toc end -->

What is it ?
============

XTDMake is a set of CMake modules that provides easy-to-use targets that generate
code quality measurements reports

Install
=======

0. Prerequisites
  ```bash
  # Doxygen (Generate documentation from source code)
  sudo apt-get install doxygen

  # Dot (Generate pictures from graphs)
  sudo apt-get install graphviz

  # xsltproc (Transform XML files from XSLT style-sheets)
  sudo apt-get install xsltproc

  # lcov (Generate HTML results from code-coverage informations)
  sudo apt-get install lcov

  # coverxygen (Generate documentation-coverage informations from doxygen documentation)
  sudo pip3 install coverxygen

  # cloc (Count line of codes)
  sudo apt-get install cloc

  # cppcheck (C++ static code analysis tool)
  sudo apt-get install cppcheck
  ```

1. Download latest release xtdmake archive
  ```bash
  # get latest tag number
  tag=$(curl -s https://api.github.com/repos/psycofdj/xtdmake/tags | \
        jq -r '[ .[] | .["name"] ] | sort | last')

  # download archive
  wget https://github.com/psycofdj/xtdmake/archive/${tag}.tar.gz -O xtdmake-${tag}.tar.gz
  ```

2. Uncompress archive in your project's root
  ```bash
  tar xvzf <version>.tar.gz
  ```

3. Load XTDMake in your project's root CMakeLists.txt
  ```cmake
  include(xtdmake/loader.cmake)
  ```


# Binary identity tracking

This feature configures your C/C++ build to add information about when and how your
binaries were constructed. Behind the scene, cmake will wrap your linker to add a
ident-compatible string to your binary. In addition, cmake will add this kind of
informations when generating static archives (.a files) and use them when linking your
binaries.

Demo:

```bash
# compile our binary (which links to libcommon_s)
make common_tf

# extract informations from generated file
ident common_tf

# output result
common_tf:
$date: 16-08-2016 $
$time: 10:43:15 $
$name: common_tf $
$user: psyco $
$host: xmarcelet $
$pwd: /home/psyco/dev/xtdcpp/.release/common $
$revno: 98b7d3e224e9ad32affab425c52bfe19f2ce302d $
$archive: [libcommon_s] (time) 10:43:12 $
$archive: [libcommon_s] (date) 16-08-2016 $
$archive: [libcommon_s] (revno) 98b7d3e224e9ad32affab425c52bfe19f2ce302d $
```

This also works on shared libraries :
```bash
# compile our shared library libcommon.so
make common

# extract informations from generated file
ident libcommon.so

# output result
$date: 16-08-2016 $
$time: 13:40:35 $
$name: libcommon.so $
$user: psyco $
$host: xmarcelet $
$pwd: /home/psyco/dev/xtdcpp/.release/common $
$revno: 8fb0f8e916078257552470ce22761dcead79158c $
```

This feature can be enabled by adding the following directive to your project's root
CMakeLists.txt :
```cmake
find_package(Tracking REQUIRED)
```

# Building both shared and static library

XTDMake provides a way to easily produce both static and shared library from a single
call. In addition it will optimize your build to produce only one set of object files
that will be used for both targets.

Note: This means that objects generated with -fPIC are used to create static archives.
This may have a performance impact.

```cmake
 # in CMakeLists.txt
add_shared_static_library(<library_name> <file1> <file2> ....)
```

This will create two CMake targets :
 - `<library_name>`   : that will produce `lib<library_name>.so`
 - `<library_name>_s` : that will produce `lib<library_name>_s.a`

You may customize theses target at will using standard CMake functions.


In order to use `add_shared_static_library` function, you must load the StaticShared
module by adding the following directive too your project's root CMakeLists.txt :
```cmake
find_package(StaticShared REQUIRED)
```

# Code quality reports

XTDMake provides a bunch of modules producing code quality measurements targets.


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


Because industrial applications' code is usually segmented in different module
with a different purpose and levels of criticity, XTDMake's KPIs reports are
generated per module, allowing a finer interpretation of the indicators.


C++ compilation being already slow enough, XTDMake's code-measurement targets are
designed to be fully incremental with a fine dependency tracking.


## Documentation

This target generate documentation with doxygen.

Default configuration file template is shipped with XTDMake (xtdmake/doc/doxygen.in).

1. In your project's root CMakeLists.txt :
  ```cmake
  find_package(DocRule REQUIRED)
  ```

2. In your module's CMakeLists.txt :
  ```cmake
  add_doc(<module_name>
      [ INPUT             dir1     [dir2 ...]]
      [ EXCLUDE           file1    [file2 ...]]
      [ FILE_PATTERNS     pattern1 [pattern2 ...]]
      [ PREDEFINED        macro1   [macro2 ...]]
      [ EXPAND_AS_DEFINED macro1   [macro2 ...]]
      [ EXAMPLE           dir]
      [ IMAGE             dir]
      [ PLANTUML          path]
      [ WERROR        ]
      [ NO_CALL_GRAHS ]
      )
  ```

  - ```INPUT```  : list of input source directories containing file to document.
    Default value is ```${CMAKE_CURRENT_SOURCE_DIR}/src```. When exists, directory
    ```${CMAKE_CURRENT_SOURCE_DIR}/doc``` is added.

  - ```FILE_PATTERNS``` : list of wildcard patterns to search in input directories.
    Default value is ```*.cc *.hh *.hpp```

  - ```EXCLUDE``` : list files to exclude from matched files

  - ```PREDEFINED``` : List of predefined macros for doxygen. See
    [here](https://www.stack.nl/~dimitri/doxygen/manual/config.html#cfg_predefined).

  - ```EXPAND_AS_DEFINED``` : List of macros to expand as defined. See
    [here](https://www.stack.nl/~dimitri/doxygen/manual/config.html#cfg_expand_as_defined).

  - ```EXAMPLE``` : Example directory path. Default is
    ```${CMAKE_CURRENT_SOURCE_DIR}/doc/example``` when exists.

  - ```PLANTUML``` : Plantuml jar path (doxygen >=1.8.11). Default is
    ```/usr/share/plantuml/plantuml.jar``` .

  - ```NO_CALL_GRAPHS``` : If given, disable doxygen call graphs and caller graphs.

  - ```WERROR``` : Treat doxygen warning as errors.


3. Generate the reports :
  ```bash
  # generate documentation for a specific module
  make -C <module_path> doc-<module_name>

  # generate documentation for all modules
  make doc

  # remove generated documentation
  make doc-clean
  ```

4. Consult the report  :
  ```
  sensible-browser ./reports/<module_name>/doc/html/index.html
  ```

  Note that it will also produce an xml version of the documentation in :
  ```
  ./reports/<module_name>/doc/xml/index.xml
  ```


## Documentation Coverage

This target will generate a report showing how complete is documentation.


1. In your project's root CMakeLists.txt :
  ```cmake
  # note that this depends on Doc module
  find_package(DocCoverageRule REQUIRED)
  ```

2. In your module's CMakeLists.txt :
  ```cmake
  add_doc_coverage(<module_name>
    [ KIND  kind1 [kind2 ...]]
    [ SCOPE scope1 [scope2 ...]]
  )
  ```

  - ```KIND``` : List of kind of symbol to take into account for coverage measurement.
    Available values are described in the ```--kind``` parameter of
    [coverxygen](https://github.com/psycofdj/coverxygen) tool

  - ```SCOPE``` : List of symbol's scope to take into account for coverage measurement.
    Available values are described in the ```--scope``` parameter of
    [coverxygen](https://github.com/psycofdj/coverxygen) tool

3. Generate the reports :
  ```bash
  # generate documentation-coverage for a specific module
  make -C <module_path> doc-coverage-<module_name>

  # generate documentation coverage for all modules
  make doc-coverage

  # remove generated report
  make doc-coverage-clean
  ```

4. Consult the report  :
  ```
  sensible-browser ./reports/<module_name>/doc-coverage/index.html
  ```

  Note that it will also produce an json version of the report in :
  ```
  ./reports/<module_name>/doc-coverage/data.json
  ```

  Output :
  ![Summary](./documentation/coverage-summary.png)
  ![Summary](./documentation/coverage-details.png)


## Count lines of code

This target generates a report counting the number of code, blank and comments lines
of your module.

1. In your project's root CMakeLists.txt :
  ```cmake
  find_package(ClocRule REQUIRED)
  ```

2. In your module's CMakeLists.txt :
  ```cmake
  add_cloc(<module_name>)
  ```

3. Generate the reports :
  ```bash
  # generate cloc for a specific module
  make -C <module_path> cloc-<module_name>

  # generate cloc for all modules
  make cloc

  # remove generated report
  make cloc-clean
  ```

4. Consult the report  :
  ```
  sensible-browser ./reports/<module_name>/cloc/index.html
  ```

  Note that it will also produce an xml version of the report in :
  ```
  ./reports/<module_name>/cloc/index.xml
  ```

  Output :
  ![Cloc](./documentation/cloc.png)



## Cppcheck static analysis


Cppcheck is a static C++ code analyzer tool. This target will produce a report of
cppcheck output.

1. In your project's root CMakeLists.txt :
  ```cmake
  find_package(CppcheckRule REQUIRED)
  ```

2. In your module's CMakeLists.txt :
  ```cmake
  add_cppcheck(<module_name>)
  ```

3. Generate the reports :
  ```bash
  # generate cloc for a specific module
  make -C <module_path> cppcheck-<module_name>

  # generate cloc for all modules
  make cppcheck

  # remove generated report
  make cppcheck-clean
  ```

4. Consult the report  :
  ```
  sensible-browser ./reports/<module_name>/cppcheck/index.html
  ```

  Note that it will also produce an xml version of the report in :
  ```
  ./reports/<module_name>/cppcheck/index.xml
  ```

  Output :
  ![Cppcheck](./documentation/cppcheck.png)


## Unit tests

XTDMake detects automatically tests source files, create cmake binary targets
accordingly and generates test reports.

### Global design

- find tests
- build binary targets
- create individual execution targets
- create overall execution and report generating target

### Finding the test sources

XTDMake's CheckRule modules scans given ```DIRECTORY``` for file names prefixed
by ```PREFIX``` and matching one of given wildcard ```PATTERNS```. Each matched file
is considered as a standalone test.

### Binary targets

For matched files named ```<prefix><name>.*```, the rule declares a new
singled source executable ```<name>```. Given ```INCLUDES``` and ```LINKS``` are
respectively given as executable's ```include_directories``` and ```link_libraries```.

User may modify generated target at will with cmake's ```target_include_directories```,
```target_link_libraries``` etc.

### Test targets

Registered executable is then added as a standard cmake test using ```add_test``` 
with given arguments ```ARGS```.



Test source files in ```DIRECTORY``` that are prefixed by ```PREFIX``` and matches
one of given ```PATTERNS``` are used to declare a test binary target. The name of
the target is the source file name stripped of its prefix and extension.





1. In your project's root CMakeLists.txt :
  ```cmake
  find_package(CheckRule REQUIRED)
  ```

2. In your module's CMakeLists.txt :
  ```cmake
  add_check(<module_name>
    [PATTERNS pattern1  [pattern2 ...]]
    [INCLUDES dir1      [dir2 ...]]
    [LINKS    lib1      [lib2 ...]]
    [ENV      name1=val [name2=val ...]]
    [ARGS     arg1      [arg2 ...]]
    [DIRECTORY dir]
    [PREFIX    name]
    [JOBS      number]
    [NO_DEFAULT_ENV]
    [NO_DEFAULT_ARGS]
    [NO_DEFAULT_INCLUDES]
  )
  ```

  - ```PATTERNS``` : List of wildcard to find source files in test directory.
    Default is ```${CheckRule_DEFAULT_PATTERNS}``` .

  - ```INCLUDES``` : List of include directories to add to test targets binaries.
    Default is ```${CheckRule_DEFAULT_INCLUDES}```, unless ```NO_DEFAULT_INCLUDES```
    is given.

  - ```LINKS``` : List of libraries to link test targets. Values of
   ```${CheckRule_DEFAULT_LINKS}``` are added unless ```NO_DEFAULT_LINKS``` is given.

  - ```ENV``` : List of environment variable to set before running tests. Values of
    ```${CheckRule_DEFAULT_ENV}``` as added unless ```NO_DEFAULT_ENV``` is given.

  - ```ARGS``` : List of arguments to run the test binaries with. Values of
    ```${CheckRule_DEFAULT_ARGS}``` are added unless ```NO_DEFAULT_ARGS``` is given.

  - ```DIRECTORY``` : Test directory path. Default is
    ```${CMAKE_CURRENT_SOURCE_DIR}/${CheckRule_DEFAULT_DIRECTORY}/``` .

  - ```PREFIX``` : Prefix of test source files in directory. Default is
    ```${CheckRule_DEFAULT_PREFIX}``` .

  - ```JOBS``` : Number of parallel jobs to run tests suite. Default is
    ```CheckRule_DEFAULT_JOBS``` .

  - ```NO_DEFAULT_ENV``` : When given, ```${CheckRule_DEFAULT_ENV}``` are not
    added to ```ENV``` .

  - ```NO_DEFAULT_ARGS``` : When given, ```${CheckRule_DEFAULT_ARGS}``` are not
    added to ```ARGS``` .

  - ```NO_DEFAULT_INCLUDES``` : When given, ```${CheckRule_DEFAULT_INCLUDES}``` are not
    added to ```INCLUDE``` .

  - ```NO_DEFAULT_LINKS``` : When given, ```${CheckRule_DEFAULT_LINKS}``` are not
    added to ```LINKS``` .

  Global configuration values :
  - ```CheckRule_DEFAULT_ARGS```      : Default is empty.
  - ```CheckRule_DEFAULT_ENV```       : Default is empty.
  - ```CheckRule_DEFAULT_INCLUDES```  : Default is empty.
  - ```CheckRule_DEFAULT_LINKS```     : Default is empty.
  - ```CheckRule_DEFAULT_DIRECTORY``` : Default is ```/unit```.
  - ```CheckRule_DEFAULT_PATTERNS```  : Default is ```.c .cc .cpp```.
  - ```CheckRule_DEFAULT_JOBS```      : Default is ```1```.
  - ```CheckRule_DEFAULT_PREFIX```    : Default is ```Test```.



3. Generate the reports :
  ```bash
  # generate cloc for a specific module
  make -C <module_path> cppcheck-<module_name>

  # generate cloc for all modules
  make cppcheck

  # remove generated report
  make cppcheck-clean
  ```

4. Consult the report  :
  ```
  sensible-browser ./reports/<module_name>/cppcheck/index.html
  ```

  Note that it will also produce an xml version of the report in :
  ```
  ./reports/<module_name>/cppcheck/index.xml
  ```

  Output :
  ![Cppcheck](./documentation/cppcheck.png)

## Code coverage

TBD

## Report Interface

In order to make all these reports as accessible as possible, XTDMake provides a
little locally consultatble web interface that helps the developer to navigate
through all generated reports.


1. In your project's root CMakeLists.txt :
  ```cmake
  find_package(Reports REQUIRED)
  ```

3. Generate the reports :
  ```bash
  # generate all reports
  make reports

  # open the web interface
  make reports-show

  # delete all reports
  make reports-clean
  ```

  Output :
  ![Reports](./documentation/reports.png)

<!--  LocalWords:  ident libcommon tf pwd revno affab bfe ce xtdmake coverxygen
 -->
<!--  LocalWords:  StaticShared WERROR DocCoverage Cloc cloc Cppcheck lcov xsltproc
 -->
<!--  LocalWords:  cppcheck graphviz sudo XTDMake CMake
 -->

<!-- Local Variables: -->
<!-- ispell-local-dictionary: "american" -->
<!-- End: -->
