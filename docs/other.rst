---------------
Other functions
---------------

.. contents::
   :local:

xtdmake_eval
------------

.. code-block:: cmake

  xtdmake_eval(var expr)

Evaluates cmake expression ``expr`` and store it in ``var``.

expr
  cmake expression to evaluate. Example: "\${CMAKE_CURRENT_SOURCE_DIR}/toto"

var
  output variable


xtdmake_get_directory
---------------------

.. code-block:: cmake

  xtdmake_get_directory(out in)

This function extract directory of path given as ``in`` and stores it in ``out``
variable. This function is compatible with both cmake (< 3.0) and cmake (>= 3.x).

in
  input file path

out
  destination variable


xtdmake_stringify
-----------------

.. code-block:: cmake

  xtdmake_stringify(var)

Transform cmake list is a space-separated string

var
  input list



xtdmake_find_program
--------------------


.. code-block:: cmake

  xtdmake_find_program(ns
    NAMES <name> [<name> ...]
    DOC   <string>
    URL   <string>
    REQUIRED <bool>
    [ VERSION_OPT <options> ]
    [ VERSION_POS <int>     ]
  )

Search program matching one of given ``NAMES``, try to extract its version using
``VERSION_OPT`` and ``VERSION_POS``, prints a message with STATUS or SEND_ERROR flag
depending on ``REQUIRED`` option value.

Searching results are stores in variables prefixed by namespace ``ns`` :
  - ``<ns>_EXECUTABLE``
       name of executable file found among given names
  - ``<ns>_FOUND``
       1 if program was found, 0 otherwise
  - ``<ns>_VERSION``
       version of found program, *unknown* if couldn't find any

ns
  namespace to store result variables

NAMES
  Possible names of searched program

DOC
  Brief description of searched program, displayed in status message when program
  is not found

URL
  url where searched program can be downloaded, displayed in status message when program
  is not found

REQUIRED
  When true and program is not found, status message is replace by an error

VERSION_OPT
  parameter string to pass to program to get its version on stdout, usually ``--version``

VERSION_POS
  position of the version number in the space-delimited string outputted by program
  with ``VERSION_OPT``


**Example**

.. code-block:: cmake

   xtdmake_find_program(cloc
     NAMES cloc
     DOC "cloc code line counting tool"
     URL "http://cloc.sourceforge.net/"
     VERSION_OPT "--version"
     VERSION_POS "0"
     REQUIRED 0)

   if (cloc_FOUND)
     message("cloc executable is ${cloc_EXECUTABLE}")
     message("cloc version ${cloc_VERSION}")
   else()
     message("cloc is not available")
   endif()


xtdmake_find_python_module
--------------------------


.. code-block:: cmake

  xtdmake_find_python_module(ns
   INTERPRETERS <pythonX> [ <pythonX> ... ]
   NAME <name>
   DOC  <string>
   URL  <string>
   REQUIRED <bool>
   VERSION_MEMBER <string>
   VERSION_POS    <string>
  )



..
   Local Variables:
   ispell-local-dictionary: "en"
   End:
