#########################################################################
# File Name: sshlogin.sh
# Author: Jensen
# mail: linuxidc@linuxidc.com
# Created Time: Mon 05 Dec 2016 06:02:20 PM CST
#########################################################################
#!/usr/bin/expect -f
set ip [lindex $argv 0]
set user [lindex $argv 1]
set password [lindex $argv 2]
set timeout 10
spawn ssh -l $user $ip
expect {
"User:" { send "$user\r"; exp_continue }
"Password:" { send "$password\r" }
}
#interact
expect {
"Controller" { send "transfer upload start\r"; exp_continue }
"*y/N" { send "y\r"; exp_continue }
"Controller" { send "logout\r" }
}

expect eof
exit
  
