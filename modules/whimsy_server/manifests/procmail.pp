#/etc/puppet/modules/whimsy_server/manifests/procmail.pp

class whimsy_server::procmail (

) {

  ############################################################
  #                       Mail Data Source                   #
  ############################################################

  user { 'apmail':
    ensure => present,
  }

  file { "${keysdir}/apmail.pub":
    content => $apmail_keycontent,
    owner   => apmail,
    mode    => '0640',
  }

  file { '/srv/mbox':
    ensure => directory,
    owner  => apmail,
    group  => apmail,
  }

  ############################################################
  #                        Mail Delivery                     #
  ############################################################

  file { '/etc/procmailrc':
    content => "MAILDIR=\$DEFAULT\n"
  }

  exec { 'newaliases' :
    command     => '/usr/bin/newaliases',
    refreshonly => true,
  }

  ############################################################
  #                      apache (www-data)                   #
  ############################################################

  $apache_mailmap = hiera_hash('whimsy_server::apache_mailmap', {})
  $apache_aliases = keys($apache_mailmap)

  mailalias { $apache_aliases:
    ensure    => present,
    recipient => $apache::user,
    notify    => 'Exec[newaliases]'
  }

  file { '/var/www/.procmailrc':
    owner   => $apache::user,
    group   => $apache::group,
    content => template('whimsy_server/apache-mailrc.erb')
  }

  file { '/srv/mail':
    ensure => directory,
    owner  => $apache::user,
    group  => $apache::group,
  }

  $mailboxes = [
    '/srv/mail/secretary',
    '/srv/mail/members',
    '/srv/mail/board'
  ]

  file { $mailboxes:
    ensure => directory,
    owner  => $apache::user,
    group  => $apache::group,
  }

  file { '/srv/mail/procmail.log':
    ensure => present,
    owner  => $apache::user,
    group  => $apache::group,
  }

  logrotate::rule { 'procmail':
    path         => '/srv/mail/procmail.log',
    rotate       => 6,
    rotate_every => 'month',
    missingok    => true,
    compress     => true,
  }

  ############################################################
  #                          whimsysvn                       #
  ############################################################

  $whimsysvn_mailmap = hiera_hash('whimsy_server::whimsysvn_mailmap', {})
  $whimsysvn_aliases = keys($whimsysvn_mailmap)

  mailalias { $whimsysvn_aliases:
    ensure    => present,
    recipient => whimsysvn,
    notify    => 'Exec[newaliases]'
  }

  file { '/home/whimsysvn/.procmailrc':
    owner   => whimsysvn,
    group   => whimsysvn,
    content => template('whimsy_server/whimsysvn-mailrc.erb')
  }


  file { '/srv/svn/procmail.log':
    ensure => present,
    owner  => whimsysvn,
    group  => whimsysvn,
  }

  logrotate::rule { 'procmail-svn':
    path         => '/srv/svn/procmail.log',
    rotate       => 6,
    rotate_every => 'month',
    missingok    => true,
    compress     => true,
  }

}
