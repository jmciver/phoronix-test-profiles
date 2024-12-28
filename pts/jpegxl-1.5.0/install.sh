#!/bin/sh
tar -xf libjxl-0.7.0.tar.gz
tar -xf png-samples-1.tar.xz
unzip -o sample-photo-6000x4000-1.zip
cd libjxl-0.7.0
./deps.sh
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF -DJPEGXL_FORCE_SYSTEM_BROTLI=ON
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" cmake --build . -- "-j${NUM_CPU_CORES}"
else
    cmake --build . -- "-j${NUM_CPU_CORES}"
fi
echo $? > ~/install-exit-status

TASKSET="nice -n -20 taskset -c 1"

cd ~
echo "#!/bin/sh
$TASKSET ./libjxl-0.7.0/build/tools/cjxl --num_threads=1 \$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > jpegxl
chmod +x jpegxl
