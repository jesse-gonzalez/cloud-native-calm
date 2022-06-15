import os
import json
import base64

import base64
import json
import os

from calm.dsl.builtins import *  # no_qa

from calm.dsl.config import get_context

ContextObj = get_context()
init_data = ContextObj.get_init_config()

# Credentials definition

if file_exists(os.path.join(init_data["LOCAL_DIR"]["location"], "nutanix_key_user")):
    NutanixKeyUser = read_local_file("nutanix_key_user")
else:
    NutanixKeyUser = "nutanix"

if file_exists(os.path.join(init_data["LOCAL_DIR"]["location"], "nutanix_user")):
    NutanixUser = read_local_file("nutanix_user")
else:
    NutanixUser = "nutanix"

if file_exists(os.path.join(init_data["LOCAL_DIR"]["location"], "prism_central_user")):
    PrismCentralUser = read_local_file("prism_central_user")
else:
    PrismCentralUser = "admin"

if file_exists(os.path.join(init_data["LOCAL_DIR"]["location"], "prism_element_user")):
    PrismElementUser = read_local_file("prism_element_user")
else:
    PrismElementUser = "admin"

NutanixPublicKey = read_local_file("nutanix_public_key")
NutanixKey = read_local_file("nutanix_key")

NutanixCred = basic_cred(
                    NutanixKeyUser,
                    name="Nutanix",
                    type="KEY",
                    password=NutanixKey,
                    default=True
                )

NutanixPassword = read_local_file("nutanix_password")
NutanixPasswordCred = basic_cred(
                    NutanixUser,
                    name="Nutanix Password",
                    type="PASSWORD",
                    password=NutanixPassword,
                    default=True
                )

PrismCentralPassword = read_local_file("prism_central_password")
PrismCentralCred = basic_cred(
                    PrismCentralUser,
                    name="Prism Central User",
                    type="PASSWORD",
                    password=PrismCentralPassword,
                    default=False
                )

PrismElementPassword = read_local_file("prism_element_password")
PrismElementCred = basic_cred(
                    PrismElementUser,
                    name="Prism Element User",
                    type="PASSWORD",
                    password=PrismElementPassword,
                    default=False
                )

# OS_USERNAME = read_local_file(os.path.join(init_data["LOCAL_DIR"]["location"], "nutanix_key_user"))
# OS_KEY = read_local_file(os.path.join(init_data["LOCAL_DIR"]["location"], "nutanix_key"))
# NutanixPublicKey = read_local_file(os.path.join(init_data["LOCAL_DIR"]["location"], "nutanix_public_key"))
# NutanixCred = basic_cred(
#     OS_USERNAME,
#     OS_KEY,
#     name="NutanixCred",
#     type="KEY",
#     default=True,
# )


# PC_USERNAME = read_local_file(os.path.join(init_data["LOCAL_DIR"]["location"], "prism_central_user"))
# PC_PASSWORD = read_local_file(os.path.join(init_data["LOCAL_DIR"]["location"], "prism_central_password"))
# PrismCentralCred = basic_cred(
#     PC_USERNAME,
#     PC_PASSWORD,
#     name="PrismCentralCred",
#     type="PASSWORD",
#     default=False,
# )


# PE_USERNAME = read_local_file(os.path.join(init_data["LOCAL_DIR"]["location"], "prism_element_user"))
# PE_PASSWORD = read_local_file(os.path.join(init_data["LOCAL_DIR"]["location"], "prism_element_password"))
# PrismElementCred = basic_cred(
#     PE_USERNAME,
#     PE_PASSWORD,
#     name="PrismElementCred",
#     type="PASSWORD",
#     default=False,
# )


# Downloadable image for AHV
AHV_CENTOS = vm_disk_package(
    name="AHV_CENTOS", config_file="specs/image/centos-cloudimage.yaml"
)

# Rke Control VMs Service
class ControlPlaneVMs(Service):

    """Control Plane VMs"""

    agent_node_token = CalmVariable.Simple(
        "",
        label="",
        is_mandatory=False,
        is_hidden=False,
        runtime=False,
        description=""
    )

    @action
    def DeployRke2Server(name="DeployRke2Server"):
        CalmTask.Exec.ssh(
            name="Deploy RKE2 Server",
            filename="scripts/rke2_deploy/install_rke2_server.sh",
            cred=NutanixCred
        )
        CalmTask.SetVariable.ssh(
            name="Set RKE2 Agent Node Token",
            filename="scripts/rke2_deploy/set_agent_node_token.sh",
            variables=["agent_node_token"],
            cred=NutanixCred
        )


class ControlPlaneVMs_Package(Package):

    services = [ref(ControlPlaneVMs)]

    @action
    def __install__():
        ControlPlaneVMs.DeployRke2Server(name="Deploy RKE2 Server")


class ControlVM_Resources(AhvVmResources):

    memory = 8
    vCPUs = 4
    cores_per_vCPU = 1
    disks = [AhvVmDisk.Disk.Pci.cloneFromVMDiskPackage(AHV_CENTOS, bootable=True)]
    nics = [AhvVmNic.NormalNic.ingress(os.getenv("IPAM_VLAN"), cluster=os.getenv("PE_CLUSTER_NAME"))]

    guest_customization = AhvVmGC.CloudInit(
        filename="specs/substrate/cloud_init_data.yaml"
    )


class ControlVM(AhvVm):

    name = "@@{RKE2_CLUSTER_NAME}@@-rke2-controlVm-@@{calm_array_index}@@"
    resources = ControlVM_Resources


class ControlPlaneVMs_Substrate(Substrate):

    os_type = "Linux"
    provider_type = "AHV_VM"
    provider_spec = ControlVM

    readiness_probe = readiness_probe(
        connection_type="SSH",
        disabled=False,
        retries="5",
        connection_port=22,
        delay_secs="60",
        credential=ref(NutanixCred),
    )

class ControlPlaneVMs_Deployment(Deployment):

    min_replicas = "1"
    max_replicas = "3"

    packages = [ref(ControlPlaneVMs_Package)]
    substrate = ref(ControlPlaneVMs_Substrate)


# Rke Worker VMs Service
class WorkerNodesVMs(Service):
    """Worker Nodes VMs"""

    @action
    def DeployRke2Agent(name="Deploy RKE2 Agent Node"):
        CalmTask.Exec.ssh(
            name="Deploy RKE2 Agent Node",
            filename="scripts/rke2_deploy/install_rke2_agent.sh",
            cred=NutanixCred
        )


class WorkerNodesVMs_Package(Package):

    services = [ref(WorkerNodesVMs)]

    @action
    def __install__():
      WorkerNodesVMs.DeployRke2Agent(name="Deploy RKE2 Agent Node")


class WorkerVM_Resources(AhvVmResources):

    memory = 8
    vCPUs = 4
    cores_per_vCPU = 1
    disks = [AhvVmDisk.Disk.Pci.cloneFromVMDiskPackage(AHV_CENTOS, bootable=True)]
    nics = [AhvVmNic.NormalNic.ingress(os.getenv("IPAM_VLAN"), cluster=os.getenv("PE_CLUSTER_NAME"))]

    guest_customization = AhvVmGC.CloudInit(
        filename="specs/substrate/cloud_init_data.yaml"
    )


class WorkerVM(AhvVm):

    name = "@@{RKE2_CLUSTER_NAME}@@-rke2-workerVm-@@{calm_array_index}@@"
    resources = WorkerVM_Resources


class WorkerNodesVMs_Substrate(Substrate):

    os_type = "Linux"
    provider_type = "AHV_VM"
    provider_spec = WorkerVM

    readiness_probe = readiness_probe(
        connection_type="SSH",
        disabled=False,
        retries="5",
        connection_port=22,
        delay_secs="60",
        credential=ref(NutanixCred),
    )

class WorkerNodesVMs_Deployment(Deployment):

    min_replicas = "2"
    max_replicas = "10"

    packages = [ref(WorkerNodesVMs_Package)]
    substrate = ref(WorkerNodesVMs_Substrate)

# Rke Admin VMs Service
class AdminNodesVMs(Service):
    """Admin Nodes VMs"""

    dependencies = [
        ref(ControlPlaneVMs_Deployment),
        ref(WorkerNodesVMs_Deployment)
    ]


class AdminNodesVMs_Package(Package):

    services = [ref(AdminNodesVMs)]


class AdminVM_Resources(AhvVmResources):

    memory = 8
    vCPUs = 4
    cores_per_vCPU = 1
    disks = [AhvVmDisk.Disk.Pci.cloneFromVMDiskPackage(AHV_CENTOS, bootable=True)]
    nics = [AhvVmNic.NormalNic.ingress(os.getenv("IPAM_VLAN"), cluster=os.getenv("PE_CLUSTER_NAME"))]

    guest_customization = AhvVmGC.CloudInit(
        filename="specs/substrate/cloud_init_data.yaml"
    )


class AdminVM(AhvVm):

    name = "@@{RKE2_CLUSTER_NAME}@@-rke2-adminVm-@@{calm_array_index}@@"
    resources = AdminVM_Resources


class AdminNodesVMs_Substrate(Substrate):

    os_type = "Linux"
    provider_type = "AHV_VM"
    provider_spec = AdminVM

    readiness_probe = readiness_probe(
        connection_type="SSH",
        disabled=False,
        retries="5",
        connection_port=22,
        delay_secs="60",
        credential=ref(NutanixCred),
    )

class AdminNodesVMs_Deployment(Deployment):

    min_replicas = "1"
    max_replicas = "1"

    packages = [ref(AdminNodesVMs_Package)]
    substrate = ref(AdminNodesVMs_Substrate)

# Rke Admin VM Service
# class AdminVM(Service):
#     """Admin VM"""

#     dependencies = [
#         ref(ControlPlaneVMs_Deployment),
#         ref(WorkerNodesVMs_Deployment)
#     ]


# class AdminVM_Package(Package):

#     services = [ref(AdminVM)]


# class AdminVM_Resources(AhvVmResources):

#     memory = 8
#     vCPUs = 4
#     cores_per_vCPU = 1
#     disks = [AhvVmDisk.Disk.Pci.cloneFromVMDiskPackage(AHV_CENTOS, bootable=True)]
#     nics = [AhvVmNic.NormalNic.ingress(os.getenv("IPAM_VLAN"), cluster=os.getenv("PE_CLUSTER_NAME"))]

#     guest_customization = AhvVmGC.CloudInit(
#         filename="specs/substrate/cloud_init_data.yaml"
#     )


# class AdminVM(AhvVm):

#     name = "@@{RKE2_CLUSTER_NAME}@@-rke2-adminVM-@@{calm_array_index}@@"
#     resources = AdminVM_Resources


# class AdminVM_Substrate(Substrate):

#     os_type = "Linux"
#     provider_type = "AHV_VM"
#     provider_spec = AdminVM

#     readiness_probe = readiness_probe(
#         connection_type="SSH",
#         disabled=False,
#         retries="5",
#         connection_port=22,
#         delay_secs="60",
#         credential=ref(NutanixCred),
#     )


# # class AdminVM_Resources(AhvVmResources):

# #     memory = 8
# #     vCPUs = 4
# #     cores_per_vCPU = 1
# #     disks = [AhvVmDisk.Disk.Pci.cloneFromVMDiskPackage(AHV_CENTOS, bootable=True)]
# #     nics = [AhvVmNic.NormalNic.ingress(os.getenv("IPAM_VLAN"), cluster=os.getenv("PE_CLUSTER_NAME"))]

# #     guest_customization = AhvVmGC.CloudInit(
# #         filename="specs/substrate/cloud_init_data.yaml"
# #     )

# # class AdminVM(AhvVm):

# #     name = "@@{RKE2_CLUSTER_NAME}@@-rke2-adminVm-@@{calm_array_index}@@"
# #     resources = AdminVM_Resources


# # class AdminVM_Substrate(Substrate):

# #     os_type = "Linux"
# #     provider_type = "AHV_VM"
# #     provider_spec = AdminVM

# #     readiness_probe = readiness_probe(
# #         connection_type="SSH",
# #         disabled=False,
# #         retries="5",
# #         connection_port=22,
# #         delay_secs="60",
# #         credential=ref(NutanixCred),
# #     )

# # class AdminVM_Substrate(Substrate):

# #     os_type = "Linux"

# #     provider_spec = read_ahv_spec(
# #         "specs/substrate/adminVm-spec.yaml",
# #         disk_packages={1: AHV_CENTOS}
# #     )
# #     provider_spec.spec["name"] = "@@{RKE2_CLUSTER_NAME}@@-adminVm-@@{calm_array_index}@@"
# #     provider_spec.spec["resources"]["nic_list"][0]["subnet_reference"]["name"] = os.getenv("IPAM_VLAN")
# #     provider_spec.spec["resources"]["nic_list"][0]["subnet_reference"]["uuid"] = os.getenv("IPAM_VLAN_UUID")

# #     readiness_probe = {
# #         "disabled": False,
# #         "delay_secs": "60",
# #         "connection_type": "SSH",
# #         "connection_port": 22,
# #         "credential": ref(NutanixCred),
# #     }


# class AdminVM_Deployment(Deployment):

#     min_replicas = "1"
#     max_replicas = "1"

#     packages = [ref(AdminVM_Package)]
#     substrate = ref(AdminVM_Substrate)


class Default(Profile):

    deployments = [
        AdminNodesVMs_Deployment,
        ControlPlaneVMs_Deployment,
        WorkerNodesVMs_Deployment
    ]

    nutanix_public_key = CalmVariable.Simple.Secret(
        NutanixPublicKey,
        label="OS User Public Key",
        is_hidden=True,
        description="SSH public key for the OS user."
    )

    RKE2_CLUSTER_NAME = CalmVariable.Simple.string(
        os.getenv("RKE2_CLUSTER_NAME"),
        name="RKE2_CLUSTER_NAME",
        label="Rke2 cluster name",
        is_mandatory=True,
        runtime=True
    )

class Rke2_on_AHV(Blueprint):

    services = [
        AdminNodesVMs,
        ControlPlaneVMs,
        WorkerNodesVMs,
    ]
    packages = [
        AdminNodesVMs_Package,
        ControlPlaneVMs_Package,
        WorkerNodesVMs_Package,
        AHV_CENTOS,
    ]
    substrates = [
        AdminNodesVMs_Substrate,
        ControlPlaneVMs_Substrate,
        WorkerNodesVMs_Substrate,
    ]
    profiles = [Default]
    credentials = [
        NutanixCred,
        PrismCentralCred,
        PrismElementCred,
    ]

def main():
    print(Rke2_on_AHV.json_dumps(pprint=True))


if __name__ == "__main__":
    main()
