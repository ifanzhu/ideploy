#!/bin/bash
getArgValue(){
arglist=($1);
length=${#arglist[@]};
for((i=0;i<$length;i++))
do
if [ "${arglist[$i]}" == "$2" ]; then
   echo "${arglist[$i+1]}";
   break;
 fi
done
}
appname=$(getArgValue "$*" "-aname");
ip=$(getArgValue "$*" "-ip");
mip=$(getArgValue "$*" "-mip");
cmd=$8;
oldIFS=$IFS
IFS=","
for iip in $ip;
do
expect /opt/lnc/rcmd.sh "$iip" "$cmd"
done
IFS=$oldIFS
expect /opt/lnc/rcmd.sh "$mip" "$cmd"
curl "http://${mip}/ac/afterUninstall.php?app_name=${appname}&status=$?"
