#sudo nomad agent -config=/etc/nomad.d/server.hcl -bind=192.168.56.20 -data-dir=/opt/nomad

server {
  enabled = true
  bootstrap_expect = 1
}

consul {
  address = "192.168.56.20:8500" # host ip
}