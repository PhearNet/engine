/*
The MIT License (MIT)

Copyright (c) 2014 PhearZero

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

job "engine" {
  datacenters = [
    "dc1", "home"
  ]
  type = "system"
  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }
  update {
    stagger = "10s"
    max_parallel = 1
  }
  group "services" {
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "fail"
    }

    task "swarm-manage" {
      driver = "docker"
      config {
        image = "swarm:latest"
        network_mode = "host"
        args = [
          "manage",
          "-H",
          ":4000",
          "--replication",
          "--advertise",
          "${meta.IP}:4000",
          "consul://localhost:8500"
        ]
      }
      resources {
        cpu = 250
        memory = 128
        network {
          mbits = 10
        }
      }
    }
    task "registrator" {
      driver = "docker"
      config {
        image = "gliderlabs/registrator:latest"
        network_mode = "host"
        args = [
          "consul://localhost:8500"
        ]
        volumes = [
          "/var/run/docker.sock:/tmp/docker.sock"
        ]
      }
      resources {
        cpu = 250
        memory = 128
        network {
          mbits = 10
        }
      }
    }
  }
}