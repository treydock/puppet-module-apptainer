# @summary Private class
# @api private
class apptainer::install::package {
  assert_private()

  if $facts['os']['family'] == 'RedHat' {
    $provider = 'rpm'
    $source = "https://github.com/apptainer/apptainer/releases/download/v${apptainer::version}/apptainer-${apptainer::version}-1.x86_64.rpm"
  } else {
    fail('Module apptainer only supports package installs on RedHat or Debian os family')
  }

  package { 'apptainer':
    ensure   => 'latest',
    name     => $apptainer::package_name,
    provider => $provider,
    source   => $source,
  }
}
