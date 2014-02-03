class exiscan::greylist_db (
  $db_type        = postgres,
  $exim_ipaddress = '127.0.0.1',
  $db_name        = 'greylist',
  $db_username    = 'Debian-exim',
  $db_password,) {
  validate_re($db_type, '^postgres$')

  $runtime_user = $db_username

  case $db_type {
    'postgres' : {
      postgresql::dbcreate { $db_name:
        role     => $db_username,
        password => $db_password,
        address  => "${exim_ipaddress}/32",
        encoding => 'UTF8',
        locale   => 'en_US.UTF-8',
        template => "template0";
      }

      file {
        "/var/lib/greylist-dbimport":
          ensure => directory,
          mode   => 0700,
          owner  => $runtime_user;

        'greylist_initial.sql':
          ensure => present,
          path   => '/var/lib/greylist-dbimport/greylist_initial.sql',
          owner  => root,
          group  => root,
          mode   => 644,
          source => 'puppet:///modules/exiscan/greylist/postgres/greylist_initial.sql',
      }

      postgresql::import { 'greylist_initial':
        source_url      => 'file:///var/lib/greylist-dbimport/greylist_initial.sql',
        database        => $db_name,
        extract_command => false,
        user            => $runtime_user,
        log             => "/var/lib/greylist-dbimport/log",
        errorlog        => "/var/lib/greylist-dbimport/errorlog",
        flagfile        => "/var/lib/greylist-dbimport/flagfile",
        require         => [File['greylist_initial.sql'], Postgresql::Dbcreate[$db_name]],
      }
    }
  }
}
