# -*- mode: ruby -*-
# vi: set ft=ruby :

# The MIT License (MIT)
#
# Copyright (c) 2014 PhearZero
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Size of the current cluster
CLUSTER_SIZE=3

# Setup the VM's subdomain based FQDN
DOMAIN_NAME="phearzero.com"
SUBDOMAIN_PREFIX="nomad"
SUBDOMAIN_SEPARATOR="-"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Good ole ubuntu
  # config.vm.box = "ubuntu/precise64"
  # config.vm.box = "ubuntu/xenial64"
  # config.vm.box = "puppetlabs/ubuntu-16.04-64-puppet"
  config.vm.box = "puppetlabs/ubuntu-14.04-64-puppet"
  #config.vm.box = "puppetlabs/ubuntu-12.04-64-puppet"

  # Disable Shared Folder
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # Set bash defaults
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  # Configure interface for internal traffic
  config.vm.network "private_network", type: "dhcp"

  # Up the juice!
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
  end

  # Provision Nomad/Docker/Consul on all nodes
  config.vm.provision "puppet" do |puppet|
    #puppet.module_path = "modules"
    puppet.environment_path = "environments"
    puppet.environment = "develop"
  end

  # Launch a set number of nodes
  (1..CLUSTER_SIZE).each do |i|
    config.vm.define nodeName = "#{SUBDOMAIN_PREFIX}#{SUBDOMAIN_SEPARATOR}#{i}" do |node|
      # Hostname is prefix + node count
      node.vm.hostname = "#{nodeName}.#{DOMAIN_NAME}"
      # Forward the consul ui port for each node
      node.vm.network "forwarded_port", guest: 8500, host: 8500 + i
      # Add the engine configuration
      node.vm.provision "file", source: "./templates/nomad/engine.system.nomad", destination: "/home/vagrant/run.nomad"
      #TODO: Start the engine with an entrypoint!
      node.vm.provision "shell", inline: "usermod -G docker -a nomad && service nomad restart"
    end
  end
end