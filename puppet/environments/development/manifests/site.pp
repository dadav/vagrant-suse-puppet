
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
    version        => "8",
    version_update => '60',
    version_build  => '27',
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


class my_wildfly{
  contain my_os, my_java, my_postgresql

  class { 'wildfly':
    version        => '8.2.0',
    install_source => 'http://download.jboss.org/wildfly/8.2.0.Final/wildfly-8.2.0.Final.tar.gz',
    # version           => '9.0.2',
    # install_source    => 'http://download.jboss.org/wildfly/9.0.2.Final/wildfly-9.0.2.Final.tar.gz',
    java_home         => '/opt/jdk1.8.0_60',
    dirname           => '/opt/wildfly',
    mode              => 'standalone',
    config            => 'standalone-full-ha.xml',
    users_mgmt        => { 'wildfly' => { password => 'wildfly'}},
  }

  wildfly::config::interfaces{'management':
    inet_address_value => '0.0.0.0',
    require  => Class['wildfly'],
  }

  wildfly::config::interfaces{'public':
    inet_address_value => '0.0.0.0',
    require  => Class['wildfly'],
  }

  wildfly::deployment { 'sample.war':
    source   => 'https://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/sample.war',
    require  => Class['wildfly'],
  }

  wildfly::config::mgmt_user { 'mgmtuser':
    password => 'mgmtuser',
    require  => Class['wildfly'],
  }

  wildfly::config::app_user { 'appuser':
    password => 'appuser',
    require  => Class['wildfly'],
  }

  wildfly::config::user_groups { 'mgmtuser':
    groups   => 'admin,mygroup',
    require  => Wildfly::Config::Mgmt_user['mgmtuser'],
  }

  wildfly::config::user_roles { 'appuser':
    roles    => 'guest,ejb',
    require  => Wildfly::Config::App_user['appuser'],
  }

  wildfly::messaging::queue { 'DemoQueue':
    durable => true,
    entries => ['java:/jms/queue/DemoQueue'],
    require => Class['wildfly'],
  }

  wildfly::messaging::topic { 'DemoTopic':
    entries => ['java:/jms/topic/DemoTopic'],
    require => Class['wildfly'],
  }

  wildfly::config::module { 'org.postgresql':
    source       => 'http://central.maven.org/maven2/org/postgresql/postgresql/9.3-1103-jdbc4/postgresql-9.3-1103-jdbc4.jar',
    dependencies => ['javax.api', 'javax.transaction.api'],
    require      => Class['wildfly'],
  } ->
  wildfly::datasources::driver { 'Driver postgresql':
    driver_name                     => 'postgresql',
    driver_module_name              => 'org.postgresql',
    driver_xa_datasource_class_name => 'org.postgresql.xa.PGXADataSource'
  } ->
  wildfly::datasources::datasource { 'petshop datasource':
    name           => 'petshopDS',
    config         => { 'driver-name'    => 'postgresql',
                        'connection-url' => 'jdbc:postgresql://10.10.10.10/petshop',
                        'jndi-name'      => 'java:jboss/datasources/petshopDS',
                        'user-name'      => 'petshop',
                        'password'       => 'password'
                      }
  } ->
  wildfly::datasources::xa_datasource { 'petshop xa datasource':
    name            => 'petshopDSXa',
    config          => {  'driver-name'              => 'postgresql',
                          'jndi-name'                => 'java:jboss/datasources/petshopDSXa',
                          'user-name'                => 'petshop',
                          'password'                 => 'password',
                          'xa-datasource-class'      => 'org.postgresql.xa.PGXADataSource',
                          'xa-datasource-properties' => {
                                'url' => {'url' => 'jdbc:postgresql://10.10.10.10/petshop'}
                          },
    }
  }


}

