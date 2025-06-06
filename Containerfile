FROM quay.io/fedora-ostree-desktops/silverblue:42 AS base

LABEL org.opencontainers.image.author="andyrusiecki"

# prepare packages
COPY --chmod=0644 ./system/usr__local__share__andyrusiecki__packages-removed /usr/local/share/andyrusiecki/packages-removed
COPY --chmod=0644 ./system/usr__local__share__andyrusiecki__packages-added /usr/local/share/andyrusiecki/packages-added
RUN jq -r .packages[] /usr/share/rpm-ostree/treefile.json > /usr/local/share/andyrusiecki/packages-base

# add repositories
RUN ostree remote add https://pkgs.tailscale.com/stable/fedora/tailscale.repo
RUN ostree remote add https://copr.fedorainfracloud.org/coprs/atim/starship/repo/fedora/atim-starship-fedora.repo

# install packages
RUN grep -vE '^#' /usr/local/share/andyrusiecki/packages-added | rpm-ostree install remove

# remove packages
RUN grep -vE '^#' /usr/local/share/andyrusiecki/packages-removed | rpm-ostree override remove

# configuration
COPY --chmod=0755 ./system/usr__local__bin/* /usr/local/bin/
COPY --chmod=0600 ./system/usr__lib__ostree__auth.json /usr/lib/ostree/auth.json
COPY --chmod=0644 ./system/usr__etc__rpm-ostreed.conf /usr/etc/rpm-ostreed.conf
COPY --chmod=0644 ./system/usr__etc__sysctl.d__99-podman.conf /usr/etc/sysctl.d/99-podman.conf

# scripts
COPY --chmod=0755 ./scripts/* /tmp/scripts/
RUN /tmp/scripts/install-fonts.sh
RUN rm -r /tmp/scripts

# flatpak updates
COPY --chmod=0644 ./systemd/usr__lib__systemd__system__flatpak-system-update.service /usr/lib/systemd/system/flatpak-system-update.service
COPY --chmod=0644 ./systemd/usr__lib__systemd__system__flatpak-system-update.timer /usr/lib/systemd/system/flatpak-system-update.timer
COPY --chmod=0644 ./systemd/usr__lib__systemd__user__flatpak-user-update.service /usr/lib/systemd/user/flatpak-user-update.service
COPY --chmod=0644 ./systemd/usr__lib__systemd__user__flatpak-user-update.timer /usr/lib/systemd/user/flatpak-user-update.timer

RUN systemctl enable flatpak-system-update.timer
RUN systemctl --global enable flatpak-user-update.timer

# auto rpm-ostree updates
RUN systemctl enable rpm-ostreed-automatic.timer

# tailscale service
RUN systemctl enable tailscaled

RUN rm -rf /tmp/* /var/* && \
  ostree container commit

FROM base AS framework

LABEL org.opencontainers.image.title="Fedora Silverblue (Framework 13)"
LABEL org.opencontainers.image.description="Fedora Silverblue customized for Framework 13"

RUN systemctl enable fprintd.service

COPY --chmod=0644 ./systemd/usr__share__gnome-background-properties__framework.xml /usr/share/gnome-background-properties/framework.xml
COPY --chmod=0644 ./systemd/usr__share__backgrounds__framework-d.webp /usr/share/backgrounds/framework-d.webp
COPY --chmod=0644 ./systemd/usr__share__backgrounds__framework-l.webp /usr/share/backgrounds/framework-l.webp
