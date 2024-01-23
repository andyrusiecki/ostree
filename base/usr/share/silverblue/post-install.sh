#!/bin/bash

if [ "$UID" = "0" ]; then
  echo "This script cannot be run as root! It will prompt for user password with sudo when root permissions are required."
  exit 1
fi

image=$(rpm-ostree status --json | jq -r '.deployments[] | select(.booted == true) | .["container-image-reference"]' | grep -oP --color=never '(?<=andyrusiecki/).*(?=:)')

echo "Detected base image '$image'"

# Replace fedora flatpak repo with flathub (https://www.reddit.com/r/Fedora/comments/z2kk88/fedora_silverblue_replace_the_fedora_flatpak_repo/)
if ! flatpak remotes | grep --quiet flathub; then
  sudo flatpak remote-modify --no-filter --enable flathub
fi

if flatpak info org.fedoraproject.MediaWriter &>/dev/null; then
  flatpak remove --noninteractive --assumeyes org.fedoraproject.MediaWriter
fi

if flatpak remotes | grep --quiet fedora; then
  flatpak install --noninteractive --assumeyes --reinstall flathub $(flatpak list --app-runtime=org.fedoraproject.Platform --columns=application | tail -n +1 )
  sudo flatpak remote-delete fedora
fi

# Install Default Flatpaks and Extensions
function getFlatpakExtension() {
  app="$1"
  ext="$2"

  version="$(flatpak info -m $app | sed -n "/^[ \t]*\[Extension $ext\]/,/\[/s/^[ \t]*version[ \t]*=[ \t]*//p")"

  echo "runtime/$ext/$(arch)/$version"
}

flatpak_apps=(
  com.discordapp.Discord
  com.getpostman.Postman
  com.github.GradienceTeam.Gradience
  com.github.marhkb.Pods
  com.github.tchx84.Flatseal
  com.github.zocker_160.SyncThingy
  com.google.Chrome
  com.mattjakeman.ExtensionManager
  com.slack.Slack
  com.spotify.Client
  com.valvesoftware.Steam
  com.visualstudio.code
  io.github.celluloid_player.Celluloid
  io.github.realmazharhussain.GdmSettings
  md.obsidian.Obsidian
  org.gnome.Boxes
  org.gnome.World.PikaBackup
  org.gtk.Gtk3theme.adw-gtk3
  org.gtk.Gtk3theme.adw-gtk3-dark
  org.libreoffice.LibreOffice
  app/org.mozilla.firefox/$(arch)/stable
  org.signal.Signal
  us.zoom.Zoom
)

flatpak install --noninteractive ${flatpak_apps[@]}

# ffmpeg firefox extension
flatpak install --noninteractive $(getFlatpakExtension org.mozilla.firefox org.freedesktop.Platform.ffmpeg-full)

# Gnome Extensions
# TODO: replace some with Just Perfection with donf settings
extensions=(
  AlphabeticalAppGrid@stuarthayhurst
  appindicatorsupport@rgcjonas.gmail.com
  blur-my-shell@aunetx
  caffeine@patapon.info
  just-perfection-desktop@just-perfection
  mediacontrols@cliffniff.github.com
  nightthemeswitcher@romainvigier.fr
  pip-on-top@rafostar.github.com
  user-theme@gnome-shell-extensions.gcampax.github.com
  Vitals@CoreCoding.com
)

shell_version=$(gnome-shell --version | cut -d' ' -f3)

for uuid in ${extensions[@]}
do
  if gnome-extensions list | grep --quiet $uuid; then
    break
  fi

  info_json=$(curl -sS "https://extensions.gnome.org/extension-info/?uuid=$uuid&shell_version=$shell_version")
  download_url=$(echo $info_json | jq ".download_url" --raw-output)

  gnome-extensions install --force "https://extensions.gnome.org$download_url"

  if ! gnome-extensions list | grep --quiet $uuid; then
    busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s $uuid
  fi

  gnome-extensions enable $uuid
done

# Gnome settings
gsettings set org.gnome.desktop.datetime automatic-timezone true

gsettings set org.gnome.desktop.interface clock-format "12h"
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface font-antialiasing "rgba"
gsettings set org.gnome.desktop.interface font-hinting "slight"
gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"
gsettings set org.gnome.desktop.interface color-scheme 'default'

gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<SHIFT><SUPER>1']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<SHIFT><SUPER>2']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<SHIFT><SUPER>3']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<SHIFT><SUPER>4']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-5 "['<SHIFT><SUPER>5']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-6 "['<SHIFT><SUPER>6']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-7 "['<SHIFT><SUPER>7']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-8 "['<SHIFT><SUPER>8']"

gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<SUPER>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<SUPER>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<SUPER>3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<SUPER>4']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<SUPER>5']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-6 "['<SUPER>6']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-7 "['<SUPER>7']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-8 "['<SUPER>8']"

gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

gsettings set org.gnome.system.location enabled true

gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.mozilla.firefox.desktop', 'com.google.Chrome.desktop', 'com.spotify.Client.desktop', 'com.valvesoftware.Steam.desktop', 'com.slack.Slack.desktop', 'md.obsidian.Obsidian.desktop', 'com.visualstudio.code.desktop', 'org.gnome.Terminal.desktop']"

# Gnome Extension settings
## Just Perfection
gsettings set org.gnome.shell.extensions.just-perfection notification-banner-position 2 # top end
gsettings set org.gnome.shell.extensions.just-perfection startup-status 0 # no overview at startup

# Media Controls
gsettings set org.gnome.shell.extensions.mediacontrols extension-index 1
gsettings set org.gnome.shell.extensions.mediacontrols extension-position "Left"
gsettings set org.gnome.shell.extensions.mediacontrols show-control-icons-seek-backward false
gsettings set org.gnome.shell.extensions.mediacontrols show-control-icons-seek-forward false


# Enable podman socket for user
systemctl --user enable --now podman.socket

# make fish the default shell
new_shell="$(command -v fish)"
current_shell="$(getent passwd $USER | awk -F : '{ print $7 }')"
if [[ "$new_shell" != "$current_shell" ]]; then
  sudo usermod -s $new_shell $USER
fi

# create dev distrobox
if ! distrobox ls | grep --quiet andyrusiecki/dev-toolbox; then
  distrobox create --name dev --image ghcr.io/andyrusiecki/dev-toolbox:latest
fi

# framework specific options
if [[ "$image" = "silverblue-framework" ]]; then
  # gnome settings
  gsettings set org.gnome.desktop.interface text-scaling-factor 1.25
  gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

  # install framework specific flatpaks
  flatpak_apps=(
    com.github.d4nj1.tlpui
  )

  flatpak install --noninteractive ${flatpak_apps[@]}

  # enable birghtness keys
  if ! rpm-ostree kargs | grep --quiet module_blacklist=hid_sensor_hub; then
    sudo rpm-ostree kargs --append="module_blacklist=hid_sensor_hub"
  fi
fi
