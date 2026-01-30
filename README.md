All shell and automation scripts are written with Ruby.
## TODOS
[ ] Find a way to encrypt secrets safely.
    # Encrypt (whole file as binary blob) → produces binary encrypted output
sops --encrypt \
  --input-type binary \
  --output-type binary \
  --age age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \   # or --pgp FINGERPRINT, or --kms ARN, etc.
  my-text-file.txt > my-text-file.enc

# Or encrypt in-place (overwrites original — be careful!)
sops --encrypt \
  --input-type binary \
  --output-type binary \
  --in-place \
  my-text-file.txt- age & sops
[ ] Setup ruby LSP, linter and formatter in neovim.
[ ] Make this project a ruby thing, with rake and bundle files.
[ ] Make this project a Go project for Kubernetes use.

## Secret Management

Via encrypted credentials (a-la ruby on rails)
It stores sensitive configuration values (API keys, passwords, tokens, etc.)
directly inside the same git repository — without exposing the actual secrets in plain text.

`config/credentials.yml.enc` Encrypted YAML file. Safe to commit to Git.
`config/master.key` 128 character encryption key (hex string) **NEVER** committed to git.
    - Add this file to .gitignore
    - Environment Variable `ENC_MASTER_KEY`

$EDITOR variable

Generate a new 256-bit key once (hex string, 64 chars) — keep this secret!
`openssl rand -hex 32 > master.key`

programs: sops, age (via package manager) (pacman -S sops age)
Or or go install
    - go install filippo.io/age/cmd/age@latest
    - go install github.com/getsops/sops/v3/cmd/sops@latest

    - SOPS_AGE_KEY_FILE (env var, path to age-keys.txt)
    - SOPS_AGE_KEY (env var, the private key text itself)
    - `~/.config/sops/age/keys.txt` (default location)
    - In CI/CD (GitHub Actions, GitLab CI, Flux/ArgoCD): mount age private key as secret → set SOPS_AGE_KEY_FILE=/secrets/age.txt


Temp file is in /dev/shm (RAM) by default → cleared on reboot, not swapped to disk.

Encrypt (whole file as binary blob) → produces binary encrypted output
    sops --encrypt \
      --input-type binary \
      --output-type binary \
      --age age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \   # or --pgp FINGERPRINT, or --kms ARN, etc.
      my-text-file.txt > my-text-file.enc

Or encrypt in-place (overwrites original — be careful!)
    sops --encrypt \
      --input-type binary \
      --output-type binary \
      --in-place \
      my-text-file.txt


## Homelab
DOING: Deploy Curious-APE in apex, and reverse proxy it throught ape-0.
    - Create kube repository to write k8s manifests in pure Go (go-kube?)
    - Write new deployment in Curious-Ape in Go with kube (go-kube)
    - Stop Curious-Ape in ape-1
    - Deploy Curious-Ape in apex (proxy thourght ape-0)

NEXT: Figure out the secrets encryption and decryption.

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
