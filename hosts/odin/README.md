# odin

Desktop workstation.

## Hardware

- **CPU**: AMD Ryzen (x86_64)
- **GPU**: NVIDIA GeForce RTX 3080 Ti (proprietary driver, closed-source)
- **Storage**: 2x Samsung NVMe 1TB
  - `nvme0n1` — NixOS (btrfs, subvolumes: root, home, nix, log)
  - `nvme1n1` — Old Linux Mint install (unmounted, contains user data)
- **Bluetooth**: Broadcom BCM20702A1 (firmware not installed)

## Boot

- systemd-boot on `nvme0n1p1` (EFI)
- Mint GRUB entry still in EFI boot manager as fallback
- `/etc/nixos` is symlinked to the repo root
