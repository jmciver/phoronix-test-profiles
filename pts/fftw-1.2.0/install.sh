#!/bin/sh

tar -xzvf fftw-3.3.6-pl2.tar.gz
rm -rf fftw-mr
rm -rf fftw-stock

mv fftw-3.3.6-pl2 fftw-stock
pushd fftw-stock > /dev/null 2>&1
cat <<EOF > configure.ac.patch
--- configure.ac	2017-01-27 21:08:13.000000000 +0000
+++ configure.ac.new	2024-06-25 18:28:06.901371406 +0000
@@ -457,6 +457,12 @@
             AX_CHECK_COMPILER_FLAGS(-mfma, [AVX2_CFLAGS="\$AVX2_CFLAGS -mfma"])
         fi
 
+        # AVX512
+        if test "\$have_avx512" = "yes" -a "x\$AVX512_CFLAGS" = x; then
+            AX_CHECK_COMPILER_FLAGS(-mavx512f, [AVX512_CFLAGS="-mavx512f"],
+                [AC_MSG_ERROR([Need a version of clang with -mavx512f])])
+        fi
+
         if test "\$have_vsx" = "yes" -a "x\$VSX_CFLAGS" = x; then
             # clang appears to need both -mvsx and -maltivec for VSX
             AX_CHECK_COMPILER_FLAGS(-maltivec, [VSX_CFLAGS="-maltivec"],

EOF
patch < configure.ac.patch
autoconf
popd > /dev/null 2>&1
cp -a fftw-stock fftw-mr

AVX_TUNING=""
if [ $OS_TYPE = "Linux" ]
then
    if grep avx512 /proc/cpuinfo > /dev/null
    then
	AVX_TUNING="$AVX_TUNING --enable-sse --enable-avx512"
    fi
    if grep avx2 /proc/cpuinfo > /dev/null
    then
	AVX_TUNING="$AVX_TUNING --enable-sse --enable-avx2"
    fi
    if `lscpu | grep -i arm > /dev/null`
    then
	AVX_TUNING="$AVX_TUNING --enable-neon"
    fi
fi

cd fftw-mr
./configure --enable-float --enable-threads $AVX_TUNING
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" make "-j${NUM_CPU_JOBS}"
else
    make "-j${NUM_CPU_JOBS}"
fi
echo $? > ~/install-exit-status

cd ~/fftw-stock
./configure --enable-float --enable-threads $AVX_TUNING
make -j $NUM_CPU_JOBS

TASKSET="nice -n -20 taskset -c 1"

cd ~/
echo "
#!/bin/sh

$TASKSET ./\$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status
" > fftw

chmod +x fftw

