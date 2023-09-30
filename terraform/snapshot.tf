resource "yandex_compute_snapshot_schedule" "snapshot" {
  schedule_policy {
	expression = "0 2 * * *"
  }

  retention_period = "168h"

}
