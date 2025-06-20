#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Canonical Ltd.
set -xeu

# Show kernel version and system information. All the files with the .debug
# extension are displayed by project-wide debug handler.
uname -a
if [ -f /etc/os-release ]; then
	tee os-release.debug </etc/os-release
fi

# Show the version of classically packaged snapd.
snap version | tee snap-version.distro.debug

case "$SPREAD_SYSTEM" in
debian-cloud-sid)
	# If requested, download a custom build of snapd from salsa.debian.org
	# artifact page. An example job is https://salsa.debian.org/debian/snapd/-/jobs/7311035/
	# from pipeline https://salsa.debian.org/debian/snapd/-/pipelines/838704
	# This is the "build" job from standard Salsa CI pipeline. The job offers
	# x86_64 debian packages to install from the debian/output/ directory inside
	# the zip file that is the artifact transport container.
	#
	# The limitation on the system name is because snapd built on Salsa is only
	# really compatible with Debian unstable (given that it is also built there).
	if [ -n "$X_SPREAD_SALSA_JOB_ID" ]; then
		curl \
			--location \
			--insecure \
			--fail \
			--output /var/tmp/snapd.salsa.zip \
			https://salsa.debian.org/debian/snapd/-/jobs/"$X_SPREAD_SALSA_JOB_ID"/artifacts/download
		mkdir -p /var/tmp/snapd.salsa
		unzip -d /var/tmp/snapd.salsa /var/tmp/snapd.salsa.zip
		apt install -y \
			/var/tmp/snapd.salsa/debian/output/snapd_*.deb \
			/var/tmp/snapd.salsa/debian/output/snap-confine_*.deb
		rm -rf /var/tmp/snapd.salsa
		# Show the version of classically updated snapd.
		snap version | tee snap-version.salsa.debug
	fi
	;;
esac

# Show the list of pre-installed snaps.
snap list | tee snap-list-preinstalled.debug

# We don't expect any snaps. This will change once we start testing with
# desktop images. Currently we remove pre-installed snaps that some Ubuntu
# releases ship. This includes snapd snap.
snap list 2>&1 | grep -q 'No snaps are installed yet'

# Show network config.
ip addr list | tee ip-addr-list.debug

# See if we can resolve snapcraft.io
getent hosts snapcraft.io | tee getent-hosts-snapcraft-io.debug

mkdir "$X_SPREAD_CACHE_DIR"
# Opportunistically mount the architecture-specific cache directory.
# NOTE: We don't enable DAX support as that is not universally enabled
# in guest kernels. Failure to mount is non-fatal, as it only affects
# performance.
mount -t virtiofs spread-cache "$X_SPREAD_CACHE_DIR" || true

# Ensure that installing snaps with classic confinement is allowed.
if [ -d /var/lib/snapd/snap ]; then
	ln -s /var/lib/snapd/snap /snap
fi

# Pre-install snapd as a snap. Use the latest/beta channel
# to always test upcoming updates.
snap-install snapd latest/"${X_SPREAD_SNAPD_RISK_LEVEL}"

# Show the version of snapd-as-a-snap packaged snapd.
snap version | tee snap-version.snap.debug

# Pre-install all the base snaps.
for snap in bare core core18 core20 core22 core24; do
	snap-install "$snap"
done
