#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Canonical Ltd.
#
# Run integration tests with spread sequentially on all the systems.
set -eu

if [ -n "$(command -v image-garden.spread)" ]; then
	if ! snap run --shell image-garden -c "snapctl is-connected kvm"; then
		echo "Please connect the kvm interface to image-garden" >&2
		echo "snap connect image-garden:kvm" >&2
		exit 1
	fi
	SPREAD=image-garden.spread
else
	SPREAD=spread
	if test -z "$(command -v spread)"; then
		echo "You need to install spread from https://github.com/snapcore/spread with the Go compiler and the command: go install github.com/snapcore/spread/cmd/spread@latest" >&2
		exit 1
	fi

	if test -z "$(command -v image-garden)"; then
		echo "You need to install image-garden from https://gitlab.com/zygoon/image-garden: make install prefix=/usr/local" >&2
		exit 1
	fi
fi

mkdir -p spread-logs

all_ok=0
for system in $(yq --raw-output '.backends.garden.systems[] | keys[]' <spread.yaml); do
	# Allow the user to filter at a high-level by invoking this script with arguments
	# such as "fedora" "debian".
	skip=$#
	for filter in "$@"; do
		if echo "$system" | grep -q "$filter"; then
			skip=0
			break
		fi
	done
	if [ $skip -ne 0 ]; then
		continue
	fi
	if ! "$SPREAD" -v "$system" | tee spread-logs/"$system".log; then
		echo "Spread exited with code $?" >spread-logs/"$system".failed
		all_ok=1
	fi
done

exit $all_ok
