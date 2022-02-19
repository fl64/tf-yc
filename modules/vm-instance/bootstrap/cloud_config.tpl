#cloud-config
disable_root: true
timezone: Europe/Moscow
repo_update: true
packages:
  - tmux
ssh_pwauth: no
users:
  - default
  - name: ${user}
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh-key}


%{ if if_hdd > 0 }
disk_setup:
  /dev/vdb:
    table_type: 'gpt'
    layout: [100]
    overwrite: true
# ------------------------------------------
fs_setup:
  - label: data
    filesystem: 'ext4'
    device: /dev/vdb
    partition: auto
    overwrite: true
# ------------------------------------------
mounts:
  - [/dev/vdb, ${mountpoint}, ext4, defaults]
%{ endif }
