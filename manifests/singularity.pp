# @summary Private class
# @api private
class apptainer::singularity {
  assert_private()

  file { '/etc/singularity':
    ensure  => 'absent',
    purge   => true,
    recurse => true,
    force   => true,
  }
  -> file { '/usr/local/sbin/singularity-mconfig.sh':
    ensure => 'absent',
  }
  -> file { '/opt/singularity':
    ensure  => 'absent',
    purge   => true,
    recurse => true,
    force   => true,
  }
  ~> exec { 'rm-singularity-source':
    path        => '/usr/bin:/bin:/usr/sbin:/sbin',
    command     => 'rm -rf /opt/singularity-3*',
    refreshonly => true,
  }
}