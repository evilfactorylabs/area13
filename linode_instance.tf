resource "linode_instance" "evilfactorylabs_social" {
  label  = "evilfactorylabs.social"
  region = "ap-south"
  type   = "g6-standard-1"

  config {
    kernel      = "linode/grub2"
    label       = "My Rocky Linux 9 Disk Profile"
    root_device = "/dev/sda"

    devices {
      sda {
        disk_label = "Rocky Linux 9 Disk"
      }

      sdb {
        disk_label = "512 MB Swap Image"
      }
    }
  }

  disk {
    label = "Rocky Linux 9 Disk"
    size  = 50688
  }
  disk {
    label = "512 MB Swap Image"
    size  = 512
  }
}
