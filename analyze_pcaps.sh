#!/usr/bin/env bash

today=$(date +%m%d%Y)
results_date=$(date +%m%d%Y_%H%M%S)

results_folder=/opt/drop_files/results/$today/$results_date

mkdir -p $results_folder
cd $results_folder

dsniff -p "$2"/"$1" -w $results_folder/dsniff_results.log > /dev/null 2>&1 &
p0f -r "$2"/"$1" -o $results_folder/"$results_date"_p0f.log > /dev/null 2>&1 &
zeek -C -r "$2"/"$1" > /dev/null 2>&1 &

brutesharkcli -i "$2"/"$1" -m Credentials,NetworkMap,DNS -o $results_folder > /dev/null 2>&1 &

current=$(date)
echo "[$current] Processing file $1" >> /opt/drop_files/scripts/logs/processed_pcaps.log

exit
