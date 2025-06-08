FROM quay.io/fedora/fedora-bootc:42 AS base

# filesystem
RUN rmdir /opt && ln -s -T /var/opt /opt
RUN mkdir /var/roothome

# prepare packages
COPY --chmod=0644 ./system/usr__local__share__fedora-bootc__packages-removed /usr/local/share/fedora-bootc/packages-removed
COPY --chmod=0644 ./system/usr__local__share__fedora-bootc__packages-added /usr/local/share/fedora-bootc/packages-added
COPY --chmod=0644 ./system/usr__local__share__fedora-bootc__flatpaks-added /usr/local/share/fedora-bootc/flatpaks-added
RUN jq -r .packages[] /usr/share/rpm-ostree/treefile.json > /usr/local/share/fedora-bootc/packages-base

# add repositories
# dnf5-plugins already in silverblue image
RUN dnf -y install dnf5-plugins
RUN dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
RUN dnf config-manager addrepo --from-repofile=https://copr.fedorainfracloud.org/coprs/atim/starship/repo/fedora/atim-starship-fedora.repo

# packages
RUN dnf -y install @workstation-product-environment
RUN grep -vE '^#' /usr/local/share/fedora-bootc/packages-added | xargs dnf -y install --allowerasing
RUN grep -vE '^#' /usr/local/share/fedora-bootc/packages-removed | xargs dnf -y remove
# TODO: enable flathub, disable fedora flatpak repo
RUN grep -vE '^#' /usr/local/share/fedora-bootc/flatpaks-added | xargs flatpak install --noninteractive --system
RUN dnf -y autoremove
RUN dnf clean all

# configuration
COPY --chmod=0644 ./system/etc__sysctl.d__99-podman.conf /etc/sysctl.d/99-podman.conf
COPY --chmod=0755 ./system/usr__local__bin/* /usr/local/bin/
COPY --chmod=0600 ./system/usr__lib__ostree__auth.json /usr/lib/ostree/auth.json

# scripts
COPY --chmod=0755 ./scripts/* /tmp/scripts/
RUN /tmp/scripts/install-fonts.sh

# systemd
COPY --chmod=0644 ./systemd/user/flatpak-update.service /usr/lib/systemd/user/flatpak-update.service
COPY --chmod=0644 ./systemd/user/flatpak-update.timer /usr/lib/systemd/user/flatpak-update.timer
COPY --chmod=0644 ./systemd/system/bootc-fetch.service /usr/lib/systemd/system/bootc-fetch.service
COPY --chmod=0644 ./systemd/system/bootc-fetch.timer /usr/lib/systemd/system/bootc-fetch.timer

RUN systemctl --global enable flatpak-update.timer
RUN systemctl enable bootloader-update.service
RUN systemctl mask bootc-fetch-apply-updates.timer
RUN systemctl enable tailscaled

# clean up
RUN find /var/log -type f ! -empty -delete
RUN bootc container lint

FROM base AS framework

COPY --chmod=0644 ./system/usr__share__gnome-background-properties__framework.xml /usr/share/gnome-background-properties/framework.xml
COPY --chmod=0644 ./system/usr__share__backgrounds__framework-d.webp /usr/share/backgrounds/framework-d.webp
COPY --chmod=0644 ./system/usr__share__backgrounds__framework-l.webp /usr/share/backgrounds/framework-l.webp
