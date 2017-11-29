# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

$script = <<SCRIPT
set -x
apt-get update
apt-get -y install docker.io docker-compose git openssl golang-go libltdl-dev
addgroup ubuntu docker
echo "#!/bin/bash" > /etc/rc.local
echo "service docker start" >> /etc/rc.local
service docker start

#fabric 1.0.4
docker pull hyperledger/fabric-peer:x86_64-1.0.4
docker pull hyperledger/fabric-ca:x86_64-1.0.4
docker pull hyperledger/fabric-ccenv:x86_64-1.0.4
docker pull hyperledger/fabric-orderer:x86_64-1.0.4
docker pull hyperledger/fabric-couchdb:x86_64-1.0.4
docker pull hyperledger/fabric-tools:x86_64-1.0.4
docker tag hyperledger/fabric-peer:x86_64-1.0.4 hyperledger/fabric-peer:latest
docker tag hyperledger/fabric-ca:x86_64-1.0.4 hyperledger/fabric-ca:latest
docker tag hyperledger/fabric-ccenv:x86_64-1.0.4 hyperledger/fabric-ccenv:latest
docker tag hyperledger/fabric-orderer:x86_64-1.0.4 hyperledger/fabric-orderer:latest
docker tag hyperledger/fabric-couchdb:x86_64-1.0.4 hyperledger/fabric-couchdb:latest
docker tag hyperledger/fabric-tools:x86_64-1.0.4 hyperledger/fabric-tools:latest

#composer 0.15.2
docker pull hyperledger/composer-playground:0.15.2
docker pull hyperledger/composer-rest-server:0.15.2
docker pull hyperledger/composer-cli:0.15.2
docker tag hyperledger/composer-playground:0.15.2 hyperledger/composer-playground:latest
docker tag hyperledger/composer-rest-server:0.15.2 hyperledger/composer-rest-server:latest
docker tag hyperledger/composer-cli:0.15.2 hyperledger/composer-cli:latest

#clone fabric repo & build cryptogen configtxgen
cd / ; git clone https://github.com/hyperledger/fabric -b v1.0.4
cd / ; mkdir -p go/src/github.com/hyperledger; cd go/src/github.com/hyperledger ; ln -s /fabric . ; cd fabric ; GOPATH=/go make cryptogen configtxgen
cd / ; cp /fabric/build/bin/cryptogen /usr/bin/ ; cp /fabric/build/bin/configtxgen /usr/bin/

#clone sample repo
su ubuntu -c "bash -c 'cd; git clone https://github.com/hyperledger/fabric-samples -b v1.0.2'"

#cloud9 IDE
apt-get install -y curl build-essential nodejs
curl -sL https://deb.nodesource.com/setup_6.x | bash -
cd / ; git clone https://github.com/c9/core.git cloud9
cd /cloud9 && scripts/install-sdk.sh
chmod a+rw -R /cloud9/build
echo 'cd /cloud9 ; su ubuntu -c "screen -d -m nodejs server.js -l 0.0.0.0 -w /home/ubuntu --auth root:secret"' >> /etc/rc.local
cd /cloud9 ; su ubuntu -c "screen -d -m nodejs server.js -l 0.0.0.0 -w /home/ubuntu --auth root:secret"


echo "exit 0" >> /etc/rc.local
SCRIPT


Vagrant.configure('2') do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.provision "shell", inline: $script
  #config.vm.box_version = "1.1.0"
  config.vm.network :forwarded_port, guest: 8080, host: 8080  #composer
  config.vm.network :forwarded_port, guest: 8181, host: 8181  #cloud9-ide
  config.vm.network :forwarded_port, guest: 9090, host: 9090  #custom-ui
end
