#!/bin/bash
# set -x
quiet="-q"

function lock
{
  l_timeout=600
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

rm -f \
   ${CMAKE_CURRENT_BINARY_DIR}/coverage-run.info \
   ${CMAKE_CURRENT_BINARY_DIR}/coverage-initial.info \
   ${CMAKE_CURRENT_BINARY_DIR}/coverage.info

lock



${Lcov_EXECUTABLE} ${quiet} -z -d ${CMAKE_CURRENT_BINARY_DIR}

# collect initial data
${Lcov_EXECUTABLE} ${quiet} -c -i \
                   -d ${CMAKE_CURRENT_BINARY_DIR} \
                   -o ${CMAKE_CURRENT_BINARY_DIR}/coverage-initial.info

# remove tests from initial
${Lcov_EXECUTABLE} ${quiet} \
                   -r ${CMAKE_CURRENT_BINARY_DIR}/coverage-initial.info \
                   "${CovRule_EXCLUDE_PATTERNS}" \
                   -o ${CMAKE_CURRENT_BINARY_DIR}/coverage-initial.info

# run tests
make ${module}-check-run-forced  VERBOSE=1

# delete tests run data
find ${CMAKE_CURRENT_BINARY_DIR} -name 'test*.gcda' | xargs rm -f

# collect run data
${Lcov_EXECUTABLE} ${quiet} -c \
                   -d ${CMAKE_CURRENT_BINARY_DIR} \
                   -o ${CMAKE_CURRENT_BINARY_DIR}/coverage-run.info || \
    cp ${CMAKE_CURRENT_BINARY_DIR}/coverage-initial.info \
       ${CMAKE_CURRENT_BINARY_DIR}/coverage-run.info

unlock

# assemble initial and run data

${Lcov_EXECUTABLE} ${quiet} \
                   -a ${CMAKE_CURRENT_BINARY_DIR}/coverage-initial.info \
                   -a ${CMAKE_CURRENT_BINARY_DIR}/coverage-run.info \
                   -o ${CMAKE_CURRENT_BINARY_DIR}/coverage.info || \
    cp ${CMAKE_CURRENT_BINARY_DIR}/coverage-initial.info \
       ${CMAKE_CURRENT_BINARY_DIR}/coverage.info

# extract current source dir files
${Lcov_EXECUTABLE} ${quiet} \
                   -e ${CMAKE_CURRENT_BINARY_DIR}/coverage.info \
                   "${CMAKE_CURRENT_SOURCE_DIR}/*" \
                   -o ${CMAKE_CURRENT_BINARY_DIR}/coverage.info
