#!/bin/sh

TASKSET="nice -n -20 taskset -c 1"

tar -xf sqlite-3460-for-speedtest.tar.gz
cd sqlite-version-3.46.0
./configure
if [ $OS_TYPE = "BSD" ]
then
	gmake speedtest1
else
	make speedtest1
fi
echo $? > ~/install-exit-status

cd ~

echo "#!/bin/sh
cd sqlite-version-3.46.0
$TASKSET ./speedtest1 \$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > sqlite-speedtest
chmod +x sqlite-speedtest
