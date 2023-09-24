job [[ template "job_name" . ]] {
  type = "service"

  constraint {
    attribute = "${node.class}"
    value     = "proxy"
  }

  group [[ template "job_name" . ]] {
    count = 1

    network {
      mode = "bridge"
    }

    service {
      name = "eth-proxy-[[ .my.node_provider ]]-http"
      tags = ["proxy", "eth", [[ .my.node_provider | quote ]] ]
      port = 8080

      connect {
        sidecar_service {
          proxy {}
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
        destination = "local/eth-proxy-[[ .my.node_provider ]].yaml"
      }

      config {
        image = "envoyproxy/envoy:v1.26-latest"
        ports = ["http"]
        volumes = ["local/eth-proxy-[[ .my.node_provider ]].yaml:/etc/envoy/envoy.yaml"]
        args  = [
          "--config-path",
          "/etc/envoy/envoy.yaml",
          "-l", "debug"
        ]
      }
    }
  }
}
