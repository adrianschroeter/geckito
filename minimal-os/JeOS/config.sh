#!/bin/bash
# vim: sw=4 et
#================
# FILE          : config.sh
#----------------
# PROJECT       : OpenSuSE KIWI Image System
# COPYRIGHT     : (c) 2006 SUSE LINUX Products GmbH. All rights reserved
#               :
# AUTHOR        : Marcus Schaefer <ms@suse.de>
#               :
# BELONGS TO    : Operating System images
#               :
# DESCRIPTION   : configuration script for SUSE based
#               : operating systems
#               :
#               :
# STATUS        : BETA
#----------------
#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]..."

#======================================
# Setup baseproduct link
#--------------------------------------
suseSetupProduct

#======================================
# Activate services
#--------------------------------------
suseInsertService sshd
suseInsertService boot.device-mapper
suseInsertService chronyd
suseRemoveService avahi-dnsconfd
suseRemoveService avahi-daemon

if [ -x /usr/bin/cloud-init ]; then
    # Found cloud-init (probably for dracut firstboot), enable it
    suseInsertService cloud-init-local
    suseInsertService cloud-init
    suseInsertService cloud-config
    suseInsertService cloud-final
fi

#======================================
# Add missing gpg keys to rpm
#--------------------------------------
suseImportBuildKey

#======================================
# Set sensible defaults
#--------------------------------------

baseUpdateSysConfig /etc/sysconfig/clock HWCLOCK "-u"
baseUpdateSysConfig /etc/sysconfig/clock TIMEZONE UTC
echo 'DEFAULT_TIMEZONE="UTC"' >> /etc/sysconfig/clock
baseUpdateSysConfig /etc/sysconfig/network/dhcp DHCLIENT_SET_HOSTNAME no
baseUpdateSysConfig /etc/sysconfig/network/dhcp WRITE_HOSTNAME_TO_HOSTS no

#==========================================
# remove unneeded kernel files
#------------------------------------------
# Stripkernel renames the image which breaks
# 2nd boot
# suseStripKernel

#==========================================
# dirs needed by kiwi for subvolumes
#------------------------------------------
mkdir -p /var/lib/mailman /var/lib/mariadb /var/lib/mysql /var/lib/named /var/lib/pgsql /var/lib/libvirt/images

#==========================================
# remove package docs
#------------------------------------------
rm -rf /usr/share/doc/packages/*
rm -rf /usr/share/doc/manual/*
rm -rf /opt/kde*

if ! rpmqpack | grep -q vim-enhanced; then
    #======================================
    # only basic version of vim is
    # installed; no syntax highlighting
    #--------------------------------------
    sed -i -e's/^syntax on/" syntax on/' /etc/vimrc
fi

#======================================
# Import GPG Key
#
t=$(mktemp)
cat - <<EOF > $t
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2.0.15 (GNU/Linux)

mQENBEkUTD8BCADWLy5d5IpJedHQQSXkC1VK/oAZlJEeBVpSZjMCn8LiHaI9Wq3G
3Vp6wvsP1b3kssJGzVFNctdXt5tjvOLxvrEfRJuGfqHTKILByqLzkeyWawbFNfSQ
93/8OunfSTXC1Sx3hgsNXQuOrNVKrDAQUqT620/jj94xNIg09bLSxsjN6EeTvyiO
mtE9H1J03o9tY6meNL/gcQhxBvwuo205np0JojYBP0pOfN8l9hnIOLkA0yu4ZXig
oKOVmf4iTjX4NImIWldT+UaWTO18NWcCrujtgHueytwYLBNV5N0oJIP2VYuLZfSD
VYuPllv7c6O2UEOXJsdbQaVuzU1HLocDyipnABEBAAG0NG9wZW5TVVNFIFByb2pl
Y3QgU2lnbmluZyBLZXkgPG9wZW5zdXNlQG9wZW5zdXNlLm9yZz6JATwEEwECACYC
GwMGCwkIBwMCBBUCCAMEFgIDAQIeAQIXgAUCU2dN1AUJHR8ElQAKCRC4iy/UPb3C
hGQrB/9teCZ3Nt8vHE0SC5NmYMAE1Spcjkzx6M4r4C70AVTMEQh/8BvgmwkKP/qI
CWo2vC1hMXRgLg/TnTtFDq7kW+mHsCXmf5OLh2qOWCKi55Vitlf6bmH7n+h34Sha
Ei8gAObSpZSF8BzPGl6v0QmEaGKM3O1oUbbB3Z8i6w21CTg7dbU5vGR8Yhi9rNtr
hqrPS+q2yftjNbsODagaOUb85ESfQGx/LqoMePD+7MqGpAXjKMZqsEDP0TbxTwSk
4UKnF4zFCYHPLK3y/hSH5SEJwwPY11l6JGdC1Ue8Zzaj7f//axUs/hTC0UZaEE+a
5v4gbqOcigKaFs9Lc3Bj8b/lE10Y
=i2TA
-----END PGP PUBLIC KEY BLOCK-----
EOF
rpm --import $t
rm -f $t

#======================================
# prepare for setting root pw, timezone
#--------------------------------------
echo ** "reset machine settings"
rm /etc/machine-id
rm /etc/localtime
rm /var/lib/zypp/AnonymousUniqueId
rm /var/lib/systemd/random-seed

#======================================
# Add Factory repo
#--------------------------------------
ARCH=$(uname -m)
case $ARCH in
  riscv64)
    # riscv64 is not supported by /etc/YaST2/control.xml yet, so add repo manually
    zypper ar -f http://download.opensuse.org/ports/riscv/tumbleweed/repo/oss/ openSUSE-Ports-Tumbleweed-repo-oss
    ;;
  *)
    # Add repos from /etc/YaST2/control.xml
    if [ -x /usr/sbin/add-yast-repos ]; then
        add-yast-repos
        zypper --non-interactive rm -u live-add-yast-repos
    fi
    ;;
esac

#======================================
# Invoke grub2-install
#--------------------------------------

case $kiwi_iname in
  *efi|*.aarch64-rootfs)
    [ -x /usr/sbin/grub2-install ] && {
        /usr/sbin/grub2-install || :
    }
    ;;
esac

#======================================
# Add Contrib repo when needed
#--------------------------------------
if [ -f /kiwi-hooks/contrib_repo ]; then
    REPO=$(cat /kiwi-hooks/contrib_repo | sed 's/devel:ARM:Factory:Contrib://')
    URLREPO=$(sed 's/:/:\//g' /kiwi-hooks/contrib_repo)
    zypper ar -f "http://download.opensuse.org/repositories/$URLREPO/standard/" "Factory-Contrib-$REPO"
    rm -f /kiwi-hooks/contrib_repo

    if [ -z "$(ls -A /kiwi-hooks)" ]; then
        rm -rf /kiwi-hooks
    fi
fi

case "$kiwi_iname" in
  *efi*|*chromebook*|*-raspberrypi2|*-raspberrypi)
    # Do not use any defaults. X server will detect what it needs to load
    # Tested with GFX images in qemu and on chromebook
    ;;
  *)
    #======================================
    # Add xorg config with fbdev for other boards
    #--------------------------------------
    mkdir -p /etc/X11/xorg.conf.d/
    cat > /etc/X11/xorg.conf.d/20-fbdev.conf <<-EOF
	Section "Device"
	    Identifier "fb gfx"
	    Driver "fbdev"
	    Option "fb" "/dev/fb0"
	EndSection
	EOF
    ;;
esac

#======================================
# Configure system for E20 usage
#--------------------------------------
# XXX only do for E20 image types
if [[ "$kiwi_iname" == *"E20-"* ]]; then
	baseUpdateSysConfig /etc/sysconfig/displaymanager DISPLAYMANAGER lightdm
	cat >> /etc/sysconfig/windowmanager <<EOF
## Path:        Desktop/Window manager
## Description:
## Type:        string(gnome,kde4,kde,lxde,xfce,twm,icewm)
## Default:     xfce
## Config:      profiles,kde,susewm
#
# Here you can set the default window manager (kde, fvwm, ...)
# changes here require at least a re-login
DEFAULT_WM="enlightenment"
EOF
	# We want to start in gfx mode
	baseSetRunlevel 5
	suseConfig
fi

#======================================
# Configure system for LXQT usage
#--------------------------------------
# XXX only do for LXQT image types
if [[ "$kiwi_iname" == *"LXQT-"* ]]; then
	baseUpdateSysConfig /etc/sysconfig/displaymanager DISPLAYMANAGER lightdm
	cat >> /etc/sysconfig/windowmanager <<EOF
## Path:        Desktop/Window manager
## Description:
## Type:        string(gnome,kde4,kde,lxde,xfce,twm,icewm)
## Default:     xfce
## Config:      profiles,kde,susewm
#
# Here you can set the default window manager (kde, fvwm, ...)
# changes here require at least a re-login
DEFAULT_WM="lxqt"
EOF
	# We want to start in gfx mode
	baseSetRunlevel 5
	suseConfig
fi

#======================================
# Configure system for XFCE usage
#--------------------------------------
# XXX only do for XFCE image types
if [[ "$kiwi_iname" == *"XFCE-"* ]]; then
	baseUpdateSysConfig /etc/sysconfig/displaymanager DISPLAYMANAGER lightdm
	cat >> /etc/sysconfig/windowmanager <<EOF
## Path:        Desktop/Window manager
## Description:
## Type:        string(gnome,kde4,kde,lxde,xfce,twm,icewm)
## Default:     xfce
## Config:      profiles,kde,susewm
#
# Here you can set the default window manager (kde, fvwm, ...)
# changes here require at least a re-login
DEFAULT_WM="xfce"
EOF
	# We want to start in gfx mode
	baseSetRunlevel 5
	suseConfig
fi

#======================================
# Configure system for IceWM usage
#--------------------------------------
if [[ "$kiwi_iname" == *"X11-"* ]]; then
       baseUpdateSysConfig /etc/sysconfig/displaymanager DISPLAYMANAGER xdm
       baseUpdateSysConfig /etc/sysconfig/windowmanager DEFAULT_WM icewm

       # We want to start in gfx mode
       baseSetRunlevel 5
       suseConfig
fi

#======================================
# Configure system for KDE/Plasma usage
#--------------------------------------
if [[ "$kiwi_iname" == *"KDE-"* ]]; then
       baseUpdateSysConfig /etc/sysconfig/displaymanager DISPLAYMANAGER sddm
       baseUpdateSysConfig /etc/sysconfig/windowmanager DEFAULT_WM plasma5

       # We want to start in gfx mode
       baseSetRunlevel 5
       suseConfig
fi

#======================================
# Configure system for GNOME usage
#--------------------------------------
if [[ "$kiwi_iname" == *"GNOME-"* ]]; then
       baseUpdateSysConfig /etc/sysconfig/displaymanager DISPLAYMANAGER gdm
       baseUpdateSysConfig /etc/sysconfig/windowmanager DEFAULT_WM gnome

       # We want to start in gfx mode
       baseSetRunlevel 5
       suseConfig
fi

#======================================
# Add tty devices to securetty
#--------------------------------------
# XXX should be target specific
cat >> /etc/securetty <<EOF
ttyO0
ttyO2
ttyAMA0
ttyAMA2
ttymxc0
ttymxc1
EOF

#======================================
# Bring up eth device automatically
#--------------------------------------
mkdir -p /etc/sysconfig/network/
case "$kiwi_iname" in
    *-m400)
	cat > /etc/sysconfig/network/ifcfg-enp1s0 <<-EOF
	BOOTPROTO='dhcp'
	MTU=''
	REMOTE_IPADDR=''
	STARTMODE='onboot'
	EOF
	;;
    *efi*)
        # Tumbleweed uses enp0s3 in qemu (eth0 in Leap)
	cat > /etc/sysconfig/network/ifcfg-enp0s3 <<-EOF
	BOOTPROTO='dhcp'
	MTU=''
	REMOTE_IPADDR=''
	STARTMODE='onboot'
	EOF
	# But some boards still have eth0 instead of enpXsY
	cat > /etc/sysconfig/network/ifcfg-eth0 <<-EOF
	BOOTPROTO='dhcp'
	MTU=''
	REMOTE_IPADDR=''
	STARTMODE='onboot'
	EOF
	;;
    *)
	# XXX extend to more boards
	cat > /etc/sysconfig/network/ifcfg-eth0 <<-EOF
	BOOTPROTO='dhcp'
	MTU=''
	REMOTE_IPADDR=''
	STARTMODE='onboot'
	EOF
	;;
esac

#======================================
# Configure chronyd
#--------------------------------------

# tell e2fsck to ignore the time differences
cat > /etc/e2fsck.conf <<EOF
[options]
broken_system_clock=true
EOF

# /etc/chronyd.conf has already one openSUSE ntp pool
# for i in 0 1 2 3; do
#     echo "server $i.opensuse.pool.ntp.org iburst" >> /etc/chronyd.conf
# done

#======================================
# Trigger {jeos,yast2}-firstboot on first boot
# XXX It breaks more than it helps for now, just disable it
#--------------------------------------
# if [ -e /usr/lib/systemd/system/jeos-firstboot.service ]; then
#     touch /var/lib/YaST2/reconfig_system
#     suseInsertService jeos-firstboot
# fi

#======================================
# Snapper quota requires a config file
#--------------------------------------
if [ -x /usr/bin/snapper ]; then
    echo "creating initial snapper config ..."
    # we can't call snapper here as the .snapshots subvolume
    # already exists and snapper create-config doens't like
    # that.
    cp /etc/snapper/config-templates/default /etc/snapper/configs/root
    baseUpdateSysConfig /etc/sysconfig/snapper SNAPPER_CONFIGS root
fi

#======================================
# Disable systemd-firstboot
#--------------------------------------
# While it's a good idea to adapt the image according to user's preferences,
# people seem to want to run headless systems, so stalling the boot is a
# really bad idea. Disable firstboot for now ... (boo#1020019)
# rm -f /usr/lib/systemd/system/systemd-firstboot.service
rm -f /usr/lib/systemd/system/sysinit.target.wants/systemd-firstboot.service


#======================================
# Latest openssh disables root login by default
# Re-enable it as we do not use 1st boot for now,
# so root is the only account by default
#--------------------------------------

echo -e "\n# Allow root login on ssh\nPermitRootLogin yes" >> /etc/ssh/sshd_config

#======================================
# Load panel-tfp410 before omapdrm
#---
if [[ "$kiwi_iname" == *"-beagle" || "$kiwi_iname" == *"-panda" ]]; then
    cat > /etc/modprobe.d/50-omapdrm.conf <<EOF
# Ensure that panel-tfp410 is loaded before omapdrm
softdep omapdrm pre: panel-tfp410
EOF
fi

#======================================
# Load cros-ec-keyb (on board keyboard), tune touchpad 
# and map function keys for chromebook (snow)
#---
if [[ "$kiwi_iname" == *"-chromebook" ]]; then
    cat > /etc/modules-load.d/cros-ec-keyb.conf <<EOF
# Load cros-ec-keyb (on board keyboard)
cros-ec-keyb
EOF

    cat > /etc/X11/xorg.conf.d/50-touchpad.conf << EOF
Section "InputClass"
	Identifier "touchpad"
	MatchIsTouchpad "on"
	Option "FingerHigh" "5"
	Option "FingerLow" "5"
EndSection
EOF

# FIXME: This config will be lost once Xmodmap package will be updated
    cat > /etc/X11/Xmodmap << EOF
! Map the Chrombook function keys
keycode 67 = XF86Back F1 F1 F1 F1 XF86Switch_VT_1
keycode 68 = XF86Forward F2 F2 F2 F2 XF86Switch_VT_2
keycode 69 = XF86Refresh F3 F3 F3 F3 XF86Switch_VT_3
!keycode 70 =  F4 F4 XF86Switch_VT_4
keycode 71 = XF86Display F5 F5 F5 F5 XF86Switch_VT_5
keycode 72 = XF86MonBrightnessDown F6 F6 F6 F6 XF86Switch_VT_6
keycode 73 = XF86MonBrightnessUp F7 F7 F7 F7 XF86Switch_VT_7
keycode 74 = XF86AudioMute F8 F8 F8 F8 XF86Switch_VT_8
keycode 75 = XF86AudioLowerVolume F9 F9 F9 F9 XF86Switch_VT_9
keycode 76 = XF86AudioRaiseVolume F10 F10 F10 F10 XF86Switch_VT_10
EOF

fi

#======================================
# Load useful modules not auto-loaded for i.MX6 boards (SabreLite)
#---
if [[ "$kiwi_iname" == *"-sabrelite" ]]; then
    cat > /etc/modules-load.d/imx6.conf <<EOF
# Load imx6q-cpufreq to make use of cpufreq
imx6q-cpufreq
EOF
fi

#======================================
# Import trusted keys
#--------------------------------------
for i in /usr/lib/rpm/gnupg/keys/gpg-pubkey*asc; do
    # importing can fail if it already exists
    rpm --import $i || true
done


#======================================
# Initrd fixes (for 2nd boot only. 1st boot modules are handled by *.kiwi files)
#--------------------------------------
if [[ "$kiwi_iname" == *"-arndale" ]] || [[ "$kiwi_iname" == *"-chromebook" ]]; then
    echo 'add_drivers+=" i2c-exynos5 tps65090-regulator sdhci-pltfm sdhci-s3c mmc_core mmc_block dwc3-exynos dw_dmac dw_mmc dw_wdt dw_mmc-exynos dw_mmc-pltfm dw_dmac dw_dmac_core usb-storage uas usbcore usb-common ehci-hcd ehci-exynos phy-exynos-usb2 phy-generic phy-exynos-dp-video phy-exynos-mipi-video exynosdrm analogix_dp mwifiex_sdio pwrseq_simple btmrvl_sdio "' >  /etc/dracut.conf.d/exynos_modules.conf
fi

if [[ "$kiwi_iname" == *"-chromebook" ]]; then
    echo 'add_drivers+=" cros_ec_devs nxp_ptn3460 pwm-samsung  i2c_mux i2c_arb_gpio_challenge "' >> /etc/dracut.conf.d/exynos_modules.conf
fi

if [[ "$kiwi_iname" == *"-beagle" || "$kiwi_iname" == *"-panda" ]]; then
    # OMAP DMA is needed for MMC
    echo 'add_drivers+=" omap_dma "' > /etc/dracut.conf.d/omap_modules.conf
fi

if [[ "$kiwi_iname" == *"-beaglebone" ]]; then
    echo 'add_drivers+=" tda998x "' > /etc/dracut.conf.d/beagleboneblack_modules.conf
fi

if [[ "$kiwi_iname" == *"-pine64" ]] || [[ "$kiwi_iname" == *"-cubietruck" ]] || [[ "$kiwi_iname" == *"-cubieboard"* ]] || [[ "$kiwi_iname" == *"olinuxino"* ]]; then
    echo 'add_drivers+=" fixed sunxi-mmc axp20x-regulator axp20x-rsb "' > /etc/dracut.conf.d/sunxi_modules.conf
fi

if [[ "$kiwi_iname" == *"-sabrelite" ]]; then
    echo 'add_drivers+=" ahci_imx imxdrm imx_ipuv3_crtc imx_ldb "' > /etc/dracut.conf.d/sabrelite_modules.conf
fi

# In 4.8 sdhci_bcm2835 was dropped in favor of sdhci-iproc.
# Leave sdhci_bcm2835 in place for 4.7 and :Contrib:RaspberryPi{,2}.

if [[ "$kiwi_iname" == *"-raspberrypi1" ]]; then
    echo 'add_drivers+=" sdhci_bcm2835 sdhci-iproc bcm2835_dma dwc2 "' > /etc/dracut.conf.d/raspberrypi_modules.conf
    echo '# The vc4 driver does not support rpi1 (yet)' > /etc/modprobe.d/90-blacklist-vc4.conf
    echo '# so blacklist it to use simplefb instead. (boo#996614)' >> /etc/modprobe.d/90-blacklist-vc4.conf
    echo 'blacklist vc4' >> /etc/modprobe.d/90-blacklist-vc4.conf
fi

if [[ "$kiwi_iname" == *"-raspberrypi2" ]]; then
    echo 'add_drivers+=" sdhci_bcm2835 sdhci-iproc bcm2835_dma mmc_block dwc2 "' > /etc/dracut.conf.d/raspberrypi_modules.conf
fi

if [[ "$kiwi_iname" == *"-raspberrypi" ]]; then
    echo 'add_drivers+=" sdhci-iproc bcm2835-sdhost bcm2835_dma mmc_block dwc2 "' > /etc/dracut.conf.d/raspberrypi_modules.conf
fi

if [[ "$kiwi_iname" == *"-socfpgade0nanosoc" ]]; then
    echo 'add_drivers+=" dw_mmc-pltfm mmc_core mmc_block dw_mmc dw_wdt "' > /etc/dracut.conf.d/socfpga_modules.conf
fi

if [[ "$kiwi_iname" == *"-odroidc2" || "$kiwi_iname" == *"-nanopik2" ]]; then
    echo 'add_drivers+=" fixed gpio-regulator "' > /etc/dracut.conf.d/meson_gxbb_modules.conf
fi

if [[ "$kiwi_iname" == *"-efi"* ]]; then
    echo 'add_drivers+=" gpio-regulator virtio_gpu scsi_mod "' > /etc/dracut.conf.d/efi_modules.conf
fi

if [[ "$kiwi_iname" == *"-rock64" ]]; then
    echo 'add_drivers+=" dw_mmc-rockchip fixed rk808 rk808-regulator i2c-rk3x "' > /etc/dracut.conf.d/rock64_modules.conf
fi

if [[ "$kiwi_iname" == *"-hikey960" ]]; then
    echo 'add_drivers+=" reset-hi3660 k3dma dw_mmc-k3 fixed hi6421-pmic-core hi6421v530-regulator ufs_hisi "' > /etc/dracut.conf.d/hikey960_modules.conf
fi



#==========================================
# Kiwi-ng: hook-scripts/* does not work anymore, so we must use dracut hooks instead.
# See: http://suse.github.io/kiwi/overview/workflow.html#boot-image-hook-scripts
#------------------------------------------
if [[ "$kiwi_iname" == *"-chromebook" ]]; then
	mkdir -p /usr/lib/dracut/modules.d/90chromebook
	
	cat >> /etc/dracut.conf.d/90chromebook.conf <<-"EOF"
add_dracutmodules+=" chromebook "
EOF

	cat >> /usr/lib/dracut/modules.d/90chromebook/fix_partition.sh <<-"EOF"
#!/bin/bash

type deactivate_all_device_maps >/dev/null 2>&1 || . /lib/kiwi-lib.sh
type lookup_disk_device_from_root >/dev/null 2>&1 || . /lib/kiwi-lib.sh
diskname=$(lookup_disk_device_from_root)

deactivate_all_device_maps

# Enable bootflag on partition 3 (u-boot now looks for bootscripts/dtb on bootable partitions only)
parted $diskname set 3 boot on

# CGPT magic
cgpt add -t kernel -i 2 -S 1 -T 5 -P 10 -l U-BOOT $diskname

systemctl daemon-reload
EOF
	cat >> /usr/lib/dracut/modules.d/90chromebook/module-setup.sh <<-"EOF" 
#!/bin/bash

check() {
	require_binaries cgpt parted
	return 0
}

depends() {
	echo rootfs-block dm kiwi-lib
	return 0
}

installkernel() {
	# load required kernel modules when needed
	return 0
}

install() {
	declare moddir=${moddir}
	inst_multiple cgpt parted
	inst_hook pre-mount 30 "${moddir}/fix_partition.sh"
}
EOF

fi

#======================================
# COnfiguration for Pinephone
#--------------------------------------
if [[ "$kiwi_iname" == *"-pinephone"* ]]; then

    # User pine needed with numerical password for unlocking PHOSH
    useradd -m pine
    echo -e "1234\n1234" | (passwd pine)

    groupadd plugdev
    groupadd netdev
    usermod -a -G plugdev pine
    usermod -a -G audio pine
    usermod -a -G video pine
    usermod -a -G dialout pine
    usermod -a -G render pine
    usermod -a -G input pine
    usermod -a -G netdev pine

    # Add pine user to sudoers
    echo "pine  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/pine
    # Set Hostname
    echo "openSUSE" > /etc/hostname
    # We only use NetworkManager for Calls and Wireless
    systemctl disable wicked || true
    systemctl enable NetworkManager || true
    systemctl disable NetworkManager-wait-online.service
    systemctl enable ofono || true
    # As some apps are currently not adapted to work in PHOSH we delete the icons from Desktop Manager
    rm -f /usr/share/applications/YaST2/org.opensuse.yast.CheckMedia.desktop
    rm -f /usr/share/applications/YaST2/messages.desktop
    rm -f /usr/share/applications/yelp.desktop

else
    # if NetworkManager is installed, then we want to use it... unfortunately, wicked gets pulled in always:
    # added wicked-service@openSUSE:Factory:ARM/standard because of sysconfig:/sbin/ifup :-(
    if rpm -q NetworkManager; then
        systemctl disable network || true
        systemctl enable NetworkManager || true
    fi
fi

#======================================
# Umount kernel filesystems
#--------------------------------------
baseCleanMount

exit 0
