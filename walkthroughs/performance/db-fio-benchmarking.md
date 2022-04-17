```bash
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: dbench
spec:
  storageClassName: ...
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
---
apiVersion: batch/v1
kind: Job
metadata:
  name: dbench
spec:
  template:
    spec:
      containers:
      - name: dbench
        image: sotoaster/dbench:latest
        imagePullPolicy: IfNotPresent
        env:
          - name: DBENCH_MOUNTPOINT
            value: /data
          - name: FIO_SIZE
            value: 1G
        volumeMounts:
        - name: dbench-pv
          mountPath: /data
      restartPolicy: Never
      volumes:
      - name: dbench-pv
        persistentVolumeClaim:
          claimName: dbench
  backoffLimit: 4
```

https://vitobotta.com/2019/08/06/kubernetes-storage-openebs-rook-longhorn-storageos-robin-portworx/


Product	Random Read/Write IOPS	Read/Write Bandwitdh	Average Latency (usec) Read/Write	Sequential Read/Write	Mixed Random Read/Write IOPS
OpenEBS (cStor)	2475/2893	21.9MiB/s / 52.2MiB/s	2137.88/1861.59	6413KiB/s / 54.2MiB/s	2786/943
Rook (Ceph)	4262/3523	225MiB/s / 141MiB/s	1247.22/2229.20	245MiB/s / 168MiB/s	3047/1021
Rancher Longhorn	7028/4032	302MiB/s / 204MiB/s	1068.23/1303.46	358MiB/s / 236MiB/s	4826/1614
StorageOS	37.7k/7832	443MiB/s / 31.2MiB/s	209.55/559.49	453MiB/s / 107MiB/s	19.1k/6664
Robin	7496/32.7k	29.5MiB/s / 273MiB/s	1119.50/786.46	54.6MiB/s / 270MiB/s	7458/2483
Portworx	58.1k/18.1k	1282MiB/s / 257MiB/s	137.85/256.42	1493MiB/s / 281MiB/s	13.2k/4370
