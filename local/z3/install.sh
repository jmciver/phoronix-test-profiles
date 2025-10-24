#!/bin/sh

Z3_VERSION='4.14.0.0'
Z3_SRC_DIR=z3_solver-${Z3_VERSION}/core
TASKSET="nice -n -20 taskset -c 1"

tar -xvf z3_solver-${Z3_VERSION}.tar.gz

pushd ${Z3_SRC_DIR} &> /dev/null
mkdir build
pushd build &> /dev/null
if [[ ! -z "$CLANG_PLUGIN_STATISTICS" ]]; then
    cmake \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DZ3_ENABLE_EXAMPLE_TARGETS=OFF \
        -DCMAKE_C_FLAGS_RELEASE="$CLANG_PLUGIN_STATISTICS" \
        -DCMAKE_CXX_FLAGS_RELEASE="$CLANG_PLUGIN_STATISTICS" .. && \
        ninja -j$NUM_CPU_CORES z3 |& tee run-build.log
else
    cmake \
        -GNinja -DCMAKE_CXX_COMPILER=$CXX \
        -DCMAKE_BUILD_TYPE=Release \
        -DZ3_ENABLE_EXAMPLE_TARGETS=OFF .. && \
        ninja -j$NUM_CPU_CORES z3
fi
popd &> /dev/null
popd &> /dev/null

echo "#!/bin/sh
$TASKSET ./${Z3_SRC_DIR}/build/z3 \$1 > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > ~/z3
chmod +x ~/z3
