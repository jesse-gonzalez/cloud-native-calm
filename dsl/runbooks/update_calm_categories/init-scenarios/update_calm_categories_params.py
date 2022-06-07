import os
from calm.dsl.builtins import *
from calm.dsl.config import get_context

CALM_CATEGORIES_LIST = "DataProtection,ServiceMesh,ImageRegistry,Observability,CICD_GitOps,KubernetesDistro,Security,IdentityManagement"

variable_list = [
   { "value": CALM_CATEGORIES_LIST, "context": "Default", "name": "categories_list" }
]