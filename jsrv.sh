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

startJavaService(){
    echo "start java service begin...";
   JAVA_SERVICE_ROOT=$(getArgValue "$1" "-p");
   JAVA_SERVICE_MODULE=$(getArgValue "$1" "-m");
   MIN_MEM=$(getArgValue "$1" "-Xms");
   MAX_MEM=$(getArgValue "$1" "-Xmx");
    classpath=$CLASSPATH
    for jar in $(ls $JAVA_SERVICE_ROOT/lib/*.jar)
    do
        classpath=$classpath:$jar;
    done
    $JAVA_HOME/bin/java -Xms$MIN_MEM   -Xmx$MAX_MEM   -cp $classpath -jar $JAVA_SERVICE_ROOT/$JAVA_SERVICE_MODULE.jar
    echo "start java service successfully";
}
stopJavaService(){
    echo "stop java service begin...";
   JAVA_SERVICE_MODULE=$(getArgValue "$1" "-m");
    pid=$(ps -ef | grep -y $JAVA_SERVICE_MODULE.jar | grep java | awk '{print $2}')
    kill -9 $pid
   echo "stop java service successfully";
}
#exec command 
COMMAND=$1;
#command parser
case $COMMAND in
-start)
startJavaService "$*";
;;
-stop)
stopJavaService "$*";
;;
*)
echo  -e "Usage:\n sh jsrv.sh -start -p <java service root dir> -m <java service module> -Xms <min memory> -Xmx <max memory> \n  sh jsrv.sh -stop -m <java service module> "
exit 1
esac

