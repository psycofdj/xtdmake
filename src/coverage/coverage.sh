#!/bin/bash
set -e

g_progName=$(basename $0)
g_verbose=0
g_debug=0
g_module=""
g_excludePatterns=""
g_topBinDir=""
g_binDir=""
g_srcDir=""
g_makeProg="$(which make)"
g_lcovProg="$(which lcov)"

function usage
{
  cat - <<EOF
usage : ${l_progName} [options]

Collects code coverage from module's units-test. In order to get coverage produced by
only module's unit-tests, the scripts implements a global mutex lock that prevents
parallel execution different module.

[options]
     --module     : (required) current module name
     --exclude    : (required) globing pattern of coverage source files to exclude
     --top-bindir : (required) project binary directory path
     --bindir     : (required) module's binary directory path
     --srcdir     : (required) module's source directory path
     --make-bin   : (optional) build program path, default ${g_makeProg}
     --lcov-bin   : (optional) lcov program path, default ${g_lcovProg}
  -v|--verbose    : (optional) enable lcov verbose mode
  -d|--debug      : (optional) enable debug mode
  -h|--help       : (optional) display this message
EOF
  exit 1
}


function read_options
{
  while true; do
    case "$1" in
      --module)
        g_module=$2;
        shift 2;;
      --exclude)
        g_excludePatterns=$2;
        shift 2;;
      --top-bindir)
        g_topBinDir=$2;
        shift 2;;
      --bindir)
        g_binDir=$2;
        shift 2;;
      --srcdir)
        g_srcDir=$2;
        shift 2;;
      --make-bin)
        g_makeProg=$(which $2);
        shift 2;;
      --lcov-bin)
        g_lcovProg=$(which $2);
        shift 2;;
      -v|--verbose)
        g_verbose=1
        shift 1;;
      -d|--debug)
        g_debug=1
        shift 1;;
      -h|--help)
				usage;;
      --)
        shift;
        break;;
      *)
        echo "error: internal problem while parsing options near '$@'"
        usage;;
    esac
  done
}

function error
{
  echo "error : $@"
  usage
}

function check_options
{
  test ! -z "${g_module}" || \
      error "invalid empty --module"
  test ! -z "${g_excludePatterns}" || \
      error "invalid empty --exclude"
  test -d "${g_topBinDir}" || \
      error "invalid --top-bindir='${g_topBinDir}', directory not found"
  test -d "${g_binDir}" || \
      error "invalid --bindir='${g_binDir}', directory not found"
  test -d "${g_srcDir}" || \
      error "invalid --srcdir='${g_srcDir}', directory not found"
  test -f "${g_makeProg}" || \
      error "invalid --make-bin='${g_makeProg}', file not found"
  test -f "${g_lcovProg}" || \
      error "invalid --lcov-bin='${g_lcovProg}', file not found"
}

# aquire mutex, wait until mutex available or timeout reached
function lock
{
  local l_timeout=900
  local l_pid=""

  echo "[${g_module}-cov] acquiring cov lock..."
  while true; do
    if [ ! -f "${g_topBinDir}/cov.lock" ]; then
        echo -n "$$" > ${g_topBinDir}/cov.lock
        break;
    else
      l_pid=$(cat "${g_topBinDir}/cov.lock")
      kill -0 "${l_pid}" 2>/dev/null || {
        rm -f ${g_topBinDir}/cov.lock
      }
    fi
    l_timeout=$((l_timeout - 1))
    if [ ${l_timeout} -le 0 ]; then
        echo "[${g_module}-cov] (pid:$$) unable to aquire lock, giving up"
        exit 1
    fi
    sleep 1
  done
  echo "[${g_module}-cov] (pid:$$) cov lock acquired"
}

# release mutex
function unlock
{
  echo "[${g_module}-cov] (pid:$$) releasing cov lock..."
  rm -f ${g_topBinDir}/cov.lock
  echo "[${g_module}-cov] (pid:$$) cov lock released"
}

# delete from target file matching pattern
function rm_files
{
  local l_target=$1; shift
  local l_pattern=$1; shift

  find ${l_target} -name "${l_pattern}" -exec rm -f \{\} \;
}

# copy files from src dir to dest dir that match given pattern
# and filtering with given exclude
function copy_files
{
  local l_src=$1; shift
  local l_dst=$1; shift
  local l_pattern=$1; shift
  local l_exclude=$1; shift

  find ${l_src} \
       -name "${l_pattern}" \
       -and \( ! -wholename "${l_exclude}" \)

  find ${l_src} \
       -name "${l_pattern}" \
       -and \( ! -wholename "${l_exclude}" \) \
       -exec cp --parents \{\} ${l_dst} \;
}

function lcov_args
{
  if [ ${g_verbose} -eq 0 ]; then
      echo "-q"
  fi
}

# removes gdca files for given directory
function lcov_zero
{
  local l_src=$1; shift

  echo "[${g_module}-cov] (pid:$$) reset coverage data"
  ${g_lcovProg} $(lcov_args) -z -d "${l_src}"
}

# collect initial coverage information from found .gnco files
function lcov_initial
{
  local l_src=$1; shift

  echo "[${g_module}-cov] (pid:$$) collect initial data"
  ${g_lcovProg} \
      $(lcov_args) \
      -c \
      -i \
      -d ${l_src} \
      -o ${g_binDir}/coverage-initial.info
}

# collect reached code coverage information from generated  .gcda files
function lcov_collect
{
  local l_src=$1; shift

  # -b ${g_binDir}

  echo "[${g_module}-cov] (pid:$$) collecting coverage data"
  ${g_lcovProg} \
      $(lcov_args) \
      -c \
      -d ${l_src} \
      -o ${g_binDir}/coverage-run.info || {
    echo "[${g_module}-cov] (pid:$$) error collecting coverage data"
    cp ${g_binDir}/coverage-initial.info ${g_binDir}/coverage-run.info
  }
}

# assemble collected coverage with initial data
function lcov_assemble
{
  echo "[${g_module}-cov] (pid:$$) assembling run and initial data"
  ${g_lcovProg} \
      $(lcov_args) \
      -b ${g_binDir} \
      -a ${g_binDir}/coverage-initial.info \
      -a ${g_binDir}/coverage-run.info \
      -o ${g_binDir}/coverage.info || {
    echo "[${g_module}-cov] error assembling run and initial data"
    cp ${g_binDir}/coverage-initial.info ${g_binDir}/coverage.info
  }
}

# exclude files from collected that don't belongs to basePath directory
function lcov_filter
{
  local l_pattern=$1; shift
  local l_mode=$1; shift
  local l_arg=""

  if [ "${l_mode}" == "extract" ]; then
      l_arg="-e ${g_binDir}/coverage.info"
  else
      l_arg="-r ${g_binDir}/coverage.info"
  fi

  echo "[${g_module}-cov] (pid:$$) extracting source directory data"
  ${g_lcovProg} \
      $(lcov_args) \
      -b ${g_binDir} \
      ${l_arg} \
      "${l_pattern}" \
      -o ${g_binDir}/coverage.info
}

function run_tests
{
  echo "[${g_module}-cov] (pid:$$) running tests"
  ${g_makeProg} -C ${g_topBinDir} ${g_module}-check-run-forced >/dev/null 2>&1
}

function main
{
  if [ ${g_debug} -eq 1 ]; then
      set -x
  fi

  rm -f \
     ${g_binDir}/coverage-run.info \
     ${g_binDir}/coverage-initial.info \
     ${g_binDir}/coverage.info

  lcov_initial "${g_binDir}"

  lock
  lcov_zero    "${g_binDir}"
  run_tests
  lcov_collect "${g_binDir}"
  unlock

  lcov_assemble
  lcov_filter "${g_srcDir}/*"        "extract"
  lcov_filter "${g_excludePatterns}" "remove"
}

l_parseResult=`/usr/bin/getopt -o hvd \
  --long module:,exclude:,top-bindir:,bindir:,srcdir:,make-bin:,lcov-bin:,verbose,debug,help \
	-n "${l_progName}" -- "$@"`

eval set -- "${l_parseResult}"

read_options "$@"
check_options
main
