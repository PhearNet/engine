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

if $::ipaddress_enp0s8 != undef {
  $listen_addr = $::ipaddress_enp0s8
}
elsif $::ipaddress_eth1 != undef {
  $listen_addr = $::ipaddress_eth1
}
elsif $::ipaddress_eth0 != undef and $::ipaddress_eth1 == undef {

  $listen_addr = $::ipaddress_eth0
} else{
  $listen_addr = "0.0.0.0"
}

if $hostname != undef {
  $node_name = $hostname
}
else {
  $node_name = "testing.local"
}
package {'unzip':
  ensure => present
}

file { '/etc/sysconfig':
  ensure => 'directory',
}

class { 'docker':
  docker_users => ['vagrant'],
}

node /nomad/ {
  class { 'nomad':
    require     => [ Class['docker'], Class['consul'], Package['unzip'] ],
    version => '0.5.0-rc1',
    config_hash => {
      'enable_syslog' => true,
      # 'datacenter' => 'home',
      'bind_addr'  => '0.0.0.0',
      'data_dir'   => '/opt/nomad',

      'advertise'  => {
        'serf'  => join([$listen_addr, ":4648"]),
        'http' => "0.0.0.0:4646",
        'rpc'  => join([$listen_addr, ":4647"]),
      },

      'server'     => {
        'enabled'          => true,
        'bootstrap_expect' => 2,
      },

      'client'     => {
        'enabled'       => true,
        'options' => {
          'driver.raw_exec.enable' => 1,
        },
        'meta' => {
          'IP' => $listen_addr,
        },
      }
    }
  }
}
node /consul/ {
  class { 'consul':
    require     => Package['unzip'],
    config_hash => {
      'bootstrap_expect'     => 2,
      'bind_addr'            => $listen_addr,
      'client_addr'          => '0.0.0.0',
      'advertise_addr'       => $listen_addr,
      'data_dir'             => '/opt/consul',
      # 'datacenter'           => 'home'
      'node_name'            => $node_name,
      'server'               => true,
      'ui_dir'               => '/opt/consul/ui',
      'atlas_infrastructure' => 'phearnet/engine',
      'atlas_join'           => true
    }
  }
}