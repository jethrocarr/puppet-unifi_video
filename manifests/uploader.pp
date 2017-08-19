# Deploys a Java application which subscribes to changes in the MongoDB
# database used by UniFi Video and uploads the video files into Amazon S3.

class unifi_video::uploader (
  $uploader_dir          = '/opt/unifi-video-s3uploader',
  $uploader_user         = 'unifiuploader',
  $uploader_group        = 'unifiuploader',
  $uploader_git_repo     = 'https://github.com/jethrocarr/unifi-video-s3uploader.git',
  $java_binary           = '/usr/bin/java',
  $java_heap_mb          = '128',
  $aws_access_key_id     = undef,
  $aws_secret_access_key = undef,
  $aws_region            = 'us-east-1',
  $s3_bucket             = undef,
  $unifi_api_key         = undef,
  ) {

  # We only support systemd
  $init_system = $::initsystem

  if (!$init_system) {
    fail('Install the jethrocarr/initfact module to provide identification of the init system being used. Required to make this module work.')
  }

  if ($init_system != 'systemd') {
    fail('The Unifi Video S3 Uploader only supports systemd')
  }

  # Going to need Git for this
  ensure_packages(['git'])

  # systemd needs a reload after any unit files are changed, we setup a handy
  # exec here.
  exec { 'uploader_reload_systemd':
    command     => 'systemctl daemon-reload',
    path        => ["/bin", "/sbin", "/usr/bin", "/usr/sbin"],
    refreshonly => true,
  }

  # Create a system user/group for the uploader
  group { $uploader_group:
    ensure => present,
    system => true,
  } ->
  user { $uploader_user:
    ensure  => present,
    gid     => $uploader_group,
    home    => $uploader_dir,
    system  => true,
    shell   => '/usr/sbin/nologin',
  } ->


  # Download and build the application
  file { 'uploader_dir':
    ensure => directory,
    name   => $uploader_dir,
    owner  => $uploader_user,
    group  => $uploader_group,
    mode   => '0700',
  }

  vcsrepo { 'uploader_code':
    ensure   => latest,
    provider => 'git',
    path     => $uploader_dir,
    source   => $uploader_git_repo,
    revision => 'master',
    notify   => Exec['build_uploader_code'], # Trigger build upon update
    require  => [
      Package['git'],
      File['uploader_dir'],
    ]
  }

  exec { "build_uploader_code":
    command     => "rm -f build/libs/latest.jar && ./gradlew bootRepackage && ln `find build -name '*.jar' | tail -n1` build/libs/latest.jar",
    notify      => Service['uploader_service'],
    cwd         => $uploader_dir,
    provider    => "shell",
    refreshonly => true,
  }


  # Create systemd file and launch service.
  file { "init_uploader_server":
    ensure   => file,
    mode     => '0644',
    path     => "/etc/systemd/system/unifi-video-s3-uploader.service",
    content  => template('unifi_video/systemd-unifi-video-s3-uploader.service.erb'),
    notify   => [
      Exec['uploader_reload_systemd'],
      Service["uploader_service"],
    ]
  }

  service { "uploader_service":
    name    => 'unifi-video-s3-uploader',
    ensure  => running,
    enable  => true,
    require => [
     Exec['uploader_reload_systemd'],
     File["init_uploader_server"],
     Vcsrepo['uploader_code'],
    ],


  }

}
