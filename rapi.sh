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
ip=$(getArgValue "$*" "-ip");
cmd=$4;
expect /opt/lnc/rcmd.sh "$ip" "$cmd"
