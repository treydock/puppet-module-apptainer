# @summary Private class
# @api private
class apptainer::singularity {
  assert_private()

  if $apptainer::install_method == 'source' {
    file { '/usr/bin/singularity': ensure => 'absent' }
    file { '/bin/singularity': ensure => 'absent' }
  }

  file { '/etc/singularity':
    ensure  => 'absent',
    purge   => true,
    recurse => true,
    force   => true,
  }
}
