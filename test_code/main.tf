terraform {
  cloud {
    hostname = "tfe19.aws.munnep.com"
    organization = "test"

    workspaces {
      name = "test5"
    }
  }
}

resource "null_resource" "example22" {
}
