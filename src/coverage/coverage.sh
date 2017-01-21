#!/bin/bash
quiet="-q"

function lock
{
  l_timeout=900
  echo "[${module}-cov] acquiring cov lock..."
  while true; do
    if [ ! -f "${CMAKE_BINARY_DIR}/cov.lock" ]; then
        echo -n "$$" > ${CMAKE_BINARY_DIR}/cov.lock
        break;
    else
      l_pid=$(cat "${CMAKE_BINARY_DIR}/cov.lock")
      kill -0 "${l_pid}" 2>/dev/null || {
        rm -f ${CMAKE_BINARY_DIR}/cov.lock
      }
    fi
    l_timeout=$((l_timeout - 1))
    if [ ${l_timeout} -le 0 ]; then
        echo "unable to aquire lock, giving up"
        exit 1
    fi
    sleep 1
  done
  echo "[${module}-cov] cov lock acquired"
}


function unlock
{
  echo "[${module}-cov] releasing cov lock..."
  rm -f ${CMAKE_BINARY_DIR}/cov.lock
  echo "[${module}-cov] cov lock released"
}


# export generated gcda to tmp dir, unlock asap
l_tmp=$(mktemp -d)

lock

# delete existing gcda
find ${CMAKE_CURRENT_BINARY_DIR} \
     -name '*.gcda' \
     -exec rm -f \{\} \;

echo "[${module}-cov] running tests"
make ${module}-check-run-forced >/dev/null 2>&1

find ${CMAKE_CURRENT_BINARY_DIR} \
     -name '*.gcda' \
     -and \( ! -wholename "*${CovRule_EXCLUDE_PATTERNS}*.gcda" \) \
     -exec cp --parents \{\} ${l_tmp} \;

unlock


rm -f \
   ${CMAKE_CURRENT_BINARY_DIR}/coverage-run.info \
   ${CMAKE_CURRENT_BINARY_DIR}/coverage-initial.info \
   ${CMAKE_CURRENT_BINARY_DIR}/coverage.info


find ${CMAKE_CURRENT_BINARY_DIR} \
     -name '*.gcno' \
     -and \( ! -wholename "*${CovRule_EXCLUDE_PATTERNS}*.gcno" \) \
     -exec cp --parents \{\} ${l_tmp} \;


# collect initial data
echo "[${module}-cov] collect initial data"
${Lcov_EXECUTABLE} ${quiet} -c -i \
                   -d ${l_tmp} \
                   -o ${CMAKE_CURRENT_BINARY_DIR}/coverage-initial.info 2>&1 | \
    grep -v 'Note:'

echo "[${module}-cov] collecting coverage data"
${Lcov_EXECUTABLE} ${quiet} -c \
                   -d ${l_tmp} \
                   -o ${CMAKE_CURRENT_BINARY_DIR}/coverage-run.info || \
    cp ${CMAKE_CURRENT_BINARY_DIR}/coverage-initial.info \
       ${CMAKE_CURRENT_BINARY_DIR}/coverage-run.info

echo "[${module}-cov] assembling run and initial data"
${Lcov_EXECUTABLE} ${quiet} \
                   -a ${CMAKE_CURRENT_BINARY_DIR}/coverage-initial.info \
                   -a ${CMAKE_CURRENT_BINARY_DIR}/coverage-run.info \
                   -o ${CMAKE_CURRENT_BINARY_DIR}/coverage.info || \
    cp ${CMAKE_CURRENT_BINARY_DIR}/coverage-initial.info \
       ${CMAKE_CURRENT_BINARY_DIR}/coverage.info

echo "[${module}-cov] extracting source directory data"
${Lcov_EXECUTABLE} ${quiet} \
                   -e ${CMAKE_CURRENT_BINARY_DIR}/coverage.info \
                   "${CMAKE_CURRENT_SOURCE_DIR}/*" \
                   -o ${CMAKE_CURRENT_BINARY_DIR}/coverage.info


# delete tmp dir
rm -rf ${l_tmp}
