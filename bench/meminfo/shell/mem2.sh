#!/bin/bash

for i in $(seq 1 $1); do
 while read name value kb; do
        case "$name" in
        MemTotal:) MemTotal=$((value/1024));;
        MemFree:)  MemFree=$((value/1024));;
        Buffers:)  Buffers=$((value/1024));;
        esac
 done < /proc/meminfo
 f=$((MemTotal-MemFree+Buffers))
 r=$((f*1000/MemTotal))
 echo "RAM ${r%?}.${r:2:1}% ${f}mb"
done
