terraform {
    required_version = "0.13.5"

    required_providers {
        digitalocean = {
            source  = "digitalocean/digitalocean"
            version = "~> 1.22.0"
        }

        local = {
            source  = "hashicorp/local"
            version = "~> 2.0.0"
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

resource "digitalocean_kubernetes_cluster" "platform_cluster" {
    name    = var.cluster_name
    region  = "lon1"
    version = "1.19.3-do.2"
    tags    = var.cluster_tags

    node_pool {
        name       = "worker-pool"
        size       = "s-1vcpu-2gb"
        node_count = 1
        tags       = var.node_tags
    }
}

provider "helm" {
    kubernetes {
        load_config_file       = false
        host                   = digitalocean_kubernetes_cluster.platform_cluster.endpoint
        token                  = digitalocean_kubernetes_cluster.platform_cluster.kube_config[0].token
        cluster_ca_certificate = base64decode(
            digitalocean_kubernetes_cluster.platform_cluster.kube_config[0].cluster_ca_certificate
        )
    }
}

resource "helm_release" "nginx" {
    name       = "iexperiment"
    chart      = "nginx-ingress"
    repository = "https://kubernetes-charts.storage.googleapis.com"
    depends_on = digitalocean_kubernetes_cluster.platform_cluster

    set {
        name  = "controller.service.nodePorts.http"
        value = "8081"
    }

    set {
        name = "nginx.ingress.kubernetes.io/force-ssl-redirect"
        value = true
    }

    set {
        name = "controller.publishService.enabled"
        value = true
    }
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


provider "kubernetes" {
    load_config_file       = false
    host                   = digitalocean_kubernetes_cluster.platform_cluster.endpoint
    token                  = digitalocean_kubernetes_cluster.platform_cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(
        digitalocean_kubernetes_cluster.platform_cluster.kube_config[0].cluster_ca_certificate
    )
}

resource "kubernetes_ingress" "ingress_load_balancer" {
    metadata {
        name = "ingress-lb"
        annotations = {
            "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
            "nginx.ingress.kubernetes.io/force-ssl-redirect" ="true"
        }
    }

    spec {
        backend {
            service_name = "app1"
            service_port = 8080
        }

        rule {
            http {
                path {
                    backend {
                        service_name = "app1"
                        service_port = 8080
                    }

                    path = "/app1/*"
                }

                path {
                    backend {
                        service_name = "app2"
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

resource "local_file" "kubeconfig" {
    content  = digitalocean_kubernetes_cluster.platform_cluster.kube_config[0].raw_config
    filename = pathexpand(var.kubeconfig_path)
}
