#!/bin/sh

TASKSET="nice -n -20 taskset -c 1"

tar -xf sqlite-3460-for-speedtest.tar.gz
cd sqlite-version-3.46.0

MAKE_PROGRAM=make
if [ $OS_TYPE = "BSD" ]; then
    MAKE_PROGRAM=gmake
fi
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    ./configure && \
        "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" "$MAKE_PROGRAM" "-j${NUM_CPU_CORES}" sqlite3.o
elif [[ ! -z "$CLANG_PLUGIN_STATISTICS" ]]; then
    CFLAGS="$CLANG_PLUGIN_STATISTICS" \
          ./configure && \
        "$MAKE_PROGRAM" |& tee run-build.log
else
    ./configure && \
        "$MAKE_PROGRAM" "-j${NUM_CPU_CORES}" speedtest1
fi
echo $? > ~/install-exit-status

cd ~

echo "#!/bin/sh
cd sqlite-version-3.46.0
$TASKSET ./speedtest1 \$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > sqlite-speedtest
chmod +x sqlite-speedtest
