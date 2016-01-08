#!/bin/bash
# Author : Kuriens Maliekal
# Decscription : Script to send daily bacula job status to ISE.

EMAIL_ID="me@example.com"

CONTENT="$(mysql bacula -t -e "select JobId, Name, JobFiles, JobBytes, JobStatus from Job where Type='B' and RealEndTime like '`date +%Y-%m-%d`%';")";
echo "$CONTENT


Job Status Codes

A        Canceled by user
B        Blocked
C        Created, but not running
c        Waiting for client resource
D        Verify differences
d        Waiting for maximum jobs
E        Terminated in error
e        Non-fatal error
f        fatal error
F        Waiting on File Daemon
j        Waiting for job resource
M        Waiting for mount
m        Waiting for new media
p        Waiting for higher priority jobs to finish
R        Running
S        Scan
s        Waiting for storage resource
T        Terminated normally
t        Waiting for start time" | mail -s "Bacula Backup Report :: $(date +%Y-%m-%d)" $EMAIL_ID