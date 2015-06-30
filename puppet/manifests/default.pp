Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/', '/usr/local/bin' ]}
File { owner => 0, group => 0, mode => 0644}

stage { 'pre':
  before => Stage['main'],
}

class { 'yum':
  extrarepo => [ 'epel' , 'remi' ],
  stage => 'pre',
}

package {[ 'mod_fcgid', 'php56', 'php56-php-pecl-xhprof', 'php56-php-pecl-xdebug', 'php56-php-pecl-mongo',
  'php56-php-mcrypt'
]:
  ensure  => 'installed',
  require => [ File['/etc/yum.repos.d/epel.repo'], File['/etc/yum.repos.d/remi.repo'] ]
}

class { 'ohmyzsh': }
ohmyzsh::install { ['root', 'vagrant']: }
ohmyzsh::theme { ['root', 'vagrant']: theme => 'avit' }
ohmyzsh::plugins { 'root': plugins => 'git composer colorize rsync' }
ohmyzsh::plugins { 'vagrant': plugins => 'git composer colorize rsync' }

class {'::mongodb::server':
  auth => true,
}
class {'::mongodb::client':}

mongodb::db { 'xhprof':
  user     => 'xhprof',
  password => 'xhprof',
}

class { 'apache': }
class { 'apache::mod::fcgid':
  options => {
    'AddHandler' => 'fcgid-script .php',
  },
}

apache::vhost { 'profiler.move-elevator.dev':
  port => '80',
  docroot => '/var/www/profiler',
  directories => {
    path => '/var/www/profiler',
    options => ['ExecCGI', 'FollowSymLinks'],
    fcgiwrapper => {
      command => '/usr/bin/php56-cgi',
    }
  },
  require => Package['mod_fcgid', 'php56']
}

apache::vhost { 'xhgui.move-elevator.dev':
  port => '80',
  docroot => '/var/www/xhgui-0.4.0/webroot',
  directories => {
    path => '/var/www/xhgui-0.4.0',
    options => ['ExecCGI', 'FollowSymLinks'],
    fcgiwrapper => {
      command => '/usr/bin/php56-cgi',
    }
  },
  require => [ Package['mod_fcgid', 'php56'], Exec['untar-xhgui'] ]
}

file { '/var/log/httpd':
  mode => 755,
  require => Package['httpd']
}

exec { 'open-port-80':
  command => 'iptables -I INPUT 1 -i eth1 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT'
}

exec { 'untar-xhgui':
  command => 'tar -xzf /vagrant/files/xhgui/xhgui-0.4.0.tar.gz -C /var/www',
  creates => '/var/www/xhgui-0.4.0'
}

file { '/var/www/xhgui-0.4.0/external/header.php':
  source => '/vagrant/files/xhgui/header.php',
  require => Exec['untar-xhgui']
}

file { '/var/www/xhgui-0.4.0/config/config.php':
  source => '/vagrant/files/xhgui/config.php',
  require => Exec['untar-xhgui']
}

exec { 'install-composer':
  command => 'curl -sS https://getcomposer.org/installer | php56',
  cwd => '/usr/bin',
  user => 'root',
  group => 'root',
  creates => '/usr/bin/composer.phar',
  require => Package['php56']
}

exec { 'xhgui-composer-update':
  command => 'php56 /usr/bin/composer.phar update',
  user => 'root',
  group => 'root',
  environment => ['COMPOSER_HOME=/root/.composer'],
  cwd => '/var/www/xhgui-0.4.0',
  creates => '/var/www/xhgui-0.4.0/vendor',
  require => [ Exec['install-composer'], Exec['untar-xhgui'] ]
}

file { "/opt/remi/php56/root/etc/php.d/99-overwrites.ini":
  source => "/vagrant/files/99-overwrites.ini",
  require => Package["php56"]
}