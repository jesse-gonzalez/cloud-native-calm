#cloud-config
package_update: true
packages:
  - iscsi-initiator-utils
  - nfs-utils
runcmd:
  - systemctl stop NetworkManager && systemctl disable NetworkManager
  - systemctl enable '--now' iscsid
  - systemctl stop firewalld && systemctl disable firewall
  - update-ca-trust extract
users:
  - default
  - name: nutanix
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC18boRNk4bUsuT+FvYopFZm3pcho7iB3vi9nw50gbs2WmJUd3Kp9S6nmgoqy/sp7dUK9i4pq+RiAErCta31zKjft4XtdFCb7wy+xfiQeO2zz88WFO0B9Beqa017/d5YzPx4iVmEkJsdNqMquPRtCmUw7AtdWNJeSDy45NfnQWU3mYxl0eE96Z4JUQ9/r640Fqk5O/9rainaOoAO+0gzCi0+HLk+/IbocEViBuuG6R38ai90WBM56/ghd65ySDKbQQ2l/tR23kKXX9VCGf3C/274wWumlaI33ALOliOlL0e2zkpxdRQPCCjBeCtRrCwPFlGa5Y4fSYvP9d65xxG1aPj nutanix@nutanix
      