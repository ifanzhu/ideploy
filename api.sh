#!/usr/bin/expect -f
set timeout 120
spawn su - root
expect ":"
send  "******\r"
expect "#"
set cmd [lindex $argv 0]
send  "$cmd\r"
send "echo $?\r"
expect eof
exit
