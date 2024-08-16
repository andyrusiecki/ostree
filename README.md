# OSTree based custom desktop environments

This repository holds custom images for my own ostree desktop environments.

Images are rebuilt with new changes on each new commit in the main branch. New images are also created every Saturday for new base image updates.

## Desktop Builds

Rebasing to one of these image can be done by running:
```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/andyrusiecki/<image name>
```
### Gnome

Image name = `silverblue`
Customized [Fedora Silverblue](https://fedoraproject.org/silverblue/) image with my updated package requirements and extensions.

## Other Builds

These images are for non-ostree use cases.

### Dev Toolbox -> dev-toolbox
Toolbox/Distrobox compatible image used for a complete dev environment based on default Fedora toolbox image. Dependencies here change based on my current use case and likely won't be usable for everyone as is.

This can be installed as a distrobox container (or replace with `toolbox`) by running:
```bash
distrobox create --name dev --image ghcr.io/andyrusiecki/dev-toolbox:latest
```
