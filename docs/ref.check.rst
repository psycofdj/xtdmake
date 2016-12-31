.. _CheckRule:

-------
CheckRule
-------

.. contents::
   :local:

Overview
--------

This module generates a report from result of cppcheck static analysis.

**Prerequisites**

This module requires that ``enable_testing()`` is called at top level CMakeLists.txt.


Functions
---------

.. code-block:: cmake

  add_check(<module_name>
    [PATTERNS  <pattern>     [<pattern>   ...]]
    [INCLUDES  <dir>         [<dir>       ...]]
    [LINKS     <lib>         [<lib>       ...]]
    [ENV       <key>=<value> [<key=value> ...]]
    [ARGS      <arg>         [<arg>       ...]]
    [DIRECTORY <dir>]
    [PREFIX    <str>]
    [JOBS      <int>]
    [NO_DEFAULT_ENV]
    [NO_DEFAULT_ARGS]
    [NO_DEFAULT_INCLUDES]
    [NO_DEFAULT_LINKS]
  )


This function generates cmake targets that produce doxygen documentation for a given
module. Generated targets are added as dependency of the global ``doc`` and
``doc-clean`` targets.


**Parameters**

PATTERNS
  List of directories where target should search source files to process.
  Ultimatly this paramter will be given to doxygen ``INPUT`` configuration
  (see https://www.stack.nl/~dimitri/doxygen/manual/config.html#cfg_input).

  Default value is given by :py:obj:`CheckRule_DEFAULT_PATTERNS`







**Global variables**

.. py:attribute:: CheckRule_DEFAULT_PATTERNS
                  ""
.. py:attribute:: CheckRule_DEFAULT_INCLUDES
                  ""
.. py:attribute:: CheckRule_DEFAULT_LINKS
                  ""
.. py:attribute:: CheckRule_DEFAULT_ENV
                  ""
.. py:attribute:: CheckRule_DEFAULT_DIRECTORY
                  ""
.. py:attribute:: CheckRule_DEFAULT_PREFIX
                  ""
.. py:attribute:: CheckRule_DEFAULT_JOBS
                  ""


Generated rules
---------------

<module_name>-check
  generate doc report for module ``<module_name>``

<module_name>-check-clean
  removes doc report for module ``<module_name>``

check
  generate doc reports for all modules

check-clean
  removes doc reports for all modules


**Dependencies**

.. graphviz::

   digraph G {
     rankdir="LR";
     node [shape=box, style=filled, fillcolor="#ffff99", fontsize=12];
     "cmake" -> "dir_list(INPUT)"
     "cmake" -> "doc"
     "cmake" -> "doc-clean"
     "doc" -> "<module>-doc"
     "<module>-doc" -> "file_list(INPUT, FILE_PATTERNS)"
     "doc-clean" -> "<module>-doc-clean"
   }

.. warning::

  The dependency of cmake build system to the modification time of
  :py:obj:`INPUT` directories doesn't work with cmake versions
  prior to 3.0. This mean you must re-run cmake after adding new sources files in
  order to properly update the rule files dependencies

Generated reports
-----------------

**XML** : ``reports/<module_name>/doc/xml/index.xml``

**HTML** : ``reports/<module_name>/doc/html/index.html``

Bellow an example of generated html report :

.. image:: _static/doc.png
  :align: center

..
   Local Variables:
   ispell-local-dictionary: "en"
   End:
