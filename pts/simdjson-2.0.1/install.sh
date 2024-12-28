#!/bin/sh

if [[ -z "$ALIVECC_PARALLEL_FIFO" || ! -d simdjson-2.0.4 ]]; then
    rm -rf simdjson-2.0.4
    tar -xf simdjson-2.0.4.tar.gz
fi
cd simdjson-2.0.4
sed -i '734i (void) count;' tests/dom/document_stream_tests.cpp

mkdir build
cd build
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    cmake .. -DCMAKE_BUILD_TYPE=Release -DSIMDJSON_JUST_LIBRARY=ON
    "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" make "-j${NUM_CPU_CORES}"
else
    cmake .. -DCMAKE_BUILD_TYPE=Release -DSIMDJSON_JUST_LIBRARY=OFF
    make "-j$NUM_CPU_CORES"
fi
echo $? > ~/install-exit-status
cd ~

TASKSET="nice -n -20 taskset -c 1"

echo "#!/bin/sh
cd simdjson-2.0.4/build/benchmark
$TASKSET ./bench_ondemand --benchmark_min_time=30 --benchmark_filter=\$@\<simdjson_ondemand\> > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > simdjson
chmod +x simdjson
