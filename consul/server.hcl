#consul agent  -config-file=/etc/consul.d/server.hcl

data_dir = "/opt/consul"

client_addr = "192.168.56.20" # host ip

ui_config{
 enabled = true
}

server = true


bind_addr = "192.168.56.20" # host ip

bootstrap_expect=1