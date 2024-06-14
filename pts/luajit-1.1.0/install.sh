#!/bin/sh

tar -xf LuaJIT-20190110.tar.xz
cd LuaJIT-Git
sed -i 's/^CC=/#CC=/g' src/Makefile
make -j $NUM_CPU_CORES
echo $? > ~/install-exit-status

TASKSET="nice -n -20 taskset -c 1"

cd ~
echo "#!/bin/sh
$TASKSET ./LuaJIT-Git/src/luajit scimark.lua -large > \$LOG_FILE 2>&1" > luajit
chmod +x luajit
