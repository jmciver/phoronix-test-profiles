#!/bin/sh

unzip -o scimark2_1c.zip -d scimark2_files
cd scimark2_files/
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" $CC $CFLAGS -o scimark2 *.c -lm
else
    $CC $CFLAGS -o scimark2 *.c -lm
fi
echo $? > ~/install-exit-status
cd ..

TASKSET="nice -n -20 taskset -c 1"
echo "#!/bin/sh
cd scimark2_files/
$TASKSET ./scimark2 -large > \$LOG_FILE 2>&1" > scimark2
chmod +x scimark2
