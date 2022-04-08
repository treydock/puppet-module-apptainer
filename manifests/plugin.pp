# @summary Manage Apptainer plugin
#
# @example install log plugin
#
#   apptainer::plugin { 'github.com/apptainer/apptainer/log-plugin':
#     source_dir => 'examples/plugins/log-plugin',
#   }
#
# @param source_dir
#   The plugin source directory
#   This path must be relative to Apptainer source directory `$apptainer::install::source::source_dir`
# @param ensure
#   Whether to install (present) or uninstall (absent) the plugin
# @param sif_name
#   The name of the SIF image to use for install after the plugin is compiled.
#   The default is to use part after last `/` in the plugin name so
#   plugin `examples/plugins/log-plugin` will have SIF name of `log-plugin.sif`.
#
define apptainer::plugin (
  Enum['present', 'absent'] $ensure = 'present',
  Optional[String] $source_dir = undef,
  Optional[String] $sif_name = undef,
) {
  include apptainer

  if $apptainer::install_method != 'source' {
    fail("Define apptainer::plugin ${name} can only be done for source installation")
  }

  if $ensure == 'present' and $source_dir =~ Undef {
    fail("Define apptainer::plugin ${name} must define source_dir")
  }

  $exec_path = "${apptainer::prefix}/bin:${apptainer::source_exec_path}"

  if $ensure == 'present' {
    $basename = split($name, '/')[-1]
    $_sif_name = pick($sif_name, "${basename}.sif")
    $sif_path = "${apptainer::install::source::source_dir}/${source_dir}/${_sif_name}"

    if $apptainer::manage_go and $apptainer::rebuild_on_go {
      Class['golang'] ~> Exec["apptainer-plugin-recompile-${name}"]
    }

    exec { "apptainer-plugin-compile-${name}":
      path        => $exec_path,
      environment => $apptainer::install::source::build_env,
      command     => "apptainer plugin compile ${source_dir}",
      cwd         => $apptainer::install::source::source_dir,
      creates     => $sif_path,
      require     => Class['apptainer::install::source'],
    }

    exec { "apptainer-plugin-recompile-${name}":
      path        => $exec_path,
      environment => $apptainer::install::source::build_env,
      command     => "apptainer plugin compile ${source_dir}",
      cwd         => $apptainer::install::source::source_dir,
      onlyif      => "test -f ${sif_path}",
      refreshonly => true,
      require     => Class['apptainer::install::source'],
      notify      => Exec["apptainer-plugin-reinstall-${name}"],
    }

    exec { "apptainer-plugin-install-${name}":
      path    => $exec_path,
      command => "apptainer plugin install ${sif_path}",
      unless  => "apptainer plugin list | grep '${name}'",
      require => Exec["apptainer-plugin-compile-${name}"],
    }

    exec { "apptainer-plugin-reinstall-${name}":
      path        => $exec_path,
      command     => "apptainer plugin install ${sif_path}",
      onlyif      => "apptainer plugin list | grep '${name}'",
      refreshonly => true,
      subscribe   => Exec["apptainer-plugin-compile-${name}"],
    }

    exec { "apptainer-plugin-enable-${name}":
      path    => $exec_path,
      command => "apptainer plugin enable ${name}",
      unless  => "apptainer plugin list | grep '${name}' | grep yes",
      require => [
        Exec["apptainer-plugin-install-${name}"],
        Exec["apptainer-plugin-reinstall-${name}"],
      ],
    }
  } else {
    exec { "apptainer-plugin-uninstall-${name}":
      path    => $exec_path,
      command => "apptainer plugin uninstall ${name}",
      onlyif  => "apptainer plugin list | grep '${name}'",
    }
  }

}