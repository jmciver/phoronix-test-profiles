#!/bin/sh

TASKSET="nice -n -20 taskset -c 1"

tar -xf sqlite-3460-for-speedtest.tar.gz
cd sqlite-version-3.46.0
./configure
MAKE_PROGRAM=make
if [ $OS_TYPE = "BSD" ]; then
    MAKE_PROGRAM=gmake
fi
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" "$MAKE_PROGRAM" "-j${NUM_CPU_CORES}" speedtest1
else
    "$MAKE_PROGRAM" "-j${NUM_CPU_CORES}" speedtest1
fi
echo $? > ~/install-exit-status

cd ~

echo "#!/bin/sh
cd sqlite-version-3.46.0
$TASKSET ./speedtest1 \$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > sqlite-speedtest
chmod +x sqlite-speedtest
