<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-generate-toc again -->
**Table of Contents**

- [Introduction](#introduction)
- [Install](#install)
    - [Get XTDMake](#get-xtdmake)
        - [From source](#from-source)
        - [From Ubuntu package](#from-ubuntu-package)
- [Using XTDMake](#using-xtdmake)
    - [Loading the packages](#loading-the-packages)
    - [Packages vs targets](#packages-vs-targets)
    - [Configuration](#configuration)
        - [Default parameter values](#default-parameter-values)
        - [Change parameter's default value](#change-parameters-default-value)
        - [Variables in parameter default value](#variables-in-parameter-default-value)
    - [Calling the function](#calling-the-function)
- [Package reference](#package-reference)
    - [DocCoverageRule](#doccoveragerule)
        - [Function reference](#function-reference)
        - [Generated targets](#generated-targets)
        - [Output reports](#output-reports)
    - [CheckRule](#checkrule)
        - [Function reference](#function-reference)
        - [Global design](#global-design)
        - [Finding the test sources](#finding-the-test-sources)
        - [Binary targets](#binary-targets)
        - [Test targets](#test-targets)
    - [CovRule](#covrule)
    - [Report Interface](#report-interface)
    - [Tracking](#tracking)
- [compile our binary (which links to libcommon_s)](#compile-our-binary-which-links-to-libcommons)
- [extract informations from generated file](#extract-informations-from-generated-file)
- [output result](#output-result)
- [compile our shared library libcommon.so](#compile-our-shared-library-libcommonso)
- [extract informations from generated file](#extract-informations-from-generated-file)
- [output result](#output-result)
    - [StaticShared](#staticshared)

<!-- markdown-toc end -->


# Introduction

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




Install
=======


Get XTDMake
-----------

### From source

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
  sudo pip install coverxygen
  # cloc (Count line of codes)
  sudo apt-get install cloc
  # cppcheck (C++ static code analysis tool)
  sudo apt-get install cppcheck
  # valgrind instrumentation framework for dynamic analysis
  sudo apt-get install valgrind
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
  list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/xtdmake/src")
  find_package(XTDMake REQUIRED)
  ```

### From Ubuntu package

1. Add repository to apt

   ```bash
   sudo add-apt-repository ppa:psycofdj/xtdmake
   sudo apt-get update
   sudo apt-get install --install-suggests xtdmake
   sudo pip install coverxygen
   ```

2. Load XTDMake in your project's root CMakeLists.txt

  ```cmake
  find_package(XTDMake REQUIRED)
  ```

# Using XTDMake

XTDMake defines multiple CMake packages. Each package provides a function to
generate a specific kind of report for your module. Like every other packages, they
must be loaded with the ```find_package``` function.

Available packages :
 - ```DocRule```         : generates doxygen code documentation
 - ```DocCoverageRule``` : measure coverage of generated documentation
 - ```CppcheckRule```    : generates report from cppcheck output (static analysis)
 - ```ClocRule```        : generates report from cloc output (count lines of codes)
 - ```CheckRule```       : generate unit tests binaries and test report
 - ```CovRule```         : measure code coverage from unit tests run
 - ```MemcheckRule```    : measure leak from unit test run


In addition, XTDMake provides two utility packages :
 - ```Tracking``` : automatically adds fine tracking information in your binaries
   and libraries
 - ```StaticShared``` : generates both static and dynamic libraries from same set
   of objects.


## Loading the packages

First thing you need to do is to load the packages you need in your root
CMakeLists.txt

```cmake
  xtdmake_init(
    [StaticShared    REQUIRED]
    [DocRule         REQUIRED]
    [DocCoverageRule REQUIRED]
    [CppcheckRule    REQUIRED]
    [CheckRule       REQUIRED]
    [ClocRule        REQUIRED]
    [Tracking        REQUIRED]
    [Cppunit         REQUIRED]
    [CovRule         REQUIRED]
    [MemcheckRule    REQUIRED]
    [Reports         REQUIRED])
```

If ```REQUIRED``` option is given, CMake will emit an error if loaded package is
missing some underlying dependencies.

Example : ```CppcheckRule``` need cppcheck to be installed on the system.


## Packages vs targets

Once loaded, each package defines a function. When called, this function generates
one or more targets that generate the output report.

For instance :
- package : ```CppcheckRule```
- declared function : ```add_cppcheck(<module_name>)```
- when called, defined targets are :
  - ```<module>-cppcheck```
  - ```<module>-check-clean```

## Configuration
### Default parameter values

Some of theses functions have optional parameters that customize how should the report
be generated for the given module. All parameters have a default value that can be
set globally.

Example:
 - function : ```add_cppcheck(<module> [INPUT] [FILE_PATTERNS])```,
 - optional parameters : ```INPUT``` and ```FILE_PATTERNS```
 - global default value :
   - ```CppcheckRule_DEFAULT_INPUT```
   - ```CppcheckRule_DEFAULT_FILE_PATTERNS```

### Change parameter's default value

To set a new default value, use CMake standard ```set```:
```cmake
set(CppcheckRule_DEFAULT_INPUT "my_default_value")
set(CppcheckRule_DEFAULT_FILE_PATTERNS "my_default_value")
```


### Variables in parameter default value

Values given in default parameters are evaluated for each module. This allow to
use CMake variable that depends on the current CMakeLists.txt.
You can escape CMake variable as follow :
```cmake
set(CppcheckRule_DEFAULT_INPUT "\${CMAKE_CURRENT_SOURCE_DIR}/src")
```


## Calling the function

To generate report targets, simply call the corresponding function in your module's
CMakeLists.txt :

```cmake
add_cppcheck(<module>
  FILE_PATTERNS *.cc *.hh *.hxx)
```

Given parameters overloads default values.


# Package reference

## CheckRule

XTDMake detects automatically tests source files, create cmake binary targets
accordingly and generates test reports.



### Function reference
  ```cmake
  add_check(<module>
    [PATTERNS  pattern1 [pattern2 ...]]
    [INCLUDES  dir1 [dir2 ...]]
    [LINKS     lib1 [lib2 ...]]
    [ENV       key1=value [key2=value ...]]
    [ARGS      arg1 [arg2 ...]]
    [DIRECTORY dir]
    [PREFIX    str]
    [JOBS      int]
    [NO_DEFAULT_ENV]
    [NO_DEFAULT_ARGS]
    [NO_DEFAULT_INCLUDES]
    [NO_DEFAULT_LINKS]
  )
  ```

- ```PATTERNS```:

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
singled source executable ```<name>```. Given ```INCLUDES``` and ```LINKS```
parameters are respectively given as executable ```include_directories``` and
```link_libraries``` .

User may modify generated target at will with cmake's ```target_include_directories```,
```target_link_libraries``` on generated target name.

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

## CovRule

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

## Tracking

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

## StaticShared

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

<!--  LocalWords:  ident libcommon tf pwd revno affab bfe ce xtdmake coverxygen
 -->
<!--  LocalWords:  StaticShared WERROR DocCoverage Cloc cloc Cppcheck lcov xsltproc
 -->
<!--  LocalWords:  cppcheck graphviz sudo XTDMake CMake
 -->

<!-- Local Variables: -->
<!-- ispell-local-dictionary: "american" -->
<!-- End: -->
