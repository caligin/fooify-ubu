add-apt-repository -y ppa:yubico/stable
if [ ! -f esl-erlang_19.2-1~ubuntu~xenial_amd64.deb ]; then
  wget http://packages.erlang-solutions.com/site/esl/esl-erlang/FLAVOUR_1_general/esl-erlang_19.2-1~ubuntu~xenial_amd64.deb
fi
dpkg -i esl-erlang_19.2-1~ubuntu~xenial_amd64.deb
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb [arch=amd64] https://apt.dockerproject.org/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list
bash node/setup_6.x
gpg --keyserver keys.gnupg.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
cp repos/tor.list /etc/apt/sources.list.d/
apt-get update
apt-get install -y git vim vlc chromium-browser gimp keepassx clang virtualbox yubioath-desktop openvpn network-manager-openvpn-gnome tor docker-engine nodejs wireshark htop iotop anthy ibus-anthy deb.torproject.org-keyring openjdk-8-jdk bpython clamav chkrootkit diffuse filezilla hexedit iftop jq mercurial mongodb-clients mysql-client nfs-common ngrep qrencode traceroute tree unrar whois 
if [ ! -f MOK.der ]; then
  openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=Vbox signing key/"
fi
mokutil --import MOK.der
for mod in $(find /lib/modules/$(uname -r)/updates/ -name 'vbox*' -exec bash -c "basename {} |  awk -F . '{ print \$1 }'" \;); do
  /usr/src/linux-headers-$(uname -r)/scripts/sign-file sha256 ./MOK.priv ./MOK.der $(modinfo -n ${mod})
done
if [ ! -f vagrant_1.9.1_x86_64.deb ]; then
  wget https://releases.hashicorp.com/vagrant/1.9.1/vagrant_1.9.1_x86_64.deb
fi
dpkg -i vagrant_1.9.1_x86_64.deb


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

cp 50-no-guest.conf /etc/lightdm/lightdm.conf.d/50-no-guest.conf



# google chrome by hand, there's some shit licence to accept and I dont't want to bother
# and wtf is wrong with erlang
