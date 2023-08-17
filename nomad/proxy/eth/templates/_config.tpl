[[ define "config" ]]
admin:
  address:
    socket_address:
      address: 0.0.0.0
      port_value: 9902

static_resources:
  listeners:
  - name: eth-[[ .my.node_provider ]]
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
            response_headers_to_add:
              - header:
                  key: "node-provider"
                  value: "[[ .my.node_provider ]]"
            virtual_hosts:
            - name: eth-[[ .my.node_provider ]]
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  host_rewrite_literal: [[ .my.domain ]]
                  prefix_rewrite: [[ .my.api_key ]]
                  cluster: eth-[[ .my.node_provider ]]
  clusters:
  - name: eth-[[ .my.node_provider ]]
    type: LOGICAL_DNS
    # Comment out the following line to test on v6 networks
    dns_lookup_family: V4_ONLY
    load_assignment:
      cluster_name: eth-[[ .my.node_provider ]]
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: [[ .my.domain ]]
                port_value: 443
    transport_socket:
      name: envoy.transport_sockets.tls
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        sni: [[ .my.domain ]]
[[ end ]]