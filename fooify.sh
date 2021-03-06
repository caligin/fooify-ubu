set -e
if [ $(whoami) == "root" ]; then
  echo "this script needs to run as non-sudo, sudo permissions will be asked on an operation-by-operation basis"
  exit 1
fi
sudo apt-get update
sudo apt-get install -y curl
sudo add-apt-repository -y ppa:yubico/stable
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88 |  grep "9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88" || (echo "docker signing key fingerprint failed"; exit 1;)
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
sudo cp repos/tor.list /etc/apt/sources.list.d/
curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | sudo tee /etc/apt/sources.list.d/signal-xenial.list
sudo add-apt-repository ppa:phoerious/keepassxc
sudo apt-get update
sudo apt-get install -y \
  anthy \
  bpython \
  chkrootkit \
  chromium-browser \
  clamav \
  clang \
  deb.torproject.org-keyring \
  diffuse \
  docker-ce \
  filezilla \
  gimp \
  git \
  gnome-session-flashback \
  gnome-tweak-tool \
  hexedit \
  htop \
  ibus-anthy \
  iftop \
  iotop \
  jq \
  keepassxc \
  mercurial \
  mokutil \
  mongodb-clients \
  mysql-client \
  network-manager-openvpn-gnome \
  network-manager-vpnc-gnome \
  nfs-common \
  ngrep \
  openjdk-8-jdk \
  openssh-server \
  openvpn \
  python-pip \
  python-virtualenv \
  qrencode \
  scdaemon \
  signal-desktop \
  strongswan \
  sublime-text \
  thunderbird \
  tor \
  traceroute \
  tree \
  unrar \
  vim \
  virtualbox \
  vlc \
  whois \
  wireshark \
  yubioath-desktop
sudo apt-get update
sudo apt-get upgrade -y

for f in $(find dotfiles/ -type f); do
  cp $f ~/
done
#bash install-nvm-v0.33.11.sh
bash install-rvm-master-01032018.sh
mkdir -p ~/bin
if [ -z $(which lein) ]; then
  wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein -O ~/bin/lein
  chmod u+x ~/bin/lein
fi

if [ ! -f vagrant_2.0.2_x86_64.deb ]; then
  wget https://releases.hashicorp.com/vagrant/2.0.2/vagrant_2.0.2_x86_64.deb
fi
sudo dpkg -i vagrant_2.0.2_x86_64.deb

if [ ! -f awscli-bundle.zip ]; then
  curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
fi
unzip awscli-bundle.zip
./awscli-bundle/install -i ~/awscli -b ~/bin/aws

curl -s https://get.sdkman.io | bash
#sdk install kotlin

curl https://sh.rustup.rs -sSf | sh

cp fake-gradle ~/bin/gradle
cp fake-mvn ~/bin/mvn

curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o ~/bin/docker-compose
chmod +x ~/bin/docker-compose

wget https://dl.google.com/go/go1.10.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.10.linux-amd64.tar.gz

curl -L https://yt-dl.org/downloads/latest/youtube-dl -o ~/bin/youtube-dl
chmod a+rx ~/bin/youtube-dl

dconf load /org/gnome/terminal/ < notdotfiles/gnome-terminal-$HOSTNAME
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
cp notdotfiles/gpg.conf ~/.gnupg
mkdir -p ~/.gimp-2.8
cp notdotfiles/gimp-menurc ~/.gimp-2.8/menurc
mkdir -p ~/.ssh
cp notdotfiles/ssh-config ~/.ssh/config
chmod 664 ~/.ssh/config

sudo systemctl disable ssh
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

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
gsettings set org.gnome.settings-daemon.plugins.media-keys email "<Super>m"
gsettings set org.gnome.settings-daemon.plugins.media-keys home "<Super>e"
gsettings set org.gnome.settings-daemon.plugins.media-keys media "<Super>v"
gsettings set org.gnome.settings-daemon.plugins.media-keys www "<Super>w"
gsettings set org.gnome.desktop.wm.keybindings panel-main-menu "['<Alt>F1']"
gsettings set org.freedesktop.ibus.panel.emoji hotkey '[]' # default ctrl-shift-e clashes with IDEs and my custom GIMP "export as" shotcut
gsettings set org.gnome.desktop.session idle-delay 0 # DANGER WARN: this disable the autolock timeout. works for me b/c I'm compulsively paranoid about locking my screen manually but it might not be the case for you!
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver '<Ctrl><Alt>l'
dconf write /org/gnome/desktop/peripherals/touchpad/natural-scroll false # not a mac so we scroll how is natural, that is not what is called natural
dconf write /org/gnome/desktop/peripherals/touchpad/click-method "'areas'" # again, not a mac. there's 2 buttons on that touchpad, not 1.

cut -d: -f1 /etc/group | grep docker || sudo groupadd docker
sudo usermod -aG docker caligin
sudo usermod -aG wireshark caligin

gpg --recv-keys 0x7AD2E918B3D5FFB7

# google chrome by hand, there's some shit licence to accept and I dont't want to bother
# same for android studio and I guess netbeans
