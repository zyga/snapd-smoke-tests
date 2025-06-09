#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Canonical Ltd.
set -xeu

# Ensure that installing snaps with classic confinement is allowed.
if [ ! -e /snap ] && [ -d /var/lib/snapd/snap ]; then
	ln -s /var/lib/snapd/snap /snap
fi

# Pre-install snapd as a snap. Use the latest/beta channel
# to always test upcoming updates.
snap-install snapd latest/"${X_SPREAD_SNAPD_RISK_LEVEL}"

# Pre-install all the base snaps.
for snap in bare core core18 core20 core22 core24; do
	snap-install "$snap"
done
