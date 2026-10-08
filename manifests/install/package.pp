# @summary Private class
# @api private
class apptainer::install::package {
  assert_private()

  if $facts['os']['family'] == 'RedHat' {
    if versioncmp($facts['os']['release']['major'], '10') >= 0 {
      $source_suffix = '-1.el10.x86_64.rpm'
    } else {
      $source_suffix = '-1.x86_64.rpm'
    }
    $source = "https://github.com/apptainer/apptainer/releases/download/v${apptainer::version}/apptainer-${apptainer::version}${source_suffix}"
    $source_suid = "https://github.com/apptainer/apptainer/releases/download/v${apptainer::version}/apptainer-suid-${apptainer::version}${source_suffix}"
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
    if $apptainer::install_setuid {
      exec { "${action}-apptainer-suid":
        path    => '/usr/bin:/bin:/usr/sbin:/sbin',
        command => "${facts['package_provider']} ${action} -y ${source_suid}",
        unless  => "rpm -q 'apptainer-suid-${apptainer::version}'",
      }
    }
  } elsif $facts['os']['family'] == 'Debian' {
    if $facts['os']['name'] == 'Debian' and versioncmp($facts['os']['release']['major'], '13') >= 0 {
      $source_suffix = '-trixie+_amd64.deb'
    } elsif $facts['os']['name'] == 'Ubuntu' and versioncmp($facts['os']['release']['major'], '26.04') >= 0 {
      $source_suffix = '-trixie+_amd64.deb'
    } else {
      $source_suffix = '_amd64.deb'
    }
    $source = "https://github.com/apptainer/apptainer/releases/download/v${apptainer::version}/apptainer_${apptainer::version}${source_suffix}"
    $source_path = "/usr/local/src/apptainer_${apptainer::version}${source_suffix}"
    $source_suid = "https://github.com/apptainer/apptainer/releases/download/v${apptainer::version}/apptainer-suid_${apptainer::version}${source_suffix}"
    $source_suid_path = "/usr/local/src/apptainer-suid_${apptainer::version}${source_suffix}"
    archive { $source_path:
      source  => $source,
      extract => false,
      cleanup => false,
      user    => 'root',
      group   => 'root',
    }
    exec { 'install-apptainer':
      path        => '/usr/bin:/bin:/usr/sbin:/sbin',
      command     => "apt install -y -o Dpkg::Options::=\"--force-confnew\" ${source_path}",
      environment => [
        'DEBIAN_FRONTEND=noninteractive',
      ],
      unless      => "dpkg -s apptainer | grep 'Version: ${apptainer::version}'",
    }
    if $apptainer::install_setuid {
      archive { $source_suid_path:
        source  => $source_suid,
        extract => false,
        cleanup => false,
        user    => 'root',
        group   => 'root',
      }
      exec { 'install-apptainer-suid':
        path        => '/usr/bin:/bin:/usr/sbin:/sbin',
        command     => "apt install --force-yes -y ${source_suid_path}",
        environment => [
          'DEBIAN_FRONTEND=noninteractive',
        ],
        unless      => "dpkg -s apptainer-suid | grep 'Version: ${apptainer::version}'",
      }
    }
  } else {
    fail('Module apptainer only supports package installs on RedHat or Debian os family')
  }
}
