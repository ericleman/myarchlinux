# myarchlinux
From archlinux  ISO from archlinux.org:

`loadkeys fr-pc` loqdkeys fr)pc

if Internet is no set:
`dhcpcd`

`wget https://github.com/ericleman/myarchlinux/tarball/master -O - | tar xz`

`cd ericleman*`

`chmod 777 arch-eric-setup.sh`

`./arch-eric-setup.sh PASSWORD`

## Then once installed:
just run this once the user is log in:
`/home/eric/gsettings.sh`

## Macbook:
If the ISO is for a Macbook, then:
`echo 'KEYMAP="mac-fr-ext_new"' >> /etc/vconsole.conf`

and in /home/eric/.xprofile, put:
`setxkbmap fr mac` instead of `setxkbmap fr`

and:
`sudo pacman -Rs virtualbox-guest-utils virtualbox-guest-modules-arch`

and for WiFi:
`git clone https://aur.archlinux.org/broadcom-wl.git`

`cd broadcom-wl` 

`makepkg -si` 

`sudo reboot now` 
 
