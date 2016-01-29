# == Class: zookeeper
#
# Minimal recipe that uses a docker registry to deploy and run zookeeper.
# Only systemd based systems are currently supported.
#
# === Parameters
#
# [*version*]
#   The container version (e.g. `v2.0.3`)
# [*registry*]
#   The docker registry uri or path (e.g. `quay.io/coreos/zookeeper`)
# [*docker_path*]
#   The path ot the docker binary on the host.
# [*service_enable*]
#   Whether this service should be enabled
# [*service_ensure*]
#   The desired service state (e.g. `running`)
#
#
# === Examples
#
#  class { 'zookeeper':
#    version => 'v2.0.3',
#  }
#
# === Authors
#
# Cosmin Lehene <clehene@adobe.com>
#
# === Copyright
#
# Copyright 2015 Cosmin Lehene
#
class zookeeper (
  $cluster_id            = "zk-1",
  $version               = "latest",
  $registry              = "cellos/zookeeper-exhibitor",
  $docker_path           = "/bin/docker",
  # AWS
  $aws_access_key_id     = undef,
  $aws_secret_access_key = undef,
  $aws_s3_bucket         = undef,
  $aws_s3_prefix         = undef,
  $aws_s3_region         = undef,
  # local
  $fs_config_dir_host    = undef,

  $hostname              = $::hostname,
  $service_enable        = "true",
  $service_ensure        = "running",
  $host_data_dir         = "/var/zookeeper"
) {

  $container_id          = "zookeeper"
  $directories = [$host_data_dir, "$host_data_dir/transactions", "$host_data_dir/snapshots"]

  include docker
  Class['zookeeper'] <- Class['docker']
  file { $directories:
    backup  => false,
    ensure  => directory,
    owner   => "root",
    group   => "root",
    mode    => '0744'
  } -> 
  file { '/etc/systemd/system/zookeeper.service':
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('zookeeper/zookeeper.service.erb'),
  } ->   
  exec { 'reload-zookeeper-service':
    command => 'systemctl daemon-reload'
  } ->
  service { 'zookeeper':
    ensure  => $service_ensure,
    enable  => $service_enable
  }
 
}
