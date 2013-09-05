#!/usr/bin/expect -f
set timeout 120
spawn su - root
expect ":"
send  "******\r"
expect "#"
set pkg [lindex $argv 0]
set ip [lindex $argv 1]
set tpath [lindex $argv 2]
spawn  scp $pkg root@$ip:$tpath
expect ":"
send  "******\n"
send "exit\n"
expect eof
exit
