resource "yandex_compute_snapshot_schedule" "snapshot_schedule" {
  name = "snapshot_schedule"
  schedule_policy {
	expression = "10 0 ? * *"
  }
  retention_period = "168h"
}
