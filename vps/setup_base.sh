#! /usr/bin/env bash

MACHINES=$(realpath machines.txt)
echo $MACHINES

SETTINGS=$(realpath settings.sh)
source $SETTINGS
echo USER: $VM_USER
echo ADMIN: $VM_ADMIN

echo Timezone $TIME_ZONE

while read IP FQDN HOST; do
    ssh -n root@${IP} "apt update -y && apt upgrade -y"
    ssh -n root@${IP} "apt install -y git fish vim curl wget ufw rsync btop debian-keyring debian-archive-keyring apt-transport-https"
    ssh -n root@${IP} "timedatectl set-timezone $TIME_ZONE"
    ssh -n root@${IP} "useradd -U --create-home --groups sudo $VM_ADMIN"
    ssh -n root@${IP} "mkdir /home/$VM_ADMIN/.ssh"
    ssh -n root@${IP} "cp ~/.ssh/authorized_keys /home/$VM_ADMIN/.ssh/authorized_keys && chown -R $VM_ADMIN:$VM_ADMIN /home/$VM_ADMIN/.ssh"
    ssh -n root@${IP} "touch /etc/sudoers.d/admin && echo '$VM_ADMIN ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/admin"
    ssh -n root@${IP} "useradd -U \
                        --create-home \
                        --shell /usr/bin/fish \
                        --groups sudo \
                        $VM_USER"
    ssh -n root@${IP} "echo $VM_USER:$VM_PASSWORD | chpasswd"
    ssh -n root@${IP} "mkdir /home/$VM_USER/.ssh"
    ssh -n root@${IP} "cp ~/.ssh/authorized_keys /home/$VM_USER/.ssh/authorized_keys && chown -R $VM_USER:$VM_USER /home/$VM_USER/.ssh"
    # ssh -n root@${IP} "curl -s https://install.crowdsec.net | sudo sh && apt install -y crowdsec crowdsec-firewall-bouncer-iptables"
    # ssh -n root@${IP} "systemctl reload crowdsec"
    scp ./config/sshd/sshd_config root@${IP}:/etc/ssh/sshd_config
    ssh -n root@${IP} "ufw allow OpenSSH && ufw --force enable"
    ssh -n root@${IP} "systemctl reload ssh && systemctl reboot"
done < "$MACHINES"

