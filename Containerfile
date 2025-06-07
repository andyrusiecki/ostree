FROM quay.io/fedora-ostree-desktops/silverblue:42 AS base

# prepare packages
COPY --chmod=0644 ./system/usr__local__share__andyrusiecki__packages-removed /usr/local/share/andyrusiecki/packages-removed
COPY --chmod=0644 ./system/usr__local__share__andyrusiecki__packages-added /usr/local/share/andyrusiecki/packages-added
RUN jq -r .packages[] /usr/share/rpm-ostree/treefile.json > /usr/local/share/andyrusiecki/packages-base

# add repositories
RUN curl -o /etc/yum.repos.d/tailscale.repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo
RUN curl -o /etc/yum.repos.d/starship.repo https://copr.fedorainfracloud.org/coprs/atim/starship/repo/fedora/atim-starship-fedora.repo

# install packages
RUN grep -vE '^#' /usr/local/share/andyrusiecki/packages-added | xargs rpm-ostree install

# remove packages
RUN grep -vE '^#' /usr/local/share/andyrusiecki/packages-removed | xargs rpm-ostree override remove

# configuration
COPY --chmod=0644 ./system/etc__rpm-ostreed.conf /etc/rpm-ostreed.conf
COPY --chmod=0644 ./system/etc__sysctl.d__99-podman.conf /etc/sysctl.d/99-podman.conf
COPY --chmod=0755 ./system/usr__local__bin/* /usr/local/bin/
COPY --chmod=0600 ./system/usr__lib__ostree__auth.json /usr/lib/ostree/auth.json

# scripts
COPY --chmod=0755 ./scripts/* /tmp/scripts/
RUN /tmp/scripts/install-fonts.sh

# flatpak updates
COPY --chmod=0644 ./system/usr__lib__systemd__system__flatpak-system-update.service /usr/lib/systemd/system/flatpak-system-update.service
COPY --chmod=0644 ./system/usr__lib__systemd__system__flatpak-system-update.timer /usr/lib/systemd/system/flatpak-system-update.timer
COPY --chmod=0644 ./system/usr__lib__systemd__user__flatpak-user-update.service /usr/lib/systemd/user/flatpak-user-update.service
COPY --chmod=0644 ./system/usr__lib__systemd__user__flatpak-user-update.timer /usr/lib/systemd/user/flatpak-user-update.timer

RUN systemctl enable flatpak-system-update.timer
RUN systemctl --global enable flatpak-user-update.timer

# auto rpm-ostree updates
RUN systemctl enable rpm-ostreed-automatic.timer

# tailscale service
RUN systemctl enable tailscaled

# clean up
RUN rm -rf /tmp/* /var/*
RUN rpm-ostree cleanup -m
RUN ostree container commit

FROM base AS framework

COPY --chmod=0644 ./system/usr__share__gnome-background-properties__framework.xml /usr/share/gnome-background-properties/framework.xml
COPY --chmod=0644 ./system/usr__share__backgrounds__framework-d.webp /usr/share/backgrounds/framework-d.webp
COPY --chmod=0644 ./system/usr__share__backgrounds__framework-l.webp /usr/share/backgrounds/framework-l.webp
