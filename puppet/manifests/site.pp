
node default {
  include my_os
  include my_mysql
  include my_postgresql
  include my_apache
  include my_java
  include my_wildfly
}

# Operating Sytem settings
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

  $install = ['binutils.x86_64','wget']

  package { $install:
    ensure  => present,
  }
}

class my_mysql {
  contain my_os

  class { '::mysql::server':
    root_password    => 'password',
    override_options => {
      'mysqld' => {
        'max_connections' => '1024' ,
        'bind-address'    => '10.10.10.10',
      }
     },
    users => {
      'petshop@%' => {
         ensure        => 'present',
         password_hash => '*8C4212B9269BA7797285063D0359C0C41311E472',
       },
     },
    grants => {
      'petshop@%/petshop.*'  => {
        ensure     => 'present',
        options    => ['GRANT'],
        privileges => ['DROP','ALTER','SELECT', 'INSERT', 'UPDATE', 'DELETE'],
        table      => 'petshop.*',
        user       => 'petshop@%',
      },
     },
    databases => {
      'petshop' => {
        ensure  => 'present',
        charset => 'utf8',
      },
     },
    service_enabled => true,
  }
}

class my_apache {
  contain my_os

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

class my_java {
  contain my_os

  class { 'jdk_oracle':
    version => "8",
  }
}

class my_wildfly{
  contain my_os,my_java

  class { 'wildfly':
    version           => '8.2.0',
    install_source    => 'http://download.jboss.org/wildfly/8.2.0.Final/wildfly-8.2.0.Final.tar.gz',
    java_home         => '/opt/jdk-8',
    dirname           => '/opt/wildfly',
    mode              => 'standalone',
    config            => 'standalone-full-ha.xml',
    users_mgmt        => { 'wildfly' => { username => 'wildfly', password => 'wildfly'}},
  }

  wget::fetch { "download sample.war":
    source      => 'https://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/sample.war',
    destination => '/opt/wildfly/standalone/deployments/sample.war',
    timeout     => 0,
    verbose     => false,
    require     => Class['wildfly::install'],
  }
}

class my_postgresql {
  contain my_os

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
