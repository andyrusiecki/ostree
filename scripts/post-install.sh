#!/bin/bash

image="$1"
dir=$(dirname $(realpath $0))

# Replace fedora flatpak repo with flathub (https://www.reddit.com/r/Fedora/comments/z2kk88/fedora_silverblue_replace_the_fedora_flatpak_repo/)
sudo flatpak remote-modify --no-filter --enable flathub
flatpak remove --noninteractive --assumeyes org.fedoraproject.MediaWriter
flatpak install --noninteractive --assumeyes --reinstall flathub $(flatpak list --app-runtime=org.fedoraproject.Platform --columns=application | tail -n +1 )
sudo flatpak remote-delete fedora

# Install Default Flatpaks and Extensions
function getFlatpakExtension() {
  app="$1"
  ext="$2"

  version="$(flatpak info -m $app | sed -n "/^[ \t]*\[$ext\]/,/\[/s/^[ \t]*version[ \t]*=[ \t]*//p")"

  echo "runtime/$app/$(arch)/$version"
}

flatpak_apps="$(jq -r '.base.flatpaks[]' $dir/config.json | tr '\n' ' ')"

flatpak install --noninteractive $flatpak_apps

# Gnome Extensions
# TODO: replace some with Just Perfection with donf settings
extensions="$(jq -r '.base.gnome-extensions[]' $dir/config.json | tr '\n' ' ')"
for uuid in $extensions
do
  info_json=$(curl -sS "https://extensions.gnome.org/extension-info/?uuid=$uuid&shell_version=$shell_version")
  download_url=$(echo $info_json | jq ".download_url" --raw-output)

  gnome-extensions install "https://extensions.gnome.org$download_url"
  gnome-extensions enable $uuid
done

# Gnome dconf settings
cat $dir/base-gnome-settings.ini | dconf load /

# Enable podman socket for user
systemctl --user enable --now podman.socket

# make fish the default shell
sudo usermod -s $(command -v fish) $USER

# framework specific options
if [[ "$image" = "framework" ]]; then
  # framework specific gnome settings
  cat $dir/framework-gnome-settings.ini | dconf load /

  # gnome fractional scaling
  gsettings set org.gnome.desktop.interface text-scaling-factor 1.25
  gsettings set org.gnome.mutter experimental-features "[]'scale-monitor-framebuffer']"

  # install framework specific flatpaks
  flatpak_apps="$(jq -r '.framework.flatpaks[]' $dir/config.json | tr '\n' ' ')"
  flatpak install $flatpak_apps

  # enable birghtness keys
  sudo rpm-ostree kargs --append="module_blacklist=hid_sensor_hub"
fi
