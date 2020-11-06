terraform {
    required_version = "0.13.5"

    required_providers {
        digitalocean = {
            source = "digitalocean/digitalocean"
            version = "~> 1.22.0"
        }
    }

    backend "remote" {
        organization = "PurpleTreeTech"

        workspaces {
            name = "mihaiblebea-platform"
        }
    }
}

provider "digitalocean" {
    token   = var.do_token
    version = "1.22.0"
}

resource "digitalocean_kubernetes_cluster" "cluster" {
    name    = var.cluster_name
    region  = "lon1"
    version = "1.18.6-do.0"
    # tags    = var.cluster_tags

    node_pool {
        name       = "worker-pool"
        size       = "s-1vcpu-2gb"
        node_count = 1
        tags       = var.node_tags
    }
}

# data "digitalocean_kubernetes_cluster" "cluster" {
#     name = var.cluster_name
# }

resource "local_file" "kubeconfig" {
    content  = digitalocean_kubernetes_cluster.cluster.kube_config[0].raw_config
    filename = pathexpand(var.kubeconfig_path)
}

# resource "digitalocean_domain" "mihaiblebea_com" {
#     name       = var.domain_name
#     ip_address = digitalocean_loadbalancer.public.ip
# }

# resource "digitalocean_certificate" "mihaiblebea" {
#     name    = "mihaiblebea-cert"
#     type    = "lets_encrypt"
#     domains = [var.domain_name]
# }

# resource "digitalocean_record" "txt_google_search_console" {
#     domain   = var.domain_name
#     type     = "TXT"
#     name     = "@"
#     priority = 10
#     value    = var.google_search_console_code
# }

# resource "digitalocean_loadbalancer" "public" {
#     name   = "loadbalancer-1"
#     region = "lon1"

#     forwarding_rule {
#         entry_port     = 80
#         entry_protocol = "http"

#         target_port     = 30011
#         target_protocol = "http"
#     }

#     forwarding_rule {
#         entry_port     = 443
#         entry_protocol = "https"

#         target_port     = 30011
#         target_protocol = "http"

#         certificate_id = digitalocean_certificate.mihaiblebea.id
#     }

#     healthcheck {
#         port     = 22
#         protocol = "tcp"
#     }

#     redirect_http_to_https = true

#     droplet_ids = [var.droplet_id]
# }

resource "kubernetes_ingress" "ingress_lb" {
    metadata {
        name = "ingress-lb"
    }

    spec {
        backend {
            service_name = "MyApp1"
            service_port = 8080
        }

        rule {
            http {
                path {
                    backend {
                        service_name = "MyApp1"
                        service_port = 8080
                    }

                    path = "/app1/*"
                }

                path {
                    backend {
                        service_name = "MyApp2"
                        service_port = 8080
                    }

                    path = "/app2/*"
                }
            }
        }

        tls {
            secret_name = "tls-secret"
        }
    }
}