# @summary Private class
# @api private
class apptainer::install::source {
  assert_private()

  if $apptainer::manage_go {
    include golang
    if $apptainer::rebuild_on_go {
      Class['golang'] ~> Exec['apptainer-mconfig']
    } else {
      Class['golang'] -> Exec['apptainer-mconfig']
    }
  }
  stdlib::ensure_packages($apptainer::source_dependencies)
  $apptainer::source_dependencies.each |$package| {
    Package[$package] -> Exec['apptainer-mconfig']
  }

  $source_dir = "${apptainer::source_base_dir}/apptainer-${apptainer::version}"
  if $apptainer::install_setuid {
    $setuid_flags = {
      'with-suid' => true,
    }
  } else {
    $setuid_flags = {}
  }
  $base_build_flags = {
    'prefix' => $apptainer::prefix,
    'localstatedir' => $apptainer::localstatedir,
    'sysconfdir' => $apptainer::sysconfdir,
  }
  $build_flags_mapped = ($base_build_flags + $setuid_flags + $apptainer::build_flags).map |$key, $value| {
    if $value == '' or $value =~ Boolean {
      "--${key}"
    } else {
      "--${key}=${value}"
    }
  }
  $build_flags = join($build_flags_mapped, ' ')
  $base_build_env = {
    'HOME' => '/root',
  }
  $build_env = ($base_build_env + $apptainer::build_env).map |$key, $value| { "${key}=${value}" }

  file { 'apptainer-mconfig':
    ensure  => 'file',
    path    => $apptainer::source_mconfig_path,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => join([
        '#!/bin/bash',
        '# File managed by Puppet, do not edit',
        "cd ${source_dir}",
        "./mconfig ${build_flags}",
        '',
    ], "\n"),
  }

  file { $source_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  -> archive { 'apptainer-source':
    path            => "/tmp/apptainer-${apptainer::version}.tar.gz",
    source          => "https://github.com/apptainer/apptainer/releases/download/v${apptainer::version}/apptainer-${apptainer::version}.tar.gz",
    extract         => true,
    extract_path    => $source_dir,
    extract_command => 'tar xfz %s --strip-components=1',
    creates         => "${source_dir}/mconfig",
    cleanup         => true,
    user            => 'root',
    group           => 'root',
    notify          => Exec['apptainer-mconfig'],
  }
  exec { 'apptainer-mconfig':
    path        => $apptainer::source_exec_path,
    environment => $build_env,
    command     => $apptainer::source_mconfig_path,
    cwd         => $source_dir,
    refreshonly => true,
    subscribe   => File['apptainer-mconfig'],
  }
  ~> exec { 'apptainer-make':
    path        => $apptainer::source_exec_path,
    environment => $build_env,
    command     => 'make -C ./builddir',
    cwd         => $source_dir,
    refreshonly => true,
  }
  ~> exec { 'apptainer-make-install':
    path        => $apptainer::source_exec_path,
    environment => $build_env,
    command     => 'make -C ./builddir install',
    cwd         => $source_dir,
    refreshonly => true,
  }
}
