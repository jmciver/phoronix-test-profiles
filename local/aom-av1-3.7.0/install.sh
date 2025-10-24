#!/bin/sh
tar -xf aom-370.tar.xz
cd aom/build
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    cmake \
        -DENABLE_DOCS=0 \
        -DENABLE_TESTS=0 \
        -DCONFIG_AV1_DECODER=0 \
        -DCMAKE_BUILD_TYPE=Release .. && \
        "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" make "-j${NUM_CPU_CORES}"
elif [[ ! -z "$CLANG_PLUGIN_STATISTICS" ]]; then
    cmake \
        -GNinja \
        -DCMAKE_C_FLAGS_RELEASE="$CLANG_PLUGIN_STATISTICS" \
        -DCMAKE_CXX_FLAGS_RELEASE="$CLANG_PLUGIN_STATISTICS" \
        -DENABLE_DOCS=0 \
        -DENABLE_TESTS=0 \
        -DCONFIG_AV1_DECODER=0 \
        -DCMAKE_BUILD_TYPE=Release .. && \
        ninja -j${NUM_CPU_CORES} |& tee run-build.log
else
    cmake \
        -DENABLE_DOCS=0 \
        -DENABLE_TESTS=0 \
        -DCONFIG_AV1_DECODER=0 \
        -DCMAKE_BUILD_TYPE=Release .. && \
        make "-j${NUM_CPU_CORES}"
fi
echo $? > ~/install-exit-status
cd ~
if [[ -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    7z x Bosphorus_1920x1080_120fps_420_8bit_YUV_Y4M.7z -aoa
    7z x Bosphorus_3840x2160_120fps_420_8bit_YUV_Y4M.7z -aoa
fi

TASKSET="nice -n -20 taskset -c 1"

echo "#!/bin/sh
# Current AOMedia Git has MAX_NUM_THREADS value of 64, don't go over 64 threads or error
if [ \"\$NUM_CPU_CORES\" -gt 64 ]; then
	NUM_CPU_CORES=64
fi
$TASKSET ./aom/build/aomenc --threads=1 -o test.av1 \$@ > 1.log 2>&1
echo \$? > ~/test-exit-status
sed \$'s/[^[:print:]\t]/\\n/g' 1.log > \$LOG_FILE
rm -f test.av1" > aom-av1
chmod +x aom-av1
