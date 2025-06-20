#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Canonical Ltd.
set -xeu
# The "purge" suite purges the classic snapd package in the restore-each step,
# trying to observe that snaps that are installed by specific tasks can indeed
# be purged correctly.
#
# This is somewhat unusual for restore, so the suite-level restore actually
# does the work necessary for restore - re-install snapd the classic package.
#
# Notably we have to do this because spread does not offer stable order of
# execution so it is possible that purge jobs will run first, and then other
# suite will start running. We must leave the system in the same state as we
# started.
exec "$SPREAD_PATH"/spread/purge-suite-prepare-each.sh
