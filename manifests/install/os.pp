# @summary Private class
# @api private
class apptainer::install::os {
  assert_private()

  if $facts['os']['family'] == 'RedHat' {

    package { 'apptainer':
      ensure => $apptainer::version,
    }

    $_suid_ensure = $apptainer::install_setuid ? {
      true    => $apptainer::version,
      default => 'absent',
    }

    package { 'apptainer-suid':
      ensure => $_suid_ensure,
    }

  } else {
    fail('Module apptainer only supports os installs on RedHat')
  }
}
