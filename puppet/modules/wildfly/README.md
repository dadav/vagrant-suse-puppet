#Wildfly JBoss puppet module
[![Build Status](https://travis-ci.org/biemond/biemond-wildfly.png)](https://travis-ci.org/biemond/biemond-wildfly)

created by Edwin Biemond email biemond at gmail dot com   
[biemond.blogspot.com](http://biemond.blogspot.com)    
[Github homepage](https://github.com/biemond/biemond-wildfly)  

Should work on every Redhat or Debian family member and tested it with Wildfly 8.1.0 & 8.0.0

##Usage


    class { 'wildfly::install':
      version        => '8.1.0',
      install_source => 'http://download.jboss.org/wildfly/8.1.0.Final/wildfly-8.1.0.Final.tar.gz',
      install_file   => 'wildfly-8.1.0.Final.tar.gz',
      java_home      => '/opt/jdk-8',
    }

or 

    class { 'wildfly::install':
      version        => '8.0.0',
      install_source => 'http://download.jboss.org/wildfly/8.0.0.Final/wildfly-8.0.0.Final.tar.gz',
      install_file   => 'wildfly-8.0.0.Final.tar.gz',
      java_home      => '/opt/jdk-8',
    }

or 

    class { 'wildfly::install':
      version        => '8.0.0',
      install_source => 'http://download.jboss.org/wildfly/8.0.0.Final/wildfly-8.0.0.Final.tar.gz',
      install_file   => 'wildfly-8.0.0.Final.tar.gz',
      java_home      => '/opt/jdk-8',
      group           = 'wildfly',
      user            = 'wildfly',
      dirname         = '/opt/wildfly',
    }
    