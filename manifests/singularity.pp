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
}
