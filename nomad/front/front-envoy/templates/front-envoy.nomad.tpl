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
        static = 80
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
            [[- range $protocol := .my.protocols ]]
              [[- range $id, $provider := $protocol.providers ]]
            upstreams {
              destination_name = "[[- $protocol.name ]]-proxy-[[- $provider ]]-http"
              local_bind_port  = [[ add 8081 $id ]]
            }
              [[- end ]]        
            [[- end ]]
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
