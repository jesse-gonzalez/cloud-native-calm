# External Secrets Operator

## Configuring AWS

1. Configure AWS:
  a. create an IAM policy;
  b. create an IAM group and bind the policy;
  c. create an IAM user and attach it to a group; and
  d. create credentials for that user;
2. Configure External-Secrets
  We first starting by creating a policy named secrets-reader:

```bash
POLICY_ARN=$(aws iam create-policy --policy-name secrets-reader
--policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:ListSecrets",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}' | jq -r .Policy.Arn)
```

We now create a group that will use this policy:

```bash
aws iam create-group --group-name secret-readers
aws iam attach-group-policy --policy-arn $POLICY_ARN --group-name secret-readers
```

Next, we create an username and attach it to the recently created-group:

```bash
aws iam create-user --user-name external-secrets
aws iam add-user-to-group --group-name secret-readers --user-name external-secrets
```

Finally, we create a set of credentials for that user, and add it as a secret in kubernetes:

```bash
aws iam create-access-key --user-name external-secrets > creds.json
ACCESS_KEY=$(cat creds.json | jq -r .AccessKey.AccessKeyId)
SECRET_KEY=$(cat creds.json | jq -r .AccessKey.SecretAccessKey)
kubectl create secret generic aws-secret
--from-literal=access-key=$ACCESS_KEY
--from-literal=secret=$SECRET_KEY
```

Now, let’s add some secrets in our secret Store!

```bash
aws secretsmanager create-secret \
--name super-secret \
--secret-string my-custom-secret \
--region us-east-2
```



### Hashi Vault with External Operator

In this tutorial, we will bring up our own Hashicorp Vault instance, configure
authentication for our workload using Kubernetes Authentication, and then use
External-Secrets to fetch information from our Vault instance.

External-secrets allows configuration of several authentication methods for the
Hashicorp Vault provider. In order to run this example, we need to perform the following
steps:

1. Set up Hashicorp Vault
2. Configure Hashicorp Vault Authentication:
  a. Create a policy;
  b. Configure Kubernetes authentication endpoint;
  c. Create a role;
  d. Bind the role to kubernetes authentication endpoint;
3. Configure External-Secrets

vault policy write demo-policy -<<EOF
path "*"
{ capabilities = ["read"]
}
EOF