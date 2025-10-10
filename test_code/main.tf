terraform {
  cloud {
    hostname = "tfe19.aws.munnep.com"
    organization = "test"

    workspaces {
      name = "test2"
    }
  }
}

resource "null_resource" "example22" {
}
