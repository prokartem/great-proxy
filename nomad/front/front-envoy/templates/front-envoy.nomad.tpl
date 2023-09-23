job [[ template "job_name" . ]] {
  type = "service"

  constraint {
    attribute = "${attr.unique.consul.name}"
    operator  = "="
    value     = "front-envoy"
  }

  group [[ template "job_name" . ]] {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        static = 8080
        to = 8080
      }
    }

    service {
      name = "front-envoy-http"
      tags = ["front", "envoy" ]
      port = "http"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "eth-proxy-getblock-http"
              local_bind_port  = 8080
            }
          }
        }
      }
    }

    task [[ template "job_name" . ]] {
      driver = "docker"

      resources {
        cpu = 100
        memory = 500
      }

      template {
        data = <<EOH[[ template "config" . ]]EOH
        destination = "local/front-envoy.yaml"
      }

      config {
        image = "envoyproxy/envoy:v1.26-latest"
        ports = ["http"]
        volumes = ["local/front-envoy.yaml:/etc/envoy/envoy.yaml"]
        args  = [
          "--config-path",
          "/etc/envoy/envoy.yaml",
          "-l", "debug"
        ]
      }
    }
  }
}
