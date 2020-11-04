variable "do_token" {
    description = "Digital ocean auth token"
}

variable "cluster_name" {
    description = "Name of the digital ocean kubernetes cluster"
    default = "mihaiblebea-platform-cluster"
}

variable "node_pool_name" {
    description = "Name of the node pool in digital ocean"
    default = "mihaiblebea-platform-node-pool"
}

variable "domain_name" {
    description = "Domain name for the cluster entrypoint. Ex. mihaiblebea.com"
    default = "mihaiblebea.com"
}

variable "google_search_console_code" {
    description = "Code from google search console to verify domain ownership"
}