#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Canonical Ltd.
set -xeu
# Remove all the pre-installed snaps in the reverse order.
for snap in core24 core22 core20 core18 core bare snapd; do
	snap remove --purge "$snap"
done

# Remove /snap if it is a symbolic link.
if [ -L /snap ]; then
	rm /snap
fi
