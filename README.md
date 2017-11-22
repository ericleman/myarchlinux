# myarchlinux
On an existing archlinux environment, install archiso

`sudo pacman -S archiso`

`cp -r /usr/share/archiso/configs/releng ~/arch-installer`

`cd ~/arch-installer/airootfs/root/`

`git clone https://github.com/ericleman/myarchlinux.git`

`cp -a myarchlinux/. .`

`rm -rf myarchlinux`

## Macbook:
If the ISO is for a Macbook, then in ~/arch-installer/airootfs/root/arch-eric-setup.sh, uncomment these lines:

`#create_mac_kmap`

`#gzip /usr/share/kbd/keymaps/mac/all/mac-fr-ext_new.kmap`
  
`#mv /usr/share/kbd/keymaps/mac/all/mac-fr-ext_new.kmap.gz /usr/share/kbd/keymaps/mac/all/mac-fr-ext_new.map.gz`

`#echo 'KEYMAP="mac-fr-ext_new"' >> /etc/vconsole.conf`

And comment this one:

`echo 'KEYMAP="fr-pc"' >> /etc/vconsole.conf`

And in ~/arch-installer/airootfs/root/scripts/xprofile, put:

`setxkbmap fr mac` instead of `setxkbmap fr`

And in ~/arch-installer/airootfs/root/arch-eric-setup.sh comment:

`packages+=' virtualbox-guest-utils virtualbox-guest-modules-arch' `

## Then:
In ~/arch-installer/airootfs/root/arch-eric-setup.sh, change `mypassword` to the password to use for user and root. 

In ~/arch-installer/efiboot/loader/entries/ change archiso-x86_64-cd.conf and archiso-x86_64-usb.conf so the last line contains the name of the script arch-eric-setup.sh:
options archisobasedir=%INSTALL_DIR% archisolabel=%ARCHISO_LABEL% script=arch-eric-setup.sh

In ~/arch-installer/, type 

`sudo ./build.sh -v`

After a while it will create an ISO in  ~/arch-installer/out/. This ISO can be used to install Archlinux.

