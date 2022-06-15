import os
from calm.dsl.builtins import *
from calm.dsl.config import get_context

variable_list = [
   { "value": os.getenv("DOMAIN_NAME"), "context": "Default", "name": "domain_name" },
   { "value": os.getenv("DNS"), "context": "Default", "name": "dns_server" },
   { "value": os.getenv("BASTION_WS_ENDPOINT_SHORT"), "context": "Default", "name": "dns_name" },
   { "value": os.getenv['BASTION_HOST_SVM_IP'], "context": "Default", "name": "dns_ip_address" },
   { "value": "Create", "context": "Default", "name": "update_type" }
]