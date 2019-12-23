#/bin/bash
make tty
cat ${1} > /dev/ttyUSB1
