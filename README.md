<!--
SPDX-License-Identifier: Apache-2.0
SPDX-FileCopyrightText: Canonical Ltd.
-->
# Snapd smoke tests

This project provides integration tests for running upcoming snapd releases
across a matrix of many different operating systems against a selection of
representative snaps.

The following distributions are tested on x86\_64 hardware:

- Amazon Linux (2023)
- Arch Linux
- CentOS (9 and 10)
- Debian (11, 12 and sid)
- Fedora (41 and 42)
- Ubuntu (LTSes since 20.04, devel releases and upcoming release)
- openSUSE (Tumbleweed)

If you are running on aarch64 hardware, you can run the same tests locally,
except for Arch Linux, as there is no upstream cloud image for Arch yet.

All distribution images are provided by their respective upstream projects.
Images are downloaded and initialized with cloud-init using
[image-garden](https://gitlab.com/zygoon/image-garden).

All tests are implemented with [spread](https://github.com/snapcore/spread).

To run tests locally install the `image-garden` snap and then run the
`run-spread.sh` script from the root of the project. For optimal performance
you may need to use _edge_ channel for both snapd snap and image-garden until
image-garden 0.4 and snapd 2.71 are released.

## Testing builds from salsa.debian.org

Grab the GitLab job ID for the "build" job of a pipeline that ran on
https://salsa.debian.org/debian/snapd and either invoke the GitHub workflow
"salsa", passing to it the ID or run spread locally with
`X_SPREAD_SALSA_JOB_ID=` environment variable set.

Note that this is only compatible with `debian-cloud-sid` spread system.
