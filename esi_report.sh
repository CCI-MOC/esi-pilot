#!/bin/bash

# run ./esi_report.sh nodes-daily to get daily nodes report
# run ./esi_report.sh leases-monthly to get last month's leases report
# run ./esi_report.sh leases-weekly to get last week's leases report
# run ./esi_report.sh leases-current to get current and future leases report

report_dir=/tmp/esi_report

source /home/stack/overcloud-deploy/overcloud/overcloudrc

if [[ $1 == "leases-weekly" ]]; then
    week=$(date -d "last Sunday -6 days" +"%Y-%m-%d")
    output_file=${report_dir}/leases/weekly/${week}_weekly.csv
    output_file_log=${report_dir}/leases/weekly/${week}_weekly.log
    first_day=$(date -d "last Sunday -6 days" +"%Y-%m-%dT%H:%M:%S")
    last_day=$(date -d "last Sunday 23:59:59" +"%Y-%m-%dT%H:%M:%S")
    echo "===== Start generating weekly report for week ${week} =====" >> $output_file_log
    echo "===== Command used: openstack esi lease list -f csv --time-range ${first_day} ${last_day} =====" >> $output_file_log
    openstack esi lease list -f csv --time-range $first_day $last_day >> $output_file

elif [[ $1 == "leases-monthly" ]]; then
    month=$(date -d "`date +%Y%m01` -1 month" +"%Y-%m")
    output_file=${report_dir}/leases/monthly/${month}_monthly.csv
    output_file_log=${report_dir}/leases/monthly/${month}_monthly.log
    first_day=$(date -d "`date +%Y%m01` -1 month" +"%Y-%m-%dT%H:%M:%S")
    last_day=$(date -d "`date +%Y%m01` -1 second" +"%Y-%m-%dT%H:%M:%S")
    echo "===== Start generating monthly report for month $month =====" >> $output_file_log
    echo "===== Command used: openstack esi lease list -f csv --time-range ${first_day} ${last_day} =====" >> $output_file_log
    openstack esi lease list -f csv --time-range $first_day $last_day >> $output_file

elif [[ $1 == "nodes-daily" ]]; then
    date=$(date +"%Y-%m-%d")
    output_file=${report_dir}/nodes/daily/${date}_daily.csv
    output_file_log=${report_dir}/nodes/daily/${date}_daily.log
    echo "===== Start generating report at $(date +"%Y-%m-%dT%H:%M:%S") =====" >> $output_file_log
    echo "===== Command used: openstack esi node list -f csv ======" >> $output_file_log
    openstack esi node list -f csv >> $output_file

elif [[ $1 == "leases-current" ]]; then
    current=$(date +"%Y-%m-%d")
    output_file=${report_dir}/leases/current/${current}_current.csv
    output_file_log=${report_dir}/leases/current/${current}_current.log
    echo "===== Start generating report at $(date +"%Y-%m-%dT%H:%M:%S") =====" >> $output_file_log
    echo "===== Command used (Active leases): openstack esi lease list --status active =====" >> $output_file_log
    echo "***Current active leases***" >> $output_file_log
    openstack esi lease list --status active >> $output_file
    echo "===== Command used (Future leases): openstack esi lease list -f csv --time-range ${current} 9999-12-31T23:59:59.999999 --status created =====" >> $output_file_log
    echo "***Future leases***" >>  $output_file_log
    openstack esi lease list -f csv --time-range $current "9999-12-31T23:59:59.999999" --status created >> $output_file

else
    echo "argument error"
fi
