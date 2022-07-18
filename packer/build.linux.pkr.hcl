build {
    sources = [
        "source.nutanix.centos8_build"
    ]
    // provisioner "shell" {
    //     inline = ["mkdir -p /opt/ocp-darkside/{source,mirror,mirror-registry}",
    //               "mount /dev/sr1 /opt/ocp-darkside/source",
    //               "tar -xvzf /opt/ocp-darkside/source/mirror-registry.tar.gz -C /opt/ocp-darkside/mirror-registry/",
    //               "install /opt/ocp-darkside/source/oc /usr/local/bin/oc",
    //               "cp -r /opt/ocp-darkside/source/mirror/ /opt/ocp-darkside/"]
    // }

    post-processor "manifest" {
      output = "manifest.json"
      strip_path = true
}
}
