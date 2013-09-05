#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin;
export PATH;
# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to run";
    exit 1;
fi
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
#nginx version
NGINX_VERSION=nginx-1.2.7;
#exec command 
COMMAND=$1;
#install root path
LNC_ROOT_PATH=$(getArgValue "$*" "-p");
#domain path
DOMAIN_ROOT=$LNC_ROOT_PATH/domains;
#master domain path
MASTER_DOMAIN_ROOT=$DOMAIN_ROOT/master;
#master nginx domain root path
MASTER_NGINX_DOMAIN_ROOT=$MASTER_DOMAIN_ROOT/$NGINX_VERSION;
#master nginx bin path
MASTER_NGINX=$MASTER_NGINX_DOMAIN_ROOT/sbin/nginx;
startMasterDomain(){
      echo "start master domain begin..."
	$MASTER_NGINX_DOMAIN_ROOT/sbin/nginx
	echo "start master domain successfully"
}
stopMasterDomain(){
     echo "stop master domain..."
	ps -e | grep $(basename $MASTER_NGINX) | {
      while read pid tty time cmd;
      do
        echo "killing $pid ==> $cmd"
        kill -9 $pid
      done
    }
  echo "stop master domain successfully"
}
#command parser
case $COMMAND in
-start)
startMasterDomain;
;;
-stop)
stopMasterDomain;
;;
*)
echo -e "Usage:\n sh mdm.sh -start -p <master domain root path> \n sh mdm.sh -stop -p <master domain root path>"
exit 1
esac

