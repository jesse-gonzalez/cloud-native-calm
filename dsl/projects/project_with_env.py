
import os
from calm.dsl.builtins import Project, read_local_file, readiness_probe
from calm.dsl.builtins import Provider, Ref, ref
from calm.dsl.builtins import Substrate, Environment
from calm.dsl.builtins import AhvVmDisk, AhvVmNic, AhvVmGC
from calm.dsl.builtins import basic_cred, AhvVmResources, ahv_vm
from calm.dsl.config import get_context


ContextObj = get_context()
init_data = ContextObj.get_init_config()


NTNX_ACCOUNT_NAME = "NTNX_LOCAL_AZ"
NTNX_SUBNET = "Primary"
NTNX_SUBNET_CLUSTER = "PHX-SPOC019-3"
CENTOS_CI = "CentOS7.qcow2"
AWS_ACCOUNT_NAME = "aws_account"
AZURE_ACCOUNT_NAME = "azure_account"
GCP_ACCOUNT_NAME = "gcp_account"
VMWARE_ACCOUNT_NAME = "vmware_account"
K8S_ACCOUNT_NAME = "k8s_account"
# USER = "sspuser1@systest.nutanix.com"
USER = "adminuser01@ntnxlab.local"
# GROUP = "cn=ssp admins,cn=users,dc=ntnxlab,dc=local"
VCPUS = 1
STORAGE = 2  # GiB
MEMORY = 1  # GiB


# this section has been added to allow environment configuration
# specifically, this creates a Calm credential
# at least one credential is mandatory when configuring a project environment
CENTOS_KEY = read_local_file("nutanix_key")
CENTOS_PUBLIC_KEY = read_local_file("nutanix_public_key")

Centos = basic_cred("centos", CENTOS_KEY, name="Centos", type="KEY", default=True)

class MyAhvLinuxVmResources(AhvVmResources):

    memory = 4
    vCPUs = 2
    cores_per_vCPU = 1
    disks = [
        AhvVmDisk.Disk.Scsi.cloneFromImageService(CENTOS_CI, bootable=True),
    ]
    nics = [AhvVmNic(NTNX_SUBNET)]

    guest_customization = AhvVmGC.CloudInit(
        config={
            "users": [
                {
                    "name": "centos",
                    "ssh-authorized-keys": [CENTOS_PUBLIC_KEY],
                    "sudo": ["ALL=(ALL) NOPASSWD:ALL"],
                }
            ]
        }
    )

    serial_ports = {0: False, 1: False, 2: True, 3: True}

class AhvVmSubstrate(Substrate):
    """AHV VM config given by reading a spec file"""

    provider_spec = ahv_vm(
        resources=MyAhvLinuxVmResources,
        categories={"AppFamily": "Backup", "AppType": "Default"},
    )
    readiness_probe = readiness_probe(disabled=True)


class ProjEnvironment1(Environment):
    """Sample project environment"""

    substrates = [AhvVmSubstrate]
    credentials = [Centos]
    providers = [
        Provider.Ntnx(
            account=Ref.Account(NTNX_ACCOUNT_NAME),
            subnets=[
                Ref.Subnet(
                    name=NTNX_SUBNET,
                    cluster=NTNX_SUBNET_CLUSTER,
                )
            ],
        ),
        # Provider.Aws(account=Ref.Account(AWS_ACCOUNT_NAME)),
        # Provider.Azure(account=Ref.Account(AZURE_ACCOUNT_NAME)),
    ]


class SampleDslProject(Project):
    """
    Sample DSL Project with environments
    NOTE: AWS account is added to environment module and not to project module, 
        By default project command will also attach the accounts attached to any environment
        to this project
    """

    providers = [
        Provider.Ntnx(
            account=Ref.Account(NTNX_ACCOUNT_NAME),
            subnets=[
                Ref.Subnet(
                    name=NTNX_SUBNET,
                    cluster=NTNX_SUBNET_CLUSTER,
                )
            ],
        ),
        # Provider.Gcp(account=Ref.Account(GCP_ACCOUNT_NAME)),
        # Provider.Vmware(account=Ref.Account(VMWARE_ACCOUNT_NAME)),
        # Provider.K8s(account=Ref.Account(K8S_ACCOUNT_NAME)),
    ]

    #users = [Ref.User(USER)]

    envs = [ProjEnvironment1]
    default_environment = ref(ProjEnvironment1)
    quotas = {
        "vcpus": 1,
        "storage": 2,
        "memory": 1,
    }
