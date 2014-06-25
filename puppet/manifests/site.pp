#
node default {
  include my_os
  include my_mysql
  include my_java
  include my_postgresql
#  include my_tomcat
  include my_wildfly
  include my_apache
}  

# operating settings for Middleware
class my_os {

  host{'localhost':
    ip           => "127.0.0.1",
    host_aliases => ['localhost.localdomain',
                     'localhost4',
                     'localhost4.localdomain4'],
  }

  host{'dev.example.com':
    ip           => "10.10.10.10",
    host_aliases => 'dev',
  }

  service { iptables:
        enable    => false,
        ensure    => false,
        hasstatus => true,
  }

  $install = [ 'binutils.x86_64','unzip.x86_64','wget','java-1.7.0-openjdk.x86_64']

  package { $install:
    ensure  => present,
  }


}

class my_java {
  require my_os

  class { 'jdk_oracle': 
    version => "8",
  }

}

class my_postgresql {
  require my_os

  class { 'postgresql::server':
    ip_mask_allow_all_users    => '0.0.0.0/0',
    listen_addresses           => '*',
    postgres_password          => 'password',
  }

  postgresql::server::db { 'petshop':
    user     => 'petshop',
    password => postgresql_password('petshop', 'password'),
  }

  postgresql::server::role { 'managers':
    password_hash => postgresql_password('managers', 'password'),
  }

  postgresql::server::database_grant { 'test1':
    privilege => 'ALL',
    db        => 'petshop',
    role      => 'managers',
  }

  postgresql::validate_db_connection { 'validate my postgres connection':
    database_host           => '10.10.10.10',
    database_username       => 'petshop',
    database_password       => 'password',
    database_name           => 'petshop',
    require                 => Postgresql::Server::Db['petshop']
  }

}

class my_mysql {
  require my_os

  yumrepo { "mysql-repo":
    baseurl  => "http://repo.mysql.com/yum/mysql-5.6-community/fc/20/x86_64/",
    descr    => "My mysql Repo",
    enabled  => 1,
    gpgcheck => 0,
    priority => 1,
    before   => Class['::mysql::server'],
  }


  # SELECT PASSWORD('petshop')
  class { '::mysql::server':
    root_password    => 'password',
    override_options => { 
          'mysqld' => { 
            'max_connections'   => '1024' ,
            'bind-address'      => '10.10.10.10',
          } 
      },
    users            => { 'petshop@%'      => {
                            ensure         => 'present',
                            password_hash  => '*8C4212B9269BA7797285063D0359C0C41311E472',
                           },  
                        },   
    grants           => { 'petshop@%/petshop.*'  => {
                            ensure     => 'present',
                            options    => ['GRANT'],
                            privileges => ['DROP','ALTER','SELECT', 'INSERT', 'UPDATE', 'DELETE'],
                            table      => 'petshop.*',
                            user       => 'petshop@%',
                          },
                        },  
    databases        => { 'petshop' => {
                            ensure  => 'present',
                            charset => 'utf8',
                          },
                        },  
    service_enabled  => true,  
  }
}  

class my_tomcat {
  require my_os,my_java

  Exec {
    path => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin',
  }

  class { 'tomcat':
    version     => 7,
    sources     => true,
  }

  tomcat::instance {'petshop':
    ensure      => present,
    server_port => '8005',
    http_port   => '8080',
    ajp_port    => '8009',
    java_home   => '/opt/jdk1.8.0_05',
  }

  file{'/srv/tomcat/petshop/webapps/sample.war':
    ensure  => present,
    source  => '/vagrant/sample.war',   
    mode    => '0664',
    require => Tomcat::Instance['petshop'],
  }

}

class my_wildfly{
  require my_os,my_java

  # class { 'wildfly::install':
  #   version        => '8.1.0',
  #   install_source => 'http://download.jboss.org/wildfly/8.1.0.Final/wildfly-8.1.0.Final.tar.gz',
  #   install_file   => 'wildfly-8.1.0.Final.tar.gz',
  #   java_home      => '/opt/jdk-8',
  # }

  class { 'wildfly::install':
    version           => '8.1.0',
    install_source    => 'http://download.jboss.org/wildfly/8.1.0.Final/wildfly-8.1.0.Final.tar.gz',
    install_file      => 'wildfly-8.1.0.Final.tar.gz',
    java_home         => '/opt/jdk-8',
    group             => 'wildfly',
    user              => 'wildfly',
    dirname           => '/opt/wildfly',
    mode              => 'standalone',
    config            => 'standalone-full.xml',
    java_xmx          => '512m',
    java_xms          => '256m',
    java_maxpermsize  => '256m',
    mgmt_http_port    => '9990',
    mgmt_https_port   => '9993',
    public_http_port  => '8080',
    public_https_port => '8443',
    ajp_port          => '8009',
    users_mgmt        => { 'wildfly' => { username => 'wildfly', password => '2c6368f4996288fcc621c5355d3e39b7'}},
  }

  file{'/opt/wildfly/standalone/deployments/sample.war':
    ensure  => present,
    source  => '/vagrant/sample.war',   
    mode    => '0664',
    require => Class['wildfly::install'],
  }

}

class my_apache {
  require my_os

  class { 'apache':
    default_mods        => true,
    default_confd_files => true,
  }

  apache::mod { 'proxy_ajp': }

  apache::vhost { 'dev.example.com':
    vhost_name       => '*',
    port             => '81',
    docroot          => '/var/www/petshop',
    proxy_pass => [
      { 'path' => '/petshop', 'url' => 'ajp://10.10.10.10:8009' },
    ],
  }
}

