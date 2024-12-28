#!/bin/sh
tar -xvf zstd-1.5.4.tar.gz
cd zstd-1.5.4
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" make "-j${NUM_CPU_CORES}"
else
    make "-j${NUM_CPU_CORES}"
fi
echo $? > ~/install-exit-status
cd ~
TASKSET="nice -n -20 taskset -c 1"
cat > compress-zstd <<EOT
#!/bin/sh
$TASKSET ./zstd-1.5.4/zstd -T1 \$@ silesia.tar > \$LOG_FILE 2>&1
sed -i -e "s/\r/\n/g" \$LOG_FILE 
EOT
chmod +x compress-zstd
