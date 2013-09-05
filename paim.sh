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
if [ "${arglist[$i]}" = "$2" ]; then
   echo "${arglist[$i+1]}";
   break;
 fi
done
}

#exec command 
COMMAND=$1;
#install root path
LNC_ROOT_PATH=$(getArgValue "$*" "-path");
#slave nginx domain instance name
PHP_APP_INSTANCE_NAME=$(getArgValue "$*" "-iname");
PHP_APP_NAME=$(getArgValue "$*" "-aname");
PHP_APP_PACKAGE_NAME=$(getArgValue "$*" "-pkg");
NGINX_PORT=$(getArgValue "$*" "-port");
PHP_APP_DOMAIN=$(getArgValue "$*" "-domain");
PHP_APP_INSTANCE_IP=$(getArgValue "$*" "-ip");
#php version
PHP_VERSION=php-5.2.17;
#nginx version
NGINX_VERSION=nginx-1.2.7;
#install src package path
LNC_SRC_ROOT=$LNC_ROOT_PATH/src;
#install upload package path
LNC_UPLOAD_ROOT=$LNC_ROOT_PATH/upload/$PHP_APP_NAME;
#php root path
PHP_ROOT=$LNC_ROOT_PATH/php/$PHP_VERSION;
#domain path
DOMAIN_ROOT=$LNC_ROOT_PATH/domains;
#master domain path
MASTER_DOMAIN_ROOT=$DOMAIN_ROOT/master;
#slave domain path
SLAVE_DOMAIN_ROOT=$DOMAIN_ROOT/slaves;
#slave nginx domain root path
SLAVE_NGNIX_DOMAIN_ROOT=$SLAVE_DOMAIN_ROOT/nginx
#slave ngnix domain instance name
SLAVE_NGNIX_DOMAIN_INSTANCE_NAME="nginx";
SLAVE_NGNIX_DOMAIN_INSTANCE=$SLAVE_NGNIX_DOMAIN_ROOT/$SLAVE_NGNIX_DOMAIN_INSTANCE_NAME/$NGINX_VERSION;
PHP_APP_INSTANCE_ROOT=$SLAVE_NGNIX_DOMAIN_ROOT/$PHP_APP_NAME
#master nginx domain root path
MASTER_NGINX_DOMAIN_ROOT=$MASTER_DOMAIN_ROOT/$NGINX_VERSION;
#php-fpm path
PHP_FPM=$PHP_ROOT/sbin/php-fpm;
#master nginx bin path
MASTER_NGINX=$MASTER_NGINX_DOMAIN_ROOT/sbin/nginx;
#app dir
PHP_APP_PATH=$PHP_APP_INSTANCE_ROOT/$PHP_APP_INSTANCE_NAME/$NGINX_VERSION/webapps/$PHP_APP_DOMAIN

restartMasterDomain(){
      pid=$(ps -ef | grep $MASTER_NGINX | grep 'nginx: master process' | awk '{print $2}')
      #echo "restart $pid"
      kill -HUP $pid;
   }
#create php app instance
createPhpAppInstance(){
if [ -d $PHP_APP_INSTANCE_ROOT ]; then
  for webnginx in $PHP_APP_INSTANCE_ROOT/*
   do
      if [[ "$PHP_APP_INSTANCE_ROOT/$PHP_APP_INSTANCE_NAME" = "$webnginx" ]];
        then
            #echo "Error: the instance name $PHP_APP_INSTANCE_NAME is also exist.please enter another instance name."
            exit 1
     fi
 done
else
   mkdir -p $PHP_APP_INSTANCE_ROOT
fi
#echo "create php  app instance begin...";
 PHP_APP_INSTANCE_PATH=$PHP_APP_INSTANCE_ROOT/$PHP_APP_INSTANCE_NAME/$NGINX_VERSION 
 mkdir -p $PHP_APP_INSTANCE_PATH
  cd $LNC_SRC_ROOT
  tar -zxvf pcre-8.31.tar.gz
  tar -zxvf $NGINX_VERSION.tar.gz
  cd $NGINX_VERSION 
#if [ $(id -nu) = "nginx" ]; then
#  echo "user nginx is not found ... "
#  else
#  echo "creating the user called 'nginx'"
#  su - -c "useradd -M nginx"
#fi
make clean
./configure --user=www --group=www --prefix=$PHP_APP_INSTANCE_PATH --with-http_ssl_module --with-http_stub_status_module  --with-http_gzip_static_module --with-ipv6  --with-pcre=$LNC_SRC_ROOT/pcre-8.31
make
make install
cd ../
cd $PHP_APP_INSTANCE_PATH
mkdir -p webapps/$PHP_APP_DOMAIN
sed  -i "s/80/$NGINX_PORT/" $PHP_APP_INSTANCE_PATH/conf/nginx.conf
sed  -i "s/server_name  localhost;/server_name  $PHP_APP_DOMAIN;/" $PHP_APP_INSTANCE_PATH/conf/nginx.conf
sed  -i "/access_log  logs\/host.access.log  main;/a\\ location ~ \.php$ {\n    root           webapps;\n    fastcgi_pass   127.0.0.1:9000;\n    fastcgi_index  index.php;\n    fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;\n    include        fastcgi_params;\n}" $PHP_APP_INSTANCE_PATH/conf/nginx.conf
sed -i "/gzip  on;/a\\ upstream  $PHP_APP_DOMAIN{\n server  $PHP_APP_INSTANCE_IP:$NGINX_PORT;\n  }" $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
sed -i "/access_log  logs\/host.access.log  main;/a\\ location ^~ /$PHP_APP_DOMAIN/ {\n    proxy_pass   http://$PHP_APP_DOMAIN;\n  proxy_next_upstream  http_500 http_502 http_503 error timeout invalid_header;\n proxy_redirect off;\n  proxy_set_header Host \$host;\n proxy_set_header X-Real-IP \$remote_addr;\n proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\n client_body_buffer_size 128k;\n proxy_connect_timeout 90;\n proxy_send_timeout 90;\n proxy_read_timeout 90;\n proxy_buffer_size 4k;\n proxy_buffers 4 32k;\n proxy_busy_buffers_size 64k;\n proxy_temp_file_write_size 64k;   \n}" $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
#echo "create php app instance successfully";
} 
#extend php app instance
extPhpAppInstance(){
if [ -d $PHP_APP_INSTANCE_ROOT ]; then
  for webnginx in $PHP_APP_INSTANCE_ROOT/*
   do
      if [[ "$PHP_APP_INSTANCE_ROOT/$PHP_APP_INSTANCE_NAME" = "$webnginx" ]];
        then
            #echo "Error: the instance name $PHP_APP_INSTANCE_NAME is also exist.please enter another instance name."
            exit 1
     fi
 done
else
   mkdir -p $PHP_APP_INSTANCE_ROOT
fi
#echo "create php  app instance begin...";
 PHP_APP_INSTANCE_PATH=$PHP_APP_INSTANCE_ROOT/$PHP_APP_INSTANCE_NAME/$NGINX_VERSION 
 mkdir -p $PHP_APP_INSTANCE_PATH
  cd $LNC_SRC_ROOT
  tar -zxvf pcre-8.31.tar.gz
  tar -zxvf $NGINX_VERSION.tar.gz
  cd $NGINX_VERSION 
#if [ $(id -nu) = "nginx" ]; then
#  echo "user nginx is not found ... "
#  else
#  echo "creating the user called 'nginx'"
#  su - -c "useradd -M nginx"
#fi
make clean
./configure --user=www --group=www --prefix=$PHP_APP_INSTANCE_PATH --with-http_ssl_module --with-http_stub_status_module  --with-http_gzip_static_module --with-ipv6  --with-pcre=$LNC_SRC_ROOT/pcre-8.31
make
make install
cd ../
cd $PHP_APP_INSTANCE_PATH
mkdir -p webapps/$PHP_APP_DOMAIN
sed  -i "s/80/$NGINX_PORT/" $PHP_APP_INSTANCE_PATH/conf/nginx.conf
sed  -i "s/server_name  localhost;/server_name  $PHP_APP_DOMAIN;/" $PHP_APP_INSTANCE_PATH/conf/nginx.conf
sed  -i "/access_log  logs\/host.access.log  main;/a\\ location ~ \.php$ {\n    root           webapps;\n    fastcgi_pass   127.0.0.1:9000;\n    fastcgi_index  index.php;\n    fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;\n    include        fastcgi_params;\n}" $PHP_APP_INSTANCE_PATH/conf/nginx.conf
sed -i "/upstream  $PHP_APP_DOMAIN{/a\\  server  $PHP_APP_INSTANCE_IP:$NGINX_PORT;\n" $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
#echo "create php app instance successfully";
} 
#deploy php app
deployPhpApp(){
   cd $LNC_UPLOAD_ROOT;
   if [ -s $PHP_APP_PACKAGE_NAME.tar.gz ]; then
        tar -zxvf $PHP_APP_PACKAGE_NAME.tar.gz;
        cd $PHP_APP_PACKAGE_NAME;
        cp -R $LNC_UPLOAD_ROOT/$PHP_APP_PACKAGE_NAME $PHP_APP_PATH
   fi
}
deploy(){
createPhpAppInstance;
deployPhpApp;
restartMasterDomain;
}
extend(){
extPhpAppInstance;
deployPhpApp;
restartMasterDomain;
}
uninstall(){
#echo "uninstall php app begin..."
rm -fr $LNC_UPLOAD_ROOT;
rm -fr $PHP_APP_INSTANCE_ROOT;
sed -i ":begin; /upstream  $PHP_APP_DOMAIN{/,/}/ { /}/! { $! { N; b begin }; }; s/upstream  $PHP_APP_DOMAIN{.*}//; };"  $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
sed -i ":begin; /location ^~ \/$PHP_APP_DOMAIN\/ {/,/}/ { /}/! { $! { N; b begin }; }; s/location ^~ \/$PHP_APP_DOMAIN\/ {.*}//; };"  $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
restartMasterDomain;
#echo "uninstall php app successfully"
}
#delete all php app instance
deleteAllPhpAppInstance(){
#echo "delete all php app instance begin..."
rm -fr $PHP_APP_INSTANCE_ROOT;
sed -i ":begin; /upstream  phpdomains{/,/}/ { /}/! { $! { N; b begin }; }; s/upstream  phpdomains{.*}//; };"  $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
restartMasterDomain;
#echo "delete all php app instance successfully"
}
#delete an exist php app instance
deletePhpAppInstance(){
#echo "delete php app instance begin..."
rm -fr $PHP_APP_INSTANCE_ROOT/$PHP_APP_INSTANCE_NAME;
sed -i "s/server  $PHP_APP_INSTANCE_IP:$NGINX_PORT;//" $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
sed -i "s/server  $PHP_APP_INSTANCE_IP:$NGINX_PORT down;//" $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
restartMasterDomain;
#echo "delete php app instance successfully"
}

#start all php app instance
startAllPhpAppInstance(){
#	echo "start all php app instance begin..."
	#$PHP_ROOT/sbin/php-fpm
      for webnginx in $PHP_APP_INSTANCE_ROOT/*
        do
           $webnginx/$NGINX_VERSION/sbin/nginx
	done
#	echo "start all php app instance begin successfully"
}
#start a php app instance
startPhpAppInstance(){
#	echo "start php app instance begin..."
	for webnginx in $PHP_APP_INSTANCE_ROOT/*
        do
          if [[ "$PHP_APP_INSTANCE_ROOT/$PHP_APP_INSTANCE_NAME" = "$webnginx" ]];
        then
             $webnginx/$NGINX_VERSION/sbin/nginx;
             sed -i "s/server  $PHP_APP_INSTANCE_IP:$NGINX_PORT down;/server  $PHP_APP_INSTANCE_IP:$NGINX_PORT;/" $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
             restartMasterDomain;
             break;
        fi
	done
#	echo "start php app instance begin successfully"
}
#stop all php app instance
stopAllPhpAppInstance(){
#    echo "stop all php app instance begin..."
     for webnginx in $PHP_APP_INSTANCE_ROOT/*
     do
      WEB_NGINX=$webnginx/$NGINX_VERSION/sbin/nginx
	pid=$(ps -ef | grep $WEB_NGINX | grep 'nginx: master process' | awk '{print $2}')
      # echo "killing $pid"
      kill -9 $pid
    done
#  echo "stop all php app instance successfully"
}
#stop a php app instance
stopPhpAppInstance(){
   # echo "stop a php app instance begin..."
    for webnginx in $PHP_APP_INSTANCE_ROOT/*
     do
      if [[ "$PHP_APP_INSTANCE_ROOT/$PHP_APP_INSTANCE_NAME" = "$webnginx" ]];
       then
         WEB_NGINX=$webnginx/$NGINX_VERSION/sbin/nginx
         pid=$(ps -ef | grep $WEB_NGINX | grep 'nginx: master process' | awk '{print $2}')
         #echo "killing $pid"
         kill -9 $pid;
         sed -i "s/server  $PHP_APP_INSTANCE_IP:$NGINX_PORT;/server  $PHP_APP_INSTANCE_IP:$NGINX_PORT down;/" $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf;
         restartMasterDomain;
        break;
      fi
    done
 # echo "stop a php app instance successfully"
}
#restart php app instance
restartPhpAppInstance(){
#    echo "restart a php app instance begin..."
    for webnginx in $PHP_APP_INSTANCE_ROOT/*
     do
      if [[ "$PHP_APP_INSTANCE_ROOT/$PHP_APP_INSTANCE_NAME" = "$webnginx" ]];
       then
         WEB_NGINX=$webnginx/$NGINX_VERSION/sbin/nginx
	   pid=$(ps -ef | grep $WEB_NGINX | grep 'nginx: master process' | awk '{print $2}')
         #   echo "killing $pid"
         kill -HUP $pid
        break;
      fi
    done
#  echo "restart a php app instance successfully"
}
killUnusedWorkerProcess(){
   ps -ef | grep 'nginx: worker process' | {
           while read user cpid ppid unk uunk tty time cmd;
           do
           if [[ "$ppid" = "1" ]];then
             #echo "killing $cpid";
             kill -9 $cpid;
          fi
        done
         }
}
case $COMMAND in
-deploy)
deploy;
killUnusedWorkerProcess;
;;
-extend)
extend;
killUnusedWorkerProcess;
;;
-uninstall)
uninstall;
killUnusedWorkerProcess;
;;
-start)
startPhpAppInstance;
killUnusedWorkerProcess;
;;
-restart)
restartPhpAppInstance;
killUnusedWorkerProcess;
;;
-stop)
stopPhpAppInstance;
killUnusedWorkerProcess;
;;
-delete)
deletePhpAppInstance;
killUnusedWorkerProcess;
;;
*)
echo -e "Usage:\n sh paim.sh -deploy[-extend|-uninstall|-start|restart|-stop|-delete] -path <install root path>  -aname <php app name> -iname <php app instance name>  -pkg <php app package name> -port <php app instance port> -domain <domain name> -ip <ip address of instance>"
exit 1
esac

