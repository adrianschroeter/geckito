#
# spec file for package openSUSE-release.spec
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


%define betaversion Beta%{nil}
Name:           geckito-release
Version:        15.3
Release:        0
# 1 is the product release, not the build release of this package 
Provides:       aaa_version
Provides:       distribution-release
Provides:       suse-release = %{version}-%{release}
Provides:       suse-release-oss = %{version}-%{release}
%if 0%{?beta_version}
# Give zypp a hint that this product must be kept up-to-date using zypper dup, not up (boo#1061384)
Provides:       product-update() = dup
%endif
# relaxes openSUSE/SUSE vendor change in zypper dup bsc#1182629
Provides:       dup-vendor-relax(suse)
# In case we have more than one product in the FTP tree, we need to give yast a hint
Provides:       system-installation() = Leap
Provides:       system-installation() = openSUSE
Obsoletes:      aaa_version
Obsoletes:      openSUSE-Promo-release <= 11.1
Obsoletes:      openSUSE-release-live <= 11.0
Obsoletes:      product_flavor(openSUSE) < 15.3
Obsoletes:      product_flavor(%{product}) < 15.3
Conflicts:      sles-release <= 10 sled-release <= 10 core-release <= 10
Conflicts:      otherproviders(distribution-release)
# bnc#826592
Provides:       weakremover(kernel-default) < 3.11
Provides:       weakremover(kernel-desktop) < 4.2
Provides:       weakremover(kernel-ec2) < 3.11
Provides:       weakremover(kernel-pae) < 3.11
Provides:       weakremover(kernel-vanilla) < 3.11
Provides:       weakremover(kernel-xen) < 3.11
# boo#1029075
Provides:       weakremover(gpg-pubkey-3d25d3d9-36e12d04)
# to obsolete old NM libs
Provides:       weakremover(libnm-glib-vpn1)
Provides:       weakremover(libnm-glib-vpn1-32bit)
Provides:       weakremover(libnm-glib4)
Provides:       weakremover(libnm-glib4-32bit)
Provides:       weakremover(libnm-gtk-devel)
Provides:       weakremover(libnm-gtk0)
Provides:       weakremover(libnm-util2)
Provides:       weakremover(libnm-util2-32bit)
Provides:       weakremover(typelib-1_0-NMClient-1_0)
Provides:       weakremover(typelib-1_0-NMGtk-1_0)
Provides:       weakremover(typelib-1_0-NetworkManager-1_0)
# to obsolete old samba packages
Provides:       weakremover(libsamba-policy-python-devel)
Provides:       weakremover(libsamba-policy0)
Provides:       weakremover(libsamba-policy0-32bit)
Provides:       weakremover(samba-libs-python)
Provides:       weakremover(samba-libs-python-32bit)
Provides:       weakremover(samba-python) 
Provides:       weakremover(libndr0)
Provides:       weakremover(libndr0-32bit)
Provides:       weakremover(python-tdb)
Provides:       weakremover(python-tdb-32bit)
Provides:       weakremover(python-tevent)
Provides:       weakremover(python-tevent-32bit)
Provides:       weakremover(python-ldb)
Provides:       weakremover(python-ldb-devel)
Provides:       weakremover(python-ldb-32bit)
Provides:       weakremover(python-talloc)
Provides:       weakremover(python-talloc-devel)
Provides:       weakremover(python-talloc-32bit)
# f2py file conflicting
Provides:       weakremover(python-numpy) 
Provides:       weakremover(python-numpy-devel) 
# some hints for the solver
# default Java for Leap 15.1
Suggests:       java-11-openjdk
# preferred MTA
Suggests:       postfix
# preferred ntp daemon
Suggests:       chrony
#
Recommends:     branding-openSUSE
Recommends:     distribution-logos-openSUSE-Leap
Recommends:     issue-generator
BuildRequires:  skelcd-control-openSUSE
BuildRequires:  skelcd-openSUSE

Provides:       %name-%version
Provides:       product() = Leap
Provides:       product(Leap) = 15.3-1
%ifarch x86_64
Provides:       product-register-target() = openSUSE%2DLeap%2D15.3%2Dx86_64
%endif
%ifarch aarch64
Provides:       product-register-target() = openSUSE%2DLeap%2D15.3%2Daarch64
%endif
%ifarch ppc64le
Provides:       product-register-target() = openSUSE%2DLeap%2D15.3%2Dppc64le
%endif
%ifarch s390x
Provides:       product-register-target() = openSUSE%2DLeap%2D15.3%2Ds390x
%endif
Provides:       product-label() = openSUSE%20Leap
Provides:       product-cpeid() = cpe%3A%2Fo%3Aopensuse%3Aleap%3A15.3
Provides:       product-url(releasenotes) = http%3A%2F%2Fdoc.opensuse.org%2Frelease%2Dnotes%2Fx86_64%2FopenSUSE%2FLeap%2F15.3%2Frelease%2Dnotes%2DopenSUSE.rpm
Provides:       product-url(repository) = http%3A%2F%2Fdownload.opensuse.org%2Fdistribution%2Fleap%2F15.3%2Frepo%2Foss%2F
Provides:       product-updates-repoid() = obsrepository%3A%2F%2Fbuild.opensuse.org%2FopenSUSE%3ALeap%3A15.3%3AUpdate%2Fstandard
Provides:       product-updates-repoid() = obsrepository%3A%2F%2Fbuild.opensuse.org%2FopenSUSE%3ALeap%3A15.3%3ANonFree%3AUpdate%2Fstandard
Provides:       product-updates-repoid() = obsrepository%3A%2F%2Fbuild.opensuse.org%2FopenSUSE%3ABackports%3ASLE%2D15%2DSP3%3AUpdate%2Fstandard
Provides:       product-updates-repoid() = obsrepository%3A%2F%2Fbuild.opensuse.org%2FSUSE%3ASLE%2D15%2DSP3%3AUpdate%2Fstandard
Provides:       product-endoflife() = 2020%2D11%2D30
Requires:       product_flavor(Leap)


Summary:        openSUSE Leap 15.3
License:        BSD-3-Clause
Group:          System/Fhs
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
#PreReq:         coreutils
# the post scriptlets uses awk, boo#976913
Requires(post):  awk

%description
Geckito distribution, experimental state

%prep
%setup -qcT
mkdir license
if [ -f /CD1/license.tar.gz ]; then
  tar -C license -xzf /CD1/license.tar.gz
elif [ -f %{_libexecdir}/skelcd/CD1/license.tar.gz ]; then
  tar -C license -xzf %{_libexecdir}/skelcd/CD1/license.tar.gz
fi

%build

%install
mkdir -p %{buildroot}%{_sysconfdir} %{buildroot}%{_libexecdir} %{buildroot}/run %{buildroot}%{_prefix}/lib/issue.d

echo -e 'Welcome to \\S - Kernel \\r (\\l).\n' > %{buildroot}%{_prefix}/lib/issue.d/10-openSUSE.conf
echo -e "\n" > %{buildroot}%{_prefix}/lib/issue.d/90-openSUSE.conf

VERSION_ID=`echo %{version}|tr '[:upper:]' '[:lower:]'|sed -e 's/ //g;'`
# note: VERSION is an optional field and has no meaning other than informative on a rolling distro
# We do thus not add it to the os-release file
cat > %{buildroot}%{_libexecdir}/os-release <<EOF
NAME="openSUSE Geckito"
VERSION="%{version}%{?betaversion: %{betaversion}}"
ID="opensuse-geckito"
ID_LIKE="suse opensuse"
VERSION_ID="$VERSION_ID"
PRETTY_NAME="openSUSE Geckito %{version}%{?betaversion: %{betaversion}}"
ANSI_COLOR="0;32"
CPE_NAME="cpe:/o:opensuse:leap:%{version}"
BUG_REPORT_URL="https://bugs.opensuse.org"
HOME_URL="https://www.opensuse.org/"
EOF
ln -s ..%{_libexecdir}/os-release %{buildroot}%{_sysconfdir}/os-release

echo "Have a lot of fun..." > %{buildroot}%{_sysconfdir}/motd
# Bug 404141 - /etc/YaST/control.xml should be owned by some package
mkdir -p %{buildroot}%{_sysconfdir}/YaST2/
echo %{buildroot}
if [ -f /CD1/control.xml ]; then
  install -m 644 /CD1/control.xml %{buildroot}%{_sysconfdir}/YaST2/
elif [ -f %{_libexecdir}/skelcd/CD1/control.xml ]; then
  install -m 644 %{_libexecdir}/skelcd/CD1/control.xml %{buildroot}%{_sysconfdir}/YaST2/
fi

# enable vendor change openSUSE,SUSE
mkdir -p %{buildroot}%{_sysconfdir}/zypp/vendors.d
echo -e "[main]\nvendors=openSUSE,SUSE,SUSE LLC <https://www.suse.com/>\n" > %{buildroot}%{_sysconfdir}/zypp/vendors.d/00-openSUSE.conf

# fate#319341, make openSUSE-release own YaST license files
# see also jsc#SLE-3067 for mess caused by SLE
install -D -d -m 755 "%{buildroot}%{_datadir}/licenses/product/base"
install -D -d -m 755 "%{buildroot}%{_defaultlicensedir}"
cp -a license "%{buildroot}%{_defaultlicensedir}/%{name}"
pushd license
# SLE compat
for i in *; do
	ln -s "%{_defaultlicensedir}/%{name}/$i" %{buildroot}%{_datadir}/licenses/product/base/$i
done

mkdir -p $RPM_BUILD_ROOT/etc/products.d
cat >$RPM_BUILD_ROOT/etc/products.d/Leap.prod << EOF
<?xml version="1.0" encoding="UTF-8"?>
<product schemeversion="0">
  <vendor>openSUSE</vendor>
  <name>Leap</name>
  <version>15.3</version>
  <release>1</release>
  <endoflife>2020-11-30</endoflife>
  <arch>%{_target_cpu}</arch>
  <cpeid>cpe:/o:opensuse:leap:15.3</cpeid>
  <productline>Leap</productline>
  <codestream>
    <name>openSUSE Leap 15</name>
    <endoflife>2021-11-30</endoflife>
  </codestream>
  <register>
    <pool>
      <repository url="http://download.opensuse.org/distribution/leap/15.3/repo/oss/">
        <zypp name="openSUSE-Leap-15.3-Pool" alias="openSUSE-Leap-15.3-Pool"/>
      </repository>
      <repository url="http://download.opensuse.org/distribution/leap/15.3/repo/non-oss/">
        <zypp name="openSUSE-Leap-15.3-NonOss-Pool" alias="openSUSE-Leap-15.3-NonOss-Pool"/>
      </repository>
    </pool>
    <updates>
      <distrotarget arch="x86_64">openSUSE-Leap-15.3-x86_64</distrotarget>
      <distrotarget arch="aarch64">openSUSE-Leap-15.3-aarch64</distrotarget>
      <distrotarget arch="ppc64le">openSUSE-Leap-15.3-ppc64le</distrotarget>
      <distrotarget arch="s390x">openSUSE-Leap-15.3-s390x</distrotarget>
      <repository project="openSUSE:Leap:15.3:Update" name="standard">
        <zypp name="openSUSE-Leap-15.3-Updates" alias="openSUSE-Leap-15.3-Updates"/>
      </repository>
      <repository project="openSUSE:Leap:15.3:NonFree:Update" name="standard">
        <zypp name="openSUSE-Leap-15.3-NonOss-Updates" alias="openSUSE-Leap-15.3-NonOss-Updates"/>
      </repository>
      <repository project="openSUSE:Backports:SLE-15-SP3:Update" name="standard">
        <zypp name="openSUSE-Backports-15.3-Updates" alias="openSUSE-Backports-15.3-Updates"/>
      </repository>
      <repository project="SUSE:SLE-15-SP3:Update" name="standard">
        <zypp name="SLE-15-SP3-Updates" alias="SLE-15-SP3-Updates"/>
      </repository>
    </updates>
  </register>
  <repositories>
    <repository type="update" repoid="obsrepository://build.opensuse.org/openSUSE:Leap:15.3:Update/standard"/>
    <repository type="update" repoid="obsrepository://build.opensuse.org/openSUSE:Leap:15.3:NonFree:Update/standard"/>
    <repository type="update" repoid="obsrepository://build.opensuse.org/openSUSE:Backports:SLE-15-SP3:Update/standard"/>
    <repository type="update" repoid="obsrepository://build.opensuse.org/SUSE:SLE-15-SP3:Update/standard"/>
  </repositories>
  <updaterepokey>000000000</updaterepokey>
  <summary>openSUSE Leap 15.3</summary>
  <shortsummary>openSUSE Leap</shortsummary>
  <description>openSUSE Leap 15.3. This is currently an experimental distribution!</description>
  <linguas>
    <language>cs</language>
    <language>da</language>
    <language>de</language>
    <language>en</language>
    <language>en_GB</language>
    <language>en_US</language>
    <language>es</language>
    <language>fi</language>
    <language>fr</language>
    <language>hu</language>
    <language>it</language>
    <language>ja</language>
    <language>nb</language>
    <language>nl</language>
    <language>pl</language>
    <language>pt</language>
    <language>pt_BR</language>
    <language>ru</language>
    <language>sv</language>
    <language>zh</language>
    <language>zh_CN</language>
    <language>zh_TW</language>
    <language>ar</language>
    <language>bg</language>
    <language>bs</language>
    <language>ca</language>
    <language>el</language>
    <language>eo</language>
    <language>et</language>
    <language>fa</language>
    <language>id</language>
    <language>ko</language>
    <language>lt</language>
    <language>sk</language>
    <language>sl</language>
    <language>uk</language>
  </linguas>
  <urls>
    <url name="releasenotes">http://doc.opensuse.org/release-notes/x86_64/openSUSE/Leap/15.3/release-notes-openSUSE.rpm</url>
    <url name="repository">http://download.opensuse.org/distribution/leap/15.3/repo/oss/</url>
  </urls>
  <buildconfig>
    <producttheme>openSUSE</producttheme>
    <betaversion>Beta</betaversion>
    <create_flavors>true</create_flavors>
  </buildconfig>
  <installconfig>
    <defaultlang>en_US</defaultlang>
    <releasepackage name="openSUSE-release" flag="EQ" version="%{version}" release="%{release}"/>
    <distribution>openSUSE</distribution>
  </installconfig>
  <runtimeconfig/>
</product>

EOF

%post
# this is a base product, create symlink  bsc#1091952
if [ ! -L %{_sysconfdir}/products.d/baseproduct ]; then
	ln -sf Leap.prod %{_sysconfdir}/products.d/baseproduct
fi

# Upgrade path - if %{_sysconfdir}/default/grub contains any of the DISTRIBUTOR= tags
# we ever put, replace it with "", which means grub will use %{_sysconfdir}/os-release to make something up
if [ -f %{_sysconfdir}/default/grub ]; then
  DISTRIBUTOR=$(awk -F= '/^GRUB_DISTRIBUTOR/ {print $2}' %{_sysconfdir}/default/grub | tr -d '"')
  case "$DISTRIBUTOR" in
        "openSUSE" | \
        "openSUSE 13.1" | \
        "openSUSE 13.2")
                # replace GRUB_DISTRIBUTOR in %{_sysconfdir}/default/grub with ""
                sed -i "s/^GRUB_DISTRIBUTOR=.*/GRUB_DISTRIBUTOR=/" %{_sysconfdir}/default/grub
                ;;
  esac
fi

%posttrans
# Launch the issue-generator: we have a new config file in /usr/lib/issue.d that needs to be represented
if [ -x %{_sbindir}/issue-generator ]; then
    if [ -x %{_bindir}/systemd-tmpfiles ]; then
      %{_bindir}/systemd-tmpfiles --create issue-generator.conf || :
    fi
    %{_sbindir}/issue-generator || :
fi

%files
%defattr(644,root,root,755)
%dir %{_datadir}/licenses/product
%{_datadir}/licenses/product/base
%license license/*
%{_sysconfdir}/os-release
%{_libexecdir}/os-release
# Bug 404141 - /etc/YaST/control.xml should be owned by some package
%dir %{_sysconfdir}/YaST2/
%config %{_sysconfdir}/YaST2/control.xml
%config %{_sysconfdir}/zypp/vendors.d/00-openSUSE.conf
%config(noreplace) %{_sysconfdir}/motd
%dir %{_prefix}/lib/issue.d/
%{_prefix}/lib/issue.d/10-openSUSE.conf
%{_prefix}/lib/issue.d/90-openSUSE.conf
%{_sysconfdir}/products.d
%ghost %{_sysconfdir}/products.d/baseproduct

%changelog
