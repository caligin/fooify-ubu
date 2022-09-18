set -e
if [ $(whoami) == "root" ]; then
  echo "this script needs to run as non-sudo, sudo permissions will be asked on an operation-by-operation basis"
  exit 1
fi
sudo apt update
sudo apt install -y curl
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | sudo tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null
sudo cp repos/tor.list /etc/apt/sources.list.d/

wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | sudo tee -a /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
# FIXME: signal jammy not available yet, revisit at a later date
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
  sudo tee -a /etc/apt/sources.list.d/signal-xenial.list

sudo apt update
sudo apt install -y \
  anthy \
  clamav \
  containerd.io \
  deb.torproject.org-keyring \
  docker-ce \
  docker-ce-cli \
  docker-compose-plugin \
  gimp \
  git \
  gnome-session-flashback \
  gnome-tweaks \
  htop \
  ibus-anthy \
  iftop \
  iotop \
  jq \
  nfs-common \
  ngrep \
  python3-virtualenv \
  rkhunter \
  scdaemon \
  signal-desktop \
  sublime-text \
  tor \
  unrar \
  vim \
  vlc \
  whois \
  wireguard \
  wireshark
sudo apt update
sudo apt upgrade -y

sudo snap refresh firefox
sudo snap install code kubectl --classic
sudo snap install yubioath-desktop keepassxc doctl

sudo rkhunter --propupd
sudo sed -i s/APT_AUTOGEN="no"/APT_AUTOGEN="yes"/g /etc/default/rkhunter

for f in $(find dotfiles/ -type f); do
  cp $f ~/
done

mkdir -p ~/bin

# 9600617c52d0d2e48493424c529ac6c945d2775b
bash install-nvm-v0.39.1.sh

bash install-rvm-master-01032018.sh

git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
ln -s ~/.tfenv/bin/* ~/bin
echo 'trust-tfenv: yes' > ~/.tfenv/use-gpgv

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install -i ~/aws-cli -b ~/bin/

curl -s https://get.sdkman.io | bash

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

cp fake-gradle ~/bin/gradle
cp fake-mvn ~/bin/mvn


wget https://go.dev/dl/go1.19.1.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.19.1.linux-amd64.tar.gz

curl -L https://yt-dl.org/downloads/latest/youtube-dl -o ~/bin/youtube-dl
chmod a+rx ~/bin/youtube-dl

dconf load /org/gnome/terminal/ < notdotfiles/gnome-terminal-$HOSTNAME
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
cp notdotfiles/gpg.conf ~/.gnupg
mkdir -p ~/.gimp-2.8
cp notdotfiles/gimp-menurc ~/.gimp-2.8/menurc
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cp notdotfiles/ssh-config ~/.ssh/config
chmod 664 ~/.ssh/config

# the "new printer" popup can drive you mad when in a shared office space with someone compulsively attachind and detaching their printer to the network
sudo systemctl stop cups-browsed.service
sudo systemctl disable cups-browsed.service

gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$(cat bindings/customkeybindings.bindings.keys)"
for kb in $(ls bindings/*.binding); do
  name=$(echo -n "$kb" | cut -d '.' -f1 | cut -d '/' -f2 | tr '+' '/')
  echo "$kb"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$name name "$(cat "$kb" | head -n1)"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$name command "$(cat "$kb" | tail -n2 | head -n1)"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$name binding "$(cat "$kb" | tail -n1)"
done
for i in $(seq 1 4); do
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']"
done
gsettings set org.gnome.settings-daemon.plugins.media-keys email "['<Super>m']"
gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"
gsettings set org.gnome.settings-daemon.plugins.media-keys media "['<Super>v']"
gsettings set org.gnome.settings-daemon.plugins.media-keys www "['<Super>w']"
gsettings set org.gnome.desktop.wm.keybindings panel-main-menu "['<Alt>F1']"
gsettings set org.gnome.desktop.session idle-delay 0 # DANGER WARN: this disable the autolock timeout. works for me b/c I'm compulsively paranoid about locking my screen manually but it might not be the case for you!
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "['<Ctrl><Alt>l']"
dconf write /org/gnome/desktop/peripherals/touchpad/natural-scroll false # not a mac so we scroll how is natural, that is not what is called natural
dconf write /org/gnome/desktop/peripherals/touchpad/tap-to-click true
dconf write /org/gnome/desktop/peripherals/touchpad/two-finger-scrolling-enabled true

cut -d: -f1 /etc/group | grep docker || sudo groupadd docker
sudo usermod -aG docker caligin
sudo usermod -aG wireshark caligin

gpg --recv-keys 0x7AD2E918B3D5FFB7
