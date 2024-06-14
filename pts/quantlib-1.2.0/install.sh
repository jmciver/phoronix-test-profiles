#!/bin/sh
tar -xf QuantLib-1.32.tar.gz
cd QuantLib-1.32/build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-O3 -march=native" -DCMAKE_C_FLAGS="-O3 -march=native" -DQL_ENABLE_PARALLEL_UNIT_TEST_RUNNER=ON 
if [ $OS_TYPE = "BSD" ]
then
	gmake -j $NUM_CPU_CORES
	echo $? > ~/install-exit-status
else
	make -j $NUM_CPU_CORES
	echo $? > ~/install-exit-status
fi
cd ~
TASKSET="nice -n -20 taskset -c 1"
echo "#!/bin/bash
cd QuantLib-1.32/build
$TASKSET ./test-suite/quantlib-benchmark > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > quantlib
chmod +x quantlib
