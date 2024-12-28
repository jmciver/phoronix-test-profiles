#!/bin/sh

tar -xf ngspice-34.tar.gz
tar -xf iscas85Circuits-1.tar.xz

cd ngspice-34
./configure
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" make "-j${NUM_CPU_CORES}"
else
    make "-j${NUM_CPU_CORES}"
fi
echo $? > ~/install-exit-status
cd ~
TASKSET="nice -n -20 taskset -c 1"

echo "#!/bin/sh

cd ngspice-34
$TASKSET ./src/ngspice \$@ > \$LOG_FILE" > ngspice
chmod +x ngspice
