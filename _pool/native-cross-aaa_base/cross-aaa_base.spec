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


Name:           cross-aaa_base
Summary:        Provides the basics for cross compiling on SUSE
License:        GPL-3.0-or-later
Group:          Development/Tools/Other
Version:        0.1
Release:        0
Source0:        LICENSE.GPL3

%description

%prep

%build
cp %{S:0} .
cat > cross-pkg-config <<EOF
#!/bin/sh

# A wrapper for pkg-config to take the default SUSE sysroot into account

export PKG_CONFIG_PATH=
export PKG_CONFIG_LIBDIR=%_sysroot/%_libdir/pkgconfig:%_sysroot%_sharedir/pkgconfig
export PKG_CONFIG_SYSROOT_DIR=%_sysroot

exec pkg-config "$@"
EOF

%install
install -D -m 0755 cross-pkg-config %buildroot%{_bindir}/cross-pkg-config

%files
%license LICENSE.GPL3
%{_bindir}/cross-pkg-config

%changelog
