# @summary Private class
# @api private
class apptainer::singularity {
  assert_private()

  if $apptainer::install_method == 'source' {
    file { '/etc/bash_completion.d/singularity':
      ensure => 'absent',
    }
    file { '/etc/singularity':
      ensure  => 'absent',
      purge   => true,
      recurse => true,
      force   => true,
    }
    -> file { '/usr/local/sbin/singularity-mconfig.sh':
      ensure => 'absent',
    }
    -> file { '/usr/bin/run-singularity':
      ensure => 'absent',
    }
    -> file { '/usr/libexec/singularity':
      ensure  => 'absent',
      purge   => true,
      recurse => true,
      force   => true,
    }
    -> file { '/var/singularity':
      ensure  => 'absent',
      purge   => true,
      recurse => true,
      force   => true,
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
}
