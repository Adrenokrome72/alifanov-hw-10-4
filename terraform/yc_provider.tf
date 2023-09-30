terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = "y0_AgAAAAANohnHAATuwQAAAADguCDoKJbDj-MMTQSD67---STyjF2ZNlU"
  cloud_id  = "b1gultsdn2kt5v4q1lct"
  folder_id = "b1g6o3gbemoas6ebc6jt"
}
