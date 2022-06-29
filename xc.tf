provider "volterra" {
  api_p12_file = "/home/ubuntu/tf/f5-amer-ent.console.ves.volterra.io.api-creds.p12"
  url          = "https://f5-amer-ent.console.ves.volterra.io/api"
}

resource "volterra_origin_pool" "mainapp-pool" {
  name                   = "${var.xc_namespace}-mainapp-pool"
  namespace              = var.xc_namespace
  endpoint_selection     = "DISTRIBUTED"
  loadbalancer_algorithm = "ROUND_ROBIN"
  origin_servers {
    public_ip {
      ip = aws_instance.nginx_server.public_ip
    }
  }
  port   = "8080"
  no_tls = true
}

resource "volterra_origin_pool" "backend-pool" {
  name                   = "${var.xc_namespace}-backend-pool"
  namespace              = var.xc_namespace
  endpoint_selection     = "DISTRIBUTED"
  loadbalancer_algorithm = "ROUND_ROBIN"
  origin_servers {
    public_ip {
      ip = aws_instance.nginx_server.public_ip
    }
  }
  port   = "8081"
  no_tls = true
}

resource "volterra_origin_pool" "api-pool" {
  name                   = "${var.xc_namespace}-api-pool"
  namespace              = var.xc_namespace
  endpoint_selection     = "DISTRIBUTED"
  loadbalancer_algorithm = "ROUND_ROBIN"
  origin_servers {
    public_ip {
      ip = aws_instance.nginx_server.public_ip
    }
  }
  port   = "8082"
  no_tls = true
}

resource "volterra_origin_pool" "app3-pool" {
  name                   = "${var.xc_namespace}-app3-pool"
  namespace              = var.xc_namespace
  endpoint_selection     = "DISTRIBUTED"
  loadbalancer_algorithm = "ROUND_ROBIN"
  origin_servers {
    public_ip {
      ip = aws_instance.nginx_server.public_ip
    }
  }
  port   = "8083"
  no_tls = true
}

resource "volterra_app_firewall" "nginx-appfw" {
  name                       = "${var.xc_namespace}-nginx-appfw"
  namespace                  = var.xc_namespace
  allow_all_response_codes   = true
  disable_anonymization      = true
  use_default_blocking_page  = true
  default_bot_setting        = true
  default_detection_settings = true
  use_loadbalancer_setting   = true
  blocking                   = true
}

resource "volterra_http_loadbalancer" "nginx-http-lb" {
  name      = "${var.xc_namespace}-nginx-http-lb"
  namespace = var.xc_namespace
  domains   = ["j-chambers-nginx.amer-ent.f5demos.com"]
  https_auto_cert {
    http_redirect = true
  }
  default_route_pools {
    pool {
      name      = "${var.xc_namespace}-mainapp-pool"
      namespace = var.xc_namespace
      tenant    = var.xc_tenant
    }
  }
  routes {
    simple_route {
      path {
        prefix = "/files"
      }
      origin_pools {
        pool {
          name      = "${var.xc_namespace}-backend-pool"
          namespace = var.xc_namespace
          tenant    = var.xc_tenant
        }
      }
    }
  }
  routes {
    simple_route {
      path {
        prefix = "/api"
      }
      origin_pools {
        pool {
          name      = "${var.xc_namespace}-api-pool"
          namespace = var.xc_namespace
          tenant    = var.xc_tenant
        }
      }
    }
  }
  routes {
    simple_route {
      path {
        prefix = "/app3"
      }
      origin_pools {
        pool {
          name      = "${var.xc_namespace}-app3-pool"
          namespace = var.xc_namespace
          tenant    = var.xc_tenant
        }
      }
    }
  }
  app_firewall {
    name      = "${var.xc_namespace}-nginx-appfw"
    namespace = var.xc_namespace
    tenant    = var.xc_tenant
  }
  depends_on = [
    volterra_origin_pool.mainapp-pool,
    volterra_origin_pool.backend-pool,
    volterra_origin_pool.api-pool,
    volterra_origin_pool.app3-pool,
    volterra_app_firewall.nginx-appfw
  ]
}