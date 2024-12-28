#!/bin/sh

unzip -o jpeg-test-1.zip
tar -xzvf libjpeg-turbo-2.1.0.tar.gz
cd libjpeg-turbo-2.1.0
mkdir build
cd build
cmake ..
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
cd libjpeg-turbo-2.1.0/build
$TASKSET ./tjbench ../../jpeg-test-1.JPG -benchtime 20 -warmup 5 -nowrite > \$LOG_FILE
echo \$? > ~/test-exit-status" > tjbench
chmod +x tjbench
