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
  $registry              = "mbabineau/zookeeper-exhibitor",
  $docker_path           = "/bin/docker",
  # AWS
  $aws_access_key_id     = undef,
  $aws_secret_access_key = undef,
  $aws_s3_bucket         = "zk-1",
  $aws_s3_prefix         = "zk-1",
  $aws_s3_region         = undef,

  $hostname              = $::hostname,
  $service_enable        = "true",
  $service_ensure        = "running",
) {

  $container_id          = "zk_${cluster_id}"

  include docker
  Class['zookeeper'] <- Class['docker']
  file { '/etc/systemd/system/zookeeper.service':
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('zookeeper/zookeeper.service.erb'),
  } ->   
  exec { 'reload-zookeeper_docker-service':
    command => 'systemctl daemon-reload'
  } ->
  service { 'zookeeper':
    ensure  => $service_ensure,
    enable  => $service_enable
  }
 
}
