# State remoto para que el pipeline pueda aplicar el fix.
# El bucket NO va en el repo: se pasa con -backend-config (local: backend.hcl,
# en CI: una variable del repositorio). Lock nativo de S3, sin DynamoDB.
terraform {
  backend "s3" {
    key          = "dataplat-prod/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }
}
