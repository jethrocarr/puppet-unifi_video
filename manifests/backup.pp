# Easily backup the unifi video data from the local server to a remote Amazon
# S3 bucket.
#
# TODO: Patches to support other stores welcome - ideally the type should be
#       detected based on the $target value.

class unifi_video::backup (
  $source                = '/var/lib/unifi-video/videos',
  $target                = undef,
  $aws_access_key_id     = undef,
  $aws_secret_access_key = undef
  ) {

  if ($target == undef) {
    fail('A unifi_video::backup::target must be set, eg "s3://bucket/path/"')
  }

  # We need the AWS CLI to be installed. We use ensure_resource to avoid any
  # issues if double-defined by other modules on this system.
  ensure_resource('package', ['python-pip'], {'ensure' => 'installed'})

  ensure_resource('package', ['awscli'], {
    'ensure'   => 'installed',
    'provider' => 'pip',
    'require'  => Package['python-pip']
    })


  # We use thias/lsyncd to do most of the lsyncd lifting - we just point
  # it to our own configuration file which configures lsyncd to use the
  # AWS S3 cli.

  # TODO: Happy to accept a PR for anything like a proper native lsyncd
  # S3 integration.

  class { 'lsyncd':
    config_content => template('unifi_video/lsyncd-s3.conf.erb'),
    require        => Package['awscli'],
  }

  
}
# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
