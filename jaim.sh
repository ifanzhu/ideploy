#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin;
export PATH;
# Check if user is root
#if [ $(id -u) != "0" ]; then
#    echo "Error: You must be root to run this script, please use root to run";
#    exit 1;
#fi
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
#tomcat version
TOMCAT_VERSION=apache-tomcat-6.0.36
#nginx version
NGINX_VERSION=nginx-1.2.7;
#exec command 
COMMAND=$1;
#install root path
LNC_ROOT_PATH=$(getArgValue "$*" "-path");
#slave tomcat domain instance name
JEE_APP_INSTANCE_NAME=$(getArgValue "$*" "-iname");
JEE_APP_INSTANCE_IP=$(getArgValue "$*" "-ip");
JEE_APP_NAME=$(getArgValue "$*" "-aname");
JEE_APP_PACKAGE_NAME=$(getArgValue "$*" "-pkg");
JEE_APP_DOMAIN=$(getArgValue "$*" "-domain");
#for create java app instance
TOMCAT_START_PORT=$(getArgValue "$*" "-startp");
TOMCAT_STOP_PORT=$(getArgValue "$*" "-stopp");
TOMCAT_REDIRECT_PORT=$(getArgValue "$*" "-redtp");
TOMCAT_AJP_PORT=$(getArgValue "$*" "-ajpp");
#install src package path
LNC_SRC_ROOT=$LNC_ROOT_PATH/src;
#install upload package path
LNC_UPLOAD_ROOT=$LNC_ROOT_PATH/upload/$JEE_APP_NAME;
#domain path
DOMAIN_ROOT=$LNC_ROOT_PATH/domains;
#master domain path
MASTER_DOMAIN_ROOT=$DOMAIN_ROOT/master;
#slave domain path
SLAVE_DOMAIN_ROOT=$DOMAIN_ROOT/slaves;
#slave tomcat domain root path
SLAVE_TOMCAT_DOMAIN_ROOT=$SLAVE_DOMAIN_ROOT/tomcat;
#slave tomcat domain instance name
SLAVE_TOMCAT_DOMAIN_INSTANCE="tomcat";
SLAVE_TOMCAT_DOMAIN_INSTANCE_PATH=$SLAVE_TOMCAT_DOMAIN_ROOT/$SLAVE_TOMCAT_DOMAIN_INSTANCE/$TOMCAT_VERSION;
JEE_APP_INSTANCE_ROOT=$SLAVE_TOMCAT_DOMAIN_ROOT/$JEE_APP_NAME;
#app dir
JEE_APP_PATH=$JEE_APP_INSTANCE_ROOT/$JEE_APP_INSTANCE_NAME/$TOMCAT_VERSION/webapps;
#master nginx domain root path
MASTER_NGINX_DOMAIN_ROOT=$MASTER_DOMAIN_ROOT/$NGINX_VERSION;
#master nginx bin path
MASTER_NGINX=$MASTER_NGINX_DOMAIN_ROOT/sbin/nginx;
#restart master nginx domain
restartMasterDomain(){
      pid=$(ps -ef | grep $MASTER_NGINX | grep 'nginx: master process' | awk '{print $2}')
      #echo "restart $pid"
      kill -HUP $pid;
   }
#create a new jee app instance
createJeeAppInstance(){
if [ -d $JEE_APP_INSTANCE_ROOT ]; then
for webtomcat in $JEE_APP_INSTANCE_ROOT/*
   do
      if [[ "$JEE_APP_INSTANCE_ROOT/$JEE_APP_INSTANCE_NAME" = "$webtomcat" ]];
        then
            #echo "Error: the instance name $JEE_APP_INSTANCE_NAME is also exist.please enter another instance name."
            exit 1
     fi
 done
else
   mkdir -p $JEE_APP_INSTANCE_ROOT
fi
#echo "create jee  app instance begin...";
JEE_APP_INSTANCE_PATH=$JEE_APP_INSTANCE_ROOT/$JEE_APP_INSTANCE_NAME/$TOMCAT_VERSION 
mkdir -p $JEE_APP_INSTANCE_PATH
cd $LNC_SRC_ROOT
tar -zxvf $TOMCAT_VERSION.tar.gz
cd  $TOMCAT_VERSION
cp -R  .  $JEE_APP_INSTANCE_PATH
sed  -i "s/8080/$TOMCAT_START_PORT/g"  $JEE_APP_INSTANCE_PATH/conf/server.xml
sed  -i "s/8005/$TOMCAT_STOP_PORT/g"  $JEE_APP_INSTANCE_PATH/conf/server.xml
sed  -i "s/8443/$TOMCAT_REDIRECT_PORT/g"  $JEE_APP_INSTANCE_PATH/conf/server.xml
sed  -i "s/8009/$TOMCAT_AJP_PORT/g"  $JEE_APP_INSTANCE_PATH/conf/server.xml
sed -i "/gzip  on;/a\\ upstream  $JEE_APP_DOMAIN{\n server  $JEE_APP_INSTANCE_IP:$TOMCAT_START_PORT;\n  }" $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
sed -i "/access_log  logs\/host.access.log  main;/a\\ location ^~ /$JEE_APP_DOMAIN/ {\n    proxy_pass   http://$JEE_APP_DOMAIN;\n  proxy_next_upstream  http_500 http_502 http_503 error timeout invalid_header;\n proxy_redirect off;\n  proxy_set_header Host \$host;\n proxy_set_header X-Real-IP \$remote_addr;\n proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\n client_body_buffer_size 128k;\n proxy_connect_timeout 90;\n proxy_send_timeout 90;\n proxy_read_timeout 90;\n proxy_buffer_size 4k;\n proxy_buffers 4 32k;\n proxy_busy_buffers_size 64k;\n proxy_temp_file_write_size 64k;   \n}" $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
#echo "create jee  app instance successfully";
}

#extend jee app instance
extJeeAppInstance(){
if [ -d $JEE_APP_INSTANCE_ROOT ]; then
for webtomcat in $JEE_APP_INSTANCE_ROOT/*
   do
      if [[ "$JEE_APP_INSTANCE_ROOT/$JEE_APP_INSTANCE_NAME" = "$webtomcat" ]];
        then
            #echo "Error: the instance name $JEE_APP_INSTANCE_NAME is also exist.please enter another instance name."
            exit 1
     fi
 done
else
   mkdir -p $JEE_APP_INSTANCE_ROOT
fi
#echo "create jee  app instance begin...";
JEE_APP_INSTANCE_PATH=$JEE_APP_INSTANCE_ROOT/$JEE_APP_INSTANCE_NAME/$TOMCAT_VERSION 
mkdir -p $JEE_APP_INSTANCE_PATH
cd $LNC_SRC_ROOT
tar -zxvf $TOMCAT_VERSION.tar.gz 
cd  $TOMCAT_VERSION
cp -R  .  $JEE_APP_INSTANCE_PATH
sed  -i "s/8080/$TOMCAT_START_PORT/g"  $JEE_APP_INSTANCE_PATH/conf/server.xml
sed  -i "s/8005/$TOMCAT_STOP_PORT/g"  $JEE_APP_INSTANCE_PATH/conf/server.xml
sed  -i "s/8443/$TOMCAT_REDIRECT_PORT/g"  $JEE_APP_INSTANCE_PATH/conf/server.xml
sed  -i "s/8009/$TOMCAT_AJP_PORT/g"  $JEE_APP_INSTANCE_PATH/conf/server.xml
sed -i "/upstream  $JEE_APP_DOMAIN{/a\\  server  $JEE_APP_INSTANCE_IP:$TOMCAT_START_PORT;\n" $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
#echo "create jee  app instance successfully";
}

#deploy jee app
deployJeeApp(){
   cd $LNC_UPLOAD_ROOT;
   if [ -s $JEE_APP_PACKAGE_NAME.war ]; then
        cp -R $JEE_APP_PACKAGE_NAME.war $JEE_APP_PATH/$JEE_APP_DOMAIN.war
   fi
}

deploy(){
createJeeAppInstance;
deployJeeApp;
restartMasterDomain;
}

extend(){
extJeeAppInstance;
deployJeeApp;
restartMasterDomain;
}

uninstall(){
#echo "uninstall jee app begin..."
rm -fr $LNC_UPLOAD_ROOT;
rm -fr $JEE_APP_INSTANCE_ROOT;
sed -i ":begin; /upstream  $JEE_APP_DOMAIN{/,/}/ { /}/! { $! { N; b begin }; }; s/upstream  $JEE_APP_DOMAIN{.*}//; };"  $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
sed -i ":begin; /location ^~ \/$JEE_APP_DOMAIN\/ {/,/}/ { /}/! { $! { N; b begin }; }; s/location ^~ \/$JEE_APP_DOMAIN\/ {.*}//; };"  $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
restartMasterDomain;
#echo "uninstall jee app successfully"
}

#delete all exist java app instance
deleteAllJavaAppInstance(){
echo "delete all java app instance begin..."
stopAllJavaAppInstance;
rm -f $SLAVE_TOMCAT_DOMAIN_ROOT;
sed -i ":begin; /upstream  javadomains{/,/}/ { /}/! { $! { N; b begin }; }; s/upstream  javadomains{.*}//; };"  $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
echo "delete all java app instance successfully"
}

#delete an exist jee app instance
deleteJeeAppInstance(){
#echo "delete jee app instance begin..."
rm -fr $JEE_APP_INSTANCE_ROOT/$JEE_APP_INSTANCE_NAME;
sed -i "s/server  $JEE_APP_INSTANCE_IP:$TOMCAT_START_PORT;//" $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
sed -i "s/server  $JEE_APP_INSTANCE_IP:$TOMCAT_START_PORT down;//" $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
restartMasterDomain;
#echo "delete jee app instance successfully"
}

#start all java app instance
startAllJavaAppInstance(){
echo "start all java app instance begin..."
  for webtomcat in $SLAVE_TOMCAT_DOMAIN_ROOT/*
        do
           $webtomcat/$TOMCAT_VERSION/bin/startup.sh
	done
echo "start all java app instance successfully"
}

startJeeAppInstance(){
#echo "start jee app instance begin..."
    for webtomcat in $JEE_APP_INSTANCE_ROOT/*
      do
         if [[ "$JEE_APP_INSTANCE_ROOT/$JEE_APP_INSTANCE_NAME" = "$webtomcat" ]];
           then
              $webtomcat/$TOMCAT_VERSION/bin/startup.sh;
               sed -i "s/server  $JEE_APP_INSTANCE_IP:$TOMCAT_START_PORT down;/server  $JEE_APP_INSTANCE_IP:$TOMCAT_START_PORT;/" $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
             restartMasterDomain;
              break;
         fi
    done
#echo "start jee app instance successfully"
}

#stop all java app instance
stopAllJavaAppInstance(){
echo "stop all java app instance begin..."
  for webtomcat in $SLAVE_TOMCAT_DOMAIN_ROOT/*
     do
         $webtomcat/$TOMCAT_VERSION/bin/shutdown.sh
     done
echo "stop all java app instance successfully"
}
#stop jee app instance
stopJeeAppInstance(){
#echo "stop jee app instance begin..."
  for webtomcat in $JEE_APP_INSTANCE_ROOT/*
     do
        if [[ "$JEE_APP_INSTANCE_ROOT/$JEE_APP_INSTANCE_NAME" = "$webtomcat" ]];
           then
             WEB_TOMCAT=$webtomcat/$TOMCAT_VERSION
             pid=$(ps -ef | grep $WEB_TOMCAT | grep java | awk '{print $2}')
             #echo "killing $pid"
             kill -9 $pid;
         sed -i "s/server  $JEE_APP_INSTANCE_IP:$TOMCAT_START_PORT;/server  $JEE_APP_INSTANCE_IP:$TOMCAT_START_PORT down;/" $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf;
         restartMasterDomain;
              break;
         fi
   done
#echo "stop jee app instance successfully"
}
restartJeeAppInstance(){
stopJeeAppInstance;
startJeeAppInstance;
}
case $COMMAND in
-deploy)
deploy;
;;
-extend)
extend;
;;
-uninstall)
uninstall;
;;
-start)
startJeeAppInstance;
;;
-restart)
restartJeeAppInstance;
;;
-stop)
stopJeeAppInstance;
;;
-delete)
deleteJeeAppInstance;
;;
*)
echo -e "Usage:\n sh jaim.sh -deploy[-extend|-uninstall|-start|restart|-stop|-delete] -path <install root path>  -aname <jee app name> -iname <jee app instance name>  -pkg <jee app package name> -startp <jee app instance start port> -stopp <jee app instance stop port> -redtp <jee app instance redirect port> -ajpp <jee app instance ajp port> -domain <domain name>  -ip <ip address of jee instance>"
exit 1
esac

