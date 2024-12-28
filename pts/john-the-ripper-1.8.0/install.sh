#!/bin/sh
unzip -o john-c7cacb14f5ed20aca56a52f1ac0cd4d5035084b6.zip
cd john-c7cacb14f5ed20aca56a52f1ac0cd4d5035084b6/src/
CFLAGS="-O3 -march=native $CFLAGS" ./configure --disable-native-tests --disable-openmp --disable-opencl
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" CFLAGS="-O3 -march=native $CFLAGS" make "-j${NUM_CPU_CORES}"
else
    CFLAGS="-O3 -march=native $CFLAGS" make "-j${NUM_CPU_CORES}"
fi
echo $? > ~/install-exit-status
cd ~/
TASKSET="nice -n -20 taskset -c 1"
echo "#!/bin/sh
cd john-c7cacb14f5ed20aca56a52f1ac0cd4d5035084b6/run/
$TASKSET ./john \$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > john-the-ripper
chmod +x john-the-ripper
