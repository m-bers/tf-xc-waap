provider "volterra" {
  api_p12_file = var.xc_p12_path
  url          = var.xc_api_url
}

resource "volterra_origin_pool" "mainapp-pool" {
  name                   = "${var.xc_namespace}-mainapp-pool"
  namespace              = var.xc_namespace
  endpoint_selection     = "DISTRIBUTED"
  loadbalancer_algorithm = "ROUND_ROBIN"
  origin_servers {
    public_ip {
      ip = aws_instance.arcadia-server.public_ip
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
      ip = aws_instance.arcadia-server.public_ip
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
      ip = aws_instance.arcadia-server.public_ip
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
      ip = aws_instance.arcadia-server.public_ip
    }
  }
  port   = "8083"
  no_tls = true
}

resource "volterra_origin_pool" "juice-shop-pool" {
  name                   = "${var.xc_namespace}-juice-shop-pool"
  namespace              = var.xc_namespace
  endpoint_selection     = "DISTRIBUTED"
  loadbalancer_algorithm = "ROUND_ROBIN"
  origin_servers {
    public_ip {
      ip = aws_instance.juice-shop-server.public_ip
    }
  }
  port   = "8080"
  no_tls = true
}

resource "volterra_app_firewall" "arcadia-appfw" {
  name                       = "${var.xc_namespace}-arcadia-appfw"
  namespace                  = var.xc_namespace
  allow_all_response_codes   = true
  disable_anonymization      = true
  use_default_blocking_page  = true
  default_bot_setting        = true
  default_detection_settings = true
  use_loadbalancer_setting   = true
  blocking                   = true
}

resource "volterra_app_firewall" "juice-shop-appfw" {
  name                       = "${var.xc_namespace}-juice-shop-appfw"
  namespace                  = var.xc_namespace
  allow_all_response_codes   = true
  disable_anonymization      = true
  use_default_blocking_page  = true
  default_bot_setting        = true
  default_detection_settings = true
  use_loadbalancer_setting   = true
  blocking                   = true
}

resource "null_resource" "juice-shop-swagger" {
  triggers = {
    swagger_name = "${var.xc_namespace}-juice-shop-swagger"
    xc_password  = var.xc_password
    xc_p12_path  = var.xc_p12_path
    xc_api_url   = var.xc_api_url
    xc_namespace = var.xc_namespace
    swaggerfile  = filebase64(var.swaggerfile_location)
  }
  provisioner "local-exec" {
    working_dir = "${path.module}/swagger"
    command     = <<EOT
      curl -sk --cert-type P12 \
        --cert ${null_resource.juice-shop-swagger.triggers.xc_p12_path}:${null_resource.juice-shop-swagger.triggers.xc_password} \
        -X PUT "${null_resource.juice-shop-swagger.triggers.xc_api_url}/object_store/namespaces/${null_resource.juice-shop-swagger.triggers.xc_namespace}/stored_objects/swagger/${null_resource.juice-shop-swagger.triggers.swagger_name}" \
        -H "Content-Type: application/json" \
        -d '{
          "bytes_value": "${null_resource.juice-shop-swagger.triggers.swaggerfile}",
          "content_format": "yaml",
          "name": "${null_resource.juice-shop-swagger.triggers.swagger_name}",
          "namespace": "${null_resource.juice-shop-swagger.triggers.xc_namespace}",
          "object_type": "swagger"
        }' | jq '.metadata' | jq -r '.version' > version
      EOT
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      curl -sk --cert-type P12 \
        --cert ${self.triggers.xc_p12_path}:${self.triggers.xc_password} \
        -X DELETE "${self.triggers.xc_api_url}/object_store/namespaces/${self.triggers.xc_namespace}/stored_objects/swagger/${self.triggers.swagger_name}?force_delete=true"
      EOT
  }
}

resource "volterra_api_definition" "juice-shop-api-definition" {
  name          = "${var.xc_namespace}-juice-shop-api-definition"
  namespace     = var.xc_namespace
  swagger_specs = ["${var.xc_api_url}/object_store/namespaces/${var.xc_namespace}/stored_objects/swagger/${null_resource.juice-shop-swagger.triggers.swagger_name}/${chomp(file("swagger/version"))}"]
  depends_on    = [null_resource.juice-shop-swagger]
}

resource "volterra_http_loadbalancer" "arcadia-http-lb" {
  name      = "${var.xc_namespace}-arcadia-http-lb"
  namespace = var.xc_namespace
  domains   = ["j-chambers-arcadia.amer-ent.f5demos.com"]
  https_auto_cert {
    http_redirect = true
  }
  single_lb_app {
    enable_discovery {
      disable_learn_from_redirect_traffic = true
    }
    enable_ddos_detection           = true
    enable_malicious_user_detection = true
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
    name      = "${var.xc_namespace}-arcadia-appfw"
    namespace = var.xc_namespace
    tenant    = var.xc_tenant
  }
  depends_on = [
    volterra_origin_pool.mainapp-pool,
    volterra_origin_pool.backend-pool,
    volterra_origin_pool.api-pool,
    volterra_origin_pool.app3-pool,
    volterra_app_firewall.arcadia-appfw
  ]
}

resource "volterra_http_loadbalancer" "juice-shop-http-lb" {
  name      = "${var.xc_namespace}-juice-shop-http-lb"
  namespace = var.xc_namespace
  domains   = ["j-chambers-juice-shop.amer-ent.f5demos.com"]
  https_auto_cert {
    http_redirect = true
  }
  api_definition {
    name      = "${var.xc_namespace}-juice-shop-api-definition"
    namespace = var.xc_namespace
    tenant    = var.xc_tenant
  }
  default_route_pools {
    pool {
      name      = "${var.xc_namespace}-juice-shop-pool"
      namespace = var.xc_namespace
      tenant    = var.xc_tenant
    }
  }
  app_firewall {
    name      = "${var.xc_namespace}-juice-shop-appfw"
    namespace = var.xc_namespace
    tenant    = var.xc_tenant
  }
  depends_on = [
    volterra_origin_pool.juice-shop-pool,
    volterra_app_firewall.juice-shop-appfw
  ]
}