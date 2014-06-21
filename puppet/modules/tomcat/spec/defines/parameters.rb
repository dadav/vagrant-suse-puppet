@parameters = {
  'DEB6' => {
    'java_home'                 => '/usr',
    'log4j'                     => 'liblog4j1.2-java',
    'logging'                   => 'libcommons-logging-java',
    'lsbmajdistrelease'         => '6',
    'operatingsystem'           => 'Debian',
    'operatingsystemmajrelease' => '6',
    'osfamily'                  => 'Debian',
    'tomcat_home'               => '/usr/share/tomcat',
    'tomcat_package'            => 'tomcat6',
    'tomcat_version'            => '6',
    'sudo_version'              => '1.7.3',
  },
  'DEB7' => {
    'java_home'                 => '/usr',
    'log4j'                     => 'liblog4j1.2-java',
    'logging'                   => 'libcommons-logging-java',
    'lsbmajdistrelease'         => '7',
    'operatingsystem'           => 'Debian',
    'operatingsystemmajrelease' => '7',
    'osfamily'                  => 'Debian',
    'tomcat_home'               => '/usr/share/tomcat',
    'tomcat_package'            => 'tomcat6',
    'tomcat_version'            => '6',
    'sudo_version'              => '1.7.3',
  },
  'RHEL5' => {
    'java_home'                 => '/usr/lib/jvm/java',
    'log4j'                     => 'log4j',
    'logging'                   => 'jakarta-commons-logging',
    'lsbmajdistrelease'         => '5',
    'operatingsystem'           => 'RedHat',
    'operatingsystemmajrelease' => '5',
    'osfamily'                  => 'RedHat',
    'tomcat_home'               => '/var/lib/tomcat',
    'tomcat_package'            => 'tomcat5',
    'tomcat_version'            => '5',
    'sudo_version'              => '1.7.3',
  },
  'RHEL6' => {
    'java_home'                 => '/usr/lib/jvm/java',
    'log4j'                     => 'log4j',
    'logging'                   => 'jakarta-commons-logging',
    'lsbmajdistrelease'         => '6',
    'operatingsystem'           => 'RedHat',
    'operatingsystemmajrelease' => '6',
    'osfamily'                  => 'RedHat',
    'tomcat_home'               => '/var/lib/tomcat',
    'tomcat_package'            => 'tomcat6',
    'tomcat_version'            => '6',
    'sudo_version'              => '1.7.3',
  },
}