#!/bin/sh

rm -rf simdjson-2.0.4
tar -xf simdjson-2.0.4.tar.gz
cd simdjson-2.0.4
sed -i '734i (void) count;' tests/dom/document_stream_tests.cpp

mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DSIMDJSON_JUST_LIBRARY=OFF
make -j $NUM_CPU_CORES
echo $? > ~/install-exit-status
cd ~

TASKSET="nice -n -20 taskset -c 1"

echo "#!/bin/sh
cd simdjson-2.0.4/build/benchmark
$TASKSET ./bench_ondemand --benchmark_min_time=30 --benchmark_filter=\$@\<simdjson_ondemand\> > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > simdjson
chmod +x simdjson
