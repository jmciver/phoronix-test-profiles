#!/bin/sh

tar -xf Botan-2.17.3.tar.xz

cd Botan-2.17.3
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    sed -E \
        -e 's/^macro_name CLANG/macro_name ALIVECC/' \
        -e 's/^binary_name clang/binary_name alivecc/' \
        src/build-data/cc/clang.txt > src/build-data/cc/alivecc.txt
    python3 ./configure.py --cc=alivecc --cc-bin=/llvm/alive2/build/release/alivecc
    "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" make "-j${NUM_CPU_CORES}"
else
    python3 ./configure.py
    make "-j${NUM_CPU_CORES}"
fi
echo $? > ~/install-exit-status

cd ~
echo "#!/bin/sh
cd Botan-2.17.3
LD_LIBRARY_PATH=.:\$LD_LIBRARY_PATH ./botan speed \$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > botan
chmod +x botan
