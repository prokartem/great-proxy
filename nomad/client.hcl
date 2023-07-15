#sudo nomad agent -config=/etc/nomad.d/client.hcl -bind=192.168.56.22 -data-dir=/opt/nomad -network-interface='eth1'

client {
  enabled = true
}
consul {
  address = "192.168.56.22:8500" # host ip 