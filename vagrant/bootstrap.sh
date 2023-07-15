echo "============ Update and upgrade soft ============"
apt-get update && apt upgrade -y

echo "============ Install Docker ============"
apt-get install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
docker run hello-world

echo "============ Add vagrant-user to Docker group ============"
usermod -aG docker vagrant

echo "============ Install UFW ============"
apt-get install ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
echo "y" | ufw enable
ufw status verbose

echo "============ Install Nomad + Consul ============"
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
echo "============ Install Consul ============"
apt-get install consul
mkdir -p /etc/consul.d
mkdir -p /opt/consul
chmod 777 /opt/consul
consul -v
echo "============ Install Nomad ============"
apt-get install nomad
mkdir -p /etc/nomad.d
mkdir -p /opt/nomad
chmod 777 /opt/nomad
nomad -v
