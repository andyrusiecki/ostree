ARG FEDORA_VERSION="39"

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_VERSION} as silverblue-base

COPY etc/ /etc/
COPY scripts/install-fonts.sh /tmp/
RUN mkdir -p /usr/share/andyrusiecki
COPY scripts/post-install.sh /usr/share/andyrusiecki

RUN rpm-ostree install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm

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

RUN /tmp/install-google-fonts.sh base && \
/tmp/install-nerd-fonts.sh base

RUN rpm-ostree cleanup -m && \
rm -rf /tmp/* && \
ostree container commit


FROM silverblue-base as silverblue-framework

COPY framework/etc/ /etc/

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

# Set max dnf parallel downloads to 20
RUN echo "max_parallel_downloads=20" >> /etc/dnf/dnf.conf

# Add Kubernetes repo
RUN echo $'[kubernetes] \n\
name=Kubernetes \n\
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-$basearch \n\
enabled=1 \n\
gpgcheck=1 \n\
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg \n\
' > /etc/yum.repos.d/kubernetes.repo

# Add starship copr repo
RUN echo $'[starship]\n\
name=Starship \n\
baseurl=https://download.copr.fedorainfracloud.org/results/atim/starship/fedora-$releasever-$basearch/ \n\
type=rpm-md \n\
skip_if_unavailable=True \n\
gpgcheck=1 \n\
gpgkey=https://download.copr.fedorainfracloud.org/results/atim/starship/pubkey.gpg \n\
repo_gpgcheck=0 \n\
enabled=1 \n\
enabled_metadata=1 \n\
' > /etc/yum.repos.d/starship.repo

# Set DOCKER_HOST env var for host podman socket
RUN echo $'# /etc/profile.d/podman-host.sh - sets Podman and Docker host.\n\
export DOCKER_HOST="unix:///run/user/1000/podman/podman.sock"\n\
' > /etc/profile.d/podman-host.sh && chmod 644 /etc/profile.d/podman-host.sh

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

