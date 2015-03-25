#!/bin/bash

# Autore: Enio Carboni
# Controllo se la vm sta swappando in base a /proc/sys/vm/swappiness
#  (vedere http://lwn.net/Articles/83588/ )
# ed ai valori di /proc/meminfo
# l'exit code e' valido per nrpe e quindi nagios

NRPE_STATE_OK=0
NRPE_STATE_WARNING=1
NRPE_STATE_CRITICAL=2
NRPE_STATE_UNKNOWN=3
NRPE_STATE_DEPENDENT=4

# metto una soglia in percentuale per il warnings
soglia=5

swappiness=$(cat /proc/sys/vm/swappiness)
swappiness_soglia_bassa=$(( $swappiness - $soglia ))
swappiness_soglia_alta=$(( $swappiness + $soglia ))
used_ram=$(awk '/MemTotal/ {mt=$2}; /MemFree/ {mf=$2}; /^Buffers:/ {b=$2}; /SReclaimable/ {sr=$2}; /^Cached:/ {c=$2}; /^Shmem:/ {sh=$2} END {print mt-mf-b-sr-c+sh}' /proc/meminfo)
tot_ram=$(awk '/MemTotal/ {mt=$2}; /^Shmem:/ {sh=$2} END {print mt+sh}' /proc/meminfo)
used_ram_perc=$(( $used_ram * 100 / $tot_ram ))
# echo "swappiness=$swappiness"
# echo "used_ram=$used_ram"
# echo "tot_ram=$tot_ram"
# echo "used_ram_perc=$used_ram_perc"
if [ "$used_ram_perc" -gt "$swappiness_soglia_alta" ]; then
	echo "Sto swappando"
	exit $NRPE_STATE_CRITICAL
elif  [ "$used_ram_perc" -gt "$swappiness_soglia_bassa" ]; then
	echo "Sto iniando a swappare"
	exit $NRPE_STATE_WARNING
else
	echo "Ok non sto swappando"
	exit $NRPE_STATE_OK
fi

# COPYRIGHT
# linux_im_swapping is Copyright (c) 2014 Enio Carboni - Italy
# netbkpstatus is free software: you can redistribute it and/or modify
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

