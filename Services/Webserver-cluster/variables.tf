variable "cluster_name" {
  description = "The name to be used by all cluster resources"
  type = string
}

variable "region"{
    description = "Specifies default region"
    type = string
    default = "eu-central-1"
}

variable "server_port" {
    description = "Port servera"
    type = number
    default = "80"
}

variable "min_size"{
    description = "minumum ASG size"
    type = number
    default = 2
}

variable "max_size"{
    description = "maximum ASG size"
    type = number
    default = 4
}