#### BTRFS commands.
Disks:
    - /dev/sdc
    - /dev/sdd
Setup both disks in raid1
```sh
sudo mkfs.btrfs -f -L app_data -d raid1 -m raid1 /dev/sdc /dev/sdd
sudo mkdir /mnt/app_data
sudo mount /dev/sdc /mnt/app_data
genfstab -U / > fstab.tmpt
```
Edit the file to add additional mount options. Only one volume needs to be mounted, btrfs manages both (raid1) volumes internally.
```sh
noatime
compress=zstd
```
Full options: `rw,relatime,noatime,ssd,discard=async,space_cache=v2,compress=zstd,subvol=/`
Then replace the new fstab into the old one

Btrfs Commands
```sh
sudo btrfs filesystem show
```
