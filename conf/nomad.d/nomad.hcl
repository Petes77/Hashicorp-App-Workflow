consul {
  address = "127.0.0.1:8321"
  ssl       = true
  ca_file   = "/etc/ssl/certs/consul-agent-ca.pem"
  cert_file = "/etc/consul.d/pki/tls/certs/consul-client.pem"
  key_file  = "/etc/consul.d/pki/tls/private/consul-client-key.pem"
  token = "244d2ca0-0db1-739c-1331-c300372012b9"
  }

# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/usr/local/nomad"

datacenter = "hashistack1"

# Enable the server
server {
  enabled = true

  # Self-elect, should be 3 or 5 for production
  bootstrap_expect = 1

  encrypt = "bulIITLYF65YbYUNnIiHqQ=="
}

# Require TLS
tls {
  http = true
  rpc  = true

  ca_file   = "/etc/ssl/certs/nomad-agent-ca.pem"
  cert_file = "/etc/nomad.d/pki/tls/certs/nomad-server.pem"
  key_file  = "/etc/nomad.d/pki/tls/private/nomad-server-key.pem"

  verify_server_hostname = true
  verify_https_client    = true
}
