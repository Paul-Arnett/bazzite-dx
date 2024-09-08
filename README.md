# bazzite-dx &nbsp; [![build-ublue](https://github.com/arnettpa/bazzite-dx/actions/workflows/build.yml/badge.svg)](https://github.com/arnettpa/bazzite-dx/actions/workflows/build.yml)

This is a personal and unofficial developer flavor of [Bazzite](https://github.com/ublue-os/bazzite/), based on the [bazzite-nvidia](https://github.com/ublue-os/bazzite/pkgs/container/bazzite-nvidia) image.

Main Packages Added:

- Virtualization: virt-manager, edk2-ovmf, qemu
- Editor: Vscode

Made using [BlueBuild](https://blue-build.org/how-to/setup/).

## Installation

> **Warning**  
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

To rebase an existing atomic Fedora installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/arnettpa/bazzite-dx:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/arnettpa/bazzite-dx:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in `recipe.yml`, so you won't get accidentally updated to the next major version.

## Additional Setup

- To setup kernel args and vfio drivers for virtualization, run `setup-virtualization.sh` after booting into the image. (TODO: figure out how to build this into the image)

## ISO

If build on Fedora Atomic, you can generate an offline ISO with the instructions available [here](https://blue-build.org/learn/universal-blue/#fresh-install-from-an-iso). These ISOs cannot unfortunately be distributed on GitHub for free due to large sizes, so for public projects something else has to be used for hosting.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/arnettpa/bazzite-dx
```
