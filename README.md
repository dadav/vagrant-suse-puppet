#vagrant-fedora20-puppet


##wildfly 8.2.0 on JDK1.8.20

###management app
http://10.10.10.10:9990

user wildfly password wildfly

###sample app
http://10.10.10.10:8080/sample/

##apache with AJP
http://10.10.10.10:81/petshop/sample/

##MySQL petshop database
10.10.10.10 3306 user root, password password 

### petshop
user petshop, password petshop

##postgresql petshop database

### petshop
10.10.10.10 5432 user petshop or postgres with password as password


##Changes

###Changes to mysql module

check out https://github.com/puppetlabs/puppetlabs-mysql/tree/2.3.x and not the default mysql enterprise module, this is not compatiable with fedora and mariadb 

###Changes to jdk_oracle module

Line 50,51 init.pp

    case $version {
        '8': {
            $javaDownloadURI = "http://download.oracle.com/otn-pub/java/jdk/8u5-b13/jdk-8u5-linux-${plat_filename}.tar.gz"
            $java_home = "${install_dir}/jdk1.8.0_05"
