#!/bin/bash
USER=archy
set -e -u

sed -i 's/#\(fr_FR\.UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo "LANG=fr_FR.UTF-8" > /etc/locale.conf
echo "LANGUAGE=fr" > /etc/locale.conf
echo "LC_ALL=fr_FR.UTF-8" > /etc/locale.conf

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

useradd $USER --create-home -U
echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers
echo "KEYMAP=fr" > /etc/vconsole.conf

# If not in French, Gnome will display a popup on startup to change/create those filenames
pushd /home/$USER
mkdir Bureau
mkdir Téléchargements
mkdir Modèles
mkdir Musique
mkdir Images
mkdir Vidéos

rm -rf Desktop
rm -rf Downloads
rm -rf Templates
rm -rf Music
rm -rf Pictures
rm -rf Videos
popd

echo "# GDM configuration storage

[daemon]
AutomaticLogin=archy
AutomaticLoginEnable=True

[security]

[xdmcp]

[chooser]

[debug]
" > /etc/gdm/custom.conf

sed -i '1s/^/auth sufficient pam_succeed_if.so user ingroup nopasswdlogin\n/' /etc/pam.d/gdm-password
groupadd nopasswdlogin
usermod -a -G nopasswdlogin archy


usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/
chmod 700 /root

sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf

rm /etc/systemd/system/getty@tty1.service.d/autologin.conf
ln -s /usr/lib/systemd/system/gdm.service /etc/systemd/system/display-manager.service
systemctl enable graphical.target gdm.service NetworkManager.service
systemctl set-default graphical.target
