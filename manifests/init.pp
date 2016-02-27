# Installs the Ubiquity UniFi video survillence software.
class unifi_video (
  $app_version = '3.1.2'
  ) {

  Exec {
    path => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
  }
  

  # Ubiquity's packaging is a bit of a PITA, they package their software as debs
  # without APT repos and naming isn't always consistent (eg sometimes the
  # Ubuntu package is "Debian", sometimes it's "Ubuntu". Only stable releases
  # are supported, however happy to merge PRs for other versions IF it's tested
  # and the software works.

  if ($::operatingsystem == 'Ubuntu') {
    if ($::operatingsystemrelease == '12.04') {
      $download_url = "https://dl.ubnt.com/firmwares/unifi-video/${app_version}/unifi-video_${app_version}-Debian7_amd64.deb"
    }
    if ($::operatingsystemrelease == '12.04') {
      $download_url = "https://dl.ubnt.com/firmwares/unifi-video/${app_version}/unifi-video_${app_version}-Ubuntu14.04_amd64.deb"
    }
  }
  if ($::operatingsystem == 'Debian') {
    if ($::operatingsystemrelease == '7') {
      $download_url = "https://dl.ubnt.com/firmwares/unifi-video/${app_version}/unifi-video_${app_version}-Debian7_amd64.deb"
     }
  }
  if ($download_url == "") {
    # If we didn't get set, we aren't supported.
    fail('unifi_video does not support this platform')
  }


  # Download and install the software.
  # TODO: Non-portable - Debian/Ubuntu Specific.
  exec { 'unifi_video_download':
    creates   => "/tmp/unifi-video-${app_version}.deb",
    command   => "wget -nv ${download_url} -O /tmp/unifi-video-${app_version}.deb",
    unless    => "dpkg -s unifi-video | grep -q \"Version: ${app_version}\"", # Download new version if not already installed.
    logoutput => true,
    notify    => Exec['unifi_video_install'],
  }

  exec { 'unifi_video_install':
    # Ideally we'd use "apt-get install package.deb" but this only become
    # available in apt 1.1 and later. Hence we do a bit of a hack, which is
    # to install the deb and then fix the deps with apt-get -y -f install.
    # TODO: When Ubuntu 16.04 is out, check if we can migrate to the better approach
    command     => "bash -c 'dpkg -i /tmp/unifi-video-${app_version}.deb; apt-get -y -f install'",
    require     => Exec['unifi_video_download'],
    logoutput   => true,
    refreshonly => true,
  }

}
# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
