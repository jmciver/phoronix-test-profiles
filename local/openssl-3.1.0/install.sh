#!/bin/sh
tar -xf openssl-3.1.0.tar.gz
cd openssl-3.1.0
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    ./config no-zlib && \
        "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" make "-j${NUM_CPU_CORES}"
elif [[ ! -z "$CLANG_PLUGIN_STATISTICS" ]]; then
    CFLAGS="$CLANG_PLUGIN_STATISTICS" \
            ./Configure no-zlib && \
        make |& tee run-build.log
else
    ./config no-zlib && \
        make "-j${NUM_CPU_CORES}"
fi
echo $? > ~/install-exit-status
cd ~
TASKSET="nice -n -20 taskset -c 1"
echo "#!/bin/sh
cd openssl-3.1.0
LD_LIBRARY_PATH=.:\$LD_LIBRARY_PATH $TASKSET ./apps/openssl speed -multi 1 -seconds 30 \$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > openssl
chmod +x openssl
