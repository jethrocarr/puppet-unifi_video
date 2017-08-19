# puppet-unifi_video

## Overview

Provisions the Unifi Video software provided by Ubiquiti for use with their
IP-based video survelliance products.


## Configuration

Currently this module is limited to installed a specific version of the server:

    class { '::unifi_video':
      app_version => '3.1.2', # pin specific version
    }

If left unset, `app_version` will be updated semi-frequently to the latest
version offered by Ubiquiti. If this isn't something you'd like, please pin
the version either using the syntax above, or by using Hiera.

This module does not configure any kind of firewall, it is *strongly*
recommended that you firewall this system heavily.

You may also wish to change the https port to be something more convenient
(eg `443`), if you change it from 7443, this module setups a firewall/NAT
redirect from 443 to 7443, since the port can't be changed using any built
in approach inside Unifi Video itself. This requires the
[puppetlabs/firewall](https://forge.puppetlabs.com/puppetlabs/firewall) module.

Note, since this port change takes place in prerouting, you'll need to allow
access to TCP/7443 regardless of what you change the port to in your iptables
firewall rules.


## Sync-to-Offsite

There is also a companion class that can be used to backup video recordings to
an Amazon S3 bucket for off-site safe keeping. This uses lsyncd and awscli to
trigger copies of files as they're written to disk to ensure prompt upload of
any content.

    class { '::unifi_video::backup':
      $target                => 's3://bucketname/videobackup,
      $aws_access_key_id     => 'Required if not using IAM roles',
      $aws_secret_access_key => 'Required if not using IAM roles',
    }

Warning: Do not include a trailing slash on `target` param, it causes
unexpected issues with AWS S3 directory browsing.

Note that this method isn't particularly efficient and can consume considerable
CPU when busy. It also uploads videos in the original format stored on disk by
UniFi Video, which consists of slices of video, rather than complete files.

A more sophisticated solution is available with `unifi_video::uploader` which
deploys a small Java application (https://github.com/jethrocarr/unifi-video-s3uploader)
which listens to the MongoDB database and uploads videos directly to a S3
bucket within seconds of their creation.

One difference of this approach is that you end up with complete video files,
rather than slices in an easily consumable format.

    class { '::unifi_video::uploader':
       # Required unless using IAM roles
       aws_access_key_id      => ''
       aws_secret_access_key  => ''

       # Need to be set to the region and name of your S3 bucket
       aws_region             => 'us-east-1'
       s3_bucket              => 'example'

       # Set the Unifi API key
       unifi_api_key          => 'abc123'
    }

Finally another option is [Detectatron](https://github.com/jethrocarr/detectatron)
which can handle uploading to S3, but also performs AI detection on the videos
using Amazon Recognition.


## Requirements

The currently listed GNU/Linux platforms at the [Ubiquiti support page](https://www.ubnt.com/download/unifi-video)
are supported by this module.

There is no RHEL/clone version or any platforms other than x86_64 because
Ubiquiti don't provide any software/support for those platforms.


## Limitations

Ubiquiti don't make the software available as a proper APT repo, so we can't
(easily) do things like check for the latest version - so we currently pin to
specific versions.

The downloads of their package come direct from their website, if they change
their download methodology or packaging approach, this could break in future.



## Contributions

All contributions are welcome via Pull Requests including documentation fixes
or compatibility fixes for supporting other distributions (or other operating
systems).


## License

This module is licensed under the Apache License, Version 2.0 (the "License").
See the `LICENSE` or http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
