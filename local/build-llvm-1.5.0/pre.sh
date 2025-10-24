#!/bin/sh
rm -rf build
rm -rf llvm-16.0.0.src
mkdir build
tar -xf llvm-16.0.0.src.tar.xz
tar -xf cmake-16.0.0.src.tar.xz
mv cmake-16.0.0.src cmake
cd build
if [ "$1" = "Ninja" ]; then
    if [[ ! -z "$CLANG_PLUGIN_STATISTICS" ]]; then
        cmake \
            -GNinja \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_C_FLAGS_RELEASE="$CLANG_PLUGIN_STATISTICS" \
            -DCMAKE_CXX_FLAGS_RELEASE="$CLANG_PLUGIN_STATISTICS" \
            -DLLVM_INCLUDE_BENCHMARKS=OFF \
            -DLLVM_BUILD_TESTS=OFF \
            -DLLVM_INCLUDE_TESTS=OFF \
            ../llvm-16.0.0.src && \
            cmake --build . -- -j$NUM_CPU_CORES |& tee run-build.log
    else
	cmake \
            -GNinja \
            -DCMAKE_BUILD_TYPE=Release \
            -DLLVM_INCLUDE_BENCHMARKS=OFF \
            -DLLVM_BUILD_TESTS=OFF \
            -DLLVM_INCLUDE_TESTS=OFF \
            ../llvm-16.0.0.src
    fi
else
    cmake \
        -G "Unix Makefiles"
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DLLVM_BUILD_TESTS=OFF \
        -DLLVM_INCLUDE_TESTS=OFF \
        ../llvm-16.0.0.src
fi
