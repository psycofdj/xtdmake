--------
Tracking
--------

This module module wraps ``C`` and ``CXX`` linkers to embed RSC keywords string
in your binaries and libraries. RSC keywords ran be later read using the ``ident``
command from ``rcs`` Ubuntu package.

Information included for libraries :

  $date
    compile date of binary
  $time
    compile time of binary
  $revno
    current git or bzr revision if any

Information included for binaries :

  $date
    compile date of binary
  $time
    compile time of binary
  $name
    target name of binary
  $user
    shell user used for compilation
  $pwd
    compile build directory
  $revno
    current git or bzr revision if any
  $archive
    [lib_name] (data)  compile date of *lib_name*
    [lib_name] (time)  compile time of *lib_name*
    [lib_name] (revno) git or bzr revno of *lib_name* if any

Functions
---------

.. code-block:: cmake

  enable_tracking()

You must call this function on top level CMakeLists.txt after loading the Tracking
module to enable tracking on your libraries and binaries.

Example
-------

Given a binary ``tAppender`` compiled with static libraries ``libxtdcore_s`` and
``libxtdtests_s`` :

::

  $ ident tAppender

  $date: 01-01-2017 $
  $time: 15:18:03 $
  $name: tAppender $
  $user: psyco $
  $host: psyco-laptop-tux $
  $pwd: /home/psyco/dev/xtdcpp/.release/core $
  $revno: 9422c4460c24c7e0289f1d4ff0525e14ccabaedb $
  $archive: [libxtdcore_s] (time) 15:17:33 $
  $archive: [libxtdcore_s] (date) 01-01-2017 $
  $archive: [libxtdcore_s] (revno) 9422c4460c24c7e0289f1d4ff0525e14ccabaedb $
  $archive: [libxtdtests_s] (time) 15:14:06 $
  $archive: [libxtdtests_s] (date) 01-01-2017 $
  $archive: [libxtdtests_s] (revno) 9422c4460c24c7e0289f1d4ff0525e14ccabaedb $


How is works
------------

Tracking module wraps C and C++ default linker and archive commands with
``link_wrapper`` and ``ar_wrapper`` scripts.

``ar_wrapper`` silently adds a ``.version`` file when creating  archives. Archives
are sort of tars of object files, adding a file to the archive is not harmful.

``link_wrapper`` does 3 things. First it searches for ``.version`` files on linked
static archives and adds their content to the list. After gathering all possible
information, it silently adds a source file to default link command. This source
file declares ``char rscid[] = __RCSID__``. Finally, the wrapper adds a
``-D__RCSID__=`` to linker command that defines the value of rcs keyword.


..
   Local Variables:
   ispell-local-dictionary: "en"
   End:
