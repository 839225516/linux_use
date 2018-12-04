#!/bin/bash

# /etc/init.d/etcdkeeper
#
# Startup script for etcdkeeper
#
# chkconfig: 2345 20 80
# description: Starts and stops etcdkeeper

. /etc/init.d/functions

prog="etcdkeeper"
prog_bin="/usr/local/etcdkeeper/$prog"
desc="etcdkeeper  service discovery daemon"

USER="root"
OPTS="-h '0.0.0.0' \
      -p 8866 "
OUT_FILE="/var/log/etcdkeeper.log"


if ! [ -f $prog_bin ]; then
  echo "$prog binary not found."
  exit 5
fi

#if [ -f /etc/sysconfig/$prog ]; then
#  . /etc/sysconfig/$prog
#else
#  echo "No sysconfig file found in /etc/sysconfig/$prog... exiting."
#  exit 5
#fi

start() {
  echo "Starting $desc ($prog): "
  su $USER -c "nohup $prog_bin $OPTS >> $OUT_FILE 2>&1 &"
  RETVAL=$?
  return $RETVAL
}

stop() {
  echo "Shutting down $desc ($prog): "
  pkill -f $prog_bin
}

restart() {
    stop
    start
}

status() {
  if [ -z $pid ]; then
     pid=$(pgrep -f $prog_bin)
  fi

  if [ -z $pid ]; then
    echo "$prog is NOT running."
    return 1
  else
    echo "$prog is running (pid is $pid)."
  fi

}

case "$1" in
  start)   start;;
  stop)    stop;;
  restart) restart;;
  status)  status;;
  *)       echo "Usage: $0 {start|stop|restart|status}"
           RETVAL=2;;
esac
exit $RETVAL