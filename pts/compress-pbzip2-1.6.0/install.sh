#!/bin/sh

tar -zxvf bzip2-1.0.8.tar.gz
tar -zxvf pbzip2-1.1.13.tar.gz

grep -rl "CC=gcc" . | xargs sed -i '/CC=gcc/d'

cd bzip2-1.0.8/
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" make "-j${NUM_CPU_CORES}"
else
    make "-j${NUM_CPU_CORES}"
fi
cp -f libbz2.a ../pbzip2-1.1.13
cp -f bzlib.h ../pbzip2-1.1.13
cd ..
cd pbzip2-1.1.13/
grep -rl PRIuMAX . | xargs sed -i 's/PRIuMAX/ PRIuMAX /g'
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" make "-j${NUM_CPU_CORES}" pbzip2-static
else
    make "-j${NUM_CPU_CORES}" pbzip2-static
fi
echo $? > ~/install-exit-status

cd ~
TASKSET="nice -n -20 taskset -c 1"
cat > compress-pbzip2 <<EOT
#!/bin/sh
cd pbzip2-1.1.13/
$TASKSET ./pbzip2 -c -p1 -r -5 ../FreeBSD-13.0-RELEASE-amd64-memstick.img > /dev/null 2>&1
EOT
chmod +x compress-pbzip2
