class cloudpd_postfix {
  
  package { "postfix":
        ensure => installed
      }

  service { "postfix":
       ensure     => running,
       enable     => true,
       hasrestart => true,
       hasstatus  => true,
       require    => Package["postfix"]
     }

  file { "/etc/postfix/generic":
           ensure  => present,
           content => template("cloudpd_postfix/generic.erb"),
           require => Package["postfix"],
           notify  => Service["postfix"]
         }

   file { "/etc/postfix/header_checks":
           ensure  => present,
           content => template("cloudpd_postfix/header_checks.erb"),
           require => Package["postfix"],
           notify  => Service["postfix"]
         }
         
  file_line { 'smtp_generic_maps':
        match => '^smtp_generic_maps',
        line => 'smtp_generic_maps = hash:/etc/postfix/generic',
        path => '/etc/postfix/main.cf',
      }
  file_line { 'header_checks':
        match => '^header_checks',
        line => 'header_checks = regexp:/etc/postfix/header_checks',
        path => '/etc/postfix/main.cf',
      }
  file_line { 'mydomain':
        match => '^mydomain',
        line => 'mydomain = cloud.pd.infn.it',
        path => '/etc/postfix/main.cf',
      }
  file_line { 'myorigin':
        match => '^myorigin',
        line => 'myorigin = $myhostname',
        path => '/etc/postfix/main.cf',
      }
  file_line { 'relayhost':
        match => '^relayhost',
        line => 'relayhost = mbox.pd.infn.it',
        path => '/etc/postfix/main.cf',
      }
  exec { "postfix-postmap-generic":
      command     => "/usr/sbin/postmap /etc/postfix/generic",
      creates => "/etc/postfix/generic.db"
    }
  }
