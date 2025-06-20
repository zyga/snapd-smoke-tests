#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Canonical Ltd.
set -xeu

# The restore-each step is unorthodox in the sense that it does not restore but
# rather, contains the property we care about measuring - it purges snapd from
# the system using the classic packaging system.
if [ -n "$(command -v apt)" ]; then
	apt remove --purge -y snapd
elif [ -n "$(command -v dnf)" ]; then
	dnf remove -y snapd
elif [ -n "$(command -v yum)" ]; then
	yum remove -y snapd
elif [ -n "$(command -v zypper)" ]; then
	zypper remove -y snapd
elif [ -n "$(command -v pacman)" ]; then
	pacman --noconfirm -R snapd
else
	echo "How do I uninstall snapd on this system? $(cat /etc/os-release)"
	exit 1
fi
