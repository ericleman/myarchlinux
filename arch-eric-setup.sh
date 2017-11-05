#!/bin/bash
set -x

setup() {
  echo '************************************************'
  echo '************************************************'
  echo '**************** Getting network'
  dhcpcd 
  sleep 5

  echo '************************************************'
  echo '************************************************'
  echo '**************** Creating partitions'
  parted -s /dev/sda mklabel gpt \
    mkpart ESP fat32 1 512M \
    mkpart primary linux-swap 512M 4G \
    mkpart primary ext3 4G 100% \
    set 1 boot on

  echo '************************************************'
  echo '************************************************'
  echo '**************** Formatting filesystems'
  mkfs.fat -F32  /dev/sda1 
  mkfs.ext4 -F /dev/sda3 
   
  mkswap /dev/sda2 
  swapon /dev/sda2 
   
  echo '************************************************'
  echo '************************************************'
  echo '**************** Mounting filesystems'
  mount /dev/sda3 /mnt 
  mkdir /mnt/boot 
  mount /dev/sda1 /mnt/boot 

  echo '************************************************'
  echo '************************************************'
  echo '**************** Installing base system'
  sleep 5
  cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup 
  sed -i 's%Server%#Server%g' /etc/pacman.d/mirrorlist
  sed -i 's%#Server = http://mir.archlinux.fr/$repo/os/$arch%Server = http://mir.archlinux.fr/$repo/os/$arch%g' /etc/pacman.d/mirrorlist

  pacstrap /mnt base base-devel
  pacstrap /mnt mc mtools dosfstools lsb-release ntfs-3g exfat-utils syslog-ng 
  genfstab -U -p /mnt >> /mnt/etc/fstab 
  pacstrap /mnt grub os-prober efibootmgr 

  echo '************************************************'
  echo '************************************************'
  echo '**************** Chrooting into installed system to continue setup...'
  sleep 5
  cp $0 /mnt/arch-eric-setup.sh
  cp -R ./scripts/ /mnt/
  arch-chroot /mnt ./arch-eric-setup.sh chroot

  if [ -f /mnt/arch-eric-setup.sh ]
  then
    echo '**************** ERROR: Something failed inside the chroot, not unmounting filesystems so you can investigate.'
    echo '**************** Make sure you unmount everything before you try to run this script again.'
  else
    echo '**************** Unmounting filesystems'
    umount -R /mnt
    echo '**************** Done! Reboot system.'
  fi
}

configure() {
  echo '************************************************'
  echo '************************************************'
  echo '**************** Installing additional packages'
  sed -i 's%#TotalDownload%TotalDownload\nILoveCandy%g' /etc/pacman.conf
  sed -i 's%#Color%Color%g' /etc/pacman.conf
  echo '[multilib]' >> /etc/pacman.conf
  echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
  echo '' >> /etc/pacman.conf
  echo '[archlinuxfr]' >> /etc/pacman.conf
  echo 'SigLevel = Never ' >> /etc/pacman.conf
  echo 'Server = http://repo.archlinux.fr/$arch ' >> /etc/pacman.conf

  local packages=''

  # Xserver
  packages+=' xorg-apps xorg-server xorg-xinit xorg-drivers' 
  # QT5
  packages+=' qt5-base qt5-webkit python-pyqt5 pyqt5-common'
  # VirtualBox
  packages+=' virtualbox-guest-utils virtualbox-guest-modules-arch' 
  # General utilities/libraries
  packages+=' arch-install-scripts acpi_call bash-completion btrfs-progs b43-fwcutter bluez-firmware clonezilla crda dialog dmraid dosfstools exfat-utils f2fs-tools fuse gpm gptfdisk grub grml-zsh-config hdparm jfsutils jsoncpp ipw2100-fw ipw2200-fw linux-atm mtools mlocate mkinitcpio-nfs-utils nfs-utils nilfs-utils ntfs-3g ntp openssh rsync parted partclone partimage refind-efi reflector reiserfsprogs rfkill rsync sdparm sudo squashfs-tools usb_modeswitch wget wireless-regdb xfsprogs zd1211-firmware'
  # Audio and Codecs
  packages+=' alsa-firmware alsa-plugins alsa-lib dcadec ffmpeg2.8 gst-libav gst-plugins-base gst-plugins-good gstreamer libdvbpsi libebml libmad libmatroska libtar libupnp pamixer pulseaudio pulseaudio-alsa pavucontrol'
  # Libreoffice
  packages+=' libreoffice-fresh'
  # XFCE4
  packages+=' xfce4-settings xfce4-power-manager xfce4-notifyd'
  # OpenBox
  packages+=' openbox obconf oblogout lxappearance lxappearance-obconf tint2 screenfetch feh compton volumeicon hardinfo catfish baobab simplescreenrecorder'
  # Themes
  packages+=' arc-gtk-theme arc-icon-theme' 
  # LightDM
  packages+=' lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings'
  # Network
  packages+=' avahi glib-networking networkmanager networkmanager-dispatcher-ntpd network-manager-applet wireless_tools wpa_actiond wpa_supplicant'

  ## Je split pacman -Syy en 2 fois pour éviter que des liens se perdent pendant la synchro qui peut durer 20 min
  #echo "Package lists: $packages"
  #sleep 5
  #pacman -Syy --noconfirm $packages
  #packages=''

  # File management
  packages+=' file-roller thunar tumbler xdg-user-dirs-gtk gvfs udisks2 udiskie'
  # Applications
  packages+=' audacious audacious-plugins galculator gparted gpicview gsimplecal gnome-system-monitor gnome-disk-utility'
  # Applications
  packages+=' chromium pepper-flash vlc qt4'
  # Utilities
  packages+=' arandr termite dialog gksu htop imagemagick intltool libmpdclient lm_sensors lsb-release numlockx p7zip playerctl polkit lxsession sudo pygobject-devel python-docopt python2-gobject2 python2-dbus python2-lxml python2-xdg scrot unrar unzip wmctrl w3m'
  # Java stuff
  packages+=' jre8-openjdk icedtea-web'
  # Fonts
  packages+=' ttf-ubuntu-font-family ttf-roboto'
  # Yaourt
  packages+=' yaourt'
  # Wine
  packages+=' winetricks lib32-libpulse' # lib32-libpulse for sound with PulseAudio
  # For laptops
  packages+=' xf86-input-libinput xf86-input-keyboard xf86-input-mouse'
  #packages+=' xf86-input-synaptics' # is synaptics better than libinput?

  echo "Package lists: $packages"
  sleep 5
  pacman -Syy --noconfirm $packages

  echo '************************************************'
  echo '************************************************'
  echo '**************** Configuring sudo'
  cp /scripts/sudoers /etc/sudoers
  chmod 440 /etc/sudoers

  echo '************************************************'
  echo '************************************************'
  echo '**************** Setting root password'
  echo -en "mypassword\nmypassword" | passwd

  echo '************************************************'
  echo '************************************************'
  echo '**************** Creating initial user'
  useradd -m -s /bin/bash -G adm,systemd-journal,wheel,rfkill,games,network,video,audio,optical,floppy,storage,scanner,power,input -c "Eric" eric
  echo -en "mypassword\nmypassword" | passwd "eric"

  echo '************************************************'
  echo '************************************************'
  echo '**************** Installing AUR packages'
  
  su eric -c "yaourt -S --noconfirm openbox-arc-git"
  su eric -c "yaourt -S --noconfirm obmenu-generator"
  su eric -c "yaourt -S --noconfirm xfdashboard"
  # su eric -c "yaourt -S --noconfirm skippy-xd-git"
  # su eric -c "yaourt -S --noconfirm networkmanager-dmenu-git"
  # su eric -c "yaourt -S --noconfirm papirus-icon-theme-git"
  # su eric -c "yaourt -S --noconfirm mkinitcpio-openswap"
  # su eric -c "yaourt -S --noconfirm pacli"
  # su eric -c "yaourt -S --noconfirm pamac-tray-appindicator"
  su eric -c "yaourt -S --noconfirm sqlectron-gui"
  su eric -c "yaourt -S --noconfirm libinput-gestures"
  su eric -c "yaourt -S --noconfirm i3lock-fancy-git"
  # su eric -c "yaourt -S --noconfirm kazam"
  # su eric -c "yaourt -S --noconfirm kalu"
  su eric -c "yaourt -S --noconfirm obkey-git"
  su eric -c "yaourt -S --noconfirm pamac-aur"
  su eric -c "yaourt -S --noconfirm sublime-text-dev"
  # su eric -c "yaourt -S --noconfirm broadcom-wl"

  echo '************************************************'
  echo '************************************************'
  echo '**************** Setting hostname'
  echo "archlinux" > /etc/hostname

  echo '************************************************'
  echo '************************************************'
  echo '**************** Setting timezone'
  ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime

  echo '************************************************'
  echo '************************************************'
  echo '**************** Setting locale'
  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
  echo "en_DK.UTF-8 UTF-8" >> /etc/locale.gen
  locale-gen
  echo 'LANG=en_US.UTF-8' >> /etc/locale.conf
  echo 'LC_TIME=en_DK.UTF-8' >> /etc/locale.conf

  echo '************************************************'
  echo '************************************************'
  echo '**************** Setting console keymap'
  #create_mac_kmap
  #gzip /usr/share/kbd/keymaps/mac/all/mac-fr-ext_new.kmap
  #mv /usr/share/kbd/keymaps/mac/all/mac-fr-ext_new.kmap.gz /usr/share/kbd/keymaps/mac/all/mac-fr-ext_new.map.gz
  #echo 'KEYMAP="mac-fr-ext_new"' >> /etc/vconsole.conf
  echo 'KEYMAP="fr-pc"' >> /etc/vconsole.conf
  echo 'CONSOLEFONT="lat9w-16"' >> /etc/vconsole.conf

  echo '************************************************'
  echo '************************************************'
  echo '**************** Setting initial daemons'
  sleep 5
  systemctl enable NetworkManager
  systemctl enable syslog-ng
  systemctl enable lightdm 
  systemctl enable ntpd 

  echo '************************************************'
  echo '************************************************'
  echo '**************** Configuring bootloader'
  sleep 5
  mkinitcpio -p linux 
  grub-mkconfig -o /boot/grub/grub.cfg 
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck 
  mkdir /boot/EFI/boot 
  cp /boot/EFI/arch_grub/grubx64.efi /boot/EFI/boot/bootx64.efi 

  echo '************************************************'
  echo '************************************************'
  echo '**************** Configure OpenBox'
  cp /scripts/bashrc /home/eric/.bashrc
  chown eric /home/eric/.bashrc
  chmod 644 /home/eric/.bashshrc

  su eric -c "mkdir -p /home/eric/.config/termite"
  cp /scripts/termite /home/eric/.config/termite/config
  chown eric /home/eric/.config/termite/config
  chmod 644 /home/eric/.config/termite/config

  su eric -c "cp -R /etc/xdg/openbox /home/eric/.config/"
  cp /scripts/autostart /home/eric/.config/openbox/autostart
  chown eric /home/eric/.config/openbox/autostart
  chmod 644 /home/eric/.config/openbox/autostart
  cp /scripts/rc.xml /home/eric/.config/openbox/rc.xml
  chown eric /home/eric/.config/openbox/rc.xml
  chmod 644 /home/eric/.config/openbox/rc.xml

  su eric -c "mkdir -p /home/eric/.config/gtk-3.0"
  cp /scripts/gtk3 /home/eric/.config/gtk-3.0/settings.ini
  chown eric /home/eric/.config/gtk-3.0/settings.ini
  chmod 644 /home/eric/.config/gtk-3.0/settings.ini
  mkdir -p /root/.config/gtk-3.0
  cp /scripts/gtk3 /root/.config/gtk-3.0/settings.ini

  cp /scripts/gtk2 /home/eric/.gtkrc-2.0
  chown eric /home/eric/.gtkrc-2.0
  chmod 644 /home/eric/.gtkrc-2.0
  cp /scripts/gtk2 /root/.gtkrc-2.0

  su eric -c "mkdir -p /home/eric/.config/volumeicon"
  cp /scripts/volumeicon /home/eric/.config/volumeicon/volumeicon
  chown eric /home/eric/.config/volumeicon/volumeicon
  chmod 644 /home/eric/.config/volumeicon/volumeicon

  su eric -c "mkdir -p /home/eric/.config/Thunar"
  cp /scripts/uca.xml /home/eric/.config/Thunar/uca.xml
  chown eric /home/eric/.config/Thunar/uca.xml
  chmod 644 /home/eric/.config/Thunar/uca.xml

  cp /scripts/xprofile /home/eric/.xprofile
  chown eric /home/eric/.xprofile
  chmod 644 /home/eric/.xprofile

  cp /scripts/compton.conf /home/eric/.config/compton.conf
  chown eric /home/eric/.config/compton.conf
  chmod 644 /home/eric/.config/compton.conf

  cp /scripts/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf
  cp /scripts/pamac.conf /etc/pamac.conf
  cp /scripts/libinput-gestures.conf /etc/libinput-gestures.conf
  cp /scripts/49-nopasswd_global.rules /etc/polkit-1/rules.d/49-nopasswd_global.rules

  cp /scripts/oblogout.conf /etc/oblogout.conf
  mkdir /usr/share/themes/AL-adeos-branco-mono/
  git clone https://github.com/ARCHLabs/Archlabs-Oblogout-Themes.git
  cp -R Archlabs-Oblogout-Themes/adeos-branco-mono/oblogout/ /usr/share/themes/AL-adeos-branco-mono/
  rm -rf /Archlabs-Oblogout-Themes


  su eric -c "mkdir -p /home/eric/.config/obmenu-generator"
  cp /scripts/obmenu-config.pl /home/eric/.config/obmenu-generator/config.pl
  chown eric /home/eric/.config/obmenu-generator/config.pl
  chmod 644 /home/eric/.config/obmenu-generator/config.pl
  cp /scripts/obmenu-schema.pl /home/eric/.config/obmenu-generator/schema.pl
  chown eric /home/eric/.config/obmenu-generator/schema.pl
  chmod 644 /home/eric/.config/obmenu-generator/schema.pl
  su eric -c "obmenu-generator -p"

  su eric -c "mkdir -p /home/eric/.config/xfce4/xfconf/xfce-perchannel-xml"
  cp /scripts/xfce4-power-manager.xml /home/eric/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
  chown eric /home/eric/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
  chmod 644 /home/eric/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml

  su eric -c "mkdir -p /home/eric/.config/tint2"
  cp /scripts/tint2rc /home/eric/.config/tint2/tint2rc
  chown eric /home/eric/.config/tint2/tint2rc
  chmod 644 /home/eric/.config/tint2/tint2rc


  sed -i 's%border.width: 1%border.width: 0%g' /usr/share/themes/Arc-Dark/openbox-3/themerc
  sed -i 's%padding.height: 4%padding.height: 1%g' /usr/share/themes/Arc-Dark/openbox-3/themerc

  mkdir /usr/share/backgrounds
  cp /scripts/NOFQh9F-arch-linux-wallpaper.png /usr/share/backgrounds/NOFQh9F-arch-linux-wallpaper.png
  cp /scripts/NOFQh9F-arch-linux-wallpaper.png /usr/share/backgrounds/SIoLm5X.png
  cp /scripts/NOFQh9F-arch-linux-wallpaper.png /usr/share/backgrounds/e3ds1gR.jpg
  cp /scripts/NOFQh9F-arch-linux-wallpaper.png /usr/share/backgrounds/hfcCKRj.jpg
  cp /scripts/NOFQh9F-arch-linux-wallpaper.png /usr/share/backgrounds/yskbiPT.jpg
  cp /scripts/fehbg /home/eric/.fehbg
  chown eric /home/eric/.fehbg
  chmod 744 /home/eric/.fehbg
  
  su eric -c "xfconf-query -c xfdashboard -p /components/windows-view/scroll-event-changes-workspace -n -t bool -s true"
  su eric -c "xfconf-query -c xfdashboard -p /theme -n -t string -s xfdashboard-dark"
  su eric -c "xfconf-query -c xfdashboard -p /always-launch-new-instance -n -t bool -s false"
  su eric -c "libinput-gestures-setup autostart"

  rm /arch-eric-setup.sh
}


create_mac_kmap() {
    cat > /usr/share/kbd/keymaps/mac/all/mac-fr-ext_new.kmap <<EOF
# marc.shapiro@inria.fr 4-october-1998
# French Macintosh keyboard
# attempt to align to the standard Mac meaning of keys.
# mostly intuitive!
# option=AltGr; Apple/Command=Alt (==> meta)
# changes : Etienne Herlent <eherlent@linux-france.org> june 2000
# adapted to "linux" keycodes : 
#         Martin Costabel <costabel@wanadoo.fr> 3-jan-2001
# changes for '=' symbol from the numeric keybap to work :
#         Etienne Herlent <eherlent@linux-france.org> 14-jan-2001
# adapted for Latin9 alphabet (ISO-8859-15) :
#         Etienne Herlent <eherlent@linux-france.org> 18-mar-2005
# TODO: CONTROL AND META COMBINATIONS

charset "iso-8859-1"
#keymaps 0-9,11-12

compose as usual for "iso-8859-1"
alt_is_meta

keycode 1 = Escape  
    alt keycode 1 = Meta_Escape
  shift alt   keycode 1 = Meta_Escape

# 1st row
keycode 41 = at     numbersign
    altgr keycode 41 =  periodcentered
    alt keycode 41 =  Meta_at
    control keycode 41 =  nul
  shift alt keycode 41 =  Meta_numbersign

keycode  2 = ampersand        one VoidSymbol  dead_acute
    alt keycode 2 = Meta_ampersand
  shift alt   keycode 2 = Meta_one

keycode  3 = eacute           two ediaeresis  Eacute
  shift alt keycode 3 = Meta_two

keycode  4 = quotedbl          three
    alt keycode 4 = Meta_quotedbl
  shift alt keycode 4 = Meta_three

keycode  5 = apostrophe        four
    alt keycode 5 = Meta_apostrophe
  shift alt keycode 5 = Meta_four

keycode  6 = parenleft          five             braceleft  bracketleft
    alt keycode 6 = Meta_parenleft
  shift alt keycode 6 = Meta_five

# **** insert meta, control
keycode   7 = section            six  paragraph aring
    shift alt keycode 7 = Meta_six

keycode   8 = egrave           seven            guillemotleft guillemotright
    shift alt keycode 8 = Meta_seven

keycode   9 = exclam         eight  exclamdown  Ucircumflex
    alt keycode 9 = Meta_exclam
  shift alt keycode 9 = Meta_eight

keycode  10 = ccedilla         nine Ccedilla  Aacute
    shift alt keycode 10 =  Meta_nine

keycode  11 = agrave           zero oslash
    shift alt keycode 11 =  Meta_zero

keycode 12 = parenright   degree          braceright  bracketright
    alt keycode 12 =  Meta_parenright

keycode 13 = minus      underscore
    alt keycode 13 =  Meta_minus
  shift   alt keycode 13 =  Meta_underscore
  shift control keycode 13 =  Control_underscore

keycode 14 = Delete   BackSpace
    alt     keycode  14 = Meta_Delete
  shift alt     keycode  14 = Meta_Delete

# 2nd row

keycode 15 = Tab  
    alt     keycode  15 = Meta_Tab
  shift alt     keycode  15 = Meta_Tab

keycode  16 = +a  +A  ae  AE
  control keycode 16 = Control_a
keycode  17 = +z  +Z  Acircumflex Aring
keycode  18 = +e  +E  ecircumflex Ecircumflex
keycode  19 = +r  +R  registered  currency
keycode  20 = +t  +T
keycode  21 = +y  +Y  Uacute  VoidSymbol
keycode  22 = +u  +U  VoidSymbol  ordfeminine
keycode  23 = +i  +I  icircumflex idiaeresis
keycode  24 = +o  +O  oe  OE
keycode  25 = +p  +P  VoidSymbol  Ugrave
keycode  26 = dead_circumflex   dead_diaeresis  ocircumflex Ocircumflex
    control keycode 26 =  Control_asciicircum
keycode 27 = dollar     asterisk  euro  yen
    alt keycode 27 =  Meta_dollar
  shift alt keycode 27 =  Meta_dollar

keycode 28 = Return 

# 3d row

keycode  58 = Caps_Lock
keycode  30 = +q  +Q  acircumflex Agrave
  control keycode 30 = Control_q
keycode  31 = +s  +S  Ograve  VoidSymbol
keycode  32 = +d  +D
keycode  33 = +f  +F
keycode  34 = +g  +G
keycode  35 = +h  +H  Igrave  Icircumflex
keycode  36 = +j  +J  Idiaeresis  Iacute
keycode  37 = +k  +K  Egrave  Ediaeresis
keycode  38 = +l  +L  notsign bar
#   alt altgr keycode 38 = Meta_notsign # Doesn't work???
  shift alt altgr keycode 38 = Meta_bar
keycode  39 = +m  +M  mu  Oacute
keycode  40 = ugrave    percent Ugrave  ucircumflex
  shift alt keycode 40 =  Meta_percent
keycode  43 = dead_grave  pound   at  numbersign
    alt keycode 43 =  Meta_grave
# shift alt keycode 43 =  Meta_sterling # doesn't work ?
#   altgr keycode 43 =  Meta_at
# shift altgr keycode 43 =  Meta_numbersign

# 4th row
keycode  42 = Shift

keycode  86 = less    greater

keycode  44 = +w  +W
keycode  45 = +x  +X
keycode  46 = +c  +C  copyright cent
keycode  47 = +v  +V
keycode  48 = +b  +B  ssharp

keycode  49 = +n  +N    dead_tilde  asciitilde
keycode 50 = comma      question  VoidSymbol  questiondown
  shift control keycode 50 =  Delete
keycode 51 = semicolon      period  VoidSymbol  periodcentered
keycode 52 = colon      slash   division  backslash
  shift altgr control keycode 52 =  Control_backslash
keycode 53 = equal      plus  VoidSymbol  plusminus

# 5th row
keycode  29 = Control

# Option key:
keycode  56 = AltGr

# Apple/Command key:
keycode  125 = Alt

keycode  57 = space space nobreakspace  nobreakspace
  control keycode  57 = nul

# 'fn' (yellow key labels)

## TO DO
 keycode 55 = KP_Multiply

# function keys

keycode    59 = F1               F11              Console_13
  control keycode    59 = F1
  alt     keycode    59 = Console_1
  control alt     keycode    59 = Console_1
keycode    60 = F2               F12              Console_14
  control keycode    60 = F2
  alt     keycode    60 = Console_2
  control alt     keycode    60 = Console_2
keycode   61 = F3               F13              Console_15
  control keycode  61 = F3
  alt     keycode  61 = Console_3
  control alt     keycode  61 = Console_3
keycode    62 = F4               F14              Console_16
  control keycode    62 = F4
  alt     keycode    62 = Console_4
  control alt     keycode    62 = Console_4
keycode  63 = F5               F15              Console_17
  control keycode  63 = F5
  alt     keycode  63 = Console_5
  control alt     keycode  63 = Console_5
keycode  64 = F6               F16              Console_18
  control keycode  64 = F6
  alt     keycode  64 = Console_6
  control alt     keycode  64 = Console_6
keycode  65 = F7               F17              Console_19
  control keycode  65 = F7
  alt     keycode  65 = Console_7
  control alt     keycode  65 = Console_7
keycode   66 = F8               F18              Console_20
  control keycode   66 = F8
  alt     keycode   66 = Console_8
  control alt     keycode   66 = Console_8
keycode    67 = F9               F19              Console_21
  control keycode    67 = F9
  alt     keycode    67 = Console_9
  control alt     keycode    67 = Console_9
keycode    68 = F10              F20              Console_22
  control keycode     68 = F10
  alt     keycode     68 = Console_10
  control alt     keycode     68 = Console_10
keycode  69 = Num_Lock
keycode  70 = Scroll_Lock      Show_Memory      Show_Registers
  control keycode     70 = Show_State
  alt     keycode     70 = Scroll_Lock
keycode  71 = seven seven
  alt     keycode  71 = Ascii_7
keycode  72 = eight eight
  alt     keycode  72 = Ascii_8
keycode  73 = nine  nine
  alt     keycode  73 = Ascii_9
keycode  74 = KP_Subtract
keycode  75 = four  four
  alt     keycode  75 = Ascii_4
keycode  76 = five  five
  alt     keycode  76 = Ascii_5
keycode  77 = six six
  alt     keycode  77 = Ascii_6
keycode  78 = KP_Add
keycode  79 = one one
  alt     keycode  79 = Ascii_1
keycode  80 = two two
  alt     keycode  80 = Ascii_2
keycode  81 = three
  alt     keycode  81 = Ascii_3
keycode  82 = zero  zero
  alt     keycode  82 = Ascii_0
keycode  83 = comma period
# altgr   control keycode  65 = Boot
  control alt     keycode  83 = Boot
keycode   87 = F11      F11      Console_23
  control keycode   87 = F11
  alt     keycode   87 = Console_11
  control alt     keycode   87 = Console_11
keycode     88 = F12    F12       Console_24
  control keycode     88 = F12
  alt     keycode     88 = Console_12
  control alt     keycode     88 = Console_12
keycode  96 = KP_Enter
keycode  98 = KP_Divide
keycode  117 = equal
keycode  103 = Up
keycode  104 = Prior
  shift   keycode    104 = Scroll_Backward
keycode  105 = Left
        alt     keycode  105 = Decr_Console
keycode  106 = Right
        alt     keycode  106 = Incr_Console
keycode  108 = Down
keycode  109 = Next
  shift   keycode    109 = Scroll_Forward
keycode 119 = Pause
keycode 110 = Insert
keycode 111 = Remove
keycode 102 = Home
keycode 107 = End
keycode  54 = Shift
keycode 124 = AltGr

string F1 = "\033[[A"
string F2 = "\033[[B"
string F3 = "\033[[C"
string F4 = "\033[[D"
string F5 = "\033[[E"
string F6 = "\033[17~"
string F7 = "\033[18~"
string F8 = "\033[19~"
string F9 = "\033[20~"
string F10 = "\033[21~"
string F11 = "\033[23~"
string F12 = "\033[24~"
string F13 = "\033[25~"
string F14 = "\033[26~"
string F15 = "\033[28~"
string F16 = "\033[29~"
string F17 = "\033[31~"
string F18 = "\033[32~"
string F19 = "\033[33~"
string F20 = "\033[34~"
string Find = "\033[1~"
string Insert = "\033[2~"
string Remove = "\033[3~"
string Select = "\033[4~"
string Prior = "\033[5~"
string Next = "\033[6~"
string Macro = "\033[M"
string Pause = "\033[P"
string F21 = ""
string F22 = ""
string F23 = ""
string F24 = ""
string F25 = ""
string F26 = ""
#
EOF
}


if [ "$1" == "chroot" ]
then
    exec 2>&1 | tee /install.log 
    configure
else
    setup
fi
