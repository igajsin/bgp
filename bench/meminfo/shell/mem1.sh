#!/bin/bash

for i in $(seq $1); do
RAM_USAGE=$(free -m | grep Mem | awk '{ printf("RAM %.1f\\%\n", ($3+$6)/$2 * 100.0) }'; free -m | grep Mem | awk '{ printf("%.0f\\mb\n", $3+$6) }');
done;
