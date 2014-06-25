#vagrant-fedora20-puppet

##tomcat 7.0.52 on JDK1.8.05

###petshop instance
/srv/tomcat/petshop

###sample app
http://10.10.10.10:8080/sample/

##wildfly 8.1.0 on JDK1.8.05

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


Changes to mysql module

Line 29,30 params.pp

  case $::osfamily {
    'RedHat': {
      if $::operatingsystem == 'Fedora' and (is_integer($::operatingsystemrelease) and $::operatingsystemrelease >= 19 or $::operatingsystemrelease == "Rawhide") {
        $client_package_name = 'mysql'
        $server_package_name = 'mysql-community-server'
