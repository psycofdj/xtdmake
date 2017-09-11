Installation
============

From PPA Package
----------------

Project homepage : https://launchpad.net/~psycofdj/+archive/ubuntu/xtdmake

1. Add PPA repository to apt

   .. code-block:: bash

     sudo add-apt-repository ppa:psycofdj/xtdmake

2. Update apt

   .. code-block:: bash

     sudo apt-get update

3. Install XTDMake

   .. code-block:: bash

     sudo apt-get install --install-suggests xtdmake


From source
-----------


Project homepage : https://github.com/psycofdj/xtdmake

.. note::

   Each packages requires a set of programs. You're not forced to install everything
   if you don't need all XTDMake's modules.

1. Install suggested dependencies

  .. code-block:: bash

    # Doxygen (Generate documentation from source code)
    sudo apt-get install doxygen
    # Dot (Generate pictures from graphs)
    sudo apt-get install graphviz
    # xsltproc (Transform XML files from XSLT style-sheets)
    sudo apt-get install xsltproc
    # lcov (Generate HTML results from code-coverage information)
    sudo apt-get install lcov
    # coverxygen (Generate documentation-coverage information from doxygen documentation)
    sudo pip install coverxygen
    # cloc (Count line of codes)
    sudo apt-get install cloc
    # cppcheck (C++ static code analysis tool)
    sudo apt-get install cppcheck
    # valgrind instrumentation framework for dynamic analysis
    sudo apt-get install valgrind
    # jq, awk for json
    sudo apt-get install jq
    # java 8
    sudo apt-get install openjdk-8-jre
    # PMD
    wget https://github.com/pmd/pmd/releases/download/pmd_releases%2F5.7.0/pmd-bin-5.7.0.zip
    sudo unzip -d /usr/share pmd-bin-5.7.0.zip
    # Include what you use
    sudo apt-get install iwyu

2. Download latest release

  .. code-block:: bash

    # fetch latest release version
    tag=$(curl -s https://api.github.com/repos/psycofdj/xtdmake/tags | \
      jq -r '[ .[] | .["name"] ] | sort | last')

    # download archive
    wget https://github.com/psycofdj/xtdmake/archive/${tag}.tar.gz -O xtdmake-${tag}.tar.gz

    # uncompress archive
    tar xvzf xtdmake-${tag}.tar.gz


3. Install XTDMake

  .. code-block:: bash

    cd xtdmake-${tag}.tar.gz
    mkdir .build
    cd .build
    cmake ..
    sudo make install





..
   Local Variables:
   ispell-local-dictionary: "en"
   End:
