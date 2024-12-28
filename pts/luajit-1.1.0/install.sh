#!/bin/sh

tar -xf LuaJIT-20190110.tar.xz
cd LuaJIT-Git
sed -i 's/^CC=/#CC=/g' src/Makefile
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" make "-j${NUM_CPU_CORES}"
else
    make "-j${NUM_CPU_CORES}"
fi
echo $? > ~/install-exit-status

TASKSET="nice -n -20 taskset -c 1"

cd ~
echo "#!/bin/sh
$TASKSET ./LuaJIT-Git/src/luajit scimark.lua -large > \$LOG_FILE 2>&1" > luajit
chmod +x luajit
