#!/usr/bin/expect -f
set timeout 120
set ip [lindex $argv 0]
set cmd [lindex $argv 1]
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
send  "$cmd\n"
send "exit\n"
expect eof
exit

