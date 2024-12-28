#!/bin/sh
tar -zxvf gutenberg-science.tar.gz
tar -xf espeak-ng-1.51.tar.gz
cd espeak-ng-1.51
./autogen.sh
./configure --prefix=$HOME/espeak_
# build seems to have problems with multiple cores.
if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
  "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" make
else
    make
fi
echo $? > ~/install-exit-status
make install
cd ~
rm -rf espeak-ng-1.51
TASKSET="nice -n -20 taskset -c 1"
echo "#!/bin/sh
cd espeak_/bin/
LD_LIBRARY_PATH=\$HOME/espeak_/lib/:\$LD_LIBRARY_PATH $TASKSET ./espeak-ng -f ~/gutenberg-science.txt -w espeak-output 2>&1
echo \$? > ~/test-exit-status" > espeak
chmod +x espeak
