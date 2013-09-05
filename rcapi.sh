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
fpkg=$(getArgValue "$*" "-fpkg");
ip=$(getArgValue "$*" "-ip");
cmd=$8;
apath="/opt/lnc/upload/$appname"
expect /opt/lnc/rdr.sh "$appname" "$ip"
expect /opt/lnc/rcp.sh "$apath/$fpkg" "$ip" "$apath"
#echo $cmd
expect /opt/lnc/rcmd.sh "$ip" "$cmd"
