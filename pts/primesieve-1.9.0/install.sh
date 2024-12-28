#!/bin/sh

version=8.0
tar xvf primesieve-$version.tar.gz
cd primesieve-$version

cmake . -DBUILD_SHARED_LIBS=OFF
MAKE_PROGRAM=make
if [ "$OS_TYPE" = "BSD" ]; then
    MAKE_PROGRAM=gmake
fi
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" "$MAKE_PROGRAM" "-j${NUM_CPU_CORES}"
else
    "$MAKE_PROGRAM" "-j${NUM_CPU_CORES}"
fi
echo $? > ~/install-exit-status
cd ~

TASKSET="nice -n -20 taskset -c 1"
echo "#!/bin/sh
$TASKSET primesieve-$version/./primesieve -t 1 \$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > primesieve-test
chmod +x primesieve-test
