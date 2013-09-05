set timeout 120
set appname [lindex $argv 0]
set ip [lindex $argv 1]
set tpath "/opt/lnc/upload/$appname"
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
send  "mkdir -p $tpath\n"
send "exit\n"
expect eof
exit


