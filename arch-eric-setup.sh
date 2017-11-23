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
  cp $0 /mnt/arch-eric-setup.sh
  cp -R ./scripts/ /mnt/
  arch-chroot /mnt ./arch-eric-setup.sh chroot | tee /mnt/install.log

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
  sed -i 's%#IgnorePkg   =%IgnorePkg = postgresql postgresql-libs %g' /etc/pacman.conf

  local packages=''
  package +=  ' acpi_call'
  package +=  ' adwaita-icon-theme'
  package +=  ' arc-gtk-theme'
  package +=  ' arch-install-scripts'
  package +=  ' arc-icon-theme'
  package +=  ' b43-fwcutter'
  package +=  ' baobab'
  package +=  ' bash-completion'
  package +=  ' boost'
  package +=  ' boost-libs'
  package +=  ' btrfs-progs'
  package +=  ' chromium'
  package +=  ' cmake'
  package +=  ' crda'
  package +=  ' cronie'
  package +=  ' cython'
  package +=  ' dconf-editor'
  package +=  ' dialog'
  package +=  ' dmraid'
  package +=  ' dosfstools'
  package +=  ' efibootmgr'
  package +=  ' eog'
  package +=  ' exfat-utils'
  package +=  ' f2fs-tools'
  package +=  ' file-roller'
  package +=  ' gdm'
  package +=  ' git'
  package +=  ' gitg'
  package +=  ' gnome-backgrounds'
  package +=  ' gnome-calculator'
  package +=  ' gnome-calendar'
  package +=  ' gnome-characters'
  package +=  ' gnome-clocks'
  package +=  ' gnome-color-manager'
  package +=  ' gnome-control-center'
  package +=  ' gnome-disk-utility'
  package +=  ' gnome-font-viewer'
  package +=  ' gnome-keyring'
  package +=  ' gnome-logs'
  package +=  ' gnome-nettool'
  package +=  ' gnome-photos'
  package +=  ' gnome-screenshot'
  package +=  ' gnome-session'
  package +=  ' gnome-settings-daemon'
  package +=  ' gnome-shell'
  package +=  ' gnome-shell-extensions'
  package +=  ' gnome-sound-recorder'
  package +=  ' gnome-system-monitor'
  package +=  ' gnome-terminal'
  package +=  ' gnome-themes-standard'
  package +=  ' gnome-tweak-tool'
  package +=  ' gnome-weather'
  package +=  ' gptfdisk'
  package +=  ' grml-zsh-config'
  package +=  ' grub'
  package +=  ' gtk3-print-backends'
  package +=  ' gucharmap'
  package +=  ' icedtea-web'
  package +=  ' ipw2100-fw'
  package +=  ' ipw2200-fw'
  package +=  ' jre8-openjdk'
  package +=  ' linux-atm'
  package +=  ' lsb-release'
  package +=  ' mc'
  package +=  ' mkinitcpio-nfs-utils'
  package +=  ' mlocate'
  package +=  ' mousetweaks'
  package +=  ' mtools'
  package +=  ' mutter'
  package +=  ' nautilus'
  package +=  ' nautilus-sendto'
  package +=  ' networkmanager'
  package +=  ' nfs-utils'
  package +=  ' nilfs-utils'
  package +=  ' ntfs-3g'
  package +=  ' ntp'
  package +=  ' openssh'
  package +=  ' os-prober'
  package +=  ' partclone'
  package +=  ' parted'
  package +=  ' partimage'
  package +=  ' pepper-flash'
  package +=  ' python-pyparsing'
  package +=  ' python-pyside'
  package +=  ' refind-efi'
  package +=  ' reflector'
  package +=  ' rsync'
  package +=  ' rygel'
  package +=  ' screenfetch'
  package +=  ' sdparm'
  package +=  ' seahorse'
  package +=  ' sqlitebrowser'
  package +=  ' squashfs-tools'
  package +=  ' sushi'
  package +=  ' syslog-ng'
  package +=  ' tk'
  package +=  ' tracker'
  package +=  ' tracker-miners'
  package +=  ' usb_modeswitch'
  package +=  ' virtualbox-guest-modules-arch'
  package +=  ' virtualbox-guest-utils'
  package +=  ' vlc'
  package +=  ' wayland'
  package +=  ' wget'
  package +=  ' wireless-regdb'
  package +=  ' xdg-user-dirs-gtk'
  package +=  ' yaourt'
  package +=  ' zd1211-firmware'

  # Wine
  #packages+=' winetricks lib32-libpulse lib32-gnutls wine lib32-libldap lib32-mpg123'
  # Gnome
  #packages+=' gnome gnome-extra'
  #packages+=' gnome-shell baobab eog evince gdm gnome-calculator gnome-control-center gnome-disk-utility gnome-screenshot gnome-session gnome-settings-daemon gnome-shell-extenstion gnome-system-monitor gnome-terminal gnome-themes-standard  mousetweaks mutter nautilius  networkmanager sushi totem xdg-user-dirs-gtk gnome-weather gnome-calendar gnome-tweak-tool gnome-clocks gnome-characters'
  #packages+=' gdm'
  # Gnome includes gnome-shell and gnome-shell-extenstion but excludes gnome-weather and gnome-calendar and gnome-tweak-tool and gnome-clocks and gnome-characters
  # Libreoffice
  #packages+=' libreoffice-fresh'
  # Network MacBook
  # packages+=' broadcom-wl-dkms'

  echo "Package lists: $packages"
  sleep 5
  pacman -Syy --noconfirm $packages
  sleep 5

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
  useradd -m -s /bin/bash -G adm,systemd-journal,wheel,games,network,video,audio,optical,floppy,storage,scanner,power,input -c "Eric" eric
  echo -en "mypassword\nmypassword" | passwd "eric"

  echo '************************************************'
  echo '************************************************'
  echo '**************** Installing AUR packages'
  
  su eric -c "yaourt -S --noconfirm sublime-text-dev"
  su eric -c "yaourt -S --noconfirm gnome-shell-extension-topicons-plus"
  su eric -c "yaourt -S --noconfirm pamac-aur"
  su eric -c "yaourt -S --noconfirm gnome-shell-extension-easyscreencast"

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
  systemctl enable gdm 

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
  echo '**************** Configure Misc'
  cp /scripts/bashrc /home/eric/.bashrc
  chown eric /home/eric/.bashrc
  chmod 644 /home/eric/.bashrc

  cp /scripts/pamac.conf /etc/pamac.conf
  
  cp /scripts/xprofile /home/eric/.xprofile
  chown eric /home/eric/.xprofile
  chmod 644 /home/eric/.xprofile

  cp /scripts/gsettings.sh /home/eric/gsettings.sh
  chown eric /home/eric/gsettings.sh
  chmod 700 /home/eric/gsettings.sh
  #su eric -c "/home/eric/gsettings.sh"

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
    #exec > install.log 2>&1
    configure
else
    setup
fi
