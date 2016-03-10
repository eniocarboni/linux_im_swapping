#!/bin/bash

# Author: Enio Carboni
# Check (the kernel behavior ) if the vm is starting to swap or not based on /proc/sys/vm/swappiness
#  see: http://lwn.net/Articles/83588/
#  see: https://en.wikipedia.org/wiki/Swappiness
#  see: http://askubuntu.com/questions/103915/how-do-i-configure-swappiness
# exit code is valid for nrpe and than nagios

DEBUG=0
NRPE_STATE_OK=0
NRPE_STATE_WARNING=1
NRPE_STATE_CRITICAL=2
NRPE_STATE_UNKNOWN=3
NRPE_STATE_DEPENDENT=4

# set a threshold (%) for a warnings message
threshold=5

swappiness=$(cat /proc/sys/vm/swappiness)
swappiness_threshold_low=$(( $swappiness - $threshold ))
swappiness_threshold_high=$(( $swappiness + $threshold ))
used_ram=$(awk '/MemTotal/ {mt=$2}; /MemFree/ {mf=$2}; /^Buffers:/ {b=$2}; /SReclaimable/ {sr=$2}; /^Cached:/ {c=$2}; /^Shmem:/ {sh=$2} END {print mt-mf-b-sr-c+sh}' /proc/meminfo)
tot_ram=$(awk '/MemTotal/ {mt=$2}; /^Shmem:/ {sh=$2} END {print mt+sh}' /proc/meminfo)
used_ram_perc=$(( $used_ram * 100 / $tot_ram ))
if [ "$DEBUG" = "1" ]; then
	echo "swappiness=$swappiness"
	echo "used_ram=$used_ram"
	echo "tot_ram=$tot_ram"
	echo "used_ram_perc=$used_ram_perc"
fi
if [ "$used_ram_perc" -gt "$((100 - $swappiness_threshold_high))" ]; then
	echo "I'm swapping (swappiness=$swappiness, used_ram_perc=$used_ram_perc)"
	exit $NRPE_STATE_CRITICAL
elif  [ "$used_ram_perc" -gt "$((100 - $swappiness_threshold_low))" ]; then
	echo "I'm starting to swap (swappiness=$swappiness, used_ram_perc=$used_ram_perc)"
	exit $NRPE_STATE_WARNING
else
	echo "Ok I'm not swapping (swappiness=$swappiness, used_ram_perc=$used_ram_perc)"
	exit $NRPE_STATE_OK
fi

# COPYRIGHT
# linux_im_swapping is Copyright (c) 2014 Enio Carboni - Italy
# linux_im_swapping is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# linux_im_swapping is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with offline. If not, see <http://www.gnu.org/licenses/>.

# SUPPORT / WARRANTY
# The linux_im_swapping is free Open Source software. IT COMES WITHOUT WARRANTY OF ANY KIND.

