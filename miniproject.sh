#!/bin/bash
# Mini Project

# delete existing output file
 empty() {
	rm APM1_metrics.csv 2> /dev/null
	rm APM2_metrics.csv 2> /dev/null
	rm APM3_metrics.csv 2> /dev/null
	rm APM4_metrics.csv 2> /dev/null
	rm APM5_metrics.csv 2> /dev/null
	rm APM6_metrics.csv 2> /dev/null
	rm system_metrics.csv 2> /dev/null
}

# wait every 5 seconds for 15 minutes
  waits() {
	sleep 5
  }

# process all applications and read PID
  spawn_ap() {
	./APM1 $1 & pid1=$!
	./APM2 $1 & pid2=$!
	./APM3 $1 & pid3=$!
	./APM4 $1 & pid4=$!
	./APM5 $1 & pid5=$!
	./APM6 $1 & pid6=$!
         ifstat -d 1
  }

# collect and output <proc_name>_metrics.csv file for each
# $3 collects cpu
# $4 collects memory
  process_level() {
       echo $SECONDS "," $(ps aux | egrep $pid1 | awk '{print $3}' | head -1) "," $(ps aux | egrep $pid1 | awk '{print $4}' | head -1) >> APM1_metrics.csv
       echo $SECONDS "," $(ps aux | egrep $pid2 | awk '{print $3}' | head -1) "," $(ps aux | egrep $pid2 | awk '{print $4}' | head -1) >> APM2_metrics.csv   
       echo $SECONDS "," $(ps aux | egrep $pid3 | awk '{print $3}' | head -1) "," $(ps aux | egrep $pid3 | awk '{print $4}' | head -1) >> APM3_metrics.csv
       echo $SECONDS "," $(ps aux | egrep $pid4 | awk '{print $3}' | head -1) "," $(ps aux | egrep $pid4 | awk '{print $4}' | head -1) >> APM4_metrics.csv
       echo $SECONDS "," $(ps aux | egrep $pid5 | awk '{print $3}' | head -1) "," $(ps aux | egrep $pid5 | awk '{print $4}' | head -1) >> APM5_metrics.csv
       echo $SECONDS "," $(ps aux | egrep $pid6 | awk '{print $3}' | head -1) "," $(ps aux | egrep $pid6 | awk '{print $4}' | head -1) >> APM6_metrics.csv  
  }

# collect and output system_metrics.csv file
# RX for RX data rate
# TX for TX data rate
# DWrite for Disk writes
# DAvaCap for Available disk capacity
  sys_level() {
	RX=$(ifstat ens33 | tail -2 | head -1 | awk '{print $9}' | sed 's/K/ /g')
	TX=$(ifstat ens33 | tail -2 | head -1 | awk '{print $7}' | sed 's/K/ /g')
	DWrite=$(iostat sda | head -7 | tail -1 | awk '{print $4}')
	DAvaCap=$(df -m /| tail -1 | awk '{print $4}')
	echo $SECONDS "," $RX "," $TX "," $DWrite "," $DAvaCap >> system_metrics.csv
  }

# kill all applications
  cleanup() { 
      killall -9 ifstat
	kill $pid1
	kill $pid2
	kill $pid3
	kill $pid4
	kill $pid5
	kill $pid6
  }

# kill all applications
  trap cleanup EXIT

# set ip address to argument 1
# set time as number of time collect data

  ip=$1
  time=0

  empty
  spawn_ap $ip

  while [ $time -lt 180 ]
  do
	sys_level
	process_level
	waits
	(( time ++ ))
	echo $SECONDS 
	
  done	


