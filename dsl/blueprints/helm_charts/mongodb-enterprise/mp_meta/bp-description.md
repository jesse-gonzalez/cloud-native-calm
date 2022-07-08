


#### Connectivity Details

MongoDB OpsManager URL:

[http://@@{instance_name}@@.@@{Helm_MongodbEnterprise.nipio_ingress_domain}@@:8080/](http://@@{instance_name}@@.@@{Helm_MongodbEnterprise.nipio_ingress_domain}@@:8080/)

Login with `admin` and mongo_db_password, which can be found via:

`kubectl get secret om-admin-secret -o jsonpath='{.data.Password}' -n mongodb-enterprise | base64 -d && echo`