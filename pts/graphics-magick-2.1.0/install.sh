#!/bin/sh

tar -xjf GraphicsMagick-1.3.38.tar.bz2
unzip -o sample-photo-6000x4000-1.zip

mkdir $HOME/gm_
cd GraphicsMagick-1.3.38/
LDFLAGS="-L$HOME/gm_/lib" CPPFLAGS="-I$HOME/gm_/include" ./configure --without-perl --prefix=$HOME/gm_ --without-png --disable-openmp > /dev/null
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
"$MAKE_PROGRAM" install

cd ~
rm -rf GraphicsMagick-1.3.38/
rm -rf gm_/share/doc/GraphicsMagick/
rm -rf gm_/share/man/

./gm_/bin/gm convert sample-photo-6000x4000.JPG input.mpc

TASKSET="nice -n -20 taskset -c 1"

echo "#!/bin/sh
$TASKSET ./gm_/bin/gm benchmark -duration 60 convert input.mpc \$@ null: > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > graphics-magick
chmod +x graphics-magick
