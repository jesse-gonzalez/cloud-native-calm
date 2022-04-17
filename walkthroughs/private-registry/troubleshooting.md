# Private Registry Troubleshooting

## Procedure to add regisitry

As of Karbon 2.1.1, this process is done via karbonctl and involves 2 steps (Please refer to the latest guide in case of improvements in this process)

1. Add the registry to Karbon eg:

`~/karbon/karbonctl registry add --port <port> --url https://yyyy --cert-file <pathtocert> -name <registry_name>`

1. Push the registry configuration to the individual k8s cluster like below:

`~/karbon/karbonctl cluster registry add --cluster-name <k8s_cluster_name> --registry-name <registry_name>`

Logs during the addition of private registry

To troubleshoot failure in either of these 2 stages the primary log file is karbon_core.out(/home/nutanix/data/logs/karbon_core.out)

Below is a sample log file that show registry added to Karbon :

    ```bash
    2020-09-27T14:27:07.393Z v1_private_registry_handler.go:71: [INFO] Run Karbon private registry addition prechecks
    2020-09-27T14:27:07.402Z v1_private_registry_handler.go:86: [INFO] Succeeded to add new user private registry in Karbon: Name: xxx, UUID: abcd
    Below is a sample log signature when the registry is pushed into the kubernetes cluster (step2)
    20-09-27T14:29:10.061Z v1_cluster_pvtreg_add_handler.go:37: [INFO] [k8s_cluster=dev1] Add access of user private registry 'reg_http' to k8s cluster 'dev1' 2020-09-27T14:29:10.165Z k8s_pvtreg.go:20: [INFO] [k8s_cluster=dev1] Get configuration commands for private registry 'reg_http' on master node: knode-master-0, IP: x.x.x.a 2020-09-27T14:29:10.196Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.a:22 executing: cat /etc/docker/daemon.json
    2020-09-27T14:29:10.493Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.a:22 successfully executed command: cat /etc/docker/daemon.json
    2020-09-27T14:29:10.493Z k8s_upgrade_utils.go:676: [DEBUG] [k8s_cluster=dev1] Configure private registry: name: reg_http, endpoint: x.x.x.201:5000
    2020-09-27T14:29:10.493Z k8s_pvtreg.go:33: [INFO] [k8s_cluster=dev1] Configuring private registry 'reg_http' on master node: knode-master-0, IP: x.x.x.a 2020-09-27T14:29:10.525Z ssh.go:136: [DEBUG] [k8s_cluster=dev1] Copying /etc/docker/daemon.json to x.x.x.a:22
    2020-09-27T14:29:11.086Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.a:22 executing: sudo systemctl daemon-reload
    2020-09-27T14:29:11.437Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.a:22 successfully executed command: sudo systemctl daemon-reload
    2020-09-27T14:29:11.437Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.a:22 executing: sudo systemctl restart docker
    2020-09-27T14:29:13.365Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.a:22 successfully executed command: sudo systemctl restart docker
    2020-09-27T14:29:13.365Z k8s_pvtreg.go:46: [INFO] [k8s_cluster=dev1] Get configuration commands for private registry 'reg_http' on worker node: node-worker-2, IP: x.x.x.b 2020-09-27T14:29:13.404Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.b:22 executing: cat /etc/docker/daemon.json
    2020-09-27T14:29:13.703Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.b:22 successfully executed command: cat /etc/docker/daemon.json
    2020-09-27T14:29:13.703Z k8s_upgrade_utils.go:676: [DEBUG] [k8s_cluster=dev1] Configure private registry: name: reg_http, endpoint: x.x.x.201:5000
    2020-09-27T14:29:13.703Z k8s_pvtreg.go:59: [INFO] [k8s_cluster=dev1] Configuring private registry 'reg_http' on worker node: node-worker-2, IP: x.x.x.b 2020-09-27T14:29:13.732Z ssh.go:136: [DEBUG] [k8s_cluster=dev1] Copying /etc/docker/daemon.json to x.x.x.b:22
    2020-09-27T14:29:14.281Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.b:22 executing: sudo systemctl daemon-reload
    2020-09-27T14:29:14.662Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.b:22 successfully executed command: sudo systemctl daemon-reload
    2020-09-27T14:29:14.662Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.b:22 executing: sudo systemctl restart docker
    2020-09-27T14:29:16.692Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.b:22 successfully executed command: sudo systemctl restart docker
    2020-09-27T14:29:16.692Z k8s_pvtreg.go:46: [INFO] [k8s_cluster=dev1] Get configuration commands for private registry 'reg_http' on worker node: node-worker-2, IP: x.x.x.c 2020-09-27T14:29:16.731Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.c:22 executing: cat /etc/docker/daemon.json
    2020-09-27T14:29:17.076Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.c:22 successfully executed command: cat /etc/docker/daemon.json
    2020-09-27T14:29:17.076Z k8s_upgrade_utils.go:676: [DEBUG] [k8s_cluster=dev1] Configure private registry: name: reg_http, endpoint: x.x.x.201:5000
    2020-09-27T14:29:17.077Z k8s_pvtreg.go:59: [INFO] [k8s_cluster=dev1] Configuring private registry 'reg_http' on worker node: node-worker-2, IP: x.x.x.c 2020-09-27T14:29:17.105Z ssh.go:136: [DEBUG] [k8s_cluster=dev1] Copying /etc/docker/daemon.json to x.x.x.c:22
    2020-09-27T14:29:17.678Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.c:22 executing: sudo systemctl daemon-reload
    2020-09-27T14:29:18.044Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.c:22 successfully executed command: sudo systemctl daemon-reload
    2020-09-27T14:29:18.044Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.c:22 executing: sudo systemctl restart docker
    2020-09-27T14:29:20.301Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.c:22 successfully executed command: sudo systemctl restart docker
    2020-09-27T14:29:20.302Z k8s_pvtreg.go:46: [INFO] [k8s_cluster=dev1] Get configuration commands for private registry 'reg_http' on worker node: node-worker-0, IP: x.x.x.194 2020-09-27T14:29:20.36Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.194:22 executing: cat /etc/docker/daemon.json
    2020-09-27T14:29:20.766Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.194:22 successfully executed command: cat /etc/docker/daemon.json
    2020-09-27T14:29:20.766Z k8s_upgrade_utils.go:676: [DEBUG] [k8s_cluster=dev1] Configure private registry: name: reg_http, endpoint: x.x.x.201:5000
    2020-09-27T14:29:20.766Z k8s_pvtreg.go:59: [INFO] [k8s_cluster=dev1] Configuring private registry 'reg_http' on worker node: node-worker-0, IP: x.x.x.194 2020-09-27T14:29:20.797Z ssh.go:136: [DEBUG] [k8s_cluster=dev1] Copying /etc/docker/daemon.json to x.x.x.194:22
    2020-09-27T14:29:21.407Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.194:22 executing: sudo systemctl daemon-reload
    2020-09-27T14:29:21.795Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.194:22 successfully executed command: sudo systemctl daemon-reload
    2020-09-27T14:29:21.795Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.194:22 executing: sudo systemctl restart docker
    2020-09-27T14:29:24.15Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.194:22 successfully executed command: sudo systemctl restart docker
    2020-09-27T14:27:07.402Z v1_private_registry_handler.go:86: [INFO] Succeeded to add new user private registry in Karbon: Name: xxx, UUID: abcd
    Below is a sample log signature when the registry is pushed into the kubernetes cluster (step2)
    20-09-27T14:29:10.061Z v1_cluster_pvtreg_add_handler.go:37: [INFO] [k8s_cluster=dev1] Add access of user private registry 'reg_http' to k8s cluster 'dev1' 2020-09-27T14:29:10.165Z k8s_pvtreg.go:20: [INFO] [k8s_cluster=dev1] Get configuration commands for private registry 'reg_http' on master node: knode-master-0, IP: x.x.x.a 2020-09-27T14:29:10.196Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.a:22 executing: cat /etc/docker/daemon.json
    2020-09-27T14:29:10.493Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.a:22 successfully executed command: cat /etc/docker/daemon.json
    2020-09-27T14:29:10.493Z k8s_upgrade_utils.go:676: [DEBUG] [k8s_cluster=dev1] Configure private registry: name: reg_http, endpoint: x.x.x.201:5000
    2020-09-27T14:29:10.493Z k8s_pvtreg.go:33: [INFO] [k8s_cluster=dev1] Configuring private registry 'reg_http' on master node: knode-master-0, IP: x.x.x.a 2020-09-27T14:29:10.525Z ssh.go:136: [DEBUG] [k8s_cluster=dev1] Copying /etc/docker/daemon.json to x.x.x.a:22
    2020-09-27T14:29:11.086Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.a:22 executing: sudo systemctl daemon-reload
    2020-09-27T14:29:11.437Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.a:22 successfully executed command: sudo systemctl daemon-reload
    2020-09-27T14:29:11.437Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.a:22 executing: sudo systemctl restart docker
    2020-09-27T14:29:13.365Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.a:22 successfully executed command: sudo systemctl restart docker
    2020-09-27T14:29:13.365Z k8s_pvtreg.go:46: [INFO] [k8s_cluster=dev1] Get configuration commands for private registry 'reg_http' on worker node: node-worker-2, IP: x.x.x.b 2020-09-27T14:29:13.404Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.b:22 executing: cat /etc/docker/daemon.json
    2020-09-27T14:29:13.703Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.b:22 successfully executed command: cat /etc/docker/daemon.json
    2020-09-27T14:29:13.703Z k8s_upgrade_utils.go:676: [DEBUG] [k8s_cluster=dev1] Configure private registry: name: reg_http, endpoint: x.x.x.201:5000
    2020-09-27T14:29:13.703Z k8s_pvtreg.go:59: [INFO] [k8s_cluster=dev1] Configuring private registry 'reg_http' on worker node: node-worker-2, IP: x.x.x.b 2020-09-27T14:29:13.732Z ssh.go:136: [DEBUG] [k8s_cluster=dev1] Copying /etc/docker/daemon.json to x.x.x.b:22
    2020-09-27T14:29:14.281Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.b:22 executing: sudo systemctl daemon-reload
    2020-09-27T14:29:14.662Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.b:22 successfully executed command: sudo systemctl daemon-reload
    2020-09-27T14:29:14.662Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.b:22 executing: sudo systemctl restart docker
    2020-09-27T14:29:16.692Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.b:22 successfully executed command: sudo systemctl restart docker
    2020-09-27T14:29:16.692Z k8s_pvtreg.go:46: [INFO] [k8s_cluster=dev1] Get configuration commands for private registry 'reg_http' on worker node: node-worker-2, IP: x.x.x.c 2020-09-27T14:29:16.731Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.c:22 executing: cat /etc/docker/daemon.json
    2020-09-27T14:29:17.076Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.c:22 successfully executed command: cat /etc/docker/daemon.json
    2020-09-27T14:29:17.076Z k8s_upgrade_utils.go:676: [DEBUG] [k8s_cluster=dev1] Configure private registry: name: reg_http, endpoint: x.x.x.201:5000
    2020-09-27T14:29:17.077Z k8s_pvtreg.go:59: [INFO] [k8s_cluster=dev1] Configuring private registry 'reg_http' on worker node: node-worker-2, IP: x.x.x.c 2020-09-27T14:29:17.105Z ssh.go:136: [DEBUG] [k8s_cluster=dev1] Copying /etc/docker/daemon.json to x.x.x.c:22
    2020-09-27T14:29:17.678Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.c:22 executing: sudo systemctl daemon-reload
    2020-09-27T14:29:18.044Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.c:22 successfully executed command: sudo systemctl daemon-reload
    2020-09-27T14:29:18.044Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.c:22 executing: sudo systemctl restart docker
    2020-09-27T14:29:20.301Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.c:22 successfully executed command: sudo systemctl restart docker
    2020-09-27T14:29:20.302Z k8s_pvtreg.go:46: [INFO] [k8s_cluster=dev1] Get configuration commands for private registry 'reg_http' on worker node: node-worker-0, IP: x.x.x.194 2020-09-27T14:29:20.36Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.194:22 executing: cat /etc/docker/daemon.json
    2020-09-27T14:29:20.766Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.194:22 successfully executed command: cat /etc/docker/daemon.json
    2020-09-27T14:29:20.766Z k8s_upgrade_utils.go:676: [DEBUG] [k8s_cluster=dev1] Configure private registry: name: reg_http, endpoint: x.x.x.201:5000
    2020-09-27T14:29:20.766Z k8s_pvtreg.go:59: [INFO] [k8s_cluster=dev1] Configuring private registry 'reg_http' on worker node: node-worker-0, IP: x.x.x.194 2020-09-27T14:29:20.797Z ssh.go:136: [DEBUG] [k8s_cluster=dev1] Copying /etc/docker/daemon.json to x.x.x.194:22
    2020-09-27T14:29:21.407Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.194:22 executing: sudo systemctl daemon-reload
    2020-09-27T14:29:21.795Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.194:22 successfully executed command: sudo systemctl daemon-reload
    2020-09-27T14:29:21.795Z ssh.go:151: [DEBUG] [k8s_cluster=dev1] On x.x.x.194:22 executing: sudo systemctl restart docker
    2020-09-27T14:29:24.15Z ssh.go:172: [DEBUG] [k8s_cluster=dev1] On x.x.x.194:22 successfully executed command: sudo systemctl restart docker
    ```

## What happens when a registry is added to the kubernetes cluster?

Depending of wether you added an insecure registry or a secure registry all nodes' docker configuration is modified to enable push / pull of images into the docker registry.

1. If an insecure registry is added, the daemon.json file of docker service is modified with the "insecure-registries" key: value pair.

    ```bash
    [k8s-master-0 ~]$ cat /etc/docker/daemon.json {
        "bridge": "none",
        "graph": "/var/nutanix/docker",
        "insecure-registries": [
        "a.b.c.d:5000"
        ],
        "live-restore": true, "log-driver": "json-file", "log-opts": {
        "max-file": "3", "max-size": "50m"
        },
        "oom-score-adjust": -1000
    ```

1. If a secure registry is added, then a folder under certs.d is created with the name <registry name>:<port> and under that the cert that was added via karbonctl is copied

```bash
[k8s-master-0 ~] $ sudo cat /etc/docker/certs.d/registryabcd\:5000/registry.crt
-----BEGIN CERTIFICATE-----
xxx
xxx
xxx
-----END CERTIFICATE-----
```

## Limistations

As of Karbon 2.1.1 - Registries with authentication is NOT supported. Please refer to latest release notes and karbon admin if this has since limitation has since been changed

## Common Troubleshooting Tools

1. The first log you should check is the karbon_core.out the file for an indication of the issue.Depending on the error - you could further diagnose the issue
1. You can use karbonctl to list registries added to karbon and those that are pushed to a particular kubernetes cluster

    ```
    nutanix@PCVM:~$ ./karbon/karbonctl registry list
    Name aaaaaaaa bbbbbbbb.
    UUID uuuuuu uuuuuu
    Endpoint x.x.x.x:5000 y.y.y.y:5000
    --cluster-name <clustername> Endpoint
    x.x.x.x:5000
    nutanix@PCVM:~$ ./karbon/karbonctl cluster registry list Name UUID
    aaaaaaaa uuuuuu
    ```

1. Another quick check we can do from Prism Central to check if the certs used to add the registry is valid as well as check for other issues like communication is calling normal v2 API endpoint of the registry server Below issues suggests that the cert is valid however we are not authorized to access the registry. This indicates that the registry is restricted(and hence not yet supported as of karbon 2.1.1)

    ```
    PCVM~/ curl -v https://<registry_server>:<registry_server_port>/v2/_catalog --CAcert cert.pem
    * Trying egistry>...
    * TCP_NODELAY set
    * Connected to <registry_server> (<registry_server>) port <registry_server_port> (#0)
    * ALPN, offering h2
    * ALPN, offering http/1.1
    * Cipher selection: ALL:!EXPORT:!EXPORT40:!EXPORT56:!aNULL:!LOW:!RC4:@STRENGTH
    * successfully set certificate verify locations:
    * CAfile: cert.pem
    CApath: none
    * TLSv1.2 (OUT), TLS handshake, Client hello (1):
    * TLSv1.2 (IN), TLS handshake, Server hello (2):
    * TLSv1.2 (IN), TLS handshake, Certificate (11):
    * TLSv1.2 (IN), TLS handshake, Server key exchange (12):
    * TLSv1.2 (IN), TLS handshake, Server finished (14):
    * TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
    * TLSv1.2 (OUT), TLS change cipher, Client hello (1):
    * TLSv1.2 (OUT), TLS handshake, Finished (20):
    * TLSv1.2 (IN), TLS change cipher, Client hello (1):
    * TLSv1.2 (IN), TLS handshake, Finished (20):
    * SSL connection using TLSv1.2 / ECDHE-RSA-AES128-GCM-SHA256
    * ALPN, server accepted to use h2
    * Server certificate:
    * subject: C=xx; ST=N/A; L=N/A; O=xx; CN=<registry_server>
    * start date: Sep 28 01:59:58 2020 GMT
    * expire date: Sep 28 01:59:59 2022 GMT
    * subjectAltName: host "<registry_server>" matched cert's IP address!
    * subject: C=xx; ST=N/A; L=N/A; O=xx; CN=<registry_server>
    * SSL certificate verify ok.
    * Using HTTP2, server supports multi-use
    * Connection state changed (HTTP/2 confirmed)
    * Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
    * Using Stream ID: 1 (easy handle 0x7fae2a002200)
    > GET /v2/_catalog HTTP/2
    > Host: <registry_server>:<registry_server_port>
    > User-Agent: curl/7.54.0
    > Accept: */* >
    * Connection state changed (MAX_CONCURRENT_STREAMS updated)!
    < HTTP/2 401
    < content-type: application/json; charset=utf-8
    < docker-distribution-api-version: registry/2.0
    < www-authenticate: Basic realm="Registry Realm"
    < x-content-type-options: nosniff
    < content-length: 145
    < date: Mon, 28 Sep 2020 02:01:37 GMT
    <
    {"errors":[{"code":"UNAUTHORIZED","message":"authentication required","detail":[{"Type":"registry","Class":"","Name":"catalog","Action":"*"}]}]}
    ```

1. Another tool that might be handy is to use openssl and check the certificate details (to verify items like CA,Subject Alt Name,etc). There are a lot of content online w.r.t using openssl - below is one such command that can be used to check the certificate

    ```
    $ openssl x509 -in cert.pem -noout -text
    Certificate: Data:
    .
    .
    .
    Version: 3 (0x2) Serial Number:
    d8:7a:ef:e5:f3:fe:b5:93
    Signature Algorithm: sha256WithRSAEncryption
    Issuer: C=xx, ST=N/A, L=N/A, O=NTNX, CN=xxx
    ```

## EXAMPLE: Failure to add registry due to IP not added as valid SAN address

```bash
PCVM~: ~/karbon/karbonctl registry add --port 1234 --url a.c.c. --cert-file cacert.pem --name reg
Failed to add new private registry to Karbon: Failed to pass private registry addition prechecks: Failed to connect to private registry with given configuration. Please check logs.
In this case - we see no clear indication from the error message. We can further check karbon_core.out logs to get a clue
karbon_core.out:
2020-09-27T15:03:10.849Z registry.go:79: [DEBUG] [PrivateRegistryConnectivityCheck]: Failed to connect to private registry with query: https://xxxx:bbbb/v2/ and err: Get https://xxxxx:<port>/v2/: x509: cannot validate certificate fo 2020-09-27T15:03:10.849Z common_handler.go:167: [ERROR] Error type: Private Registry Create, message: Failed to add new private registry to Karbon: Failed to pass private registry addition prechecks: Failed to connect to private reg
```

You can verify this by connecting to the private registry using openssl and valdate the server certificate:

```bash
openssl s_client -connect <registery_server_ip>:<port> -CAcert <cert used as part of karbonctl registry add> .

Server certificate
-----BEGIN CERTIFICATE-----
x
x
x
-----END CERTIFICATE------- .
.

Verify return code: xxxx. ###(Certificate validation error - if no error - you should get OK)
```

With the above command - you could copy the certificate section(The text including and between the Begin and End Certificate) and save it to a file. You could later open it to review if it has IP address as valid SAN

```bash
$ openssl x509 -in certstest.pem -noout -text .
.
.
X509v3 extensions:
X509v3 Subject Alternative Name:
IP Address:<ip_address>
```

https://medium.com/@antelle/how-to-generate-a-self-signed-ssl-certificate-for-an-ip-address-f0dd8dddf754
