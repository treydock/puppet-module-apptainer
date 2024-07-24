# @summary Private class
# @api private
class apptainer::config {
  assert_private()

  file { 'apptainer.conf':
    ensure  => 'file',
    path    => $apptainer::config_path,
    content => template($apptainer::config_template),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  if ! empty($apptainer::namespace_users) {
    file { '/etc/subuid':
      ensure  => 'file',
      content => template($apptainer::subid_template),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }
    file { '/etc/subgid':
      ensure  => 'file',
      content => template($apptainer::subid_template),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }
  }
}
