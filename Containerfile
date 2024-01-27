ARG FEDORA_VERSION="39"

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_VERSION} as silverblue

COPY overlays/silverblue/ /

RUN rpm-ostree install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

RUN rpm-ostree override remove \
  firefox \
  firefox-langpacks \
  toolbox

RUN rpm-ostree install \
  adw-gtk3-theme \
  distrobox \
  fish \
  gnome-tweaks \
  starship \
  steam-devices \
  tailscale

RUN systemctl enable rpm-ostreed-automatic.timer && \
  systemctl enable tailscaled

RUN /tmp/install-fonts.sh

RUN rm -rf /tmp/* /var/* && \
  ostree container commit


FROM silverblue as silverblue-framework

COPY overlays/silverblue-framework/ /

RUN rpm-ostree override remove \
  power-profiles-daemon

RUN rpm-ostree install \
  fprintd \
  tlp \
  tlp-rdw \
  powertop

RUN systemctl enable fprintd && \
  systemctl enable tlp

RUN rm -rf /tmp/* /var/* && \
  ostree container commit

FROM quay.io/fedora-ostree-desktops/base:${FEDORA_VERSION} as hyprland

COPY overlays/hyprland/ /

# add yq binary (no rpm available)
COPY --from=docker.io/mikefarah/yq /usr/bin/yq /usr/bin/yq

RUN rpm-ostree install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

RUN rpm-ostree install \
  adw-gtk3-theme \
  btop \
  catimg \
  distrobox \
  dunst \
  fish \
  git \
  grim \
  hyprland \
  imv \
  kanshi \
  kitty \
  mpv \
  neovim \
  playerctl \
  polkit-gnome \
  qt6-qtwayland \
  ranger \
  rofi-wayland \
  slurp \
  starship \
  steam-devices \
  swaybg \
  swaylock \
  swayidle \
  tailscale \
  thunar \
  thunar-archive-plugin \
  thunar-volman \
  waybar \
  wlsunset \
  wl-clipboard \
  xdg-desktop-portal-hyprland \
  sddm

RUN systemctl enable sddm

RUN /tmp/install-fonts.sh
RUN /tmp/install-themes.sh
RUN /tmp/install-screenshot-tools.sh

RUN rm -rf /tmp/* /var/* && \
  ostree container commit

FROM registry.fedoraproject.org/fedora-toolbox:${FEDORA_VERSION} as dev-toolbox

COPY overlays/dev-toolbox/ /

# Set max dnf parallel downloads to 20
RUN echo "max_parallel_downloads=20" >> /etc/dnf/dnf.conf

# add symlinks to host for podman
RUN ln -s /usr/bin/distrobox-host-exec /usr/local/bin/podman
RUN ln -s /usr/local/bin/podman /usr/local/bin/docker

# install extra packages
RUN dnf install -y --refresh \
  awscli \
  docker-compose \
  fish \
  golang \
  kubectl \
  make \
  starship \
  vim

# Add AWS ECR Credential Helper
RUN go install github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login@latest && cp /root/go/bin/docker-credential-ecr-login /usr/local/bin/

