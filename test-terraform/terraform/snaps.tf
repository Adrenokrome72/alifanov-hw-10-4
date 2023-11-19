resource "yandex_compute_snapshot_schedule" "snaps" {
  name = "snaps"

  schedule_policy {
    expression = "0 3 ? * *"
  }

  snapshot_count = 7

  snapshot_spec {
    description = "daily"
  }

  disk_ids = [yandex_compute_instance.vm1.boot_disk[0].disk_id,
    yandex_compute_instance.vm2.boot_disk[0].disk_id,
    yandex_compute_instance.vm3.boot_disk[0].disk_id,
    yandex_compute_instance.vm4.boot_disk[0].disk_id,
    yandex_compute_instance.vm5.boot_disk[0].disk_id,
    yandex_compute_instance.vm6.boot_disk[0].disk_id,
  yandex_compute_instance.vm7.boot_disk[0].disk_id]
}
