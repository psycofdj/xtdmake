------------
StaticShared
------------

.. contents::
   :local:

This module provides an equivalent of cmake's ``add_library`` function that builds
both static and shared libraries from the same set of object file which improves
compilation time.

.. warning::
  Objects are created with ``-fPIC`` flag which *may* lead to a loss of runtime
  performance when linking to static library.


Prerequisites
-------------

name and version
  The following variables must be defined :

  - ``PROJECT_NAME``
  - ``PROJECT_VERSION_MAJOR``
  - ``PROJECT_VERSION_MINOR``
  - ``PROJECT_VERSION_PATH``

cmake
  This module doesn't work properly with cmake version prior to 3.0. However this
  module is still compatible with such versions but will create two separate sets
  of objects for static and shared libraries.


Functions
---------

.. code-block:: cmake

  add_shared_static_library(<libname>
    <source> [ <source> ... ]
    [ INSTALL_HEADERS_PATTERNS  <pattern>  [<pattern>  ...]]
    [ INSTALL_HEADERS_DESTINATION <path> ]
    [ INSTALL_LIBS_DESTINATION    <path> ]
    [ INSTALL_HEADERS_DIRECTORY   <dir>  ]
    [ VERSION <version>   ]
    [ SOVERSION <version> ]
    [ NOINSTALL ]
  )

Parameters
----------

libname
  Internal name of target libraries. At install time, files will be respectively
  named ``lib${PROJECT_NAME}<name>.so`` and ``lib${PROJECT_NAME}<name>.a``.

source
  List of source file to build in libraries.

INSTALL_HEADERS_PATTERNS
  List of glob pattern to match headers file to install with target libraries.

  Default value is given by :py:obj:`StaticShared_DEFAULT_INSTALL_HEADERS_PATTERNS`.


INSTALL_HEADERS_DIRECTORY
  Directory containing headers to install with target libraries.

  Default value is given by :py:obj:`StaticShared_DEFAULT_INSTALL_HEADERS_DIRECTORY`.

INSTALL_HEADERS_DESTINATION
  Headers target install directory.

  Default value is given by :py:obj:`StaticShared_DEFAULT_INSTALL_HEADERS_DESTINATION`.

INSTALL_LIBS_DESTINATION
  Libraries target install directory

  Default value is given by :py:obj:`StaticShared_DEFAULT_INSTALL_LIBS_DESTINATION`.

VERSION
  Shared library version given to cmake ``VERSION`` property

SOVERSION
  Shared library version given to cmake ``SOVERSION``  property.

NOINSTALL
  Disables installation configuration for current libraries



Global variables
----------------

.. py:attribute:: StaticShared_DEFAULT_INSTALL_LIBS_DESTINATION
                  "lib"
.. py:attribute:: StaticShared_DEFAULT_INSTALL_HEADERS_DESTINATION
                  "include/\${PROJECT_NAME}/\${name}"
.. py:attribute:: StaticShared_DEFAULT_INSTALL_HEADERS_PATTERNS
                  "*.h;*.hxx;*.hh;*.hpp"
.. py:attribute:: StaticShared_DEFAULT_DIRECTORY
                  "src/"
.. py:attribute:: StaticShared_DEFAULT_DEFAULT_VERSION
                  "\${PROJECT_VERSION_MAJOR}.\${PROJECT_VERSION_MINOR}.\${PROJECT_VERSION_PATCH}"
.. py:attribute:: StaticShared_DEFAULT_DEFAULT_SOVERSION
                  "\${PROJECT_VERSION_MAJOR}"

Generated targets
-----------------

``<libname>``
  Target shared library

``<libname>_s``
   Target static library

Dependencies
------------

.. graphviz::

   digraph G {
     rankdir="LR";
     node [shape=box, style=filled, fillcolor="#ffff99", fontsize=12];
     "libname"   -> "objects(source...)"
     "libname_s" -> "objects(source...)"
     "objects(source...)" -> "list(source...)"
   }

..
   Local Variables:
   ispell-local-dictionary: "en"
   End:
