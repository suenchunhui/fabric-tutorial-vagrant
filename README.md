# Introduction
This REPO contains a Vagrant-based VM for running hyperledger fabric and composer examples and sample (include cloud9 IDE)

# Preparation
- Download and install vagrant (include virtualbox installation) on the host system from [vagrantup.com](https://www.vagrantup.com/downloads.html)
- If you are using windows 7, please use [vagrant 1.9.6 only](https://releases.hashicorp.com/vagrant/1.9.6/)
- Download the `Vagrantfile` from this repo at this [link](https://raw.githubusercontent.com/suenchunhui/fabric-tutorial-vagrant/master/Vagrantfile) to an empty folder

# Settings
- Adjust the VM memory and number of cores, in the `Vagrantfile` using a text editor at the lines:
```
v.memory = 2048
v.cpus = 2
```

#Provisioning
- change directory to the folder containing the downloaded `Vagrantfile`
- run `vagrant up` from the commandline(OSX: terminal, Win: cmd.exe) to provision the entire system. Download and provisioning system can take a long up (up to 10-20mins)
- Once you reach the success screen output, 
```
==> default:
==> default: tern_from_ts@0.0.1 node_modules/tern_from_ts
==> default: --------------------------------------------------------------------
==> default: Success!
==> default: run 'node server.js -p 8080 -a :' to launch Cloud9
==> default: ++ echo 'cd /cloud9 ; su ubuntu -c "nodejs server.js -l 0.0.0.0 -w /home/ubuntu --auth root:secret" &'
==> default: ++ cd /cloud9
==> default: ++ su ubuntu -c 'nodejs server.js -l 0.0.0.0 -w /home/ubuntu --auth root:secret'
```
- and the terminal command exits, you can open the browser based IDE at [localhost:8181](http://localhost:8181)

#Using fabric samples
The repo containing [hyperledger fabric samples](https://github.com/hyperledger/fabric-samples) are already downloaded inside the provisioned VM. You can use the browser IDE to run the sample scripts directly in the cloud9 IDE.