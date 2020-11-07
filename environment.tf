variable "do_token" {
    description = "Digital ocean auth token"
}

variable "cluster_name" {
    description = "Name of the digital ocean kubernetes cluster"
    default     = "mihaiblebea-platform-cluster"
}

variable "node_pool_name" {
    description = "Name of the node pool in digital ocean"
    default     = "mihaiblebea-platform-node-pool"
}

variable "node_tags" {
    description = "Node tags to reference the node worker"
    default     = ["worker-node"]
}

variable "cluster_tags" {
    description = "Node tags to reference the node worker"
    default     = ["k8s-cluster"]
}

variable "domain_name" {
    description = "Domain name for the cluster entrypoint. Ex. mihaiblebea.com"
    default     = "mihaiblebea.com"
}

variable "kubeconfig_path" {
    description = "Path to save the kube config locally"
    default     = "~/.kube/test-mihaiblebea-platform.yaml"
}

variable "google_search_console_code" {
    description = "Code from google search console to verify domain ownership"
    default     = "serban"
}