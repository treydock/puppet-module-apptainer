# @summary Private class
# @api private
class apptainer::install::package {
  assert_private()

  if $facts['os']['family'] == 'RedHat' {
    $source = "https://github.com/apptainer/apptainer/releases/download/v${apptainer::version}/apptainer-${apptainer::version}-1.x86_64.rpm"
    if $facts['apptainer_version'] {
      if versioncmp($apptainer::version, $facts['apptainer_version']) < 0 {
        $action = 'downgrade'
      } else {
        $action = 'install'
      }
    } else {
      $action = 'install'
    }
    exec { "${action}-apptainer":
      path    => '/usr/bin:/bin:/usr/sbin:/sbin',
      command => "${facts['package_provider']} ${action} -y ${source}",
      unless  => "rpm -q 'apptainer-${apptainer::version}'",
    }
  } else {
    fail('Module apptainer only supports package installs on RedHat or Debian os family')
  }
}
