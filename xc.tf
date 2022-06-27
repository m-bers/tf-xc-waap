provider "volterra" {
  api_p12_file = "/home/ubuntu/tf/f5-amer-ent.console.ves.volterra.io.api-creds.p12"
  url          = "https://f5-amer-ent.console.ves.volterra.io/api"
}

resource "volterra_origin_pool" "nginx-pool" {
  name                   = "nginx-pool"
  namespace              = var.XC_NAMESPACE
  endpoint_selection     = "DISTRIBUTED"
  loadbalancer_algorithm = "ROUND_ROBIN"
  origin_servers {
    public_ip {
      ip = aws_instance.nginx_server.public_ip
    }
  }
  port   = "80"
  no_tls = true
}

# resource "volterra_http_loadbalancer" "nginx_http_lb" {
#   name      = "nginx-http_lb"
#   namespace = var.XC_NAMESPACE
#   domains   = ["j-chambers-nginx.amer-ent.f5demos.com"]
#   default_route_pools {
#     pool {
#       name      = "nginx-pool"
#       namespace = var.XC_NAMESPACE
#       tenant    = var.XC_TENANT
#     }
#   }
# }