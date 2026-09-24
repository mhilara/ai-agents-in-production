variable "region" {
  description = "Region de la demo. Aislada: no hay nada mas aqui."
  type        = string
  default     = "us-east-2"
}

variable "name" {
  description = "Prefijo de todos los recursos."
  type        = string
  default     = "dataplat-prod"
}

variable "service_name" {
  description = "Servicio de la plataforma de datos."
  type        = string
  default     = "ingest-api"
}

variable "app_version" {
  description = "Version desplegada de ingest-api. Cambiar aca = desplegar."
  type        = string
  default     = "1.4.0"
}

variable "app_message" {
  description = "Variable de entorno que la app necesita para arrancar. Vacia = crash loop."
  type        = string
  default     = "ok"
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "github_repo" {
  description = "owner/repo que puede asumir el rol de CI por OIDC."
  type        = string
  default     = "mhilara/ai-agents-in-production"
}

variable "budget_alert_email" {
  type    = string
  default = "" # se pasa por terraform.tfvars, no se publica
}
