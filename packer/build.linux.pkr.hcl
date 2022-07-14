build {
        sources = [
            "source.nutanix.ocp_darkside"
        ]
    provisioner "shell" {
        inline = ["mkdir -p /opt/ocp-darkside/{source,mirror,mirror-registry}",
                  "mount /dev/sr1 /opt/ocp-darkside/source",
                  "tar -xvzf /opt/ocp-darkside/source/mirror-registry.tar.gz -C /opt/ocp-darkside/mirror-registry/",
                  "install /opt/ocp-darkside/source/oc /usr/local/bin/oc",
                  "cp -r /opt/ocp-darkside/source/mirror/ /opt/ocp-darkside/"]
    }

#    provisioner "shell" {
#        inline = ["mkdir -p /opt/ocp-darkside/{content,mirror-registry}"]
#    }
#    provisioner "file" {
#        source = "/tmp/add-files/mirror-registry"
#        destination = "/opt/ocp-darkside"
#    }
#    provisioner "file" {
#        source = "/tmp/add-files/content/"
#        destination = "/opt/ocp-darkside/content"
#    }
#    provisioner "file" {
#        source = "/tmp/add-files/images/"
#        destination = "/opt/ocp-darkside/images"
#    }
#    provisioner "shell" {
#        inline = ["tar -xvzf /opt/ocp-darkside/mirror-registry/mirror-registry.tar.gz"]
#    }
    post-processor "manifest" {
      output = "manifest.json"
      strip_path = true
}
}
