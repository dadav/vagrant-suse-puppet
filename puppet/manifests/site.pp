#
node default {
  include os
  include java
  include mysql
}  

# operating settings for Middleware
class os {

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

  group { 'dba' :
    ensure => present,
  }

  # http://raftaman.net/?p=1311 for generating password
  # password = oracle
  user { 'dev' :
    ensure     => present,
    groups     => 'dba',
    shell      => '/bin/bash',
    password   => '$1$JWbdEnvW$rrWeR8H1DIuZsXp4f776H0',
    home       => "/home/wls",
    comment    => 'dev user created by Puppet',
    managehome => true,
    require    => Group['dba'],
  }

  $install = [ 'binutils.x86_64','unzip.x86_64','wget']

  package { $install:
    ensure  => present,
  }

  yumrepo { "mysql-repo":
    baseurl  => "http://repo.mysql.com/yum/mysql-5.6-community/fc/20/x86_64/",
    descr    => "My mysql Repo",
    enabled  => 1,
    gpgcheck => 0,
    priority => 1,
    before      => Package['mysql-community-server'],
  }


}

class java {
  require os

  $remove = [ "java-1.7.0-openjdk.x86_64", "java-1.6.0-openjdk.x86_64" ]

  package { $remove:
    ensure  => absent,
  }

  class { 'jdk_oracle': 
    version => "8",
    require => Package[$remove],
  }
}

class postgresql {
  require os

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

}

class mysql {
  require os

  # SELECT PASSWORD('petshop')
  class { '::mysql::server':
    root_password    => 'password',
    override_options => { 
          'mysqld' => { 
            'max_connections'   => '1024' ,
          } 
      },
    users            => { 'petshop@%'      => {
                            ensure         => 'present',
                            password_hash  => '*8C4212B9269BA7797285063D0359C0C41311E472',
                           },  
                        },   
    grants           => { 'petshop@%'  => {
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



