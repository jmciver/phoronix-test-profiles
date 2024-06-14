#!/bin/sh
tar -xf openssl-3.1.0.tar.gz
cd openssl-3.1.0
./config no-zlib
make -j $NUM_CPU_CORES
echo $? > ~/install-exit-status
cd ~
TASKSET="nice -n -20 taskset -c 1"
echo "#!/bin/sh
cd openssl-3.1.0
LD_LIBRARY_PATH=.:\$LD_LIBRARY_PATH $TASKSET ./apps/openssl speed -multi 1 -seconds 30 \$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > openssl
chmod +x openssl
