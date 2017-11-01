#!/usr/bin/python3

import re
import sys

def print_result(meminfo):
    memTotal = int(meminfo['MemTotal'])
    memFree = int(meminfo['MemFree'])
    buffers = int(meminfo['Buffers'])
    freeRam = memTotal - memFree + buffers
    percentFree = 100 * freeRam / memTotal
    print("RAM {}% {}mb".format(percentFree, freeRam/1024))

def ready(meminfo):
    return meminfo['Ready'] == 3

def analize(line, meminfo, scan):
    match = scan.match(line)
    name, value = match.group(1), match.group(2)
    if name in meminfo.keys():
        meminfo[name] = value
        meminfo['Ready'] += 1
    return meminfo
    

def read_file(filename, meminfo, scan):
    with open(filename) as fl:
        for line in fl:
            meminfo = analize(line, meminfo, scan)
            if ready(meminfo):
                break
    return meminfo

def test_memory(filename, scan):
    meminfo = {'MemTotal': 0, 'MemFree': 0, 'Buffers': 0, 'Ready': 0}
    print_result(read_file(filename, meminfo, scan))

def main(n):
    scan = re.compile("(\w+)\:\s+(\d+)")
    for i in range(0, n):
        test_memory("/proc/meminfo", scan)
    return 0

if __name__ == "__main__":
    main(int(sys.argv[1]))
