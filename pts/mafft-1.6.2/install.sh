#!/bin/sh

rm -rf $HOME/mafft_
mkdir $HOME/mafft_
tar -xvf mafft-7.471-without-extensions-src.tgz
cd mafft-7.471-without-extensions/core/

MAKE_PROGRAM=make
if [ $OS_TYPE = "BSD" ]; then
    MAKE_PROGRAM=gmake
fi
"$MAKE_PROGRAM" clean

sed -i -e "s|PREFIX = /usr/local|PREFIX = $HOME/mafft_|g" Makefile

if [[ ! -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    "$ALIVE2_JOB_SERVER_PATH" "-j${ALIVE2_JOB_SERVER_THREADS}" "$MAKE_PROGRAM" "-j${NUM_CPU_CORES}" "ENABLE_MULTITHREAD=-Denablemultithread"
else
    exit 1
    "$MAKE_PROGRAM" "-j${NUM_CPU_CORES}" "ENABLE_MULTITHREAD=-Denablemultithread"
fi
echo $? > ~/install-exit-status
"$MAKE_PROGRAM" install
cd ~/
cp -f mafft-7.471-without-extensions/scripts/mafft mafft_/
if [[ -z "$ALIVECC_PARALLEL_FIFO" ]]; then
    rm -rf mafft-7.471-without-extensions/
fi

cp mafft-ex1-lsu-rna.txt mafft_

if [ -x /usr/pkg/bin/bash ]
then
	# bsd fix
	sed -i -e "s|/bin/bash|/usr/pkg/bin/bash|g" mafft_/mafft
fi

TASKSET="nice -n -20 taskset -c 1"
cat>mafft<<EOT
#!/bin/sh
cd mafft_/
$TASKSET ./mafft --thread 1 --auto mafft-ex1-lsu-rna.txt > \$LOG_FILE
echo \$? > ~/test-exit-status
EOT
chmod +x mafft
