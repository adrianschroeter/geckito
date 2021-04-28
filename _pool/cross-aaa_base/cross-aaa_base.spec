#
# spec file for package hello
#
# Copyright (c) 2019 SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via https://bugs.opensuse.org/
#

#!NativeBuild
%define tarch @BUILD_FLAVOR@
%define tlibdir /usr/lib64
%if "@BUILD_FLAVOR@" == ""
ExclusiveArch: skipit
%endif

# keep in sync with macros.cross definition
%define cross_sysroot %{_prefix}/%{tarch}-suse-linux/sys-root

Name:           cross-%{tarch}-aaa_base
Summary:        Provides the basics for cross compiling on SUSE
License:        GPL-3.0-or-later
Group:          Development/Tools/Other
Version:        0.1
Release:        0
Source0:        LICENSE.GPL3
Source1:        macros.cross

%description

%prep

%build
cp %{S:0} .

cat > cross-buildsystem.sh <<EOF
# Setting up cross compiler
export CC=%{tarch}-suse-linux-gcc
export CXX=%{tarch}-suse-linux-g++
EOF

cat > cross-pkg-config <<EOF
#!/bin/sh

# A wrapper for pkg-config to take the default SUSE sysroot into account

export PKG_CONFIG_PATH=
export PKG_CONFIG_LIBDIR=%cross_sysroot%{tlibdir}/pkgconfig:%cross_sysroot/usr/share/pkgconfig
export PKG_CONFIG_SYSROOT_DIR=%cross_sysroot

exec pkg-config "$@"
EOF

%install
install -D -m 0755 cross-pkg-config %buildroot%{_bindir}/cross-%{tarch}-pkg-config
install -D -m 0644 cross-buildsystem.sh %buildroot/etc/profile.d/cross-buildsystem.sh
install -D -m 0644 %{S:1} %buildroot/etc/rpm/macros.cross
sed -i -e 's,@ARCH@,%{tarch},' %buildroot/etc/rpm/macros.cross

%files
%license LICENSE.GPL3
%{_bindir}/cross-%{tarch}-pkg-config
/etc/rpm/macros.cross
/etc/profile.d/cross-buildsystem.sh

%changelog
