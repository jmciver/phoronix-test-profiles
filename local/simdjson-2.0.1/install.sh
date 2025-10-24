#!/bin/sh

if [[ -z "$ALIVECC_PARALLEL_FIFO" || ! -d simdjson-2.0.4 ]]; then
    rm -rf simdjson-2.0.4
    tar -xf simdjson-2.0.4.tar.gz
fi
cd simdjson-2.0.4
sed -i '734i (void) count;' tests/dom/document_stream_tests.cpp
sed -i 's/operator "" _padded/operator ""_padded/g' singleheader/simdjson.h
sed -i 's/operator "" _padded/operator ""_padded/g' include/simdjson/padded_string.h

mkdir build
cd build

if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    cmake .. -DCMAKE_BUILD_TYPE=Release -DSIMDJSON_JUST_LIBRARY=ON
    "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" make "-j${NUM_CPU_CORES}"
elif [[ ! -z "$CLANG_PLUGIN_STATISTICS" ]]; then
    cmake -GNinja \
          -DCMAKE_BUILD_TYPE=Release \
          -DSIMDJSON_JUST_LIBRARY=OFF \
          -DCMAKE_C_FLAGS_RELEASE="$CLANG_PLUGIN_STATISTICS" \
          -DCMAKE_CXX_FLAGS_RELEASE="$CLANG_PLUGIN_STATISTICS" \
          .. && \
        ninja -j$NUM_CPU_CORES |& tee run-build.log
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
