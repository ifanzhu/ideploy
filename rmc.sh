#!/usr/bin/expect -f
set timeout 120
set ip [lindex $argv 0]
set cmd1 [lindex $argv 1]
set cmd2 [lindex $argv 2]
spawn ssh -t root@$ip
expect {
  "yes/no?" {
     send  "yes\n"
     expect "password:"
      send  "******\n"  
   }
"password:" {
   send  "******\n"  
}
}
expect "#"
send  "$cmd1\r"
send  "$cmd2\r"
send "exit\r"
expect eof
exit



