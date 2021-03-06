gsettings set org.gnome.desktop.interface gtk-theme 'Paper'
gsettings set org.gnome.desktop.interface icon-theme 'Paper'
gsettings set org.gnome.desktop.interface cursor-theme 'Paper'
gsettings set org.gnome.shell.extensions.user-theme name 'Paper'
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'chromium.desktop', 'sublime_text_3.desktop']"
# for MacBook:
#gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'fr+mac')]"
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'fr')]"
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-show-seconds true
gsettings set org.gnome.desktop.session idle-delay 0

gsettings set org.gnome.settings-daemon.plugins.media-keys home '<Super>f'
gsettings set org.gnome.settings-daemon.plugins.media-keys www '<Super>w'

gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'gnome-terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>t'

gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'SublimeText'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'subl3'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Super>e'

#gsettings set org.gnome.shell enabled-extensions "['workspace-indicator@gnome-shell-extensions.gcampax.github.com','user-theme@gnome-shell-extensions.gcampax.github.com','alternate-tab@gnome-shell-extensions.gcampax.github.com', 'TopIcons@phocean.net', 'EasyScreenCast@iacopodeenosee.gmail.com']"
gsettings set org.gnome.shell enabled-extensions "['workspace-indicator@gnome-shell-extensions.gcampax.github.com','user-theme@gnome-shell-extensions.gcampax.github.com','alternate-tab@gnome-shell-extensions.gcampax.github.com', 'TopIcons@phocean.net']"
gsettings set org.gnome.shell.extensions.topicons tray-pos 'right'
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.GWeather temperature-unit 'centigrade'
