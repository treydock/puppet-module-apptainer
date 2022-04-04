# @summary Manage Apptainer
#
# @example
#   include ::apptainer
#
# @param install_method
#   Sets how Apptainer will be installed
# @param version
#   Version of Apptainer to install
# @param remove_singularity
#   Set whether to remove Singularity before installing Apptainer
# @param package_name
#   Apptainer package name
#   Only used when install_method=package
# @param source_dependencies
#   Packages needed to build from source
#   Only used when install_method=source
# @param manage_go
#   Sets if golang module should be included
#   Only used when install_method=source
# @param rebuild_on_go
#   Sets if Apptainer should be rebuilt on updates to Go via golang module
#   Only used when install_method=source and manage_go=true
# @param source_base_dir
#   Base directory of where Apptainer source will be extracted
#   Only used when install_method=source
# @param source_mconfig_path
#   Path to source install mconfig script
# @param build_flags
#   Build flags to pass to mconfig when building Apptainer
#   Only used when install_method=source
# @param build_env
#   Environment variables to use when building from source
#   Only used when install_method=source
# @param prefix
#   The --prefix value when building from source
#   Only used when install_method=source
# @param localstatedir
#   The --localstatedir value when building from source
#   Only used when install_method=source
# @param sysconfdir
#   The --sysconfdir value when building from source
#   Only used when install_method=source
# @param source_exec_path
#   Set PATH when building from source
#   Only used when install_method=source
# @param plugins
#   Hash to define apptainer::plugin resources
# @param config_path
#   Path to apptainer.conf
# @param config_template
#   Template used for apptainer.conf
# @param allow_setuid
#   See apptainer.conf: `allow setuid`
# @param max_loop_devices
#   See apptainer.conf: `max loop devices`
# @param allow_pid_ns
#   See apptainer.conf: `allow pid ns`
# @param config_passwd
#   See apptainer.conf: `config passwd`
# @param config_group
#   See apptainer.conf: `config group`
# @param config_resolv_conf
#   See apptainer.conf: `config resolv conf`
# @param mount_proc
#   See apptainer.conf: `mount proc`
# @param mount_sys
#   See apptainer.conf: `mount sys`
# @param mount_dev
#   See apptainer.conf: `mount dev`
# @param mount_devpts
#   See apptainer.conf: `mount devpts`
# @param mount_home
#   See apptainer.conf: `mount home`
# @param mount_tmp
#   See apptainer.conf: `mount tmp`
# @param mount_hostfs
#   See apptainer.conf: `mount hostfs`
# @param bind_paths
#   See apptainer.conf: `bind paths`
# @param user_bind_control
#   See apptainer.conf: `user bind control`
# @param enable_fusemount
#   See apptainer.conf: `enable fusemount`
# @param enable_overlay
#   See apptainer.conf: `enable overlay`
# @param enable_underlay
#   See apptainer.conf: `enable underlay`
# @param mount_slave
#   See apptainer.conf: `mount slave`
# @param sessiondir_max_size
#   See apptainer.conf: `sessiondir max size`
# @param limit_container_owners
#   See apptainer.conf: `limit container owners`
# @param limit_container_groups
#   See apptainer.conf: `limit container groups`
# @param limit_container_paths
#   See apptainer.conf: `limit container paths`
# @param allow_containers
#   See apptainer.conf: `allow containers`
# @param allow_net_users
#   See apptainer.conf: `allow net users`
# @param allow_net_groups
#   See apptainer.conf: `allow net groups`
# @param allow_net_networks
#   See apptainer.conf: `allow net networks`
# @param always_use_nv
#   See apptainer.conf: `always use nv`
# @param use_nvidia_container_cli
#   See apptainer.conf: `use nvidia-container-cli`
# @param always_use_rocm
#   See apptainer.conf: `always use rocm`
# @param root_default_capabilities
#   See apptainer.conf: `root default capabilities`
# @param memory_fs_type
#   See apptainer.conf: `memory fs type`
# @param cni_configuration_path
#   See apptainer.conf: `cni configuration path`
# @param cni_plugin_path
#   See apptainer.conf: `cni plugin path`
# @param cryptsetup_path
#   See apptainer.conf: `cryptsetup path`
# @param go_path
#   See apptainer.conf: `go path`
# @param ldconfig_path
#   See apptainer.conf: `ldconfig path`
# @param mksquashfs_path
#   See apptainer.conf: `mksquashfs path`
# @param mksquashfs_procs
#   See apptainer.conf: `mksquashfs procs`
# @param mksquashfs_mem
#   See apptainer.conf: `mksquashfs mem`
# @param nvidia_container_cli_path
#   See apptainer.conf: `nvidia-container-cli path`
# @param unsquashfs_path
#   See apptainer.conf: `unsquashfs path`
# @param shared_loop_devices
#   See apptainer.conf: `shared loop devices`
# @param image_driver
#   See apptainer.conf: `image driver`
# @param download_concurrency
#   See apptainer.conf: `download concurrency`
# @param download_part_size
#   See apptainer.conf: `download part size`
# @param download_buffer_size
#   See apptainer.conf: `download buffer size`
# @param namespace_users
#   List of uses to add to /etc/subuid and /etc/subgid to support user namespaces
# @param namespace_begin_id
#  The beginning ID for /etc/subuid and /etc/subgid. The value is incremented
#  For each user by start + namespace_id_range + 1
# @param namespace_id_range
#   The range of UIDs/GIDs usable by a user in namespaces
# @param subid_template
#   The template to use for /etc/subuid and /etc/subgid
#
class apptainer (
  Enum['package','source'] $install_method = 'package',
  String $version = '1.0.1',
  Boolean $remove_singularity = false,
  # Package install
  String $package_name = 'apptainer',
  # Source install
  Array $source_dependencies = [],
  Boolean $manage_go = true,
  Boolean $rebuild_on_go = true,
  Stdlib::Absolutepath $source_base_dir = '/opt',
  Stdlib::Absolutepath $source_mconfig_path = '/usr/local/sbin/apptainer-mconfig.sh',
  Hash $build_flags = {},
  Hash $build_env = {},
  Stdlib::Absolutepath $prefix = '/usr',
  Stdlib::Absolutepath $localstatedir = '/var',
  Stdlib::Absolutepath $sysconfdir = '/etc',
  String $source_exec_path = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
  Hash $plugins = {},
  # Config
  Stdlib::Absolutepath $config_path = '/etc/apptainer/apptainer.conf',
  String $config_template = 'apptainer/apptainer.conf.erb',
  Enum['yes','no'] $allow_setuid  = 'yes',
  Integer $max_loop_devices = 256,
  Enum['yes','no'] $allow_pid_ns = 'yes',
  Enum['yes','no'] $config_passwd = 'yes',
  Enum['yes','no'] $config_group = 'yes',
  Enum['yes','no'] $config_resolv_conf = 'yes',
  Enum['yes','no'] $mount_proc = 'yes',
  Enum['yes','no'] $mount_sys = 'yes',
  Enum['yes','no'] $mount_dev = 'yes',
  Enum['yes','no'] $mount_devpts = 'yes',
  Enum['yes','no'] $mount_home = 'yes',
  Enum['yes','no'] $mount_tmp = 'yes',
  Enum['yes','no'] $mount_hostfs = 'no',
  Array[Stdlib::Absolutepath] $bind_paths = ['/etc/localtime', '/etc/hosts'],
  Enum['yes','no'] $user_bind_control = 'yes',
  Enum['yes','no'] $enable_fusemount = 'yes',
  Enum['yes','no','try'] $enable_overlay = 'try',
  Enum['yes','no','try','driver'] $enable_underlay = 'yes',
  Enum['yes','no'] $mount_slave = 'yes',
  Integer $sessiondir_max_size = 16,
  Optional[Array] $limit_container_owners = undef,
  Optional[Array] $limit_container_groups = undef,
  Optional[Array] $limit_container_paths = undef,
  Hash[String,Enum['yes','no']] $allow_containers = {
    'sif' => 'yes',
    'encrypted' => 'yes',
    'squashfs' => 'yes',
    'extfs' => 'yes',
    'dir' => 'yes',
  },
  Array $allow_net_users = [],
  Array $allow_net_groups = [],
  Array $allow_net_networks = [],
  Enum['yes','no'] $always_use_nv = 'no',
  Enum['yes','no'] $use_nvidia_container_cli = 'no',
  Enum['yes','no'] $always_use_rocm = 'no',
  Enum['full','file','default','no'] $root_default_capabilities = 'full',
  Enum['tmpfs','ramfs'] $memory_fs_type = 'tmpfs',
  Optional[Stdlib::Absolutepath] $cni_configuration_path = undef,
  Optional[Stdlib::Absolutepath] $cni_plugin_path = undef,
  Optional[Stdlib::Absolutepath] $cryptsetup_path = undef,
  Optional[Stdlib::Absolutepath] $go_path = undef,
  Optional[Stdlib::Absolutepath] $ldconfig_path = undef,
  Optional[Stdlib::Absolutepath] $mksquashfs_path = undef,
  Integer[0,default] $mksquashfs_procs = 0,
  Optional[String[1]] $mksquashfs_mem = undef,
  Optional[Stdlib::Absolutepath] $nvidia_container_cli_path = undef,
  Optional[Stdlib::Absolutepath] $unsquashfs_path = undef,
  Enum['yes','no'] $shared_loop_devices = 'no',
  Optional[String] $image_driver = undef,
  Integer[0,default] $download_concurrency = 3,
  Integer[0,default] $download_part_size = 5242880,
  Integer[0,default] $download_buffer_size = 32768,
  Array $namespace_users = [],
  Integer $namespace_begin_id = 65537,
  Integer $namespace_id_range = 65536,
  String $subid_template = 'apptainer/subid.erb',
) {

  contain "apptainer::install::${install_method}"
  contain apptainer::config

  Class["apptainer::install::${install_method}"]
  ->Class['apptainer::config']

  if $remove_singularity {
    contain apptainer::singularity
    Class['apptainer::singularity'] -> Class["apptainer::install::${install_method}"]
  }

  $plugins.each |$name, $plugin| {
    apptainer::plugin { $name: * => $plugin }
  }
}
