#!/bin/bash

# 获取当前时间戳
CUR_TIME=`date +%s`
echo "当前时间戳：$CUR_TIME "

CUR_DAY=`date +%f -d @$CUR_TIME`
echo "当前的日期：$CUR_DAY"

YESTERDAY=`date +%f -d @$(( CUR_TIME - 86400))`
echo "昨天的日期： $YESTERDAY"

