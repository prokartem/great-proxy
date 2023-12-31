[[ define "config" ]]
admin:
  address:
    socket_address:
      address: 0.0.0.0
      port_value: 9902

static_resources:
  listeners:
  - name: front-proxy
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 8080
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          access_log:
          - name: envoy.access_loggers.stdout
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.stream.v3.StdoutAccessLog
          http_filters:
          - name: envoy.filters.http.router
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
          route_config:
            name: local_route
            virtual_hosts:
            - name: front-proxy
              domains: ["*"]
              routes:
              - match:
                  prefix: "/admin/nomad"
                route:
                  prefix_rewrite: "/"
                  cluster: nomad
              - match:
                  prefix: "/admin/consul"
                route:
                  prefix_rewrite: "/"
                  cluster: consul
              [[- range $protocol := .my.protocols ]]
              - match:
                  prefix: "/[[- $protocol.name ]]"
                route:
                  prefix_rewrite: "/"
                  cluster: [[ $protocol.name ]]-proxy
              [[- end]]

  clusters:
  - name: nomad
    lb_policy: ROUND_ROBIN
    type: STRICT_DNS
    # Comment out the following line to test on v6 networks
    # dns_lookup_family: V4_ONLY
    load_assignment:
      cluster_name: nomad
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 192.168.56.86
                port_value: 4646
  - name: consul
    lb_policy: ROUND_ROBIN
    type: STRICT_DNS
    # Comment out the following line to test on v6 networks
    # dns_lookup_family: V4_ONLY
    load_assignment:
      cluster_name: consul
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 192.168.56.86
                port_value: 8500
[[- range $protocol := .my.protocols ]]
  - name: [[ $protocol.name ]]-proxy
    lb_policy: ROUND_ROBIN
    type: STRICT_DNS
    # Comment out the following line to test on v6 networks
    # dns_lookup_family: V4_ONLY
    outlier_detection:
      consecutive_5xx: 2
    load_assignment:
      cluster_name: [[ $protocol.name ]]-proxy
      endpoints:
      - lb_endpoints:
  [[- range $id, $provider := $protocol.providers ]]
        - endpoint:
            address:
              socket_address:
                address: {{ env "NOMAD_UPSTREAM_IP_[[- $protocol.name ]]-proxy-[[- $provider ]]-http" }}
                port_value: {{ env "NOMAD_UPSTREAM_PORT_[[- $protocol.name ]]-proxy-[[- $provider ]]-http" }}
  [[- end ]]        
[[- end ]]

[[ end ]]