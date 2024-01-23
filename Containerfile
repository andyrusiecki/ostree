ARG FEDORA_VERSION="39"

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_VERSION} as silverblue-base

COPY base/etc/ /etc/
COPY base/usr/ /usr/

COPY scripts/install-fonts.sh /tmp/

RUN rpm-ostree install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

RUN rpm-ostree override remove \
  firefox \
  firefox-langpacks

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

RUN rpm-ostree cleanup -m && \
  rm -rf /tmp/* && \
  ostree container commit


FROM silverblue-base as silverblue-framework

COPY framework/etc/ /etc/
COPY framework/usr/ /usr/

RUN rpm-ostree override remove \
  power-profiles-daemon

RUN rpm-ostree install \
  fprintd \
  tlp \
  tlp-rdw \
  powertop

RUN systemctl enable fprintd && \
  systemctl enable tlp

RUN rpm-ostree cleanup -m && \
  ostree container commit

FROM registry.fedoraproject.org/fedora-toolbox:${FEDORA_VERSION} as dev-toolbox

COPY dev-toolbox/etc/ /etc/

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

