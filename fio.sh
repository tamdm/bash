#!/usr/bin/env bash

	if [ -e '/usr/bin/fio' ]; then
		#echo "Fio Test"
		tmp=$(mktemp)
		fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=fio_test --filename=fio_test --bs=4k --numjobs=1 --iodepth=64 --size=256M --readwrite=randrw --rwmixread=75 --runtime=30 --time_based --output="$tmp"  > /dev/null 2>&1

		if [ $(fio -v | cut -d '.' -f 1) == "fio-2" ]; then
			iops_read=`grep "iops=" "$tmp" | grep read | awk -F[=,]+ '{print $6}'`
			iops_write=`grep "iops=" "$tmp" | grep write | awk -F[=,]+ '{print $6}'`
			bw_read=`grep "bw=" "$tmp" | grep read | awk -F[=,B]+ '{if(match($4, /[0-9]+K$/)) {printf("%.1f", int($4)/1024);} else if(match($4, /[0-9]+M$/)) {printf("%.1f", substr($4, 0, length($4)-1))} else {printf("%.1f", int($4)/1024/1024);}}'`"MB/s"
			bw_write=`grep "bw=" "$tmp" | grep write | awk -F[=,B]+ '{if(match($4, /[0-9]+K$/)) {printf("%.1f", int($4)/1024);} else if(match($4, /[0-9]+M$/)) {printf("%.1f", substr($4, 0, length($4)-1))} else {printf("%.1f", int($4)/1024/1024);}}'`"MB/s"

		elif [ $(fio -v | cut -d '.' -f 1) == "fio-3" ]; then
			iops_read=`grep "IOPS=" "$tmp" | grep read | awk -F[=,]+ '{print $2}'`
			iops_write=`grep "IOPS=" "$tmp" | grep write | awk -F[=,]+ '{print $2}'`
			bw_read=`grep "bw=" "$tmp" | grep READ | awk -F"[()]" '{print $2}'`
			bw_write=`grep "bw=" "$tmp" | grep WRITE | awk -F"[()]" '{print $2}'`
		fi

		echo "Read performance     : $bw_read"
		echo "Read IOPS            : $iops_read"
		echo "Write performance    : $bw_write"
		echo "Write IOPS           : $iops_write"

		rm -f $tmp fio_test
	else
		echo "Fio is missing!!! Trying to install fio package."
		apt install fio -y 2>&1
	fi

