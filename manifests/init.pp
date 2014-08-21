class statsfeeder(
  $appliance_name,
  $vcenter_host,
  $vcenter_user,
  $vcenter_passwd,
  $version         = '4.1.697',
  $graphite_host,
  $install_dir     = '/opt/statsfeeder',
  $config          = '/opt/statsfeeder/config/config.xml',
) {

  file { '/opt/statsfeeder':
    ensure => directory,
    before => Exec['get_statsfeeder'],
  }

  exec { 'get_statsfeeder':
    command => "wget -O /opt/statsfeeder/StatsFeeder.zip http://download3.vmware.com/software/vmw-tools/statsfeeder/StatsFeeder-${version}.zip",
    path    => ['/bin', '/usr/bin'],
    create  => '/opt/statsfeeder/StatsFeeder.zip',
    notify  => Exec['expand_statsfeeder'],
  }

  exec { 'expand_statsfeeder':
    command     => 'unzip StatsFeeder.zip',
    path        => ['/bin', '/usr/bin'],
    cwd         => '/opt/statsfeeder',
    refreshonly => true,
    creates     => '/opt/statsfeeder/lib',
  }

  file { 'statsfeeder-default':
    path    => '/etc/default/statsfeeder',
    ensure  => present,
    content => template('statsfeeder/statsfeeder.erb'),
    require => Exec['expand_statsfeeder'],
  }

  file { 'statsfeeder-config':
    path    => '/opt/statsfeeder/config/config.xml',
    ensure  => present,
    content => template('statsfeeder/config.xml.erb'),
    require => Exec['expand_statsfeeder'],
  }

  file { 'statsfeeder-logging':
    path    => '/opt/statsfeeder/log4j.properties',
    ensure  => present,
    content => template('statsfeeder/log4j.properties.erb'),
    require => Exec['expand_statsfeeder'],
  }

  cron { 'statsfeeder-cron':
    command => '/opt/statsfeeder/parse.py',
    user    => 'root',
    minute  => '*/15',
    require => Exec['expand_statsfeeder'],
  }

  file { 'statsfeeder-parse':
    path    => '/opt/statsfeeder/parse.py',
    ensure  => present,
    content => template('statsfeeder/parse.py.erb'),
    require => Exec['expand_statsfeeder'],
  }

  file { 'statsfeeder-service':
    path    => '/etc/init.d/statsfeeder',
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/statsfeeder/etc/init.d/statsfeeder',
    require => Exec['expand_statsfeeder'],
  }

  file { 'statsfeeder-runner':
    path    => '/opt/statsfeeder/StatsFeeder.sh',
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/statsfeeder/opt/statsfeeder/StatsFeeder.sh',
    require => Exec['expand_statsfeeder'],
  }

  service { 'statsfeeder':
    ensure    => running,
    enable    => true,
    subscribe => File[[
        'statsfeeder-service',
        'statsfeeder-runner',
        'statsfeeder-default',
        'statsfeeder-config',
        'statsfeeder-logging'
      ]],
  }
}
