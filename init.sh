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
clear;
echo "=========================================================================";
echo "auto nginx cluster shell script for CentOS/RadHat Written by dingzhoufang";
echo "creatred in 2013/03/07";
echo "last modified in 2013/03/10";
echo "=========================================================================";
echo "=========================================================================";
echo "PHP Version: 5.2.17";
echo "=========================================================================";
echo "=========================================================================";
echo "nginx Version: 1.2.7";
echo "=========================================================================";
echo "=========================================================================";
echo "Java Version: 1.6.0_37";
echo "=========================================================================";
echo "=========================================================================";
echo "Tomcat Version: 6.0.36";
echo "=========================================================================";

#exec command 
COMMAND=$1;
#install root path
LNC_ROOT_PATH=$(getArgValue "$*" "-p");
#php version
PHP_VERSION=php-5.2.17;
#nginx version
NGINX_VERSION=nginx-1.2.7;
#tomcat version
TOMCAT_VERSION=apache-tomcat-6.0.36
#jdk version
JAVA_VERSION=jdk-6u37-linux-x64
#mysql version
MYSQL_VERSION=mysql-5.1.60
#install src package path
LNC_SRC_ROOT=$LNC_ROOT_PATH/src;
MYSQL_ROOT=$LNC_ROOT_PATH/mysql/$MYSQL_VERSION;
#php root path
PHP_ROOT=$LNC_ROOT_PATH/php/$PHP_VERSION;
#java root path
JAVA_ROOT=$LNC_ROOT_PATH/java/$JAVA_VERSION
#the third libs path
PHP_EXTRA_LIBS=$PHP_ROOT/3rdlibs;
#domain path
DOMAIN_ROOT=$LNC_ROOT_PATH/domains;
#master domain path
MASTER_DOMAIN_ROOT=$DOMAIN_ROOT/master;
#slave domain path
SLAVE_DOMAIN_ROOT=$DOMAIN_ROOT/slaves;
#slave ngnix domain instance name
SLAVE_NGNIX_DOMAIN_INSTANCE="nginx";
#slave tomcat domain instance name
SLAVE_TOMCAT_DOMAIN_INSTANCE="tomcat";
#slave nginx domain root path
SLAVE_NGNIX_DOMAIN_ROOT=$SLAVE_DOMAIN_ROOT/nginx
SLAVE_NGNIX_DOMAIN_INSTANCE=$SLAVE_NGNIX_DOMAIN_ROOT/$SLAVE_NGNIX_DOMAIN_INSTANCE/$NGINX_VERSION;
#slave tomcat domain root path
SLAVE_TOMCAT_DOMAIN_ROOT=$SLAVE_DOMAIN_ROOT/tomcat
SLAVE_TOMCAT_DOMAIN_INSTANCE=$SLAVE_TOMCAT_DOMAIN_ROOT/$SLAVE_TOMCAT_DOMAIN_INSTANCE/$TOMCAT_VERSION;
#master nginx domain root path
MASTER_NGINX_DOMAIN_ROOT=$MASTER_DOMAIN_ROOT/$NGINX_VERSION;
#php-fpm path
PHP_FPM=$PHP_ROOT/sbin/php-fpm;
#master nginx bin path
MASTER_NGINX=$MASTER_NGINX_DOMAIN_ROOT/sbin/nginx;
if [ -d $LNC_ROOT_PATH ]; then
  echo "lnc root directory is $LNC_ROOT_PATH"
  else
  echo "lnc is creating the directory $LNC_ROOT_PATH"
  mkdir -p $LNC_ROOT_PATH
fi
if [ -d $LNC_SRC_ROOT ]; then
  echo "lnc src directory is $LNC_SRC_ROOT"
  else
  echo "lnc is creating the directory $LNC_SRC_ROOT"
  mkdir -p $LNC_SRC_ROOT
fi
#install domain
install(){
echo "install domain begin...";
cd $LNC_SRC_ROOT;
installMasterDomain;
cd $LNC_SRC_ROOT;
installSlaveTomcatDomain;
cd $LNC_SRC_ROOT;
installMysql;
cd $LNC_SRC_ROOT;
installPHP;
cd $LNC_SRC_ROOT;
installSlaveNginxDomain;
echo "install domain end..."
}
prepare(){
for filename in $(rpm -aq|grep php)
do
     yum erase $filename
     #yum erase $filename -y
done
echo "========================================================================="
echo "install dependences"
echo "========================================================================="

for packages in patch make gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal nano fonts-chinese gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip autoconf yum;
do yum -y install $packages; done

echo "check files begin..."
cd $LNC_SRC_ROOT;
if [ -s $PHP_VERSION.tar.bz ]; then
  echo "$PHP_VERSION.tar.gz [found]"
  else
  echo "Error: $PHP_VERSION.tar.gz not found!!!download now......"
  wget -c http://cn2.php.net/get/$PHP_VERSION.tar.gz/from/cn.php.net/mirror 
fi

if [ -s libiconv-1.14.tar.gz ]; then
  echo "libiconv-1.14.tar.gz [found]"
  else
  echo "Error: libiconv-1.14.tar.gz not found!!!download now......"
  wget -c http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
fi

if [ -s pcre-8.31.tar.gz ]; then
  echo "pcre-8.31.tar.gz [found]"
  else
  echo "Error: pcre-8.31.tar.gz not found!!!download now......"
  wget -c http://downloads.sourceforge.net/project/pcre/pcre/8.31/pcre-8.31.tar.gz
fi

if [ -s $NGINX_VERSION.tar.gz ]; then
  echo "$NGINX_VERSION.tar.gz [found]"
  else
  echo "Error: $NGINX_VERSION.tar.gz not found!!!download now......"
  wget -c http://nginx.org/download/$NGINX_VERSION.tar.gz
fi

if [ -s $TOMCAT_VERSION.tar.gz ]; then
  echo "$TOMCAT_VERSION.tar.gz [found]"
  else
  echo "Error: $TOMCAT_VERSION.tar.gz not found!!!download now......"
  wget -c http://www.fayea.com/apache-mirror/tomcat/tomcat-6/v6.0.36/bin/$TOMCAT_VERSION.tar.gz
fi

if [ -s $MYSQL_VERSION.tar.gz ]; then
  echo "$MYSQL_VERSION.tar.gz [found]"
  else
  echo "Error: $MYSQL_VERSION.tar.gz not found!!!download now......"
  wget -c http://soft.vpser.net/datebase/mysql/$MYSQL_VERSION.tar.gz
fi

echo "check files successfully"
}
#install master nginx domain
installMasterDomain(){
  echo "install master domain begin...";
  cd $LNC_SRC_ROOT
  tar -zxvf pcre-8.31.tar.gz
  mkdir -p $MASTER_NGINX_DOMAIN_ROOT;
  tar -zxvf $NGINX_VERSION.tar.gz
  cd $NGINX_VERSION 
if [ $(id -nu) == "nginx" ]; then
  echo "user nginx is not found ... "
  else
  echo "creating the user called 'nginx'"
  su - -c "useradd -M nginx"
fi
make clean
./configure --user=nginx --group=nginx --prefix=$MASTER_NGINX_DOMAIN_ROOT --with-http_ssl_module --with-http_stub_status_module  --with-http_gzip_static_module --with-ipv6  --with-pcre=$LNC_SRC_ROOT/pcre-8.31
make
make install
cd ../
sed -i '/server {/i\\ upstream  phpdomains{\n server  127.0.0.1:81;\n  }' $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
sed -i '/server {/i\\ upstream  javadomains{\n server  127.0.0.1:8080;\n  }' $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf     
sed -i '/.php\$/i\\ location ~ \.php$ {\n    proxy_pass   http://phpdomains;\n  proxy_next_upstream  http_500 http_502 http_503 error timeout invalid_header;\n proxy_redirect off;\n  proxy_set_header Host $host;\n proxy_set_header X-Real-IP $remote_addr;\n proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n client_body_buffer_size 128k;\n proxy_connect_timeout 90;\n proxy_send_timeout 90;\n proxy_read_timeout 90;\n proxy_buffer_size 4k;\n proxy_buffers 4 32k;\n proxy_busy_buffers_size 64k;\n proxy_temp_file_write_size 64k;   \n}' $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf
sed -i '/.php\$/i\\ location ~ (\.jsp)|(\.cmd)$  {\n    proxy_pass   http://javadomains;\n  proxy_next_upstream  http_500 http_502 http_503 error timeout invalid_header;\n proxy_redirect off;\n  proxy_set_header Host $host;\n proxy_set_header X-Real-IP $remote_addr;\n proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n client_body_buffer_size 128k;\n proxy_connect_timeout 90;\n proxy_send_timeout 90;\n proxy_read_timeout 90;\n proxy_buffer_size 4k;\n proxy_buffers 4 32k;\n proxy_busy_buffers_size 64k;\n proxy_temp_file_write_size 64k;   \n}' $MASTER_NGINX_DOMAIN_ROOT/conf/nginx.conf

echo "install master domain successfully";
}
#install slave tomcat domain
installSlaveTomcatDomain(){
  echo "install slave tomcat domain begin...";
  mkdir -p $JAVA_ROOT
  cd $LNC_SRC_ROOT
#http://download.oracle.com/otn/java/jdk/6u37-b06/jdk-6u37-linux-x64.bin
chmod 777 jdk-6u37-linux-x64.bin
./jdk-6u37-linux-x64.bin
if [ ! -d jdk1.6* ];then 
  echo "I cann't find JDK directory." 
  exit 0 
fi 
cp -R jdk1.6*  $JAVA_ROOT
cat >> /etc/profile  << EFF  
JAVA_HOME=\$JAVA_ROOT
JRE_HOME=\$JAVA_HOME/jre 
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH 
export JAVA_HOME JRE_HOME CLASSPATH PATH   
EFF 
source /etc/profile 

mkdir -p $SLAVE_TOMCAT_DOMAIN_ROOT
cd $LNC_SRC_ROOT
tar -zxvf $TOMCAT_VERSION.tar.gz 
cp -R $TOMCAT_VERSION  $SLAVE_TOMCAT_DOMAIN_ROOT
cat >> /etc/profile << TTD 
TOMCAT_HOME=\$TOMCAT_ROOT
PATH=\$PATH:\$TOMCAT_HOME/bin/: 
export JAVA_HOME JRE_HOME CLASSPATH PATH TOMCAT_HOME  
TTD 
source /etc/profile 

echo "install slave tomcat domain successfully";
}
#for install mysql
installMysql(){
  echo "install mysql begin..."
   #set mysql root password
    mysqlrootpwd="root"
    echo "Please input the root password of mysql:"
    read -p "(Default password: root):" mysqlrootpwd
    if [ "$mysqlrootpwd" = "" ]; then
		mysqlrootpwd="root"
    fi
	echo "==========================="
	echo mysqlrootpwd="$mysqlrootpwd"
	echo "==========================="
#do you want to install the InnoDB Storage Engine?
	installinnodb="n"
	echo "Do you want to install the InnoDB Storage Engine?"
	read -p "(Default no,if you want please input: y ,if not please press the enter button):" installinnodb
	case "$installinnodb" in
	y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
	echo "You will install the InnoDB Storage Engine"
	installinnodb="y"
	;;
	n|N|No|NO|no|nO)
	echo "You will NOT install the InnoDB Storage Engine!"
	installinnodb="n"
	;;
	*)
	echo "INPUT error,The InnoDB Storage Engine will NOT install!"
	installinnodb="n"
	esac

mkdir -p $MYSQL_ROOT
cd $LNC_SRC_ROOT
tar -zxvf $MYSQL_VERSION.tar.gz
cd $MYSQL_VERSION/
if [ $installinnodb = "y" ]; then
./configure --prefix=$MYSQL_ROOT --with-extra-charsets=complex --enable-thread-safe-client --enable-assembler --with-mysqld-ldflags=-all-static --with-charset=utf8 --enable-thread-safe-client --with-big-tables --with-readline --with-ssl --with-embedded-server --enable-local-infile --with-plugins=innobase
else
./configure --prefix=$MYSQL_ROOT --with-extra-charsets=complex --enable-thread-safe-client --enable-assembler --with-mysqld-ldflags=-all-static --with-charset=utf8 --enable-thread-safe-client --with-big-tables --with-readline --with-ssl --with-embedded-server --enable-local-infile
fi
make && make install
cd ../

groupadd mysql
useradd -s /sbin/nologin -M -g mysql mysql

cp $MYSQL_ROOT/share/mysql/my-medium.cnf /etc/my.cnf
sed -i 's/skip-locking/skip-external-locking/g' /etc/my.cnf
if [ $installinnodb = "y" ]; then
sed -i 's:#innodb:innodb:g' /etc/my.cnf
fi
$MYSQL_ROOT/bin/mysql_install_db --user=mysql
chown -R mysql $MYSQL_ROOT/var
chgrp -R mysql $MYSQL_ROOT/.
cp $MYSQL_ROOT/share/mysql/mysql.server /etc/init.d/mysql
chmod 755 /etc/init.d/mysql

cat > /etc/ld.so.conf.d/mysql.conf<<EOF
$MYSQL_ROOT/lib/mysql
/usr/local/lib
EOF
ldconfig

ln -s $MYSQL_ROOT/lib/mysql /usr/lib/mysql
ln -s $MYSQL_ROOT/include/mysql /usr/include/mysql
/etc/init.d/mysql start

ln -s $MYSQL_ROOT/bin/mysql /usr/bin/mysql
ln -s $MYSQL_ROOT/bin/mysqldump /usr/bin/mysqldump
ln -s $MYSQL_ROOT/bin/myisamchk /usr/bin/myisamchk

$MYSQL_ROOT/bin/mysqladmin -u root password $mysqlrootpwd

cat > /tmp/mysql_sec_script<<EOF
use mysql;
update user set password=password('$mysqlrootpwd') where user='root';
delete from user where not (user='root') ;
delete from user where user='root' and password=''; 
drop database test;
DROP USER ''@'%';
flush privileges;
EOF

$MYSQL_ROOT/bin/mysql -u root -p$mysqlrootpwd -h localhost < /tmp/mysql_sec_script

rm -f /tmp/mysql_sec_script

/etc/init.d/mysql restart
/etc/init.d/mysql stop

echo "install mysql successfully"
}

#install php
installPHP(){
echo "install php begin..."
cd $LNC_SRC_ROOT
mkdir -p $PHP_EXTRA_LIBS

tar -zxvf libiconv-1.14.tar.gz
cd libiconv-1.14
make clean
./configure --prefix=$PHP_EXTRA_LIBS/libiconv-1.14/
make
make install
ls $PHP_EXTRA_LIBS/libiconv-1.14/
cd ../

tar -zxvf pcre-8.31.tar.gz
cd pcre-8.31
make clean
./configure --prefix=$PHP_EXTRA_LIBS/pcre-8.31/
make
make install
cd ../
cd $LNC_SRC_ROOT;
mkdir -p $PHP_ROOT 
tar -zxvf $PHP_VERSION.tar.gz 
cd $PHP_VERSION
make clean
 ./configure   --prefix=$PHP_ROOT   --with-config-file-path=$PHP_ROOT/etc/  --with-mysql=$MYSQL_ROOT  --with-mysqli=$MYSQL_ROOT/bin/mysql_config      --with-freetype-dir   --with-jpeg-dir   --with-png-dir   --with-zlib   --with-libxml-dir=/usr   --enable-xml   --disable-rpath   --enable-discard-path   --enable-magic-quotes   --enable-safe-mode   --enable-bcmath   --enable-shmop   --enable-sysvsem   --enable-inline-optimization   --with-curl   --with-curlwrappers   --enable-mbregex   --enable-fastcgi   --enable-fpm   --enable-force-cgi-redirect   --enable-mbstring   --with-mcrypt   --enable-ftp   --with-gd   --enable-gd-native-ttf   --with-openssl   --with-mhash   --enable-pcntl   --enable-sockets   --with-xmlrpc   --enable-zip   --enable-soap   --without-pear   --with-gettext   --with-mime-magic  --with-iconv-dir=$PHP_EXTRA_LIBS/libiconv-1.14 --with-pcre-dir=$PHP_EXTRA_LIBS/pcre-8.31  
make ZEND_EXTRA_LIBS = -liconv
make install
cp ./php.ini-production $PHP_ROOT/etc/php.ini
cp $PHP_ROOT/etc/php-fpm.conf.default $PHP_ROOT/etc/php-fpm.conf
cd ../

echo "install php successfully"
} 
#install slave nginx domain
installSlaveNginxDomain(){
  echo "install slave  nginx domain begin...";
  cd $LNC_SRC_ROOT
  tar -zxvf pcre-8.31.tar.gz
  mkdir -p $SLAVE_NGNIX_DOMAIN_INSTANCE;
  tar -zxvf $NGINX_VERSION.tar.gz
  cd $NGINX_VERSION 
if [ $(id -nu) == "nginx" ]; then
  echo "user nginx is not found ... "
  else
  echo "creating the user called 'nginx'"
  su - -c "useradd -M nginx"
fi
make clean
./configure --user=nginx --group=nginx --prefix=$SLAVE_NGNIX_DOMAIN_INSTANCE --with-http_ssl_module --with-http_stub_status_module  --with-http_gzip_static_module --with-ipv6  --with-pcre=$LNC_SRC_ROOT/pcre-8.31
make
make install
cd ../
sed  -i 's/listen       80;/ listen       81;/' $SLAVE_NGNIX_DOMAIN_INSTANCE/conf/nginx.conf
sed  -i '/.php\$/i\\ location ~ \.php$ {\n    root           html;\n    fastcgi_pass   127.0.0.1:9000;\n    fastcgi_index  index.php;\n    fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;\n    include        fastcgi_params;\n}' $SLAVE_NGNIX_DOMAIN_INSTANCE/conf/nginx.conf
  echo "install slave nginx domain successfully";
}
#prepare
prepare;
#command parser
case $COMMAND in
-i)
install;
;;
*)
echo -e "Usage:\n sh init.sh -i -p <install root path>"
exit 1
esac

