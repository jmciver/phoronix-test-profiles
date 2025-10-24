#!/bin/sh
mkdir $HOME/flac_
tar -xJf flac-1.4.2.tar.xz

cd flac-1.4.2
MAKE_PROGRAM=make
if [ $OS_TYPE = "BSD" ]; then
    MAKE_PROGRAM=gmake
fi
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    ./configure --prefix=$HOME/flac_ && \
        "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" "$MAKE_PROGRAM" "-j${NUM_CPU_CORES}"
elif [[ ! -z "$CLANG_PLUGIN_STATISTICS" ]]; then
    mkdir build && \
        cd build && \
        cmake -GNinja \
              -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_C_FLAGS_RELEASE="$CLANG_PLUGIN_STATISTICS" \
              -DCMAKE_CXX_FLAGS_RELEASE="$CLANG_PLUGIN_STATISTICS" \
              -DWITH_OGG=OFF \
              .. && \
        ninja -j${NUM_CPU_CORES} |& tee run-build.log
else
    ./configure --prefix=$HOME/flac_ && \
        "$MAKE_PROGRAM" "-j${NUM_CPU_CORES}" && \
        make install
fi
echo $? > ~/install-exit-status

TASKSET="nice -n -20 taskset -c 1"

cd ~
if [[ -z "$ALIVECC_PARALLEL_FIFO" && -z "$CLANG_PLUGIN_STATISTICS" ]]; then
    rm -rf flac-1.4.2
    rm -rf flac_/share/
fi
echo "#!/bin/sh
$TASKSET ./flac_/bin/flac --best \$TEST_EXTENDS/pts-trondheim.wav -f -o output 2>&1
echo \$? > ~/test-exit-status" > encode-flac
chmod +x encode-flac
