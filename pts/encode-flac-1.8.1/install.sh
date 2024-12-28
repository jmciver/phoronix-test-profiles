#!/bin/sh
mkdir $HOME/flac_
tar -xJf flac-1.4.2.tar.xz

cd flac-1.4.2
./configure --prefix=$HOME/flac_
MAKE_PROGRAM=make
if [ $OS_TYPE = "BSD" ]; then
    MAKE_PROGRAM=gmake
fi
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" "$MAKE_PROGRAM" "-j${NUM_CPU_CORES}"
else
    "$MAKE_PROGRAM" "-j${NUM_CPU_CORES}"
fi
echo $? > ~/install-exit-status

make install

TASKSET="nice -n -20 taskset -c 1"

cd ~
if [[ -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    rm -rf flac-1.4.2
    rm -rf flac_/share/
fi
echo "#!/bin/sh
$TASKSET ./flac_/bin/flac --best \$TEST_EXTENDS/pts-trondheim.wav -f -o output 2>&1
echo \$? > ~/test-exit-status" > encode-flac
chmod +x encode-flac
