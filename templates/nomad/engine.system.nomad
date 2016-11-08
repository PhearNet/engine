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