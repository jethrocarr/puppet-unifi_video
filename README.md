# puppet-unifi_video

## Overview

Provisions the Unifi Video software provided by Ubiquiti for use with their
IP-based video survelliance products.


## Configuration

Currently this module is limited to installed a specific version of the server:

    class { '::unifi_video':
      app_version => '3.1.2', # pin specific version
    }

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
