# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Canonical Ltd.
#
# This file defines cloud-init profiles for virtual machine images that are
# used by the spread "garden" backend. In all the cases we install "jq" and
# "curl" for the needs of the test suite. For most systems we also ensure that
# snapd is installed.

# The copy of snapd that is currently in most systems is susceptible to a bug
# where snapd will deactivate itself in a racy and problematic wait. Increase
# the timeout to 15 minutes to avoid this problem.
define snapd_suspend_workaround
- |
    # Work around a bug in snapd auto-suspend feature by making snapd wait for at least 15 minutes.
    mkdir -p /etc/systemd/system/snapd.service.d;
    echo -e "[Service]\\nEnvironment=SNAPD_STANDBY_WAIT=15m" >/etc/systemd/system/snapd.service.d/standby.conf;
endef

define ARCHLINUX_CLOUD_INIT_USER_DATA_TEMPLATE
$(BASE_CLOUD_INIT_USER_DATA_TEMPLATE)
$(snapd_suspend_workaround)
# We cannot build the package as root so switch to the archlinux user.
- sudo -u archlinux git clone https://aur.archlinux.org/snapd.git /tmp/snapd
- cd /tmp/snapd && sudo -u archlinux makepkg -si --noconfirm
- systemctl enable --now snapd.socket
- systemctl enable --now snapd.apparmor.service
# https://documentation.ubuntu.com/lxd/latest/howto/network_bridge_firewalld/#prevent-connectivity-issues-with-lxd-and-docker
- echo net.ipv4.conf.all.forwarding=1 >/etc/sysctl.d/99-forwarding.conf
packages:
- curl
- jq
# To clone and build snapd.
- base-devel
- git
endef

define AMAZONLINUX_CLOUD_INIT_USER_DATA_TEMPLATE
$(BASE_CLOUD_INIT_USER_DATA_TEMPLATE)
$(snapd_suspend_workaround)
# https://documentation.ubuntu.com/lxd/latest/howto/network_bridge_firewalld/#prevent-connectivity-issues-with-lxd-and-docker
- echo net.ipv4.conf.all.forwarding=1 >/etc/sysctl.d/99-forwarding.conf
packages:
# Curl is pre-installed but only in the "minimal" version.
# Installing curl via cloud-init fails as it conflicts with curl-minimal
- jq
# Ensure that snapd is installed.
- snapd
# Snapd is distributed via Maciej's quasi-official archive.
yum_repos:
  snapd:
    name: snapd packages for Amazon Linux
    baseurl: https://bboozzoo.github.io/snapd-amazon-linux/al2023/$$basearch
    gpgcheck: false
    enabled: true
endef

define CENTOS_CLOUD_INIT_USER_DATA_TEMPLATE
$(BASE_CLOUD_INIT_USER_DATA_TEMPLATE)
$(snapd_suspend_workaround)
# https://documentation.ubuntu.com/lxd/latest/howto/network_bridge_firewalld/#prevent-connectivity-issues-with-lxd-and-docker
- echo net.ipv4.conf.all.forwarding=1 >/etc/sysctl.d/99-forwarding.conf
# Install snapd after getting epel-release installed via packages below.
- dnf install -y snapd
- systemctl enable --now snapd.socket
packages:
- curl
- jq
# Snapd is distributed via the EPEL archive.
- epel-release
endef

define DEBIAN_CLOUD_INIT_USER_DATA_TEMPLATE
$(BASE_CLOUD_INIT_USER_DATA_TEMPLATE)
$(snapd_suspend_workaround)
# https://documentation.ubuntu.com/lxd/latest/howto/network_bridge_firewalld/#prevent-connectivity-issues-with-lxd-and-docker
- echo net.ipv4.conf.all.forwarding=1 >/etc/sysctl.d/99-forwarding.conf
packages:
- curl
- jq
# Ensure that snapd is installed.
- snapd
endef


define FEDORA_CLOUD_INIT_USER_DATA_TEMPLATE
$(BASE_CLOUD_INIT_USER_DATA_TEMPLATE)
$(snapd_suspend_workaround)
# https://documentation.ubuntu.com/lxd/latest/howto/network_bridge_firewalld/#prevent-connectivity-issues-with-lxd-and-docker
- echo net.ipv4.conf.all.forwarding=1 >/etc/sysctl.d/99-forwarding.conf
packages:
- curl
- jq
# Ensure that snapd is installed.
- snapd
endef

define OPENSUSE_tumbleweed_CLOUD_INIT_USER_DATA_TEMPLATE
$(BASE_CLOUD_INIT_USER_DATA_TEMPLATE)
$(snapd_suspend_workaround)
# https://documentation.ubuntu.com/lxd/latest/howto/network_bridge_firewalld/#prevent-connectivity-issues-with-lxd-and-docker
- echo net.ipv4.conf.all.forwarding=1 >/etc/sysctl.d/99-forwarding.conf
# Tumbleweed is now using SELinux. Switch it back to AppArmor
- sed -i -e 's/security=selinux/security=apparmor/g' /etc/default/grub
- update-bootloader
# Add the system:snappy repository and install snapd
- zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy
- zypper --gpg-auto-import-keys refresh
- zypper dup --from snappy
- zypper install -y snapd
- systemctl enable --now snapd
- systemctl enable --now snapd.apparmor
packages:
- curl
- jq
endef

define UBUNTU_CLOUD_INIT_USER_DATA_TEMPLATE
$(BASE_CLOUD_INIT_USER_DATA_TEMPLATE)
$(snapd_suspend_workaround)
# https://documentation.ubuntu.com/lxd/latest/howto/network_bridge_firewalld/#prevent-connectivity-issues-with-lxd-and-docker
- echo net.ipv4.conf.all.forwarding=1 >/etc/sysctl.d/99-forwarding.conf
# Remove the LXD snap that is sometimes pre-installed.
# We want to make sure that we can remove all the base
# snaps at the end of testing.
- |
    if snap list lxd | grep -q lxd; then
        snap remove --purge lxd
    fi
packages:
- curl
- jq
endef
