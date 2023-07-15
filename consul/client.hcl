#consul agent -config-file=/etc/consul.d/client.hcl

data_dir = "/opt/consul"
client_addr = "192.168.56.22" # host ip
server = false
bind_addr = "192.168.56.22" # host ip
retry_join = ["192.168.56.20"] # server ip