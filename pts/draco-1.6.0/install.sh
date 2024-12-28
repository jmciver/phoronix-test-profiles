#!/bin/sh
tar -xf draco-1.5.6.tar.gz
cd draco-1.5.6
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" make "-j${NUM_CPU_CORES}"
else
    make "-j${NUM_CPU_CORES}"
fi
echo $? > ~/install-exit-status
cd ~
unzip -o church-facade-ply.zip
mv Church\ façade.ply draco-1.5.6/build/church.ply
unzip -o lion-statue_ply.zip
mv Lion\ statue_ply/Lion\ statue.ply draco-1.5.6/build/lion.ply
TASKSET="nice -n -20 taskset -c 1"
cd ~
echo "#!/bin/sh
cd draco-1.5.6/build
$TASKSET ./draco_encoder \$@ -o out.drc -cl 10 -qp 16 > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > draco
chmod +x draco
